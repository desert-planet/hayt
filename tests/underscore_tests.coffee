Helper = require('hubot-test-helper')

helper = new Helper('../scripts/underscores.coffee')
expect = require('chai').expect

describe 'when user uses underscores', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    room.robot.brain.remove('adlib')
    room.robot.brain.set('adlib', ['dickbutt'])

  context 'respond with adlib', ->
    it 'should replace underscores with adlib', ->
      room.user.say 'alpha', 'At ___ they ventured into his room.'
      expect(room.messages[1][1]).to.not.contain '_____'
      expect(room.messages[1][1]).to.contain 'dickbutt'

    it 'should support multiple adlibs', ->
      room.user.say 'beta', 'Bits of ___ clung to the ___.'
      expect(room.messages[1][1]).to.not.contain '___'
      expect(room.messages[1][1]).to.contain 'dickbutt'

    it 'should support underscores of any length', ->
      room.user.say 'charlie', 'We _____ the ______.'
      expect(room.messages[1][1]).to.not.contain '_____'
      expect(room.messages[1][1]).to.not.contain '______'
      expect(room.messages[1][1]).to.contain 'dickbutt'
