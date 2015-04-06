# Description:
#   Benedict Cumberbatch name generator.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   cumberbatch - Creates your very own Benedict Cumberbatch
#
# Author:
#   mbulmer

module.exports = (robot) ->
  robot.respond /(cumberbatch)/i, (msg) ->
    cumberbatch = require('../lib/cumberbatch')
    msg.send(cumberbatch.generate())