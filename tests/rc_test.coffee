assert = require 'assert'

Helper = require('hubot-test-helper')

helper = new Helper('../scripts/rc.coffee')
expect = require('chai').expect
stub = require('sinon').stub

describe 'Roll Call', ->
  room = null
  random_stub = null

  beforeEach ->
    room = helper.createRoom()

  context 'sanity', ->
    beforeEach ->
      room.user.say 'alice', '@hubot rc ping'

    it 'compiled if it got this fucking far', ->
      assert room.messages.length > 0
