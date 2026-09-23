-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\EventCommonGuideComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EventCommonGuideComponent")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local GameEventData = require("Data.game_event_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local EventCommonGuideData = require("Data.event_common_guide_data")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Utils = require("Common.Utils.Utils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local GuideHandlerRegistry = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerRegistry")
local EventCommonGuideComponent = Class.LightClass("EventCommonGuideComponent", EventContainerComponent)
local TEA_PARTY_MAP_EVENT_ID = 1885

function EventCommonGuideComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.rootObjectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootUComponent = self.transform:GetChild(0):GetComponent("UComponent")
	self.backgroundUImage = self.rootObjectReference:GetRefValue("backgroundUImage")
	self.eventTitleUContainer = self.rootObjectReference:GetRefValue("eventTitleUContainer")
	self.rewardPreviewUWidget = self.rootObjectReference:GetRefValue("rewardPreviewUWidget")
	self.rewardTitleTxt = self.rootObjectReference:GetRefValue("rewardTitleTxt")
	self.listRewardUList = self.rootObjectReference:GetRefValue("listRewardUList")
	self.btnGotoUButton = self.rootObjectReference:GetRefValue("btnGotoUButton")
	self.btnNameUButton = self.rootObjectReference:GetRefValue("btnNameUButton")
	self.btnReadyUWidget = self.rootObjectReference:GetRefValue("btnReadyUWidget")
	self.btnReadyTxt = self.rootObjectReference:GetRefValue("btnReadyTxt")
	self.rewardContentUWidget = self.rootObjectReference:GetRefValue("rewardContentUWidget")
	self.waterSectorPreheatingUContainer = self.rootObjectReference:GetRefValue("waterSectorPreheatingUContainer")
	self.bossCatchModeUContainer = self.rootObjectReference:GetRefValue("bossCatchModeUContainer")
	self.lockUWidget = self.rootObjectReference:GetRefValue("lockUWidget")
	self.lockUBaseText = self.rootObjectReference:GetRefValue("lockUBaseText")

	local btnGoObjectRef = self.btnGotoUButton:GetComponent("ObjectReference")

	self.btnGotoTxt = btnGoObjectRef:GetRefValue("txtNameUText")

	local btnNameObjectRef = self.btnNameUButton:GetComponent("ObjectReference")

	self.btnNameTxt = btnNameObjectRef:GetRefValue("txtNameUText")
	self.incubateUContainer = self.rootObjectReference:GetRefValue("incubateUContainer")
	self.xYTeaBgUContainer = self.rootObjectReference:GetRefValue("xYTeaBgUContainer")
	self.seasonHubUContainer = self.rootObjectReference:GetRefValue("seasonCollectionUContainer")
	self.bossRushUContainer = self.rootObjectReference:GetRefValue("bossRushUContainer")
	self.starPlanGuideUContainer = self.rootObjectReference:GetRefValue("starPlanGuideUContainer")
	self.redBookUContainer = self.rootObjectReference:GetRefValue("redBookUContainer")
	self.tikTokPetUContainer = self.rootObjectReference:GetRefValue("tikTokPetUContainer")

	local allOwnedRefKeys = {}

	for _, handlerClass in pairs(GuideHandlerRegistry) do
		if handlerClass and handlerClass.getOwnedRefKeys then
			local refKeys = handlerClass:getOwnedRefKeys()

			for _, refKey in ipairs(refKeys) do
				allOwnedRefKeys[refKey] = true
			end
		end
	end

	for refKey, _ in pairs(allOwnedRefKeys) do
		local widget = self.rootObjectReference:GetRefValue(refKey)

		if widget then
			widget:SetActive(false)
		end
	end

	self.curHandler = nil
	self.curHandlerEventType = nil
end

function EventCommonGuideComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	self.commonGuideId = GameEventData[self.eventId] and GameEventData[self.eventId].guideId
	self.commonGuideType = EventCommonGuideData[self.commonGuideId] and EventCommonGuideData[self.commonGuideId].type
	self.preheated = ClientActivityUtils.checkPreHeatDone(self.eventId)
	self.isLock = ActivityUtils.getOprActivityUnlockCond(self.eventId) == false

	self:_prepareHandler()
