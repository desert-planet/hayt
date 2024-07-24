# Scaffolds for AYP
# That good, handmade shit.

fs = require 'fs'
path = require 'path'
Url = require 'url'
Redis = require 'redis'
GD = require 'node-gd'
S3 = require 'node-s3'
HTTP = require 'scoped-http-client'
Twitter = require '../lib/twitter'

## Knobs and buttons

# S3 Keys
AYP_AWS_KEY    = process.env.AYP_AWS_KEY
AYP_AWS_SECRET = process.env.AYP_AWS_SECRET
AYP_AWS_BUCKET = process.env.AYP_AWS_BUCKET

# AYP The website hooks
AYP_SITE = process.env.AYP_SITE or "http://ayp.wtf.cat/"
AYP_ENDPOINT = "#{AYP_SITE}new/"
AYP_SECRET = process.env.AYP_SECRET

# The size of single panel
AYP_PANEL_WIDTH   = 348
AYP_PANEL_HEIGHT  = 348

# The ammount of padding on each side of a panel
AYP_PANEL_PADDING = 6

# Space left between stacked speech bubbles
# and the sides of the panel and the speech bubbles
AYP_BUBBLE_PADDING_VERTICAL   = 3
AYP_BUBBLE_PADDING_HORIZONTAL = 3

# Maximum width of the speech bubble, after text becomes wider
# it is wrapped to a new line
AYP_BUBBLE_MAX_WIDTH          = AYP_PANEL_WIDTH - 18

# Padding on each side of the text bubble
AYP_TEXT_PADDING              = 2

# The size anf font of the text to use in the text bubbles
AYP_FONT_SIZE                 = 12
AYP_FONT_FILE                 = "DroidSans.ttf"


## Paths to find media
ROOT = path.resolve(__dirname, '..')
IMG_BASE = path.resolve(ROOT, 'ayp-template-images')
BG_BASE = path.resolve(IMG_BASE, 'bg')
AVATAR_BASE = path.resolve(IMG_BASE, 'avatars')
FONT_PATH = path.resolve(IMG_BASE, AYP_FONT_FILE)

## S3 Storage
s3 = S3("s3://#{AYP_AWS_KEY}:#{AYP_AWS_SECRET}@#{AYP_AWS_BUCKET}.s3.amazonaws.com/")

## Are we in debug mode?
DEBUG = (process.env.DEBUG || "").toLowerCase() in ["true", "1", "on"]

## Content filters. These can be used to change the text from the logging
## engine to be whatever is better for AGGGHHHHHHT reasons. Such as removing URLs
## or mapping a pattern of names into a single, consistent one.

