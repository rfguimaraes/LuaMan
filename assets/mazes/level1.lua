maze = require "maze"

local tileString = [[
###########
#s        #
#  ## ##  #
#  ##.##  #
#  #####  #
#         #
###########
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 },	-- floor 
	{ '#', 32, 0 }, -- wall
	{ '.',  0, 0 }, -- floor, dot
	{ 's',  0, 0 }, -- floor, start
}

return maze.Maze(32,32,'assets/images/maze.png', tileString, quadInfo)