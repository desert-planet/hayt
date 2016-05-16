# Description:
#  Taunt dat ass
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   butt name
#
# Author:
#   sshirokov

insult = [
  (opt) -> "#{opt.name} has a big butt.",
  (opt) -> "And their big butt smells.",
  (opt) -> "#{opt.name} likes to smell their big butt."
]

module.exports = (robot) ->
  robot.respond /butts?( \w+)?/, (msg) ->
    name = msg.match[1]?.trim() or 'me'
    name = msg.message.user.name if name == 'me'

    delay = 0
    for section in insult
      do (section) ->
        delay += Math.random() * 1500
        setTimeout (->
          msg.send section(name: name)
          ), delay
