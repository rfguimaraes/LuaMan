classer = require "classer"
anim8 = require "lib.anim8"

local enemy = {}

enemy.Enemy = classer.ncls()

enemy.dirs = 
	{["RIGHT"] = {x = 1, y = 0},
	  ["DOWN"] = {x = 0, y = 1}, 
	  ["LEFT"] = {x = -1, y = 0}, 
		["UP"] = {x = 0, y = -1}}

function enemy.Enemy:_init(world, level, tileW, tileH, x, y, speed, img, index)
	self.index = index
	self.ctype = "enemy"
	--- Identical code to player
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.level = level
	self.world:add(self, x, y, tileW, tileH)
	
	-- change this relatively to the player's power
	self.status = "normal"
	self.alive = true

	self.marker = {x = nil, y = nil}

	self.speed = speed
	self.tileset = img
	self.dir = "UP"
	self.ndir = "UP"


	local tilesetH = self.tileset:getHeight()
	local tilesetW = self.tileset:getWidth()
	local grid = anim8.newGrid(32,32,tilesetW,tilesetH)

	self.ox = tileW/2
	self.oy = tileH/2

	--- Identical code to player

	local normalFrames = grid('1-2', index)
	self.normalAnim = anim8.newAnimation(normalFrames, 0.1)

	local fearFrames = grid('3-4', index)
	self.fearAnim = anim8.newAnimation(fearFrames, 0.1)

	local eyeFrames = grid(5, index)
	self.eyeAnim = anim8.newAnimation(eyeFrames, 0.1)

	self.animations = {	normal = self.normalAnim,
						fear = self.fearAnim,
						eye = self.eyeAnim
					}
end

--- Identical code to player
function enemy.Enemy:checkDir(dir)
	return self.level:freeSpots(self.x + self.ox, self.y + self.oy)[dir]
end

function enemy.Enemy:update(dt)
	self.normalAnim:update(dt)
	self.y = self.y + self.speed * dt
end

function enemy.Enemy:draw(dt)
	self.normalAnim:draw(self.tileset, self.x, self.y)
end

return enemy