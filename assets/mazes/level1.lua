maze = require "maze"

local tileString = [[
###########
#s        #
#  ## b#  #
#  ##.##  #
#  ##. #  #
#    #    #
###########
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 },	-- floor 
	{ '#', 32, 0 }, -- wall
	{ '.',  0, 0 }, -- floor, dot
	{ 's',  0, 0 }, -- floor, start
	{ 'b',  0, 0 }, -- floor, enemy
}

return {tileString = tileString, quadInfo = quadInfo}