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


robot.hear /(mad)/i, (msg) ->
  msg.send mad
