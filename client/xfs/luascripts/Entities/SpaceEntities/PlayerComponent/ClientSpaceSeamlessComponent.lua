-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientSpaceSeamlessComponent.lua

local Class = require("Core.Framework.Class")
local ClientSpaceSeamlessComponent = Class.Component("ClientSpaceSeamlessComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientSpaceSeamlessComponent")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneData = require("Data.scene_data")
local RegionSyncData = require("Data.region_sync_config_data")
local Utils = require("Common.Utils.Utils")
local NEAR_TIP_CD = 5
local TICK_INTERVAL = 0.5
local CHECK_IN_AREA_CD = 0.5
local Vector2 = Vector2
local Vector3 = Vector3
local math = math

function ClientSpaceSeamlessComponent:ctor()
	self.retryCount = 0
	self.__LastTickTime = 0
	self.waitTickEndTime = 0
	self.__enableCheck = true
	self.mappingRegionNearTipTime = {}
end

function ClientSpaceSeamlessComponent:start()
	if pg.global.scene and pg.global.scene:isSceneValid() then
		self:seamless_startSeamlessCheck()
	end
end

function ClientSpaceSeamlessComponent:EVENT_EnterScene()
	if not self.space then
		return
	end

	if not pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	pg.global.ui.hudV2:showSeamlessVFX()

	local curSceneId = self.space.sceneId
	local sData = SceneData[curSceneId]

	if sData and sData.enterSeamless then
		local content = pg.getGameString(sData.enterSeamless)

		pg.global.showBubbleMessageRaw(content, 2)
	end

	pg.game.seamless:seam_sys_enterSeamless(self)
end

function ClientSpaceSeamlessComponent:EVENT_LeaveScene()
	if not pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	pg.global.ui.hudV2:showSeamlessVFX()

	local lastSceneId = pg.game.seamless:seam_sys_getLastSeamlessId()
	local sData = lastSceneId and SceneData[lastSceneId]

	if sData and sData.exitSeamless then
		local content = pg.getGameString(sData.exitSeamless)

		pg.global.showBubbleMessageRaw(content, 2)
	end

	pg.game.seamless:seam_sys_exitSeamless()
end

function ClientSpaceSeamlessComponent:seamless_startSeamlessCheck()
	if self.tickTimer then
		self:removeTimer(self.tickTimer)
	end

	self.tickTimer = self:addRepeatTimer(0.1, function()
		self:seamless_tick()
	end)
end

function ClientSpaceSeamlessComponent:seamless_endSeamlessCheck()
	if self.tickTimer then
		self:removeTimer(self.tickTimer)
	end

	self.tickTimer = nil
	self.mappingRegionExitAreaId = nil
	self.mappingRegionExitTime = nil
end

function ClientSpaceSeamlessComponent:seamless_tick(deltaTime)
	self:seamless_checkTipTiming()
	self:seamless_checkMappingRegionExit()
	self:seamless_checkInAreaTiming()
end

function ClientSpaceSeamlessComponent:seamless_setEnableCheck(enable)
	self.__enableCheck = enable
	self.waitTickEndTime = self.waitTickEndTime + 1
end

function ClientSpaceSeamlessComponent:seamless_checkTipTiming()
	if Time.realSecondCache - self.__LastTickTime < TICK_INTERVAL or self:seamless_InSeamless() then
		return
	end

	self.__LastTickTime = Time.realSecondCache

	local minDistance = math.huge
	local minAreaId, minAreaData
	local selfPosition = self:getPosition()

	for areaId, regionData in pairs(RegionSyncData) do
		local _, areaData = pg.game.seamless:seam_sys_getMappingRegionConfig(areaId)
		local nearRegion = regionData.nearRegion

		if areaData and Utils.isTable(nearRegion) then
			local distance = Vector3.Distance(areaData.position, selfPosition)

			if distance < minDistance and distance < (nearRegion[1] or 30) then
				minDistance = distance
				minAreaId = areaId
				minAreaData = areaData
			end
		end
	end

	if minAreaId == nil then
		pg.game.seamless:seam_sys_setLastTipArea(nil)

		return
	end

	if minAreaId == pg.game.seamless:seam_sys_getLastTipArea() or pg.game.seamless:seam_sys_inSeamlessArea(selfPosition, minAreaData) then
		return
	end

	local lastNearTipTime = self.mappingRegionNearTipTime[minAreaId]

	if lastNearTipTime and Time.realSecondCache - lastNearTipTime < NEAR_TIP_CD then
		return
	end

	pg.game.seamless:seam_sys_setLastTipArea(minAreaId)

	self.mappingRegionNearTipTime[minAreaId] = Time.realSecondCache

	self:seamless_showMappingRegionTip(RegionSyncData[minAreaId].nearRegion[2])
end

function ClientSpaceSeamlessComponent:seamless_checkMappingRegionExit()
	if self.mappingRegionExitTime and Time.realSecondCache >= self.mappingRegionExitTime then
		local areaId = self.mappingRegionExitAreaId

		self.mappingRegionExitAreaId = nil
		self.mappingRegionExitTime = nil

		self:seamless_finishMappingRegionExit(areaId)
	end
end

