classer = require "classer"
bump = require "bump"
maze = require "maze"

local universe = {}

universe.Universe = classer.ncls()

function universe.Universe:_init(gridSize, level)
	self.world = bump.newWorld(gridSize)
	self.coins = {}
	self.enemies = {}
	self.player = nil
end

function universe.Universe.populate()
	local c,p,e
	for x = 1,self.level.width do
		for y = 1,self.level.height do
			tile = self.level.tileTable[x][y]
			if tile:match(maze.Maze.blocks) then
				self.world:add({ctype = tile}, (x - 1)*self.tileW, (y - 1)*self.tileH, self.tileW, self.tileH)
			elseif tile == "." then
				c = coin.Coin(self.world, 4, (x - 1)*self.tileW, (y - 1)*self.tileH, self.tileH/2)
				table.insert(self.coins, c)
			elseif tile:match(maze.Maze.enemies) then
				self:parseEnemy(tile, tx, ty)
			elseif tile == "s" then
				self.parsePlayer(tx, ty)
			elseif tile == "$" then
				self.parsePill(tx, ty)
			end
		end
	end
end

function universe.Universe.parseEnemy(tile, tx, ty)
end

function universe.Universe.parsePlayer(tx, ty)
end

function universe.Universe.parsePill(tx, ty)
end

function universe.Universe:set_level(maze)
	self.level = maze
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