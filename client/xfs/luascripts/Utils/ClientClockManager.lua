-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientClockManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local EntityManager = require("Core.Common.EntityManager")
local phonestcore = require("phonestcore")
local logger = LoggerManager.getLogger("ClientClockManager")

local function fireTimeCmp(info1, info2)
	return info1[2] > info2[2]
end

local ClientClockManager = Class.OldLightClass("ClientClockManager", nil, true)

function ClientClockManager:ctor()
	self.clockEntityidsMap = {}
	self.clockNextFireTimeSorted = {}
	self.latelyTimer = nil

	self:init()
end

function ClientClockManager:init()
	return
end

function ClientClockManager:regClock(clockId, entityId)
	if self.clockEntityidsMap[clockId] == nil then
		self.clockEntityidsMap[clockId] = {
			entityId
		}

		self:addClock(clockId)
	else
		for _, value in ipairs(self.clockEntityidsMap[clockId]) do
			if value == entityId then
				return
			end
		end

		local curLen = #self.clockEntityidsMap[clockId]

		self.clockEntityidsMap[clockId][curLen + 1] = entityId

		if curLen > 999 and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("MONITOR_LOG: regClock MAX for clockId=%s", clockId)
		end
	end
end

function ClientClockManager:unregClock(clockId, entityId)
	self:removeEntityIds(clockId, {
		entityId
	})
end

function ClientClockManager:addClock(clockId)
	local nextFireTime = phonestcore.getNextFireTime(clockId, Time.secondCache)

	if nextFireTime == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("addClock but nextFireTime error for clockId=%s", clockId)
		end

		return
	end

	self.clockNextFireTimeSorted[#self.clockNextFireTimeSorted + 1] = {
		clockId,
		nextFireTime
	}

	table.sort(self.clockNextFireTimeSorted, fireTimeCmp)
	self:startLatelyTimer()
end

function ClientClockManager:stopLatelyTimer()
	if self.latelyTimer ~= nil then
		TimerManager.removeTimer(self.latelyTimer)

		self.latelyTimer = nil
	end
end

function ClientClockManager:startLatelyTimer()
	self:stopLatelyTimer()

	if #self.clockNextFireTimeSorted > 0 then
		local data = self.clockNextFireTimeSorted[#self.clockNextFireTimeSorted]
		local now = Time.secondCache
		local diff = data[2] - now

		if diff <= 0 then
			diff = 0.1
		end

		self.latelyTimer = TimerManager.addTimer(diff, function()
			self.latelyTimer = nil

			self:clockCallback(data[1], data[2])
		end)
	end
end

function ClientClockManager:clockCallback(clockId, lastUpdateTs)
	local data = table.remove(self.clockNextFireTimeSorted)

	if data[1] ~= clockId and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("clockCallback but not match for clockId=%s, data=(%s, %s), lastUpdateTs=%s", clockId, data[1], data[2], lastUpdateTs)
	end

	data[2] = phonestcore.getNextFireTime(data[1], Time.secondCache)
	self.clockNextFireTimeSorted[#self.clockNextFireTimeSorted + 1] = data

	table.sort(self.clockNextFireTimeSorted, fireTimeCmp)
	self:startLatelyTimer()

	local needRemove = {}
	local entityIds = self.clockEntityidsMap[clockId]

	if entityIds == nil then
		return
	end

	for _, entityId in ipairs(entityIds) do
		local ent = EntityManager.getEntity(entityId)

		if ent == nil then
			needRemove[#needRemove + 1] = entityId
		else
			self:dispatchClockCallback(ent, clockId, lastUpdateTs)
		end
	end

	self:removeEntityIds(clockId, needRemove)
end

function ClientClockManager:dispatchClockCallback(ent, clockId, lastUpdateTs)
	ent:clockCallback(clockId)
end

function ClientClockManager:removeEntityIds(clockId, needRemove)
	local entityIds = self.clockEntityidsMap[clockId]

	for _, value in ipairs(needRemove) do
		for index, entityId in ipairs(entityIds) do
			if value == entityId then
				entityIds[index] = entityIds[#entityIds]
				entityIds[#entityIds] = nil

				break
			end
		end
	end
end

function ClientClockManager:recalAllNextFireTime()
	for _, value in ipairs(self.clockNextFireTimeSorted) do
		value[2] = phonestcore.getNextFireTime(value[1], Time.secondCache)
	end

	self:startLatelyTimer()
end

return ClientClockManager
