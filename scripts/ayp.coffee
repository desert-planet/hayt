# Scaffolds for AYP
# That good, handmade shit.

fs = require 'fs'
path = require 'path'
Url = require 'url'
Redis = require 'redis'
GD = require 'node-gd'
S3 = require 'node-s3'

## Knobs and buttons
AYP_AWS_KEY    = process.env.AYP_AWS_KEY
AYP_AWS_SECRET = process.env.AYP_AWS_SECRET
AYP_AWS_BUCKET = process.env.AYP_AWS_BUCKET

## Paths to find media
ROOT = path.resolve(__dirname, '..')
IMG_BASE = path.resolve(ROOT, 'ayp-template-images')
BG_BASE = path.resolve(IMG_BASE, 'bg')
AVATAR_BASE = path.resolve(IMG_BASE, 'avatars')
FONT = path.resolve(IMG_BASE, "arial.ttf")

## S3 Storage
s3 = S3("s3://#{AYP_AWS_KEY}:#{AYP_AWS_SECRET}@#{AYP_AWS_BUCKET}.s3.amazonaws.com/")

## Robot event bindings
module.exports = (robot) ->
  buffer = new PantsBuffer()

  # We listen to everything.
  # Everything.
  robot.catchAll (msg) ->
    return if !msg.message.text

    buffer.store(
      msg.message.user.name.trim(),
      msg.message.text.trim()
    )

  # Ask for what currently serves as "output"
  robot.respond /ayp(\s+(me)?)?\s*$/i, (msg) ->
    buffer.get 6, (err, lines) ->
      # Build a strip of AYP
      buildComic lines, (err, image) ->
        return msg.reply "SOMETHING TERRIBLE HAPPENED: #{err}" if err

        # Save locally, upload, cleanup
        name = "ayp-#{Date.now()}.png"
        outPath = path.resolve("/tmp", name)
        image.savePng outPath, 0, (err) ->
          return console.error "Failed to write result:", err if err

          fs.readFile outPath, (err, data) ->
            # We can unlink unconditionally now that we have it or failed
            fs.unlink(outPath, ->)
            return msg.reply "I somehow lost the file I just put down at #{outpath}. Like a moron :(" if err
            return msg.reply "You hve no S3 creds bub" unless [AYP_AWS_KEY, AYP_AWS_SECRET, AYP_AWS_BUCKET].every (p) -> p?.length

            info =
              headers:
                'Content-Type': 'image/png'
              body: data
            s3.put name, info, (err) ->
              return msg.reply "Woooops! Failed to upload: #{err}" if err
              msg.reply "I made a thing: http://s3.amazonaws.com/#{AYP_AWS_BUCKET}/#{name}"

      # Echo the lines to the channel
      count = 0
      for log in lines
        do (log) ->
          [who, what] = log
          msg.reply "=#{count += 1}> [#{who}] '#{what}'"

# Build a comic and invoke the cb(err, res) with res
# being the resulting image. `err` will be true if an error
# is encountered.
buildComic = (lines, cb) ->
  buildPanels lines, (err, panels) ->
    return cb(err, null) if err
    loaders =
      png: GD.openPng
      jpg: GD.openJpeg
      jpeg: GD.openJpeg


    fs.readdir BG_BASE, (err, files) ->
      cb(err, null) if err
      files = files.filter (f) -> f[0] != '.'
      selected = files[Math.round(Math.random() * files.length)]
      ext = selected[-3..].toLowerCase()
      loader = loaders[ext]

      # If we pick a BG we can't load, panic
      # TODO: Or try again a few times?
      cb("Can't find loader for #{selected}", null) unless loader

      loader path.resolve(BG_BASE, selected), (err, bg) ->
        return cb(err, bg) if err
        totalPadding = 12
        left = 0
        top = totalPadding / 2
        for panel in panels
          do (panel) ->
            compositeImage bg, panel, (left += (totalPadding / 2)), top
            left += panel.width # Panel width
            left += (totalPadding / 2)
        cb(false, bg)

# Turn a set of 6 `lines` into 3 panels
# using two lines per panel, then invokes `cb`.
#
# callback invoked as `cb(err, [image, image, image])`
# Error will only be set on failure.
buildPanels = (lines, cb) ->
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
  buildPanel lines[0..1], (err, panel) -> finishPanel(err, 0, panel)
  buildPanel lines[2..3], (err, panel) -> finishPanel(err, 1, panel)
  buildPanel lines[4..5], (err, panel) -> finishPanel(err, 2, panel)

