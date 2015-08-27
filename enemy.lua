classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"

local enemy = {}

enemy.Enemy = classer.ncls(actor.Actor)

enemy.dirs = 
	{["RIGHT"] = {x = 1, y = 0},
	  ["DOWN"] = {x = 0, y = 1}, 
	  ["LEFT"] = {x = -1, y = 0}, 
		["UP"] = {x = 0, y = -1}}

function enemy.Enemy:_init(world, level, tileW, tileH, x, y, speed, img, index)
	actor.Actor(world, level, ctype, tileW, tileH, x, y, speed, img)
	self.index = index
end

function enemy.Enemy:initAnims()
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

function enemy.Enemy:act()
	if math.random() < 0.25 then
		self.ndir = self.dir
		return
	end
	local r = math.random()
	if r < 0.25 then
		self.ndir = "UP"
	elseif r < 0.5 then
		self.ndir = "DOWN"
	elseif r < 0.75 then
		self.ndir = "RIGHT"
	else
		self.ndir = "LEFT"
	end
end

function enemy.Enemy:handleCollisions(cols, len)
	-- Do something
end

function enemy.Enemy:collide(other)
	if other.ctype == "#" then
		return "touch"
	elseif other.ctype == "player" then
		return "cross"
	else
		return false
	end
end

function enemy.Enemy:draw(dt)
	local curAnim = self.animations[self.status]
	curAnim:draw(self.tileset, self.x, self.y)
end

return enemy