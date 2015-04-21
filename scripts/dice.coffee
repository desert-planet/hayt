# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roll (die|one) - Roll one six-sided dice
#   hubot roll dice - Roll two six-sided dice
#   hubot roll <x>d<y>(+|-)<z> - roll x dice, each of which has y sides. Alternately, add/subtract z from the total.
#                                Also supports a subset of the modifiers on https://wiki.roll20.net/Dice_Reference
#                                Current supported modifiers (see link for details):
#                                Exploding Dice
#                                Keep / Drop Dice
#                                Rerolling Dice (only supports < and >)
#   hubot roll <x>dF - roll x fudge dice, each of which has +, +, 0, 0, -, and - sides.
#
# Author:
#   ab9
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/dice.coffee
#   drobati
#   Added fudge dice and modifiers.
#   annabunches
#   Added some advanced bullshit.
#
# Regex Tests:
#   https://regex101.com/r/mC7vQ3/3

module.exports = (robot) ->
  robot.respond /roll (die|one)/i, (msg) ->
    msg.reply report 0, [rollOne(6)]
    
  robot.respond /roll dice/i, (msg) ->
    msg.reply report 0, roll 2, 6
    
  robot.respond /roll (\d+)d(\d+)([\+-]\d+)?(\S*)/, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    modifier = parseInt msg.match[3]

    meta_modifiers = parse_mods(msg.match[4])

    answer = if sides < 2
      "You want to roll dice with less than two sides. Wow."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report modifier, roll(dice, sides, meta_modifiers)
    msg.reply answer
    
  robot.respond /roll (\d+)dF([\+-]\d+)?/i, (msg) ->
    dice = parseInt msg.match[1]
    modifier = parseInt msg.match[2]
    answer = if dice > 100
      "I'm not going to roll more than 100 fudge dice for you."
    else
      report modifier, fudgeRoll dice
    msg.reply answer

report = (modifier, results) ->
  if results?
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        total = results[0]
        answer = "I rolled a #{total}."
        if not isNaN(modifier)
          answer += modified total, modifier
        else
          answer
      else
        total = results.reduce (x, y) -> x + y
        answer = if results.length < 10
          finalComma = if (results.length > 2) then "," else ""
          last = results.pop()
          "I rolled #{results.join(", ")}#{finalComma} and #{last}, making #{total}."
        else
          "I rolled a handful of dice, making #{total}."
        if not isNaN(modifier)
          answer += modified total, modifier
        else
          answer

modified = (total, modifier) ->
  mod = Math.abs(modifier)
  if modifier < 0
    " With the modifier, #{total} - #{mod} is #{total-mod}."
  else if modifier > 0
    " With the modifier, #{total} + #{mod} is #{total+mod}."
  else
    ""

roll = (dice, sides, meta_modifiers) ->
  results = (rollOne(sides, meta_modifiers) for i in [0...dice])

  if meta_modifiers['explode']?
    results = explode(results, sides, meta_modifiers)

  results.sort((a, b) -> return a - b)
  if meta_modifiers['drop_low']?
    results = results[meta_modifiers['drop_low']..]
  if meta_modifiers['drop_high']?
    results = results[...-1 * meta_modifiers['drop_high']]
  if meta_modifiers['keep_low']?
    results = results[...meta_modifiers['keep_low']]
  if meta_modifiers['keep_high']?
    results = results[-1 * meta_modifiers['keep_high']..]

  return results


rollOne = (sides, meta_modifiers) ->
  result = 1 + Math.floor(Math.random() * sides)

  # Rerolling logic
  if meta_modifiers['reroll']?['lt']? and meta_modifiers['reroll']['lt'] >= sides
    return result # skip rerolling when we would roll forever

  if meta_modifiers['reroll']?
    while result <= meta_modifiers['reroll']['lt'] or result >= meta_modifiers['reroll']['gt']
      result = 1 + Math.floor(Math.random() * sides)
      if meta_modifiers['reroll']['once'] then break

  return result


# Exploding dice. KABOOM.
explode = (results, sides, meta_modifiers) ->
  # Base case
  if results.length == 0
    return []

  new_results = []
  for result in results
    if result == sides
      new_results.push(rollOne(sides, meta_modifiers))

  results.concat(explode(new_results, sides, meta_modifiers))


fudgeRoll = (dice) ->
  fudge() for i in [0...dice]

fudge = ->
  Math.floor(Math.random() * 3) - 1


# Parse the modifier string and return a more useful object
parse_mods = (data) ->
  result = {}

  if not data
    return result
  
  while data.length > 0
    switch data[0]
      # Exploding
      when '!'
        result['explode'] = true
        data = data[1..]

      # Keep/Drop
      when 'd'
        match = data.match(/^d([lh])?(\d+)/)
        switch match[1]
          when 'h'
            result['drop_high'] = parseInt match[2]
          when 'l', undefined
            result['drop_low'] = parseInt match[2]
        data = data[match[0].length..]
      when 'k'
        match = data.match(/^k([lh])?(\d+)/)
        switch match[1]
          when 'l'
            result['keep_low'] = parseInt match[2]
          when 'h', undefined
            result['keep_high'] = parseInt match[2]
        data = data[match[0].length..]

      # Rerolling
      when 'r'
        match = data.match(/^r(o)?(<|>)(\d+)/)
        reroll_once = false
        reroll_lt = undefined
        reroll_gt = undefined
        if match[1] == 'o' then reroll_once = true
        if match[2] == '<' then reroll_lt = parseInt match[3]
        if match[2] == '>' then reroll_gt = parseInt match[3]
        # ignore impossible reroll logic that we can detect easily here
        if reroll_gt? and ((reroll_gt <= 1) or (reroll_lt? and reroll_lt >= reroll_gt))
          result['reroll'] = null
        else
          result['reroll'] = {
            'once': reroll_once,
            'lt': reroll_lt,
            'gt': reroll_gt
          }
        data = data[match[0].length..]

      # This suggests we have unparseable data in our mod string.
      # Bail out with nothing.
      # TODO(annabunches): warn the user that their data sucks
      else
        break

  return result
