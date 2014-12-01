# Description
#  Grab the title of a liveleak video
#
# Dependencies:
#  utils/phantomjs-liveleak.coffee
#  phantomjs
#
# Configuration:
#  None
#
# Commands:
#  None
#
# Notes:
#  why are you even linking to liveleak???
#
# Author:
#  kimagure

url = require 'url'
path = require 'path'
child_process = require 'child_process'
spawn = child_process.spawn
PHANTOMJS_PATH = path.join __dirname, '../node_modules/.bin/phantomjs'
PHANTOMJS_LIVELEAK_PATH = path.join __dirname, '../utils/phantomjs-liveleak.coffee'


module.exports = (robot) ->
  robot.hear /(http?:\/\/www\.liveleak\.com\/view\?.+?)(?:\s|$)/i, (msg) ->
    getTitle msg, msg.match[1]

getTitle = (msg, url) ->
  output = ''
  # kick off glorious phantomjs, hope it's in PATH
  phantomjs = spawn PHANTOMJS_PATH, [PHANTOMJS_LIVELEAK_PATH, url]
  phantomjs.stdout.on 'data', (data) ->
    # need to string concat because data is weird
    output += data
  phantomjs.on 'close', ->
    msg.send output
