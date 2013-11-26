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
    msg.send "/topic #arrakis #{msg.match[2]"
    
