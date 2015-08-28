classer = require "classer"
maze = require "maze"
player = require "player"
bump = require "lib.bump"
db = require "db"
univ = require "universe"

enemy = require "enemy"

debug = true
scene = nil
quit = false

-- Game starts
function love.load(arg)
	scene = univ.Universe(32)
	scene:populate()
end

-- Every frame
function love.update(dt)
	if love.keyboard.isDown('escape') or quit then
		love.event.push('quit')
	end
	scene.player:update(dt)
	scene.enemies[1]:update(dt)
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

	for _,p in ipairs(scene.pills) do
		if p.alive then
			p:draw(dt)
		else
			scene.coins[p] = nil
		end
	end
	scene.enemies[1]:draw(dt)
	if not scene.player.alive then
		quit = true
	end
end