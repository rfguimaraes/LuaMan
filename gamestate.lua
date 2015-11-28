classer = require "classer"
univ = require "universe"
db = require "db"

local gamestate = {}

gamestate.GameState = classer.ncls()

gamestate.drawn = false
gamestate.inited = false
gamestate.scene = nil
gamestate.switch = false

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

function gamestate.StartState:_init()
	gamestate.GameState._init()
	db.load()
    self.lastTime = love.timer.getTime()
    self.intro = {db.img.intro1,
                  db.img.intro2,
                  db.img.intro3,
                  db.img.intro4,
                  db.img.intro5}
    self.index = 1
end

function gamestate.StartState:update(dt)
    if love.timer.getTime() - self.lastTime > 3 then
        self.lastTime = love.timer.getTime()
        self.index = (self.index % #self.intro) + 1
        gamestate.drawn = false
    end
	if not gamestate.inited then
		gamestate.inited = true
		gamestate.scene = univ.Universe(16)
		gamestate.scene:populate()
        db.bgm.intro:play()
        db.bgm.game:stop()
	end
	if gamestate.switch then
		gamestate.switch = false
        db.bgm.intro:stop()
        db.bgm.game:play()
		return gamestate.state["playing"]
	end
	return gamestate.state["start"]
end

function gamestate.StartState:draw(dt)
	gamestate.drawn = true
    love.graphics.draw(self.intro[self.index], 24, 100)
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setFont(db.fonts.title);
	love.graphics.print("LUAMAN", 100, 50)
	love.graphics.setFont(db.fonts.default);
	love.graphics.print("Press SPACE to play/pause, Esc to Exit", 50, 400)
	love.graphics.print("Arrow-keys move the LuaMan", 70, 450)
end

-----------------------------------------------------------

gamestate.PlayingState = classer.ncls(gamestate.GameState)

function gamestate.PlayingState:update(dt)
	if gamestate.switch then
		gamestate.switch = false
        db.bgm.game:pause()
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
	if gamestate.scene then
        local score = gamestate.scene.player.score
		gamestate.scene:drawAndClean(dt)
        love.graphics.print("Score: ".. score, 300, 10)
	end
end

-----------------------------------------------------------

gamestate.PausedState = classer.ncls(gamestate.GameState)

function gamestate.PausedState:update(dt)
	if gamestate.switch then
		gamestate.switch = false
        db.bgm.game:play()
		return gamestate.state["playing"]
	end
	return gamestate.state["paused"]
end

function gamestate.PausedState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
    local ref = gamestate.scene.player:getTileCoords()
    love.graphics.print("POS: ".. util.phash(ref), 300, 10)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.setFont(db.fonts.header)
	love.graphics.print("GAME PAUSED", 50, 100)
	love.graphics.setFont(db.fonts.default)
	love.graphics.print("Press SPACE to continue, Esc to Exit", 50, 200)
	love.graphics.setColor(255, 255, 255, 255)
end

-----------------------------------------------------------

gamestate.WinState = classer.ncls(gamestate.GameState)

function gamestate.WinState:_init()
    gamestate.GameState:_init()
    self.played = false
end

function gamestate.WinState:update(dt)
    if not self.played then
        self.played = true
        db.sfx.win:play()
    end
	if gamestate.switch then
		gamestate.switch = false
		gamestate.inited = false
        self.played = false
		return gamestate.state["start"]
	end
	return gamestate.state["win"]
end

function gamestate.WinState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.setFont(db.fonts.header)
	love.graphics.print("WIN :D", 50, 100)
	love.graphics.setFont(db.fonts.default)
	love.graphics.print("Press SPACE to restart, Esc to Exit", 50, 200)
	love.graphics.setColor(255, 255, 255, 255)
end

-----------------------------------------------------------

gamestate.LossState = classer.ncls(gamestate.GameState)

function gamestate.LossState:update(dt)
	if gamestate.switch then
		gamestate.switch = false
		gamestate.inited = false
        db.bgm.game:stop()
		return gamestate.state["start"]
	end
	return gamestate.state["loss"]
end

function gamestate.LossState:draw(dt)
	gamestate.drawn = true
	gamestate.scene:drawAndClean(dt)
	love.graphics.setColor(255, 0, 0, 255)
	love.graphics.setFont(db.fonts.header)
	love.graphics.print("Game Over :(", 50, 100)
	love.graphics.setFont(db.fonts.default)
	love.graphics.print("Press SPACE to restart, Esc to Exit", 50, 200)
	love.graphics.setColor(255, 255, 255, 255)
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
