# A scale that means almost literally nothing
# We'll track your current mood, and it over time
util = require 'util'

Redis = require 'redis'
Url = require 'url'
prettyMs = require 'pretty-ms'
wolfram = require 'wolfram'

## Config
##
WOLFRAM_APPID = process.env.WOLFRAM_APPID

## Robot hooks
##
module.exports = (robot) ->
  ## Check out someone's RC or take a look
  ## at some graphs.
  ##
  ##  - .rc for Someone
  ##     Get the last RC for a name
  ##
  ##  - .rc recently # TODO(sshirokov): <--
  ##     Get RC's from the past interval
  ##
  ##  - .rc for Someone graph #TODO(sshirokov): <--
  ##     Show a spark graph for the past bit for someone
  ##
  ##  + Intervals for interval operations that use time can be specified as
  ##    hours or days as "3h" or "5d", etc.
  robot.respond /(?:rc)\s+for\s([^\s]+)\s*([^\s]+.*)?\s*$/i, (msg) ->
    who = msg.match[1].toLowerCase()
    options = (msg.match[2] ? "").toLowerCase()

    new RCScore(who).fetch (err, self) =>
      if self.score == null
        return msg.reply "Never heard of '#{who}'"
      distance = Date.now() - self.timestamp
      msg.reply "#{who} was at #{self.score} something like #{prettyMs distance} ago"

  ## Check in for Roll Call
  ##  - .rc expression
  ##    Check in your current RC value, however you choose to express it
  ##    It will be stored as a floating point decimal number.
  robot.respond /(?:rc)\s+([^\s]+)\s*$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    expr = msg.match[1]

    submitScore = (score) ->
      new RCScore(who).set score, (err, self) ->
        return msg.reply "Whoooops: #{err}" if err
        msg.reply "Your RC is now #{self.score}"

    if isNaN(Number(expr))
      console.log("Trying to turn '#{expr}' to decimal with wolfram")
      wolframToDecimal expr, (err, score) ->
        return msg.reply "Oh no: #{err}" if err
        submitScore score
    else
      submitScore expr

## Bases and utilities
##
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

# Try to use wolfram alpha to evaluate expr
# into a decimal form and then invoke cb(err, result)
wolframToDecimal = (expr, cb) ->
  return cb(new RCError("No Wolfram keys"), null) unless WOLFRAM_APPID
  client = wolfram.createClient(WOLFRAM_APPID)
  client.query expr, (err, res) ->
    return cb(err, null) if err
    console.log("Results: %j", res.map (e) -> e.title)
    decimal = res.filter (e) ->
      e.title == 'Result' or
      e.title.match /Decimal approximation/
    console.log("Result options: %j", decimal.map (e) -> [e.title, e?.subpods?[0]?.value])
    decimal = decimal?[0]?.subpods?[0]?.value
    decimal = parseFloat(decimal)
    return cb("Couldn't make #{expr} into decimal", null) if isNaN(decimal)
    cb(false, decimal)

## Drivers
##
class RCScore extends RCBase
  constructor: (@who, @options={}) -> super()

  set: (score, cb) =>
    now = Date.now()

    @storage.multi([
      ["ZADD", @key("latest"), now, @who],
      ["ZADD", @key("#{@who}:scores"), score, now],
      ["ZADD", @key("#{@who}:times"), now, now],
    ]).exec (err, replies) =>
      return cb(err, this) if err
      [@score, @timestamp] = [score, now]
      cb(false, this)

  fetch: (cb) =>
    @storage.zscore @key("latest"), @who, (err, stamp) =>
      return cb(err, this) if err
      @fetch_by_time stamp, cb

  fetch_by_time: (time, cb) =>
    @storage.zscore @key("#{@who}:scores"), time, (err, score) =>
      return cb(err, this) if err
      [@score, @timestamp] = [score, time]
      cb(false, this)