# Make any changes required to the name
filterName = (name) ->
  if /dusy[ae]/i.test(name) or /tired/i.test(name) or /k2y/i.test(name)
    # She likes to change her name A LOT. We can assume if it
    # looks like her, it's her.
    #
    # Also, one day she decided that she has a new name for how
    # she is feeling so that's cool I guess
    # In addition, i18n reasons
    name = 'dusya'

  if /minus/i.test(name)
    # Another one fond of aliases
    name = 'minusx'

  if /jense/i.test(name) or /prawn/i.test(name) or /sinjen/.test(name) or /sen/.test(name)
    # Has bouncer, bounces anyway, and also no one likes her.
    # New laptop, new nick.
    name = 'prawn'

  if /geckomuerto/i.test(name)
    # ;_;
    name = 'geckomuerto'

  if /cheerycherries/i.test(name)
    # ¯\_(ツ)_/¯
    name = 'cheerycherries'

  if /cody/i.test(name)
    # I don't even understand this one
    name = 'cody_'

  if /laura/i.test(name) or /kickstand/i.test(name)
    # Some kind of laura is one kind of laura. Now a deprercated bike component
    name = 'laura'

  if /arbo/i.test(name)
    # Bouncers are hard or something, whatever.
    name = 'arbo'

  if name == 'sflios' || name == 'PITlios' || name == 'missourios77' || name == 'sofalios' || name == 'solios'
    # He visited this one time. And then moved that other time. And then did a
    # joke. And then no one knows anymore. And lastly, a totally reasonable change.
    #
    # http://pixxx.wtf.cat/image/0Q3B34330v0c/12188116_10205398142892807_4244989619067012464_o.jpg
    name = 'solient'

  # decides to shed letters randomly!
  if /justin/i.test(name)
    name = 'justinw2'

  if /blah64/i.test(name)
    name = 'blah64'

  # All hosts are dongs
  if /(dev|dong|dodge)host/i.test(name)
    name = 'dong'

  if /meowth/i.test(name)
    name = 'o_rly'

  if /twerk/i.test(name) or /^high_tw/i.test(name)
    name = 'high_twerk'

  if name == 'esch' or name == 'egbe' or /egg/i.test(name)
    # No one knows why, but he's an asshole for it
    name = 'esch'

  # The bouncer muerto'd and now the lizard bounces
  if /geckomuerto/i.test(name)
    name = 'geckomuerto'

  # Hold my beer, I'm about to computer a computer
  if /drewzar/i.test(name)
    name = 'drewzar'

  # Lets just get the whole channel in this function
  if /shyguy/i.test(name)
    name = 'shyguy'
    
  # I'm not kidding. Whole. fucking. channel.
  if /shadypkg/i.test(name)
    name = 'shadypkg'
  
  # I don't even know how to joke about this anymore
  if /nomikos/i.test(name)
    name = 'nomikos'
    
  # I was feeling left out
  if /skalnik/i.test(name)
    name = 'skalnik'
    
  # Shows up, picks a new name, then goes back to the old one. A tale as old as this file.
  if /phil/i.test(name)
    name = 'philza'
    
  # The only person that maybe has a good reason of being in here
  if /Aqua/i.test(name) || /\[Ri?i?\]/i.test(name) || /Namine/i.test(name)
    name = 'Aqua'
    
  # Honestly, I have no idea what to say this time around
  if /ramatevish/i.test(name)
    name = 'ramatevish'

  # Nickles hates IRC, but loves us and gets to be added
  if /nickels/i.test(name)
    name = 'nickels'

  # Feels left out from having bouncer problems I guess
  if /Nicole/i.test(name) || /fullyDeterministicMedicine/i.test(name)
    name = 'randompoison'

  # You make *one* joke about how many s<tab> names there are and this happens.
  if /zSunsetDan/i.test(name)
    name = 'sunsetdan'

  # Shows up, disappears, reappears and here we are
  if /^titties/i.test(name)
    name = 'big_daddy'

  return name

# Make any changes required to the text
filterText = (text) ->
  # Urls are secret. Not for you. Not for anyone.
  text = text.replace(/(https?:\/\/[^\s]+)/g, "[redacted]")

  # Emails 'R' Secret
  text = text.replace(/([^@\s]+@)[^@\s]+\.[^@\s]+/g, "$1[redacted]")

  # Let users redact shit too
  text = text.replace(/\[[^\]]*\]/g, "[redacted]")

  # Twitter length, then truncate with `...`
  limit = 140
  suffix = '...'
  if text.length > limit
    text = text.slice(0, (limit - suffix.length))
    text += suffix

  return text

util = require 'util'
## Robot event bindings
module.exports = (robot) ->
  buffer = new PantsBuffer()

  # Store everything that the robot says in the PantsBuffer
  # Note:
  #   This is not a standard feature, and requires an adapter
  #   that emits a `say` event when the robot speaks
  robot.adapter.on 'say', (envelope, str) ->
    str = str or ""
    buffer.store robot.name.trim(), str.trim()

  # We listen to everything.
  # Almost...everything...
  # Don't listen to robot commands via the alias (.)
  robot.hear /^[^\.].*/i, (msg) ->
    return if !msg.message.text

    buffer.store(
      msg.message.user.name.trim(),
      msg.message.text.trim()
    )

  # Ask for what currently serves as "output"
  robot.respond /(?:nmp|ayp)(\s+(me)?)?\s*$/i, (msg) ->
    buffer.get 6, (err, lines) ->
      # Build a strip of AYP
      new AYPStrip lines, (err, image, strip) ->
        return msg.reply "SOMETHING TERRIBLE HAPPENED: #{err}" if err

        # Save locally, upload, cleanup
        strip.post (err, url) ->
          return msg.reply "What the hell is a JAY PEG?! #{err}" if err

          # Tell our good friends that we made them something
          prefix = msg.random [
            "OH DEAR GOD!",
            "So I sneezed and this came out",
            "I found this on the internet",
            "GOOD NEWS EVERYONE:",
            "This is awkward...",
            "Turns out,",
            "Despite my best efforts",
            "Bleep, Bloop, Bop:",
            "I have done the thing,",
          ]
          msg.reply "#{prefix} #{url} is now -> #{strip.info.image_url}"

          # Tweet a link to the comic, with some sort of text to go with it.
          prefix = msg.random [
            "Welp",
            "Here you go",
            "You made this? I made this.",
            "The one that doesn't make sense",
            "In which nothing happens",
            "Laughter, sorrow, nonsense",
            "#arrakis",
            "#dickbutt",
            "butts",
            "Have a comic",
            "#pants",
          ]
          Twitter.mediaTweet strip.info.image_jpeg, "#{prefix} - #{strip.info.url}", (err, tweet, url) =>
            sorry = msg.random ["sorry", "it's your fault"]
            # We will fix this when we fix twitter
            # return msg.reply "Well, I fucked tweeting that RIGHT up, #{sorry}: #{err}" if err
            return if err
            prefix = msg.random [
              "SHARE FAVE RT",
              "Connect with #brands",
              "Promoted by #a",
              "I put it on twitter, shitbirds",
            ]
            msg.send "#{prefix} #{url}"



