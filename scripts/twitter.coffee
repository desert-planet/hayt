t = require '../lib/twitter'

module.exports = (robot) ->
  robot.respond /tweet(\s+(me)?)?\s+(.{3,})$/i, (msg) ->
    who = msg.message.user.name or "Some-Idiot"
    what = msg.match[3].trim()

    t.tweet "'#{what}' -#{who}", (error, tweet, url) ->
      if error
        return msg.reply "The internet rejected you as follows: #{error[0].message}"

      msg.send url