classer = require "classer"
util = require "util"

local actor = {}

actor.Actor = classer.ncls()

actor.Actor.blocks = "[w#]"

-- Initialization

function actor.Actor:_init(world, level, ctype, tileW, tileH, x, y, speed, img)
	self.ctype = ctype

	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.world = world
	self.level = level
	self.world:add(self, x, y, tileW, tileH)
	
	self.status = "normal" 
	self.alive = true

	self.marker = {x = nil, y = nil}
    self.nextStep = nil
	
	self.speed = speed
	self.tileset = img
	self.dir = "UP"
	self.ndir = "UP"

	local tilesetH = self.tileset:getHeight()
	local tilesetW = self.tileset:getWidth()
	self.grid = anim8.newGrid(self.tileW, self.tileH,tilesetW, tilesetH)

	self.ox = self.tileW/2
	self.oy = self.tileH/2

	self.animations = {}
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

function actor.Actor:getTileCoords()
	return self.level:curTile(self.x + self.ox, self.y + self.oy)
end

function actor.Actor:checkDir(dir)
	local c = self.level:lookAround(self.x + self.ox, self.y + self.oy)[dir]
	return c ~= nil and not c:match(actor.Actor.blocks)
end

function actor.Actor:neighbors(point)
	local neighbors = {}
    local bestn = self.level:getNeighbors(point.x, point.y)[self.dir]
    if bestn then
        c = self.level.tileTable[bestn.x][bestn.y]
        if not c:match(actor.Actor.blocks) then
            table.insert(neighbors, {x = bestn.x, y = bestn.y})
        end
    end
	for key, val in pairs(self.level:getNeighbors(point.x, point.y)) do
        if key ~= self.dir then
            c = self.level.tileTable[val.x][val.y]
            if not c:match(actor.Actor.blocks) then
                table.insert(neighbors, {x = val.x, y = val.y})
            end
        end
	end

	return neighbors
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
    local dx, dy = 0, 0
    if not self.nextStep then
        return
    end
    self.dir = self.nextStep.dir
    print(self.nextStep.dir)
    print("mark: " .. util.phash(self.nextStep.mark))
    local now = {x = self.x + self.ox, y = self.y + self.oy}
    print("now: " .. util.phash(now))
    if util.point_equal(self.nextStep.mark, {x = self.x + self.ox, y = self.y + self.oy}, 3) then
        print("Done")
        self.x = self.nextStep.mark.x - self.ox
        self.y = self.nextStep.mark.y - self.oy
        self.world:update(self, self.x, self.y)
        self.nextStep = nil
    else
        dx = util.dirs[self.dir].x * self.speed * dt
        dy = util.dirs[self.dir].y * self.speed * dt
    end
	local goalX, goalY = self.x + dx, self.y + dy
    print("goal: " .. util.phash({x = goalX + self.ox, y = goalY + self.oy}))

  	local tx, ty, cols, len = self.world:move(self, goalX, goalY, self.collide)
    print("final: " .. util.phash({x = tx + self.ox, y = ty + self.oy}))
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

return actor
