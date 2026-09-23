-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\EventCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientConst = require("Const.ClientConst")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local Const = require("Common.Const.Const")
local UICtrl = require("Guis.UICtrl")
local PetSaveRootComponent = require("Guis.Panels.Event.Component.PetSaveRootComponent")
local WeekWishComponent = require("Guis.Panels.Event.Component.WeekWishComponent")
local DailyPuppetResearchComponent = require("Guis.Panels.Event.Component.DailyPuppetResearchComponent")
local PhotoSurveyComponent = require("Guis.Panels.Event.Component.PhotoSurveyComponent")
local OfficialGroupComponent = require("Guis.Panels.Event.Component.OfficialGroupComponent")
local CatchRogueComponent = require("Guis.Panels.Event.Component.CatchRogueComponent")
local VitalityContestComponent = require("Guis.Panels.Event.Component.VitalityContestComponent")
local EcologyTraceComponent = require("Guis.Panels.Event.Component.EcologyTraceComponent")
local ArkCarnComponent = require("Guis.Panels.Event.Component.ArkCarnComponent")
local AreaActivityComponent = require("Guis.Panels.Event.Component.AreaActivityComponent")
local ReunionTrainingComponent = require("Guis.Panels.Event.Component.ReunionTrainingComponent")
local SignBaseComponent = require("Guis.Panels.Event.Component.SignBaseComponent")
local EventCommonGuideComponent = require("Guis.Panels.Event.Component.EventCommonGuideComponent")
local PaidWipeTestComponent = require("Guis.Panels.Event.Component.PaidWipeTestComponent")
local PetDispatchHomeComponent = require("Guis.Panels.Event.Component.PetDispatchHomeComponent")
local FirstTopupComponent = require("Guis.Panels.Event.Component.FirstTopupComponent")
local CrossPlatformComponent = require("Guis.Panels.Event.Component.CrossPlatformComponent")
local GameEventData = require("Data.game_event_data")
local GameEventTypeData = require("Data.game_event_type_data")
local PetSaveManualData = require("Data.event_petsave_manual_data")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local LeylineTreeUpComponent = require("Guis.Panels.Event.Component.LeylineTreeUpComponent")
local GrowGiftComponent = require("Guis.Panels.Event.Component.GrowGiftComponent")
local LittleFireFestivalComponent = require("Guis.Panels.Event.Component.LittleFireFestivalComponent")
local BindAccountComponent = require("Guis.Panels.Event.Component.BindAccountComponent")
local FishingCaptureActivityComponent = require("Guis.Panels.Event.Component.FishingCaptureActivityComponent")
local Utils = require("Common.Utils.Utils")
local EventCtrl = Class.LightClass("EventCtrl", UICtrl)

function EventCtrl:getManagedBlurEffect()
	return self.view and self.view.bgBlurUIBlurEffect
end

