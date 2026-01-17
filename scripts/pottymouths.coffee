module.exports = (robot) ->
  robot.hear /(.*)/, (msg) ->
    # Ignore ourselves
    return if msg.message.user.name == robot.name

    cusses = [
      "fuck",
      "shit",
      "piss",
      "damn",
      "dammit",
    ]

    fullMessage = msg.match[1].trim().toLowerCase()
    for cuss in cusses
      if fullMessage.indexOf(cuss) != -1
        msg.send "#{msg.message.user.name} said '#{cuss}'!"
