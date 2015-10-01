Helper = require('hubot-test-helper')

helper = new Helper('../scripts/dice.coffee')
expect = require('chai').expect
stub = require('sinon').stub

describe 'when user rolls', ->
  room = null
  random_stub = null

  beforeEach ->
    room = helper.createRoom()

  context 'No crash happens', ->
    beforeEach ->
      room.user.say 'alice', '@hubot roll 1d6'
      room.user.say 'alice', '@hubot roll 1d1'
      room.user.say 'bob', '@hubot roll 1d0'
      room.user.say 'eric', '@hubot roll 1d-1'

    it 'is sstill alive', ->
      expect(room.messages.length).to.be.above(0)