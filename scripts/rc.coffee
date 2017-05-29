# A scale that means almost literally nothing
# We'll track your current mood, and it over time
util = require 'util'

Redis = require 'redis'
Url = require 'url'


module.exports = (robot) ->
  robot.respond /(?:rc)\s+for\s([^\s]+)$/i, (msg) ->
    who = msg.match[1]
    new RCScore(who).fetch (err, info, self) =>
      msg.reply "TODO(sshirokov): Err: #{err} Info: #{util.inspect info}: Self: #{self}"

  robot.respond /(?:rc)\s+(\d+.?\d*)$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    score = msg.match[1]

    new RCScore(who).set score, (err, res, self) ->
      msg.reply "TODO(sshirokov): rc: #{who} => #{score}"
      msg.reply "Err: #{err} Res: #{util.inspect res} -- #{self}"


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
  constructor: (@who, @options={}) -> super()

  set: (score, cb) =>
    now = Date.now()

    @storage.multi([
      ["ZADD", @key("latest"), now, @who],
      ["ZADD", @key("#{@who}:scores"), score, now],
    ]).exec (err, replies) =>
      return cb(err, null, this) if err
      # Update the internal state if we succeed
      # So that .get is free
      @info = {score: score, when: now}
      cb(false, @info, this)

  score: -> @info?.score
  timestamp: -> @info?.timestamp

  fetch: (cb) =>
    @storage.zscore @key("latest"), @who, (err, stamp) =>
      return cb(err, null, this) if err
      # Use `stamp` to fetch from `@key("@{who}:scores")`
      cb(new RCError("TODO(sshirokov): Got score of #{stamp} for #{@who}"), null, this)
