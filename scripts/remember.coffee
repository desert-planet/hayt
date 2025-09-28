# Description
#   Remembers a key and value
#
# Commands:
#   hubot what is|remember <key> - Returns a string
#   hubot remember <key> is <value>. - Returns nothing. Remembers the text for next time!
#   hubot what do you remember - Returns everything hubot remembers.
#   hubot forget <key> - Removes key from hubots brain.
#   hubot what are your favorite memories? - Returns a list of the most remembered memories.  
#   hubot random memory - Returns a random string
#
# Dependencies:
#   "underscore": "*"

_ = require('underscore')

module.exports = (robot) ->
  memoriesByRecollection = () -> robot.brain.data.memoriesByRecollection ?= {}
  memories = () -> robot.brain.data.remember ?= {}

  findSimilarMemories = (key) ->
    searchRegex = new RegExp(key, 'i')
    Object.keys(memories()).filter (key) -> searchRegex.test(key)

  robot.respond /(?:what is|rem(?:ember)?)\s+(.*)/i, (msg) ->
    msg.finish()
    words = msg.match[1].trim()

    # First check for a search expression.
    if match = words.match /\|\s*(grep\s+)?(.*)$/i
      searchPattern = match[2]
      matchingKeys = findSimilarMemories(searchPattern)
      if matchingKeys.length > 0
        msg.send "I remember:\n#{matchingKeys.join(', ')}"
      else
        msg.send "I don't remember anything matching `#{searchPattern}`"
      return

    # Next, attempt to interpret `words` as an existing key. This also strips
    # off the last "?" character.
    if match = words.match /(.+?)\??$/i
      stripped_key = match[1].toLowerCase()
      value = memories()[stripped_key]

      if value
        memoriesByRecollection()[stripped_key] ?= 0
        memoriesByRecollection()[stripped_key]++
        msg.send value
        return

    # Next, attempt to interpret `words` as a "foo is bar" expression in order
    # to store a memory.
    if match = words.match /^(.*)is(.*)$/i
      key = match[1].trim().toLowerCase()
      value = match[2].trim()
      if key and value
        currently = memories()[key]
        if currently
          msg.send "But #{key} is already #{currently}.  Forget #{key} first."
        else
          memories()[key] = value
          msg.send "OK, I'll remember #{key}."
        return

    # If none of the previous actions succeeded, search existing memories for
    # similar keys.
    matchingKeys = findSimilarMemories(stripped_key)
    if matchingKeys.length > 0
      keys = matchingKeys.join(', ')
      msg.send "I don't remember `#{stripped_key}`. Did you mean:\n#{keys}"
    else
      msg.send "I don't remember anything matching `#{stripped_key}`"

  robot.respond /(forget|forgor)\s+(.*)/i, (msg) ->
    key = msg.match[2].toLowerCase()
    value = memories()[key]
    delete memories()[key]
    delete memoriesByRecollection()[key]
    msg.send "I've forgotten #{key} is #{value}."

  robot.respond /what are your favorite memories/i, (msg) ->
    msg.finish()
    sortedMemories = _.sortBy Object.keys(memoriesByRecollection()), (key) ->
      memoriesByRecollection()[key]
    sortedMemories.reverse()

    msg.send "My favorite memories are:\n#{sortedMemories[0..20].join(', ')}"

  robot.respond /(me|random memory)(\s+.*)?$/i, (msg) ->
    msg.finish()

    search = msg.match[2]?.trim()
    randomKey = if search
      msg.random(findSimilarMemories(search))
    else
      msg.random(Object.keys(memories()))

    msg.send randomKey
    msg.send memories()[randomKey]

  robot.respond /mem(ory)? bomb x?(\d+)/i, (msg) ->
    keys = []
    keys.push value for key,value of memories()
    unless msg.match[2]
      count = 10
    else
      count = parseInt(msg.match[2])

    msg.send(msg.random(keys)) for [1..count]
