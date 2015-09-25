classer = require "classer"

local maze = {}

maze.Maze = classer.ncls()
maze.Maze.blocks = "[w#]"
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

function maze.Maze:lookAround(x, y)
	tx = math.floor(x/self.tileW) + 1
	ty = math.floor(y/self.tileH) + 1

	local dir = {}

	if (tx > self.width) then dir.RIGHT = nil else dir.RIGHT = self.tileTable[tx + 1][ty] end
	if (tx < 1) then dir.LEFT = nil else dir.LEFT = self.tileTable[tx - 1][ty] end
	if (ty < 1) then dir.UP = nil else dir.UP = self.tileTable[tx][ty - 1] end
	if (ty > self.height) then dir.DOWN = nil else dir.DOWN = self.tileTable[tx][ty + 1] end
	return dir
end

function maze.Maze:getNeighbors(tx, ty)
	local neighbors = {}
	if (tx <= self.width) then neighbors.RIGHT = {x = tx + 1, y = ty} end
	if (tx >= 1) then neighbors.LEFT = {x = tx - 1, y = ty} end
	if (ty >= 1) then neighbors.UP = {x = tx, y = ty - 1} end
	if (ty <= self.height) then neighbors.DOWN = {x = tx, y = ty + 1} end
	return neighbors
end

function maze.Maze:curTile(x, y)
	local pos = {}
	pos.x = math.floor(x/self.tileW) + 1
	pos.y = math.floor(y/self.tileH) + 1
	return pos
end

function maze.Maze:getTile(x, y)
	local tx = math.floor(x/self.tileW) + 1
	local ty = math.floor(y/self.tileH) + 1
	return self.tileTable[tx][ty]
end

function maze.Maze:setTile(x, y, data)
	local tx = math.floor(x/self.tileW) + 1
	local ty = math.floor(y/self.tileH) + 1
	self.tileTable[tx][ty] = data
end

function maze.Maze:draw()
	love.graphics.draw(self.tileBatch)
end

return maze