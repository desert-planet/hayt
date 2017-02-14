assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/imgur-info.coffee')

describe 'Imgur Links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'alice', 'shut up your face'

  it 'should like, compile, man', ->
    assert room.messages.length > 0
