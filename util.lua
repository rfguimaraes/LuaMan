pq = require "pq"
maze = require "maze"

local util = {}

util.verbose = false

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

function dbg_print(text)
    if util.verbose then
        print(text)
    end
end

function util.aStar(indv)
	dbg_print(" A*-----------------")
	start = indv:getTileCoords()
    level = indv.level
	fringe = pq.PQ()
	fringe:insert(start, 0)
	ancestor = {}
	accum = {}

	ancestor[util.phash(start)] = nil
	accum[util.phash(start)] = 0

	dbg_print("START")
	dbg_print(util.phash(start))
	--print(indv:huntHeuristic(start))

	while not fringe:empty() do
		--print("====")
		cur = fringe:getNext()
		--print(util.phash(cur))
		if indv:goalCheck(cur) then
			dbg_print("GOAL")
			dbg_print(util.phash(cur))
			break
		end
		--print("neigh:")
		for _, neigh in ipairs(indv:neighbors(cur)) do
			new_cost = accum[util.phash(cur)] + 1 + indv:eval(neigh)
			--print("\t" .. util.phash(neigh) .. " " .. new_cost)
			if not accum[util.phash(neigh)] or new_cost < accum[util.phash(neigh)] then
				accum[util.phash(neigh)] = new_cost
				cost = new_cost
				fringe:insert(neigh, cost)
				ancestor[util.phash(neigh)] = cur
			end
		end
	end

	path = {}
	-- dbg_print(">>>>>>>>>>>>>START<<<<<<<<<<<<<<<")
	local dir = nil
	while util.phash(cur) ~= util.phash(start) do
		if ancestor[util.phash(cur)].x == cur.x then
			if ancestor[util.phash(cur)].y < cur.y then
				dir = "DOWN"
			else
				dir = "UP"
			end
		else
			if ancestor[util.phash(cur)].x < cur.x then
				dir = "RIGHT"
			else
				dir = "LEFT"
			end
		end
        data = {dir = dir, mark = indv.level:tileCenter(cur)}
        local ances = "nil"
        if ancestor[util.phash(cur)] then
            ances = util.phash(ancestor[util.phash(cur)])
        end
        dbg_print(ances .. " D: " .. data.dir .. " until: " .. util.phash(cur) .. "/" .. util.phash(data.mark))
		table.insert(path, data)
		-- dbg_print(dir)
		cur = ancestor[util.phash(cur)]
	end
	-- dbg_print(">>>>>>>>>>>>>END<<<<<<<<<<<<<<<")

	dbg_print(" -----------------A*")
    res = {}
    for v = math.max(1, #path - 5),#path,1 do
        table.insert(res, path[v])
    end
    return res
end

return util
