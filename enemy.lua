classer = require "classer"

local enemy = {}

enemy.Enemy = classer.ncls()

function enemy.Enemy:_init(world, level, tileW, tileH, x, y, speed, img)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.level = level
	self.world:add(self, x, y, tileW, tileH)
	self.ctype = "enemy"
	-- change this relatively to the player's power
	self.status = "normal"
	self.alive = true

	self.marker = {x = nil, y = nil}

	self.speed = speed
	self.tileset = img
	self.dir = "UP"
	self.ndir = "UP"
end

return enemy