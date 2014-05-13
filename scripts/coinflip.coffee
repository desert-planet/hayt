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
#   coinflip - Flip a fucking coin
#
# Author:
#   sshirokov

module.exports = (robot) ->
  robot.respond /(coinflip)/i, (msg) ->
    msg.random ["Heads", "Tails"]
