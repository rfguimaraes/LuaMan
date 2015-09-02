classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"

local enemy = {}

enemy.Enemy = classer.ncls(actor.Actor)

enemy.Enemy.blocks = "[#]"

function enemy.Enemy:_init(world, level, tileW, tileH, x, y, speed, img, index)
	actor.Actor._init(self, world, level, "enemy", tileW, tileH, x, y, speed, img)
	self.index = index
	self:initAnims()
end

function enemy.Enemy:initAnims()
	local normalFrames = self.grid('1-2', self.index)
	self.normalAnim = anim8.newAnimation(normalFrames, 0.1)

	local fearFrames = self.grid('3-4', self.index)
	self.fearAnim = anim8.newAnimation(fearFrames, 0.1)

	local eyeFrames = self.grid(5, self.index)
	self.eyeAnim = anim8.newAnimation(eyeFrames, 0.1)

	self.animations = {	normal = self.normalAnim,
						fear = self.fearAnim,
						eye = self.eyeAnim
					}
end

function enemy.Enemy:update(gotPill, cur, dt)
	local toFear = gotPill
	local noFear = (not gotPill and cur == "normal")

	if self.status == "normal" and toFear then
		self.status = "fear"
		io.input()
	elseif self.status == "fear" and noFear then
		self.status = "normal"
	end
	
	actor.Actor.update(self, dt)	
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

function enemy.Enemy:onFear()
	self.status = "fear"
end

function enemy.Enemy:checkDir(dir)
	local c = self.level:lookAround(self.x + self.ox, self.y + self.oy)[dir]
	return c ~= nil and not c:match(enemy.Enemy.blocks)
end

function enemy.Enemy:handleCollisions(cols, len)
	for i=1,len do
		if cols[i].other.ctype == "player" then
    		self:versusPlayer(cols[i].other)
    	elseif cols[i].other.ctype == "spawn" then
    		if self.status == "eye" then
    			self.status = "normal"
    		end
    	end
  	end
end

function enemy.Enemy:versusPlayer(player)
	if self.status == "fear" then
		self:kill()
	end
end

function enemy.Enemy:collide(other)
	if other.ctype == "#" then
		return "touch"
	elseif other.ctype == "spawn" then
		return "cross"
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

function enemy.Enemy:kill()
	if self.status ~= "fear" then
		return
	else
		self.status = "eye"
	end
end

return enemy