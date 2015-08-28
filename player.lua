classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"

local player = {}
player.Player = classer.ncls(actor.Actor)

player.rots = 
	{["RIGHT"] = math.rad(0),
	  ["DOWN"] = math.rad(90), 
	  ["LEFT"] = math.rad(180), 
		["UP"] = math.rad(270)}

player.MAX_ENERGY = 100
player.ENERGY_LOSS = 10

-- TODO: model "power" decayment
function player.Player:_init(world, level, tileW, tileH, x, y, speed, img)
	actor.Actor._init(self, world, level, "player", tileW, tileH, x, y, speed, img)
	self:initAnims()
	self.energy = 0
end

function player.Player:initAnims()
	local walkFrames = self.grid('1-4',1, '3-1', 1)
	self.walkAnim = anim8.newAnimation(walkFrames, 0.05)

	self.animations = { normal = self.walkAnim,
						power = self.walkAnim
	}
end

function player.Player:update(dt)
	actor.Actor.update(self, dt)
	self.energy = self.energy - player.ENERGY_LOSS * dt
	if self.energy <=  0 then
		self.energy = 0
		self.status = "normal"
	end
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

function player.Player:handleCollisions(cols, len)
	for i=1,len do
  		if cols[i].other.ctype == "coin" then
    		cols[i].other:kill()
    	elseif cols[i].other.ctype == "pill" then
    		cols[i].other:kill()
    		self.energy = player.MAX_ENERGY
    		self.status = "power"
    	elseif cols[i].other.ctype == "enemy" then
    		self:versusEnemy(cols[i].other)
    	end
  	end
end

function player.Player:versusEnemy(enemy)
	if self.status == "normal" then
		assert(enemy.status ~= "fear", "Invalid state!\n")
		if enemy.status == "normal" then
			self:kill()
		end
	elseif enemy.status ~= "eye" then
		-- TODO: Earn points maybe?
	end
end

function player.Player:collide(other)
	if other.ctype == "coin" then
		return "cross"
	elseif other.ctype == "pill" then
		return "cross"
	elseif other.ctype == "#" then
		return "slide"
	elseif other.ctype == "%" then
		return "slide"
	elseif other.ctype == "enemy" then
	    if self.status == "normal" then
	    	return "cross"
	    elseif self.status == "super" then
	    	return "cross"
	    end
	else
		return false
	end
end

function player.Player:draw(dt)
	angle = player.rots[self.dir]
	ox = self.tileW/2
	oy = self.tileH/2
	self.walkAnim:draw(self.tileset, self.x + ox, self.y + oy, angle, 1, 1, ox, oy)
end

function player.Player:kill()
	self.alive = false
end


return player