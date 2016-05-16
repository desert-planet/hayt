webpage = require 'webpage'
page = webpage.create()
system = require 'system'
url = system.args[1]

page.onError = ->
  'i dont give a shit'
page.open url, ->
  title = page.evaluate ->
    return document.title
  system.stdout.writeLine title
  phantom.exit()
