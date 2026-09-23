-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandSeasonComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SceneUtils = require("Common.Utils.SceneUtils")
local CelebrationData = require("Data.home_season_celebration_data")
local Const = require("Common.Const.Const")
local logger = require("Core.Log.LoggerManager").getLogger("ClientHomelandSeasonComponent")
local NoticeDef = require("Common.NoticeDef")
local CELEBRATION_STATE_IDLE = 0
local CELEBRATION_STATE_PREPARING = 1
local CELEBRATION_STATE_RUNNING = 2
local CELEBRATION_TIP_ID = "HomeSeasonCelebration"
local CELEBRATION_OPENING_DURATION_SECONDS = 3
local CELEBRATION_FIREWORK_DURATION_SECONDS = 300
local CELEBRATION_FINISH_TIME_TOLERANCE_SECONDS = 2
local CELEBRATION_EVENT_TIP_DURATION_SECONDS = 7
local CELEBRATION_PREPARE_CANCEL_EXIT_TIP_VALID_SECONDS = 0.5
local CELEBRATION_EVENT_TEXT_KEYS = {
	[Const.HomeSeasonCelebrationEventType.WavePreview] = "HOME_SEASON_CELEBRATION_WAVE_PREVIEW",
	[Const.HomeSeasonCelebrationEventType.LastWavePreview] = "HOME_SEASON_CELEBRATION_LAST_WAVE_PREVIEW",
	[Const.HomeSeasonCelebrationEventType.WaveExpireWarning] = "HOME_SEASON_CELEBRATION_WAVE_EXPIRE_WARNING"
}
local ClientHomelandSeasonComponent = Class.Component("ClientHomelandSeasonComponent")

function ClientHomelandSeasonComponent:start()
	self:refreshHomeSeasonCelebrationState(CELEBRATION_STATE_IDLE, self.homeSeasonCelebrationState or CELEBRATION_STATE_IDLE)
end

function ClientHomelandSeasonComponent:destroy()
	self:stopHomeSeasonCelebrationEventTip()
	self:hideHomeSeasonCelebrationTip()
	self:stopHomeSeasonCelebrationFireworks()
	self:stopHomeSeasonCelebrationCutscene()
	pg.global.ui:close(UIConst.UI_ID_HOME_SEASON_CELEBRATION_START)
end

function ClientHomelandSeasonComponent:isCelebrationOwner()
	return pg.me ~= nil and self.isSelfHomeland ~= nil and self:isSelfHomeland(pg.me)
end

function ClientHomelandSeasonComponent:consumeHomeSeasonPrepareCancelExitTip()
	local isPreparing = self.homeSeasonCelebrationState == CELEBRATION_STATE_PREPARING
	local cancelTime = self._homeSeasonPrepareCancelTime
	local isRecentCancel = cancelTime and Time.realtimeSinceStartup - cancelTime <= CELEBRATION_PREPARE_CANCEL_EXIT_TIP_VALID_SECONDS

	self._homeSeasonPrepareCancelTime = nil

	return isPreparing or isRecentCancel == true
end

function ClientHomelandSeasonComponent:getCelebrationRemainSeconds()
	return math.max(0, (self.homeSeasonCelebrationEndTs or 0) - Time.secondCache)
end

function ClientHomelandSeasonComponent:openHomeSeasonCelebrationPrepare()
	if self.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_CELEBRATION_PREPARE, {
		space = self
	})
end

function ClientHomelandSeasonComponent:hideHomeSeasonCelebrationTip()
	if pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:hideA1Tips(CELEBRATION_TIP_ID, CELEBRATION_TIP_ID)
	end
end

function ClientHomelandSeasonComponent:stopHomeSeasonCelebrationEventTip()
	if self._homeSeasonCelebrationEventTipTimer then
		self:removeTimer(self._homeSeasonCelebrationEventTipTimer)

		self._homeSeasonCelebrationEventTipTimer = nil
	end
end

