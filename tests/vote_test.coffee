Helper = require('hubot-test-helper')

helper = new Helper('../scripts/vote.coffee')
expect = require('chai').expect
sinon = require('sinon')

describe 'user voting', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'vote?', ->
    it 'should tell the user how to vote', ->
      room.user.say 'alice', '@hubot vote?'
      expect(room.messages[1][1].split("\n")[0]).to.eql "Voting allows you to pretend you have the power of a god."

  context 'custom timeout', ->
    beforeEach ->
      this.clock = sinon.useFakeTimers()

    afterEach ->
      this.clock.restore()

    it "shouldn't expire for 10 minutes", ->
      room.user.say 'alice', '@hubot vote 10 on Foo'
      this.clock.tick(300000)
      expect(room.messages.length).to.eql 2
      this.clock.tick(300000)
      expect(room.messages.length).to.eql 3
      expect(room.messages[2][1]).to.contain "Vote failed, time's up!"
