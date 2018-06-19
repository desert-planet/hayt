# Description:
#   Hubot will pretend that the world is fair by offering
#   an illusion of choice.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   vote? - tell me more about freedom
#
# Author:
#   sshirokov

Twitter = require '../lib/twitter'

## Dat model
class Vote
  @current = null

  ## Internal API
  finish: () =>
    # Close the gate, and update the current vote
    @finished = true
    Vote.current = null

    if @expired
      @msg.send "Vote failed, time's up! (#{@duration()} seconds)"
      return false

    if @votes.yes.length == @votes.no.length
      @msg.send "Tie. House wins, everyone loses."
      return false

    if @votes.yes.length > @votes.no.length
      @msg.send "Vote passes."
      do @vote_cb
      return true
    else
      @msg.send "Vote failed #{@votes.yes.length} to #{@votes.no.length}"
      return false


  # See if we're done with this vote.
  # Safe to call whenever, use to periodically
  # check if we're done on modifying actions
  maybeFinish: () =>
    # Can't finish twice
    return if @finished or @expired
    # We're not done unless we get three votes
    return if (@votes.yes.length + @votes.no.length) < 3
    # We're not done if there's no difference between the votes
    return if (Math.abs(@votes.yes.length - @votes.no.length) < 1)
    # Is this still being contested?
    return if (Date.now() - @votes.prev) < 10000
    @finish()


  _vote: (how, who) =>
    # Lookup table of opposites
    how_else =
      yes: 'no'
      no: 'yes'
    return false if @finished
    return false if who.toLowerCase() in @votes[how].concat(@votes[how_else[how]])
    @votes.prev = @votes.last
    @votes.last = Date.now()
    @votes[how].push who.toLowerCase()
    do @maybeFinish
    return true

  ## Public Voting API
  constructor: (@robot, @msg, @description, @time, @vote_cb) ->
    @length = @time * 60 * 1000
    @finished = false
    @expired = false
    @votes =
      started: Date.now() # When voting started
      last: Date.now()    # The last time action was taken
      prev: Date.now()    # Previous `last`
      yes: []
      no: []

  start: () =>
    if Vote.current
      throw "A vote is already in progress, hold up"

    fn = =>
      do @maybeFinish
      return if @finished
      @expired = true
      @finish()
    @timeout = setTimeout fn, @length

    @msg.send "New Vote: #{@description}"
    Vote.current = this

  yes: (who) =>
    @_vote 'yes', who

  no: (who) =>
    @_vote 'no', who

  duration: () =>
    (Date.now() - @votes.started) / 1000




## Dose Handlers
module.exports = (robot) ->
  # Dat help
  robot.respond /vote\??$/i, (msg) ->
    msg.send """Voting allows you to pretend you have the power of a god.
Supported commands:
  .vote?                            - This help noise
  .voting?                          - What is going on, RIGHT NOW.
  .vote yes                         - Vote yes in the current vote
  .vote no                          - Vote no in the current vote
  .vote random                      - Vote one way or the other, who cares
  .vote [duration] topic <new topic> - Propose a new topic, with optional duration (in minutes)
  .vote [duration] on <new thing>    - Vote on a thing, with optional duration (in minutes)
"""

  robot.respond /voting\??$/i, (msg) ->
    sure_am = "Yep, for #{Vote.current?.duration()} seconds now. #{Vote.current?.votes.yes.length} vs #{Vote.current?.votes.no.length}"
    nope = "Nope, democracy has totally failed."
    msg.reply if Vote.current then sure_am else nope

  # Election driver
  robot.respond /(?:vote|freedom|oppressed) (\d+ )?([^\s]+)\s?(.*)?$/, (msg) ->
    timeout = 5 # default timeout is 5 minute
    timeout = parseInt(msg.match[1].trim()) if msg.match[1]?.length > 0

    action = msg.match[2].trim().toLowerCase()
    arg = msg.match[3]?.trim()

    switch action
      # Vote on a current issue
      when "yes","po","bai","da","si","ano","ja","jah","kylia","oui","vai","igen","taip","iva","tak","sim","ie","yog","ha","inde","ee","haa","oo","ya","yea","yeah","iya nih","jes"
        return msg.reply "There's no vote going on." unless Vote.current?
        result = Vote.current?.yes msg.message.user.name
        reply = "Your vote " +
          (if result then "totally counted." else "was absolutely worthless!")
        msg.reply reply

      when "no","jo","ne","ingen","nee","ei","non","ningunha","nein","nem","ekki","aon","nie","nao","nu","nej","dim","yox","yo'q","khong","geen","palibe","babu","ha ho","hakuna","ko si","akukho","dili","hindi","tidak","ora","tsy misy","tidak","kahore","neniu","pa gen okenn","nyet","nope","nada","neg","negative"
        return msg.reply "There's nothing to disagree with." unless Vote.current?
        result = Vote.current?.no msg.message.user.name
        reply = "Your vote " +
          (if result then "totally counted." else "was absolutely worthless!")
        msg.reply reply

      when "random"
       return msg.reply "You can't randomly vote on nothing!" unless Vote.current?
       voteResult = msg.random ["yes", "no"]
       result = if voteResult == "yes"
                  Vote.current?.yes msg.message.user.name
                else
                  Vote.current?.no msg.message.user.name
       reply = "Your vote " +
        (if result then "totally counted." else "was absolutely worthless!")
       msg.reply reply

      # Super Important Issues to vote about
      when "topic"
        try
          vote = new Vote robot, msg, "Topic: '#{arg}'", timeout, ->
            msg.topic arg
          vote.start()
        catch error
          msg.reply error

      when "on"
        try
          vote = new Vote robot, msg, "Thing: '#{arg}'", timeout, ->
            msg.send msg.random [
              "Skalnik approves #{arg}",
              "YES TO #{arg}!!!!!!",
              "#{arg}. It is so.",
              "#{arg} has been agreed upon."
            ]
          vote.start()
        catch error
          msg.reply error

      when "poop"
        try
          vote = new Vote robot, msg, "Should I poop!?", 1, ->
            msg.send msg.random [
              "Poop is coming out",
              "I am pooping",
              "Butt evacuation in progress.",
              "http://i.imgur.com/ZTukQOl.gif",
              "http://i.imgur.com/0nwjhNO.gif",
              "http://i.imgur.com/pm4DXWS.jpg"
            ]
          vote.start()
        catch error
          msg.reply error

      when "tweet"
        try
          vote = new Vote robot, msg, "Do we Tweet '#{arg}'", timeout, ->
            Twitter.tweet arg, (err, tweet, url) ->
              return msg.reply "It can't be done, #{err}" if err
              msg.send "I hope you're all proud - #{url}"
          vote.start()
        catch error
          msg.reply error

      # Shut up, loony bin
      else
        msg.reply "That made no sense, and you're probably crazy."
