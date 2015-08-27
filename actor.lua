classer = require "classer"
util = require "util"

local actor = {}

actor.Actor = classer.ncls()


-- Initialization

function actor.Actor:_init(world, level, tileW, tileH, x, y, speed, img)
	self.ctype = nil

	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.level = level
	self.world:add(self, x, y, tileW, tileH)
	
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

	self.animations = {}

	self:initAnims()
end

function actor.Actor:initAnims()
	assert(false, "Must be overloaded!\n")
end

-- Updating

function actor.Actor:update(dt)
	self:act()
	self:move(dt)
	self.animations[self.status]:update(dt)
end

function actor.Actor:act()
	assert(false, "Must be overloaded!\n")
end

-- Movement

function actor.Actor:checkDir(dir)
	return self.level:freeSpots(self.x + self.ox, self.y + self.oy)[dir]
end

function actor.Actor:turn()
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

function actor.Actor:move(dt)
	if self:turn() then
		if util.point_equal(self.marker, {x = self.x + self.ox, y = self.y + self.oy}, 3) then
			self.dir = self.ndir
			self.x = self.marker.x - self.ox
			self.y = self.marker.y - self.oy
			self.world:update(self, self.x, self.y)
		end
	end
	local dx = util.dirs[self.dir].x * self.speed * dt
	local dy = util.dirs[self.dir].y * self.speed * dt
	local goalX, goalY = self.x + dx, self.y + dy

  	local tx, ty, cols, len = self.world:move(self, goalX, goalY, self.collide)
 	self.x, self.y = tx, ty
  	-- deal with the collisions
  	self:handleCollisions(cols, len)
end

-- Collisions

function actor.Actor:handleCollisions(cols, len)
	assert(false, "Must be overloaded!\n")
end

function actor.Actor:collide(other)
	assert(false, "Must be overloaded!\n")
end

-- Drawing

function actor.Actor:draw(dt)
	assert(false, "Must be overloaded!\n")
end