chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'calculator', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/calculator')(@robot)

  it 'registers a respond listener for calculating', ->
    expect(@robot.respond).to.have.been.calledOnce
