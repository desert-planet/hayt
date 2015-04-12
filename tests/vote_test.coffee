Helper = require('hubot-test-helper')

helper = new Helper('../scripts/vote.coffee')

expect = require('chai').expect

sleep = (ms) ->
  start = new Date().getTime()
  continue while new Date().getTime() - start < ms

describe 'user voting', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'vote?', ->
    it 'should tell the user how to vote', ->
      room.user.say 'alice', '@hubot vote?'
      expect(room.messages[1][1].split("\n")[0]).to.eql "Voting allows you to pretend you have the power of a god."
      
  context 'vote random', ->
    it 'should submit a random vote', ->
      room.user.say 'alice', '@hubot vote poop'
      room.user.say 'alice', '@hubot vote random'
      room.user.say 'tom', '@hubot vote random'
      room.user.say 'sally', '@hubot vote random'
      room.user.say 'eric', '@hubot vote random'
      room.user.say 'betsy', '@hubot vote random'
      sleep 60000 # 60 seconds

      expect(room.messages).to.eql [
        ['alice', '@hubot vote poop']
        ['hubot', 'New Vote: Should I poop!?']
        ['alice', '@hubot vote random']
        ['hubot', 'alice: Your vote totally counted with a #{value}.']
        ['tom', '@hubot vote random']
        ['hubot', 'tom: Your vote totally counted with a #{value}.']
        ['sally', '@hubot vote random']
        ['hubot', 'sally: Your vote totally counted with a #{value}.']
        ['eric', '@hubot vote random']
        ['hubot', 'eric: Your vote totally counted with a #{value}.']
        ['betsy', '@hubot vote random']
        ['hubot', 'betsy: Your vote totally counted with a #{value}.']
        ['hubot', 'Vote #{result}, time\'s up! (60 seconds)']
      ]
