classer = require "classer"

local coin = {}

coin.Coin = classer.ncls()

function coin.Coin:_init(world, radius, x, y)
	self.width = radius
	self.height = radius
	self.x = x
	self.y = y
	self.ctype = "coin"
	self.world = world
	world:add(self, x  + 11, y + 11, radius, radius)
	self.alive = true
end

function coin.Coin:draw(dt)
	local ox = 16
	local oy = 16
	love.graphics.circle("fill", self.x + ox, self.y + oy, self.width, 10)
end

function coin.Coin:kill()
	print("kill")
	self.world:remove(self)
	self.alive = false
end

return coin