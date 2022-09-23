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
    result = msg.random ["shorturl.at/ceiVZ", "shorturl.at/hiQRT"]
    msg.send "And your mood for the day is ... #{result}