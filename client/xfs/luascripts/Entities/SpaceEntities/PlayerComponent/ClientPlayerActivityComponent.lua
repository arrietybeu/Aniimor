-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerActivityComponent.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local GameEventData = require("Data.game_event_data")
local ClientPlayerActivityComponent = class.Component("ClientPlayerActivityComponent")

function ClientPlayerActivityComponent:ctor()
	self._bpLastGear = nil
	self._bpLastUnlockCycleReward = nil
end

function ClientPlayerActivityComponent:init(avtDict)
	local activityBattlePass = avtDict and avtDict.activityBattlePass or self.activityBattlePass

	self._bpLastGear = activityBattlePass and activityBattlePass.bpGear or 0
	self._bpLastUnlockCycleReward = activityBattlePass and activityBattlePass.unlockCycleReward or 0

	return true
end

function ClientPlayerActivityComponent:destroy()
	return
end

function ClientPlayerActivityComponent:on_activityBattlePass_changed(oldV, newV)
	local oldLevel = oldV and oldV.bpLevel or 0
	local newLevel = newV and newV.bpLevel or 0

	if oldLevel < newLevel then
		facade:sendMsgToUI(MessageName.BATTLEPASS_LEVEL_UP, {
			bpLevel = newLevel
		})
	end

	local oldPhase = oldV and oldV.activityBase and oldV.activityBase.activityPhase or 0
	local newPhase = newV and newV.activityBase and newV.activityBase.activityPhase or 0
	local newGear = newV and newV.bpGear or 0
	local oldGear = self._bpLastGear or newGear

	self._bpLastGear = newGear

	local newUnlockCycleReward = newV and newV.unlockCycleReward or 0
	local oldUnlockCycleReward = self._bpLastUnlockCycleReward or newUnlockCycleReward

	self._bpLastUnlockCycleReward = newUnlockCycleReward

	facade:sendMsgToUI(MessageName.BATTLEPASS_CHANGE, {
		oldPhase = oldPhase,
		newPhase = newPhase,
		oldGear = oldGear,
		newGear = newGear,
		oldUnlockCycleReward = oldUnlockCycleReward,
		newUnlockCycleReward = newUnlockCycleReward
	})
end

function ClientPlayerActivityComponent:on_activityLittleFirePerson_changed(oldV, newV)
	facade:sendMsgToUI(MessageName.LITTLE_FIRE_PERSON_CHANGE)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityComponent:on_fishingCaptureCurPhase_changed(oldV, newV)
	local space = self.space or pg and pg.me and pg.me.space or pg and pg.space

	if not space or not space.getEntityByStaticId then
		return
	end

	local refreshedStaticIds = {}

	local function refreshBossTopLogoDeadState(phase)
		if type(phase) ~= "number" or phase <= 0 then
			return
		end

		local config = FishingCaptureActivityData[phase]
		local bossStaticId = config and config.bossStaticId
		local alreadyRefreshed = refreshedStaticIds[bossStaticId]

		if type(bossStaticId) ~= "number" or bossStaticId <= 0 or alreadyRefreshed then
			return
		end

		refreshedStaticIds[bossStaticId] = true

		local bossEntity = space:getEntityByStaticId(bossStaticId)

		if bossEntity and bossEntity.refreshTopLogoDeadState then
			bossEntity:refreshTopLogoDeadState()
		end
	end

	refreshBossTopLogoDeadState(oldV)
	refreshBossTopLogoDeadState(newV)
end

function ClientPlayerActivityComponent:_refreshFishingCaptureBossTopLogoDeadState(activityBase, refreshedStaticIds)
	local eventData = activityBase and GameEventData[activityBase.activityId]
	local config = eventData and FishingCaptureActivityData[eventData.phase]
	local bossStaticId = config and config.bossStaticId

	if type(bossStaticId) ~= "number" or bossStaticId <= 0 or refreshedStaticIds[bossStaticId] then
		return
	end

	refreshedStaticIds[bossStaticId] = true

	local space = self.space or pg and pg.me and pg.me.space or pg and pg.space

	if not space or not space.getEntityByStaticId then
		return
	end

	local bossEntity = space:getEntityByStaticId(bossStaticId)

	if bossEntity and bossEntity.refreshTopLogoDeadState then
		bossEntity:refreshTopLogoDeadState()
	end
end

function ClientPlayerActivityComponent:on_activityFishingCapture_activityBase_changed(oldV, newV)
	local refreshedStaticIds = {}

	self:_refreshFishingCaptureBossTopLogoDeadState(oldV, refreshedStaticIds)
	self:_refreshFishingCaptureBossTopLogoDeadState(newV, refreshedStaticIds)
end

function ClientPlayerActivityComponent:on_activityFishingCapture_changed(oldV, newV)
	local oldCountMap = oldV and oldV.cubeExchangeCountMap
	local newCountMap = newV and newV.cubeExchangeCountMap
	local legendCubeType = FishingCaptureConst.CubeType.LEGEND
	local seasonCubeType = FishingCaptureConst.CubeType.SEASON
	local legendCountChanged = (tonumber(oldCountMap and oldCountMap[legendCubeType]) or 0) ~= (tonumber(newCountMap and newCountMap[legendCubeType]) or 0)
	local seasonCountChanged = (tonumber(oldCountMap and oldCountMap[seasonCubeType]) or 0) ~= (tonumber(newCountMap and newCountMap[seasonCubeType]) or 0)

	if not legendCountChanged and not seasonCountChanged then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_TAB_LIST)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityComponent:on_activityFishingCapture_irisRewardReceived_changed(oldV, newV)
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityComponent:on_sparkStreakDaysMap_entry_added(playerUid, streakDays)
	self:on_sparkStreakDaysMap_changed(0, streakDays, playerUid)
end

function ClientPlayerActivityComponent:on_sparkStreakDaysMap_changed(oldDays, newDays, playerUid)
	if newDays <= oldDays then
		return
	end

	pg.game.audio:playEvent("SFX_Act_Spark")

	if self:showLittleFireSparkToast(playerUid) then
		return
	end

	pg.game.chat:getBasicPlayerInfoListFromServer({
		playerUid
	}, CallbackHandler(self, "onLittleFireSparkPlayerInfoReady", playerUid))
end

function ClientPlayerActivityComponent:onLittleFireSparkPlayerInfoReady(playerUid)
	self:showLittleFireSparkToast(playerUid)
end

function ClientPlayerActivityComponent:showLittleFireSparkToast(playerUid)
	local playerInfo = pg.game.chat:getPlayerInfo(playerUid)
	local playerName = LuaUIUtils.getPlayerDisplayName(playerUid, playerInfo and playerInfo.playerName)

	if string.isNilOrEmpty(playerName) then
		return false
	end

	pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("CHAT_SPARK_LIT_TOAST"), playerName))

	return true
end

function ClientPlayerActivityComponent:on_sparkLastLightDayMap_entry_added(playerUid, lightDay)
	self:on_sparkLastLightDayMap_changed(0, lightDay, playerUid)
end

function ClientPlayerActivityComponent:on_sparkLastLightDayMap_changed(oldDay, newDay, playerUid)
	facade:sendMsgToUI(MessageName.PLAYER_SPARK_CHANGE, playerUid)
end

function ClientPlayerActivityComponent:RPC_SC_NotifyActivityStageInfo(activityStageInfo)
	facade:sendMsgToSystem(MessageName.ACTIVITY_STAGE_INFO_UPDATED, activityStageInfo)

	if pg.global.ui.event:checkUIOpen() then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_TAB_LIST)
	else
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	end
end

return ClientPlayerActivityComponent