EventCtrl.messages = {
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"onRefreshCurPage",
		true
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerTeleport",
		true
	},
	[MessageName.EVENT_GET_VITALITY_REWARD] = {
		"onGetVitalityReward",
		true
	},
	[MessageName.EVENT_PETSAVE_CHANGE] = {
		"onPetSaveChange",
		true
	},
	[MessageName.EVENT_REFRESH_TAB_LIST] = {
		"onRefreshTabList",
		true
	},
	[MessageName.UI_ON_CLOSE] = {
		"onUIClose",
		true
	},
	[MessageName.EVENT_VOTE_PET_REFRESH] = {
		"onVotePetRefresh",
		true
	},
	[MessageName.EVENT_VOTE_INFO_PULL] = {
		"onVoteInfoPull",
		true
	},
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onEventRedDotRefresh",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onTaskStageChanged",
		true
	},
	[MessageName.LITTLE_FIRE_PERSON_CHANGE] = {
		"onLittleFirePersonChanged",
		true
	},
	[MessageName.EVENT_MYSTERIOUS_MERCHANT_REFRESH] = {
		"onMysteriousMerchantRefresh",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityDayUpdated",
		true
	},
	[MessageName.CAFE_GATHERING_DAILY_CHANGED] = {
		"onTeaPartyRedDotRefresh",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onRefreshTabList",
		true
	}
}
EventCtrl.EventTypeInfo = {
	[ActivityConst.EventType.PetSave] = {
		container = "petSaveUContainer",
		cls = PetSaveRootComponent
	},
	[ActivityConst.EventType.WeekWish] = {
		container = "prayersUContainer",
		cls = WeekWishComponent
	},
	[ActivityConst.EventType.PuppetCatch] = {
		container = "dailySurveyUContainer",
		cls = DailyPuppetResearchComponent
	},
	[ActivityConst.EventType.PuppetPhoto] = {
		container = "morphologicalSurveyUContainer",
		cls = PhotoSurveyComponent
	},
	[ActivityConst.EventType.OfficialGroup] = {
		container = "officialGroupUContainer",
		cls = OfficialGroupComponent
	},
	[ActivityConst.EventType.CatchRogue] = {
		container = "catchPetUContainer",
		cls = CatchRogueComponent
	},
	[ActivityConst.EventType.EnergyMatch] = {
		container = "vitalityContestUContainer",
		cls = VitalityContestComponent
	},
	[ActivityConst.EventType.EcologyTrace] = {
		container = "ecologicalTraceabilityUContainer",
		cls = EcologyTraceComponent
	},
	[ActivityConst.EventType.ArkCarn] = {
		container = "arkPartyUContainer",
		cls = ArkCarnComponent
	},
	[ActivityConst.EventType.AreaActivity] = {
		container = "waterAreaUContainer",
		cls = AreaActivityComponent
	},
	[ActivityConst.EventType.JourneyTrial] = {
		container = "reunionTrainingUContainer",
		cls = ReunionTrainingComponent
	},
	[ActivityConst.EventType.PetDispatch] = {
		container = "themeMonthUContainer",
		cls = PetDispatchHomeComponent
	},
	[ActivityConst.EventType.RechargeRebate] = {
		container = "paidWipeTestUContainer",
		cls = PaidWipeTestComponent
	},
	[ActivityConst.EventType.LeylineTreeUp] = {
		container = "leylinesTreeUContainer",
		cls = LeylineTreeUpComponent
	},
	[ActivityConst.EventType.GrowthGift] = {
		container = "growthGiftUContainer",
		cls = GrowGiftComponent
	},
	[ActivityConst.EventType.LittleFirePerson] = {
		container = "littleFireFestivalUContainer",
		cls = LittleFireFestivalComponent
	},
	[ActivityConst.EventType.BindAccount] = {
		container = "bindAccountUContainer",
		cls = BindAccountComponent
	},
	[ActivityConst.EventType.FirstTopup] = {
		container = "firstTopupUContainer",
		cls = FirstTopupComponent
	},
	[ActivityConst.EventType.CrossPlatform] = {
		container = "crossPlatformUContainer",
		cls = CrossPlatformComponent
	},
	[ActivityConst.EventType.FishingCapture] = {
		container = "bossCatchUContainer",
		cls = FishingCaptureActivityComponent
	}
}
EventCtrl.UI_CLOSE_ID_WHITE_LIST = {
	[UIConst.UI_ID_APPEARANCE_V2] = true,
	[UIConst.UI_ID_PETEVENT_SETTLEMENT] = true,
	[UIConst.UI_ID_PETEVENT_PETCHOICE] = true,
	[UIConst.UI_ID_PET_ACCESSORY_PRESET] = true,
	[UIConst.UI_ID_ALBUM_SINGLE_PHOTO] = true,
	[UIConst.UI_ID_SHOP_MAIN] = true,
	[UIConst.UI_ID_APPEARANCE_PREVIEW] = true,
	[UIConst.UI_ID_EVENT_PHOTO_RECOGNIZE] = true
}

function EventCtrl:hasActiveTab(tabType)
	local tabList = self.model:getTabList(tabType)

	return #tabList > 0
end

function EventCtrl:getOtherTabType(tabType)
	return tabType == UIConst.EVENT_TAB_TYPE.ACTIVITY and UIConst.EVENT_TAB_TYPE.DAILY or UIConst.EVENT_TAB_TYPE.ACTIVITY
end

function EventCtrl:activateTab(tabType)
	self.curTabType = tabType

	local tabPageIndex = tabType == UIConst.EVENT_TAB_TYPE.ACTIVITY and 0 or 1

	self.view.widget:TryChangePage("EventTab", tabPageIndex)
	self:refreshTabList()
