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
#   adlib add [TEXT]    - Add a adlib to the database.
#   adlib delete [TEXT] - Delete the loud with the matching text.
#
# Author:
#   drobati

module.exports = (robot) ->
  robot.hear /^(___+)$/, (res) ->
    # Any text that has 3 or more underscores will result in adlib replacement.

  robot.brain.once 'loaded', (data) ->
    if not robot.brain.get('adlib')?
      robot.brain.set('adlib', [])

