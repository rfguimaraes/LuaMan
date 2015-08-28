-- Configuration
function love.conf(t)
	-- The title of the window the game is in (string)
	t.title = "LuaMan: a Pac-Man clone"
	-- The LÖVE version this game was made for (string)
	t.version = "0.9.2"

	t.window.width = 800
	t.window.height = 600

	-- For Windows debugging
	t.console = true
end