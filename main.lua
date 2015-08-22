classer = require "classer"
maze = require "maze"
player = require "player"

debug = true

luaman = nil
level = nil

-- Game starts
function love.load(arg)
	path = "assets/mazes/level1.lua"
	level = love.filesystem.load(path)()

	luaman = player.Player(32, 32, 16, 48, 40, "assets/images/player.png")
end

-- Every frame
function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	luaman:update(dt)
	--if love.keyboard.isDown('left','a') then
	--	player.x = player.x - (player.speed*dt)
	--elseif love.keyboard.isDown('right','d') then
	--	player.x = player.x + (player.speed*dt)
	--end

end

-- Every frame
function love.draw(dt)
	level:draw()
	luaman:draw(dt)
end