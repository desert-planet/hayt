assert = require 'assert'
util = require 'util'

Helper = require('hubot-test-helper')

helper = new Helper('../scripts/rc.coffee')
expect = require('chai').expect
stub = require('sinon').stub

describe 'Roll Call', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'sanity', ->
    beforeEach ->
      room.user.say 'alice', '@hubot rc ping'
      room.user.say 'alice', '@hubot rc 5'
      room.user.say 'alice', '@hubot rc for alice'

    it 'compiled if it got this fucking far', ->
      assert room.messages.length >= 3

    # TODO(sshirokov): Figure out if we have a sane enough version of node
    #                  to actually use promises correctly and to test the
    #                  callbacks that wait on redis
