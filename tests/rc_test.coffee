assert = require 'assert'
util = require 'util'

Redis = require 'redis'
Url = require 'url'

Helper = require('hubot-test-helper')

helper = new Helper('../scripts/rc.coffee')
expect = require('chai').expect
stub = require('sinon').stub

# Create a new connection to redis, send a "PING" and
# wait for a success reply. If there are no errors,
# call the `next` callback to continue flow.
#
# Used to wait for scripts to finish redis-based callback work
# By forcing the tests to wait for at least one redis request-response
# cycle before executing.
after_redis = (next) ->
  info = Url.parse process.env.REDISTOGO_URL or
    process.env.REDISCLOUD_URL or
    process.env.BOXEN_REDIS_URL or
    'redis://localhost:6379'
  storage = Redis.createClient(info.port, info.hostname)
  storage.auth info.auth.split(":")[1] if info.auth
  storage.ping (err, res) ->
    throw err if err
    do next


describe 'Roll Call', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

  context 'sanity', ->
    beforeEach ->
      room.user.say 'alice', '@hubot rc ping'

    it 'compiled if it got this fucking far', ->
      assert room.messages.length > 0

  context 'a user can set an RC', ->
    beforeEach ->
      room.user.say 'alice', '@hubot rc 5'

    it 'should not crash and say something', -> after_redis ->
      assert(room.messages.length >= 2)
