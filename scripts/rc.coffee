# A scale that means almost literally nothing
# We'll track your current mood, and it over time
util = require 'util'

Redis = require 'redis'
Url = require 'url'
prettyMs = require 'pretty-ms'

# Robot hooks
module.exports = (robot) ->
  robot.respond /(?:rc)\s+for\s([^\s]+)\s*$/i, (msg) ->
    who = msg.match[1].toLowerCase()
    new RCScore(who).fetch (err, info, self) =>
      {score: score, when: stamp} = info
      if score == null
        return msg.reply "Never heard of '#{who}'"
      distance = Date.now() - stamp
      msg.reply "#{who} was at #{score} something like #{prettyMs distance} ago"

  robot.respond /(?:rc)\s+(\d+.?\d*)$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    score = msg.match[1]

    new RCScore(who).set score, (err, res, self) ->
      return msg.reply "Whoooops: #{err}" if err
      msg.reply "Your RC is now #{res.score}"

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

# Drivers
class RCScore extends RCBase
  constructor: (@who, @options={}) -> super()

  set: (score, cb) =>
    now = Date.now()

    @storage.multi([
      ["ZADD", @key("latest"), now, @who],
      ["ZADD", @key("#{@who}:scores"), score, now],
      ["ZADD", @key("#{@who}:times"), score, now],
    ]).exec (err, replies) =>
      return cb(err, null, this) if err
      # Update the internal state if we succeed
      # So that .get is free
      @info = {score: score, when: now}
      cb(false, @info, this)

  score: -> @info?.score
  timestamp: -> @info?.timestamp

  # TODO(sshirokov): Take a timestamp to lookup by instead of just latest
  fetch: (cb) =>
    @storage.zscore @key("latest"), @who, (err, stamp) =>
      return cb(err, null, this) if err
      @storage.zscore @key("#{@who}:scores"), stamp, (err, score) =>
        return cb(err, null, this) if err
        @info = {score: score, when: stamp}
        cb(false, @info, this)
