# Description
#  Grab the title of a youtube video
#
# Dependencies:
#  youtube-dl-exec
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
youtubedl = require 'youtube-dl-exec'

module.exports = (robot) ->
  robot.hear /(youtube\.com\/(?:watch\?v=|shorts\/)|youtu.be\/)(.+)/i, (msg) ->
    url_parsed = url.parse(msg.match[2])
    getTitle msg, url_parsed.href

getTitle = (msg, url) ->
  muhUrl = "https://youtube.com/watch?v=#{url}"
  youtubedl muhUrl, {
    dumpSingleJson: true
    noCheckCertificates: true
    noWarnings: true
    preferFreeFormats: true
  }
    .then (output) ->
      msg.send output.title
    .catch (err) ->
      msg.send "couldn't do anything with #{muhUrl}"
