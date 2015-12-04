Helper = require('hubot-test-helper')

helper = new Helper('../scripts/youtube-info.coffee')
expect = require('chai').expect

describe 'when user links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'youtube.com url', ->
    beforeEach (done) ->
      setTimeout ->
        room.user.say 'alice', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'
        done()
      , 10000
      
    it 'should be able to find title', ->
      console.log room.messages
      expect(room.messages[1][1]).to.contain "Adele's Hello by the Movies"

  context 'youtube.com url with additional values', ->
    beforeEach (done)->
      setTimeout ->
        room.user.say 'alice', 'https://www.youtube.com/watch?v=iq9DLJfpHd0&feature=youtu.be&ab_channel=CatRe-Tailer'
        done()
      , 10000

    it 'should be able to find title', ->
      console.log room.messages
      expect(room.messages[1][1]).to.contain "Shia Surprise"

  context 'youtu.be url', ->
    beforeEach (done) ->
      setTimeout ->
        room.user.say 'alice', 'https://youtu.be/HP66dH1yEZo'
        done()
      , 10000

    it 'should be able to find title', ->
      console.log room.messages
      expect(room.messages[1][1]).to.contain "R2D2 learns a new trick"

  context 'youtu.be url with additional values', ->
    beforeEach (done) ->
      setTimeout ->
        room.user.say 'alice', 'https://youtu.be/oVnAVcbMoSM?t=39s'
        done()
      , 10000

    it 'should be able to find title', ->
      console.log room.messages
      expect(room.messages[1][1]).to.contain "GoPro fall at Garden of the Gods"

