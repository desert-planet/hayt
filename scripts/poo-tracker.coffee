Redis = require 'redis'
Url = require 'url'

POO_TRACKER_KEY = "poo:skalnik:message"
POO_LATEST_KEY = "poo:skalnik:latest_message"

info = Url.parse process.env.POO_REDIS_URL
redis_client = Redis.createClient(info.port, info.hostname)
redis_clent.auth info.auth.split(":")[1] if info.auth

module.exports = (robot) ->
  setInterval ->
    checkRedisForShit()
  , 1000

  checkRedisForShit ->
    redis_clent.get POO_TRACKER_KEY -> (err, reply)
      return console.error("Failed get of #{POO_TRACKER_KEY}: #{err}") if err
      return if reply == null

      robot.messageRoom "#arrakis", "We got a poo over here: #{reply}"
      redis_clent.del POO_TRACKER_KEY
      redis_clent.set POO_LATEST_KEY, reply

  robot.respond /poo tracker( me)?/i, (res) ->
    redis_client.get POO_LATEST_KEY -> (err, reply)
      return res.send "Latest poo: #{reply}"
