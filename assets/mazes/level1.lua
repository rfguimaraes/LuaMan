maze = require "maze"

local tileString = [[
#########################
#u.....................u#
#.####.##.##.##.##.####.#
#.####.##.##.##.##.####.#
#.##...#.........#...##.#
#.##.###.#.##.##.###.##.#
#........#.##.#.........#
#.###.##....b....######.#
#.###.##.##www##.##.....#
#.....ww.wwcip##.##.###.#
#.wwwwww.www####.##.###.#
#...........s...........#
#.ww.www...w##...###.##.#
#.ww...ww........#...##.#
#.wwww.ww.ww.##.##.####.#
#.wwww.ww.ww.##.##.####.#
#u.....................u#
#########################
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
	{ 'u',  0, 0 }  -- floor, pill
}

return {tileString = tileString, quadInfo = quadInfo}