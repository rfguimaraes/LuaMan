classer = require "classer"

local maze = {}

maze.Maze = classer.ncls()

function maze.Maze:_init(tileW, tileH, imgFile, tileString, quadInfo)
	self.tileW = tileW
	self.tileH = tileH
	self.tileset = love.graphics.newImage(imgFile)

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
			self.tileBatch:add(self.quads[tile], (x - 1)*self.tileW, (y - 1)*self.tileH)
			x = x + 1
		end
		y = y + 1
	end
	self.tileBatch:flush()
end

function maze.Maze:draw()
	love.graphics.draw(self.tileBatch)
end

return maze