classer = require "classer"
univ = require "universe"

local gamestate = {}

gamestate.GameState = classer.ncls()

gamestate.drawn = false
gamestate.inited = false
gamestate.scene = nil

-----------------------------------------------------------

function gamestate.GameState:_init()
end

function gamestate.GameState:update(univ, dt)
	assert(false, "Must be overloaded!\n")
end

function gamestate.GameState:draw(univ, dt)
	assert(false, "Must be overloaded!\n")
end

-----------------------------------------------------------

gamestate.StartState = classer.ncls(gamestate.GameState)

function gamestate.StartState:update(dt)
	if not gamestate.inited then
		gamestate.inited = true
		gamestate.scene = univ.Universe(32)
		gamestate.scene:populate()
	end
	if love.keyboard.isDown(' ') then
		return gamestate.state["playing"]
	end
	return gamestate.state["start"]
end

function gamestate.StartState:draw(dt)
	gamestate.drawn = true
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.print("LUAMAN", 500, 200)
	love.graphics.print("Press SPACE to play/pause, Esc to Exit", 300, 300)
	love.graphics.print("Arrow-keys move the LuaMan", 300, 400)
end

-----------------------------------------------------------

gamestate.PlayingState = classer.ncls(gamestate.GameState)

function gamestate.PlayingState:update(dt)
	table.foreach(gamestate, print)
	if love.keyboard.isDown(' ') then
		return gamestate.state["paused"]
	end
	if not gamestate.scene.player.alive then
		return gamestate.state["loss"]
	elseif gamestate.scene:cleared() then
		return gamestate.state["win"]
	end
	gamestate.scene:update(dt)
	return gamestate.state["playing"]
end

function gamestate.PlayingState:draw(dt)
	print(gamestate.scene)
	if gamestate.scene then
		gamestate.scene:drawAndClean(dt)
	end
end

-----------------------------------------------------------

gamestate.PausedState = classer.ncls(gamestate.GameState)

function gamestate.PausedState:update(dt)
	if love.keyboard.isDown(' ') then
		return gamestate.state["playing"]
	end
	return gamestate.state["paused"]
end

function gamestate.PausedState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
	love.graphics.print("GAME PAUSED", 300, 300)
	love.graphics.print("Press SPACE to continue, Esc to Exit", 300, 400)
end

-----------------------------------------------------------

gamestate.WinState = classer.ncls(gamestate.GameState)

function gamestate.WinState:update(dt)
	if love.keyboard.isDown(' ') then
		gamestate.inited = false
		return gamestate.state["playing"]
	end
	return gamestate.state["win"]
end

function gamestate.WinState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
	love.graphics.print("WIN :D", 300, 300)
	love.graphics.print("Press SPACE to restart, Esc to Exit", 300, 400)
end

-----------------------------------------------------------

gamestate.LossState = classer.ncls(gamestate.GameState)

function gamestate.LossState:update(dt)
	if love.keyboard.isDown(' ') then
		gamestate.inited = false
		return gamestate.state["start"]
	end
	return gamestate.state["loss"]
end

function gamestate.LossState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
	love.graphics.print("Game Over :(", 300, 300)
	love.graphics.print("Press SPACE to restart, Esc to Exit", 300, 400)
end

-----------------------------------------------------------

gamestate.state = {
	start = gamestate.StartState(),
	playing = gamestate.PlayingState(),
	paused = gamestate.PausedState(),
	win = gamestate.WinState(),
	loss = gamestate.LossState()
}

return gamestate