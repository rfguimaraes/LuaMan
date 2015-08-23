classer = require "classer"
maze = require "maze"
player = require "player"
bump = require "bump"
debug = true

luaman = nil
level = nil
scene = bump.newWorld(32)
mycoins = nil

-- Game starts
function love.load(arg)
	path = "assets/mazes/level1.lua"
	level = love.filesystem.load(path)()
	mycoins = level:toWorld(scene)

	luaman = player.Player(scene, level,32, 32, 32, 32, 90, "assets/images/player.png")
	local items, len = scene:getItems()
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
	--for ci in mycoins do
	if mycoins[1].alive then
		mycoins[1]:draw(dt)
	end
	--end
end