end

function EventCtrl:checkCanOpen(info)
	if not self:hasActiveTab(UIConst.EVENT_TAB_TYPE.ACTIVITY) and not self:hasActiveTab(UIConst.EVENT_TAB_TYPE.DAILY) then
		pg.global.showBubbleMessageRaw(pg.getGameString("EVENT_CENTER_NO_ACTIVITY"))

		return false
	end

	return true
end

function EventCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	self.signComponents = {}

	self:addComponents()

	self.cacheEventIds = {}

	self:initTrackInfo()
end

function EventCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshByOpenInfo(info)
end

function EventCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function EventCtrl:refreshConsoleBarState()
	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if navManager then
		local isCanCheck = false
		local isCanGet = false
		local groupName = navManager.CurrentFocusedGroupName
		local eventType = self.curComponent and self.curComponent.eventType
		local isSuperstar = eventType == ActivityConst.EventType.StarPlanGuidePage
		local isSelectVisible = groupName == "ListReward"

		if eventType == ActivityConst.EventType.GrowthGift or eventType == ActivityConst.EventType.SignNewbie then
			isSelectVisible = false
		elseif eventType == 14 then
			local signPage = self.curComponent and self.curComponent.showPage
			local canGet = isSelectVisible and signPage and signPage:isCurrentItemCanGet() or false

			isSelectVisible = isSelectVisible and not canGet
			isCanGet = canGet
		elseif eventType == ActivityConst.EventType.OfficialGroup then
			isSelectVisible = true
		elseif eventType == ActivityConst.EventType.FirstTopup then
			local focusOnReward = self.curComponent.focusOnReward and self.curComponent:focusOnReward()

			isCanCheck = focusOnReward ~= true
		elseif eventType == ActivityConst.EventType.CrossPlatform then
			local isCurrentTaskCanReceive = self.curComponent.isCurrentTaskCanReceive and self.curComponent:isCurrentTaskCanReceive()

			isCanGet = isCurrentTaskCanReceive == true
		elseif eventType == ActivityConst.EventType.FishingCapture then
			local focusOnReward = self.curComponent.focusOnReward and self.curComponent:focusOnReward()

			isSelectVisible = focusOnReward == true
		elseif eventType == ActivityConst.EventType.PuppetPhoto then
			isSelectVisible = true
		elseif eventType == ActivityConst.EventType.PetDispatch then
			isSelectVisible = true
		end

		local isRuleVisible = true

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Event_Select", isSelectVisible, true)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Event_Rule", isRuleVisible, true)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Event_Check", isCanCheck, true)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Event_Get", isCanGet, true)
	end
end

function EventCtrl:refreshByOpenInfo(info)
	if info and info.tabType then
		local eventId = info.id

		eventId = info.eventType and self.model:getEventIdByEventType(info.eventType) or eventId
		self.cacheEventIds[info.tabType] = eventId
	end

	self:refreshPage(info)
end

function EventCtrl:initTrackInfo()
	self._curEventTrackInfo = nil

	for eventId, data in pairs(GameEventData) do
		if ClientActivityUtils.isEventOpen(eventId) then
			local trackInfo = self.model:getTrackInfo(eventId, data.eventType)

			if trackInfo and trackInfo.hasTrack then
				self._curEventTrackInfo = {
					eventId = eventId,
					markStaticId = trackInfo.markStaticId
				}

				break
			end
		end
	end
end

function EventCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.backUButton.gameObject, "Common/Cancel", function()
		self.view.backUButton.luaClick()
	end)

	function self.view.backUButton.luaClick()
		self:dismiss()
	end

	function self.view.tab1UButton.luaClick()
		local tabType = UIConst.EVENT_TAB_TYPE.ACTIVITY

		if self.curTabType == tabType then
			return
		end

		if not self:hasActiveTab(tabType) then
			pg.global.showBubbleMessageRaw(pg.getGameString("EVENT_CENTER_NO_ACTIVITY"))

			local otherType = self:getOtherTabType(tabType)

			if self:hasActiveTab(otherType) then
				self:activateTab(otherType)
			end

			return
		end

		self:activateTab(tabType)
	end

	function self.view.tab2UButton.luaClick()
		local tabType = UIConst.EVENT_TAB_TYPE.DAILY

		if self.curTabType == tabType then
			return
		end

		if not self:hasActiveTab(tabType) then
			pg.global.showBubbleMessageRaw(pg.getGameString("EVENT_CENTER_NO_ACTIVITY"))

			return
		end

		self:activateTab(tabType)
	end

	function self.view.tabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local contentUBaseText = objectReference:GetRefValue("contentUBaseText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local iconUpUContainer = objectReference:GetRefValue("iconUpUContainer")

		if data.showIconUp then
			iconUpUContainer:SetActive(true)
			iconUpUContainer:LoadDefaultUrlManually(function(obj)
				local txtUWidget = obj:Find("TxtName")

				if txtUWidget then
					local txtUBaseText = txtUWidget:GetComponent("USDFText")

					ClientTextUtils.setText(txtUBaseText, pg.getGameString("UP_EVENT_TIP"))
				end
			end)
		else
			iconUpUContainer:SetActive(false)
		end

		self:setTabImg(iconUImage, contentUBaseText, data)

		local treePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, data.id)

		pg.global.setPreViewRedDot(treePath, button, function()
			if data.isShow then
				return ClientActivityUtils.getEventRedDotStyle(nil, data.id)
			else
				return RedDotConst.RedDotStyle.NONE
			end
		end)
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		self:onRefreshCurrencyItem(button, index, data)
	end

	function self.view.tabUList.luaClick(button, data)
		self.cacheEventIds[data.tabType] = data.id

		local container
		local eventTypeData = GameEventTypeData[data.eventType]
		local eventData = GameEventData[data.id]
		local eventTypeInfo = EventCtrl.EventTypeInfo[data.eventType]

		if eventTypeInfo then
			container = eventTypeInfo.container
		elseif eventData and eventData.guideId then
			container = "commonGuideUContainer"
		elseif eventData and eventData.container then
			container = eventData.container
		end

		if not container then
			logger:error("EventCtrl:tabUList.luaClick eventType:%s can not find avaliable eventTypeInfo ! Pls Regist first!", data.eventType)

			return
		end

		if not self.isProgrammaticTabSelect and self.curComponent and self.curComponent == self[container] and self.curComponent.eventId == data.id then
			return
		end

		if data.isShow then
			if not self[container] then
				logger:error("EventCtrl:tabUList.luaClick container=%s not initialized for eventId=%s eventType=%s", container, data.id, data.eventType)
				pg.global.showBubbleMessageRaw(pg.getGameString("EVENT_LOAD_FAILED_REOPEN"))

				return
			end

			if self.curComponent then
				self.curComponent:onExitPage()
			end

			self.curComponent = self[container]

			if self.curComponent then
				self.curComponent:onEnterPage(data.id)
				self:refreshCurrency()
				self:refreshConsoleBarState()
			end

			local treePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, data.id)

			if data.eventType == ActivityConst.EventType.PetDispatch then
				self.model:redDotDispatchRecordSet(data.id, false)
			elseif data.eventType == ActivityConst.EventType.TeaParty then
				local dailyKey = ClientActivityUtils.getTeaPartyDailyRedDotKey(data.id)

				self.model:redDotRecordSet(dailyKey, false)
			else
				self.model:redDotRecordSet(treePath, false)
			end

			self.model:refreshCommonNodeRedDot(data.id)
		elseif self.curComponent then
			self.curComponent:onExitPage()
		end

		self.view.blurUWidget.gameObject:SetActiveEx(data.eventType ~= ActivityConst.EventType.EnergyMatch)
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.EVENT_TAB1, self.view.tab1UButton, function()
		return ClientActivityUtils.getEventRedDotStyle(UIConst.EVENT_TAB_TYPE.ACTIVITY)
	end)
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.EVENT_TAB2, self.view.tab2UButton, function()
		return ClientActivityUtils.getEventRedDotStyle(UIConst.EVENT_TAB_TYPE.DAILY)
	end)

	function self.removeMapMarkTrace(spawnerId)
		self:onMapMarkTraceRemove(spawnerId)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self.removeMapMarkTrace)

	if pg.global.navMgr then
		self:addNavFocusListener(function()
			self:refreshConsoleBarState()
		end, "EventConsoleBar")
	end
