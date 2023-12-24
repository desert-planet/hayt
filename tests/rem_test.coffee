Helper = require('hubot-test-helper')

helper = new Helper('../scripts/loud.coffee')
expect = require('chai').expect

describe 'remembering things', ->
  room = null
  memoriesByRecollection = () -> room.robot.brain.data.memoriesByRecollection ?= {}
  memories = () -> room.robot.brain.data.remember ?= {}

  beforeEach ->
    room = helper.createRoom()

  it 'should remember things', ->
    room.user.say 'alice', '@hubot rem key is value', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot rem key is value']
        ['hubot', 'Okay, I\'ll remember key']
      ]
      expect(room.robot.brain.data.remember['key']).to.eql 'value'
