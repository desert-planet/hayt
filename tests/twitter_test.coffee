assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/twitter.coffee')

describe 'Twitter', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.user.say 'shithead', '@hubot hello, this is dog'

  it 'compiled if it got this fucking far', ->
    assert room.messages.length > 0

  it 'probably errors when we try to use it, but with words not Exceptions', ->
    room.user.say 'KimK', "@hubot tweet I'm so pretty!!!!"
    assert room.messages.length > 0