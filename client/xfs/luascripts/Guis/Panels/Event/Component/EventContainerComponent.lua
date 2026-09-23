-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\EventContainerComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetSaveComponent")
local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local GameEventData = require("Data.game_event_data")
local GameEventTypeData = require("Data.game_event_type_data")
local EventContainerComponent = Class.LightClass("EventContainerComponent", UIComponent)

EventContainerComponent.EnterStage = {
	Preparing = 1,
	Exited = 0,
	Destroyed = 3,
	Visible = 2
}

function EventContainerComponent:ctor(ctrl, refUContainer, id)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self.eventId = id
	self.eventType = GameEventData[self.eventId].eventType
	self.eventPhase = GameEventData[self.eventId].phase
	self.refContainersLoaded = false
	self.listenerAdded = false
	self.prepareEnterSerial = 0
	self.enterStage = EventContainerComponent.EnterStage.Exited
	self.isDestroyed = false
end

function EventContainerComponent:onDestroy()
	self.isDestroyed = true
	self.prepareEnterSerial = self.prepareEnterSerial + 1
	self.enterStage = EventContainerComponent.EnterStage.Destroyed

	UIComponent.onDestroy(self)

	self.refUContainer = nil
end

function EventContainerComponent:checkContentLoaded()
	return self.refContainersLoaded
end

function EventContainerComponent:onContentLoaded()
	self.refContainersLoaded = true

	self:findObjects()
	self:_addListenerOnce()
	self:onContentReady()
end

function EventContainerComponent:initView()
	if not self:checkContentLoaded() then
		return
	end

	self:_addListenerOnce()
	self:onBeforeRefreshPage()
	self:refreshPage()
end

function EventContainerComponent:onEnterPage(eventId)
	local eventChanged = eventId and self.eventId ~= eventId
	local isCurrentPageShowing = self.enterStage == EventContainerComponent.EnterStage.Visible and self.refUContainer.transform and self.refUContainer.transform.gameObject.activeSelf

	if self:checkContentLoaded() and not eventChanged and isCurrentPageShowing then
		logger:warn("[EventContainerTiming] lightRefresh eventId=%s eventType=%s loaded=true stage=%s", tostring(self.eventId), tostring(self.eventType), tostring(self.enterStage))
		self:onBeforeRefreshPage()
		self:refreshPage()
		self:onEnterPlayEvent()

		return
	end

	if self.isDestroyed then
		return
	end

	self.prepareEnterSerial = self.prepareEnterSerial + 1

	local enterSerial = self.prepareEnterSerial

	self.enterStage = EventContainerComponent.EnterStage.Preparing

	logger:warn("[EventContainerTiming] enterStart serial=%s fromEventId=%s targetEventId=%s loaded=%s eventChanged=%s", tostring(enterSerial), tostring(self.eventId), tostring(eventId), tostring(self:checkContentLoaded()), tostring(eventChanged))

	if eventId and self.eventId ~= eventId then
		self.eventId = eventId
		self.eventType = GameEventData[self.eventId].eventType
		self.eventPhase = GameEventData[self.eventId].phase
	end

	self.refUContainer:SetActive(true)

	if self.refUContainer.transform then
		UIUtils.ScaleVisible(self.refUContainer.transform.gameObject, false)
	end

	if not self:checkContentLoaded() then
		if self.refUContainer:CheckURLLoaded() then
			logger:warn("[EventContainerTiming] rootAlreadyLoaded serial=%s eventId=%s", tostring(enterSerial), tostring(self.eventId))
			self:onContentLoaded()
		else
			logger:warn("[EventContainerTiming] rootLoadStart serial=%s eventId=%s", tostring(enterSerial), tostring(self.eventId))
			self.refUContainer:LoadDefaultUrlManually(function()
				if self.isDestroyed or self.prepareEnterSerial ~= enterSerial then
					logger:warn("[EventContainerTiming] rootLoadSkip serial=%s currentSerial=%s eventId=%s", tostring(enterSerial), tostring(self.prepareEnterSerial), tostring(self.eventId))

					return
				end

				logger:warn("[EventContainerTiming] rootLoadDone serial=%s eventId=%s", tostring(enterSerial), tostring(self.eventId))
				self:onContentLoaded()
				self:_refreshWhenReady(enterSerial)
			end)

			return
		end
	end

	self:_refreshWhenReady(enterSerial)
end

function EventContainerComponent:onExitPage()
	self.prepareEnterSerial = self.prepareEnterSerial + 1
	self.enterStage = EventContainerComponent.EnterStage.Exited

	logger:warn("[EventContainerTiming] exitInvalidate serial=%s eventId=%s eventType=%s stage=%s", tostring(self.prepareEnterSerial), tostring(self.eventId), tostring(self.eventType), tostring(self.enterStage))
	self:onBeforeExitPage()
	self.refUContainer:SetActive(false)
end

