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
	{ ' ',  0,  0 }, -- floor 
	{ '#',  0, 32 }  -- wall
}

return maze.Maze(32,32,'assets/images/maze.png', tileString, quadInfo)