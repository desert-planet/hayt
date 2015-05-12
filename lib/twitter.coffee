Twitter = require 'twitter'

client = new Twitter
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.HUBOT_TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET,

# I give you, a pre-configured twitter client,
# So you don't have to.
module.exports = client