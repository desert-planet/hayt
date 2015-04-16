assert = require 'assert'

Helper = require('hubot-test-helper')
helper = new Helper('../scripts/dice.coffee')


describe 'AYP', ->
  it 'compiled if it got this fucking far', ->
    assert helper
