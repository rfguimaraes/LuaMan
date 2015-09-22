classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"
fsm = require "fsm"

local player = {}

player.Player = classer.ncls(actor.Actor)

player.rots = 
	{["RIGHT"] = math.rad(0),
	  ["DOWN"] = math.rad(90), 
	  ["LEFT"] = math.rad(180), 
		["UP"] = math.rad(270)}

player.MAX_ENERGY = 100
player.ENERGY_LOSS = 10
player.fsm_table =
{
	{"eat", "ok", "eat", nil},
	{"eat", "danger", "pill_near", nil},
	{"eat", "only_pill", "get_pill", nil},
	{"pill_near", "yes", "get_pill", nil},
	{"pill_near", "no", "run", nil},
	{"get_pill", "sucess", "hunt", nil},
	{"get_pill", "fail", "run", nil},
	{"run", "ok", "eat", nil},
	{"run", "danger", "pill_near", nil},
	{"hunt", "power_off", "eat", nil},
}

function player.Player:_init(world, level, tileW, tileH, x, y, speed, img)
	actor.Actor._init(self, world, level, "player", tileW, tileH, x, y, speed, img)
	self:initAnims()
	self.energy = 0
	self.gotPill = false
	self.countdown = 0
	self.score = 0
	self.fsm = fsm.FSM("eat", player.fsm_table)
end

function player.Player:initAnims()
	local walkFrames = self.grid('1-4',1, '3-1', 1)
	self.walkAnim = anim8.newAnimation(walkFrames, 0.05)

	local dieFrames = self.grid('5-10',1)
	self.dieAnim = anim8.newAnimation(dieFrames, 0.08, 'pauseAtEnd')

	self.animations = { normal = self.walkAnim,
						power = self.walkAnim,
						die = self.dieAnim
	}
end

function player.Player:update(dt)
	actor.Actor.update(self, dt)
	
	if self.status == "die" then
		self.countdown = self.countdown + dt
		if self.countdown >= 0.08 * 5 then
			self.alive = false
		end
		return
	end
	self.energy = self.energy - player.ENERGY_LOSS * dt
	if self.energy <= 0 then
		self.energy = 0
		self.status = "normal"
	end
end

function player.Player:act()
	-- if love.keyboard.isDown('left','a') then
	-- 	self.ndir = "LEFT"
	-- elseif love.keyboard.isDown('right','d') then
	-- 	self.ndir = "RIGHT"
	-- elseif love.keyboard.isDown('up','w') then
	-- 	self.ndir = "UP"
	-- elseif love.keyboard.isDown('down','s') then
	-- 	self.ndir = "DOWN"
	-- end


end

function player.Player:act_eat()
end

function player.Player:act_getPill()
end

function player.Player:act_hunt()
end

function player.Player:act_run()
end

function player.Player:handleCollisions(cols, len)
	for i=1,len do
  		if cols[i].other.ctype == "coin" then
    		cols[i].other:kill()
    		self.score = self.score + 10
    	elseif cols[i].other.ctype == "pill" then
    		cols[i].other:kill()
    		self.energy = player.MAX_ENERGY
    		self.status = "power"
    		self.gotPill = true
    		self.score = self.score + 50
    	elseif cols[i].other.ctype == "enemy" then
    		self:versusEnemy(cols[i].other)
    	end
  	end
end

function player.Player:versusEnemy(enemy)
	if enemy.status == "normal" then
		self:kill()
		return
	elseif self.status == "normal" then
		assert(enemy.status ~= "fear", "Invalid state!\n")
	elseif enemy.status ~= "eye" then
		self.score = self.score + 100
	end
end

function player.Player:collide(other)
	if other.ctype == "coin" then
		return "cross"
	elseif other.ctype == "pill" then
		return "cross"
	elseif other.ctype == "#" then
		return "slide"
	elseif other.ctype == "w" then
		return "slide"
	elseif other.ctype == "enemy" then
	    if self.status == "normal" then
	    	return "cross"
	    elseif self.status == "power" then
	    	return "cross"
	    end
	elseif other.ctype == "spawn" then
		return "touch"
	else
		return false
	end
end

function player.Player:draw(dt)
	angle = player.rots[self.dir]
	ox = self.tileW/2
	oy = self.tileH/2
	self.animations[self.status]:draw(self.tileset, self.x + ox, self.y + oy, angle, 1, 1, ox, oy)
end

function player.Player:kill()
	self.status = "die"
	self.countdown = 0
end

return player