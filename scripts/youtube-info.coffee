# Description
#  Grab the title of a youtube video
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
#  youtube sucks
#
# Author:
#  justinwoo

url = require 'url'
path = require 'path'
request = require 'request'
cheerio = require 'cheerio'

module.exports = (robot) ->
  robot.hear /(youtube\.com\/watch\?v=|youtu.be\/)(.+)/i, (msg) ->
    url_parsed = url.parse(msg.match[2])
    getTitle msg, url_parsed.href

getTitle = (msg, url) ->
  muhUrl = "https://youtube.com/watch?v=#{url}"
  request muhUrl, (err, res, body) ->
    if err
      msg.send "couldn't do anything with #{muhUrl}"
    else
      $ = cheerio.load(body)
      title = $('title').text()
      msg.send title
