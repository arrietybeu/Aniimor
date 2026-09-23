-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapturePetalSource\\FishingCapturePetalSourceCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local Time = require("Core.Common.Time")
local RedDotConst = require("Const.RedDotConst")
local ItemConst = require("Common.Const.ItemConst")
local ItemSourceData = require("Data.item_source_data")
local GameEventData = require("Data.game_event_data")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local FishingCapturePetalSourceCtrl = Class.LightClass("FishingCapturePetalSourceCtrl", UICtrl)

FishingCapturePetalSourceCtrl.GroupTabTitleKey = {
	[1] = "FC_HUABANGET_WEEK",
	[2] = "FC_HUABANGET_ONETIME"
}
FishingCapturePetalSourceCtrl.GroupTabRuleField = {
	[1] = "TabRule2",
	[2] = "TabRule1"
}
FishingCapturePetalSourceCtrl.messages = {
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityDayUpdated",
		true
	}
}

function FishingCapturePetalSourceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.model:setInfo(info)

	self._lastFocusedChannel = nil

	self:refreshInfo()

	self._lastVisible = nil
end

function FishingCapturePetalSourceCtrl:onVisibleChange(visible)
	if visible and self._lastVisible == false then
		self:refreshDataAndView()
	end

	self._lastVisible = visible
end

function FishingCapturePetalSourceCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:dismiss()
		end

		self:bindCloseButton(self.view.btnBackUButton)
	end

	if self.view.groupTabUList then
		function self.view.groupTabUList.luaRenderItem(button, index, data)
			self:_renderGroupTab(button, index, data)
		end

		function self.view.groupTabUList.luaCheckCanSelected(data)
			return data ~= nil and not data.locked
		end

		function self.view.groupTabUList.luaClick(_, data)
			self:onGroupTabClick(data)
		end
	end

	if self.view.channelUList then
		function self.view.channelUList.luaRenderItem(button, index, data)
			self:_renderChannel(button, index, data)
		end

		function self.view.channelUList.luaClick(_, data)
			self:onChannelClick(data)
		end

		function self.view.channelUList.luaFinishRender()
			if self._lastFocusedChannel then
				self:restoreNavFocus()
			end
		end
	end
end

function FishingCapturePetalSourceCtrl:refreshDataAndView()
	self.model:refreshData()
	self:refreshInfo()
end

