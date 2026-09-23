-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\LinkedQueue.lua

local Class = require("Core.Framework.Class")
local LinkedQueue = Class.LightClass("LinkedQueue")

function LinkedQueue:ctor(nodePool)
	self.head = nil
	self.tail = nil
	self.size = 0
	self.nodePool = nodePool
end

function LinkedQueue:destroy()
	self:clear()

	self.nodePool = nil
end

function LinkedQueue:pushBack(value)
	local node = self.nodePool:get(value)

	node.value = value
	node._owner = self

	if not self.tail then
		self.head = node
		self.tail = node
	else
		node.prev = self.tail
		self.tail.next = node
		self.tail = node
	end

	self.size = self.size + 1

	return node
end

function LinkedQueue:pushFront(value)
	local node = self.nodePool:get(value)

	node.value = value
	node._owner = self

	if not self.head then
		self.head = node
		self.tail = node
	else
		node.next = self.head
		self.head.prev = node
		self.head = node
	end

	self.size = self.size + 1

	return node
end

function LinkedQueue:_removeNode(node)
	local prev = node.prev
	local next = node.next

	if prev then
		prev.next = next
	else
		self.head = next
	end

	if next then
		next.prev = prev
	else
		self.tail = prev
	end

	node.prev = nil
	node.next = nil
	node._owner = nil
	self.size = self.size - 1

	self.nodePool:release(node)
end

function LinkedQueue:removeNode(node)
	if not node or node._owner ~= self then
		return false
	end

	self:_removeNode(node)

	return true
end

function LinkedQueue:popFront()
	if not self.head then
		return nil
	end

	local node = self.head
	local value = node.value

	self:_removeNode(node)

	return value
end

function LinkedQueue:popBack()
	if not self.tail then
		return nil
	end

	local node = self.tail
	local value = node.value

	self:_removeNode(node)

	return value
end

function LinkedQueue:clear()
	local node = self.head

	while node do
		local nextNode = node.next

		self.nodePool:release(node)

		node = nextNode
	end

	self.head = nil
	self.tail = nil
	self.size = 0
end

function LinkedQueue:isEmpty()
	return self.size == 0
end

function LinkedQueue:peekFront()
	return self.head and self.head.value or nil
end

function LinkedQueue:peekBack()
	return self.tail and self.tail.value or nil
end

function LinkedQueue:popFrontBatch(count)
	local result = {}
	local actualCount = math.min(count, self.size)

	for _ = 1, actualCount do
		local value = self:popFront()

		if not value then
			break
		end

		result[#result + 1] = value
	end

	return result
end

return LinkedQueue
