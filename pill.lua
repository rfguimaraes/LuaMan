classer = require "classer"
coin = require "coin"

local pill = {}

pill.Pill = classer.ncls(coin.Coin)

function pill.Pill:_init(world, x, y, tileW, tileH)
	coin.Coin._init(self, world, 6, x, y, tileW, tileH)
	self.ctype = "pill"
end

return pill