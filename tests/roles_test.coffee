Helper = require('hubot-test-helper')
expect = require('chai').expect

helper = new Helper('../scripts/roles.coffee')

describe 'roles management', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

    # Manually create users in the brain since the test helper doesn't do it
    # automatically.
    room.robot.brain.userForId('1', name: 'alice')
    room.robot.brain.userForId('2', name: 'bob')

  context 'assigning roles', ->
    it 'should assign a role to a user', ->
      room.user.say 'alice', '@hubot bob is a badass guitarist'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.contain 'a badass guitarist'
      expect(room.messages[1][1]).to.eql 'Ok, bob is a badass guitarist.'
