-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\IndexedHeap.lua

local Class = require("Core.Framework.Class")
local IndexedHeap = Class.LightClass("IndexedHeap")

function IndexedHeap:ctor(compareFunc)
	assert(type(compareFunc) == "function", "compareFunc required")

	self.size = 0
	self.heap = {}
	self.indexMap = {}
	self.compare = compareFunc
end

local function swap(self, i, j)
	local heap = self.heap
	local map = self.indexMap
	local n1, n2 = heap[i], heap[j]

	heap[i], heap[j] = n2, n1
	map[n1.key] = j
	map[n2.key] = i
end

local function siftUp(self, index)
	local heap = self.heap
	local compare = self.compare

	while index > 1 do
		local parent = math.floor(index / 2)

		if compare(heap[parent], heap[index]) then
			break
		end

		swap(self, parent, index)

		index = parent
	end
end

local function siftDown(self, index)
	local size = self.size
	local heap = self.heap
	local compare = self.compare

	while true do
		local left = index * 2
		local right = left + 1
		local best = index

		if left <= size and compare(heap[left], heap[best]) then
			best = left
		end

		if right <= size and compare(heap[right], heap[best]) then
			best = right
		end

		if best == index then
			break
		end

		swap(self, index, best)

		index = best
	end
end

function IndexedHeap:isEmpty()
	return self.size == 0
end

function IndexedHeap:getSize()
	return self.size
end

function IndexedHeap:contains(key)
	return self.indexMap[key] ~= nil
end

function IndexedHeap:peek()
	return self.heap[1]
end

function IndexedHeap:push(key, value)
	assert(key ~= nil, "key cannot be nil")
	assert(not self.indexMap[key], "duplicated key")

	self.size = self.size + 1

	local index = self.size
	local node = {
		key = key,
		value = value
	}

	self.heap[index] = node
	self.indexMap[key] = index

	siftUp(self, index)
end

function IndexedHeap:remove(key)
	local index = self.indexMap[key]

	if not index then
		return nil
	end

	local heap = self.heap
	local removedNode = heap[index]
	local lastIndex = self.size

	if index ~= lastIndex then
		swap(self, index, lastIndex)

		heap[lastIndex] = nil
		self.indexMap[key] = nil
		self.size = lastIndex - 1

		siftDown(self, index)
		siftUp(self, index)
	else
		heap[lastIndex] = nil
		self.indexMap[key] = nil
		self.size = lastIndex - 1
	end

	return removedNode
end

function IndexedHeap:update(key, newValue)
	local index = self.indexMap[key]

	if not index then
		return false
	end

	self.heap[index].value = newValue

	siftDown(self, index)
	siftUp(self, index)

	return true
end

function IndexedHeap:pop()
	if self.size == 0 then
		return nil
	end

	local heap = self.heap
	local root = heap[1]
	local lastIndex = self.size

	if lastIndex == 1 then
		heap[1] = nil
		self.indexMap[root.key] = nil
		self.size = 0
	else
		local lastNode = heap[lastIndex]

		heap[1] = lastNode
		self.indexMap[lastNode.key] = 1
		heap[lastIndex] = nil
		self.indexMap[root.key] = nil
		self.size = lastIndex - 1

		siftDown(self, 1)
	end

	return root
end

return IndexedHeap
