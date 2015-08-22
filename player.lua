classer = require "classer"
anim8 = require "anim8"

local player = {}

player.Player = classer.ncls()

player.rots = 
	{["RIGHT"] = math.rad(0),
	  ["DOWN"] = math.rad(90), 
	  ["LEFT"] = math.rad(180), 
		["UP"] = math.rad(270)}

player.dirs = 
	{["RIGHT"] = {x = 1, y = 0},
	  ["DOWN"] = {x = 0, y = 1}, 
	  ["LEFT"] = {x = -1, y = 0}, 
		["UP"] = {x = 0, y = -1}}

function player.Player:_init(tileW, tileH, x, y, speed, imgFile)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.speed = speed
	self.tileset = love.graphics.newImage(imgFile)
	self.dir = "UP"

	local tilesetH = self.tileset:getHeight()
	local tilesetW = self.tileset:getWidth()
	local grid = anim8.newGrid(32,32,tilesetW,tilesetH)

	local walkFrames = grid('1-4',1, '3-1', 1)
	self.walkAnim = anim8.newAnimation(walkFrames, 0.05)
end

function player.Player:update(dt)
	-- table.foreach(self, print)

	self:act()
	self:move(dt)
	self.walkAnim:update(dt)
end

function player.Player:move(dt)
	local dx = player.dirs[self.dir].x * self.speed*dt
	local dy = player.dirs[self.dir].y * self.speed*dt
	self.x = self.x + dx
	self.y = self.y + dy
end

function player.Player:act()
	if love.keyboard.isDown('left','a') then
		self.dir = "LEFT"
	elseif love.keyboard.isDown('right','d') then
		self.dir = "RIGHT"
	elseif love.keyboard.isDown('up','w') then
		self.dir = "UP"
	elseif love.keyboard.isDown('down','s') then
		self.dir = "DOWN"
	end
end

function player.Player:draw(dt)
	angle = player.rots[self.dir]
	ox = self.tileW/2
	oy = self.tileH/2
	self.walkAnim:draw(self.tileset, self.x, self.y, angle, 1, 1, ox, oy)
	-- table.foreach(player.rots, print)
	-- print(angle)
end

return player