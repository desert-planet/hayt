Helper = require('hubot-test-helper')
expect = require('chai').expect
helper = new Helper('../scripts/youtube-info.coffee')

class MockResponse extends Helper.Response
  send: (strings...) ->
      "Works"

describe 'when user links', ->
  room = null

  beforeEach ->
      room = helper.createRoom({'response': MockResponse})

  afterEach ->
      room.destroy()

  context 'youtube.com url', ->
    beforeEach (done) ->
        room.user.say 'fuckyou', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'
        "Adele's Hello by the Movies"
      
    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "Works"

  context 'youtube.com url with additional values', ->
    beforeEach (done)->
        room.user.say 'alice', 'https://www.youtube.com/watch?v=iq9DLJfpHd0&feature=youtu.be&ab_channel=CatRe-Tailer'

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "Shia Surprise"

  context 'youtu.be url', ->
    beforeEach (done) ->
        room.user.say 'alice', 'https://youtu.be/HP66dH1yEZo'

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "R2D2 learns a new trick"

  context 'youtu.be url with additional values', ->
    beforeEach (done) ->
        room.user.say 'alice', 'https://youtu.be/oVnAVcbMoSM?t=39s'

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "GoPro fall at Garden of the Gods"

