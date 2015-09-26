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
	run = {["."] = 2, ["u"] = 0, ["?"] = 2, ["ghost"] = 1500},
	hunt = {["."] = 1, ["u"] = 7, ["?"] = 1, ["ghost"] = 0}
}

function player.Player:toEat()
	self.state = "eat"
	self.dirStack = util.aStar(self, self.level)
	self.init = true
end

function player.Player:toRun()
	self.state = "run"
	self.dirStack = util.aStar(self, self.level)
	self.init = true

end

function player.Player:toHunt()
	self.state = "hunt"
	self.dirStack = util.aStar(self, self.level)
	self.init = true
end

function player.Player:_init(universe, level, tileW, tileH, x, y, speed, img)
	actor.Actor._init(self, universe.world, level, "player", tileW, tileH, x, y, speed, img)
	self.universe = universe
	self:initAnims()
	self.energy = 0
	self.gotPill = false
	self.countdown = 0
	self.score = 0
	self.fsm = fsm.FSM("eat", player.fsm_table)
	self:initRunPoints()
	self.state = "eat"
	self.dirStack = {}
	self:toEat()
	self.init = true
end

function player.Player:initRunPoints()
	local lw, lh = self.level.width, self.level.height
	self.runpoints = {}
	table.insert(self.runpoints, {x = 2, y = 2})
	table.insert(self.runpoints, {x = 2, y = lh - 1})
	table.insert(self.runpoints, {x = lw - 1, y = 2})
	table.insert(self.runpoints, {x = lw - 1, y = lh - 1})
	table.insert(self.runpoints, math.floor(lw/2), math.floor(lh/2))
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
	local prevTile = self:getTileCoords()

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
	if self.init or util.phash(prevTile) ~= util.phash(self:getTileCoords()) or not self:checkDir(self.ndir) then
		self.init = false
		--print(self.dirStack[#self.dirStack])
		--print(#self.dirStack)
  		if #self.dirStack == 0 then
  			self.dirStack = util.aStar(self, self.level)
  			self.init = true
  		end
  		self.ndir = table.remove(self.dirStack)
  	else
  		--print("BO")
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

	if self.state == "eat" then
		self:actEat()
	elseif self.state == "run" then
		self:actRun()
	else
		self:actHunt()
	end
end

function player.Player:actEat()
	if self:minDistGhosts(self:getTileCoords()) < 8 then
		self:toRun()
	elseif self.energy > 0.2 * player.MAX_ENERGY then
		self:toHunt()
	end
end

function player.Player:actRun()
	if self:minDistGhosts(self:getTileCoords()) > 10 then
		self:toEat()
	elseif self.energy > 0.2 * player.MAX_ENERGY then
		self:toHunt()
	else
		self:toRun()
	end
end

function player.Player:actHunt()
	if self.energy < 0.1 * player.MAX_ENERGY then
		if self:minDistGhosts(self:getTileCoords()	) > 7 then
			self:toEat()
		else
			self:toRun()
		end
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

---------------------------

function player.Player:eatHeuristic(point)
	return 0
end

function player.Player:eatGoalCheck(point)
	data = self.level.tileTable[point.x][point.y]
	return data == '.' or data == 'u'
end

---------

function player.Player:avgDistGhosts(point)
	dist = 0
	for _,ghost in ipairs(self.universe.enemies) do
		goal = self.level:curTile(ghost.x, ghost.y)
		dist = dist + util.l1Norm(point, goal)
	end
	return dist/#self.universe.enemies
end

function player.Player:minDistGhosts(point)
	goals = {}
	for _, ghost in ipairs(self.universe.enemies) do
		if ghost.status ~= "eye" then
			table.insert(goals, self.level:curTile(ghost.x, ghost.y))
		end
	end
	if #goals == 0 then
		return 0
	end
	local min = util.l1Norm(point, goals[1])
	for _, goal in ipairs(goals) do
		min = math.min(min, util.l1Norm(point, {x = goal.x, y = goal.y}))
	end
	return min
end

function player.Player:bestRunPoint()
	goals = self.runpoints
	local best, max = goals[1], self:avgDistGhosts(goals[1])
	for _, goal in ipairs(goals) do
		aux = self:avgDistGhosts(goal)
		if aux > max then
			max = aux
			best = goal
		end
	end
	return best
end

function player.Player:runHeuristic(point)
	return util.l1Norm(self:bestRunPoint(), point)
end

function player.Player:runGoalCheck(point)
	return util.phash(self:bestRunPoint()) == util.phash(point)
end

---------

function player.Player:huntHeuristic(point)
	goals = {}
	for _, ghost in ipairs(self.universe.enemies) do
		if ghost.status == "fear" then
			table.insert(goals, self.level:curTile(ghost.x, ghost.y))
		end
	end
	if #goals == 0 then
		return 0
	end
	local min = util.l1Norm(point, goals[1])
	for _, goal in ipairs(goals) do
		min = math.min(min, util.l1Norm(point, {x = goal.x, y = goal.y}))
	end
	return min
end

function player.Player:huntGoalCheck(point)
	goals = {}
	for _, ghost in ipairs(self.universe.enemies) do
		if ghost.status == "fear" then
			local tmp = ghost:getTileCoords()
			table.insert(goals, tmp)
		end
	end
	if #goals == 0 then
		return true
	end
	for _,goal in ipairs(goals) do
		if util.phash(point) == util.phash({x = goal.x, y = goal.y}) then
			return true
		end
	end
	return false
end

----------

function player.Player:heuristic(point)
	if self.state == "eat" then
		return self:eatHeuristic(point)
	elseif self.state == "run" then
		return self:runHeuristic(point)
	else
		return self:huntHeuristic(point)
	end
end

function player.Player:goalCheck(point)
	if self.state == "eat" then
		return self:eatGoalCheck(point)
	elseif self.state == "run" then
		return self:runGoalCheck(point)
	else
		return self:huntGoalCheck(point)
	end
end

function player.Player:eval(point)
	local tile = nil

	if self.level.tileTable[point.x][point.y] == "." then
		tile = "."
	elseif self.level.tileTable[point.x][point.y] == "u" then
		tile = "u"
	else
		tile = "?"
	end
	local contentCost = player.costTable[self.state][tile]
	local dangerFactor = player.costTable[self.state]["ghost"] * (1/(self:minDistGhosts(point) + 1))
	if self.state == "hunt" then
		dangerFactor = 0
	end

	return self:heuristic(point) + contentCost + dangerFactor
end

return player