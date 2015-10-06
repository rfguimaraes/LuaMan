classer = require "classer"
maze = require "maze"
player = require "player"
bump = require "lib.bump"
db = require "db"
univ = require "universe"
enemy = require "enemy"
gamestate = require "gamestate"
util = require "util"

debug = nil
quit = false
curState = gamestate.state["start"]
nextState = curState
util.verbose = true

-- Game starts
function love.load(arg)
end

-- Every frame
function love.update(dt)
	if love.keyboard.isDown('escape') or quit then
		love.event.push('quit')
	end
	if love.keyboard.isDown('o') then
        util.verbose = not util.verbose
    end
	nextState = curState:update(dt)
end

-- Every frame
function love.draw(dt)
	curState:draw(dt)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
	curState = nextState
end

function love.keypressed(key, isRepeat)
	if key == " " then
		gamestate.switch = not gamestate.switch
	end
end
