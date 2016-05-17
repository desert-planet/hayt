Redis = require 'redis'
Url = require 'url'

POO_TRACKER_KEY = "poops"
POO_LATEST_KEY = "poops:latest_message"

info = Url.parse process.env.POO_REDIS_URL
redis_client = Redis.createClient(info.port, info.hostname)
redis_clent.auth info.auth.split(":")[1] if info.auth

module.exports = (robot) ->
  setInterval ->
    checkRedisForShit()
  , 1000

  checkRedisForShit ->
    redis_clent.lindex POO_TRACKER_KEY, -1 -> (err, reply)
      return console.error("Failed lindex with key '#{POO_TRACKER_KEY}' and index -1: #{err}") if err
      return if reply == null

      robot.messageRoom "#arrakis", "#{reply}"
      redis_clent.ltrim POO_TRACKER_KEY, -1, -1
      redis_clent.lpop POO_TRACKER_KEY
      redis_clent.set POO_LATEST_KEY, reply

  robot.respond /poo tracker( me)?/i, (res) ->
    redis_client.get POO_LATEST_KEY -> (err, reply)
      return res.send "Latest poo: #{reply}"