# This wraps up everything that builds the image strips of the comic
#
# Usage:
# `new AYPStrip script, (err, image) -> ...`
# Will invoke the callback with the completed
# strip when it's ready.
class AYPStrip
  # Constructor just stores the script and callback
  # and passes flow to the builder.
  constructor: (@script, @ready) ->
    # TODO(sshirokov): Update `@script` to use `@info.script` errywhere
    @info =
      when: Date.now()  # The creation stamp in ms since epoch
      script: @script   # The script for this comic
      image: null       # The GD object
      image_jpeg: null  # The data as JPEG
      image_url: null   # The URL in S3
      url: null         # The URL on the site

    do @buildComic

  # Build a comic and invoke the @ready(err, res, this) callback with res
  # being the resulting image. `err` will be true if an error
  # is encountered.
  buildComic: =>
    @buildPanels (err, panels) =>
      return @ready(err, null, this) if err
      loaders =
        png: GD.openPng
        jpg: GD.openJpeg
        jpeg: GD.openJpeg


      fs.readdir BG_BASE, (err, files) =>
        return @ready(err, null, this) if err

        # No hidden files
        files = files.filter (f) -> f[0] != '.'
        # No files we can't load
        files = files.filter (f) -> loaders[f[-3..]]

        selected = files[Math.round(Math.random() * (files.length - 1))]
        ext = selected[-3..].toLowerCase()
        loader = loaders[ext]

        loader path.resolve(BG_BASE, selected), (err, bg) =>
          return @ready(err, bg, this) if err
          totalPadding = (AYP_PANEL_PADDING * 2)
          left = 0
          top = Math.round(totalPadding / 2)
          for panel in panels
            do (panel) =>
              @compositeImage bg, panel, Math.round(left += (totalPadding / 2)), top
              left += panel.width # Panel width
              left += Math.round(totalPadding / 2)
          @ready(false, (@info.image = bg), this)

  # Turn the `@script` into 3 panels
  # using two lines per panel, then invokes `cb`.
  #
  # callback invoked as `cb(err, [image, image, image])`
  # Error will only be set on failure.
  buildPanels: (cb) =>
    failed = false
    panels = [null, null, null]

    # Handler for when a panel fails to build.
    fail = (err) ->
      cb(err, [])
      return failed = true

    # Handler for panel completion, store in the list, see if we're done,
    # invoke callback if we are.
    finishPanel = (err, n, panel) ->
      # No one cares if we already lost.
      return if failed
      return fail(err) if err

      panels[n] = panel
      cb(false, panels) if panels.every (p) -> p

    # TODO: There's a loop here, somewhere
    @buildPanel @script[0..1], (err, panel) -> finishPanel(err, 0, panel)
    @buildPanel @script[2..3], (err, panel) -> finishPanel(err, 1, panel)
    @buildPanel @script[4..5], (err, panel) -> finishPanel(err, 2, panel)

  # Build a single panel out of (UP TO) two lines of dialog
  # cb invoked as `cb(err, image)`. `err` is only set on failure
  buildPanel: (lines, cb) =>
    # Setup a transparant frame that we'll composite characters and text into.
    frame = GD.createTrueColor(AYP_PANEL_WIDTH, AYP_PANEL_HEIGHT)
    frame.saveAlpha(1)
    clear = frame.colorAllocateAlpha(0, 0, 0, 127)
    frame.fill(0, 0, clear)

    # We can just return the empty transperant
    # frame if we get no lines
    return cb(false, frame) unless lines.length > 0

    names = (l[0] for l in lines).
      filter((v, i, a) -> a.indexOf(v) == i) # De-dupe

    @loadAvatars names, (err, avatars) =>
      return cb(err, null) if err

      if names.length == 1
        # The only person speaking is centered in the frame
        char = avatars[names[0]].img
        left = (frame.width / 2) - (char.width / 2)
        top = (frame.height - char.height)
        @compositeImage frame, char, left, top
      else
        # We have two speakers
        first = true
        for line in lines
          [who, what] = line
          char = avatars[who].img
          top = (frame.height - char.height)

          if first
            left = 0
            first = false
          else
            left = frame.width - char.width

          @compositeImage frame, char, left, top

      # Helper for transforms below
      # Randomly sort the words that were said
      scramble = (what) ->
        scrambleSort = -> 0.5 - Math.random()
        what.split(' ').sort(scrambleSort).join(' ')

      # Add the text after all the avatars are painted on, optionally
      # transforming the spoken text for presentation
      @drawPanelText frame, (
        for line in lines
          do (line) ->
            [who, what] = line
            # Scramble the words if this is the default avatar
            what = scramble(what) if avatars[who].default
            [who, what]
      )

      # Return the frame to the caller
      return cb(false, frame)

  # Draw the text into a `frame` described by
  # the `@script`
  # No character drawing is done, just bubbles being placed.
  # The avatars should already be painted, in case the text
  # needs to overlap them.
  drawPanelText: (frame, lines) =>
    # I can render all the text unconditionally
    # since it looks the same regardless of the number
    # of speakers. (i.e. left -> right, top -> bottom)
    first = true
    top = 0
    left = AYP_BUBBLE_PADDING_HORIZONTAL
    topPad = AYP_BUBBLE_PADDING_VERTICAL
    for line in lines
      [who, what] = line
      bubble = @textBubble what

      if not first
        left = frame.width - bubble.width - AYP_BUBBLE_PADDING_HORIZONTAL
      else
        first = false

      @compositeImage frame, bubble, left, top
      top += bubble.height + topPad

  # Produce a text bubble that contains `msg` printed in the
  # font `font` in the size `size`. The bubble will be at most
  # `max` pixels wide, and will be padded according to `AYP_TEXT_PADDING`
  #
  # The return value will be a GD image.
  textBubble: (msg, font=FONT_PATH, size=AYP_FONT_SIZE, max=AYP_BUBBLE_MAX_WIDTH) =>
    msg = @formatForTextBubble(msg, font, size, max)
    [w, h] = @textSize(msg, font, size)

    frame = GD.createTrueColor(
      w + (AYP_TEXT_PADDING * 2),
      h + (AYP_TEXT_PADDING * 2)
    )
    frame.saveAlpha(1)
    white = frame.colorAllocate(0xff, 0xff, 0xff)
    black = frame.colorAllocate(0x00, 0x00, 0x00)
    frame.fill(0, 0, white)

    frame.stringFT(black, font, size,
      0,                           # Rotation angle
      AYP_TEXT_PADDING,            # x
      AYP_TEXT_PADDING + size + 1, # y
      msg
    )
    return frame

  ##
  ## Helpers and utilities

  # Load avatars for `names` and invoke `cb` as:
  # `cb(err, {"Nickname": {"img": avatarImg, "default": false}, ...})`
  # mapping each name to an avatar image that
  # can be used to represent it.
  #
  # `err` is only set on failure
  loadAvatars: (names, cb) =>
    # Prepare requirements
    names = names.map (n) -> {name: n, img: null, err: null}
    failed = false

    fail = (err) ->
      cb(err, null)
      return faliled = true

    charPathForNick = (nick) ->
      potential = path.resolve(AVATAR_BASE, "#{nick.toLowerCase()}.png")
      return potential if (try fs.statSync(potential))
      return path.resolve(AVATAR_BASE, "default.png")

    for nameObj in names
      do (nameObj) ->
        imgPath = charPathForNick(nameObj.name)
        GD.openPng imgPath, (err, img) ->
          return if failed
          return fail(err) if err

          # Store the actual image data in `.img` and
          # the path to that data in `.imgPath`
          nameObj.img = img
          nameObj.imgPath = imgPath

          # Are we done? Then build up a dictionary
          # and tell the caller.
          if names.every((o) -> o.img)
            avatars = {}
            for obj in names
              avatars[obj.name] =
                img: obj.img
                default: !!obj.imgPath.match(/default\.png$/)
            cb(null, avatars)

  # Returns the bounding box of `msg`
  # When printed using `font` of `size`
  # in the form [width, height]
  textSize: (msg, font, size) ->
    img = GD.create(1,1)
    black = img.colorAllocate(0, 0, 0)
    bb = img.stringFTBBox(black, font, size, 0, 0, 0, msg)
    [
      bb[2] - bb[0],
      bb[1] - bb[7]
    ]

  # Splits the input `msg` into a list of
  # `splits` chunks performing word wrapping on
  # each chunk as in ["Hello", "World"]
  chunkInputInto: (msg, splits) ->
    stepSize = Math.round(msg.length / splits)
    chunks = []

    for n in [0...splits]
      chunks[n] = msg[...stepSize]
      msg = msg[stepSize..]

      # Shift words down until the last space in this line and
      # give them back to the buffer
      while not /\s$/.test(chunks[n])
        chunkLen = chunks[n].length
        msg = "#{chunks[n][chunkLen - 1]}#{msg}"
        chunks[n] = chunks[n][...-1]

    # If we somehow have some message left over, shove it
    # into the last chunk.
    if msg.length
      chunks[chunks.length - 1] += msg

    return chunks.map (c) -> c.trim()

  # Prpares a string `msg` for prtinting with `font`
  # at size `size` that will fit into `max`. The string
  # will be broken into multiple lines so that it does not
  # exceed `max` pixels
  formatForTextBubble: (msg, font, size, max) =>
    msg = msg.trim()
    [w, h] = @textSize(msg, font, size)
    if w > max
      splits = Math.round(w / max)
      splits += 1 if w % max
      msg = @chunkInputInto(msg, splits).join "\n"
    else
      msg

  # Composite `sprite` onto `dst` in full.
  # Offsets `sprite` `+left` from the left
  # and `+top` from the top
  compositeImage: (dst, sprite, left, top) ->
    dim = [sprite.width, sprite.height]
    left = Math.round(left)
    top = Math.round(top)
    sprite.copyResampled dst,
      left, top, # dst x, y
      0, 0,      # src x, y
      dim..., dim... # No size change
    return dst

  postToDisk: (cb) =>
    return cb(new Error("Nice try HACKERMAN. This does nothing unless you `$DEBUG`")) unless DEBUG
    out_path = path.resolve(ROOT, "ayp-DEBUG-#{@info.when}.jpg")

    @buildJPEG (jpg_err) =>
      return cb(jpg_err) if jpg_err
      fs.writeFile out_path, @info.image_jpeg, (err) =>
        return cb(err) if err
        return cb(false, out_path)

  # Post a strip to the AYP site
  # Invokes the callback as `cb(err, url)`
  post: (cb=(->)) =>
    return @postToDisk(cb) if DEBUG
    return cb(new Error("No AYP_SECRET")) unless AYP_SECRET
    perform = =>
      HTTP.create(AYP_ENDPOINT).
        header('Content-Type', 'application/json').
        post(JSON.stringify(url: @info.image_url, time: @info.when, secret: AYP_SECRET)) (err, res, body) =>
          return cb(err) if err
          return cb(new Error("Bad response: #{res?.statusCode}")) unless res?.statusCode in [200...400]

          @info.url = "#{AYP_SITE}at/#{@info.when}/"
          cb(false, @info.url)

    return perform() if @info.image_url
    @upload (err) ->
      return cb(err) if err
      do perform

  # Upload a strip S3 and updates @info.image_url
  #
  # cb invoked as `cb(error, url)`
  upload: (cb=(->)) =>
    return cb(new Error("You hve no S3 creds bub")) unless [AYP_AWS_KEY, AYP_AWS_SECRET, AYP_AWS_BUCKET].every (p) -> p?.length

    perform = =>
      name = "ayp-#{@info.when}.jpg"
      info =
        headers: {'Content-Type': 'image/jpeg'}
        body: @info.image_jpeg
      s3.put name, info, (err) =>
        return cb(new Error("Woooops! Failed to upload: #{err}")) if err
        return cb(false, @info.image_url = "http://s3.amazonaws.com/#{AYP_AWS_BUCKET}/#{name}")

    # Either upload existing JPEG data, or compile some and upload that
    return perform() if @info.image_jpeg
    @buildJPEG (err) ->
      return cb(err) if err
      do perform

  # Build a JPEG version of the image and invoke the callback
  # with the data. The resulting data is also stored in
  # @info.image_jpeg
  #
  # Requires `@info.image` to exist
  #
  # cb invoked as `cb(error, data)`
  buildJPEG: (cb=(->)) =>
    return cb(new Error("@info.image does not exist")) unless @info.image

    # Save locally, cleanup
    name = "ayp-#{@info.when}.jpg"
    outPath = path.resolve("/tmp", name)
    @info.image.saveJpeg outPath, 95, (err) =>
      return cb(new Error("Failed to write result: #{err}")) if err
      fs.readFile outPath, (err, data) =>
        return cb(new Error("Failed to read file I just wrote to #{outPath}: #{err}")) if err
        # We can unlink unconditionally now that we have it or failed
        fs.unlink(outPath, ->)
        cb(false, (@info.image_jpeg = data))


