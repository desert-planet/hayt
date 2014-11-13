# Says "your nuts" to Katy before she can

module.exports = (robot) ->
  robot.enter (msg) ->
    msg.send inspect(msg)
    # If its dusya optionally follwed by ANYTHING
    # if /^dusya/.test(msg.user.name.toLowerCase())
    #  msg.send "YOUR NUTS"
