# Scaffolds for AYP
# That good, handmade shit.

Url = require 'url'
Redis = require 'redis'

module.exports = (robot) ->
  buffer = new PantsBuffer()

  # We listen to everything.
  # Everything.
  robot.catchAll (msg) ->
    return if !msg.message.text

    buffer.store(
      msg.message.user.name.trim(),
      msg.message.text.trim()
    )

  # Ask for what currently serves as "output"
  robot.respond /ayp(\s+(me)?)?\s*$/i, (msg) ->
    buffer.get 6, (err, lines) ->
      count = 0
      for log in lines
        do (log) ->
          [who, what] = log
          msg.reply "=#{count += 1}> [#{who}] '#{what}'"

# Make any changes required to the name
filterName = (name) ->
  name

# Make any changes required to the text
filterText = (text) ->
  # Twitter length, then truncate with `...`
  limit = 140
  suffix = '...'
  if text.length > limit
    text = text.slice(0, (limit - suffix.length))
    text += suffix

  # Urls are secret. Not for you. Not for anyone.
  text = text.replace(/(https?:\/\/[^\s]+)/, "[redacted]")

  text

# PantsBuffer is the abstraction of "The Logs".
#
# It keeps a ringbuffer of logs configured on construction
# and fed by `.store(who, what)` which computes timestamps
# and allows you to get n random lines with `.get`.
#
# Fetches are asyncronous, because NODE JS NINJA REDIS
class PantsBuffer
  # The zset that stores the buffer of logs
  key: -> "#{@options.prefix}:buffer"

  # Get an array of `n` lines from the log.
  # When data arrives the callback will be called
  # as cb(err, data). `err` will be only be set on
  # error. `res` will be an array of lines.
  get: (n=6, callback=((err, res) ->)) ->
    # This wraps the supplied `callback` to process the resulting
    # list into a list of [[who, what], ...] to save the consumer
    # a step.
    # In case of error, the result is untouched
    resultWrapper = (err, res) ->
      return callback(err, res) if err

      res = res.map (line) ->
        [_, who, what] = line.match(/^([^\s]+): (.+)$/)
        [filterName(who), filterText(what)]
      callback(err, res)

    @storage.zcard @key(), (err, count) =>
      return console.error("Failed zcard of #{@key()}: #{err}") if err

      # If we don't have enough lines, return all the lines we have
      return @storage.zrange @key(), 0, -1, resultWrapper if count <= n

      # Get a random offset where we can grab n lines otherwise
      start = Math.round(Math.random() * (count - n))
      return @storage.zrange @key(), start, (start + (n - 1)), resultWrapper


  # Store and timestamp `who` saying `what`.
  # Also trims the set with `@trim` to the configured
  # length
  store: (who, what) ->
    do @trim
    stamp = Date.now()
    body = "#{who}: #{what}"
    @storage.zadd [@key(), stamp, body], (err, response) =>
       return console.error "WARNING: Failed to store: '#{who}: #{what}' @ #{stmp}: #{err}" if err

  # Trim the logging buffer to `@options.days` since we don't care about
  # being a general purpose logger.
  trim: ->
    days = @options.days
    end = Date.now() - (
      days *  # Days
      24   *  # Hours
      60   *  # Minutes
      60   *  # Seconds
      1000    # ms
    )
    @storage.zremrangebyscore @key(), 0, end, (err, response) =>
      return console.error "WARNING: Failed to trim '#{@key()}': #{err}" if err

  # Constructor for `PantsBuffer`
  #
  # Options:
  #   prefix: The redis prefix to use for the ringbuffer.
  #   days:   The number of days to keep logs in the buffer
  constructor: (@options={}) ->
    # Connect to redis
    info = Url.parse process.env.REDISTOGO_URL or
      process.env.REDISCLOUD_URL or
      process.env.BOXEN_REDIS_URL or
      'redis://localhost:6379'
    @storage = Redis.createClient(info.port, info.hostname)
    @storage.auth info.auth.split(":")[1] if info.auth

    # Defaults for options
    @options.prefix ?= "ayp:"
    @options.days   ?= 3
