Helper = require('hubot-test-helper')

helper = new Helper('../scripts/loud.coffee')
expect = require('chai').expect

describe 'when user uses underscores', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'respond with adlib', ->
    it 'should replace underscores with adlib', ->
      room.user.say 'alpha', 'At _____ they ventured into his room.'
      console.log room.messages
      expect(room.messages[2][1]).to.not.contain '_____'

    it 'should support multiple underscores', ->
      room.user.say 'beta', 'Bits of ___ clung to the ___.'
      console.log room.messages
      expect(room.messages[2][1]).to.not.contain '___'

    it 'should have a populated database', ->
      console.log room.robot.brain.get('adlib')
      expect(room.robot.brain.get('adlib')).to.have.length.above 1
