assert = require 'assert'
util = require 'util'

Helper = require('hubot-test-helper')

helper = new Helper('../scripts/rc.coffee')
expect = require('chai').expect
stub = require('sinon').stub
co = require('co')

describe 'Roll Call', ->
  room = null

  beforeEach ->
    room = helper.createRoom(httpd: false)

  afterEach ->
    room.destroy()

  context 'sanity', ->
    beforeEach ->
      co ->
        yield room.user.say 'alice', '@hubot rc ping'
        yield room.user.say 'alice', '@hubot rc 5'
        yield room.user.say 'alice', '@hubot rc for alice'

    it 'compiled if it got this fucking far', ->
      assert room.messages.length >= 3

    # TODO(sshirokov): Figure out if we have a sane enough version of node
    #                  to actually use promises correctly and to test the
    #                  callbacks that wait on redis
