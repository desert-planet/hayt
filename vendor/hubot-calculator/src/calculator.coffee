# Description:
#   Allows Hubot to do mathematics.
#
# Dependencies:
#   "mathjs": ">= 0.16.0"
#
# Configuration:
#   None
#
# Commands:
#   hubot calculate <expression> - Calculate the given math expression.
#   hubot convert <expression> in <units> - Convert expression to given units.
#
# Author:
#   canadianveggie

mathjs = require("mathjs")

module.exports = (robot) ->
  robot.respond /(calc|calculate|calculator|convert|math|maths)( me)? (.*)/i, (msg) ->
    try
      result = mathjs.eval msg.match[3]
      msg.send "#{result}"
    catch error
      msg.send error.message || 'Could not compute.'

