# Description:
#   ENCOURAGE SHOUTING. LOUD TEXT IS FOREVER.
#   LOUD WILL CAUSE YOUR HUBOT TO STORE ALL-CAPS MESSAGES FROM THE CHANNEL,
#   AND SPIT THEM BACK AT RANDOM IN RESPONSE.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   loud delete [TEXT] - Delete the loud with the matching text.
#   loud nuke          - Delete the entire loud database. (available in debug mode only!)
#   loud all           - Print every single loud in the database. (available in debug mode only!)
#
# Author:
#   annabunches

module.exports = (robot) ->
  robot.hear /^([A-Z"][A-Z0-9 .,'"()\?!&%$#@+-]+)$/, (res) ->
    # Pick a loud from the stored list and say it. Skip if there are no louds.
    old_loud = res.random(robot.brain.get('louds'))
    if old_loud in robot.brain.get('louds_banned')
      old_loud = res.random(robot.brain.get('louds'))

    if old_loud?
      res.send old_loud

    # Save new loud in the list, but only if it is unique
    new_loud = res.match[1].trim()
    if new_loud not in robot.brain.get('louds')
      robot.brain.get('louds').push(new_loud)

  robot.respond /loud (\w+)\s*(.*)?$/i, (res) ->
    action = res.match[1].trim()
    data = res.match[2]?.trim()

    switch action
      when 'delete'
        index = robot.brain.get('louds').indexOf(data)
        if index != -1
          robot.brain.get('louds').splice(index, 1)
          res.send "Loud deleted."
        else
          res.send "Couldn't find that loud."

      when 'ban'
        if data in robot.brain.get('louds')
          if data not in robot.brain.get('louds_banned')
            robot.brain.get('louds_banned').push(data)

      when 'nuke'
        if process.env.DEBUG != 'true'
          res.send "Nukes are only available in debug mode."
          return

        robot.brain.set('louds', [])
        res.send "All louds deleted."

      when 'all'
        if process.env.DEBUG != 'true'
          res.send "Printing all louds only available in debug mode."
          return

        louds = robot.brain.get('louds')
        for loud in louds
          res.send loud

  # Initialize the louds list, if it doesn't exist yet.
  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('louds')?
      robot.brain.set('louds', [])
    if not robot.brain.get('louds_banned')?
      robot.brain.set('louds_banned', [])

  getRandomLoud = (res) ->
