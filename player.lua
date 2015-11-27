classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"
fsm = require "fsm"
util = require "util"

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
	{"eat", "power_on", "hunt", nil},
	{"eat", "danger", "run", nil},
	{"run", "safe", "eat", nil},
	{"run", "power_on", "hunt", nil},
	{"hunt", "power_off_safe", "eat", nil},
	{"hunt", "power_off_danger", "eat", nil}
}

player.costTable =
{
	eat = {["."] = 0, ["u"] = 5, ["?"] = 2, ["ghost"] = 100},
	run = {["."] = 2, ["u"] = 0, ["?"] = 2, ["ghost"] = 15000},
	hunt = {["."] = 1, ["u"] = 7, ["?"] = 1, ["ghost"] = 100}
}

function player.Player:_init(name, universe, level, tileW, tileH, x, y, speed, img)
	actor.Actor._init(self, name, universe, level, "player", tileW, tileH, x, y, speed, img)
	self:initAnims()
	self.energy = 0
	self.gotPill = false
	self.countdown = 0
	self.score = 0
    self.dir = "RIGHT"
    self.ndir = "RIGHT"
    self.lastResult = true
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
	if self.status == "die" then
		self.countdown = self.countdown + dt
		if self.countdown >= 0.08 * 5 then
			self.alive = false
            return
		end
	end

    if self.status == "power" then
        self.energy = self.energy - player.ENERGY_LOSS * dt
    end
	if self.energy <= 0 and self.status == "power" then
		self.energy = 0
		self.status = "normal"
	end

    self:act()

    if not self.nextStep then
        self.nextStep = table.remove(self.dirStack)
    end
    self.lastResult = self:move(dt)
    self.animations[self.status]:update(dt)
end

function player.Player:act()
    local goDir = self.dir
	if love.keyboard.isDown('left','a') then
		self.ndir = "LEFT"
    elseif love.keyboard.isDown('right','d') then
        self.ndir = "RIGHT"
	elseif love.keyboard.isDown('up','w') then
		self.ndir = "UP"
	elseif love.keyboard.isDown('down','s') then
		self.ndir = "DOWN"
	end
    local cur = self:getTileCoords()
    self.dirStack = {}
    if self:checkDir(self.ndir) then
        goDir = self.ndir
    end
    if self:checkDir(goDir) then
        cur.x = cur.x + util.dirs[goDir].x
        cur.y = cur.y + util.dirs[goDir].y
        data = {dir = goDir, mark = self.level:tileCenter(cur)}
        table.insert(self.dirStack, data)
    end
end

function player.Player:handleCollisions(cols, len)
	for i=1,len do
  		if cols[i].other.ctype == "coin" then
    		cols[i].other:kill()
    		self.score = self.score + 10
    		self.level:setTile(cols[i].other.x, cols[i].other.y, ' ')
    	elseif cols[i].other.ctype == "pill" then
    		cols[i].other:kill()
    		self.energy = player.MAX_ENERGY
    		self.status = "power"
    		self.gotPill = true
    		self.score = self.score + 50
    		self.level:setTile(cols[i].other.x, cols[i].other.y, ' ')
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
