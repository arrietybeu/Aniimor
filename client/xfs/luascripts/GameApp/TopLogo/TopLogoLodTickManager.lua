-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\TopLogo\\TopLogoLodTickManager.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoLodTickManager")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local CallbackGuard = require("Core.Common.CallbackGuard")
local Utils = require("Common.Utils.Utils")
local TopLogoConst = require("Const.TopLogoConst")
local SampleUtils = SampleUtils
local TopLogoLodTickManager = Class.LightClass("TopLogoLodTickManager")
local MaxCreateCountPerLodTick = 10
local IS_MOBILE = IS_MOBILE
local USE_MOBILE_SCHEDULE = IS_MOBILE or TopLogoConst.IS_SIMULATE_MOBILE
local FAR_TOPLOGO_CLEANUP_INTERVAL = USE_MOBILE_SCHEDULE and 2 or 1
local defaultDelayConfig = USE_MOBILE_SCHEDULE and {
	{
		40,
		30,
		0
	},
	{
		0.6,
		0.3,
		0.1
	}
} or {
	{
		40,
		30,
		0
	},
	{
		0.3,
		0.2,
		0.1
	}
}
local LIMIT_COUNT_RATIO = USE_MOBILE_SCHEDULE and 0.34 or 0.5
local _arrayDelayConfigCache = {}
local PENDING_OPRATION_TYPE = {
	Add = 1,
	Remove = 2
}
local DIST_CYCLE_SECOND = 0.5
local DIST_MAX_ELAPSED_PER_TICK = 0.1
local DIST_MAX_SCAN_RATIO = DIST_MAX_ELAPSED_PER_TICK / DIST_CYCLE_SECOND
local WEAK_VALUE_MAP_METATABLE = {
	__mode = "v"
}

local function updateEntityDelta(self, entity, delayConfig)
	local fixedInterval = entity.topLogoLodTickInterval

	if fixedInterval and fixedInterval > 0 then
		self.entityDeltaMap[entity.id] = fixedInterval

		return
	end

	if pg.playerPos == nil or not delayConfig then
		return
	end

	local distance = math.floor(entity:getPlayerDistance(15))
	local delta = delayConfig[distance]

	if not delta and self:needFarTopLogoCleanupTick(entity) then
		delta = FAR_TOPLOGO_CLEANUP_INTERVAL
	end

	if not delta and entity._forceShowBubble then
		delta = FAR_TOPLOGO_CLEANUP_INTERVAL
	end

	self.entityDeltaMap[entity.id] = delta
end

function TopLogoLodTickManager:m_resetRunData()
	rawset(self, "_lodTickHandler", nil)

	self.lodCallbackId = 0
	self.lodTickLastTime = {}
	self.lodConfigs = {}
	self.lodConfigsEntId2IndexMap = {}
	self.lodConfigsIndex2EntIdMap = {}
	self.lodHandler = {}
	self.entMap = setmetatable({}, WEAK_VALUE_MAP_METATABLE)
	self.entityCount = 0
	self.curTickCount = 0
	self.nextTickStartIndex = 1
	self.lodIsInTick = false
	self.loadPendingOprations = {}
	self.entityDeltaMap = {}
	self.distCursor = 0
	self.distScanCredit = 0
	self.distLastUpdateTime = Time.getTickSecond()
end

function TopLogoLodTickManager:m_initDistanceRunData(now)
	self.entityDeltaMap = {}
	self.distCursor = 0
	self.distScanCredit = 0
	self.distLastUpdateTime = now - DIST_MAX_ELAPSED_PER_TICK
end

function TopLogoLodTickManager:m_initEntityMap()
	local entMap = setmetatable({}, WEAK_VALUE_MAP_METATABLE)

	for _, entityId in ipairs(self.lodConfigsIndex2EntIdMap or EMPTY_TABLE) do
		local entity = pg.getEntity(entityId)

		if entity then
			entMap[entityId] = entity
		end
	end

	self.entMap = entMap
