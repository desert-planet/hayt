Helper = require('hubot-test-helper')

helper = new Helper('../scripts/remember.coffee')
expect = require('chai').expect

describe '.rem/.replace', ->
  room = null

  lastResponse = () -> room.messages[room.messages.length - 1]

  beforeEach ->
    room = helper.createRoom()

  it 'should remember things', ->
    # Test that we can create a new memory.
    room.user.say 'alice', '@hubot rem key is value'

    expect(lastResponse()).to.eql ['hubot', 'OK, I\'ll remember key.']
    expect(room.robot.brain.data.remember['key']).to.eql 'value'

    # Test recalling the new memory.
    room.user.say 'alice', '@hubot rem key'
    expect(lastResponse()).to.eql ['hubot', 'value']

  it 'should be able to update memories', ->
    # Create a new memory `key` and then update its value.
    room.user.say 'alice', '@hubot rem key is value'
    room.user.say 'alice', '@hubot replace key with a different value'

    expect(lastResponse()).to.eql ['hubot', 'OK, key has been updated.']
    expect(room.robot.brain.data.remember['key']).to.eql 'a different value'

  it 'should be able to forget memories', ->
    # Create a new memory `key` and then try to forget it.
    room.user.say 'alice', '@hubot rem key is value'
    room.user.say 'alice', '@hubot forget key'

    expect(lastResponse()).to.eql ['hubot', 'I\'ve forgotten key is value.']
    expect(room.robot.brain.data.remember['key']).to.eql undefined

    # Make sure we respond correctly if no such key exists.
    room.user.say 'alice', '@hubot forget key'
    expect(lastResponse()).to.eql ['hubot', "I don't remember anything matching `key`... so we're probably all good?"]

  it 'should not hallucinate memories', ->
    room.user.say 'alice', '@hubot rem key'

    expect(lastResponse()).to.eql ['hubot', 'I don\'t remember anything matching `key`']
    expect(room.robot.brain.data.remember['key']).to.eql undefined
