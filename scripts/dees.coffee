# Says "your nuts" to Katy before she can

module.exports = (robot) ->
  robot.enter (msg) ->
    console.log(msg.user)
    # If its dusya optionally follwed by ANYTHING
    # if /^dusya/.test(msg.user.name.toLowerCase())
    #  msg.send "YOUR NUTS"
