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
  robot.hear /(mad)/i, (msg) ->
    msg.send mad
