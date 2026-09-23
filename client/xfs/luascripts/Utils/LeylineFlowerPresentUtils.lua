-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LeylineFlowerPresentUtils.lua

local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local SysConfigData = require("Data.sys_config_data")
local LoggerManager = require("Core.Log.LoggerManager")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local AddressDataConst = require("Const.AddressDataConst")
local EventConst = require("Const.EventConst")
local logger = LoggerManager.getLogger("LeylineFlowerPresentUtils")
local LeylineFlowerPresentUtils = {}
local FLOW_WATCHDOG_EXTRA = 5
local RAINBOW_PET_SCREEN_EFFECT_FALLBACK_DURATION = 3
local HIDE_RAINBOW_PET_SCREEN_EFFECT = true

LeylineFlowerPresentUtils.PRESENT_TYPE = {
	RainbowEnergyChanged = 2,
	RainbowPetSpawn = 1
}

local PRESENT_POLICY = {
	[LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowPetSpawn] = {
		openMap = true,
		states = {
			LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowEnergy
		}
	},
	[LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowEnergyChanged] = {
		states = {
			LeylineFlowerConst.CULTIVATE_TIP_STATE.RainbowEnergy
		}
	}
}
local flowVersion = 0
local activePetFlow, flowWatchdogTimerId

local function getTipsCtrl()
	return pg.global and pg.global.ui and pg.global.ui.tips
end

local function showCultivateTips(states, data)
	local tipsCtrl = getTipsCtrl()

	if not tipsCtrl or not tipsCtrl.showCultivateTips then
		logger:error("@leylineflower show cultivate HUD skipped: tips ctrl unavailable")

		return false
	end

	local pushed = false
	local success, errorMessage = xpcall(function()
		pushed = tipsCtrl:showCultivateTips(states, data) == true
	end, debug.traceback)

	if not success then
		logger:error("@leylineflower show cultivate HUD failed: %s", tostring(errorMessage))

		return false
	end

	if not pushed then
		logger:error("@leylineflower show cultivate HUD dropped by tips ctrl, blockId: %s", tostring(data and data.blockId))
	end

	return pushed
end

local function getCurrentSpace(flow)
	local space = pg.space

	if not pg.me or not space then
		return nil
	end

	if space.id ~= flow.spaceId or space.sceneId ~= flow.sceneId then
		return nil
	end

	if space.ownerPlayerId ~= pg.me.id then
		return nil
	end

	local pointCountMap = space.rainbowPetPosFlags and space.rainbowPetPosFlags[flow.staticId]

	if not pointCountMap or (pointCountMap[flow.pointId] or 0) <= 0 then
		return nil
	end

	return space
end

local function isPetFlowValid(flow)
	return flow and flow.flowId == flowVersion and getCurrentSpace(flow) ~= nil
end

local function getCurrentPetTemplateId(flow, space)
	local petTemplateId = space.getRainbowPetTemplateId and space:getRainbowPetTemplateId(flow.staticId, flow.pointId)

	if petTemplateId and petTemplateId > 0 then
		flow.petTemplateId = petTemplateId
	end

	return flow.petTemplateId
end

local function playRainbowPetScreenEffect(duration)
	if HIDE_RAINBOW_PET_SCREEN_EFFECT then
		return
	end

	if not pg.pawn or not pg.pawn.playScreenEffect then
		return
	end

	duration = tonumber(duration) or 0

	if duration <= 0 then
		duration = RAINBOW_PET_SCREEN_EFFECT_FALLBACK_DURATION
	end

	pg.pawn:playScreenEffect(AddressDataConst.LEYLINEFLOWER_RAINBOW_PET_SCREEN_EFFECT_RES, duration)
end

local function emitRainbowPetSpawnPresented(staticId, pointId)
	local eventEmitter = pg.global and pg.global.eventEmitter

	if not eventEmitter then
		return
	end

	eventEmitter:emit(EventConst.ON_LEYLINE_RAINBOW_PET_SPAWN_PRESENTED, {
		staticId = staticId,
		pointId = pointId
	})
end

