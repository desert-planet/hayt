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
#   hubot roll <x>d<y> - roll x dice, each of which has y sides
#   hubot roll <x>dF - roll x fudge dice, each of which has +, +, 0, 0, -, and - sides.
#
# Author:
#   ab9
#   https://github.com/github/hubot-scripts/blob/master/src/scripts/dice.coffee
#   drobati
#   Added fudge dice and modifiers.
#
# Regex Tests:
#   https://regex101.com/r/mC7vQ3/3

module.exports = (robot) ->
  robot.respond /roll (die|one)/i, (msg) ->
    msg.reply report [rollOne(6)]
  robot.respond /roll dice/i, (msg) ->
    msg.reply report roll 2, 6
  robot.respond /roll (\d+)d(\d+)([\+-]\d+)?$/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    modifier = parseInt msg.match[3]
    answer = if sides < 1
      "I don't know how to roll a zero-sided die."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report modifier, roll dice, sides
    msg.reply answer
  robot.respond /roll (\d+)dF/i, (msg) ->
    dice = parseInt msg.match[1]
    answer = if dice > 100
      "I'm not going to roll more than 100 fudge dice for you."
    else
      report fudgeRoll dice
    msg.reply answer

report = (modifier, results) ->
  if results?
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        total = results[0]
        "I rolled a #{total}."
        if modifier
          modified total, modifier
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        "I rolled #{results.join(", ")}#{finalComma} and #{last}, making #{total}."
        if modifier
          modified total, modifier

modified = (total, modifier) ->
  if modifier
    "With the modifier, #{total} #{modifier} is #{total+modifier}."

roll = (dice, sides) ->
  rollOne(sides) for i in [0...dice]

rollOne = (sides) ->
  1 + Math.floor(Math.random() * sides)

fudgeRoll = (dice) ->
  fudge() for i in [0...dice]

fudge = ->
  Math.floor(Math.random() * 3) - 1
