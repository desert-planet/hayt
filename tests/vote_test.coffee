Helper = require('hubot-test-helper')

helper = new Helper('../scripts/vote.coffee')

expect = require('chai').expect
assert = require('chai').assert

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

      test_random = (messages, user) ->
        request = messages.shift()
        response = messages.shift()
        expect(request).to.eql ['#{user}', '@hubot vote random']
        bot = response.shift()
        msg = response.shift()
        expect(bot).to.eql 'hubot'
        assert(msg.matches /'#{user}: Your vote totally counted with a [yes|no].'/)
        
      expect(room.messages.shift()).to.eql ['alice', '@hubot vote poop']
      expect(room.messages.shift()).to.eql ['hubot', 'New Vote: Should I poop!?']
      
      test_random room.messages 'alice'
      
      expect(room.messages.shift()).to.eql ['tom', '@hubot vote random']
      expect(room.messages.shift()).to.eql ['hubot', 'tom: Your vote totally counted with a #{value}.']
      
      expect(room.messages.shift()).to.eql ['sally', '@hubot vote random']
      expect(room.messages.shift()).to.eql ['hubot', 'sally: Your vote totally counted with a #{value}.']
      
      expect(room.messages.shift()).to.eql ['eric', '@hubot vote random']
      expect(room.messages.shift()).to.eql ['hubot', 'eric: Your vote totally counted with a #{value}.']
      
      expect(room.messages.shift()).to.eql ['betsy', '@hubot vote random']
      expect(room.messages.shift()).to.eql ['hubot', 'betsy: Your vote totally counted with a #{value}.']
      
      expect(room.messages.shift()).to.eql ['hubot', 'Vote #{result}, time\'s up! (60 seconds)']
      expect(room.messages.shift()).to.eql ["hubot", "http://i.imgur.com/ZTukQOl.gif"]
