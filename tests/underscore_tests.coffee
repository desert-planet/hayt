Helper = require('hubot-test-helper')

helper = new Helper('../scripts/underscores.coffee')
expect = require('chai').expect
co = require('co')

describe 'when user uses underscores', ->
  room = null

  beforeEach ->
    room = helper.createRoom(httpd: false)
    room.robot.brain.remove('adlib')
    room.robot.brain.set('adlib', ['dickbutt'])

  afterEach ->
    room.destroy()

  context 'respond with adlib', ->
    it 'should replace underscores with adlib', ->
      co ->
        yield room.user.say 'alpha', 'At ___ they ventured into his room.'
        expect(room.messages[1][1]).to.not.contain '_____'
        expect(room.messages[1][1]).to.contain 'dickbutt'

    it 'should support multiple adlibs', ->
      co ->
        yield room.user.say 'beta', 'Bits of ___ clung to the ___.'
        expect(room.messages[1][1]).to.not.contain '___'
        expect(room.messages[1][1]).to.contain 'dickbutt'

    it 'should support underscores of any length', ->
      co ->
        yield room.user.say 'charlie', 'We _____ the ______.'
        expect(room.messages[1][1]).to.not.contain '_____'
        expect(room.messages[1][1]).to.not.contain '______'
        expect(room.messages[1][1]).to.contain 'dickbutt'
