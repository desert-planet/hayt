# Says things when people join

module.exports = (robot) ->
  robot.enter (msg) ->
    username = msg.message.user.name.toLowerCase().trim()
    # If its dusya optionally follwed by ANYTHING
    if /dusya/.test(username)
      msg.send "DEES NUTS"
    if /prawn/.test(username)
      msg.send "HAPPY BIRTHDAY JENSEN"
    else if /anonuser/.test(username)
      msg.send "Bazinga!"
