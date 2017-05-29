# A scale that means almost literally nothing
# We'll track your current mood, and it over time

Redis = require 'redis'

module.exports = (robot) ->
  robot.respond /(?:rc)\s+(\d+.?\d*)$/i, (msg) ->
    who = msg.message.user.name.toLowerCase()
    score = msg.match[1]

    return msg.reply "TODO(sshirokov): Not fucking yet: rc: #{who} => #{score}"
