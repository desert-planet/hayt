# Description:
#  Mad
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Mad - Recite Mad
#
# Author:
#   lcsaph

mad = "凸(｀0´)凸"

module.exports = (robot) ->
  robot.hear /\b(mad)\b/i, (msg) ->
    msg.send mad
