maze = require "maze"

local tileString = [[
#####
#   #
#   #
#   #
#####
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 }, -- floor 
	{ '#', 32, 0 }  -- wall
}

return maze.Maze(32,32,'assets/images/maze.png', tileString, quadInfo)