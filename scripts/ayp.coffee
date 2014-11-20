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
    msg.reply "HOLD YOUR FUCKING HORSES"

class PantsBuffer
  # The zset that stores the buffer of logs
  key: -> "#{@options.prefix}:buffer"

  # Store and timestamp `who` saying `what`.
  # Also trims the set with `@trim` to the configured
  # length
  store: (who, what) ->
    do @trim
    stamp = Date.now()
    body = "#{who}: #{what}"
    console.log "=> Storing #{@key()} => #{stamp} @ #{who}: #{what}"
    @storage.zadd [@key(), stamp, body], (err, response) =>
       return console.log "WARNING: Failed to store: '#{who}: #{what}' @ #{stmp}: #{err}" if err

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
    console.log "=> Trimming #{@key()} 0 #{end} (Now: #{Date.now()})"
    @storage.zremrangebyscore @key(), 0, end, (err, response) =>
      return console.log "WARNING: Failed to trim '#{@key()}': #{err}" if err

  # Constructor for `PantsBuffer`
  #
  # Options:
  #   prefix: The redis prefix to use for the ringbuffer.
  #   adys:   The number of days to keep logs in the buffer
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
