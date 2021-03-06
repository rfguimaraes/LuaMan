maze = require "maze"

local tileString = [[
############################
#u...........##...........u#
#.####.#####.##.#####.####.#
#.####.#####.##.#####.####.#
#.##......##.##.##......##.#
#.##.####.##....##.####.##.#
#.##.####.##.##.##.####.##.#
#.##.####.##.##.##.####.##.#
#............##............#
###.##.##.########.##.##.###
###.##.##.########.##.##.###
###....##    b     ##....###
######.##.###ww###.##.######
######.##.#eeeeee#.##.######
####...##.wecipeew.##...####
####.####.#eeeeee#.####.####
####.####.########.####.####
#............s.............#
#.ww.ww.wwww.w#.####.##.##.#
#.ww.ww.wwww.w#.####.##.##.#
#....ww......w#......##....#
#.ww.wwww.wwww####.####.##.#
#.ww.wwww.wwww####.####.##.#
#.ww....................##.#
#.wwww.ww.wwww####.##.####.#
#.wwww.ww.wwww####.##.####.#
#.ww...ww....w#....##...##.#
#.ww.wwww.ww.w#.##.####.##.#
#.ww.wwww.ww.w#.##.####.##.#
#u........ww....##........u#
############################
]]

local quadInfo = 
{ 
	{ ' ',  0, 0 },	-- floor 
	{ '#', 16, 0 }, -- wall
	{ 'w', 32, 0 }, -- specwall
	{ '.',  0, 0 }, -- floor, dot
	{ 's',  0, 0 }, -- floor, start
	{ 'b',  0, 0 }, -- floor, enemy: blinky
	{ 'c', 48, 0 }, -- spawn, enemy: clyde
	{ 'i', 48, 0 }, -- spawn, enemy: inky
	{ 'p', 48, 0 }, -- spawn, enemy: pinky
	{ 'e', 48, 0 }, -- spawn
	{ 'u',  0, 0 }  -- floor, pill
}

return {tileString = tileString, quadInfo = quadInfo}
