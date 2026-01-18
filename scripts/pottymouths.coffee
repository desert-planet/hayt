# Description:
#   Track who cusses the most and which cusses get said the most.
#
# Commands:
#   pottymouths   - List the users who have cussed the most
#   cusses        - List which cusses have been said the most
#   cusses <user> - List someone's top cusses
#   cuss <cuss>   - List how many times a cuss has been said

module.exports = (robot) ->
  # Sourced from https://en.wiktionary.org/wiki/Category:English_swear_words
  CUSSES = [
    "arse",
    "arsehead",
    "arsehole",
    "ass",
    "asshole"
    "bastard",
    "bitch",
    "bloody",
    "bollocks",
    "brotherfucker",
    "bugger",
    "bullshit",
    "cock",
    "cocksucker",
    "crap",
    "cunt",
    "dammit",
    "damn",
    "damned",
    "dick",
    "dickhead",
    "dumbass",
    "fatherfucker"
    "fuck",
    "fucked",
    "fucker",
    "fucking",
    "goddammit",
    "goddamn",
    "goddamned",
    "goddamnit",
    "godsdamn",
    "hell",
    "horseshit",
    "jackarse",
    "jackass",
    "motherfucker",
    "pigfucker",
    "piss",
    "prick",
    "pussy",
    "shit",
    "shite",
    "sisterfucker",
    "slut",
    "twat",
    "wanker",
  ]

  robot.hear /(.*)/, (msg) ->
    user = msg.message.user.name

    # Ignore ourselves.
    return if user == robot.name

    user = user.toLowerCase()
    fullMessage = msg.match[1].trim().toLowerCase()
    pottymouths = robot.brain.get('pottymouths')

    for cuss in CUSSES
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

  robot.respond /cusses( \S+)?/, (msg) ->
    user = msg.match[1]?.trim().toLowerCase()
    pottymouths = robot.brain.get('pottymouths')
    verbiage = []

    if user
      verbiage.push "#{user}'s top cusses"
      cusses = pottymouths.users?[user]?.cusses ? {}
    else
      verbiage.push "Top cusses"
      cusses = pottymouths.cusses ? {}

    cusses = ({cuss, total} for cuss, total of cusses)
    cusses.sort (a, b) -> b.total - a.total
    top = cusses.slice(0, 5)

    for {cuss, total}, rank in top
      verbiage.push "#{rank + 1}. #{cuss} (#{total})"
    msg.send verbiage.join("\n")

  robot.respond /cuss (\S+)/, (msg) ->
    cuss = msg.match[1].trim().toLowerCase()
    if cuss in CUSSES
      pottymouths = robot.brain.get('pottymouths')
      total = pottymouths.cusses?[cuss] ? 0
      msg.send "'#{cuss}' has been said #{total} times"
    else
      msg.send "'#{cuss}' isn't a (recognized) cuss!"

  # Initialize the pottymouth data if it doesn't exist yet.
  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('pottymouths')?
      robot.brain.set('pottymouths', {})
