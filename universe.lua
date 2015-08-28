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
	local x = (tx - 1) * self.level.tileW
	local y = (ty - 1) * self.level.tileH
	local e = enemy.Enemy(self.world, self.level, 32, 32, x ,y, 140, db.img.enemy, 1)
	table.insert(self.enemies, e)
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

function universe.Universe:add(entity)
end

function universe.collision(item, other)
	if item.is_a[player.Player] then
		if other.is_a[coin] or other.is_a[pill] then
			return "cross"
		else
		    return "touch"
		end
	end

	if item.is_a[enemy] then
		if other.is_a[wall] or other.is_a[player.Player] then
			return "touch"
		else
			return false
		end
	end

	return false
end

return universe