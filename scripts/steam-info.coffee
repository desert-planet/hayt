# Description
#  Grab the title of a ~~youtube video~~ steam game
#
# Dependencies:
#  cheerio
#  request
#
# Configuration:
#  None
#
# Commands:
#  None
#
# Notes:
#  steam also sucks (but mostly I'm lazy)
#
# Author:
#  ~~justinwoo~~ sshirokov without copy and paste at all!

url = require 'url'
path = require 'path'
request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.hear /store.steampowered.com\/app\/(\d+)/i, (msg) ->
    url_parsed = url.parse(msg.match[1])
    getInfo msg, url_parsed.href

getInfo = (msg, url) ->
  muhUrl = "http://store.steampowered.com/app/#{url}/"
  request muhUrl, (err, res, body) ->
    if err
      msg.send "couldn't do anything with #{muhUrl}. steam sucks"
    else
      $ = cheerio.load(body)
      title = $('title').text()
      blurb = $('.game_description_snippet').text()?.trim() || "I have no fucking idea what '#{title}' is about"
      msg.send title
      msg.send blurb