end

function EventCommonGuideComponent:_prepareHandler()
	local newType = self.eventType

	if self.curHandlerEventType == newType then
		return
	end

	if self.curHandler then
		self.curHandler:onExit()
	end

	local handlerClass = GuideHandlerRegistry[newType]

	if handlerClass then
		self.curHandler = handlerClass.new(self)

		self.curHandler:onFindObjects(self.rootObjectReference)
	else
		self.curHandler = nil
	end

	self.curHandlerEventType = newType
end

function EventCommonGuideComponent:addListener()
	function self.btnGotoUButton.luaClick()
		local commonGuideData = EventCommonGuideData[self.commonGuideId]

		if not commonGuideData then
			if pg.logError() then
				logger:error("@EventCommonGuideComponent commonGuideData is nil, eventId: %d, commonGuideId: %d", self.eventId, self.commonGuideId)
			end

			return
		end

		if self.isLock then
			return
		end

		if self.curHandler and self.curHandler:onButton1() then
			LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_COMMON_GUIDE, {
				event_id = self.eventId
			})

			return
		end

		local gotoEventId = commonGuideData.event1

		if gotoEventId ~= nil then
			pg.me:doEvent(gotoEventId)
		end

		if commonGuideData.linkAddress1 ~= nil then
			pg.global.sdkManager:openUrl("EventCommonGuideComponent", self.eventId, commonGuideData.linkAddress1)
		end

		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_COMMON_GUIDE, {
			event_id = self.eventId
		})
	end

	function self.btnNameUButton.luaClick()
		local commonGuideData = EventCommonGuideData[self.commonGuideId]

		if not commonGuideData then
			if pg.logError() then
				logger:error("@EventCommonGuideComponent commonGuideData is nil, eventId: %d, commonGuideId: %d", self.eventId, self.commonGuideId)
			end

			return
		end

		if self.curHandler and self.curHandler:onButton2() then
			return
		end

		if commonGuideData.event2 then
			pg.me:doEvent(commonGuideData.event2)
		end

		if commonGuideData.linkAddress2 then
			pg.global.sdkManager:openUrl("EventCommonGuideComponent", self.eventId, commonGuideData.linkAddress2)
		end
	end
end

function EventCommonGuideComponent:refreshPage()
	self.rewardPreviewUWidget:SetActive(true)

	local commonGuideData = EventCommonGuideData[self.commonGuideId]
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = commonGuideData.hideCountDown ~= 1 and eventTimeCfg and eventTimeCfg.tabEndDayTime or nil

	eventEndDayTime = commonGuideData.dailyStartTime and self.model:getTeaPartyGuideEndTime(commonGuideData.dailyStartTime) or eventEndDayTime

	self.lockUWidget:SetActive(self.isLock)

	if self.isLock then
		ClientTextUtils.setText(self.lockUBaseText, self.model:getEventLockInfo(self.eventId) or pg.getGameString("HOMELAND_ITEM_UNLOCK_NOT_MET"))
	end

	self.btnGotoUButton.interactable = not self.isLock

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime, pg.getLocalizationText(GameEventData[self.eventId].name))
	self.rootUComponent:TryChangePage("Type", self.commonGuideType - 1)

	if self.commonGuideType ~= ActivityConst.CommonGuideType.WaterAreaPreview then
		self:_refreshCommonShow()
	else
		self:_refreshPreview()
	end

	local rewardTitleText = self.commonGuideType == ActivityConst.CommonGuideType.WaterAreaPreview and pg.getGameString("PRE_REG_AWARD") or pg.getGameString("EVENT_GUIDE_AWARD")
	local rewardDescKey = commonGuideData.rewardDesc
	local rewardText = rewardDescKey and pg.getLocalizationText(rewardDescKey) or nil

	if rewardText then
		rewardTitleText = rewardText
	end

	ClientTextUtils.setText(self.rewardTitleTxt, rewardTitleText)

	self.backgroundUImage.url = commonGuideData.backImage

	self.rewardContentUWidget:SetActive(commonGuideData.showRewardId ~= nil or commonGuideData.preRewardId ~= nil)
	self.btnNameUButton:SetActive(commonGuideData.event2 ~= nil or commonGuideData.linkAddress2 ~= nil)

	local btn2Txt = commonGuideData.btnName2 and pg.getLocalizationText(commonGuideData.btnName2) or pg.getGameString("BUTTON_NAME_REDNOTE")

	ClientTextUtils.setText(self.btnNameTxt, btn2Txt)

	if self.curHandler then
		self.curHandler:onRefresh()
	end

	local containers = self:collectShowReadyContainers()
	local hasExtraContainer = #containers > 0

	self.backgroundUImage:SetActive(not hasExtraContainer)

	if not hasExtraContainer then
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function EventCommonGuideComponent:onDestroy()
	if self.curHandler then
		self.curHandler:onDestroy()
	end

	EventContainerComponent.onDestroy(self)
