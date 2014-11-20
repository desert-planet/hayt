# Scaffolds for AYP
# That good, handmade shit.

Url = require 'url'
Redis = require 'redis'

module.exports = (robot) ->
  # Configure redis the same way that redis-brain does.
  info = Url.parse process.env.REDISTOGO_URL or
    process.env.REDISCLOUD_URL or
    process.env.BOXEN_REDIS_URL or
    'redis://localhost:6379'
  client = Redis.createClient(info.port, info.hostname)
  client.auth info.auth.split(":")[1] if info.auth

  buffer = new PantsBuffer(client)

  # We listen to everything.
  # Everything.
  robot.catchAll (msg) ->
    return if !msg.message.text

    buffer.store(
      msg.message.user.name.trim(),
      msg.message.text.trim()
    )

  robot.respond /ayp(\s+(me)?)?\s*$/i, (msg) ->
    msg.reply "HOLD YOUR FUCKING HORSES"

class PantsBuffer
  constructor: (@storage, @options={}) ->
    @options.prefix ?= "ayp:"

  key: -> "#{@options.prefix}:buffer"

  store: (who, what) ->
    do @trim
    stamp = Date.now()
    body = "#{who}: #{what}"
    console.log "=> Storing #{@key()} => #{stamp} @ #{who}: #{what}"
    @storage.zadd [@key(), stamp, body], (err, response) =>
       return console.log "WARNING: Failed to store: '#{who}: #{what}' @ #{stmp}: #{err}" if err

  trim: ->
    days = 3
    end = Date.now() - (
      days *  # Days
      24   *  # Hours
      60   *  # Minutes
      60   *  # Seconds
      1000    # ms
    )
    console.log "=> Trimming #{@key()} 0 #{end}"
    @storage.zremrangebyrank @key(), 0, end, (err, response) =>
      return console.log "WARNING: Failed to trim '#{@key()}': #{err}" if err