function ClientHomelandSeasonComponent:showHomeSeasonCelebrationEventTip(text)
	self:stopHomeSeasonCelebrationEventTip()
	self:hideHomeSeasonCelebrationTip()
	pg.global.ui.tips:showTextTip(text, CELEBRATION_EVENT_TIP_DURATION_SECONDS)

	self._homeSeasonCelebrationEventTipTimer = self:addTimer(CELEBRATION_EVENT_TIP_DURATION_SECONDS, function()
		self._homeSeasonCelebrationEventTipTimer = nil

		if self.homeSeasonCelebrationState == CELEBRATION_STATE_RUNNING then
			self:showHomeSeasonCelebrationTip(CELEBRATION_STATE_RUNNING)
		end
	end)
end

function ClientHomelandSeasonComponent:showHomeSeasonCelebrationTip(state)
	local remainSeconds = self:getCelebrationRemainSeconds()

	if remainSeconds <= 0 or not pg.global.ui or not pg.global.ui.tips then
		self:hideHomeSeasonCelebrationTip()

		return
	end

	local isPreparing = state == CELEBRATION_STATE_PREPARING

	pg.global.ui.tips:showA1Tips({
		id = CELEBRATION_TIP_ID,
		uniqueId = CELEBRATION_TIP_ID,
		title = isPreparing and pg.getGameString("HOME_SEASON_CELEBRATION_PREPARING_TITLE") or pg.getGameString("HOME_SEASON_CELEBRATION_RUNNING_TITLE"),
		duration = remainSeconds,
		endTime = self.homeSeasonCelebrationEndTs,
		clickable = isPreparing,
		clickFunc = function()
			self:openHomeSeasonCelebrationPrepare()
		end
	})
end

function ClientHomelandSeasonComponent:playHomeSeasonCelebrationCutscene(festival)
	local cutsceneResId = festival and festival.cutsceneResId

	if string.isNilOrEmpty(cutsceneResId) then
		return
	end

	if not pg.game.cutscene then
		return
	end

	self:stopHomeSeasonCelebrationCutscene()

	local cutsceneItem

	cutsceneItem = pg.game.cutscene:playCutscene(cutsceneResId, cutsceneResId, nil, nil, CELEBRATION_OPENING_DURATION_SECONDS, nil, {
		keepPrefabTrans = true,
		endCallback = function()
			if self._homeSeasonCelebrationCutscene == cutsceneItem then
				self._homeSeasonCelebrationCutscene = nil
			end
		end
	})
	self._homeSeasonCelebrationCutscene = cutsceneItem
end

function ClientHomelandSeasonComponent:stopHomeSeasonCelebrationCutscene()
	local cutsceneItem = self._homeSeasonCelebrationCutscene

	if cutsceneItem and pg.game.cutscene then
		pg.game.cutscene:stopCutscene(cutsceneItem.id)
	end

	self._homeSeasonCelebrationCutscene = nil
end

function ClientHomelandSeasonComponent:stopHomeSeasonCelebrationFireworks()
	for _, effectId in ipairs(self._homeSeasonCelebrationFireworkIds or EMPTY_TABLE) do
		if pg.game.effect then
			pg.game.effect:stopEffect(0, effectId)
		end
	end

	self._homeSeasonCelebrationFireworkIds = nil
end

