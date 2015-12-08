Helper = require('hubot-test-helper')

helper = new Helper('../scripts/youtube-info.coffee')
expect = require('chai').expect

describe 'when user links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'youtube.com url', ->

    it 'should be able to find title', (done) ->

      @timeout(10000)

      room.user.say 'alice', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'
      setTimeout =>
        expect(room.messages[1][1]).to.contain "Adele's Hello by the Movies"
        console.log room.messages
        done()
      , 10000

  context 'youtube.com url with additional values', ->

    it 'should be able to find title', (done) ->

      @timeout(10000)

      room.user.say 'alice', 'https://www.youtube.com/watch?v=iq9DLJfpHd0&feature=youtu.be&ab_channel=CatRe-Tailer'
      setTimeout =>
        expect(room.messages[1][1]).to.contain "Shia Surprise"
        console.log room.messages
        done()
      , 10000

  context 'youtu.be url', ->

    it 'should be able to find title', (done) ->

      @timeout(10000)

      room.user.say 'alice', 'https://youtu.be/HP66dH1yEZo'
      setTimeout =>
        expect(room.messages[1][1]).to.contain "R2D2 learns a new trick"
        console.log room.messages
        done()
      , 10000

  context 'youtu.be url with additional values', ->

    it 'should be able to find title', (done) ->

      @timeout(10000)

      room.user.say 'alice', 'https://youtu.be/oVnAVcbMoSM?t=39s'
      setTimeout =>
        expect(room.messages[1][1]).to.contain "GoPro fall at Garden of the Gods"
        console.log room.messages
        done()
      , 10000

