# Description
#  Grab the title of a youtube video
#
# Dependencies:
#  request
#
# Configuration:
#  None
#
# Commands:
#  None
#
# Notes:
#  youtube sucks, so this uses the oembed endpoint instead of scraping the page
#
# Author:
#  justinwoo

request = require 'request'

module.exports = (robot) ->
  robot.hear /(?:youtube\.com\/(?:watch\?(?:\S*&)?v=|shorts\/|live\/|embed\/)|youtu\.be\/)([\w-]{11})/i, (msg) ->
    getTitle msg, msg.match[1]

getTitle = (msg, id) ->
  videoUrl = "https://www.youtube.com/watch?v=#{id}"
  oembedUrl = "https://www.youtube.com/oembed?format=json&url=#{encodeURIComponent videoUrl}"
  request oembedUrl, (err, res, body) ->
    return msg.send "couldn't do anything with #{videoUrl}" if err or res.statusCode isnt 200
    try
      title = JSON.parse(body).title
    catch
      return msg.send "couldn't do anything with #{videoUrl}"
    msg.send title if title
