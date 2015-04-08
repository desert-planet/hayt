Helper = require('../node_modules/hubot-test-helper/src/index.coffee')

helper = new Helper('../scripts/dice.coffee')

expect = require('chai').expect

describe 'dice rolling', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'user rolls 1d1', ->
    beforeEach ->
      room.user.say 'alice', '@hubot roll 1d1'
      room.user.say 'bob', '@hubot roll 1d0'
      room.user.say 'eric', '@hubot roll 1d-1'

    it 'should be invalid snarky message', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot roll 1d1']
        ['hubot', '@alice You want to roll dice with less than two sides. Wow.']
        ['bob', '@hubot roll 1d0']
        ['hubot', '@alice You want to roll dice with less than two sides. Wow.']
        ['eric', '@hubot roll 1d-1']
        ['hubot', '@alice You want to roll dice with less than two sides. Wow.']
      ]
