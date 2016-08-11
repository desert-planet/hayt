t = require '../lib/twitter'
util = require 'util'

module.exports = (robot) ->
  robot.respond /(?:retweet|rt|retwat)\s+(.+$)/i, (msg) ->
    tid = msg.match[1].trim()
    tid = if tid.match(/^\d+$/)
        tid
      else if (info = tid.match /twitter.com\/\w+\/status+\/(\d+)/)
        info[1]

    return msg.reply "That's not a fucking tweet, moron" if not tid
    t.client.post "statuses/retweet/#{tid}", {}, (err, tweet, response) ->
      insult = msg.random ["idiot", "dumb ass", "moron", "asshole", "jackass", "butthole", "butt"]
      # For *SOME RAISIN* the error is in a list? Who the fuck does this? Why is this a thing?
      [ {message = "no fucking clue"}, ... ] = err if err
      return msg.reply "No, because #{message.replace(/.$/, '')}, #{insult}." if err
      msg.reply "Fine, did it."


  robot.respond /tweet(\s+(me)?)?\s+(.{3,})$/i, (msg) ->
    who = msg.message.user.name or "Some-Idiot"
    what = msg.match[3].trim()

    t.tweet "'#{what}' -#{who}", (error, tweet, url) ->
      if error
        return msg.reply "The internet rejected you as follows: #{error[0].message}"

      msg.send url
