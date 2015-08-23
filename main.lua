classer = require "classer"
maze = require "maze"
player = require "player"
bump = require "bump"
db = require "db"
univ = require "universe"

debug = true
scene = nil
-- Game starts
function love.load(arg)
	scene = univ.Universe(32)
	scene:populate()
end

-- Every frame
function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	scene.player:update(dt)
end

-- Every frame
function love.draw(dt)
	scene.level:draw()
	scene.player:draw(dt)
	for _,c in ipairs(scene.coins) do
		if c.alive then
			c:draw(dt)
		else
			scene.coins[c] = nil
		end
	end
end