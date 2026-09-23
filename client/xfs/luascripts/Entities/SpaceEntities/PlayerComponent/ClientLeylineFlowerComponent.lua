-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientLeylineFlowerComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local LeylineFlowerStatusData = require("Data.leylineflower_status_data")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local CatchLuckyRewardDisplayData = require("Data.catch_lucky_reward_display_data")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local LeylineFlowerPresentUtils = require("Utils.LeylineFlowerPresentUtils")
local ClientLeylineFlowerComponent = class.Component("ClientLeylineFlowerComponent")
local PRESENT_REASON = LeylineFlowerConst.RAINBOW_PRESENT_REASON
local DAILY_AI_HELPER_MAX_LEVEL = 59
local DAILY_AI_HELPER_CACHE_KEY_PREFIX = "LeylineFlowerDailyAIHelper_"
local DAILY_AI_HELPER_IDS = {
	[133] = true,
	[121] = true
}
local PICK_FRUIT_BURST_FALLBACK = "Eff_Env_SceneObject_LeaderFlower_KeyItem_Burst"
local DEFAULT_PICK_FRUIT_TO_HUD_DELAY = 0.8

local function getPickFruitToHudDelay()
	return math.max(0, tonumber(SysConfigData.LEYLINE_FLOWER_RAINBOW_PICK_HUD_DELAY) or DEFAULT_PICK_FRUIT_TO_HUD_DELAY)
end

local function getCaptureLuckyEnergyHudDelay(present)
	if not present or present.reason ~= PRESENT_REASON.AreaLucky then
		return 0
	end

	local luckyType = tonumber(present.luckyEventId)
	local energyLevel = tonumber(present.luckyEnergyLevel)

	if not luckyType or not energyLevel then
		return 0
	end

	local luckyConfigs = CatchLuckyRewardDisplayData[tostring(luckyType)]
	local displayConfig = luckyConfigs and luckyConfigs[energyLevel]

	return math.max(0, tonumber(displayConfig and displayConfig.delaySecondsEnergyHUD) or 0)
end

local function getPickFruitEffectKey(energyGain)
	local config = SysConfigData.LEYLINEFLOWER_ENERGY_GET_EFFECT_CONFIG

	if type(config) ~= "table" then
		return PICK_FRUIT_BURST_FALLBACK
	end

	energyGain = energyGain or 0

	local matchedKey, matchedNeed

	for _, item in ipairs(config) do
		local need, effectKey = item[1], item[2]

		if need and need <= energyGain and (not matchedNeed or matchedNeed <= need) and not string.isNilOrEmpty(effectKey) then
			matchedNeed = need
			matchedKey = effectKey
		end
	end

	return matchedKey or PICK_FRUIT_BURST_FALLBACK
end

function ClientLeylineFlowerComponent:ctor()
	self.logger = LoggerManager.getLogger("ClientLeylineFlowerComponent")
end

function ClientLeylineFlowerComponent:tryTriggerDailyAIHelper(aiId)
	if not DAILY_AI_HELPER_IDS[aiId] then
		return false
	end

	local playerLevel = tonumber(self.level)

	if not playerLevel or playerLevel >= DAILY_AI_HELPER_MAX_LEVEL then
		return false
	end

	local serverDayBegin = TimeUtils.getServerDayBegin()

	if not serverDayBegin or serverDayBegin <= 0 then
		return false
	end

	local prefsCacheUtils = pg.global.prefsCacheUtils
	local cacheKey = DAILY_AI_HELPER_CACHE_KEY_PREFIX .. tostring(aiId)
	local lastServerDayBegin = prefsCacheUtils:getInt(cacheKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if lastServerDayBegin == serverDayBegin then
		return false
	end

	prefsCacheUtils:setIntImmediately(cacheKey, serverDayBegin, ClientConst.CACHE_TYPE_FLAG.USER)
	self:doEventByData({
		"startAIRemind",
		{
			aiId
		}
	})

	return true
end

function ClientLeylineFlowerComponent:RPC_SC_LeylineRainbowPresent(present)
	if not present or not present.flowerId then
		self.logger:error("RPC_SC_LeylineRainbowPresent invalid payload")

		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_LeylineRainbowPresent", present.flowerId, present.reason, present.oldStage, present.oldEnergy, present.grownStage, present.grownEnergy, present.newStage, present.newEnergy, present.rainbowPetId, present.luckyEventId, present.luckyEnergyLevel)
	end

	local flowerId = present.flowerId
	local reason = present.reason
	local rainbowPetId = present.rainbowPetId or 0
	local hasPickFruitEffect = reason == PRESENT_REASON.Pick
	local hudDelay = 0

	if hasPickFruitEffect then
		hudDelay = getPickFruitToHudDelay()
	elseif reason == PRESENT_REASON.AreaLucky then
		hudDelay = getCaptureLuckyEnergyHudDelay(present)

		self:tryTriggerDailyAIHelper(133)
	end

	if reason == PRESENT_REASON.TreeMeteorology then
		self:syncRainbowPetTemplateId(flowerId, rainbowPetId)
		LeylineFlowerPresentUtils.notifyRainbowPetSpawnPresented(flowerId)

		return
	end

	if hasPickFruitEffect then
		self:tryTriggerDailyAIHelper(121)
		self:playPickFruitEffect(flowerId, rainbowPetId > 0 and math.huge or (present.grownEnergy or 0) - (present.oldEnergy or 0))
		pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, LeylineFlowerConst.RUMBLE_NAME.Bloom)
	end

	if rainbowPetId > 0 then
		self:presentRainbowPetSpawn(flowerId, present, hudDelay)

		return
	end

	if reason == PRESENT_REASON.Timeout then
		return
	end

	self:presentRainbowEnergyChanged(flowerId, present, hudDelay)
