# Description:
#   Hubot will pretend that the world is fair by offering
#   an illusion of choice.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   vote? - tell me more about freedom
#
# Author:
#   sshirokov

module.exports = (robot) ->
  robot.respond /vote ([^\s]+)\s?(.*)?$/, (msg) ->
    # TODO: REMOVE: Just me for now.
    if msg.message.user.name.toLowerCase() != 'muta_work'
      msg.reply "You're not my real dad."
      return

    action = msg.match[1].trim()
    arg = msg.match[2]?.trim()

    msg.reply "Working on it: [#{action}](#{arg})"

  robot.respond /vote\??$/i, (msg) ->
    msg.send "Voting is a lie, and you can't do it yet."