classer = require "classer"

local bar = {}

bar.Bar = classer.ncls()

function bar.Bar:_init(x, y, width, height, val)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	self.max = val
end

function bar.Bar:draw(dt)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.rectangle("fill", self.x, self.y, math.floor(self.width*self.val) + 1, self.height)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.rectangle("line", self.x, self.y, math.floor(self.width*self.val) + 1, self.height)
	love.graphics.setFont(db.fonts.UI)
	love.graphics.print("POWER:", math.max(self.x - 60,0), math.max(self.y - 2, 0))
end

return bar