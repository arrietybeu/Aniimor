-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Queue.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("Queue")
local Queue = class.Class("Queue")

function Queue:ctor(capacity)
	self.capacity = capacity
	self.queue = {}
	self.size_ = 0
	self.head = -1
	self.rear = -1
end

function Queue:enQueue(element)
	if self.size_ == 0 then
		self.head = 0
		self.rear = 1
		self.size_ = 1
		self.queue[self.rear] = element
	else
		if self.size_ == self.capacity then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("Error: capacity is full.", debug.traceback())
			end

			return false
		end

		self.rear = self.rear + 1

		if self.rear > self.capacity then
			self.rear = 1
		end

		self.queue[self.rear] = element
		self.size_ = self.size_ + 1
	end

	return true
end

function Queue:deQueue()
	if self:isEmpty() then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("Error: The Queue is empty.")
		end

		return
	end

	self.size_ = self.size_ - 1
	self.head = self.head + 1

	if self.head > self.capacity then
		self.head = 1
	end

	local value = self.queue[self.head]

	return value
end

function Queue:getFirst()
	if self:isEmpty() then
		return
	end

	local head = self.head + 1

	if head > self.capacity then
		head = 1
	end

	local value = self.queue[head]

	return value
end

function Queue:getLast()
	if self:isEmpty() then
		return
	end

	return self.queue[self.rear]
end

function Queue:clear()
	self.queue = nil
	self.queue = {}
	self.size_ = 0
	self.head = -1
	self.rear = -1
end

function Queue:isFull()
	return self.size_ >= self.capacity
end

function Queue:isEmpty()
	if self:size() == 0 then
		return true
	end

	return false
end

function Queue:size()
	return self.size_
end

return Queue
