assert = require 'assert'

Helper = require('hubot-test-helper')
process.env.POO_REDIS_URL = "redis://h:pass@localhost:6379/0"
helper = new Helper('../scripts/poo-tracker.coffee')

describe 'poo-tracker', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'shithead', '@hubot hello, this is dog'

  it 'compiled if it got this fucking far', ->
    assert room.messages.length > 0
