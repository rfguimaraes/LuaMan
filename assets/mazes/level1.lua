maze = require "maze"

local tileString = [[
###########
#         #
#  #####  #
#  ##x##  #
#  #####  #
#         #
###########
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 }, -- floor 
	{ '#', 32, 0 },  -- wall
	{ 'x',  0, 0 } -- floor
}

return maze.Maze(32,32,'assets/images/maze.png', tileString, quadInfo)