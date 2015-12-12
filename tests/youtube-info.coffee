assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/youtube-info.coffee')

describe 'when user links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'alice', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'

  it 'should be able to find title', ->
    assert room.messages.length > 0
