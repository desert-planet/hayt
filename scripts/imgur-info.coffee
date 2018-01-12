# Description
#  Grab the title of a ~~youtube video~~ ~~steam game~~ imgur post
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
#  imgur also sucks (but mostly I'm lazy)
#
# Author:
#  ~~justinwoo~~ ~~sshirokov~~ justinwoo without copy and paste at all!

url = require 'url'
path = require 'path'
request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.hear /imgur.com\/gallery\/(\w+)/i, (msg) ->
    url_parsed = url.parse(msg.match[1])
    getInfo msg, url_parsed.href

getInfo = (msg, url) ->
  muhUrl = "http://imgur.com/gallery/#{url}/"
  request muhUrl, (err, res, body) ->
    if err
      msg.send "couldn't do anything with #{muhUrl}. imgur sucks"
    else
      $ = cheerio.load(body)
      title = $('title').text().trim()
      msg.send title

