Helper = require('hubot-test-helper')

helper = new Helper('../scripts/vote.coffee')

expect = require('chai').expect

describe 'user voting', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'vote?', ->
    it 'should tell the user how to vote', ->
      room.user.say 'alice', '@hubot vote?'
      expect(room.messages[0]).to.eql "Voting allows you to pretend you have the power of a god."
