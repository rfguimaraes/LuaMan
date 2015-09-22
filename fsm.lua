-- Based on suggestion http://lua-users.org/wiki/FiniteStateMachine
-- by Luiz Henrique De Figueiredo (http://lua-users.org/wiki/LuizHenriqueDeFigueiredo)

classer = require "classer"

local fsm = {}

fsm.FSM = classer.ncls()

function fsm.FSM:_init(initial, trans_table)
	self.trans = {}
	self.current = initial

	for _,v in ipairs(self.trans) do
		local old, event, new, action = v[1], v[2], v[3], v[4]
		if self.trans[old] == nil then
			self.trans[old] = {}
		end
		self.trans[old][event] = {new = new, action = action}
	end
end

function fsm.FSM:trigger(event)
    local t = self.trans[state][event]
    if t then
    	if t.action then
    		t.action(state, event, t.new)
    	end
    	self.current = t.new
    	return true
    else
    	return false
    end
end

function fsm.FSM:goTo(state)
	for _,v in ipairs(self.trans) do
		local old, _, new, _ = v[1], v[2], v[3], v[4]
		if state == old or state == new then
			self.current =state
			return true
		end
	end
	return false
end

return fsm