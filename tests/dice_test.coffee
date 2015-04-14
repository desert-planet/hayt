Helper = require('hubot-test-helper')

helper = new Helper('../scripts/dice.coffee')
expect = require('chai').expect
stub = require('sinon').stub

describe 'when user rolls', ->
  room = null
  random_stub = null

  beforeEach ->
    room = helper.createRoom()

  context 'invalid dice', ->
    beforeEach ->
      room.user.say 'alice', '@hubot roll 1d1'
      room.user.say 'bob', '@hubot roll 1d0'
      room.user.say 'eric', '@hubot roll 1d-1'

    it 'should be snarky message', ->
      expect(room.messages).to.eql [
        ['alice', '@hubot roll 1d1']
        ['hubot', '@alice You want to roll dice with less than two sides. Wow.']
        ['bob', '@hubot roll 1d0']
        ['hubot', '@bob You want to roll dice with less than two sides. Wow.']
        ['eric', '@hubot roll 1d-1']
        # Nothing returns for last command.
      ]

  context 'and drops lowest die', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0.9) # 6
      random_stub.onCall(1).returns(0.7) # 5
      random_stub.onCall(2).returns(0.5) # 4
      random_stub.onCall(3).returns(0.4) # 3
      room.user.say 'alice', '@hubot roll 4d6 drop_low 1'

    afterEach ->
      random_stub.restore()

    it 'should only return 3 results', ->
      expect(room.messages[1][1]).to.match /I rolled \d, \d, and \d/

    it 'should total 15', ->
      expect(room.messages[1][1]).to.contain "making 15."

  context 'and rerolls 1s and 2s', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0) # 1
      random_stub.onCall(1).returns(0.3) # 2
      random_stub.onCall(2).returns(0.4) # 3
      random_stub.onCall(3).returns(0.5) # 4
      random_stub.onCall(4).returns(0.7) # 5
      random_stub.onCall(5).returns(0.9) # 6
      room.user.say 'alice', '@hubot roll 4d6 reroll 2'

    afterEach ->
      random_stub.restore()

    it "shouldn't return any 1s or 2s", ->
      expect(room.messages[1][1]).to.match /I rolled [3-6], [3-6], [3-6], and [3-6]/

    it 'should total 18', ->
      expect(room.messages[1][1]).to.contain "making 18."

  context 'and rerolls 1s twice, but is having terrible luck', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.returns(0) # 1
      room.user.say 'alice', '@hubot roll 4d6 reroll 1 reroll_max 2'

    afterEach ->
      random_stub.restore()

    it 'should return 1s', ->
      expect(room.messages[1][1]).to.contain "I rolled 1, 1, 1, and 1, making 4."

    it 'should call Math.random 12 times', ->
      expect(random_stub.callCount).to.eql 12

  context 'and rerolls all possible dice values', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0) # 1
      random_stub.onCall(1).returns(0.3) # 2
      random_stub.onCall(2).returns(0.4) # 3
      random_stub.onCall(3).returns(0.5) # 4
      random_stub.onCall(4).returns(0.7) # 5
      random_stub.onCall(5).returns(0.9) # 6
      room.user.say 'alice', '@hubot roll 4d6 reroll 6'

    afterEach ->
      random_stub.restore()

    it "should just skip rerolling", ->
      expect(random_stub.callCount).to.eql 4
      expect(room.messages[1][1]).to.match /I rolled 1, 2, 3, and 4/
