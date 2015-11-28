classer = require "classer"

local coin = {}

coin.Coin = classer.ncls()

function coin.Coin:_init(world, radius, x, y, tileW, tileH)
	self.radius = radius
	self.width = radius * 2
	self.height = radius * 2
	self.x = x
	self.y = y
	self.ctype = "coin"
	self.world = world
	self.ox = tileW/2
	self.oy = tileH/2
	world:add(self, x  + (self.ox - radius), y + (self.oy - radius), self.width, self.height)
	self.alive = true
end

function coin.Coin:draw(dt)
	love.graphics.circle("fill", self.x + self.ox, self.y + self.oy, self.width, 10)
end

function coin.Coin:kill()
	self.world:remove(self)
	self.alive = false
end

return coin
