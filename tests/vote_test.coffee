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
  
      # Start the fucking vote.
      expect(room.messages.shift()).to.eql ['alice', '@hubot vote poop']
      expect(room.messages.shift()).to.eql ['hubot', 'New Vote: Should I poop!?']
  
      vote_random = (messages, user) ->
        request = messages.shift()
        expect(request).to.eql ["#{user}", '@hubot vote random']
        response = messages.shift()
        bot = response.shift()
        msg = response.shift()
        expect(bot).to.eql 'hubot'
        pattern = "#{user}: Your vote totally counted with a [yes|no]."
        assert(msg.matches /pattern/)
  
      # Submit random votes.
      vote_random room.messages, 'alice'
      vote_random room.messages, 'tom'
      vote_random room.messages, 'sally'
      vote_random room.messages, 'eric'
      vote_random room.messages, 'betsy'
      
      # Finished vote.
      message = room.messages.shift()
      expect(message.shift()).to.eql 'hubot'
      assert(message.shift().match /Vote passed, time's up! (60 seconds)/)
      
      # Poop picture.
      expect(room.messages.shift()).to.eql ["hubot", "http://i.imgur.com/ZTukQOl.gif"]
