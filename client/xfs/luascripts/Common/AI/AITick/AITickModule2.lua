-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\AITick\\AITickModule2.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local AiConst = require("Common.Const.AiConst")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local BUCKET_ENTRY_STRIDE = 2
local pg = pg
local AITickModule2Perception = require("Common.AI.AITick.AITickModule2Perception")
local AITickModule2 = Class.LightClass("AITickModule2")

local function isEntityUnavailable(entity)
	return entity == nil or entity.destroyed or entity.isDestroyed
end

function AITickModule2:getEntity(entityInfo)
	local currentEntity = pg.getEntityByActorId(entityInfo.actorId)

	if isEntityUnavailable(currentEntity) then
		return nil
	end

	return currentEntity
end

function AITickModule2:getValidBucketIndex(index)
	return (index - 1) % self.bucketCount + 1
end

function AITickModule2:addToHead(entityInfo)
	if self.currentLinkListHead == nil then
		self.currentLinkListHead = entityInfo
		self.currentLinkListTail = entityInfo
	else
		entityInfo.next = self.currentLinkListHead
		self.currentLinkListHead.prev = entityInfo
		self.currentLinkListHead = entityInfo
	end

	self.currentLinkListCount = self.currentLinkListCount + 1
end

function AITickModule2:addToTail(entityInfo)
	if self.currentLinkListHead == nil then
		self.currentLinkListHead = entityInfo
		self.currentLinkListTail = entityInfo
	else
		entityInfo.prev = self.currentLinkListTail
		self.currentLinkListTail.next = entityInfo
		self.currentLinkListTail = entityInfo
	end

	self.currentLinkListCount = self.currentLinkListCount + 1
end

function AITickModule2:removeHead()
	local entityInfo = self.currentLinkListHead

	if entityInfo.next ~= nil then
		entityInfo.next.prev = nil
	end

	self.currentLinkListHead = entityInfo.next

	if self.currentLinkListTail == entityInfo then
		self.currentLinkListTail = nil
	end

	entityInfo.prev = nil
	entityInfo.next = nil
	self.currentLinkListCount = self.currentLinkListCount - 1
end

function AITickModule2:removeEntityInfo(entityInfo)
	if entityInfo.prev ~= nil then
		entityInfo.prev.next = entityInfo.next
	end

	if entityInfo.next ~= nil then
		entityInfo.next.prev = entityInfo.prev
	end

	if self.currentLinkListHead == entityInfo then
		self.currentLinkListHead = entityInfo.next
	end

	if self.currentLinkListTail == entityInfo then
		self.currentLinkListTail = entityInfo.prev
	end

	entityInfo.prev = nil
	entityInfo.next = nil
	self.currentLinkListCount = self.currentLinkListCount - 1
end

function AITickModule2:releaseEntityInfo(entityInfo)
	self.tickEntsInfo[entityInfo.actorId] = nil

	TablePool.returnTable(entityInfo)
end

function AITickModule2:debugTestLimit()
	local entCount = 0
	local entTickCount = 0
	local limitTickCount = (self.bucketCount - 1) * self.limitCount

	for _, entityInfo in pairs(self.tickEntsInfo) do
		entCount = entCount + 1
		entTickCount = entTickCount + (self.bucketCount - 1) / entityInfo.interval
	end

	return entCount, entTickCount, limitTickCount
end

function AITickModule2:setLimitParam(minLimitCount, maxLimitCount)
	self.minLimitCount = minLimitCount
	self.limitCount = minLimitCount
	self.maxLimitCount = maxLimitCount
end

