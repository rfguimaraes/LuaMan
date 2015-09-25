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

function util.l1Norm(p1, p2)
	return math.abs(p1.x - p2.x) + math.abs(p1.y - p2.y)
end

function util.aStar(indv, level)
	start = indv.level:curTile(indv.x, indv.y)
	fringe = pq.PQ()
	fringe:insert(start, 0)
	ancestor = {}
	accum = {}

	ancestor[util.phash(start)] = nil
	accum[util.phash(start)] = 0

	print("START")


	while not fringe:empty() do
		print("====")
		cur = fringe:getNext()
		print(util.phash(cur))

		if indv:goalCheck(cur) then
			print("GOAL")
			print(util.phash(cur))
			break
		end
		print("neigh:")
		for _, neigh in ipairs(indv:neighboors(cur)) do
			new_cost = accum[util.phash(cur)] + 1 + indv:eval()
			print("\t" .. util.phash(neigh) .. " " .. new_cost)
			if not accum[util.phash(neigh)] or new_cost < accum[util.phash(neigh)] then
				accum[util.phash(neigh)] = new_cost
				cost = new_cost
				fringe:insert(neigh, cost)
				ancestor[util.phash(neigh)] = cur
			end
		end
	end

	path = {}
	table.insert(path, cur)
	while util.phash(cur) ~= util.phash(start) do
		cur = ancestor[util.phash(cur)]
		table.insert(path, cur)
	end

	res = {}
	for index = #path,1,-1 do
        table.insert(res, path[index])
    end

    return res
end

return util