# Description:
#   Basically pull and die. Like the old days.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   deploy [branch] - Deploy a new branch
#
# Author:
#   sshirokov
util = require 'util'
exec = require('child_process').exec

# DAT DOWNCASE
OPS = ['muta_work']

module.exports = (robot) ->
  robot.respond /deployed\??/, (msg) ->
    exec 'git name-rev --always HEAD', (err, stdout, stderr) ->
      msg.send "Deployed: #{stdout.trim()}"

  robot.respond /deploy(\s@?[\w_\-/]+)?$/, (msg) ->
    remote = 'origin'
    branch = (msg.match[1] or "master").trim()

    if msg.message.user.name.toLowerCase() not in OPS
      msg.reply "Sorry, I can't do that for you."
      return

    prefix = ""
    if remote[0] == '@'
      remote = remote.replace '@', ''
      prefix = "git remote add #{remote} https://github.com/#{remote}/arrakis-hubot"

    msg.send "\"Deploying\" #{origin}/#{branch}"
    exec "#{prefix} ; git fetch --all && git checkout -f '#{origin}/#{branch}'", (err, stdout, stderr) ->
      if err
        msg.send "Something has gone wrong: #{util.inspect err}"
      else
        msg.send "Restarting (in theory)"
        setTimeout process.exit, 500