local function notifyPetFlowSpawnPresented(flow)
	if not flow or flow.spawnPresentedNotified then
		return
	end

	flow.spawnPresentedNotified = true

	emitRainbowPetSpawnPresented(flow.staticId, flow.pointId)
end

function LeylineFlowerPresentUtils.notifyRainbowPetSpawnPresented(staticId, pointId)
	emitRainbowPetSpawnPresented(staticId, pointId)
end

local function getCameraConfig()
	return {
		focusDelay = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_FOCUS_DELAY or 1,
		rotateTime = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_ROTATE_TIME or 1,
		heightOffset = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_HEIGHT or 12,
		focusDuration = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_FOCUS_DURATION or 2,
		backBlendTime = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_BACK_TIME or 0.8,
		startFOV = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_START_FOV or 40,
		endFOV = SysConfigData.LEYLINE_FLOWER_RAINBOW_CAMERA_END_FOV or 70
	}
end

local function stopFlowWatchdog()
	if flowWatchdogTimerId then
		TimerManager.removeTimer(flowWatchdogTimerId)

		flowWatchdogTimerId = nil
	end
end

local function resetPetFlow(skipSpawnNotify)
	local flow = activePetFlow

	activePetFlow = nil

	stopFlowWatchdog()

	if skipSpawnNotify then
		return
	end

	notifyPetFlowSpawnPresented(flow)
end

local function finishPetFlow(flow)
	if activePetFlow ~= flow then
		return
	end

	resetPetFlow()
end

local function getFlowWatchdogTimeout()
	local cameraConfig = getCameraConfig()
	local hudMaxDuration = tonumber(SysConfigData.LEYLINE_FLOWER_RAINBOW_HUD_MAX_DURATION) or 30

	return hudMaxDuration + cameraConfig.focusDelay + cameraConfig.rotateTime + cameraConfig.focusDuration + cameraConfig.backBlendTime + FLOW_WATCHDOG_EXTRA
end

local function startFlowWatchdog(flow)
	stopFlowWatchdog()

	flowWatchdogTimerId = TimerManager.addTimer(getFlowWatchdogTimeout(), function()
		flowWatchdogTimerId = nil

		if activePetFlow ~= flow then
			return
		end

		logger:error("@leylineflower rainbow pet flow timeout, staticId: %s pointId: %s", tostring(flow.staticId), tostring(flow.pointId))

		activePetFlow = nil

		notifyPetFlowSpawnPresented(flow)
		LeylineFlowerUtils.cancelCameraFocus(flow.staticId, flow.pointId)
	end)
end

local function openRainbowPetMap(flow)
	local success, errorMessage = xpcall(function()
		if not isPetFlowValid(flow) then
			return
		end

		local map = pg.game and pg.game.map

		if not map then
			return
		end

		local globalUI = pg.global and pg.global.ui

		if not globalUI or globalUI:checkUIVisible(UIConst.UI_ID_MAP) then
			return
		end

		local markInfo = map:getMarkInfo(flow.pointId)

		if not markInfo then
			logger:error("@leylineflower rainbow pet mark missing, pointId: %s", tostring(flow.pointId))

			return
		end

		local space = getCurrentSpace(flow)

		if not space then
			return
		end

		map:openMapAndLocateMark(flow.sceneId, markInfo.markType, flow.pointId, true, 1, function()
			local callbackSuccess, callbackError = xpcall(function()
				if not isPetFlowValid(flow) then
					return
				end

				local tipsCtrl = getTipsCtrl()
				local currentSpace = getCurrentSpace(flow)
				local petTemplateId = currentSpace and getCurrentPetTemplateId(flow, currentSpace)

				if tipsCtrl and petTemplateId then
					tipsCtrl:showRainbowPetAppear(petTemplateId, flow.duration)
				end
			end, debug.traceback)

			if not callbackSuccess then
				logger:error("@leylineflower show map tip failed: %s", tostring(callbackError))
			end
		end, true)
	end, debug.traceback)

	if not success then
		logger:error("@leylineflower open rainbow pet map failed: %s", tostring(errorMessage))
	end
end

