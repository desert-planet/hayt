# Description:
#   You are a ____.
#   So ____ maybe you should _____,
#   but perhaps ____.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   adlib add [TEXT]    - Add an adlib to the database.
#   adlib delete [TEXT] - Delete an adlib from the database.
#
# Author:
#   drobati
fs = require('fs')

loadBrain = (robot) ->
  fs.readFile 'data/answers.txt', 'utf8', (err, contents) =>
    list = []
    if err 
      list = ['dickbutt'] # This is the only way to please the tests.
    else    
      list = contents.toString().split "\n"
    robot.brain.set('adlib', list)

module.exports = (robot) ->
  robot.hear /(_{3,})+/g, (res) ->
    # Any text that has 3 or more underscores will result in adlib replacement.
    message = res.message.text
    matches = res.match
    for match in matches
        word = match.trim()
        adlib = res.random robot.brain.get('adlib')
        message = message.replace(word, adlib)
    res.send message

  robot.respond /adlib (\w+)\s*(.*)?$/i, (res) ->
    action = res.match[1].trim()
    data = res.match[2]?.trim()

    switch action
      when 'add'
        if data not in robot.brain.get('adlib')
          robot.brain.get('adlib').push(data)
          res.send "Adlib added."
        else
          res.send "Already have that adlib."

      when 'delete'
        index = robot.brain.get('adlib').indexOf(data)
        if index != -1
          robot.brain.get('adlib').splice(index, 1)
          res.send "Adlib deleted."
        else
          res.send "Couldn't find that adlib."

      when 'nuke'
        if process.env.DEBUG != 'true'
          res.send "Nukes are only available in debug mode."
          return

        robot.brain.remove 'adlib'
        res.send "All adlibs deleted."

      when 'all'
        if process.env.DEBUG != 'true'
          res.send "Printing all adlibs only available in debug mode."
          return

        adlibs = robot.brain.get('adlib')
        for adlib in adlibs
          res.send adlibs

      when 'setup'
        if process.env.DEBUG != 'true'
          res.send "Setting up brain is only available in debug mode."
          return

        robot.brain.remove 'adlib'
        loadBrain robot
        res.send "Adlib brain setup."

  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('adlib')?
      loadBrain robot
