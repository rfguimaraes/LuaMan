classer = require "classer"

local coin = {}

coin.Coin = classer.ncls()

function coin.Coin:_init(world, radius, x, y, offset)
	self.width = radius * 2
	self.height = radius * 2
	self.x = x
	self.y = y
	self.ctype = "coin"
	self.world = world
	self.off = offset
	world:add(self, x  + (offset - radius), y + (offset - radius), self.width, self.height)
	self.alive = true
end

function coin.Coin:draw(dt)
	love.graphics.circle("fill", self.x + self.off, self.y + self.off, self.width, 3)
end

function coin.Coin:kill()
	self.world:remove(self)
	self.alive = false
end

return coin