end

function ClientLeylineFlowerComponent:playPickFruitEffect(flowerId, energyGain)
	local space = self.space

	if not space then
		return
	end

	local flowerPos = LeylineFlowerUtils.getFlowerPositionByStaticId(flowerId, space.sceneId, space.id)

	if not flowerPos then
		return
	end

	LeylineFlowerUtils.playEffect(flowerPos, getPickFruitEffectKey(energyGain))

	local audioPos = Vector3(flowerPos[1], flowerPos[2], flowerPos[3])

	pg.game.audio:playSoundAtPos(LeylineFlowerConst.FLOWER_AUDIO_EVENT.RainbowEnergyGet, audioPos)
end

function ClientLeylineFlowerComponent:syncRainbowPetTemplateId(flowerId, rainbowPetId)
	local space = self.space

	if not space or not space.setRainbowPetTemplateId then
		return
	end

	space:setRainbowPetTemplateId(flowerId, rainbowPetId)
end

function ClientLeylineFlowerComponent:presentRainbowPetSpawn(flowerId, present, delay)
	local space = self.space

	if not space or not space.setPendingRainbowPetPresentation then
		self.logger:error("presentRainbowPetSpawn space unavailable, flowerId:", flowerId)

		return
	end

	self:syncRainbowPetTemplateId(flowerId, present.rainbowPetId)

	delay = math.max(0, tonumber(delay) or 0)

	space:setPendingRainbowPetPresentation(flowerId, {
		petTemplateId = present.rainbowPetId,
		rainbowSnapshot = present,
		luckyEventId = present.luckyEventId,
		holdSeconds = delay
	})

	if delay <= 0 then
		space:tryPresentRainbowPetSpawn(flowerId)

		return
	end

	self:addTimer(delay, function()
		local curSpace = self.space

		if not curSpace or not curSpace.tryPresentRainbowPetSpawn then
			return
		end

		curSpace:tryPresentRainbowPetSpawn(flowerId)
	end)
end

function ClientLeylineFlowerComponent:presentRainbowEnergyChanged(flowerId, present, delay)
	delay = math.max(0, tonumber(delay) or 0)

	if delay > 0 then
		local expectedSpace = self.space

		self:addTimer(delay, function()
			if not expectedSpace or self.space ~= expectedSpace then
				return
			end

			self:presentRainbowEnergyChanged(flowerId, present, 0)
		end)

		return true
	end

	local blockId = LeylineFlowerUtils.getBlockIdByStaticId(self.space and self.space.sceneId, flowerId)

	if not blockId then
		self.logger:error("presentRainbowEnergyChanged blockId nil, flowerId:", flowerId)

		return false
	end

	return LeylineFlowerPresentUtils.present(LeylineFlowerPresentUtils.PRESENT_TYPE.RainbowEnergyChanged, {
		blockId = blockId,
		flowerId = flowerId,
		sourceUid = present.sourceUid,
		rainbowSnapshot = present
	})
end

function ClientLeylineFlowerComponent:onLeylineFlowerInfoMapFlowerState_changed(ov, nv, leylineFlowerId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLeylineFlowerInfoMapFlowerState_changed", ov, nv, leylineFlowerId)
	end

	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_FLOWER_STATE_CHANGED, {
		oldValue = ov,
		newValue = nv,
		leylineFlowerId = leylineFlowerId
	})
end

