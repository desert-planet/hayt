# Description:
#   Remind us all that we're only human, even if we're also sort of computers.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   mantra - Recite the Mentat's Mantra
#
# Author:
#   annabunches

mantra = "It is by will alone I set my mind in motion.\n
It is by the juice of sapho that thoughts acquire speed,\n
the lips acquire stains,\n
the stains become a warning.\n
It is by will alone I set my mind in motion."

module.exports = (robot) ->
  robot.respond /(mantra)/i, (msg) ->
    msg.send mantra
