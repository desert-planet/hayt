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
        pottymouths.users ?= {}
        pottymouths.users[user] ?= {}
        userEntry = pottymouths.users[user]

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

  robot.respond /pottymouths/, (msg) ->
    users = robot.brain.get('pottymouths').users ? {}

    # Find the users who have cussed the most.
    totals = ({name, total: entry.total} for name, entry of users)
    totals.sort (a, b) -> b.total - a.total
    top = totals.slice(0, 5)

    verbiage = ["The pottiest of mouths"]
    for {name, total}, rank in top
      verbiage.push "#{rank + 1}. #{name} (#{total})"
    msg.send verbiage.join("\n")

  # Initialize the pottymouth data if it doesn't exist yet.
  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('pottymouths')?
      robot.brain.set('pottymouths', {})