function EventContainerComponent:_addListenerOnce()
	if self.listenerAdded then
		return
	end

	self.listenerAdded = true

	self:addListener()
end

function EventContainerComponent:_refreshWhenReady(enterSerial)
	if self.isDestroyed or self.prepareEnterSerial ~= enterSerial then
		logger:warn("[EventContainerTiming] refreshSkip serial=%s currentSerial=%s eventId=%s", tostring(enterSerial), tostring(self.prepareEnterSerial), tostring(self.eventId))

		return
	end

	self:onBeforeRefreshPage()

	local containers = self:collectShowReadyContainers() or {}
	local pendingCount = 0
	local completed = false

	for _, uContainer in ipairs(containers) do
		if uContainer and not uContainer:CheckURLLoaded() then
			pendingCount = pendingCount + 1
		end
	end

	if pendingCount <= 0 then
		logger:warn("[EventContainerTiming] refreshNow serial=%s eventId=%s waitCount=0", tostring(enterSerial), tostring(self.eventId))
		self:refreshPage()
		self:_showPreparedPage(enterSerial)

		return
	end

	logger:warn("[EventContainerTiming] childLoadStart serial=%s eventId=%s waitCount=%s", tostring(enterSerial), tostring(self.eventId), tostring(pendingCount))

	local function onContainerLoaded()
		if completed then
			return
		end

		pendingCount = pendingCount - 1

		if pendingCount <= 0 then
			completed = true

			if self.isDestroyed or self.prepareEnterSerial ~= enterSerial then
				logger:warn("[EventContainerTiming] childLoadSkip serial=%s currentSerial=%s eventId=%s", tostring(enterSerial), tostring(self.prepareEnterSerial), tostring(self.eventId))

				return
			end

			logger:warn("[EventContainerTiming] childLoadDone serial=%s eventId=%s", tostring(enterSerial), tostring(self.eventId))
			self:refreshPage()
			self:_showPreparedPage(enterSerial)
		end
	end

	for _, uContainer in ipairs(containers) do
		if uContainer and not uContainer:CheckURLLoaded() then
			uContainer:SetActive(true)
			uContainer:LoadDefaultUrlManually(onContainerLoaded)
		end
	end
end

function EventContainerComponent:_showPreparedPage(enterSerial)
	if self.isDestroyed or self.prepareEnterSerial ~= enterSerial then
		logger:warn("[EventContainerTiming] showSkip serial=%s currentSerial=%s eventId=%s", tostring(enterSerial), tostring(self.prepareEnterSerial), tostring(self.eventId))

		return
	end

	logger:warn("[EventContainerTiming] showPage serial=%s eventId=%s eventType=%s", tostring(enterSerial), tostring(self.eventId), tostring(self.eventType))

	self.enterStage = EventContainerComponent.EnterStage.Visible

	self.refUContainer:SetActive(true)

	if self.refUContainer.transform then
		UIUtils.ScaleVisible(self.refUContainer.transform.gameObject, true)
	end

	self:onEnterPlayEvent()
end

function EventContainerComponent:refreshCommonNodeRedDot()
	self.model:refreshCommonNodeRedDot(self.eventId)
end

function EventContainerComponent:onEnterPlayEvent()
	local moveInSound = GameEventTypeData[self.eventType] and GameEventTypeData[self.eventType].moveInSound
	local playSound = moveInSound or "SFX_UI_ActivePage_MoveInCommon"

	pg.game.audio:playEvent(playSound)
end

function EventContainerComponent:addListener()
	return
end

function EventContainerComponent:onContentReady()
	return
end

function EventContainerComponent:findObjects()
	return
end

function EventContainerComponent:onBeforeRefreshPage()
	local needShow = pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.EventTypeShowGuide .. self.eventType .. pg.me.uid, true)
	local helpId = GameEventTypeData[self.eventType] and GameEventTypeData[self.eventType].helpId

	if needShow and helpId then
		pg.global.prefsCacheUtils:setBool(ClientConst.PrefKey.EventTypeShowGuide .. self.eventType .. pg.me.uid, false)
		pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
			helpId = helpId
		})
	end
end

function EventContainerComponent:setEventTitle(uContainer, countDownTime, title, timeTitle, ruleDesc, desc, peopleNum)
	self.ctrl:setEventTitle(uContainer, true, GameEventData[self.eventId].textColor or self.model.TitleColor.Black, title or ClientActivityUtils.getEventTitle(self.eventId), timeTitle or pg.getGameString("EVENT_TIME_TIP_5"), countDownTime, ruleDesc or ClientActivityUtils.getEventRule(self.eventId), desc or ClientActivityUtils.getEventDesc(self.eventId), peopleNum)
end

function EventContainerComponent:collectShowReadyContainers()
	return nil
end

function EventContainerComponent:refreshPage()
	return
end

function EventContainerComponent:onBeforeExitPage()
	return
end

return EventContainerComponent
