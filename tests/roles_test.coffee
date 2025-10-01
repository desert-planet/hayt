Helper = require('hubot-test-helper')
expect = require('chai').expect

helper = new Helper('../scripts/roles.coffee')

describe 'roles management', ->
  room = null

  beforeEach ->
    room = helper.createRoom()

    # Manually create users in the brain since the test helper doesn't do it
    # automatically.
    room.robot.brain.userForId('1', name: 'alice')
    room.robot.brain.userForId('2', name: 'bob')
    room.robot.brain.userForId('3', name: 'charlie')

  context 'assigning roles', ->
    it 'should assign a role to a user', ->
      room.user.say 'alice', '@hubot bob is a badass guitarist'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.contain 'a badass guitarist'
      expect(room.messages[1][1]).to.eql 'Ok, bob is a badass guitarist.'

    it 'should assign multiple roles to the same user', ->
      room.user.say 'alice', '@hubot bob is a badass guitarist'
      room.user.say 'alice', '@hubot bob is a coffee enthusiast'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.contain 'a badass guitarist'
      expect(bob.roles).to.contain 'a coffee enthusiast'
      expect(room.messages[1][1]).to.eql 'Ok, bob is a badass guitarist.'
      expect(room.messages[3][1]).to.eql 'Ok, bob is a coffee enthusiast.'

    it 'should acknowledge when a user already has the role', ->
      room.user.say 'alice', '@hubot bob is a badass guitarist'
      room.user.say 'alice', '@hubot bob is a badass guitarist'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.contain 'a badass guitarist'
      expect(bob.roles.length).to.eql 1
      expect(room.messages[1][1]).to.eql 'Ok, bob is a badass guitarist.'
      expect(room.messages[3][1]).to.eql 'I know'

    it 'should not assign roles for reserved words', ->
      room.user.say 'alice', '@hubot who is a person'
      room.user.say 'alice', '@hubot what is happening'
      room.user.say 'alice', '@hubot where is the location'

      # Only "who is" should get a response, "what" and "where" should be ignored.
      expect(room.messages.length).to.eql 4  # 3 user messages + 1 robot response
      expect(room.messages[1][1]).to.eql "a person? Never heard of 'em"

    it 'should handle unknown users', ->
      room.user.say 'alice', '@hubot unknown_user is a mystery'
      expect(room.messages[1][1]).to.eql "I don't know anything about unknown_user."

    it 'should handle empty role assignments gracefully', ->
      room.user.say 'alice', '@hubot bob is '

      bob = room.robot.brain.userForName('bob')
      # Should not assign empty roles.
      expect(bob.roles or []).to.not.contain ''
      # Should not respond to empty role assignments.
      expect(room.messages.length).to.eql 1

  context 'removing roles', ->
    beforeEach ->
      # Give bob some initial roles.
      bob = room.robot.brain.userForName('bob')
      bob.roles = ['a badass guitarist', 'a coffee enthusiast', 'a code reviewer']

    it 'should remove a role from a user', ->
      room.user.say 'alice', '@hubot bob is not a badass guitarist'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.not.contain 'a badass guitarist'
      expect(bob.roles).to.contain 'a coffee enthusiast'
      expect(bob.roles).to.contain 'a code reviewer'
      expect(room.messages[1][1]).to.eql 'Ok, bob is no longer a badass guitarist.'

    it 'should acknowledge when trying to remove a role the user does not have', ->
      room.user.say 'alice', '@hubot bob is not a ninja'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.eql ['a badass guitarist', 'a coffee enthusiast', 'a code reviewer']
      expect(room.messages[1][1]).to.eql 'I know.'

    it 'should prevent users from removing their own roles', ->
      room.user.say 'bob', '@hubot bob is not a badass guitarist'

      bob = room.robot.brain.userForName('bob')
      expect(bob.roles).to.contain 'a badass guitarist'
      expect(room.messages[1][1]).to.eql '@bob Nice try, buddy.'

    it 'should handle unknown users when removing roles', ->
      room.user.say 'alice', '@hubot unknown_user is not a mystery'
      expect(room.messages[1][1]).to.eql "I don't know anything about unknown_user."

  context 'querying roles', ->
    beforeEach ->
      # Set up some users with different role configurations.
      bob = room.robot.brain.userForName('bob')
      bob.roles = ['a badass guitarist', 'a coffee enthusiast']

      charlie = room.robot.brain.userForName('charlie')
      charlie.roles = ['a developer, tester, and debugger', 'a team lead']

    it 'should list all roles for a user', ->
      room.user.say 'alice', '@hubot who is bob'
      expect(room.messages[1][1]).to.eql 'bob is a badass guitarist, a coffee enthusiast.'

    it 'should handle users with no roles', ->
      room.user.say 'alice', '@hubot who is alice'
      expect(room.messages[1][1]).to.eql 'alice is nothing to me.'

    it 'should use semicolons when roles contain commas', ->
      room.user.say 'alice', '@hubot who is charlie'
      expect(room.messages[1][1]).to.eql 'charlie is a developer, tester, and debugger; a team lead.'

    it 'should handle the special case "who is you"', ->
      room.user.say 'alice', '@hubot who is you'
      expect(room.messages[1][1]).to.eql "Who ain't I?"

    it 'should handle asking about the robot by name', ->
      room.user.say 'alice', '@hubot who is hubot'
      expect(room.messages[1][1]).to.eql "The best."

    it 'should handle unknown users', ->
      room.user.say 'alice', '@hubot who is unknown_user'
      expect(room.messages[1][1]).to.eql "unknown_user? Never heard of 'em"

    it 'should handle question marks in queries', ->
      room.user.say 'alice', '@hubot who is bob?'
      expect(room.messages[1][1]).to.eql 'bob is a badass guitarist, a coffee enthusiast.'

  context 'user disambiguation', ->
    beforeEach ->
      # Add charlie_smith for ambiguity testing with charlie.
      room.robot.brain.userForId('4', name: 'charlie_smith')

    it 'should handle ambiguous usernames when assigning roles', ->
      room.user.say 'alice', '@hubot char is a developer'
      expect(room.messages[1][1]).to.contain 'Be more specific, I know 2 people named like that: charlie, charlie_smith'

    it 'should handle ambiguous usernames when removing roles', ->
      room.user.say 'alice', '@hubot char is not a developer'
      expect(room.messages[1][1]).to.contain 'Be more specific, I know 2 people named like that: charlie, charlie_smith'

    it 'should handle ambiguous usernames when querying roles', ->
      room.user.say 'alice', '@hubot who is char'
      expect(room.messages[1][1]).to.contain 'Be more specific, I know 2 people named like that: charlie, charlie_smith'

    it 'should work with exact username matches', ->
      room.user.say 'alice', '@hubot charlie is a specific user'

      charlie = room.robot.brain.userForName('charlie')
      expect(charlie.roles).to.contain 'a specific user'
      expect(room.messages[1][1]).to.eql 'Ok, charlie is a specific user.'
