# Description:
#   Hubot will flip your fucking mood.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mood - declare your daily mood
#
# Author:
#   max-sec

module.exports = (robot) ->
  robot.respond /(mood)/i, (msg) ->
    result = msg.random ["https://imgur.com/XujwziE.jpg", "https://i.imgur.com/8BYpECO.jpg"]
    msg.send "And your mood for the day is ... #{result}
