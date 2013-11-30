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

## Dat state
current = null

## Dat model
class Vote
  length: 30 * 1000


  finish: () =>
    # Close the gate, and update the current vote
    @finished = true
    current = null

    @msg.reply "TODO: Finish F:[#{@finished}] E:[#{@expired}] +:[#{@votes.yes.length}] -:[#{@votes.no.length}]"

    if @expired
      @msg.send "Vote failed, time's up!"
      return false

    if @votes.yes.length == @votes.no.length
      @msg.send "Tie. House wins, everyone loses."
      return false

    if @votes.yes.length > @votes.no.length
      @msg.send "Vote passes."
      do @vote_cb
      return true
    else
      msg.send "Vote failed #{@votes.yes.length} to #{votes.no.length}"
      return false


  # See if we're done with this vote.
  # Safe to call whenever, use to periodically
  # check if we're done on modifying actions
  maybeFinish: () =>
    # Can't finish twice
    return if @finished or @expired
    # We're not done unless we get three votes
    return if (@votes.yes.length + @votes.no.length) < 3
    # We're not done if it's only a two vote difference
    return if (Math.abs(@votes.yes.length - @votes.no.length) < 2)
    # Is this still being contested?
    return if (Date.now() - @votes.last) < 5000
    @finish()


  _vote: (how, who) =>
    # Lookup table of opposites
    how_else =
      yes: 'no'
      no: 'yes'
    return false if @finished
    return false if who.toLowerCase() in @votes[how].concat(@votes[how_else[how]])
    @votes.last = Date.now()
    @votes[how].push who.toLowerCase()
    do @maybeFinish
    return true

  ## Public Voting API
  constructor: (@robot, @msg, @vote_cb) ->
    @finished = false
    @expired = false
    @votes =
      started: Date.now()
      last: Date.now()
      yes: []
      no: []

  start: () =>
    fn = =>
      return if @finished
      @expired = true
      @finish()
    @timeout = setTimeout fn, @length
    # Note myself if I haven't been yet
    current ?= this

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
    msg.send "Voting is a lie, and you can't do it yet."

  robot.respond /voting\??$/i, (msg) ->
    sure_am = "Yep, for #{current?.duration()} seconds now. #{current?.votes.yes.length} vs #{current?.votes.no.length}"
    nope = "Nope, democracy has totally failed."
    msg.reply if current then sure_am else nope

  # Election driver
  robot.respond /vote ([^\s]+)\s?(.*)?$/, (msg) ->
    action = msg.match[1].trim().toLowerCase()
    arg = msg.match[2]?.trim()

    switch action
      # Vote on a current issue
      when "yes"
        return msg.reply "There's no vote going on." unless current?
        result = current?.yes msg.message.user.name
        reply = "Your vote " +
          (if result then "totally counted." else "was absolutely worthless!")
        msg.reply reply
      when "no"
        return msg.reply "There's nothing to disagree with." unless current?
        result = current?.no msg.message.user.name
        reply = "Your vote " +
          (if result then "totally counted." else "was absolutely worthless!")
        msg.reply reply

      # Super Important Issues to vote about
      when "poop"
        if current
          msg.reply "A vote is already in progress, hold up."
          return
        current = new Vote robot, msg, ->
          msg.send robot.random [
            "Poop is coming out",
            "I am pooping"
            "Butt evacuation in progress.",
          ]
        current.start()
        msg.send "New Vote: Should I poop!?"

      # Shut up, loony bin
      else
        msg.reply "That make no sense, and you're probably crazy."