end

function EventCtrl:setTabImg(icon, tex, data)
	if data.eventType == ActivityConst.EventType.PetSave then
		local curWeekCfg = self.model:checkPetSaveCurWeekCfg()

		if curWeekCfg then
			ClientTextUtils.setText(tex, pg.getLocalizationText(curWeekCfg.taskName))
			self:setImage(icon, curWeekCfg.iconResId)
		end

		return
	end

	ClientTextUtils.setText(tex, pg.getLocalizationText(data.text))
	self:setImage(icon, data.icon)
end

function EventCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.curComponent = nil
	self.cacheEventIds = nil
	self.curTabList = nil

	self:removeComponents()

	local tips = pg.global.ui.tips

	if tips and tips.dispatcher then
		tips.dispatcher:tryNext()
	end

	if self.removeMapMarkTrace then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_TRACE_REMOVE, self.removeMapMarkTrace)
	end
end

function EventCtrl:onShow()
	return
end

function EventCtrl:onHide()
	return
end

function EventCtrl:addComponents()
	for eventType, data in pairs(GameEventTypeData) do
		if data.tabType < UIConst.EVENT_TAB_TYPE.SCHOOL_GUIDE then
			local eventId = self.model:getEventIdByEventType(eventType)

			if eventId then
				local eventTypeInfo = EventCtrl.EventTypeInfo[eventType]
				local eventData = eventId and GameEventData[eventId]

				if eventTypeInfo then
					local container = eventTypeInfo.container

					if not self.view[container] then
						logger:error("EventCtrl:addComponents eventType:%s container=%s not found in view ! Pls export ref first!", eventType, container)
					elseif not self[container] then
						self[container] = eventTypeInfo.cls.new(self, self.view[container], eventId)
					end
				elseif eventData and eventData.guideId then
					local container = "commonGuideUContainer"

					if not self[container] then
						self[container] = EventCommonGuideComponent.new(self, self.view[container], eventId)
					end
				elseif eventData and eventData.container then
					local container = eventData.container

					if not self.view[container] then
						logger:error("EventCtrl:addComponents eventType:%s container=%s not found in view ! Pls export ref first!", eventType, eventData.container)
					elseif not self[container] then
						self[container] = SignBaseComponent.new(self, self.view[container], eventId)
						self.signComponents[container] = self[container]
					end
				else
					logger:error("EventCtrl:addComponents eventType:%s can not find avaliable eventTypeInfo ! Pls Regist first!", eventType)
				end
			else
				logger:warn("EventCtrl:addComponents eventType:%s can not find avaliable eventId !", eventType)
			end
		end
	end
end

function EventCtrl:removeComponents()
	for eventType, data in pairs(GameEventTypeData) do
		if data.tabType < UIConst.EVENT_TAB_TYPE.SCHOOL_GUIDE then
			local eventTypeInfo = EventCtrl.EventTypeInfo[eventType]

			if eventTypeInfo and self[eventTypeInfo.container] then
				self[eventTypeInfo.container] = nil
			end
		end
	end

	self.commonGuideUContainer = nil

	if self.signComponents then
		for containerName in pairs(self.signComponents) do
			self[containerName] = nil
		end

		self.signComponents = nil
	end
end

function EventCtrl:refreshPage(info)
	ClientTextUtils.setText(self.view.titleUBaseText, pg.getGameString("GAME_EVENT"))

	self.view.tab2UButton.enabledVisualSelect = false
	self.view.tab2UButton.visualInteractable = self:hasActiveTab(UIConst.EVENT_TAB_TYPE.DAILY)

	local preferType = info and info.tabType or UIConst.EVENT_TAB_TYPE.ACTIVITY

	if self:hasActiveTab(preferType) then
		self:activateTab(preferType)
	else
		self:activateTab(self:getOtherTabType(preferType))
	end
end

