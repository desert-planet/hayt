Redis = require 'redis'
Url = require 'url'

POO_TRACKER_KEY = "poops"
POO_LATEST_KEY = "poops:latest_message"

info = Url.parse process.env.POO_REDIS_URL
redis_client = Redis.createClient(info.port, info.hostname)
redis_clent.auth info.auth.split(":")[1] if info.auth

module.exports = (robot) ->
  checkRedisForShit ->
    redis_clent.lindex POO_TRACKER_KEY, -1 -> (err, reply)
      return console.error("Failed lindex with key '#{POO_TRACKER_KEY}' and index -1: #{err}") if err
      return if reply == null

      robot.messageRoom "#arrakis", "#{reply}"

      # clean up
      redis_clent.lrem POO_TRACKER_KEY, 0
      redis_clent.set POO_LATEST_KEY, reply

  robot.respond /poo tracker( me)?/i, (res) ->
    redis_client.get POO_LATEST_KEY -> (err, reply)
      return console.error("Failed get with key '#{POO_TRACKER_KEY}': #{err}") if err
      return if reply == null
      return res.send "Latest poo: #{reply}"
      
  setInterval ->
    checkRedisForShit()
  , 1000
