# Description:
#   Hubot will encourage self-sabotage.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   weed - declare your daily mood
#
# Author:
#   arbo

module.exports = (robot) ->
  robot.respond /(weed)/i, (msg) ->
    result = msg.random [
      "https://cdn.sklnk.xyz/tR3orbQ6rGJDgog_Wx7cCBSuwuDq1UgnOYc-0Pe5MM0%2Farbo.png",
      "https://i.imgur.com/6ZJtA3i.jpeg",
      "https://i.imgur.com/nUBDLQ8.jpeg",
      
    ]
    msg.send "420 blaze it ... #{result}"
