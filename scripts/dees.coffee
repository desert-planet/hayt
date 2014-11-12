# Says "your nuts" to Katy before she can

module.exports = (robot) ->
  robot.enter (msg) ->
    # If its dusya, optionally followed by 1 or more numbers or _work
    if /^dusya(\d+|_work)*/.test(msg.user)
      msg.send "YOUR NUTS"
