local util = {}

util.dirs = {["RIGHT"] = {x = 1, y = 0},
	  ["DOWN"] = {x = 0, y = 1}, 
	  ["LEFT"] = {x = -1, y = 0}, 
		["UP"] = {x = 0, y = -1}}

function util.point_equal(p1, p2, th)
	local x2 = (p1.x - p2.x) * (p1.x - p2.x)
	local y2 = (p1.y - p2.y) * (p1.y - p2.y)
	return math.sqrt(x2 + y2) < th
end

return util