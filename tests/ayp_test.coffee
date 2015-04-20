assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/ayp.coffee')

util = require 'util'


describe 'AYP', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'shithead', '@hubot ayp'

  it 'compiled if it got this fucking far', ->
    assert room.messages.length > 0
