-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\UniqueQueue.lua

local UniqueQueue = {}

UniqueQueue.__index = UniqueQueue

function UniqueQueue.new()
	return setmetatable({
		list = {},
		hash = {}
	}, UniqueQueue)
end

function UniqueQueue:enqueue(val)
	if self.hash[val] then
		return
	end

	table.insert(self.list, val)

	self.hash[val] = true
end

function UniqueQueue:remove(val)
	local idx = self.hash[val]

	if not idx then
		return
	end

	self.hash[val] = nil

	local list = self.list

	for i = #list, 1, -1 do
		if list[i] == val then
			table.remove(list, i)
		end
	end
end

function UniqueQueue:dequeue()
	local val = table.remove(self.list, 1)

	if val then
		self.hash[val] = nil
	end

	return val
end

UniqueQueue.push = UniqueQueue.enqueue
UniqueQueue.pop = UniqueQueue.dequeue

function UniqueQueue:clear()
	table.clear(self.hash)
	table.clearArray(self.list)
end

function UniqueQueue:count()
	return #self.list
end

return UniqueQueue
