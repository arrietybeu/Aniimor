-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Timer\\TimerWheel.lua

local CommonRepo = require("Core.Common.CommonRepo")
local class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local TimerWheel = class.Class("TimerWheel")
local MILLISECONDS_OF_ONE_SECOND = 1000

function TimerWheel:ctor(interval, callback, slotNum)
	assert(interval > 0)
	assert(type(callback) == "function")

	self.slotNum = slotNum

	if self.slotNum == nil or self.slotNum <= 0 then
		self.slotNum = 60
	end

	self.interval = interval
	self.callback = callback
	self.slots = {}
	self.index = {}
	self.current = 0
	self.waitNum = 0
	self.nextId = 0
	self._triggers = {}
end

function TimerWheel:getEventId()
	self.nextId = self.nextId + 1

	return self.nextId
end

function TimerWheel:setTimer()
	if self.timer == nil then
		if not self._tickCb then
			function self._tickCb()
				self:tick()
			end
		end

		self.timer = TimerManager.addRepeatTimer(self.interval, self._tickCb)
	end
end

function TimerWheel:clrTimer()
	if self.timer ~= nil then
		TimerManager.removeTimer(self.timer)

		self.timer = nil
	end
end

function TimerWheel:destroy()
	self:clrTimer()

	self.slots = {}
	self.index = {}
end

function TimerWheel:tick()
	self.current = (self.current + 1) % self.slotNum

	local triggers = self._triggers
	local triggerCount = 0
	local events = self.slots[self.current]

	if events ~= nil and #events ~= 0 then
		local curr = 1
		local size = #events

		while curr <= size do
			if events[curr].circle == 0 then
				self.index[events[curr].id] = nil

				local data = events[curr].data

				events[curr] = events[size]
				events[size] = nil
				size = size - 1
				self.waitNum = self.waitNum - 1
				triggerCount = triggerCount + 1
				triggers[triggerCount] = data
			else
				events[curr].circle = events[curr].circle - 1
				curr = curr + 1
			end
		end

		self.slots[self.current] = events
	end

	local callback = self.callback

	for i = 1, triggerCount do
		local status, err = xpcall(callback, debug.traceback, triggers[i])

		if not status then
			local ex = err or "unknown error occurred"

			self.slots[self.current] = {}

			CommonRepo.exceptionFunc(ex)
		end

		triggers[i] = nil
	end

	if self.waitNum == 0 then
		self:clrTimer()
	end
end

function TimerWheel:push(timeout, data, id)
	if self.waitNum == 0 then
		self:setTimer()
	end

	self.waitNum = self.waitNum + 1

	if id == nil then
		id = self:getEventId()
	end

	local delay = math.floor(timeout * MILLISECONDS_OF_ONE_SECOND / (self.interval * MILLISECONDS_OF_ONE_SECOND))
	local circle = math.floor(math.abs(delay / self.slotNum))
	local slot = (self.current + 1 + delay) % self.slotNum

	self.index[id] = slot

	if self.slots[slot] then
		local slotEvents = self.slots[slot]

		slotEvents[#slotEvents + 1] = {
			id = id,
			data = data,
			circle = circle
		}
	else
		self.slots[slot] = {
			{
				id = id,
				data = data,
				circle = circle
			}
		}
	end

	return id
end

function TimerWheel:remove(id)
	local slot = self.index[id]

	if slot == nil then
		return
	end

	local events = self.slots[slot]

	if events == nil or #events == 0 then
		return
	end

	local index = 1
	local size = #events

	while index <= size do
		if events[index].id == id then
			events[index] = events[size]
			events[size] = nil
			size = size - 1
			self.waitNum = self.waitNum - 1
		else
			index = index + 1
		end
	end

	self.slots[slot] = events
	self.index[id] = nil

	if self.waitNum == 0 then
		self:clrTimer()
	end
end

return TimerWheel
