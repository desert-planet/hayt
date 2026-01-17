Helper = require('hubot-test-helper')
helper = new Helper('../scripts/pottymouths.coffee')
expect = require('chai').expect

describe 'pottymouths', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  it 'should not die if nobody cusses', ->
    room.user.say 'alice', '@hubot pottymouths'
    expect(room.messages[1][1]).to.eql "The pottiest of mouths"

  it 'report top cussists', ->
    room.user.say 'alice', 'oh shit oh fuck'
    room.user.say 'bob', 'i would never cuss'
    room.user.say 'charlie', 'fuck shit piss damnit'

    room.user.say 'alice', '@hubot pottymouths'
    expect(room.messages[4][1]).to.eql "The pottiest of mouths\n1. charlie (4)\n2. alice (2)"
