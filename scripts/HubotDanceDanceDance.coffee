# Description:
#   Hubot will make you dance, dance, dance.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   dance - Recite dance
#
# Author:
#   lcsaph

dance = "~(‾▿‾)~ \n" +
"┌(‾▿‾)┘ \n" +
"└(‾▿‾)┐\n" +
"~(‾▿‾)~"

module.exports = (robot) ->
  robot.respond /(dance)/i, (msg) ->
    msg.send dance
