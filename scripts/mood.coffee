# Description:
#   Hubot will decide your fucking mood.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mood - roll the dice and see your mood
#
# Author:
#   max-sec

module.exports = (robot) ->
  robot.respond /(mood)/i, (msg) ->
    result = msg.random ["https://i.imgur.com/XujwziE.jpg", "https://i.imgur.com/8BYpECO.jpg", "https://i.imgur.com/28hx2in.jpg"]
    msg.send "And your mood for the day is ... #{result}"