local function startRainbowPetCamera(data, policy)
	local cameraStarted = LeylineFlowerUtils.focusCameraToPosition(data.staticId, data.targetPosition, getCameraConfig(), {
		pointId = data.pointId,
		canStart = function()
			return isPetFlowValid(data)
		end,
		onBackBlendFinished = function()
			finishPetFlow(data)

			if policy.openMap then
				openRainbowPetMap(data)
			end
		end,
		onCancelled = function()
			finishPetFlow(data)
		end
	})

	if not cameraStarted then
		finishPetFlow(data)
	end

	return cameraStarted
end

local function presentRainbowPetSpawn(data, policy)
	if not data or not data.staticId or not data.pointId or not data.targetPosition then
		return false
	end

	if not data.petTemplateId or data.petTemplateId <= 0 then
		return false
	end

	flowVersion = flowVersion + 1

	local previousFlow = activePetFlow

	resetPetFlow()

	if previousFlow then
		LeylineFlowerUtils.cancelCameraFocus(previousFlow.staticId, previousFlow.pointId)
	end

	data.flowId = flowVersion
	data.duration = data.duration or 2
	data.isRainbowSpawn = true

	local finishNotified = false

	function data.onCultivateFinished()
		if finishNotified then
			return
		end

		finishNotified = true

		if not isPetFlowValid(data) then
			finishPetFlow(data)

			return
		end

		startRainbowPetCamera(data, policy)
	end

	local watchdogStarted = false

	function data.onCultivateRendered()
		if watchdogStarted or activePetFlow ~= data then
			return
		end

		watchdogStarted = true

		startFlowWatchdog(data)
	end

	local rushNotified = false

	function data.onCultivateRushStart(rushDuration)
		if rushNotified then
			return
		end

		rushNotified = true

		if not isPetFlowValid(data) then
			return
		end

		playRainbowPetScreenEffect(rushDuration)
	end

	function data.onRainbowPetShown()
		notifyPetFlowSpawnPresented(data)
	end

	activePetFlow = data

	if not showCultivateTips(policy.states, data) then
		finishNotified = true
		watchdogStarted = true
		rushNotified = true
		data.onCultivateFinished = nil
		data.onCultivateRendered = nil
		data.onCultivateRushStart = nil
		data.onRainbowPetShown = nil

		finishPetFlow(data)

		return false
	end

	return true
end

local function presentRainbowEnergyChanged(data, policy)
	if not data or not data.blockId then
		logger:error("@leylineflower present energy changed missing blockId")

		return false
	end

	local activeSnapshot = activePetFlow and activePetFlow.rainbowSnapshot or nil
	local incomingSnapshot = data.rainbowSnapshot
	local activeLuckyEventId = activePetFlow and (activePetFlow.luckyEventId or activeSnapshot and activeSnapshot.luckyEventId) or nil
	local incomingLuckyEventId = data.luckyEventId or incomingSnapshot and incomingSnapshot.luckyEventId or nil
	local isSameSnapshot = activeSnapshot ~= nil and activeSnapshot == incomingSnapshot
	local isSameLuckyEvent = activeLuckyEventId ~= nil and activeLuckyEventId ~= 0 and activeLuckyEventId == incomingLuckyEventId

	if activePetFlow and activePetFlow.staticId == data.flowerId and (isSameSnapshot or isSameLuckyEvent) then
		return false
	end

	return showCultivateTips(policy.states, data)
end

function LeylineFlowerPresentUtils.present(presentType, data)
	local policy = PRESENT_POLICY[presentType]

	if not policy then
		return false
	end

	if presentType == LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowPetSpawn then
		return presentRainbowPetSpawn(data, policy)
	end

	if presentType == LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowEnergyChanged then
		return presentRainbowEnergyChanged(data, policy)
	end

	return false
end

function LeylineFlowerPresentUtils.clear()
	flowVersion = flowVersion + 1

	local flow = activePetFlow

	resetPetFlow(true)

	if flow then
		LeylineFlowerUtils.cancelCameraFocus(flow.staticId, flow.pointId)
	end
end

return LeylineFlowerPresentUtils