function ClientLeylineFlowerComponent:onLeylineFlowerInfoMapRainbowStage_changed(ov, nv, leylineFlowerId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLeylineFlowerInfoMapRainbowStage_changed", ov, nv, leylineFlowerId)
	end

	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_RAINBOW_STAGE_CHANGED, {
		leylineFlowerId = leylineFlowerId,
		rainbowStage = nv
	})
end

function ClientLeylineFlowerComponent:onLeylineFlowerInfoMapCaptureProgressCount_changed(ov, nv, leylineFlowerId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLeylineFlowerInfoMapCaptureProgressCount_changed", ov, nv, leylineFlowerId)
	end

	if nv == 0 then
		pg.game.leylineTree.curPlentyLeylineFlowerId = leylineFlowerId
	end
end

function ClientLeylineFlowerComponent:onLeylineFlowerInfoMapPendingCaptureBloomCount_changed(ov, nv, leylineFlowerId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onLeylineFlowerInfoMapPendingCaptureBloomCount_changed", ov, nv, leylineFlowerId)
	end

	if (ov or 0) > 0 == ((nv or 0) > 0) then
		return
	end

	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_PLENTY_CIRCLE_CHANGED, {
		leylineFlowerId = leylineFlowerId
	})
end

function ClientLeylineFlowerComponent:getSpaceOwnerSceneLeylineFlowerInfoMap()
	if not self:isUsingSpaceOwnerMap() then
		return nil
	end

	local leaderPlayer = self:getTeamLeaderPlayer()

	if leaderPlayer == nil then
		return nil
	end

	local res = require("CustomTypes.LeylineFlowerInfoMap")(leaderPlayer.leylineFlowerInfoMap:getRawTable())

	return res
end

function ClientLeylineFlowerComponent:getCurFlowerState(flowerId)
	local leylineFlowerInfoMap = self:getSpaceOwnerSceneLeylineFlowerInfoMap() or self.leylineFlowerInfoMap:getRawTable()
	local flowerInfo = leylineFlowerInfoMap[flowerId]

	if not flowerInfo or not next(flowerInfo) then
		return nil
	end

	return flowerInfo.flowerState
end

function ClientLeylineFlowerComponent:getCurFlowerInfo(flowerId)
	local leylineFlowerInfoMap = self:getSpaceOwnerSceneLeylineFlowerInfoMap() or self.leylineFlowerInfoMap:getRawTable()
	local flowerInfo = leylineFlowerInfoMap[flowerId]

	if not flowerInfo or not next(flowerInfo) then
		return nil
	end

	return flowerInfo
end

function ClientLeylineFlowerComponent:getCurFlowerCreateId(flowerId)
	local leylineFlowerInfoMap = self:getSpaceOwnerSceneLeylineFlowerInfoMap() or self.leylineFlowerInfoMap:getRawTable()
	local flowerInfo = leylineFlowerInfoMap[flowerId]

	if not flowerInfo or not next(flowerInfo) then
		return nil
	end

	return flowerInfo.plentyTableId
end

function ClientLeylineFlowerComponent:shouldShowPlentyCircle(flowerId)
	local leylineFlowerInfoMap = self:getSpaceOwnerSceneLeylineFlowerInfoMap() or self.leylineFlowerInfoMap:getRawTable()
	local flowerInfo = leylineFlowerInfoMap[flowerId]

	if not flowerInfo or not next(flowerInfo) then
		return false
	end

	if flowerInfo.flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming then
		return true
	end

	if flowerInfo.flowerState == LeylineFlowerConst.FLOWER_STATE.Budding then
		return true
	end

	if flowerInfo.pendingCaptureBloomCount and flowerInfo.pendingCaptureBloomCount > 0 then
		return true
	end

	return false
end

function ClientLeylineFlowerComponent:getCurFlowerEndTs(flowerId)
	local leylineFlowerInfoMap = self:getSpaceOwnerSceneLeylineFlowerInfoMap() or self.leylineFlowerInfoMap:getRawTable()
	local flowerInfo = leylineFlowerInfoMap[flowerId]

	if not flowerInfo or not next(flowerInfo) then
		return nil
	end

	local stateStartTime = flowerInfo.stateStartTime
	local flowerState = flowerInfo.flowerState

	if flowerState ~= LeylineFlowerConst.FLOWER_STATE.Blooming then
		return nil
	end

	local duringTime = LeylineFlowerStatusData[LeylineFlowerConst.FLOWER_STATE.Blooming].stateTime or 120

	return stateStartTime + duringTime
end

function ClientLeylineFlowerComponent:onCachedMapRainbowPetsChanged(oldValue, newValue)
	facade:SendMessageCommand(MessageName.LEYLINE_MAP_RAINBOW_CHANGED)
end

return ClientLeylineFlowerComponent
