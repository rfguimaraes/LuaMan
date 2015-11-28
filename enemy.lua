classer = require "classer"
anim8 = require "lib.anim8"
actor = require "actor"
fsm = require "fsm"
util = require "util"

local enemy = {}

enemy.Enemy = classer.ncls(actor.Actor)

enemy.Enemy.blocks = "[#]"

enemy.fsm_table = 
{
    {"wander", "player_near", "seek", nil},
    {"wander", "on_fear", "avoid", nil},
    {"wander", "on_eye", "restore", nil},
    {"seek", "player_far", "wander", nil},
    {"seek", "on_fear", "avoid", nil},
    {"seek", "on_eye", "restore", nil},
    {"avoid", "player_near", "seek", nil},
    {"avoid", "player_far", "wander", nil},
    {"restore", "player_near", "seek", nil},
    {"restore", "player_far", "wander", nil}
}

function enemy.Enemy:changeState(state)
    self.state = state
    self.dirStack = util.aStar(self, 5)
end

function enemy.Enemy:_init(name, universe, level, tileW, tileH, x, y, speed, img, index)
    self.name = name
	actor.Actor._init(self, name, universe, level, "enemy", tileW, tileH, x, y, speed, img)
    self.baseSpeed = speed
	self.index = index
	self:initAnims()
	self.lastUpdate = love.timer.getTime()
    self.fsm = fsm.FSM("wander", enemy.fsm_table)
    -- move this to actWander?
    self.destiny = self.level:randTile()
    self.dirStack = util.aStar(self, nil)
    self:changeState("wander")
    self.maxCoins = #universe.coins
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
	elseif self.status == "fear" and noFear then
		self.status = "normal"
	end
    if #self.dirStack == 0 then
        self.dirStack = util.aStar(self, 5)
    end
    if not self.nextStep then
        self.nextStep = table.remove(self.dirStack)
    end
	actor.Actor.update(self, dt)	
    local coef = (self.maxCoins - #self.universe.coins)/self.maxCoins
    self.speed = self.baseSpeed * (1 + coef * 0.5)
end

function enemy.Enemy:neighbors(point)
	local neighbors = {}
	for key, val in pairs(self.level:getNeighbors(point.x, point.y)) do
            c = self.level.tileTable[val.x][val.y]
            if not c:match(enemy.Enemy.blocks) then
                table.insert(neighbors, {x = val.x, y = val.y})
            end
	end
    return neighbors
end

function enemy.Enemy:act()
    if self.state == "wander" then
        self:actWander()
    elseif self.state == "seek" then
        self:actSeek()
    elseif self.state == "avoid" then
        self:actAvoid()
    else
        self:actRestore()
    end
end

function enemy.Enemy:actWander()
    if not self.destiny then
        self.destiny = self.level:randTile()
    end
    if self.status == "eye" then
        self:changeState("restore")
    elseif self.status == "fear" then
        self:changeState("avoid")
    elseif util.l1Norm(self:getTileCoords(), self.universe.player:getTileCoords()) < 10 then
        self:changeState("seek")
    end

    local tile
	if #self.dirStack == 0 then
        repeat
            self.destiny = self.level:randTile()
            tile = self.level.tileTable[self.destiny.x][self.destiny.y]
        until not tile:match(actor.Actor.blocks)
        self.dirStack = util.aStar(self, nil)
		self.lastUpdate = love.timer.getTime()
	end
end

function enemy.Enemy:actSeek()
    if self.status == "eye" then
        self:changeState("restore")
    elseif self.status == "fear" then
        self:changeState("avoid")
    elseif util.l1Norm(self:getTileCoords(), self.universe.player:getTileCoords()) > 10 then
        self:changeState("wander")
    end
end

function enemy.Enemy:actAvoid()
    if self.status == "eye" then
        self:changeState("restore")
    elseif self.status == "normal" then
        if util.l1Norm(self:getTileCoords(), self.universe.player:getTileCoords()) < 10 then
            self:changeState("seek")
        else
            self:changeState("wander")
        end
    end
    if not self.destiny then
        self.destiny = self.level:randTile()
    end
    local tile
	if #self.dirStack == 0 then
        repeat
            self.destiny = self.level:randTile()
            tile = self.level.tileTable[self.destiny.x][self.destiny.y]
        until not tile:match(actor.Actor.blocks)
        self.dirStack = util.aStar(self, nil)
		self.lastUpdate = love.timer.getTime()
    end
end

function enemy.Enemy:actRestore()
    if self.status == "normal" then
        if util.l1Norm(self:getTileCoords(), self.universe.player:getTileCoords()) > 10 then
            self:changeState("wander")
        else
            self:changeState("seek")
        end
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

---------------------------

function enemy.Enemy:wanderHeuristic(point)
    return util.l1Norm(point, self.destiny)
end

function enemy.Enemy:wanderGoalCheck(point)
    return util.phash(point) == util.phash(self.destiny)
end

---------

function enemy.Enemy:seekHeuristic(point) 
    return util.l1Norm(point, self.universe.player:getTileCoords())
end

function enemy.Enemy:seekGoalCheck(point)
    return (util.l1Norm(point, self.universe.player:getTileCoords()) <= math.random(1, 5))
end

---------

function enemy.Enemy:avoidHeuristic(point)
    --local per = 2*(self.level.width+self.level.height)
    --return util.l1Norm(point, universe.player:getTileCoords())
    return self:wanderHeuristic(point)
end

function enemy.Enemy:avoidGoalCheck(point)
    return self:wanderGoalCheck(point)
end

---------

function enemy.Enemy:restoreHeuristic(point)
    local mapCenter = {}
    mapCenter.x = math.floor(self.level.width/2)
    mapCenter.y = math.floor(self.level.height/2)
    return util.l1Norm(point, mapCenter)
end

function enemy.Enemy:restoreGoalCheck(point)
    local data = self.level.tileTable[point.x][point.y]
    return data:match("[eipc]")
end

---------

function enemy.Enemy:heuristic(point)
    if self.state == "wander" then
        return self:wanderHeuristic(point)
    elseif self.state == "seek" then
        return self:seekHeuristic(point)
    elseif self.state == "avoid" then
        return self:avoidHeuristic(point)
    else
        return self:restoreHeuristic(point)
    end
end

function enemy.Enemy:goalCheck(point)
    if self.state == "wander" then
        return self:wanderGoalCheck(point)
    elseif self.state == "seek" then
        return self:seekGoalCheck(point)
    elseif self.state == "avoid" then
        return self:avoidGoalCheck(point)
    else
        return self:restoreGoalCheck(point)
    end
end

function enemy.Enemy:proxOthers(point)
    local sum = 0
    local dist
    for _,ghost in ipairs(self.universe.enemies) do
        if ghost.name ~= self.name then
            dist = util.l1Norm(point, ghost:getTileCoords())
            if dist < 5 then 
                sum = sum + dist
            end
        end
    end
    return sum
end

function enemy.Enemy:eval(point)
    local proxFactor = 0
    local h
    proxFactor = self:proxOthers(point)
    proxFactor = 1/(proxFactor + 1)
    proxFactor = proxFactor * proxFactor * 1000
    h = self:heuristic(point)
    return h + proxFactor
end

return enemy
