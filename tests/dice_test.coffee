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

  context 'and drops the lowest die', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0.9) # 6
      random_stub.onCall(1).returns(0.7) # 5
      random_stub.onCall(2).returns(0.5) # 4
      random_stub.onCall(3).returns(0.4) # 3
      room.user.say 'alice', '@hubot roll 4d6d1'

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
      room.user.say 'alice', '@hubot roll 4d6r<2'

    afterEach ->
      random_stub.restore()

    it "shouldn't return any 1s or 2s", ->
      expect(room.messages[1][1]).to.match /I rolled [3-6], [3-6], [3-6], and [3-6]/

    it 'should total 18', ->
      expect(room.messages[1][1]).to.contain "making 18."

  context 'and rerolls 1s once, but is having terrible luck', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.returns(0) # 1
      room.user.say 'alice', '@hubot roll 4d6ro<1'

    afterEach ->
      random_stub.restore()

    it 'should return 1s', ->
      expect(room.messages[1][1]).to.contain "I rolled 1, 1, 1, and 1, making 4."

    it 'should call Math.random 8 times', ->
      expect(random_stub.callCount).to.eql 8

  context 'and rerolls all possible dice values', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0) # 1
      random_stub.onCall(1).returns(0.3) # 2
      random_stub.onCall(2).returns(0.4) # 3
      random_stub.onCall(3).returns(0.5) # 4
      random_stub.onCall(4).returns(0.7) # 5
      random_stub.onCall(5).returns(0.9) # 6
      room.user.say 'alice', '@hubot roll 4d6r<6'

    afterEach ->
      random_stub.restore()

    it "should just skip rerolling", ->
      expect(room.messages[1][1]).to.match /I rolled 1, 2, 3, and 4/
      expect(random_stub.callCount).to.eql 4

  context 'and rerolls anything over 4', ->
    beforeEach ->
      random_stub = stub(Math, "random")
      random_stub.onCall(0).returns(0.7) # 5
      random_stub.onCall(1).returns(0.9) # 6
      random_stub.onCall(2).returns(0)   # 1
      random_stub.onCall(3).returns(0.3) # 2
      random_stub.onCall(4).returns(0.4) # 3
      random_stub.onCall(5).returns(0.5) # 4
      room.user.say 'alice', '@hubot roll 4d6r>5'

    afterEach ->
      random_stub.restore()

    it "should only have low rolls", ->
      expect(room.messages[1][1]).to.match /I rolled [1-4], [1-4], [1-4], and [1-4]/

  context '2 dice and drops the lowest', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 20
      random_stub.onCall(1).returns(0) # 1
      room.user.say 'alice', '@hubot roll 2d20d1'

    afterEach ->
      random_stub.restore()

    it 'should output as if a single die were rolled', ->
      expect(room.messages[1][1]).to.contain 'I rolled a 20.'

  context '2 dice and drops both of them', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 20
      random_stub.onCall(1).returns(0) # 1
      room.user.say 'alice', '@hubot roll 2d20d2'

    afterEach ->
      random_stub.restore()

    it 'should output as if no dice were rolled', ->
      expect(room.messages[1][1]).to.contain "I didn't roll any dice."

  context 'exploding dice', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 10
      random_stub.onCall(1).returns(0.99) # 10
      random_stub.onCall(2).returns(0.5) # 6
      random_stub.onCall(3).returns(0.4) # 5
      random_stub.onCall(4).returns(0.99) # 10
      random_stub.onCall(5).returns(0) # 1
      random_stub.onCall(6).returns(0.99) # 10
      random_stub.onCall(7).returns(0.5) # 6
      random_stub.onCall(8).returns(0.4) # 5, shouldn't get rolled
      room.user.say 'alice', '@hubot roll 4d10!'

    afterEach ->
      random_stub.restore()

    it 'should explode properly', ->
      expect(room.messages[1][1]).to.match /I rolled \d+, \d+, \d+, \d+, \d+, \d+, \d+, and \d+/
      expect(random_stub.callCount).to.eql 8

  context 'and keeps only the highest 2 dice rolled', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 10
      random_stub.onCall(1).returns(0.5) # 6
      random_stub.onCall(2).returns(0.4) # 5
      random_stub.onCall(3).returns(0.4) # 5
      random_stub.onCall(4).returns(0) # 1
      room.user.say 'alice', '@hubot roll 5d10k2'

    afterEach ->
      random_stub.restore()

    it 'should have 2 results, totalling 16', ->
      expect(room.messages[1][1]).to.match /I rolled \d+ and \d+/
      expect(room.messages[1][1]).to.match /making 16/

  context 'and keeps only the lowest 2 dice rolled', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 10
      random_stub.onCall(1).returns(0.5) # 6
      random_stub.onCall(2).returns(0.4) # 5
      random_stub.onCall(3).returns(0.4) # 5
      random_stub.onCall(4).returns(0) # 1
      room.user.say 'alice', '@hubot roll 5d10kl2'

    afterEach ->
      random_stub.restore()

    it 'should have 2 results, totalling 6', ->
      expect(room.messages[1][1]).to.match /I rolled \d+ and \d+/
      expect(room.messages[1][1]).to.match /making 6/

  context 'and keeps only the lowest die', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 20
      random_stub.onCall(1).returns(0) # 1
      room.user.say 'alice', '@hubot roll 2d20dh1'

    afterEach ->
      random_stub.restore()

    it 'should have a single, low result', ->
      expect(room.messages[1][1]).to.match /I rolled a 1/

  context 'and specifies a success threshold', ->
    beforeEach ->
      random_stub = stub(Math, 'random')
      random_stub.onCall(0).returns(0.99) # 10
      random_stub.onCall(1).returns(0.6) # 7
      random_stub.onCall(2).returns(0.4) # 5
      random_stub.onCall(3).returns(0.4) # 5
      random_stub.onCall(4).returns(0) # 1
      random_stub.onCall(5).returns(0) # 1

    afterEach ->
      random_stub.restore()

    it 'should have 2 successes at >= 7', ->
      room.user.say 'alice', '@hubot roll 6d10>7'
      expect(room.messages[1][1]).to.match /2 successes./

    it 'should have 4 successes at <= 5', ->
      room.user.say 'alice', '@hubot roll 6d10<5'
      expect(room.messages[1][1]).to.match /4 successes./

    it 'should have 1 success at >= 9', ->
      room.user.say 'alice', '@hubot roll 6d10>9'
      expect(room.messages[1][1]).to.match /1 success./

    it 'should have 1 success with 1d10>9', ->
      room.user.say 'alice', '@hubot roll 1d10>9'
      expect(room.messages[1][1]).to.match /I rolled a success./

    it 'should have a failure with 1d10<9', ->
      room.user.say 'alice', '@hubot roll 1d10<9'
      expect(room.messages[1][1]).to.match /I rolled a failure./