function AITickModule2:ctor()
	if Utils.checkClient() then
		self.minTimePerFrame = 0.01
		self.normalizeTimePerFrame = 0.02
		self.frameCountPerTick = 4
		self.minLimitCount = 1
		self.limitCount = 1
		self.maxLimitCount = 2
		self.limitTime = 600
	else
		self.minTimePerFrame = 0.05
		self.normalizeTimePerFrame = 0.1
		self.frameCountPerTick = 1
		self.minLimitCount = 80
		self.limitCount = 80
		self.maxLimitCount = 80
		self.limitTime = 5000
	end

	self.bucketCount = AiConst.TICK_INTERVAL.Normal * AiConst.LOD.VeryLow * self.frameCountPerTick * 2 + 1
	self.bucketIndex = 1
	self.buckets = ListPool.getList(3)

	for i = 1, self.bucketCount do
		self.buckets[i] = ListPool.getList(3)
	end

	self.tickEntsInfo = TablePool.getTable()
	self.toAddList = ListPool.getList(3)
	self.nextRegistrationGeneration = 0

	AITickModule2Perception.initPerceptionTick(self)

	self.currentLinkListHead = nil
	self.currentLinkListTail = nil
	self.currentLinkListCount = 0
	self.refreshIntervalTime = 1
	self.lastPeriodTime = 0
	self.intervalMultiplier = 1
end

