# Says "your nuts" to Katy before she can

module.exports = (robot) ->
  robot.enter (msg) ->
    # If its dusya, optionally followed by 1 or more numbers or _work with 0-n numbers
    if /^dusya(\d+|_work\d*)*/.test(msg.user)
      msg.send "YOUR NUTS"