# PantsBuffer is the abstraction of "The Logs".
#
# It keeps a ringbuffer of logs configured on construction
# and fed by `.store(who, what)` which computes timestamps
# and allows you to get n random lines with `.get`.
#
# Fetches are asyncronous, because NODE JS NINJA REDIS
class PantsBuffer
  # The zset that stores the buffer of logs
  key: -> "#{@options.prefix}:buffer"

  # Get an array of `n` lines from the log.
  # When data arrives the callback will be called
  # as cb(err, data). `err` will be only be set on
  # error. `res` will be an array of lines.
  get: (n, callback) ->
    # This wraps the supplied `callback` to process the resulting
    # list into a list of [[who, what], ...] to save the consumer
    # a step.
    # In case of error, the result is untouched
    resultWrapper = (err, res) ->
      return callback(err, res) if err

      res = res.map (line) ->
        [_, who, what] = line.toString('utf8').match(/^([^\s]+): (.+)$/)
        [filterName(who), filterText(what)]
      callback(err, res)

    @storage.zcard @key(), (err, count) =>
      return console.error("Failed zcard of #{@key()}: #{err}") if err

      # If we don't have enough lines, return all the lines we have
      return @storage.zrange @key(), 0, -1, resultWrapper if count <= n

      # Get a random offset where we can grab n lines otherwise
      start = Math.round(Math.random() * (count - n))
      return @storage.zrange @key(), start, (start + (n - 1)), resultWrapper


  # Store and timestamp `who` saying `what`.
  # Also trims the set with `@trim` to the configured
  # length
  store: (who, what) ->
    do @trim
    stamp = Date.now()
    body = "#{who}: #{what}"
    @storage.zadd [@key(), stamp, body], (err, response) =>
       return console.error "WARNING: Failed to store: '#{who}: #{what}' @ #{stamp}: #{err}" if err

  # Trim the logging buffer to `@options.days` since we don't care about
  # being a general purpose logger.
  trim: ->
    days = @options.days
    end = Date.now() - (
      days *  # Days
      24   *  # Hours
      60   *  # Minutes
      60   *  # Seconds
      1000    # ms
    )
    @storage.zremrangebyscore @key(), 0, end, (err, response) =>
      return console.error "WARNING: Failed to trim '#{@key()}': #{err}" if err

  # Constructor for `PantsBuffer`
  #
  # Options:
  #   prefix: The redis prefix to use for the ringbuffer.
  #   days:   The number of days to keep logs in the buffer
  constructor: (@options={}) ->
    # Connect to redis
    info = Url.parse process.env.REDISTOGO_URL or
      process.env.REDISCLOUD_URL or
      process.env.BOXEN_REDIS_URL or
      'redis://localhost:6379'
    @storage = Redis.createClient(info.port, info.hostname)
    @storage.auth info.auth.split(":")[1] if info.auth

    # Defaults for options
    @options.prefix ?= "ayp:"
    @options.days   ?= 3
