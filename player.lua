require "classer"

local player = {}

player.Player = classer.ncls()

directions = {["RIGHT"] = 0, ["DOwN"] = 90, ["LEFT"] = 180, ["UP"] = 270}

function player.Player:_init(tileW, tileH, x, y, speed, imgFile)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.speed = speed
	self.tileset = love.graphics.newImage(imgFile)
	self.dir = "RIGHT"

	local tilesetH = self.tileset:getHeight()
	local tilesetW = self.tileset:getWidth()

	rows = tilesetH/tileH
	cols = tilesetW/tileW

	walkAnim = {1,2,3,4}

	self.quads = {}
	for x = 1,rows do
		for y = 1,cols do
			quad = love.graphics.newQuad((x - 1)*tileW, (y - 1)*tileH, tileW, tileH, tilesetW, tilesetH)
			self.quads[(x - 1) * cols + y] = quad
		end
	end
end

return player