# Description:
#   Hubot will flip a fucking coin.
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
  robot.respond /(coinflip)/i, (msg) ->
    result = msg.random ["https://usercontent.irccloud-cdn.com/file/DbMM89Wi/mood", "https://usercontent.irccloud-cdn.com/file/3g41hAJc/signal-2022-09-22-08-37-39-817.jpg"]
    msg.send "And the result is: #{result}