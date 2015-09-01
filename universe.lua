classer = require "classer"
bump = require "lib.bump"
maze = require "maze"
db = require "db"
enemy = require "enemy"
pill = require "pill"

local universe = {}

universe.Universe = classer.ncls()

function universe.Universe:_init(gridSize)
	db.load()
	self.world = bump.newWorld(gridSize)
	self.coins = {}
	self.pills = {}
	self.enemies = {}
	self.player = nil
	self.level = db.lvl[1]
end

-- Populate

function universe.Universe:populate()
	local tileW, tileH = self.level.tileW, self.level.tileH
	for x = 1,self.level.width do
		for y = 1,self.level.height do
			tile = self.level.tileTable[x][y]
			if tile:match(maze.Maze.blocks) then
				self.world:add({ctype = tile}, (x - 1)*tileW, (y - 1)*tileH, tileW, tileH)
			elseif tile == "." then
				self:parseCoin(x, y)
			elseif tile:match(maze.Maze.enemies) then
				self:parseEnemy(tile, x, y)
			elseif tile == "s" then
				self:parsePlayer(x, y)
			elseif tile == "u" then
				self:parsePill(x, y)
			end
		end
	end
end

function universe.Universe:parseEnemy(tile, tx, ty)
	local enemyIndex = {b = 1, c = 2, i = 3, p = 4}
	local x = (tx - 1) * self.level.tileW
	local y = (ty - 1) * self.level.tileH
	local e = enemy.Enemy(self.world, self.level, 32, 32, x ,y, 140, db.img.enemy, enemyIndex[tile])
	if tile ~= "b" then
		self:addSpawn(x, y)
	end
	table.insert(self.enemies, e)
end

function universe.Universe:addSpawn(x, y)
	local ox, oy = self.level.tileW/2, self.level.tileH/2
	self.world:add({ctype = "spawn"}, x + ox/2, y + oy/2, ox, oy)
end

function universe.Universe:parsePlayer(tx, ty)
	local x = (tx - 1) * self.level.tileW
	local y = (ty - 1) * self.level.tileH
	self.player = player.Player(self.world, self.level,32, 32, x, y, 90, db.img.player)
end

function universe.Universe:parseCoin(tx, ty)
	local tileW, tileH = self.level.tileW, self.level.tileH
	local c = coin.Coin(self.world, 3, (tx - 1) * tileW, (ty - 1) * tileH, tileW, tileH)
	table.insert(self.coins, c)
end

function universe.Universe:parsePill(tx, ty)
	local tileW, tileH = self.level.tileW, self.level.tileH
	local p = pill.Pill(self.world, (tx - 1) * tileW, (ty - 1) * tileH, tileW, tileH)
	table.insert(self.pills, p)
end

-- Update

function universe.Universe:update(dt)
	local prev = self.player.status
	
	self.player:update(dt)
	for _,e in ipairs(self.enemies) do
		e:update(prev, self.player.status, dt)
	end
end

-- Draw

function universe.Universe:drawAndClean(dt)
	self.level:draw()
	self:drawAndCleanList(self.coins, dt)
	self:drawAndCleanList(self.pills, dt)
	self:drawAndCleanList(self.enemies, dt)
	self.player:draw(dt)
end

function universe.Universe:drawAndCleanList(list, dt)
	for _,x in ipairs(list, dt) do
		if x.alive then
			x:draw(dt)
		else
			list[x] = nil
		end
	end
end

function universe.Universe:cleared()
	local answer = #self.pills == 0
	answer = answer and #self.coins == 0
	return answer
end

return universe