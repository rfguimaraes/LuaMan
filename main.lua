classer = require "classer"

debug = true

player = { x = 32, y = 64, speed = 150, img = nil }

-- Game starts
function love.load(arg)
	player.img = love.graphics.newImage("assets/images/player.png")
end

-- Every frame
function love.update(dt)
	-- I always start with an easy way to exit the game
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end

	if love.keyboard.isDown('left','a') then
		player.x = player.x - (player.speed*dt)
	elseif love.keyboard.isDown('right','d') then
		player.x = player.x + (player.speed*dt)
	end
end

-- Every frame
function love.draw(dt)
	love.graphics.draw(player.img, player.x, player.y)
end