-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\CircularQueue.lua

local CircularQueue = {}

CircularQueue.__index = CircularQueue

function CircularQueue.new(size, fixedCapacity)
	size = size or 128

	if type(size) ~= "number" or size <= 0 then
		error("队列大小必须是正数")
	end

	local instance = {
		counter = 0,
		count = 0,
		tail = 1,
		head = 1,
		data = {},
		capacity = size,
		fixedCapacity = fixedCapacity == true
	}

	setmetatable(instance, CircularQueue)

	return instance
end

function CircularQueue:InitUniqueCache()
	self.unique = {}
end

function CircularQueue:pop()
	if self.count == 0 then
		return nil
	end

	local value = self.data[self.head]

	self.data[self.head] = nil
	self.head = self.head % self.capacity + 1
	self.count = self.count - 1

	return value
end

function CircularQueue:peek()
	if self.count == 0 then
		return nil
	end

	return self.data[self.head]
end

function CircularQueue:push(value)
	if self.count >= self.capacity then
		if self.fixedCapacity then
			local evicted = self.data[self.tail]

			self.data[self.tail] = value
			self.tail = self.tail % self.capacity + 1
			self.head = self.tail

			return true, evicted
		end

		local newCapacity = math.max(math.floor(self.capacity * 1.5), self.capacity + 1)
		local newData = {}
		local idx = self.head

		for i = 1, self.count do
			newData[i] = self.data[idx]
			idx = idx % self.capacity + 1
		end

		self.data = newData
		self.capacity = newCapacity
		self.head = 1
		self.tail = self.count + 1
	end

	self.data[self.tail] = value
	self.tail = self.tail % self.capacity + 1
	self.count = self.count + 1

	return true
end

function CircularQueue:push_unique(value)
	for i = self.head, self.head + self.count - 1 do
		local index = (i - 1) % self.capacity + 1

		if self.data[index] == value then
			return true
		end
	end

	return self:push(value)
end

function CircularQueue:push_unique2(value)
	if self.unique[value] then
		return
	end

	return self:push(value)
end

function CircularQueue:size()
	return self.count
end

function CircularQueue:isEmpty()
	return self.count == 0
end

function CircularQueue:getCapacity()
	return self.capacity
end

function CircularQueue:getCounter()
	return self.counter
end

function CircularQueue:clear()
	self.head = 1
	self.tail = 1
	self.count = 0
	self.counter = 0

	if self.unique then
		table.clear(self.unique)
	end
end

function CircularQueue:toString()
	local items = {}
	local idx = self.head

	for i = 1, self.count do
		table.insert(items, tostring(self.data[idx]))

		idx = idx % self.capacity + 1
	end

	return string.format("CircularQueue[count=%d, capacity=%d, counter=%d, items=[%s]]", self.count, self.capacity, self.counter, table.concat(items, ", "))
end

return CircularQueue
