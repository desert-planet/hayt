Helper = require('hubot-test-helper')

helper = new Helper('../scripts/loud.coffee')
expect = require('chai').expect
co = require('co')

describe 'being loud', ->
  room = null

  beforeEach ->
    room = helper.createRoom(httpd: false)

  afterEach ->
    room.destroy()

  context 'loud database', ->
    it 'should have 3 louds after some user chatter', ->
      co ->
        yield room.user.say 'alice',   'WHO THE HECK ARE YOU'
        yield room.user.say 'bob',     'WHAT IS GOING ON HERE'
        yield room.user.say 'charlie', 'HELP I AM TRAPPED IN A UNIT TEST'
        expect(room.robot.brain.get('louds').length).to.eql 3
        expect(room.robot.brain.get('louds')).to.eql ['WHO THE HECK ARE YOU', 'WHAT IS GOING ON HERE', 'HELP I AM TRAPPED IN A UNIT TEST']

    it 'should support funny characters', ->
      co ->
        yield room.user.say 'alice',   '"FOO"'
        yield room.user.say 'bob',     'FOO+'
        yield room.user.say 'charlie', 'FOO-'
        yield room.user.say 'alice',   'FOO!'
        yield room.user.say 'bob',     'FOO@BAR'
        yield room.user.say 'charlie', 'FOO #BAR'
        yield room.user.say 'alice',   'FOO$'
        yield room.user.say 'bob',     'FOO%'
        yield room.user.say 'charlie', 'FOO?'
        yield room.user.say 'alice',   'FOO & BAR'
        yield room.user.say 'charlie', 'FOO"BAR"'
        expect(room.robot.brain.get('louds').length).to.eql 11

    it 'should only have 1 loud stored after deleting the second', ->
      co ->
        yield room.user.say 'alice', 'FOO'
        yield room.user.say 'bob',   'BAR'
        yield room.user.say 'alice', '@hubot loud delete BAR'
        expect(room.robot.brain.get('louds')).to.eql ['FOO']

    it 'should store banned words', ->
      co ->
        yield room.user.say 'alice', 'FOO'
        yield room.user.say 'bob',   'BAR'
        yield room.user.say 'alice', '@hubot loud ban BAR '
        expect(room.robot.brain.get('louds_banned')).to.eql ['BAR']

    it 'should be able to removed banned words', ->
      co ->
        yield room.user.say 'alpha',   'BAR'
        yield room.user.say 'bravo',   '@hubot loud ban BAR'
        yield room.user.say 'charlie', '@hubot loud unban BAR'
        expect(room.robot.brain.get('louds_banned')).to.eql []

  context 'louds in chat', ->
    it 'should be produced whenever someone louds anew', ->
      co ->
        yield room.user.say 'alice', 'FOO'
        yield room.user.say 'bob',   'BAR'
        expect(room.messages[2]).to.eql ['hubot', 'FOO']

  context 'louds in chat not from banned', ->
    it 'should be produced whenever someone louds anew', ->
      co ->
        yield room.user.say 'alpha',   'FISH'
        yield room.user.say 'bravo',   '@hubot loud ban FISH'
        yield room.user.say 'charlie', 'CHICKEN'
        yield room.user.say 'delta',   'COW'
        expect(room.messages[5]).to.eql ['hubot', 'CHICKEN']
