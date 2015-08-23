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

function player.Player:_init(world, tileW, tileH, x, y, speed, imgFile)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.world:add(self, x, y, tileW, tileH)
	self.ctype = "player"
	self.status = "normal"
	
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
	local goalX, goalY = self.x + dx, self.y + dy

  	local tx, ty, cols, len = self.world:move(self, goalX, goalY, self.collide)
 	self.x, self.y = tx, ty
  	-- deal with the collisions
  	for i=1,len do
    	print('collided with ' .. tostring(cols[i].other))
  	end
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
	self.walkAnim:draw(self.tileset, self.x + ox, self.y + oy, angle, 1, 1, ox, oy)
	-- table.foreach(player.rots, print)
	-- print(angle)
end

function player.Player:collide(other)
	if other.ctype == "coin" then
		return "cross"
	elseif other.ctype == "pill" then
		return "cross"
	elseif other.ctype == "#" then
		return "touch"
	elseif other.ctype == "%" then
		return "touch"
	elseif other.ctype == "enemy" then
	    if self.status == "normal" then
	    	return "touch"
	    elseif self.status == "super" then
	    	return "cross"
	    end
	else
		return false
	end
end

function player.Player:getCoin(coin)
	self.score = self.score + 1
end

return player