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

module.exports = (robot) ->
  robot.hear /___+/, (res) ->
    # Any text that has 3 or more underscores will result in adlib replacement.
    adlib = res.random robot.brain.get('adlib')
    res.send res.message.text.replace('___', adlib)

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

  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('adlib')?
      # TODO: Figure out how to load in the adlibs in a textfile.
      fs.readFile 'answers.txt', 'utf8', (err, contents) =>
        if err then throw err
        list = contents.toString().split "\n"
        robot.brain.set('adlib', list)

