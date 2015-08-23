classer = require "classer"
maze = require "maze"
player = require "player"
bump = require "bump"
debug = true
db = require "db"

luaman = nil
level = nil
scene = bump.newWorld(32)
mycoins = nil

-- Game starts
function love.load(arg)
	db.load()
	level = db.lvl[1]
	mycoins = level:toWorld(scene)

	luaman = player.Player(scene, level,32, 32, 32, 32, 90, db.img.player)
	local items, len = scene:getItems()
end

-- Every frame
function love.update(dt)
	if love.keyboard.isDown('escape') then
		love.event.push('quit')
	end
	luaman:update(dt)
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