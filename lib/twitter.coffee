Twitter = require 'twitter'

client = new Twitter
  consumer_key: process.env.HUBOT_TWITTER_CONSUMER_KEY,
  consumer_secret: process.env.HUBOT_TWITTER_CONSUMER_SECRET,
  access_token_key: process.env.HUBOT_TWITTER_ACCESS_TOKEN_KEY,
  access_token_secret: process.env.HUBOT_TWITTER_ACCESS_TOKEN_SECRET,

# I give you, a pre-configured twitter client,
# So you don't have to.
self = module.exports =
  client: client

  # A helper for the general case, posts `body`
  # as a tweet, and calls you back with it, as well
  # as a pre-built URL.
  #
  # body - String to tweet
  # opts - (optional) Any other parameters to add to the outgooing update
  # cb   - Finish callback invoked in the form cb(err, tweet, url)
  #
  # Callback invoked as `cb(err, tweet, url)`
  tweet: (body, opts, cb) =>
    # "Optional" for you "Annoying" for me
    if typeof(opts) is typeof(->)
      cb = opts
      opts = {}

    # If you're the kind of asshole that passes a `body:` key, you'll overwrite
    # the initial string, but you probably like that, sick fuck.
    params = status: body
    (params[key] = opts[key] for own key of opts)

    client.post 'statuses/update', params, (error, tweet, response) ->
      return cb(error) if error

      # LUCKY US
      myself = tweet.user.screen_name
      tid = tweet.id_str
      url = "https://twitter.com/#{myself}/status/#{tid}"
      return cb(undefined, tweet, url)

  # Send a tweet, but with media.
  #
  # mediaData - Data of the media to attach to the tweet.
  # body      - A String body of the tweet
  # opts      - (Optional) any other parameters to pass
  # cb        - Finish callback invoked as `cb(err, tweet, url)`
  mediaTweet: (mediaData, body, opts, cb) =>
    if typeof(opts) is typeof(->)
      cb = opts
      opts = {}

    client.post 'media/upload', {media: mediaData}, (error, media, response) =>
      return cb(error) if error
      self.tweet body, media_ids: media.media_id_string, cb
