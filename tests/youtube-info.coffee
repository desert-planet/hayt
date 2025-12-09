assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/youtube-info.coffee')

describe 'when user links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  afterEach ->
    room.destroy()

  it 'should be able to find title', (done) ->
    @timeout(10000)  # Increase timeout for youtube-dl-exec
    room.user.say 'alice', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'
    setTimeout ->
      assert room.messages.length > 1
      done()
    , 5000
