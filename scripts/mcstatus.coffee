# Description:
#   Report the status of a Minecraft server
#   Uses http://api.syfaro.net/
#
# Dependencies:
#   None
#
# Configuration:
#   MINECRAFT_HOST and MINECRAFT_PORT
#
# Commands:
#   mcstatus [host] [port] - Report the status of a minecraft server.
#
# Author:
#   annabunches

default_url = process.env.MINECRAFT_HOST
default_port = process.env.MINECRAFT_PORT

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
  robot.respond /mcstatus( +\S+)?( +\d+)?/i, (res) ->
    host = res.match[1]?.trim() || process.env.MINECRAFT_HOST
    port = res.match[2]?.trim() || process.env.MINECRAFT_PORT
    get_mc_server_status(res, host, port)
