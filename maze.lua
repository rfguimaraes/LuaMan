classer = require "classer"
coin = require "coin"

local maze = {}

maze.Maze = classer.ncls()
maze.Maze.blocks = "[%%#]"
maze.Maze.enemies = "[bcip]"

function maze.Maze:_init(tileW, tileH, img, tileString, quadInfo)
	self.tileW = tileW
	self.tileH = tileH
	self.tileset = img

	local tilesetW, tilesetH = self.tileset:getWidth(), self.tileset:getHeight()
	self.quads = {}
  
	for _,info in ipairs(quadInfo) do
		-- info[1] = the character, info[2] = x, info[3] = y
		self.quads[info[1]] = love.graphics.newQuad(info[2], info[3], tileW,  tileH, tilesetW, tilesetH)
	end


	self.tileTable = {}

	self.width = #(tileString:match("[^\n]+"))
	self.height = select(2, tileString:gsub('\n', '\n'))
	self.tileBatch = love.graphics.newSpriteBatch(self.tileset, self.width * self.height)
	for x = 1,self.width,1 do self.tileTable[x] = {} end
	self.tileBatch:clear()
	local x, y = 1,1
	for row in tileString:gmatch("[^\n]+") do
		x = 1
		for tile in row:gmatch(".") do
			self.tileTable[x][y] = tile
			self.tileBatch:add(self.quads[tile], (x - 1)*tileW, (y - 1)*tileH)
			x = x + 1
		end
		y = y + 1
	end
	self.tileBatch:flush()
end

function maze.Maze:toWorld(world)
	self.world = world
	local wcoins = {}
	local tile = nil
	for x = 1,self.width do
		for y = 1,self.height do
			tile = self.tileTable[x][y]
			if tile:match(maze.Maze.blocks) then
				self.world:add({ctype = tile}, (x - 1)*self.tileW, (y - 1)*self.tileH, self.tileW, self.tileH)
			elseif tile == "." then
				ck = coin.Coin(self.world, 4, (x - 1)*self.tileW, (y - 1)*self.tileH, self.tileH/2)
				table.insert(wcoins, ck)
			end
		end
	end
	return wcoins
end

function maze.Maze:freeSpots(x, y)
	tx = math.floor(x/self.tileW) + 1
	ty = math.floor(y/self.tileH) + 1

	local dir = {}

	dir.RIGHT = (tx < self.width) and not self.tileTable[tx + 1][ty]:match(maze.Maze.blocks)
	dir.LEFT = (tx > 1) and not self.tileTable[tx - 1][ty]:match(maze.Maze.blocks)
	dir.UP = (ty > 1) and not self.tileTable[tx][ty - 1]:match(maze.Maze.blocks)
	dir.DOWN = (ty < self.height) and not self.tileTable[tx][ty + 1]:match(maze.Maze.blocks)
	
	return dir
end

function maze.Maze:curTile(x, y)
	local pos = {}
	pos.x = math.floor(x/self.tileW) + 1
	pos.y = math.floor(y/self.tileH) + 1
	return pos
end

function maze.Maze:draw()
	love.graphics.draw(self.tileBatch)
end

return maze