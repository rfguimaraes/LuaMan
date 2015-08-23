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

function player.Player:_init(world, level, tileW, tileH, x, y, speed, img)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.level = level
	self.world:add(self, x, y, tileW, tileH)
	self.ctype = "player"
	self.status = "normal"

	self.marker = {x = nil, y = nil}
	
	self.speed = speed
	self.tileset = img
	self.dir = "UP"
	self.ndir = "UP"

	local tilesetH = self.tileset:getHeight()
	local tilesetW = self.tileset:getWidth()
	local grid = anim8.newGrid(32,32,tilesetW,tilesetH)

	local walkFrames = grid('1-4',1, '3-1', 1)
	self.walkAnim = anim8.newAnimation(walkFrames, 0.05)

	self.ox = tileW/2
	self.oy = tileH/2
end

function player.Player:update(dt)
	self:act()
	self:move(dt)
	self.walkAnim:update(dt)
	self:checkDir(self.dir)
end

function player.Player:checkDir(dir)
	return self.level:freeSpots(self.x + self.ox, self.y + self.oy)[dir]
end

function player.Player:move(dt)
	if self:turn() then
		if point_equal(self.marker, {x = self.x + self.ox, y = self.y + self.oy}, 3) then
			self.dir = self.ndir
			self.x = self.marker.x - self.ox
			self.y = self.marker.y - self.oy
			self.world:update(self, self.x, self.y)
		end
	end
	local dx = player.dirs[self.dir].x * self.speed * dt
	local dy = player.dirs[self.dir].y * self.speed * dt
	local goalX, goalY = self.x + dx, self.y + dy

  	local tx, ty, cols, len = self.world:move(self, goalX, goalY, self.collide)
 	self.x, self.y = tx, ty
  	-- deal with the collisions
  	for i=1,len do
  		if cols[i].other.ctype == "coin" then
    		--print('collided with ' .. tostring(cols[i].other.ctype))
    		cols[i].other:kill()
    	end
  	end
end

function point_equal(p1, p2, th)
	local x2 = (p1.x - p2.x) * (p1.x - p2.x)
	local y2 = (p1.y - p2.y) * (p1.y - p2.y)
	return math.sqrt(x2 + y2) < th
end

function player.Player:turn()
	if self.dir == self.ndir then
		return false
	elseif not self:checkDir(self.ndir) then
	    return false
	end

	local cur = self.level:curTile(self.x + self.ox, self.y + self.oy)

	self.marker.x = ((cur.x - 1) * self.level.tileW) + self.ox
	self.marker.y = ((cur.y - 1) * self.level.tileH) + self.oy
	return true
end

function player.Player:act()
	if love.keyboard.isDown('left','a') then
		self.ndir = "LEFT"
	elseif love.keyboard.isDown('right','d') then
		self.ndir = "RIGHT"
	elseif love.keyboard.isDown('up','w') then
		self.ndir = "UP"
	elseif love.keyboard.isDown('down','s') then
		self.ndir = "DOWN"
	end
end

function player.Player:draw(dt)
	angle = player.rots[self.dir]
	ox = self.tileW/2
	oy = self.tileH/2
	self.walkAnim:draw(self.tileset, self.x + ox, self.y + oy, angle, 1, 1, ox, oy)
end

function player.Player:collide(other)
	if other.ctype == "coin" then
		return "cross"
	elseif other.ctype == "pill" then
		return "cross"
	elseif other.ctype == "#" then
		return "slide"
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

return player