# A scale that means almost literally nothing
# We'll track your current mood, and it over time
util = require 'util'

Redis = require 'redis'
Url = require 'url'
prettyMs = require 'pretty-ms'
wolfram = require 'wolfram'
sparkline = require 'sparkline'

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
  ##  - .rc for Someone recently
  ##     Get RC's from the past interval
  ##
  ##  - .rc for Someone graph
  ##     Show a spark graph for the past bit for someone
  ##
  ##  + Intervals for interval operations that use time can be specified as
  ##    hours or days as "3h" or "5d", etc.
  robot.respond /(?:rc)\s+for\s([^\s]+)\s*([^\s]+.*)?\s*$/i, (msg) ->
    who = msg.match[1].toLowerCase()
    options = (msg.match[2] ? "").toLowerCase()

    if not options
      new RCScore(who).fetch (err, self) =>
        if self.score == null
          return msg.reply "Never heard of '#{who}'"
        distance = Date.now() - self.timestamp
        return msg.reply "#{who} was at #{self.score} something like #{prettyMs distance} ago"
    else
      # Do we have an interval ready?
      interval = if match = options.match /(\d+)([hmd])/i
        [count, unit, ...] = match[1...]
        count = parseInt(count)
        console.log "Count: #{count} unit #{unit}"
        switch unit
          when 'm' then count * 60
          when 'd' then count * 24 * 60 * 60
          when 'h' then count * 60 * 60
      interval ||= 3 * 60 * 60
      interval *= 1000 # To ms
      start = Date.now() - interval

      if options.match /recent/
        new RCScore(who).fetch_recent start, (err, self) =>
          return msg.reply "That fucking blew up: #{err}" if err
          if self.recent.length
            latest = self.recent[..].pop()
            age = Date.now() - latest.timestamp
            recent = (s.score for s in self.recent[-5...]).join ', '
            return msg.reply "Recent RCs for #{who}: #{recent}, latest from #{prettyMs age} total of #{self.recent.length} in the last #{prettyMs interval}"
          return msg.reply "There wasn't enough data :("
      else if options.match /graph/
        new RCScore(who).fetch_recent start, (err, self) =>
          return msg.reply "That fucking blew up: #{err}" if err
          return msg.reply "Can't draw with nothing ;(" if not self.recent.length

          if self.recent.length
            first = self.recent[0]
            latest = self.recent[..].pop()
            age = Date.now() - latest.timestamp
            span = latest.timestamp - first.timestamp
            recent = (parseFloat(s.score) for s in self.recent[-140...]).filter (score) ->
              not isNaN(score)
            [min, max] = [Math.min(recent...), Math.max(recent...)]
            scaled = recent.map (v) -> v * 10
            return msg.reply "#{who} - #{sparkline scaled} - #{scaled.length} samples, range #{min}-#{max}, spans #{prettyMs span}, latest #{prettyMs age} old"
      else
        return msg.reply "What the fuck does #{options} even mean?"

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
    decimals = res.filter (e) ->
      e.title == 'Result' or
      e.title.match /Decimal approximation/
    console.log("Result options: %j", decimals.map (e) -> [e.title, e?.subpods?[0]?.value])
    for option in decimals
      console.log("Trying option #{option.title}")
      decimal = option.subpods?[0]?.value
      decimal = parseFloat(decimal)
      if not isNaN(decimal)
        return cb(false, decimal)
    return cb("Couldn't make #{expr} into decimal", null)

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
    console.log "Fetching by time: #{time} for #{@who}"
    @storage.zscore @key("#{@who}:scores"), time, (err, score) =>
      return cb(err, this) if err
      [@score, @timestamp] = [score, time]
      cb(false, this)

  # Invoke callback as:
  # cb(error, self) with all RCScores found stored as an array
  # in @recent fully updated.
  # `start` - the furthest back to look for RCScores
  # `cb` - callback invoked as cb(err, self) with error == false on success
  fetch_recent: (start, cb) =>
    console.log "fetch_recent: #{start} for #{@who}"
    @storage.zrevrangebyscore @key("#{@who}:times"), '+inf', start, (err, res) =>
      return cb(err, this) if err
      # If no error happeend, but no results came back
      # we're still done
      if not res.length
        @recent = []
        return cb(false, this)
      jobs = ({result: null, error: false, request: time} for time in res)
      hasFailed = ->
        jobs.filter((j) -> j.error).length
      hasFinished = ->
        finished = jobs.filter((j) -> j.result).length
        res = finished == jobs.length
        console.log "Finish? #{res}: #{finished}/#{jobs.length}"
        res
      for job in jobs
        do (job) => new RCScore(@who).fetch_by_time parseInt(job.request), (err, self) =>
          if not err
            console.log "Fetched: Score: #{self.score} @ #{self.timestamp}"
          else
            console.err "Error in fetch: #{err}"
          # If we are the first error, call the callback, and mark the job failed
          # so that future jobs can skip execution. We'll pass on whatever we already
          # computed in the callback.
          if err and not hasFailed()
            cb(err, self)
          job.error = err if err
          # If we've already failed, stop
          return if hasFailed()
          # Store the result
          job.result = self
          # "Return" if we're done
          if hasFinished()
            @recent = (j.result for j in jobs).reverse()
            console.log "Recent: #{@recent.map (r) -> [r.score, r.timestamp]}"
            return cb(false, this)
