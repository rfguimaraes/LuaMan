pq = require "pq"

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

function util.phash(p)
	return p.x .. ":" .. p.y
end

function util.manhattan(p1, p2)
	return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

function h(p1, p2)

end

function util.aStar(level, h, start, goal_check)
	fringe = pq.PQ()
	fringe:insert(start, 0)
	ancestor = {}
	accum = {}

	ancestor[util.phash(start)] = nil
	accum[util.phash(start)] = 0

	while not fringe:empty() do
		cur = fringe:getNext()

		if goal_check(cur)
			break
		end

		for neigh in level:neighboors(cur) do
			new_cost = accum[util.phash(cur)] + 1
			if not accum[util.phash(neigh)] or new_cost < accum[neigh] then
				accum[util.phash(neigh)] = new_cost
				cost = new_cost + h(neigh)
				fringe:insert(neigh, cost)
				ancestor[neigh] = cur
		end
	end

	path = {}
	table.insert(path, cur)
	while util.phash(cur) != util.phash(start):
	   cur = ancestor[util.phash(cur)]
	   table.insert(path, cur)

	res = {}
	for index = #path,1,-1 do
        table.insert(res, path[index])
    end

    return res
end

return util