function ClientSpaceSeamlessComponent:seamless_mappingRegionEnter(areaId, regionData)
	self.mappingRegionExitAreaId = nil
	self.mappingRegionExitTime = nil

	if self.mappingRegionId == areaId and self.regionId == areaId then
		return
	end

	self.mappingRegionId = areaId

	self:serverMsg("RPC_CS_MappingRegionEnter", areaId)
	self:seamless_showMappingRegionTip(regionData.enterRegion)
end

function ClientSpaceSeamlessComponent:seamless_mappingRegionExit(areaId, regionData)
	if self.mappingRegionId ~= areaId then
		return
	end

	local exitRegionDelay = regionData.exitRegionDelay or 0

	if exitRegionDelay > 0 then
		self.mappingRegionExitAreaId = areaId
		self.mappingRegionExitTime = Time.realSecondCache + exitRegionDelay

		return
	end

	self:seamless_finishMappingRegionExit(areaId, regionData)
end

function ClientSpaceSeamlessComponent:seamless_finishMappingRegionExit(areaId, regionData)
	if self.mappingRegionId ~= areaId then
		return
	end

	self.mappingRegionId = nil

	self:serverMsg("RPC_CS_MappingRegionLeave", areaId)
	self:seamless_showMappingRegionTip((regionData or RegionSyncData[areaId]).exitRegion)
end

function ClientSpaceSeamlessComponent:seamless_showMappingRegionTip(tipKey)
	if tipKey and tipKey ~= "" then
		pg.global.showBubbleMessageRaw(pg.getGameString(tipKey), 2)
	end
end

function ClientSpaceSeamlessComponent:on_regionId_changed(oldValue, newValue)
	if newValue == 0 and self.mappingRegionId == oldValue then
		self.mappingRegionId = nil
	end

	if pg.global.ui and pg.global.ui.hudV2 then
		pg.global.ui.hudV2:showSeamlessVFX()
	end
end

function ClientSpaceSeamlessComponent:seamless_checkInAreaTiming()
	if not self.__enableCheck then
		return
	end

	if Time.realSecondCache < self.waitTickEndTime then
		return
	end

	self.waitTickEndTime = Time.realSecondCache + CHECK_IN_AREA_CD

	local rawData

	if self:seamless_InSeamless() then
		local sceneData = SceneData[self.space.sceneId]
		local areaId = sceneData.seamlessRange and sceneData.seamlessRange[1]

		rawData = areaId and pg.game.seamless:seam_sys_getAreaData(areaId)
	else
		rawData = pg.game.seamless:seam_sys_getLastAreaInfo()
	end

	if rawData == nil then
		return
	end

	if pg.game.seamless:seam_sys_isForbidAutoEnter(self, rawData.id) then
		return
	end

	local selfPos = self:getPosition()

	if pg.game.seamless:seam_sys_inSeamlessArea(selfPos, rawData) then
		if rawData.areaLoadType == Const.AREA_LOAD_TYPE.PHASE_LOAD and not self:seamless_InSeamless() then
			self:seamless_enterSeamlessWithRPC(rawData)
		end
	elseif rawData.areaLoadType == Const.AREA_LOAD_TYPE.PHASE_LOAD and self:seamless_InSeamless() then
		self:seamless_exitSeamlessWithRPC(rawData)
	end
end

function ClientSpaceSeamlessComponent:seamless_event_TriggerAutoExitSeamless()
	local rawData = pg.game.seamless:seam_sys_getLastAreaInfo()

	if rawData == nil then
		return
	end

	if pg.game.seamless:seam_sys_isForbidAutoEnter(self, rawData.id) then
		return
	end
end

function ClientSpaceSeamlessComponent:seamless_event_enterSeamless(sceneId, dynamic)
	if not dynamic then
		local cData = SceneData[sceneId]

		if not Utils.inSeamlessRange(sceneId, cData.seamlessRange[1], self:getPosition(), true, false) then
			pg.global.showBubbleMessageRaw("不在区域范围内，无法通过事件进入静态位面!", 2)

			return
		end
	end

	pg.game.seamless:seam_sys_addDynamicArea(sceneId, dynamic)
end

function ClientSpaceSeamlessComponent:seamless_InSeamless()
	if self.space == nil then
		return false
	end

	local curSceneId = self.space.sceneId

	return SceneUtils.isSeamlessScene(curSceneId)
end

function ClientSpaceSeamlessComponent:seamless_enterSeamlessWithRPC(rawData)
	if pg.game.seamless:seam_sys_checkIsDynamic() then
		pg.me:CallServerMsgTeleportToPhase(rawData.sceneId, rawData.position)
	else
		pg.me:CallServerMsgTeleportToScene(rawData.sceneId, Const.SeamlessPortalId, false)
	end

	pg.game.seamless:seam_sys_setLastTipArea(rawData.id)
end

function ClientSpaceSeamlessComponent:seamless_exitSeamlessWithRPC(rawData)
	self:serverMsg("RPC_CS_QuitSpace")
end

function ClientSpaceSeamlessComponent:RPC_SC_CheckSeamlessConditionFail(isEnter)
	pg.game.seamless:seam_sys_setSwitchState(false)
end

function ClientSpaceSeamlessComponent:RPC_SC_EnterPhase()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("bgf ClientSpaceSeamlessComponent:RPC_SC_EnterPhase")
	end

	if pg.pawn then
		pg.pawn:cancelAbility()
	end

	pg.game.seamless:seam_sys_setSwitchState(true)
	pg.game.seamless:recordEntity(pg.game.controller.pawn)
end

return ClientSpaceSeamlessComponent
