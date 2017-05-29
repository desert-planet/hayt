# A scale that means almost literally nothing
# We'll track your current mood, and it over time

Redis = require 'redis'

module.exports = (robot) ->
  robot.respond /(?:rc)\s+(\d+.?\d*)$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    score = msg.match[1]

    return msg.reply "TODO(sshirokov): Not fucking yet: rc: #{who} => #{score}"

class RCError extends Error

class RollCall
  # Constructor for `RollCall`
  #
  # TODO(sshirokov): Describe params
  constructor: (@who=null, @options={}) ->
    # Connect to redis
    info = Url.parse process.env.REDISTOGO_URL or
      process.env.REDISCLOUD_URL or
      process.env.BOXEN_REDIS_URL or
      'redis://localhost:6379'
    @storage = Redis.createClient(info.port, info.hostname)
    @storage.auth info.auth.split(":")[1] if info.auth
    
    throw RCError("TODO(sshirokov): More?")