function FishingCapturePetalSourceCtrl:refreshInfo()
	if self.view.backTxt then
		local info = self.model:getInfo()
		local eventId = info.eventId
		local eventData = GameEventData and GameEventData[eventId]
		local activityData = eventData and FishingCaptureActivityData and FishingCaptureActivityData[eventData.phase]

		ClientTextUtils.setText(self.view.backTxt, pg.getLocalizationText(activityData.getcoin))
	end

	self:_refreshItemInfo()

	self.visibleGroups = self.model:getVisibleGroups()

	if self.weeklyTabButton and pg and pg.global and pg.global.setRedDot then
		pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_WEEKLY_TAB, self.weeklyTabButton, false, RedDotConst.RedDotStyle.NEW)
	end

	self.weeklyTabButton = nil

	if self.view.groupTabUList then
		self.view.groupTabUList:SetList(self.visibleGroups)
	end

	if self.view.groupTabUWidget then
		self.view.groupTabUWidget:SetActive(#self.visibleGroups >= 2)
	end

	self.view.widget:TryChangePage("Tab", #self.visibleGroups >= 2 and 0 or 1)

	if self.view.emptyUWidget then
		self.view.emptyUWidget:SetActive(#self.visibleGroups == 0)
	end

	local selectedGroup, selectedIndex = self:_findSelectableGroup(self.selectedGroupType)

	if not selectedGroup then
		self.selectedGroupType = nil

		if self.view.channelUList then
			self.view.channelUList:SetList({})
		end

		self:refreshRedDotState()

		return
	end

	self:selectGroup(selectedGroup.groupType)

	if self.view.groupTabUList then
		self.view.groupTabUList:SelectItem(selectedIndex - 1, false)
	end

	self:refreshRedDotState()
end

function FishingCapturePetalSourceCtrl:_refreshItemInfo()
	local info = self.model:getItemInfo() or {}

	if self.view.itemNameUBaseText and info.nameId ~= nil then
		ClientTextUtils.setText(self.view.itemNameUBaseText, pg.getLocalizationText(info.nameId))
	end

	if self.view.itemCountUBaseText then
		ClientTextUtils.setText(self.view.itemCountUBaseText, tostring(info.count or 0))
	end

	if self.view.itemDescUBaseText and info.descId ~= nil then
		ClientTextUtils.setText(self.view.itemDescUBaseText, pg.getLocalizationText(info.descId))
	end
end

function FishingCapturePetalSourceCtrl:_findVisibleGroup(groupType)
	for index, group in ipairs(self.visibleGroups or {}) do
		if group.groupType == groupType then
			return group, index
		end
	end

	return nil, nil
end

function FishingCapturePetalSourceCtrl:_findSelectableGroup(groupType)
	local group, index = self:_findVisibleGroup(groupType)

	if group and not group.locked then
		return group, index
	end

	for visibleIndex, visibleGroup in ipairs(self.visibleGroups or EMPTY_TABLE) do
		if not visibleGroup.locked then
			return visibleGroup, visibleIndex
		end
	end

	return nil, nil
end

function FishingCapturePetalSourceCtrl:_buildChannelDisplayList(channels)
	local displayList = {}

	for _, channel in ipairs(channels or EMPTY_TABLE) do
		local displayData = {}

		for key, value in pairs(channel) do
			displayData[key] = value
		end

		displayData.tIndex = 0
		displayList[#displayList + 1] = displayData
	end

	return displayList
end

function FishingCapturePetalSourceCtrl:selectGroup(groupType)
	local group = self:_findVisibleGroup(groupType)

	if not group or group.locked then
		return
	end

	self.selectedGroupType = groupType

	if self.view.channelUList then
		self.view.channelUList:SetList(self:_buildChannelDisplayList(group.channels))
	end

	self:refreshRedDotState()
end

function FishingCapturePetalSourceCtrl:onGroupTabClick(data)
	if not data then
		return
	end

	if data.locked then
		if pg.game.input:isUsingGamepad() then
			pg.global.showBubbleMessageRaw(pg.getGameString("FC_PHASE_CLOSE_TEXT"))
		end

		local selectedGroup, selectedIndex = self:_findSelectableGroup(self.selectedGroupType)

		if selectedGroup and self.view.groupTabUList then
			self.view.groupTabUList:SelectItem(selectedIndex - 1, false)
		end

		return
	end

	if self.selectedGroupType == data.groupType then
		if data.groupType == self.model.GroupType.Weekly then
			self:_clearWeeklyRedDot()
			self:refreshRedDotState()
		end

		return
	end

	self._lastFocusedChannel = nil

	if self.view.channelUList then
		self.view.channelUList:SetNavGroupDefaultItemInThis(nil)
	end

	self:selectGroup(data.groupType)

	if data.groupType == self.model.GroupType.Weekly then
		self:_clearWeeklyRedDot()
		self:refreshRedDotState()
	end
end

function FishingCapturePetalSourceCtrl:_openRuleDesc(groupType)
	local info = self.model:getInfo()
	local eventData = GameEventData[info.eventId]
	local activityData = FishingCaptureActivityData[eventData.phase]
	local ruleDesc = activityData[self.GroupTabRuleField[groupType]]

	pg.global.ui.tips:openEventRuleDesc(ruleDesc, "FC_SPECIFIC_TITLE")
end

function FishingCapturePetalSourceCtrl:refreshRedDotState()
	if not self.weeklyTabButton or not pg or not pg.global or not pg.global.setRedDot then
		return
	end

	local weeklyGroup = self:_findVisibleGroup(self.model.GroupType.Weekly)

	if not weeklyGroup or weeklyGroup.locked or #self.visibleGroups < 2 then
		return
	end

	local info = self.model:getInfo()

	if not info.eventId then
		return
	end

	local state = ClientActivityUtils.getFishingCaptureRedDotState(info.eventId)

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_WEEKLY_TAB, self.weeklyTabButton, state.weeklyNew, RedDotConst.RedDotStyle.NEW)
end

function FishingCapturePetalSourceCtrl:_clearWeeklyRedDot()
	local info = self.model:getInfo()

	if not info.eventId then
		return
	end

	ClientActivityUtils.clearFishingCaptureRedDot(info.eventId, ClientActivityUtils.FishingCaptureRedDotName.Weekly, TimeUtils.getAreaWeekBegin(Time.secondCache))
end

function FishingCapturePetalSourceCtrl._getWeeklyRefreshTime()
	return TimeUtils.getAreaCurOrNextWeekResetTime(Time.secondCache, Utils.getWeekRefreshDayOfWeek(), Utils.getDayRefreshTime(), 0, 0)
end

function FishingCapturePetalSourceCtrl:_renderGroupTab(button, _, data)
	if not button then
		return
	end

	button.navForceNonInteractable = data.locked == true

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local rootBtn = objectReference:GetRefValue("rootBtn")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local txtNameTextPlus = objectReference:GetRefValue("txtNameTextPlus")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	local btnLockInfoUButton = objectReference:GetRefValue("btnLockInfoUButton")

	if rootBtn then
		rootBtn:TryChangePage("Group", data.groupType)
		rootBtn:TryChangePage("Lock", data.locked and 1 or 0)
		rootBtn:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart, nil, function()
			if data.locked or self.selectedGroupType ~= data.groupType then
				return true
			end

			self:_openRuleDesc(data.groupType)

			return false
		end)
	end

	local titleKey = self.GroupTabTitleKey[data.groupType]
	local titleText = pg.getGameString(titleKey)
	local weeklyTitleText

	if not data.locked and data.groupType == self.model.GroupType.Weekly then
		weeklyTitleText = string.format("%s %s", titleText, ClientActivityUtils.getFishingCaptureDayHourText(FishingCapturePetalSourceCtrl._getWeeklyRefreshTime()))
	end

	if txtNameUBaseText then
		ClientTextUtils.setText(txtNameUBaseText, weeklyTitleText or titleText)
	end

	if txtNameTextPlus then
		local plusTitleText = weeklyTitleText or titleText

		if data.locked and data.unlockTime then
			plusTitleText = string.format("%s %s", titleText, ClientActivityUtils.getFishingCaptureDayHourText(data.unlockTime))
		end

		ClientTextUtils.setText(txtNameTextPlus, plusTitleText)
	end

	if btnInfoUButton then
		btnInfoUButton.enabledTooltip = false

		btnInfoUButton:SetActive(not data.locked)

		if pg.game.input:isUsingGamepad() then
			btnInfoUButton:SetActive(false)
		end

		btnInfoUButton.luaClick = nil

		if not data.locked then
			function btnInfoUButton.luaClick()
				self:_openRuleDesc(data.groupType)
			end
		end
	end

	if btnLockInfoUButton then
		btnLockInfoUButton.luaClick = nil

		if data.locked then
			function btnLockInfoUButton.luaClick()
				pg.global.showBubbleMessageRaw(pg.getGameString("FC_PHASE_CLOSE_TEXT"))
			end
		end
	end

	if data.groupType == self.model.GroupType.Weekly then
		self.weeklyTabButton = button

		self:refreshRedDotState()
	end
end

function FishingCapturePetalSourceCtrl:_renderChannel(button, _, data)
	data = data or {}

	if not button or not button.GetComponent then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local rootBtn = objectReference:GetRefValue("rootBtn")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local progressUBaseText = objectReference:GetRefValue("progressUBaseText")
	local remainTimeUWidget = objectReference:GetRefValue("remainTimeUWidget")
	local remainTimeTxt = objectReference:GetRefValue("remainTimeTxt")
	local lockTxt = objectReference:GetRefValue("lockTxt")
	local btnTipUButton = objectReference:GetRefValue("btnTipUButton")
	local itemPath = data.groupType == self.model.GroupType.Weekly and string.format(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_WEEKLY_ITEM, tostring(data.id))

	if itemPath then
		pg.global.setRedDot(itemPath, button, data.newRedDot == true, RedDotConst.RedDotStyle.NEW)
	end

	local state = data.state or self.model.ChannelState.Normal

	if rootBtn then
		rootBtn:TryChangePage("State", state)
	end

	if iconUImage and data.icon then
		iconUImage.url = data.icon
	end

	if nameUBaseText and data.nameId ~= nil then
		ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(data.nameId))
	end

	if progressUBaseText and data.logText ~= nil then
		progressUBaseText.supportRichText = true

		ClientTextUtils.setText(progressUBaseText, string.format("%s%s", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_BOSS_CAPTURE_COIN), pg.getLocalizationText(data.logText)))
	elseif progressUBaseText and data.current ~= nil and data.target ~= nil then
		progressUBaseText.supportRichText = true

		ClientTextUtils.setText(progressUBaseText, string.format("%s%s/%s", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_BOSS_CAPTURE_COIN), data.current, data.target))
	end

	local countdownType = data.countdownType or self.model.ChannelCountdownType.None

	if rootBtn then
		rootBtn:TryChangePage("Time", countdownType)
	end

	local showConditionText = state == self.model.ChannelState.Locked and data.conditionMet == false and data.conditionText ~= nil
	local showLockTime = not showConditionText and countdownType == self.model.ChannelCountdownType.Open and data.countdownTarget ~= nil

	if lockTxt then
		lockTxt:SetActive(showConditionText or showLockTime)

		if showConditionText then
			ClientTextUtils.setText(lockTxt, pg.getLocalizationText(data.conditionText))
		elseif showLockTime then
			ClientTextUtils.setText(lockTxt, ClientActivityUtils.getFishingCaptureDayHourText(data.countdownTarget, "FC_CONDITION_TIME_TEXT"))
		end
	end

	local showRemainTime = state ~= self.model.ChannelState.Completed and countdownType == self.model.ChannelCountdownType.End and data.countdownTarget ~= nil

	if remainTimeUWidget then
		remainTimeUWidget:SetActive(showRemainTime)
	end

	if showRemainTime and remainTimeTxt then
		ClientTextUtils.setText(remainTimeTxt, ClientActivityUtils.getFishingCaptureDayHourText(data.countdownTarget, "FC_CONDITION_TIMEDOWN_TEXT"))
	end

	if btnTipUButton then
		btnTipUButton.luaClick = nil

		if state == self.model.ChannelState.Locked then
			function btnTipUButton.luaClick()
				self:onChannelTipClick(data)
			end
		end
	end
