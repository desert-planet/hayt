Twitter = require 'twitter'

client = new Twitter
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.HUBOT_TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET,

# I give you, a pre-configured twitter client,
# So you don't have to.
module.exports =
  client: client

  # A helper for the general case, posts `body`
  # as a tweet, and calls you back with it, as well
  # as a pre-built URL.
  #
  # Callback invoked as `cb(err, tweet, url)`
  tweet: (body, cb=(->)) =>
    params = status: body
    client.post 'statuses/update', params, (error, tweet, response) ->
      return cb(error) if error

      # LUCKY US
      myself = tweet.user.screen_name
      tid = tweet.id_str
      url = "https://twitter.com/#{myself}/status/#{tid}"
      return cb(undefined, tweet, url)
