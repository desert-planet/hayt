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
#   hubot roll <x>d<y> [reroll N] [reroll_max R] [drop_(low|high) M] - roll x dice, each of which has y sides. 
#                                                                      Optionally, reroll dice that roll M or lower up to R times (default forever),
#                                                                      and drop the lowest or highest M dice from the result.
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
    
  # Behold my regex, for it is terrible and mighty upon the Earth - annabunches
  robot.respond /roll (\d+)d(\d+)([\+-]\d+)?((?:\s+(?:reroll|reroll_max|drop_low|drop_high)\s+\d+)*)/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    modifier = parseInt msg.match[3]

    # Extract the optional match modifiers
    meta_modifiers = {}
    if msg.match[4]?
      match_data = msg.match[4].trim().split(' ')
      for i in [0..match_data.length-1] by 2
        meta_modifiers[match_data[i]] = parseInt match_data[i+1]

    answer = if sides < 2
      "You want to roll dice with less than two sides. Wow."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report modifier, meta_modifiers, roll(dice, sides, meta_modifiers)
    msg.reply answer
    
  robot.respond /roll (\d+)dF([\+-]\d+)?/i, (msg) ->
    dice = parseInt msg.match[1]
    modifier = parseInt msg.match[2]
    answer = if dice > 100
      "I'm not going to roll more than 100 fudge dice for you."
    else
      report modifier, fudgeRoll dice
    msg.reply answer

report = (modifier, meta_modifiers, results) ->
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
        if meta_modifiers['drop_low']?
          results.sort().splice(0, meta_modifiers['drop_low'])
        if meta_modifiers['drop_high']?
          results.sort().splice(-1, meta_modifiers['drop_high'])

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
  rollOne(sides, meta_modifiers) for i in [0...dice]

rollOne = (sides, meta_modifiers) ->
  result = 1 + Math.floor(Math.random() * sides)

  # Rerolling logic
  if meta_modifiers['reroll']? and meta_modifiers['reroll'] < sides
    reroll_max = meta_modifiers['reroll_max']
    reroll_max ?= -1
    while result <= meta_modifiers['reroll'] and (reroll_max > 0 or reroll_max == -1)
      result = 1 + Math.floor(Math.random() * sides)
      reroll_max -= 1 if reroll_max > 0

  return result
    

fudgeRoll = (dice) ->
  fudge() for i in [0...dice]

fudge = ->
  Math.floor(Math.random() * 3) - 1
