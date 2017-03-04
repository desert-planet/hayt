# Description:
#   Ya know, sets the title
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot topic <new topic> - Sets the topic
#
# Author:
#   skalnik

module.exports = (robot) ->
  robot.respond /topic( me)? (.*)/i, (msg) ->
    msg.emit 'raw',
      command: 'TOPIC',
      channel: '#arrakis',
      args: msg.match[2]
    
