-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\AITick\\AITickModule.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("AITickModule")
local Time = require("Core.Common.Time")
local AITickModule = Class.LightClass("AITickModule")
local _frameSplitLimit = {
	0.1,
	0.05,
	0.033,
	0.025,
	0.02
}

function AITickModule:ctor()
	self.lastDeltaTime = {
		0,
		0,
		0,
		0,
		0
	}
	self.lastDeltaTimeCount = 5
	self.tickEnts = {}
	self.tickLodMax = AiConst.LOD.VeryLow
	self.tickIntervalMax = AiConst.TICK_INTERVAL.Normal
	self.tickMaxCount = self.tickLodMax * self.tickIntervalMax * #_frameSplitLimit
	self.tickCountCurrent = 0
	self.tickCounter = 0
	self.tickQueueKey = {}
	self.tickQueue = {}
	self.tickIndex = {}
	self.tickEntCountLimit = 0
	self.tickEntCounter = 0
	self.splitFrameCountCurrent = 1

	self:_initTickQueue()

	self.subTickQueue = {}
	self.subTickTime = {}
	self.subTickDeltaTime = {}
	self.subTickIndex = 0
	self.subTickQueueTickEntCountLimit = 5
	self.subTickQueueTickEntCounter = 0
	self.tickEntThisFrame = {}
	self.entShouldTickCount = {}
end

function AITickModule:onTick(deltaTime)
	if Utils.checkClient() and SampleUtils.sampleOn() then
		SampleUtils.beginSample("AITickModule.onTick")
	end

	for i = self.lastDeltaTimeCount - 1, 1, -1 do
		self.lastDeltaTime[i + 1] = self.lastDeltaTime[i]
	end

	self.lastDeltaTime[1] = deltaTime
	self.tickEntCounter = self.tickEntCounter + self.tickEntCountLimit

	local queue, queueCount, currentIndex, ent

	for _, key in ipairs(self.tickQueueKey) do
		queue = self.tickQueue[key]
		queueCount = #queue

		if queueCount > 0 then
			currentIndex = self.tickIndex[key]

			if self.tickCounter % (key * self.splitFrameCountCurrent) == 0 then
				currentIndex = 0
			end

			while currentIndex < queueCount do
				currentIndex = currentIndex + 1
				ent = queue[currentIndex]

				if ent and ent.AI.valid then
					ent:aiTick()
				end

				self.tickEntCounter = self.tickEntCounter - 1

				if self.tickEntCounter <= 0 then
					break
				end
			end

			self.tickIndex[key] = currentIndex

			if self.tickEntCounter <= 0 then
				break
			end
		end
	end

	local currentTime = Time.realSecondCache

	self.subTickQueueTickEntCounter = self.subTickQueueTickEntCountLimit

	if self.subTickIndex >= #self.subTickQueue then
		self.subTickIndex = 0
	end

	while self.subTickIndex < #self.subTickQueue do
		self.subTickIndex = self.subTickIndex + 1
		ent = self.subTickQueue[self.subTickIndex]

		if ent and ent.AI.valid and currentTime > self.subTickTime[ent] then
			self.subTickTime[ent] = currentTime + self.subTickDeltaTime[ent]

			ent:aiTick()

			self.subTickQueueTickEntCounter = self.subTickQueueTickEntCounter - 1

			if self.subTickQueueTickEntCounter <= 0 then
				break
			end
		end
	end

	self.tickCounter = self.tickCounter + 1

	if self.tickCounter >= self.tickCountCurrent then
		self.tickCounter = 0

		self:_calcTickQueue()
	end

	if Utils.checkClient() and SampleUtils.sampleOn() then
		SampleUtils.endSample()
	end
end

function AITickModule:onDestroy()
	return
end

function AITickModule:_initTickQueue()
	for _, interval in pairs(AiConst.TICK_INTERVAL) do
		for _, lod in pairs(AiConst.LOD) do
			local temp = interval * lod

			if not table.contains(self.tickQueueKey, temp) then
				self.tickQueueKey[#self.tickQueueKey + 1] = temp
			end

			self.tickQueue[temp] = {}
			self.tickIndex[temp] = 0
		end
	end

	table.sort(self.tickQueueKey)
end

function AITickModule:_resetTickQueue()
	for _, interval in pairs(AiConst.TICK_INTERVAL) do
		for _, lod in pairs(AiConst.LOD) do
			local temp = interval * lod

			table.clearArray(self.tickQueue[temp])

			self.tickIndex[temp] = 0
		end
	end
end

function AITickModule:_calcSplitFrameCount()
	local deltaTime = 0

	for i = 1, self.lastDeltaTimeCount do
		deltaTime = deltaTime + self.lastDeltaTime[i]
	end

	deltaTime = deltaTime / self.lastDeltaTimeCount

	for i = 1, #_frameSplitLimit do
		if deltaTime >= _frameSplitLimit[i] then
			return i
		end
	end

	return #_frameSplitLimit
end

function AITickModule:_calcTickQueue()
	self:_resetTickQueue()
	self:_resetSubTickQueue()

	self.splitFrameCountCurrent = self:_calcSplitFrameCount()
	self.tickCountCurrent = self.tickLodMax * self.tickIntervalMax * self.splitFrameCountCurrent

	for _, ent in pairs(self.tickEnts) do
		local tickInterval = ent.AI.tickInterval * (ent:checkIgnoreAILod() and 1 or AIUtils.getAITickCount(ent))

		table.insert(self.tickQueue[tickInterval], ent)
	end

	local totalTickCount = 0

	for key, queue in pairs(self.tickQueue) do
		local count = #queue

		if count > 0 then
			totalTickCount = totalTickCount + count * (self.tickLodMax * self.tickIntervalMax / key)
		end
	end

	self.tickEntCounter = 0
	self.tickEntCountLimit = totalTickCount / self.tickCountCurrent
end

function AITickModule:_resetSubTickQueue()
	table.clearArray(self.subTickQueue)
	table.clear(self.subTickTime)
	table.clear(self.subTickDeltaTime)

	self.subTickIndex = 0
end

function AITickModule:registerAgent(ent)
	local actorId = ent.actorId or 0

	ent.AI.valid = true
	self.tickEnts[actorId] = ent
	self.subTickQueue[#self.subTickQueue + 1] = ent
	self.subTickTime[ent] = 0
	self.subTickDeltaTime[ent] = ent.AI.tickInterval * (ent:checkIgnoreAILod() and 1 or AIUtils.getAITickCount(ent)) * 0.1
end

function AITickModule:unregisterAgent(ent)
	local actorId = ent.actorId or 0

	ent.AI.valid = false
	self.tickEnts[actorId] = nil
end

return AITickModule
