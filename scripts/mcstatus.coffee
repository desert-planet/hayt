# Description:
#   Report the status of a Minecraft server
#   Uses http://api.syfaro.net/
#
# Dependencies:
#   None
#
# Configuration:
#   server_url and server_port, below
#
# Commands:
#   mcstatus - Report the status of the configured minecraft server.
#
# Author:
#   annabunches

default_url = 'mc.wtf.cat'
default_port = '10070'

get_mc_server_status = (msg, url, port) ->
  request_url = "http://api.syfaro.net/server/status?ip=#{url}&port=#{port}&players=true"

  msg.http(request_url)
  .header(Accept: 'application/json')
  .get() (err, res, body) ->
    if err?
      msg.send "Error: #{err}"
      return
    try
      data = JSON.parse(body)
    catch error
      msg.send "Error parsing JSON"
      return

    if not data.online
      status = "offline."
    else
      status = "online, with #{data.players.now}/#{data.players.max} players."
      
      if data.players.now > 0
        status += ' (' + [player.name for player in data.players.sample].join(', ') + ')'

    msg.send "Minecraft server #{url}:#{port} is #{status}"


module.exports = (robot) ->
  robot.respond /mcstatus/i, (res) ->
    get_mc_server_status(res, default_url, default_port)
