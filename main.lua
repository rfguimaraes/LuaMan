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
	scene:update(dt)
end

-- Every frame
function love.draw(dt)
	scene:drawAndClean(dt)
	if not scene.player.alive then
		quit = true
	end
end