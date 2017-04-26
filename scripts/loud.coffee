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
  robot.hear /^\s*([A-Z"][A-Z0-9 .,'"()\?!&%$#@+-]+)$/, (res) ->
    # Pick a loud from the stored list and say it. Skip if there are no louds.
    old_loud = res.random(robot.brain.get('louds'))

    if old_loud?
      res.send old_loud

    # Save new loud in the list, but only if it is unique
    new_loud = res.match[1].trim()
    if new_loud not in robot.brain.get('louds')
      robot.brain.get('louds').push(new_loud) if new_loud not in robot.brain.get('louds_banned')

  robot.respond /loud (\w+)\s*(.*)?$/i, (res) ->
    action = res.match[1].trim()
    data = res.match[2]?.trim()

    deleteLoud = (data, brain) ->
      index = robot.brain.get(brain).indexOf(data)
      if index != -1
        robot.brain.get(brain).splice(index, 1)
        res.send "Loud deleted."
      else
        res.send "Couldn't find that loud."

    addLoud = (data, brain) ->
      robot.brain.get(brain).push(data) if data not in robot.brain.get(brain)

    switch action
      when 'delete'
        deleteLoud(data, 'louds')

      when 'ban'
        addLoud(data, 'louds_banned')
        deleteLoud(data, 'louds') if data in robot.brain.get('louds')

      when 'unban'
        deleteLoud(data, 'louds_banned') if data in robot.brain.get('louds_banned')
        addLoud(data, 'louds')

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