end

function FishingCapturePetalSourceCtrl:onChannelClick(data)
	if not data or not data.sourceId then
		return
	end

	local sourceData = ItemSourceData[data.sourceId]

	if sourceData then
		self._lastFocusedChannel = {
			groupType = data.groupType,
			id = data.id,
			sourceId = data.sourceId
		}

		LuaUIUtils.clueSeek(sourceData)

		if data.groupType == self.model.GroupType.Weekly then
			if tonumber(data.id) == 10 and data.newRedDot then
				ClientActivityUtils.clearFishingCaptureRedDot(self.model:getInfo().eventId, ClientActivityUtils.FishingCaptureRedDotName.WeeklyItem, tostring(data.id))
			end

			self:_clearWeeklyRedDot()
			self:refreshRedDotState()
		end
	end
end

function FishingCapturePetalSourceCtrl:onChannelTipClick(data)
	if not data or data.state ~= self.model.ChannelState.Locked or not data.sourceId then
		return
	end

	if data.countdownType == self.model.ChannelCountdownType.Open then
		pg.global.showBubbleMessageRaw(ClientActivityUtils.getFishingCaptureDayHourText(data.countdownTarget, "FC_CONDITION_TIME_TEXT"))

		return
	end

	if data.countdownType == self.model.ChannelCountdownType.Ended then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))

		return
	end

	local sourceData = ItemSourceData[data.sourceId]

	if sourceData then
		self._lastFocusedChannel = {
			groupType = data.groupType,
			id = data.id,
			sourceId = data.sourceId
		}

		LuaUIUtils.clueSeek(sourceData)
	end
end

function FishingCapturePetalSourceCtrl:onActivityDayUpdated()
	self:refreshDataAndView()
end

function FishingCapturePetalSourceCtrl:restoreNavFocus()
	local focusedChannel = self._lastFocusedChannel

	self._lastFocusedChannel = nil

	local usingGamepad = pg.game.input:isUsingGamepad()

	if not focusedChannel then
		return
	end

	if not usingGamepad then
		return
	end

	local group = self:_findVisibleGroup(focusedChannel.groupType)

	if not group then
		return
	end

	if group.locked then
		return
	end

	if self.selectedGroupType ~= focusedChannel.groupType then
		return
	end

	if not self.view.channelUList then
		return
	end

	for index, channel in ipairs(group.channels) do
		if channel.id == focusedChannel.id and channel.sourceId == focusedChannel.sourceId then
			local listIndex = index - 1
			local hasButton, button = self.view.channelUList:TryGetChildAt(listIndex)

			if hasButton then
				self.view.channelUList:SetNavGroupDefaultItemInThis(button)
				pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Restore)
			end

			return
		end
	end
end

return FishingCapturePetalSourceCtrl
