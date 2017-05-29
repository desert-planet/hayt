# A scale that means almost literally nothing
# We'll track your current mood, and it over time
util = require 'util'

Redis = require 'redis'
Url = require 'url'


module.exports = (robot) ->
  robot.respond /(?:rc)\s+(\d+.?\d*)$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    score = msg.match[1]

    new RCScore(who).set score, (err, res) ->
      msg.reply "TODO(sshirokov): rc: #{who} => #{score}"
      msg.reply "Err: #{err} Res: #{util.inspect res}"


# Bases and utilities
class RCError extends Error
class RCBase
  prefix: "rc:"

  # Return a correctly prefixed redis key
  key: (name) ->
    "#{@prefix}:#{name}"

  constructor: ->
    # Connect to redis
    info = Url.parse process.env.REDISTOGO_URL or
      process.env.REDISCLOUD_URL or
      process.env.BOXEN_REDIS_URL or
      'redis://localhost:6379'
    @storage = Redis.createClient(info.port, info.hostname)
    @storage.auth info.auth.split(":")[1] if info.auth

class RCScore extends RCBase
  constructor: (@who=null, @options={}) -> super()

  set: (score, cb) ->
    cb(new RCError("Setting score of nobody")) unless @who
    now = Date.now()

    @storage.multi([
      ["ZADD", @key("latest"), now, @who],
      ["ZADD", @key("#{@who}:scores"), score, now],
    ]).exec (err, replies) =>
      return cb(err) if err
      # Update the internal state if we succeed
      # So that .get is free
      @info = {score: score, when: now}
      cb(false, @info)

  score: -> @info?.score
  timestamp: -> @info?.timestamp

  fetch: (cb) ->
    throw RCError("TODO(sshirokov): Update the latest scores and stamps, the call the CB")
