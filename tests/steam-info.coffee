assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/steam-info.coffee')

describe 'Steam Links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'alice', 'shut up your face'

  it 'should like, compile, man', ->
    assert room.messages.length > 0
