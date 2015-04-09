Helper = require('hubot-test-helper')

helper = new Helper('../scripts/dice.coffee')

expect = require('chai').expect

describe 'when user rolls', ->
  room = null
  user_list = ['alice', 'bob', 'eric']

  beforeEach ->
    room = helper.createRoom()

  context 'an invalid dice', ->
    beforeEach ->
      room.user.say 'alice', '@hubot roll 1d1'
      room.user.say 'bob', '@hubot roll 1d0'
      room.user.say 'eric', '@hubot roll 1d-1'

    it 'should be snarky message', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot roll 1d1']
        ['hubot', '@alice You want to roll dice with less than two sides. Wow.']
        ['bob', '@hubot roll 1d0']
        ['hubot', '@bob You want to roll dice with less than two sides. Wow.']
        ['eric', '@hubot roll 1d-1']
        # Nothing returns for last command.
      ]

  context 'a die', ->
    beforeEach ->
      for name in user_list
        room.user.say name, '@hubot roll die'

    it 'should be "I rolled a 1d6."', ->
      messages = room.messages
      count = messages.length
      for i in [0...count] by 2
        # Get each pair of request and response.
        request = messages[i]
        response = messages[i+1]

        # Split out request and response
        user = request[0]
        user_msg = request[1]
        bot = response[0]
        bot_msg = response[1]

        # TODO Parse bot_msg so that the roll is checkable.

        # Assertions
        expect(user_list).to.include(user)
        expect(user_msg).to.eql '@hubot roll die'
        expect(bot).to.eql 'hubot'
        expect(bot_msg).to.be.a('string')
  
  context 'dice', ->
  
  context 'configurable-sided dice', ->
  
  context 'fudge dice', ->
