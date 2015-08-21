require "classer"

local player = {}

player.Player = classer.ncls()

function player.Player:_init(tileW, tileH, x, y, speed, imgFile)
	self.tileW, self.tileH = tileW, tileH
	self.x, self.y = x, y
	self.speed = speed
	self.tileset = love.graphics.newImage(imgFile)
	self.dir = "RIGHT"
end

return player