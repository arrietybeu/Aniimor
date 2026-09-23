-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceLeylineFlowerComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local EventConst = require("Const.EventConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local LeylineFlowerPresentUtils = require("Utils.LeylineFlowerPresentUtils")
local ClientSpaceLeylineFlowerComponent = Class.Component("ClientSpaceLeylineFlowerComponent")
local PENDING_PRESENTATION_TTL = 8
local RAINBOW_PET_EFFECT_WAIT_PRESENT = 0.5

function ClientSpaceLeylineFlowerComponent:ctor()
	self.logger = LoggerManager.getLogger("ClientSpaceLeylineFlowerComponent")
	self.hasStarted = false
	self.leylineFlowerMap = {}
	self.rainbowPetEffects = {}
	self.rainbowPetTemplateIds = {}
	self.pendingRainbowPetPresentations = {}
	self.pendingRainbowPetEffects = {}
	self.rainbowPetEffectWaitTimers = {}
	self.rainbowPetSpawnPresented = {}
end

function ClientSpaceLeylineFlowerComponent:start()
	self.hasStarted = true

	if not self.onRainbowPetSpawnPresentedEvent then
		self.onRainbowPetSpawnPresentedEvent = CallbackHandler(self, "onRainbowPetSpawnPresented")

		pg.global.eventEmitter:addEventListener(EventConst.ON_LEYLINE_RAINBOW_PET_SPAWN_PRESENTED, self.onRainbowPetSpawnPresentedEvent)
	end

	if not self.rainbowPetPosFlags then
		return
	end

	for staticId, pointCountMap in pairs(self.rainbowPetPosFlags) do
		self:refreshRainbowPetEffects(staticId, pointCountMap, true)
	end
end

function ClientSpaceLeylineFlowerComponent:addLeylineFlowerMap(entityId, leylineFlowerId)
	self.leylineFlowerMap[leylineFlowerId] = entityId
end

function ClientSpaceLeylineFlowerComponent:removeLeylineFlowerMap(leylineFlowerId)
	self.leylineFlowerMap[leylineFlowerId] = nil
end

function ClientSpaceLeylineFlowerComponent:on_rainbowPetPosFlags_entry_added(staticId, pointCountMap)
	self:refreshRainbowPetEffects(staticId, pointCountMap, not self.hasStarted)
end

function ClientSpaceLeylineFlowerComponent:on_rainbowPetPosFlags_entry_deleted(staticId, pointCountMap)
	self:stopRainbowPetEffect(staticId)

	self.pendingRainbowPetPresentations[staticId] = nil
	self.pendingRainbowPetEffects[staticId] = nil
	self.rainbowPetSpawnPresented[staticId] = nil

	self:cancelRainbowPetEffectWait(staticId)

	for pointId in pairs(pointCountMap or EMPTY_TABLE) do
		self:refreshRainbowPetMapMark(pointId)
		self:clearRainbowPetTracking(pointId)
	end
end

function ClientSpaceLeylineFlowerComponent:on_rainbowPetPosFlags_point_added(pointId, count, staticId)
	self:refreshRainbowPetEffect(staticId, pointId, count, not self.hasStarted)
end

function ClientSpaceLeylineFlowerComponent:on_rainbowPetPosFlags_point_deleted(pointId, count, staticId)
	self:stopRainbowPetEffect(staticId, pointId)
	self:dropPendingPresentationIfNoPoint(staticId)
	self:refreshRainbowPetMapMark(pointId)
	self:clearRainbowPetTracking(pointId)
end

function ClientSpaceLeylineFlowerComponent:on_rainbowPetPosFlags_point_changed(oldCount, newCount, staticId, pointId)
	oldCount = oldCount or 0
	newCount = newCount or 0

	self:refreshRainbowPetMapMark(pointId)

	if oldCount < newCount then
		self:activateRainbowPetPoint(staticId, pointId, not self.hasStarted, not self.hasStarted)
	elseif newCount <= 0 then
		self:stopRainbowPetEffect(staticId, pointId)
		self:dropPendingPresentationIfNoPoint(staticId)
		self:clearRainbowPetTracking(pointId)
	end
end

function ClientSpaceLeylineFlowerComponent:isRainbowPetEffectEnabled(count)
	return count and count > 0
end

function ClientSpaceLeylineFlowerComponent:hasEnabledRainbowPetPoint(staticId)
	local pointCountMap = self.rainbowPetPosFlags and self.rainbowPetPosFlags[staticId]

	if not pointCountMap then
		return false
	end

	for _, count in pairs(pointCountMap) do
		if self:isRainbowPetEffectEnabled(count) then
			return true
		end
	end

	return false
end

function ClientSpaceLeylineFlowerComponent:dropPendingPresentationIfNoPoint(staticId)
	if self:hasEnabledRainbowPetPoint(staticId) then
		return
	end

	self.pendingRainbowPetEffects[staticId] = nil
	self.pendingRainbowPetPresentations[staticId] = nil
	self.rainbowPetSpawnPresented[staticId] = nil

	self:cancelRainbowPetEffectWait(staticId)
end

function ClientSpaceLeylineFlowerComponent:refreshRainbowPetEffects(staticId, pointCountMap, isRestore)
	local enabledPointIds = {}
	local shouldSkipPresentation = isRestore

	if pointCountMap then
		for pointId, count in pairs(pointCountMap) do
			self:refreshRainbowPetMapMark(pointId)

			if self:isRainbowPetEffectEnabled(count) then
				enabledPointIds[pointId] = true

				if self:activateRainbowPetPoint(staticId, pointId, shouldSkipPresentation, isRestore) then
					shouldSkipPresentation = true
				end
			end
		end
	end

	local effectData = self.rainbowPetEffects[staticId]

	if not effectData then
		return
	end

	local removedPointIds = {}

	for pointId in pairs(effectData.pointEffectIds) do
		if not enabledPointIds[pointId] then
			removedPointIds[#removedPointIds + 1] = pointId
		end
	end

	for _, pointId in ipairs(removedPointIds) do
		self:stopRainbowPetEffect(staticId, pointId)
	end
end

function ClientSpaceLeylineFlowerComponent:refreshRainbowPetEffect(staticId, pointId, count, isRestore)
	self:refreshRainbowPetMapMark(pointId)

	if self:isRainbowPetEffectEnabled(count) then
		self:activateRainbowPetPoint(staticId, pointId, isRestore, isRestore)
	else
		self:stopRainbowPetEffect(staticId, pointId)
	end
end

function ClientSpaceLeylineFlowerComponent:activateRainbowPetPoint(staticId, pointId, skipPresentation, isRestore)
	local rainbowPetPos = LeylineFlowerUtils.getRainbowPetSpawnPosition(self.sceneId, pointId, self.id)

	if not rainbowPetPos then
		return false
	end

	local presented = false

	if not skipPresentation and self:isLocalSpaceOwner() then
		if not self.rainbowPetSpawnPresented[staticId] then
			self:holdRainbowPetEffect(staticId, not self:hasPendingRainbowPetPresentation(staticId) and RAINBOW_PET_EFFECT_WAIT_PRESENT or nil)
		end

		presented = self:presentRainbowPetSpawn(staticId, pointId, rainbowPetPos)
	end

	self:createRainbowPetEffect(staticId, pointId, rainbowPetPos, isRestore)

	return presented
end

function ClientSpaceLeylineFlowerComponent:holdRainbowPetEffect(staticId, waitPresentSeconds)
	if not staticId then
		return
	end

	self.pendingRainbowPetEffects[staticId] = true

	if not waitPresentSeconds then
		self:cancelRainbowPetEffectWait(staticId)

		return
	end

	if self.rainbowPetEffectWaitTimers[staticId] then
		return
	end

	self.rainbowPetEffectWaitTimers[staticId] = self:addTimer(waitPresentSeconds, function()
		self.rainbowPetEffectWaitTimers[staticId] = nil

		if self:hasPendingRainbowPetPresentation(staticId) then
			return
		end

		self:releaseDeferredRainbowPetEffects(staticId)
	end)
end

function ClientSpaceLeylineFlowerComponent:cancelRainbowPetEffectWait(staticId)
	local timerId = staticId and self.rainbowPetEffectWaitTimers[staticId]

	if not timerId then
		return
	end

	self.rainbowPetEffectWaitTimers[staticId] = nil

	self:removeTimer(timerId)
end

function ClientSpaceLeylineFlowerComponent:createRainbowPetEffect(staticId, pointId, rainbowPetPos, isRestore)
	if self.pendingRainbowPetEffects[staticId] then
		return
	end

	local effectData = self.rainbowPetEffects[staticId]

	if not effectData then
		effectData = {
			pointEffectIds = {},
			flowerBurstEffects = {}
		}
		self.rainbowPetEffects[staticId] = effectData
	end

	local petSpawnEffectKey = SysConfigData.RAINBOW_PET_SPAWN_EFFECT

	if petSpawnEffectKey and not effectData.pointEffectIds[pointId] then
		local petEffectId = LeylineFlowerUtils.playEffect(rainbowPetPos, petSpawnEffectKey)

		if petEffectId and petEffectId ~= 0 then
			effectData.pointEffectIds[pointId] = petEffectId
		end
	end

	if not isRestore then
		self:playFlowerBurstEffect(staticId, effectData)
	end
end

function ClientSpaceLeylineFlowerComponent:playFlowerBurstEffect(staticId, effectData)
	local flowerEffectKey = SysConfigData.RAINBOW_FLOWER_EFFECT
	local flowerPos = LeylineFlowerUtils.getFlowerPositionByStaticId(staticId, self.sceneId, self.id)

	if not flowerPos then
		return
	end

	if flowerEffectKey then
		local burstEffectId = LeylineFlowerUtils.playOneShotEffect(flowerPos, flowerEffectKey)

		if burstEffectId then
			local duration = LeylineFlowerUtils.getEffectDuration(flowerEffectKey)

			if duration then
				effectData.flowerBurstEffects[burstEffectId] = self:addTimer(duration, function()
					local data = self.rainbowPetEffects[staticId]

					if data then
						data.flowerBurstEffects[burstEffectId] = nil
					end
				end)
			else
				effectData.flowerBurstEffects[burstEffectId] = true
			end
		end
	end

	local audioPos = Vector3(flowerPos[1], flowerPos[2], flowerPos[3])

	pg.game.audio:playSoundAtPos(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowPillar, audioPos)
end

function ClientSpaceLeylineFlowerComponent:stopFlowerBurstEffects(effectData)
	if not effectData.flowerBurstEffects then
		return
	end

	for burstEffectId, timerId in pairs(effectData.flowerBurstEffects) do
		if timerId ~= true then
			self:removeTimer(timerId)
		end

		LeylineFlowerUtils.stopEffect(burstEffectId)
	end

	effectData.flowerBurstEffects = {}
end

function ClientSpaceLeylineFlowerComponent:onRainbowPetSpawnPresented(data)
	local staticId = data and data.staticId

	if not staticId then
		return
	end

	self.rainbowPetSpawnPresented[staticId] = true

	self:releaseDeferredRainbowPetEffects(staticId)
end

function ClientSpaceLeylineFlowerComponent:releaseDeferredRainbowPetEffects(staticId)
	if not staticId or not self.pendingRainbowPetEffects[staticId] then
		return
	end

	self.pendingRainbowPetEffects[staticId] = nil

	self:cancelRainbowPetEffectWait(staticId)

	local pointCountMap = self.rainbowPetPosFlags and self.rainbowPetPosFlags[staticId]

	for pointId, count in pairs(pointCountMap or EMPTY_TABLE) do
		if self:isRainbowPetEffectEnabled(count) then
			local rainbowPetPos = LeylineFlowerUtils.getRainbowPetSpawnPosition(self.sceneId, pointId, self.id)

			if rainbowPetPos then
				self:createRainbowPetEffect(staticId, pointId, rainbowPetPos)
			end
		end
	end
end

function ClientSpaceLeylineFlowerComponent:stopRainbowPetEffect(staticId, pointId)
	LeylineFlowerUtils.cancelCameraFocus(staticId, pointId)

	local data = self.rainbowPetEffects[staticId]

	if not data then
		return
	end

	if pointId ~= nil then
		local petEffectId = data.pointEffectIds[pointId]

		if petEffectId then
			LeylineFlowerUtils.stopEffect(petEffectId)

			data.pointEffectIds[pointId] = nil
		end
	else
		for _, petEffectId in pairs(data.pointEffectIds) do
			LeylineFlowerUtils.stopEffect(petEffectId)
		end

		data.pointEffectIds = {}
	end

	if next(data.pointEffectIds) then
		return
	end

	self:stopFlowerBurstEffects(data)

	self.rainbowPetEffects[staticId] = nil
end

function ClientSpaceLeylineFlowerComponent:isLocalSpaceOwner()
	return pg.me and self.ownerPlayerId == pg.me.id
end

function ClientSpaceLeylineFlowerComponent:presentRainbowPetSpawn(staticId, pointId, rainbowPetPos)
	if not self:isLocalSpaceOwner() then
		return false
	end

	local pending = self:takePendingPresentation(staticId)

	if not pending then
		return false
	end

	local petTemplateId = pending.petTemplateId or self:getRainbowPetTemplateId(staticId, pointId)

	if not petTemplateId or petTemplateId <= 0 then
		return false
	end

	local presented = LeylineFlowerPresentUtils.present(LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowPetSpawn, {
		duration = 2,
		staticId = staticId,
		pointId = pointId,
		targetPosition = rainbowPetPos,
		sceneId = self.sceneId,
		spaceId = self.id,
		petTemplateId = petTemplateId,
		blockId = LeylineFlowerUtils.getBlockIdByStaticId(self.sceneId, staticId) or 0,
		rainbowSnapshot = pending.rainbowSnapshot,
		luckyEventId = pending.luckyEventId
	})

	if presented then
		self.pendingRainbowPetPresentations[staticId] = nil

		self:holdRainbowPetEffect(staticId)
	end

	return presented
end

function ClientSpaceLeylineFlowerComponent:setPendingRainbowPetPresentation(staticId, data)
	if not staticId or not data then
		return
	end

	data.pendingTime = Time.realSecondCache
	data.readyTime = data.pendingTime + math.max(0, tonumber(data.holdSeconds) or 0)
	self.pendingRainbowPetPresentations[staticId] = data
end

function ClientSpaceLeylineFlowerComponent:hasPendingRainbowPetPresentation(staticId)
	local pending = self.pendingRainbowPetPresentations[staticId]

	if not pending then
		return false
	end

	return not self:isPendingPresentationExpired(staticId, pending)
end

function ClientSpaceLeylineFlowerComponent:isPendingPresentationExpired(staticId, pending)
	local age = Time.realSecondCache - (pending.readyTime or pending.pendingTime or 0)

	if age <= PENDING_PRESENTATION_TTL then
		return false
	end

	self.pendingRainbowPetPresentations[staticId] = nil

	self.logger:error("@leylineflower pending rainbow pet presentation expired, staticId:", staticId, "age:", age)
	self:releaseDeferredRainbowPetEffects(staticId)

	return true
end

function ClientSpaceLeylineFlowerComponent:takePendingPresentation(staticId)
	local pending = self.pendingRainbowPetPresentations[staticId]

	if not pending then
		return nil
	end

	if self:isPendingPresentationExpired(staticId, pending) then
		return nil
	end

	if Time.realSecondCache < (pending.readyTime or 0) then
		return nil
	end

	return pending
end

function ClientSpaceLeylineFlowerComponent:tryPresentRainbowPetSpawn(staticId)
	local pointCountMap = self.rainbowPetPosFlags and self.rainbowPetPosFlags[staticId]

	if not pointCountMap or not self:takePendingPresentation(staticId) then
		return false
	end

	for pointId, count in pairs(pointCountMap) do
		if self:isRainbowPetEffectEnabled(count) then
			local rainbowPetPos = LeylineFlowerUtils.getRainbowPetSpawnPosition(self.sceneId, pointId, self.id)

			if rainbowPetPos and self:presentRainbowPetSpawn(staticId, pointId, rainbowPetPos) then
				return true
			end
		end
	end

	return false
end

function ClientSpaceLeylineFlowerComponent:getRainbowPetTemplateId(staticId, pointId)
	local activityData = LeylineFlowerUtils.getActivityRainbowPetData(staticId)
	local syncedTemplateId = self.rainbowPetTemplateIds[staticId]

	if syncedTemplateId and syncedTemplateId > 0 then
		return syncedTemplateId
	end

	if activityData and activityData.specialRainbowPetPoint == pointId then
		return activityData.specialRainbowPetWorld
	end

	local normalData = LeylineFlowerUtils.getRainbowPetData(staticId)

	if normalData and normalData.rainbowPetPoint == pointId then
		return normalData.rainbowPetWorld
	end

	return activityData and activityData.specialRainbowPetWorld or normalData and normalData.rainbowPetWorld
end

function ClientSpaceLeylineFlowerComponent:setRainbowPetTemplateId(staticId, petTemplateId)
	if not staticId or not petTemplateId or petTemplateId <= 0 then
		return
	end

	self.rainbowPetTemplateIds[staticId] = petTemplateId

	local pointCountMap = self.rainbowPetPosFlags and self.rainbowPetPosFlags[staticId]

	for pointId, count in pairs(pointCountMap or EMPTY_TABLE) do
		if count and count > 0 then
			self:refreshRainbowPetMapMark(pointId)
		end
	end
end

function ClientSpaceLeylineFlowerComponent:getRainbowPetTemplateIdByPointId(pointId)
	for staticId, pointCountMap in pairs(self.rainbowPetPosFlags or EMPTY_TABLE) do
		if pointCountMap[pointId] and pointCountMap[pointId] > 0 then
			return self:getRainbowPetTemplateId(staticId, pointId), staticId
		end
	end
end

function ClientSpaceLeylineFlowerComponent:refreshRainbowPetMapMark(pointId)
	if pointId and pg.global and pg.global.eventEmitter then
		pg.global.eventEmitter:emit(EventConst.ON_MAP_MARK_UPDATED, {
			type = "addOrUpdate",
			id = pointId
		})
	end
end

function ClientSpaceLeylineFlowerComponent:clearRainbowPetTracking(pointId)
	if pg.game and pg.game.map then
		pg.game.map:manualUnTraceQuestMark(pointId)
	end
end

function ClientSpaceLeylineFlowerComponent:clearRainbowPetEffects()
	local staticIds = {}

	for staticId in pairs(self.rainbowPetEffects) do
		staticIds[#staticIds + 1] = staticId
	end

	for _, staticId in ipairs(staticIds) do
		self:stopRainbowPetEffect(staticId)
	end
end

function ClientSpaceLeylineFlowerComponent:destroy()
	if self.onRainbowPetSpawnPresentedEvent then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_LEYLINE_RAINBOW_PET_SPAWN_PRESENTED, self.onRainbowPetSpawnPresentedEvent)

		self.onRainbowPetSpawnPresentedEvent = nil
	end

	LeylineFlowerPresentUtils.clear()

	for staticId in pairs(self.rainbowPetEffectWaitTimers) do
		self:removeTimer(self.rainbowPetEffectWaitTimers[staticId])
	end

	self.rainbowPetEffectWaitTimers = {}
	self.pendingRainbowPetPresentations = {}
	self.pendingRainbowPetEffects = {}
	self.rainbowPetSpawnPresented = {}

	self:clearRainbowPetEffects()
	LeylineFlowerUtils.stopAllCameraFocus()
end

return ClientSpaceLeylineFlowerComponent