function ClientHomelandSeasonComponent:playHomeSeasonCelebrationFireworks(festival, duration)
	self:stopHomeSeasonCelebrationFireworks()

	local effectNames = festival and festival.fireworkEffectNames or {}
	local staticIds = festival and festival.fireworkStaticIds or {}

	duration = duration or CELEBRATION_FIREWORK_DURATION_SECONDS

	if duration <= 0 then
		return
	end

	if #effectNames == 0 or #effectNames ~= #staticIds then
		logger:error("home season celebration firework config invalid festivalId=%s effectCount=%s pointCount=%s", tostring(self.homeSeasonCelebrationFestivalId), tostring(#effectNames), tostring(#staticIds))

		return
	end

	self._homeSeasonCelebrationFireworkIds = {}

	for index, effectName in ipairs(effectNames) do
		local staticId = staticIds[index]
		local position, rotation = staticId and SceneUtils.getCommonBasicsPosition(self.sceneId, staticId)

		if position and not string.isNilOrEmpty(effectName) then
			local effectId = pg.game.effect:playEffectAt(0, effectName, position, rotation and rotation:ToEulerAngles() or nil, nil, {
				duration = duration
			})

			if effectId then
				self._homeSeasonCelebrationFireworkIds[#self._homeSeasonCelebrationFireworkIds + 1] = effectId
			end
		end
	end
end

function ClientHomelandSeasonComponent:tryPlayHomeSeasonCelebrationPresentation(oldState)
	if (self.homeSeasonCelebrationState or 0) ~= CELEBRATION_STATE_RUNNING then
		return
	end

	local sessionId = self.homeSeasonCelebrationSessionId or 0
	local festival = CelebrationData[self.homeSeasonCelebrationFestivalId]

	if not festival or sessionId <= 0 then
		return
	end

	if self._fireworkCelebrationSessionId ~= sessionId then
		local totalDuration = CELEBRATION_FIREWORK_DURATION_SECONDS
		local elapsed = math.max(0, Time.secondCache - (self.homeSeasonCelebrationStartTs or 0))
		local remainDuration = math.max(0, totalDuration - elapsed)

		if remainDuration > 0 and (self.homeSeasonCelebrationStartTs or 0) > 0 then
			self._fireworkCelebrationSessionId = sessionId

			self:playHomeSeasonCelebrationFireworks(festival, remainDuration)
		end
	end

	if oldState ~= CELEBRATION_STATE_PREPARING or self._presentedCelebrationSessionId == sessionId then
		return
	end

	self._presentedCelebrationSessionId = sessionId

	pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_CELEBRATION_START, {
		duration = CELEBRATION_OPENING_DURATION_SECONDS
	})
	self:playHomeSeasonCelebrationCutscene(festival)
end

function ClientHomelandSeasonComponent:tryShowHomeSeasonCelebrationFinished(oldState)
	local endTs = self._activeCelebrationEndTs or 0

	if oldState == CELEBRATION_STATE_RUNNING and self._activeCelebrationSessionId == self.homeSeasonCelebrationSessionId and endTs <= Time.secondCache + CELEBRATION_FINISH_TIME_TOLERANCE_SECONDS and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(pg.getGameString("HOME_SEASON_CELEBRATION_FINISHED"))
	end

	self._activeCelebrationSessionId = nil
	self._activeCelebrationEndTs = nil
end

function ClientHomelandSeasonComponent:refreshHomeSeasonCelebrationState(oldState, newState)
	if oldState == CELEBRATION_STATE_PREPARING and newState ~= CELEBRATION_STATE_PREPARING then
		pg.global.ui:close(UIConst.UI_ID_INFO_PLAYER_MAIN)
		pg.global.ui:close(UIConst.UI_ID_INFO_PLAYER_CARD)
	end

	if newState == CELEBRATION_STATE_IDLE then
		if oldState == CELEBRATION_STATE_PREPARING then
			self._homeSeasonPrepareCancelTime = Time.realtimeSinceStartup

			pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_PREPARE_CANCEL)
		end

		self:stopHomeSeasonCelebrationEventTip()
		self:tryShowHomeSeasonCelebrationFinished(oldState)
		self:hideHomeSeasonCelebrationTip()
		self:stopHomeSeasonCelebrationFireworks()
		self:stopHomeSeasonCelebrationCutscene()
		pg.global.ui:close(UIConst.UI_ID_HOME_SEASON_CELEBRATION_PREPARE)
		pg.global.ui:close(UIConst.UI_ID_HOME_SEASON_CELEBRATION_START)
	else
		self:showHomeSeasonCelebrationTip(newState)
	end

	if newState == CELEBRATION_STATE_RUNNING then
		self._activeCelebrationSessionId = self.homeSeasonCelebrationSessionId
		self._activeCelebrationEndTs = self.homeSeasonCelebrationEndTs

		pg.global.ui:close(UIConst.UI_ID_HOME_SEASON_CELEBRATION_PREPARE)
		pg.global.ui:close(UIConst.UI_ID_HOME_SEASON_CELEBRATION_INVITE)
		self:tryPlayHomeSeasonCelebrationPresentation(oldState)
	end

	facade:sendMsgToUI(MessageName.HOME_SEASON_CELEBRATION_CHANGE, {
		oldState = oldState,
		newState = newState,
		space = self
	})
end

function ClientHomelandSeasonComponent:on_homeSeasonCelebrationState_changed(oldValue, newValue)
	self:refreshHomeSeasonCelebrationState(oldValue, newValue)
end

function ClientHomelandSeasonComponent:on_homeSeasonCelebrationEndTs_changed()
	local state = self.homeSeasonCelebrationState or CELEBRATION_STATE_IDLE

	if state ~= CELEBRATION_STATE_IDLE then
		self:showHomeSeasonCelebrationTip(state)
	end

	if state == CELEBRATION_STATE_RUNNING then
		self._activeCelebrationEndTs = self.homeSeasonCelebrationEndTs
	end
end

function ClientHomelandSeasonComponent:on_homeSeasonCelebrationStartTs_changed()
	self:tryPlayHomeSeasonCelebrationPresentation(CELEBRATION_STATE_IDLE)
end

function ClientHomelandSeasonComponent:on_homeSeasonCelebrationFestivalId_changed()
	self:tryPlayHomeSeasonCelebrationPresentation(CELEBRATION_STATE_IDLE)
end

function ClientHomelandSeasonComponent:on_homeSeasonCelebrationSessionId_changed()
	self:tryPlayHomeSeasonCelebrationPresentation(CELEBRATION_STATE_IDLE)
end

function ClientHomelandSeasonComponent:RPC_SC_OnHomeSeasonCelebrationEvent(sessionId, eventType, waveIndex, chestCount)
	if sessionId ~= self.homeSeasonCelebrationSessionId or self.homeSeasonCelebrationState ~= CELEBRATION_STATE_RUNNING then
		logger:warn("[CelebrationRPC] filtered sessionMatched=%s running=%s", tostring(sessionId == self.homeSeasonCelebrationSessionId), tostring(self.homeSeasonCelebrationState == CELEBRATION_STATE_RUNNING))

		return
	end

	if eventType == Const.HomeSeasonCelebrationEventType.WaveSpawned then
		local text = pg.getFormatText(pg.getGameString("HOME_SEASON_CELEBRATION_WAVE_SPAWNED"), chestCount)

		self:showHomeSeasonCelebrationEventTip(text)

		return
	end

	if eventType == Const.HomeSeasonCelebrationEventType.WavePreview then
		local text = pg.getFormatText(pg.getGameString("HOME_SEASON_CELEBRATION_WAVE_PREVIEW"), waveIndex)

		self:showHomeSeasonCelebrationEventTip(text)

		return
	end

	local textKey = CELEBRATION_EVENT_TEXT_KEYS[eventType]

	if textKey then
		self:showHomeSeasonCelebrationEventTip(pg.getGameString(textKey))
	end
end

function ClientHomelandSeasonComponent:onHomelandEntityJoin(entity)
	if entity and entity.uid then
		facade:sendMsgToUI(MessageName.HOME_SEASON_CELEBRATION_PLAYERS_CHANGE)
	end
end

function ClientHomelandSeasonComponent:onHomelandEntityLeave(entity)
	if entity and entity.uid then
		facade:sendMsgToUI(MessageName.HOME_SEASON_CELEBRATION_PLAYERS_CHANGE)
	end
end

return ClientHomelandSeasonComponent
