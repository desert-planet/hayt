Helper = require('hubot-test-helper')

helper = new Helper('../scripts/youtube-info.coffee')
expect = require('chai').expect
sinon = require('sinon')

describe 'when user links', ->
  room = null

  beforeEach ->
    room = helper.createRoom()
    this.clock = sinon.useFakeTimers()

  afterEach ->
    this.clock.restore()

  context 'youtube.com url', ->
    beforeEach ->
      room.user.say 'alice', 'https://www.youtube.com/watch?v=ePoi0_zSnYk'
      this.clock.tick(3000)

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "Adele's Hello by the Movies"

  context 'youtube.com url with additional values', ->
    beforeEach ->
      room.user.say 'alice', 'https://www.youtube.com/watch?v=iq9DLJfpHd0&feature=youtu.be&ab_channel=CatRe-Tailer'
      this.clock.tick(3000)

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "Shia Surprise"

  context 'youtu.be url', ->
    beforeEach ->
      room.user.say 'alice', 'https://youtu.be/HP66dH1yEZo'
      this.clock.tick(3000)

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "R2D2 learns a new trick"

  context 'youtu.be url with additional values', ->
    beforeEach ->
      room.user.say 'alice', 'https://youtu.be/oVnAVcbMoSM?t=39s'
      this.clock.tick(3000)

    it 'should be able to find title', ->
      expect(room.messages[1][1]).to.contain "GoPro fall at Garden of the Gods"

