# Description:
#   hayt will detect $100 and give us the value expressed as kstnd, as all values should be
#
# Dependencies:
#   robot http?  idk, I couldn't make vagrant work
#
# Configuration:
#   None
#
# Commands:
#   we should use .butt more than we do
#
# Author:
#   arbog

module.exports = (robot) ->
  robot.hear /\$(\d+)/i, (msg) ->
    amount = msg.match[1]

    # Make a request to a cryptocurrency API to get the current price
    robot.http("https://api.coinmarketcap.com/v1/ticker/kstnd/").get() (err, res, body) ->
      # Check for errors
      if err
        msg.send "fuck, what does kstnd even cost?? #{err}"
        return

      # Parse the response body
      data = JSON.parse(body)
      price = data[0].price_usd
      kstndAmount = amount / price
      msg.send "you mean #{kstndAmount.toFixed(4)} kstnd"