function EventCtrl:refreshTabList()
	local tabList = self.model:getTabList(self.curTabType)

	self.curTabList = tabList

	self.view.tabUList:SetList(tabList)

	local cacheEventId = self.cacheEventIds[self.curTabType]
	local isFound = false

	self.isProgrammaticTabSelect = true

	local ok, err = pcall(function()
		if cacheEventId then
			for idx, tabInfo in ipairs(tabList) do
				if cacheEventId == tabInfo.id then
					local res, button = self.view.tabUList:TryGetChildAt(idx - 1)

					if res then
						isFound = true

						button:OnClickSimulate()
						self.view.tabUList:RedirectToCenter(idx - 1, false, true)

						break
					end
				end
			end
		end

		if not isFound then
			for idx, tabInfo in ipairs(tabList) do
				if tabInfo.isShow then
					local res, button = self.view.tabUList:TryGetChildAt(idx - 1)

					if res then
						button:OnClickSimulate()

						break
					end
				end
			end
		end
	end)

	self.isProgrammaticTabSelect = false

	if not ok then
		error(err)
	end
end

function EventCtrl:refreshTabTexts()
	if not self.curTabList then
		return
	end

	for idx, tabInfo in ipairs(self.curTabList) do
		local text = self.model:getTabText(tabInfo.id)

		if text and text ~= tabInfo.text then
			tabInfo.text = text

			self.view.tabUList:RefreshElement(idx - 1)
		end
	end
end

function EventCtrl:setTabListVisible(visible)
	self.view.leftTabUWidget.gameObject:SetActiveEx(visible)
	self.view.tab1UButton.gameObject:SetActiveEx(visible)
	self.view.tab2UButton.gameObject:SetActiveEx(visible)
	self.view.titleUWidget.gameObject:SetActiveEx(visible)
end

function EventCtrl:startEventTrack(newEventId, staticId, cb)
	if not newEventId or not staticId or not cb then
		return
	end

	if self._curEventTrackInfo then
		local oriEventId = self._curEventTrackInfo.eventId
		local oriStaticId = self._curEventTrackInfo.markStaticId
		local oriEventType = GameEventData[oriEventId].eventType

		pg.global.showConfirmMsgRaw(pg.getGameString("WEEKEND_PRAY_CONFIRM_TITLE"), pg.getGameString("WEEKEND_PRAY_CONFIRM_DESC"), function()
			pg.game.map:manualUnTraceQuestMark(oriStaticId)
			cb()

			self._curEventTrackInfo = self._curEventTrackInfo or {}
			self._curEventTrackInfo.eventId = newEventId
			self._curEventTrackInfo.markStaticId = staticId
		end, nil)
	else
		cb()

		self._curEventTrackInfo = {
			eventId = newEventId,
			markStaticId = staticId
		}
	end
end

function EventCtrl:setImage(img, url)
	if not img then
		return
	end

	if string.startsWith(url, "http") then
		img:SetTextureByUrl(url)
	else
		img.url = url
	end
end

function EventCtrl:onRefreshCurrencyItem(button, index, data)
	local objectReference = button.transform:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("iconUImage")
	local countTxt = objectReference:GetRefValue("countUText")

	icon.url = LuaUIUtils.getIconByItemId(data.id, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

	local count = pg.me:getItemCountById(data.id)

	ClientTextUtils.setText(countTxt, count)

	button.name = tostring(data.id)

	function button.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = data.id,
			num = count,
			targetRect = button
		})
	end
end

function EventCtrl:refreshCurrency()
	if not self.curComponent then
		return
	end

	local currencyItems

	if self.curComponent.getCurrencyItems then
		currencyItems = self.curComponent:getCurrencyItems()
	end

	currencyItems = currencyItems or self.model:getEventCurrency(self.curComponent.eventType)

	local showCurrency = currencyItems and next(currencyItems)

	self.view.currencyUComponent.gameObject:SetActiveEx(showCurrency)
	self.view.listCurrencyUList.gameObject:SetActiveEx(showCurrency)

	if showCurrency then
		self.view.listCurrencyUList:SetList(currencyItems)
	end
end

function EventCtrl:setUnlockPanel(visible, eventId)
	local state = visible and 1 or 0

	self.view.widget:TryChangePage("Unlock", state)

	if visible then
		local condStr = self.model:getEventLockInfo(eventId)

		ClientTextUtils.setText(self.view.unlockTxtName, condStr)
	end
end