function AITickModule2:appendBucketEntry(bucketIndex, entityInfo)
	local bucket = self.buckets[bucketIndex]

	bucket[#bucket + 1] = entityInfo.actorId
	bucket[#bucket + 1] = entityInfo.registrationGeneration
end

function AITickModule2:scheduleNextCycle(entityInfo)
	local interval = entityInfo.interval
	local btIndex = self:getValidBucketIndex(self.bucketIndex + interval)

	entityInfo.btBucketIndex = btIndex

	self:appendBucketEntry(btIndex, entityInfo)
	AITickModule2Perception.schedulePerceptionTick(self, entityInfo, interval)
end

function AITickModule2:preProcessLinkList()
	local entityInfo, actorId

	for index = 1, #self.toAddList do
		entityInfo = self.toAddList[index]

		if entityInfo.valid then
			if entityInfo.loadPriority then
				self:addToHead(entityInfo)
			else
				self:addToTail(entityInfo)
			end
		else
			self:releaseEntityInfo(entityInfo)
		end

		self.toAddList[index] = nil
	end

	local bucketIndex = self.bucketIndex
	local bucket = self.buckets[bucketIndex]
	local bucketLength = #bucket
	local generation

	for index = 1, bucketLength, BUCKET_ENTRY_STRIDE do
		actorId = bucket[index]
		generation = bucket[index + 1]
		entityInfo = self.tickEntsInfo[actorId]

		if entityInfo and entityInfo.registrationGeneration == generation then
			if entityInfo.valid then
				if not AITickModule2Perception.processPerceptionBucketEntry(self, entityInfo, bucketIndex) and entityInfo.btBucketIndex == bucketIndex then
					self:addToTail(entityInfo)

					entityInfo.btBucketIndex = nil
				end
			else
				self:releaseEntityInfo(entityInfo)
			end
		end

		bucket[index] = nil
		bucket[index + 1] = nil
	end
end

function AITickModule2:onTick(deltaTime)
	if Utils.checkClient() and SampleUtils.sampleOn() then
		SampleUtils.beginSample("AITickModule2.onTick")
	end

	local currentTime = Time.getTickSecond()

	if self.bucketIndex == 1 then
		if self.lastPeriodTime > 0 then
			local timePerFrame = math.min(math.max((currentTime - self.lastPeriodTime) / self.bucketCount, self.minTimePerFrame), self.normalizeTimePerFrame)

			self.intervalMultiplier = self.normalizeTimePerFrame / timePerFrame
		end

		if self.currentLinkListCount > self.limitCount and self.limitCount < self.maxLimitCount then
			self.limitCount = self.limitCount + 1
		end

		if self.currentLinkListCount < self.limitCount and self.limitCount > self.minLimitCount then
			self.limitCount = self.limitCount - 1
		end

		self.lastPeriodTime = currentTime
	end

	self:preProcessLinkList()

	local tickCount = 0
	local startTime = Time.getMicrosecond()
	local entity
	local entityInfo = self.currentLinkListHead

	while entityInfo ~= nil do
		entity = self:getEntity(entityInfo)

		if entityInfo.valid and entity then
			AITickModule2Perception.attemptPerceptionBeforeAITick(self, entityInfo)
			entity:aiTick()
			AITickModule2Perception.finishPerceptionCycle(entityInfo)

			tickCount = tickCount + 1

			self:removeHead(entityInfo)

			if currentTime > entityInfo.refreshIntervalNextTime then
				entityInfo.interval = math.floor(entity.AI.tickInterval * (entity:checkIgnoreAILod() and 1 or AIUtils.getAITickCount(entity)) * self.frameCountPerTick * self.intervalMultiplier)
				entityInfo.refreshIntervalNextTime = currentTime + self.refreshIntervalTime
			end

			self:scheduleNextCycle(entityInfo)
		else
			self:removeHead(entityInfo)
			self:releaseEntityInfo(entityInfo)
		end

		entityInfo = self.currentLinkListHead

		if self.limitCount > 0 and tickCount >= self.limitCount then
			break
		end

		if self.limitTime > 0 and Time.getMicrosecond() - startTime > self.limitTime then
			break
		end
	end

	AITickModule2Perception.processPerceptionReady(self, startTime)

	self.bucketIndex = self:getValidBucketIndex(self.bucketIndex + 1)

	if Utils.checkClient() and SampleUtils.sampleOn() then
		SampleUtils.endSample()
	end
end

function AITickModule2:onDestroy()
	for i = 1, self.bucketCount do
		ListPool.returnList(self.buckets[i], 3)
	end

	ListPool.returnList(self.buckets, 3)

	for _, entInfo in pairs(self.tickEntsInfo) do
		TablePool.returnTable(entInfo)
	end

	TablePool.returnTable(self.tickEntsInfo)
	ListPool.returnList(self.toAddList, 3)
	AITickModule2Perception.destroyPerceptionTick(self)

	self.currentLinkListHead = nil
	self.currentLinkListTail = nil
end

function AITickModule2:createEntityInfo(entity)
	local actorId = entity.actorId or 0
	local tickLevel = AIUtils.getAITickCount(entity)
	local ignoreAILod = entity:checkIgnoreAILod()
	local loadPriority = ignoreAILod or tickLevel == AiConst.LOD.High
	local entityInfo = TablePool.getTable()

	self.nextRegistrationGeneration = self.nextRegistrationGeneration + 1
	entityInfo.actorId = actorId
	entityInfo.valid = true
	entityInfo.prev = nil
	entityInfo.next = nil
	entityInfo.loadPriority = loadPriority
	entityInfo.interval = entity.AI.tickInterval * (ignoreAILod and 1 or tickLevel) * self.frameCountPerTick
	entityInfo.refreshIntervalNextTime = Time.getTickSecond() + self.refreshIntervalTime
	entityInfo.registrationGeneration = self.nextRegistrationGeneration
	entityInfo.btBucketIndex = nil

	AITickModule2Perception.initPerceptionEntityInfo(entityInfo)

	self.tickEntsInfo[actorId] = entityInfo
	self.toAddList[#self.toAddList + 1] = entityInfo

	return entityInfo
end

function AITickModule2:registerAgent(entity)
	local actorId = entity.actorId or 0
	local entityInfo = self.tickEntsInfo[actorId]

	if entityInfo then
		entityInfo.valid = true

		return
	end

	self:createEntityInfo(entity)
end

function AITickModule2:unregisterAgent(entity)
	local actorId = entity.actorId or 0
	local entityInfo = self.tickEntsInfo[actorId]
	local currentEntity = pg.getEntityByActorId(actorId)

	if entityInfo and (currentEntity == nil or currentEntity == entity) then
		entityInfo.valid = false
	end
end

return AITickModule2
