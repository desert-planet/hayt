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
    exec 'git name-rev --always HEAD && git rev-parse HEAD', (err, stdout, stderr) ->
      msg.send "Deployed: #{stdout.trim().split('\n').join('  --  ').trim()}"

  robot.respond /deploy(\s@?[\w_\-/]+)?$/, (msg) ->
    remote = 'origin'
    branch = (msg.match[1] or "master").trim()

    if msg.message.user.name.toLowerCase() not in OPS
      msg.reply "Sorry, I can't do that for you."
      return

    prefix = ":"
    if branch[0] == '@' and branch.indexOf('/') != -1
      branch = branch.replace '@', ''
      [remote, branch] = branch.split '/'
      prefix = "git remote add #{remote} https://github.com/#{remote}/hayt"

    msg.send "\"Deploying\" #{remote}/#{branch}"
    exec "#{prefix} ; git fetch --all && git checkout -f '#{remote}/#{branch}'  && git merge origin/master", (err, stdout, stderr) ->
      if err
        msg.send "Something has gone wrong: #{util.inspect err}"
        exec "git checkout -f origin/master", (err, stdout, stderr) =>
          if err
            msg.send "Also failed to roll back to master: #{err}"
      else
        msg.send "Restarting (in theory)"
        setTimeout process.exit, 500