end

function EventCommonGuideComponent:collectShowReadyContainers()
	local containers = {}
	local containerSet = {}

	if self.commonGuideType == ActivityConst.CommonGuideType.CenterPet then
		if self.bossCatchModeUContainer then
			containers[#containers + 1] = self.bossCatchModeUContainer
			containerSet[self.bossCatchModeUContainer] = true
		end
	elseif self.commonGuideType == ActivityConst.CommonGuideType.WaterAreaPreview and self.waterSectorPreheatingUContainer then
		containers[#containers + 1] = self.waterSectorPreheatingUContainer
		containerSet[self.waterSectorPreheatingUContainer] = true
	end

	if self.curHandler and self.curHandler.getOwnedContainers then
		local containerRefKeys = self.curHandler:getOwnedContainers()

		for _, containerRefKey in ipairs(containerRefKeys) do
			local container = self[containerRefKey]

			if container and not containerSet[container] then
				containers[#containers + 1] = container
				containerSet[container] = true
			end
		end
	end

	return containers
end

function EventCommonGuideComponent:onMoneyChanged()
	if self.curHandler then
		self.curHandler:onMoneyChanged()
	end
end

function EventCommonGuideComponent:onMysteriousMerchantRefresh(err, idList)
	if self.curHandler and self.curHandler.onMysteriousMerchantRefresh then
		self.curHandler:onMysteriousMerchantRefresh(err, idList)
	end
end

function EventCommonGuideComponent:_refreshCommonShow()
	local commonGuideData = EventCommonGuideData[self.commonGuideId]

	self.listRewardUList:SetActive(commonGuideData.showRewardId ~= nil)

	if commonGuideData.showRewardId then
		LuaUIUtils.setRewardListByDropId(self.listRewardUList, commonGuideData.showRewardId)
	end

	local btn1Txt = commonGuideData.btnName1 and pg.getLocalizationText(commonGuideData.btnName1) or pg.getGameString("BUTTON_NAME_4")

	ClientTextUtils.setText(self.btnGotoTxt, btn1Txt)

	local hasGotoEvent = commonGuideData.event1 ~= nil or self.eventType == ActivityConst.EventType.TeaParty
	local handlerNeedBtn1 = self.curHandler == nil or self.curHandler:needBtn1()

	self.btnGotoUButton:SetActive((hasGotoEvent == true or commonGuideData.linkAddress1 ~= nil) and handlerNeedBtn1)
	self.btnReadyUWidget:SetActive(false)
end

function EventCommonGuideComponent:_refreshPreview()
	local commonGuideData = EventCommonGuideData[self.commonGuideId]

	self.listRewardUList:SetActive(commonGuideData.preRewardId ~= nil)
	self.btnReadyUWidget:SetActive(self.preheated)
	ClientTextUtils.setText(self.btnReadyTxt, pg.getGameString("BUTTON_NAME_6"))
	ClientTextUtils.setText(self.btnGotoTxt, pg.getGameString("BUTTON_NAME_5"))

	if commonGuideData.preRewardId then
		LuaUIUtils.setRewardListByDropId(self.listRewardUList, commonGuideData.preRewardId)
	end

	self.btnGotoUButton:SetActive(self.preheated ~= true)
end

return EventCommonGuideComponent
