# Says things when people join

module.exports = (robot) ->
  robot.enter (msg) ->
    username = msg.message.user.name.toLowerCase().trim()
    # If its dusya optionally follwed by ANYTHING
    if /^dusya/.test(username)
      msg.send "DEES NUTS"
    else if username == 'anonuser'
      msg.send "Bazinga!"
