Helper = require('hubot-test-helper')
helper = new Helper('../scripts/triggers.coffee')
expect = require('chai').expect

describe 'triggers', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  it 'should let you set a trigger', ->
    trigger = 'butts'
    response = 'Haha butts'
    room.user.say 'skalnik', "@hubot trigger #{trigger} to #{response}"
    expect(room.robot.brain.get('triggers')[trigger]).to.eql response

  it 'should let you delete a trigger', ->
    trigger = 'butts'
    response = 'Haha butts'
    room.user.say 'skalnik', "@hubot trigger #{trigger} to #{response}"
    expect(room.robot.brain.get('triggers')[trigger]).to.eql response
    room.user.say 'buttFace', "@hubot trigger delete #{trigger}"
    expect(room.robot.brain.get('triggers')[trigger]).to.eql undefined

  it 'responds with the known response if it hears a trigger', ->
    trigger = 'butts'
    response = 'Haha butts'
    room.user.say 'skalnik', "@hubot trigger #{trigger} to #{response}"
    room.user.say 'aBird', "All about dem #{trigger}!"
    expect(room.messages[3]).to.eql ['hubot', response]

  it 'ignores the robot itself', ->
    trigger = 'butts'
    response = 'Haha butts'
    room.user.say 'skalnik', "@hubot trigger #{trigger} to #{response}"
    expect(room.messages.length).to.eql 2
