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

function enemy.Enemy:move(dt)
	if self:turn() then
		if point_equal(self.marker, {x = self.x + self.ox, y = self.y + self.oy}, 3) then
			self.dir = self.ndir
			self.x = self.marker.x - self.ox
			self.y = self.marker.y - self.oy
			self.world:update(self, self.x, self.y)
		end
	end
	local dx = enemy.dirs[self.dir].x * self.speed * dt
	local dy = enemy.dirs[self.dir].y * self.speed * dt
	local goalX, goalY = self.x + dx, self.y + dy

  	local tx, ty, cols, len = self.world:move(self, goalX, goalY, self.collide)
 	self.x, self.y = tx, ty
  	-- deal with the collisions
  	for i=1,len do
  		-- if cols[i].other.ctype == "coin" then
    -- 		--print('collided with ' .. tostring(cols[i].other.ctype))
    -- 		cols[i].other:kill()
    -- 	end
  	end
end

-- TODO: put this in another place
function point_equal(p1, p2, th)
	local x2 = (p1.x - p2.x) * (p1.x - p2.x)
	local y2 = (p1.y - p2.y) * (p1.y - p2.y)
	return math.sqrt(x2 + y2) < th
end

function enemy.Enemy:turn()
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

function enemy.Enemy:update(dt)
	self:act()
	self:move(dt)
	self.animations[self.status]:update(dt)
end

function enemy.Enemy:draw(dt)
	local curAnim = self.animations[self.status]
	curAnim:draw(self.tileset, self.x, self.y)
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

return enemy