end

function TopLogoLodTickManager:ctor()
	self:m_resetRunData()

	self.callbackGuard = CallbackGuard(self)
end

function TopLogoLodTickManager:Clear()
	self:m_resetRunData()

	if self.callbackGuard then
		self.callbackGuard:clear()
	end

	self.callbackGuard = nil
end

function TopLogoLodTickManager:GenerateLodConfig(originConfig)
	if _arrayDelayConfigCache[originConfig] then
		return _arrayDelayConfigCache[originConfig]
	end

	local disArr = originConfig[1]
	local secs = originConfig[2]
	local lastIndex = math.floor(disArr[1])
	local dis2Interval = {}

	for i = 2, #disArr do
		local curIndex = math.floor(disArr[i]) + 1
		local sec = secs[i]

		for index = curIndex, lastIndex do
			dis2Interval[index] = sec
		end

		lastIndex = curIndex - 1
	end

	dis2Interval[0] = secs[#secs]
	_arrayDelayConfigCache[originConfig] = dis2Interval

	return dis2Interval
end

function TopLogoLodTickManager:addLODRepeatTimer(entity, handler, delayConfig)
	if delayConfig == nil then
		delayConfig = defaultDelayConfig
	end

	if not entity or not entity.id then
		return
	end

	if self.lodIsInTick then
		table.insert(self.loadPendingOprations, {
			type = PENDING_OPRATION_TYPE.Add,
			entity = entity,
			handler = handler,
			delayConfig = delayConfig
		})

		return
	end

	self:m_addLODTimerDirect(entity, handler, delayConfig)
end

function TopLogoLodTickManager:m_addLODTimerDirect(entity, handler, delayConfig)
	local now = Time.getTickSecond()

	if self.entityDeltaMap == nil then
		self:m_initDistanceRunData(now)
	end

	if self.entMap == nil then
		self:m_initEntityMap()
	end

	if self.lodConfigsEntId2IndexMap[entity.id] then
		self:m_removeLODTimerDirect(entity)
	end

	if self.entityCount <= 0 then
		self.distCursor = 0
		self.distScanCredit = 0
		self.distLastUpdateTime = now
	end

	local lodConfig = self:GenerateLodConfig(delayConfig)

	self.lodConfigs[entity.id] = lodConfig
	self.lodTickLastTime[entity.id] = now
	self.lodHandler[entity.id] = handler
	self.entityCount = self.entityCount + 1

	local newIndex = #self.lodConfigsIndex2EntIdMap + 1

	table.insert(self.lodConfigsIndex2EntIdMap, entity.id)

	self.lodConfigsEntId2IndexMap[entity.id] = newIndex
	self.entMap[entity.id] = entity

	updateEntityDelta(self, entity, lodConfig)
end

function TopLogoLodTickManager:removeLODTimer(entity)
	if not entity or not entity.id then
		return
	end

	if self.lodIsInTick then
		table.insert(self.loadPendingOprations, {
			type = PENDING_OPRATION_TYPE.Remove,
			entity = entity
		})

		return
	end

	self:m_removeLODTimerDirect(entity)
end

function TopLogoLodTickManager:m_removeLODTimerDirect(entity)
	if self.entityDeltaMap == nil then
		self:m_initDistanceRunData(Time.getTickSecond())
	end

	if self.entMap == nil then
		self:m_initEntityMap()
	end

	local entId = entity.id
	local index = self.lodConfigsEntId2IndexMap[entId]
	local hasRegistered = index or self.lodConfigs[entId] or self.lodHandler[entId] or self.lodTickLastTime[entId]

	if not hasRegistered then
		self.entMap[entId] = nil

		return
	end

	local lastIndex = #self.lodConfigsIndex2EntIdMap

	if index then
		if index < lastIndex then
			local lastId = self.lodConfigsIndex2EntIdMap[lastIndex]

			self.lodConfigsIndex2EntIdMap[index] = lastId
			self.lodConfigsEntId2IndexMap[lastId] = index
		end

		table.remove(self.lodConfigsIndex2EntIdMap)

		self.lodConfigsEntId2IndexMap[entId] = nil
	end

	self.lodConfigs[entId] = nil
	self.lodTickLastTime[entId] = nil
	self.lodHandler[entId] = nil
	self.entityDeltaMap[entId] = nil
	self.entMap[entId] = nil
	self.entityCount = math.max(0, self.entityCount - 1)
end

function TopLogoLodTickManager:RemoveTimer(timerid)
	self.callbackGuard:removeTimerCallbackByTimerId(timerid)
end

function TopLogoLodTickManager:m_getNormalizedTickStartIndex()
	local entityCount = #(self.lodConfigsIndex2EntIdMap or {})

	if entityCount <= 0 then
		self.nextTickStartIndex = 1

		return 1, entityCount
	end

	local startIndex = self.nextTickStartIndex or 1

	if startIndex < 1 or entityCount < startIndex then
		startIndex = 1
	end

	self.nextTickStartIndex = startIndex

	return startIndex, entityCount
end

function TopLogoLodTickManager:m_advanceTickStartIndex(entityCount, startIndex, advanceBy)
	if entityCount <= 0 then
		self.nextTickStartIndex = 1

		return
	end

	advanceBy = advanceBy or 1

	local nextIndex = startIndex + advanceBy

	if entityCount < nextIndex then
		nextIndex = nextIndex - entityCount
	end

	self.nextTickStartIndex = nextIndex
end

function TopLogoLodTickManager:m_lodTickOpenUI()
	if self.entityCount <= 0 then
		return
	end

	local now = Time.getTickSecond()

	if self.entityDeltaMap == nil then
		self:m_initDistanceRunData(now)
	end

	if self.entMap == nil then
		self:m_initEntityMap()
	end

	self.curTickCount = self.curTickCount + 1

	local tickEnt
	local entMap = self.entMap

	self.lodIsInTick = true

	self:m_updateDistanceSegment(now)

	if pg.me == self or pg.playerPos == nil then
		if self.curTickCount % 3 == 0 then
			local lodHandler = self.lodHandler

			for _, entityId in ipairs(self.lodConfigsIndex2EntIdMap) do
				local handler = lodHandler[entityId]

				tickEnt = entMap[entityId]

				if tickEnt and tickEnt.id == entityId and not tickEnt.destroyed then
					handler(tickEnt, false)
				elseif tickEnt then
					entMap[entityId] = nil
				end
			end
		end
	else
		local lodHandler = self.lodHandler
		local lodTickLastTime = self.lodTickLastTime
		local sampleOn = SampleUtils.sampleOn()

		if sampleOn then
			SampleUtils.beginSample("TopLogoLodTickManager_Devlop")
		end

		local startIndex, entityCount = self:m_getNormalizedTickStartIndex()
		local limitCount = math.max(1, math.ceil(entityCount * LIMIT_COUNT_RATIO))
		local scannedCount = 0
		local costCount = 0
		local indexMap = self.lodConfigsIndex2EntIdMap
		local entityDeltaMap = self.entityDeltaMap

		for offset = 0, limitCount - 1 do
			local curIndex = startIndex + offset

			if entityCount < curIndex then
				curIndex = curIndex - entityCount
			end

			scannedCount = scannedCount + 1

			local entityId = indexMap[curIndex]

			if entityId then
				local delta = entityDeltaMap[entityId]

				if delta and delta < now - lodTickLastTime[entityId] then
					tickEnt = entMap[entityId]

					if tickEnt and tickEnt.id == entityId and not tickEnt.destroyed then
						local handler = lodHandler[entityId]

						lodTickLastTime[entityId] = now
						costCount = costCount + (handler(tickEnt, costCount < MaxCreateCountPerLodTick) or 0)

						if costCount >= MaxCreateCountPerLodTick then
							break
						end
					elseif tickEnt then
						entMap[entityId] = nil
					end
				end
			end
		end

		self:m_advanceTickStartIndex(entityCount, startIndex, scannedCount)

		if sampleOn then
			SampleUtils.endSample()
		end
	end

	self.lodIsInTick = false

	self:m_processPendingOprations()
end

function TopLogoLodTickManager:m_lodTickHideUI()
	return 0
end

TopLogoLodTickManager._lodTickHandler = TopLogoLodTickManager.m_lodTickOpenUI

function TopLogoLodTickManager:setUIPaused(paused)
	local handler = paused == true and self.m_lodTickHideUI or nil

	if rawget(self, "_lodTickHandler") == handler then
		return
	end

	rawset(self, "_lodTickHandler", handler)
end

function TopLogoLodTickManager:lodTick()
	return self._lodTickHandler(self)
end

local operationsToProcess = {}

function TopLogoLodTickManager:m_processPendingOprations()
	if #self.loadPendingOprations == 0 then
		return
	end

	local originalIsInLodTick = self.lodIsInTick

	self.lodIsInTick = false

	table.clearArray(operationsToProcess)

	for i, operation in ipairs(self.loadPendingOprations) do
		operationsToProcess[i] = operation
	end

	table.clearArray(self.loadPendingOprations)

	for _, operation in ipairs(operationsToProcess) do
		if operation.type == PENDING_OPRATION_TYPE.Add then
			self:m_addLODTimerDirect(operation.entity, operation.handler, operation.delayConfig)
		elseif operation.type == PENDING_OPRATION_TYPE.Remove then
			self:m_removeLODTimerDirect(operation.entity)
		end
	end

	self.lodIsInTick = originalIsInLodTick
end

function TopLogoLodTickManager:needFarTopLogoCleanupTick(tickEnt)
	if tickEnt.topLogoCreated then
		return true
	end

	if tickEnt._forceShowBubble then
		return true
	end

	local item = tickEnt.topLogoItem

	return item and item.checkCreate and item:checkCreate()
end

function TopLogoLodTickManager:m_updateDistanceSegment(now)
	local lastUpdateTime = self.distLastUpdateTime

	self.distLastUpdateTime = now

	local entityCount = #self.lodConfigsIndex2EntIdMap

	if entityCount <= 0 or pg.playerPos == nil then
		self.distScanCredit = 0
		self.distCursor = 0

		return
	end

	local elapsed = now - lastUpdateTime

	if elapsed < 0 then
		self.distScanCredit = 0

		return
	end

	if elapsed == 0 then
		return
	end

	elapsed = math.min(elapsed, DIST_MAX_ELAPSED_PER_TICK)

	local scanCredit = self.distScanCredit + elapsed * entityCount / DIST_CYCLE_SECOND
	local scanCount = math.floor(scanCredit)

	if scanCount <= 0 then
		self.distScanCredit = scanCredit

		return
	end

	local scanLimit = math.min(math.ceil(entityCount * DIST_MAX_SCAN_RATIO), entityCount)

	scanCount = math.min(scanCount, scanLimit)
	self.distScanCredit = scanCredit - scanCount

	local indexMap = self.lodConfigsIndex2EntIdMap
	local lodConfigs = self.lodConfigs
	local entMap = self.entMap
	local cursor = self.distCursor % entityCount

	for offset = 0, scanCount - 1 do
		local index = (cursor + offset) % entityCount + 1
		local entityId = indexMap[index]

		if entityId then
			local tickEnt = entMap[entityId]

			if tickEnt and tickEnt.id == entityId and not tickEnt.destroyed then
				local delayConfig = lodConfigs[entityId]

				if delayConfig then
					updateEntityDelta(self, tickEnt, delayConfig)
				end
			elseif tickEnt then
				entMap[entityId] = nil
			end
		end
	end

	self.distCursor = (cursor + scanCount) % entityCount
end

return TopLogoLodTickManager
