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
    result = msg.random [
      "https://i.imgur.com/XujwziE.jpg",
      "https://i.imgur.com/8BYpECO.jpg",
      "https://i.imgur.com/yEfseSE.jpeg",
      "https://c.sklnk.xyz/UwhVo.png",
      "https://imgur.com/a/W2A5VMF.png",
    ]
    msg.send "And your mood for the day is ... #{result}"
