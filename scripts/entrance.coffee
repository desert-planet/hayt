# Says things when people join

module.exports = (robot) ->
  robot.enter (msg) ->
    username = msg.message.user.name.toLowerCase().trim()
    # If its dusya optionally follwed by ANYTHING
    if /dusya/.test(username)
      msg.send "#{username}: USE YOUR DAMN BOUNCER"
    else if /anonuser/.test(username)
      msg.send "Bazinga!"
    else if /shyguy/.test(username)
      msg.send "wb #{username}"
    else if /kin/.test(username)
      msg.send "Hello #{username}! We missed you!"