function EventCtrl:setCommonTitle(isVisible, loadCallBack, uContainer)
	local titleContainer = uContainer or self.view.eventTitleUContainer

	if isVisible then
		titleContainer:SetActive(true)

		if titleContainer:CheckURLLoaded() then
			if loadCallBack then
				loadCallBack(titleContainer.content)
			end
		else
			titleContainer:LoadDefaultUrlManually(loadCallBack)
		end
	else
		titleContainer:SetActive(false)
	end
end

function EventCtrl:setEventTitle(uContainer, isVisible, showType, title, timeTitle, countDownTime, ruleDesc, desc, peopleNum)
	self:setCommonTitle(isVisible, function(content)
		local objectRef = content.transform:GetChild(0):GetComponent("ObjectReference")
		local rootUComponent = objectRef:GetRefValue("rootUComponent")
		local txtTitleUBaseText = objectRef:GetRefValue("txtTitleUBaseText")
		local txtTitleUBaseText2 = objectRef:GetRefValue("txtTitleUBaseText2")
		local txtTimeTitleText = objectRef:GetRefValue("txtTimeTitleText")
		local countDownUCountDown = objectRef:GetRefValue("countDownUCountDown")
		local btnInfoUButton = objectRef:GetRefValue("btnInfoUButton")
		local txtPeopleNumUBaseText = objectRef:GetRefValue("txtPeopleNumUBaseText")
		local scrollRectUScrollRect = objectRef:GetRefValue("scrollRectUScrollRect")
		local scrollRectUScrollRect2 = objectRef:GetRefValue("scrollRectUScrollRect2")
		local peopleUWidget = objectRef:GetRefValue("peopleUWidget")
		local countDownRootUWidget = objectRef:GetRefValue("countDownRootUWidget")
		local timeUWidget = objectRef:GetRefValue("timeUWidget")
		local btnInfoNameTxt = objectRef:GetRefValue("btnInfoNameTxt")

		rootUComponent:TryChangePage("Title", showType)
		peopleUWidget:SetActive(peopleNum)
		countDownRootUWidget:SetActive(countDownTime)

		if timeUWidget then
			timeUWidget:SetActive(countDownTime or ruleDesc)
		end

		ClientTextUtils.setText(txtTitleUBaseText, title)

		if txtTitleUBaseText2 then
			ClientTextUtils.setText(txtTitleUBaseText2, title)
		end

		ClientTextUtils.setText(scrollRectUScrollRect.content, desc)

		if scrollRectUScrollRect2 then
			ClientTextUtils.setText(scrollRectUScrollRect2.content, desc)
		end

		if timeTitle then
			ClientTextUtils.setText(txtTimeTitleText, timeTitle)
		end

		if peopleNum then
			ClientTextUtils.setText(txtPeopleNumUBaseText, peopleNum)
		end

		if btnInfoNameTxt then
			ClientTextUtils.setText(btnInfoNameTxt, pg.getGameString("BATTLEPASS_RULE_TITLE"))
		end

		local needInfo = ruleDesc ~= nil

		btnInfoUButton:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, not needInfo)

		if needInfo then
			function btnInfoUButton.luaClick()
				pg.global.ui.tips:openEventRuleDesc(ruleDesc)
			end

			if btnInfoUButton.activeCtrlValid then
				btnInfoUButton:RefreshActiveCtrl()
			else
				btnInfoUButton:SetActive(true)
			end
		else
			btnInfoUButton:SetActive(false)
		end

		if countDownTime then
			LuaUIUtils.setCountDownTime(countDownUCountDown, countDownTime, UIConst.TimeType.Short)
		end
	end, uContainer)
end

function EventCtrl:onMapMarkTraceRemove(spawnerId)
	if self._curEventTrackInfo and self._curEventTrackInfo.markStaticId == spawnerId then
		local eventId = self._curEventTrackInfo.eventId

		self._curEventTrackInfo = nil

		if self.curComponent and self.curComponent.eventId == eventId and self.curComponent.refreshPage then
			self.curComponent:refreshPage()
		end
	end
end

function EventCtrl:onTeaPartyRedDotRefresh()
	self.model:refreshCommonNodeRedDot()
end

function EventCtrl:onActivityDayUpdated()
	self.model:refreshCommonNodeRedDot()

	if self.curComponent and self.curComponent.onActivityDayUpdated then
		self.curComponent:onActivityDayUpdated()
	end

	if self.curTabType and self.refreshTabList then
		self:refreshTabList()
	end
