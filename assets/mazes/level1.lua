maze = require "maze"

local tileString = [[
#########################
#s                      #
# ######  # ## #   ###  #
# ######  # ## #   ###  #
# ######  # ## # #####  #
#         # ## # #      #
# ######  # ## # ###wwww#
# ######    ## #      w #
#.....##....u.b.........#
#.##..##.u..wwwww.......#
#...u....  uwcipw ....w.#
############wwwww #     #
#...............        #
################        #
#       ............    #
#       ............    #
#       ............   u#
#########################
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 },	-- floor 
	{ '#', 32, 0 }, -- wall
	{ 'w', 64, 0 }, -- specwall
	{ '.',  0, 0 }, -- floor, dot
	{ 's',  0, 0 }, -- floor, start
	{ 'b',  0, 0 }, -- floor, enemy: blinky
	{ 'c', 96, 0 }, -- spawn, enemy: clyde
	{ 'i', 96, 0 }, -- spawn, enemy: inky
	{ 'p', 96, 0 }, -- spawn, enemy: pinky
	{ 'u',  0, 0 }  -- floor, pill
}

return {tileString = tileString, quadInfo = quadInfo}