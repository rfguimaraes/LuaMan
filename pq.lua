classer = require "classer"

-- min-heap

local pq = {}

-- Node = {item, priority, left, right}

pq.PQ = classer.ncls()
pq.Node = classer.ncls()

function pq.Node:_init(item, priority)
	self.item = item
	self.priority = priority
end

function pq.Node:before(other)
	return other.priority >= self.priority
end

function pq.PQ:_init()
	self.elements = {}
end

function pq.PQ:fixUp(k)
	while k > 1 and self.elements[k]:before(self.elements[k//2]) do
		self.elements[k//2], self.elements[k] = self.elements[k], self.elements[k//2]
		k = k//2
	end
end

function pq.PQ:fixDown(k)
	while 2*k <= #self.elements do
		local c = 2*k
		if c < #self.elements and self.elements[c + 1]:before(self.elements[c]) then
			c = c + 1
		end
		if self.elements[k]:before(self.elements[c]) then
			break
		end
		self.elements[c], self.elements[k] = self.elements[k], self.elements[c]
		k = c
	end
end

function pq.PQ:insert(item, priority)
	local new = pq.Node(item, priority)
	table.insert(self.elements, new)
	self:fixUp(#self.elements)
end

function pq.PQ:getNext()
	local res = self.elements[1]
	table.remove(self.elements, 1)
	local last = self.elements[#self.elements]
	table.remove(self.elements, #self.elements)
	table.insert(self.elements, last)
	self:fixDown(1)
	return res
end


return pq