end

function EventCtrl:onRefreshCurPage()
	if self.curComponent and self.curComponent.onEnterPage then
		self.curComponent:onEnterPage()
	end

	self:refreshTabTexts()
	self.model:refreshCommonNodeRedDot(self.curComponent and self.curComponent.eventId)
end

function EventCtrl:onVoteInfoPull(info)
	if not self.curComponent then
		return
	end

	local response = info.response
	local eventType = info.eventType

	if eventType == ActivityConst.EventType.ArkCarn then
		if self.curComponent.eventType == ActivityConst.EventType.ArkCarn and self.curComponent:checkContentLoaded() then
			self.curComponent:refreshVotePets()
		end
	elseif eventType == ActivityConst.EventType.WeekWish then
		self.model:setWeekWishVoteInfo(response)

		if self.curComponent.eventType == ActivityConst.EventType.WeekWish and self.curComponent:checkContentLoaded() then
			self.curComponent:refreshPage()
		end
	end
end

function EventCtrl:onVotePetRefresh()
	if not self.curComponent then
		return
	end

	if self.curComponent.eventType == ActivityConst.EventType.ArkCarn and self.curComponent:checkContentLoaded() then
		self.curComponent:refreshPage()
	end
end

function EventCtrl:onGetVitalityReward()
	if self.curComponent and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end
end

function EventCtrl:onPetSaveChange()
	if self.curComponent and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end
end

function EventCtrl:onTaskStageChanged(info)
	if self.curComponent and self.curComponent.onTaskStageChanged then
		self.curComponent:onTaskStageChanged(info)
	elseif self.curComponent and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end

	self:refreshConsoleBarState()
	self.model:refreshCommonNodeRedDot(self.curComponent and self.curComponent.eventId)
end

function EventCtrl:onLittleFirePersonChanged()
	if self.curComponent and self.curComponent.eventType == ActivityConst.EventType.LittleFirePerson and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end
end

function EventCtrl:onPlayerTeleport()
	self:dismiss()
end

function EventCtrl:onRefreshTabList()
	local hasActivity = self:hasActiveTab(UIConst.EVENT_TAB_TYPE.ACTIVITY)
	local hasDaily = self:hasActiveTab(UIConst.EVENT_TAB_TYPE.DAILY)

	self.view.tab2UButton.visualInteractable = hasDaily

	if not hasActivity and not hasDaily then
		pg.global.showBubbleMessageRaw(pg.getGameString("EVENT_CENTER_NO_ACTIVITY"))
		self:close()

		return
	end

	self:addComponents()

	local curHasContent = self.curTabType == UIConst.EVENT_TAB_TYPE.ACTIVITY and hasActivity or hasDaily

	if not curHasContent then
		self:activateTab(self:getOtherTabType(self.curTabType))
	else
		self:refreshTabList()
	end
end

function EventCtrl:onUIClose(uid)
	if not uid or EventCtrl.UI_CLOSE_ID_WHITE_LIST[uid] or not UIConst.UI_CONFIGS[uid] or UIConst.UI_CONFIGS[uid].uiType == UIConst.INFOS_LAYER or UIConst.UI_CONFIGS[uid].uiType == UIConst.POPUP_LAYER then
		return
	end

	if self.curComponent and self.curComponent:checkContentLoaded() and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end

	self.model:refreshCommonNodeRedDot(self.curComponent and self.curComponent.eventId)
end

function EventCtrl:onEventRedDotRefresh()
	if self.curComponent and self.curComponent.refreshRedDotState then
		self.curComponent:refreshRedDotState()
	end

	self.model:refreshCommonNodeRedDot(self.curComponent and self.curComponent.eventId)
end

function EventCtrl:onMoneyChanged()
	self:refreshCurrency()

	if self.curComponent and self.curComponent.onMoneyChanged then
		self.curComponent:onMoneyChanged()
	end

	self.model:refreshCommonNodeRedDot(self.curComponent and self.curComponent.eventId)
end

function EventCtrl:onMysteriousMerchantRefresh(messageBody)
	if self.curComponent and self.curComponent.onMysteriousMerchantRefresh then
		self.curComponent:onMysteriousMerchantRefresh(messageBody.err, messageBody.idList)
	end
end

return EventCtrl
