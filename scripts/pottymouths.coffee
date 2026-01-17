module.exports = (robot) ->
  robot.hear /(.*)/, (msg) ->
    # Ignore ourselves.
    user = msg.message.user.name
    return if user == robot.name

    cusses = [
      "fuck",
      "shit",
      "piss",
      "damn",
      "dammit",
    ]

    fullMessage = msg.match[1].trim().toLowerCase()
    pottymouths = robot.brain.get('pottymouths')

    for cuss in cusses
      if fullMessage.indexOf(cuss) != -1
        pottymouths[user] ?= {}
        userEntry = pottymouths[user]

        # Total times the user has cussed.
        userEntry.total ?= 0
        userEntry.total += 1

        # Total number of times the user said this particular cuss.
        userEntry.cusses ?= {}
        userEntry.cusses[cuss] ?= 0
        userEntry.cusses[cuss] += 1

        # Total number of times this cuss has been said by all users.
        pottymouths.cusses ?= {}
        pottymouths.cusses[cuss] ?= 0
        pottymouths.cusses[cuss] += 1

        msg.send "#{user} said '#{cuss}'! (#{userEntry.cusses[cuss]} times, #{pottymouths.cusses[cuss]} across all users)"

  # Initialize the pottymouth data if it doesn't exist yet.
  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('pottymouths')?
      robot.brain.set('pottymouths', {})