# Build a single panel out of (UP TO) two lines of dialog
# cb invoked as `cb(err, image)`. `err` is only set on failure
buildPanel = (lines, cb) ->
  # Setup a transparant frame that we'll composite
  # characters and text into.
  # See: https://github.com/sshirokov/arrakis-hubot/pull/43#issuecomment-63786326
  frame = GD.createTrueColor(348, 348)
  frame.saveAlpha(1)
  clear = frame.colorAllocateAlpha(0, 0, 0, 127)
  frame.fill(0, 0, clear)

  # We can just return the empty transperant
  # frame if we get no lines
  return cb(false, frame) unless lines.length > 0

  # Set up a list of names that we need to load avatars for
  # as a list of [{name: "nick", img: .., err: ..},.. ]
  # As the images load, we'll fill in `.img` and if any fail,
  # we'll bail, and make sure no later calls do anything
  failed = false
  names = (l[0] for l in lines).
    filter((v, i, a) -> a.indexOf(v) == i).    # De-dupe
    map (n) -> {name: n, img: null, err: null} # Prepare requirements

  fail = (err) ->
    cb(err, null)
    return faliled = true

  charPathForNick = (nick) ->
    potential = path.resolve(AVATAR_BASE, "#{nick.toLowerCase()}.png")
    return potential if (try fs.statSync(potential))
    return path.resolve(AVATAR_BASE, "default.png")

  for nameObj in names
    do (nameObj) ->
      GD.openPng charPathForNick(nameObj.name), (err, img) ->
        return if failed
        return fail(err) if err
        nameObj.img = img unless err

        # Are we done?
        namesReady(names) if names.every((o) -> o.img)

  # This will be invoked when all the names finish loading above
  namesReady = (namesList) ->
    # Dictionary of name -> img
    names = {}
    for obj in namesList
      names[obj.name] = obj.img

    if namesList.length == 1
      # The only person speaking is centered in the frame
      char = namesList[0].img
      left = (frame.width / 2) - (char.width / 2)
      top = (frame.height - char.height)
      compositeImage frame, char, left, top
    else
      # We have two speakers
      first = true
      for line in lines
        [who, what] = line
        char = names[who]
        top = (frame.height - char.height)

        if first
          left = 0
          first = false
        else
          left = frame.width - char.width

        compositeImage frame, char, left, top

    # I can render all the text unconditionally
    # since it looks the same regardless of the number
    # of speakers. (i.e. left -> right, top -> bottom)
    top = 0
    left = 0
    first = true
    topPad = 3
    for line in lines
      [who, what] = line
      bubble = textBubble what

      if not first
        left = frame.width - bubble.width

      compositeImage frame, bubble, left, top

      top += bubble.height + topPad
      first = false if first




    # Return the frame to the caller from `namesReady`
    # [Comment highlights indent]
    # TODO: JESUS GOD REFACTOR THIS FLOW
    return cb(false, frame)

textSize = (msg, font, size) ->
  img = GD.create(1,1)
  black = img.colorAllocate(0, 0, 0)
  bb = img.stringFTBBox(black, font, size, 0, 0, 0, msg)
  [
    bb[2] - bb[0],
    bb[1] - bb[7]
  ]

chunkInputInto = (msg, splits) ->
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

formatForTextBubble = (msg, font="./ayp-template-images/arial.ttf", size=12, max=330) ->
  msg = msg.trim()
  [w, h] = textSize(msg, font, size)
  if w > max
    splits = Math.round(w / max)
    splits += 1 if w % max
    msg = chunkInputInto(msg, splits).join "\n"
  else
    msg

textBubble = (msg, font="./ayp-template-images/arial.ttf", size=12, max=330) ->
  msg = formatForTextBubble(arguments...)
  [w, h] = textSize(msg, font, size)

  frame = GD.createTrueColor(w, h)
  frame.saveAlpha(1)
  white = frame.colorAllocate(0xff, 0xff, 0xff)
  black = frame.colorAllocate(0x00, 0x00, 0x00)
  frame.fill(0, 0, white)

  frame.stringFT(black, font, size,
    0,    # Rotation angle
    0,    # x
    size, # y
    msg
  )
  return frame

# Composite `sprite` onto `dst` in full.
# Offsets `sprite` `+left` from the left
# and `+top` from the top
compositeImage = (dst, sprite, left, top) ->
  dim = [sprite.width, sprite.height]
  left = Math.round(left)
  top = Math.round(top)
  sprite.copyResampled dst,
    left, top, # dst x, y
    0, 0,      # src x, y
    dim..., dim... # No size change
  return dst

# Make any changes required to the name
filterName = (name) ->
  name

# Make any changes required to the text
filterText = (text) ->
  # Urls are secret. Not for you. Not for anyone.
  text = text.replace(/(https?:\/\/[^\s]+)/, "[redacted]")

  # Twitter length, then truncate with `...`
  limit = 140
  suffix = '...'
  if text.length > limit
    text = text.slice(0, (limit - suffix.length))
    text += suffix

  text

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
        [_, who, what] = line.match(/^([^\s]+): (.+)$/)
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
       return console.error "WARNING: Failed to store: '#{who}: #{what}' @ #{stmp}: #{err}" if err

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
