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

  it 'should report top cussists', ->
    room.user.say 'alice', 'oh shit oh fuck'
    room.user.say 'bob', 'i would never cuss'
    room.user.say 'charlie', 'fuck shit piss damnit'

    room.user.say 'alice', '@hubot pottymouths'
    expect(room.messages[4][1]).to.eql "The pottiest of mouths\n1. charlie (4)\n2. alice (2)"

  it 'should report top cusses', ->
    room.user.say 'alice', 'oh shit oh fuck oh piss'
    room.user.say 'alice', 'oh fuck shit'
    room.user.say 'alice', 'fuck'

    room.user.say 'alice', '@hubot cusses alice'
    expect(room.messages[4][1]).to.eql "alice's top cusses\n1. fuck (3)\n2. shit (2)\n3. piss (1)"

    room.user.say 'alice', '@hubot cusses bob'
    expect(room.messages[6][1]).to.eql "bob's top cusses"

    room.user.say 'alice', '@hubot cusses'
    expect(room.messages[8][1]).to.eql "Top cusses\n1. fuck (3)\n2. shit (2)\n3. piss (1)"

  it 'should report how many times a cuss is said', ->
    room.user.say 'alice', 'oh shit oh fuck oh piss'
    room.user.say 'alice', 'oh fuck shit'
    room.user.say 'alice', 'fuck'

    room.user.say 'alice', '@hubot cuss fuck'
    expect(room.messages[4][1]).to.eql "'fuck' has been said 4 times"

    room.user.say 'alice', '@hubot cuss damn'
    expect(room.messages[6][1]).to.eql "'damn' has been said 1 times"

    room.user.say 'alice', '@hubot cuss butt'
    expect(room.messages[8][1]).to.eql "'butt' isn't a (recognized) cuss!"

  it 'should be case insensitive', ->
    room.user.say 'alice', 'oh shit oh fuck oh piss'
    room.user.say 'aLiCe', 'Oh FuCk ShIt'
    room.user.say 'ALICE', 'FUCK'

    room.user.say 'alice', '@hubot cusses Alice'
    expect(room.messages[4][1]).to.eql "alice's top cusses\n1. fuck (3)\n2. shit (2)\n3. piss (1)"

    room.user.say 'alice', '@hubot cusses'
    expect(room.messages[6][1]).to.eql "Top cusses\n1. fuck (3)\n2. shit (2)\n3. piss (1)"

    room.user.say 'alice', '@hubot cuss Fuck'
    expect(room.messages[8][1]).to.eql "'fuck' has been said 4 times"
