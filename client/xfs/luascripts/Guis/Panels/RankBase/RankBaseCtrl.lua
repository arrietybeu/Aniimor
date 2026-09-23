-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\RankBaseCtrl.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RankBaseInfoComponent = require("Guis.Panels.RankBase.Component.RankBaseInfoComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local RankBaseCtrl = Class.LightClass("RankBaseCtrl", UICtrl)

RankBaseCtrl.messages = {
	[MessageName.RANK_DATA_UPDATED] = {
		"onRankDataUpdated",
		true
	},
	[MessageName.SELF_RANK_DATA_UPDATED] = {
		"onSelfRankDataUpdated",
		true
	},
	[MessageName.RANK_TAB_MAPPING_UPDATED] = {
		"onRankTabMappingUpdated",
		true
	},
	[MessageName.LOGIC_TIME_UPDATE] = {
		"update",
		true
	}
}

local FILTER_TYPE_ALL = 1
local FILTER_TYPE_FRIEND_ONLY = 2
local FILTER_OPTIONS = {
	{
		textKey = "ALL",
		tIndex = 0,
		filterType = FILTER_TYPE_ALL
	},
	{
		textKey = "RANK_FILTER_FRIEND_ONLY",
		tIndex = 0,
		filterType = FILTER_TYPE_FRIEND_ONLY
	}
}

local function getLeftTabGroupKey(data)
	return tostring(data.rankId) .. ":" .. tostring(data.tab1)
end

function RankBaseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.rankInfoComponent = RankBaseInfoComponent.new(self)
end

function RankBaseCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnRewardUButton.luaClick()
		self:openRankReward()
	end

	function self.view.btnFilterUButton.luaClick()
		self:openRankFilter()
	end

	function self.view.btnInfoUButton.luaRenderTooltip(_, tooltip)
		self.rankInfoComponent:renderRankInfoTooltip(tooltip)
	end

	self:initGamepadNavigation()

	function self.view.listLeftTabUList.luaRenderItem(button, _, data)
		self:renderLeftTabItem(button, data)
	end

	function self.view.listRankingUList.luaRenderItem(button, index, data)
		self.rankInfoComponent:renderRankItem(button, index, data)
	end
end

function RankBaseCtrl:initGamepadNavigation()
	TimerManager.addNextFrameCb(function()
		if not self.isDestroyed and self.view and not IsNil(self.view.btnInfoUButton) then
			self.view.btnInfoUButton:SetHotkeyConsoleBar("CONSOLE_BAR_RULES_DESCRIPTION", 0)
		end
	end)
	self:bindHotKeyPerform("Raw/GamepadButtonEast", function()
		return self:handleLeftTabBack()
	end, self.view.gameObject)
	self:addNavFocusListener(function()
		self:refreshConsoleBarState()
	end, "Ranking")
end

function RankBaseCtrl:refreshConsoleBarState()
	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if not navManager then
		return
	end

	local focusedItem = navManager.CurrentFocusedUContent
	local focusedData = not IsNil(focusedItem) and focusedItem.dataFromUList
	local isInOptionGroup = navManager.CurrentFocusedGroupName == "ListLeftTab" and focusedData ~= nil and focusedItem.gameObject.name == "UI_Node_RankingTab_OptionGroup(Clone)" and #focusedData.secondTabList > 0

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Ranking_isInOptionGroup", isInOptionGroup)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("Ranking_isOutsideOptionGroup", not isInOptionGroup)
end

function RankBaseCtrl:focusLeftTabCell(groupButton, listUList, selectedTab2)
	local cellButtons = listUList:GetAllButtons()
	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if not cellButtons or cellButtons.Length == 0 or not navManager then
		return false
	end

	local targetButton = cellButtons[0]

	for i = 0, cellButtons.Length - 1 do
		local button = cellButtons[i]
		local buttonData = button.dataFromUList

		if buttonData and buttonData.tab2 == selectedTab2 then
			targetButton = button

			break
		end
	end

	self:setLeftTabNavigationMode(groupButton)

	return navManager:FocusItem(targetButton)
end

function RankBaseCtrl:focusDefaultLeftTabCell()
	local groupButtons = self.view.listLeftTabUList:GetAllButtons()
	local navManager = CS.XGUI.Navigation.NavManager.Instance
	local firstGroupButton = groupButtons and groupButtons.Length > 0 and groupButtons[0]

	if IsNil(firstGroupButton) or not navManager then
		self:setLeftTabNavigationMode(nil)

		return
	end

	local listUList = firstGroupButton:GetComponent("ObjectReference"):GetRefValue("listUList")

	if not self:focusLeftTabCell(firstGroupButton, listUList) then
		self:setLeftTabNavigationMode(nil)
		navManager:FocusItem(firstGroupButton)
	end
end

function RankBaseCtrl:setLeftTabNavigationMode(activeParentButton)
	local navigateCells = not IsNil(activeParentButton)

	self.activeLeftTabOptionGroupButton = navigateCells and activeParentButton or nil

	local groupButtons = self.view.listLeftTabUList:GetAllButtons()

	local function updateOptionCells()
		for secondButton, parentButton in pairs(self.optionCellParentButtons) do
			if not IsNil(secondButton) then
				secondButton.navForceNonInteractable = not navigateCells or not IsNil(activeParentButton) and parentButton ~= activeParentButton
			end
		end
	end

	local function updateOptionGroups()
		if not groupButtons then
			return
		end

		for i = 0, groupButtons.Length - 1 do
			groupButtons[i].navForceNonInteractable = navigateCells
		end
	end

	if navigateCells then
		updateOptionCells()
		updateOptionGroups()
	else
		updateOptionGroups()
		updateOptionCells()
	end
end

function RankBaseCtrl:handleLeftTabBack()
	local navManager = CS.XGUI.Navigation.NavManager.Instance

	if not navManager or navManager.CurrentFocusedGroupName ~= "ListLeftTab" then
		return true
	end

	local focusedItem = navManager.CurrentFocusedUContent

	if IsNil(focusedItem) or focusedItem.gameObject.name ~= "UI_Node_RankingTab_OptionCell(Clone)" then
		return true
	end

	local parentButton = self.optionCellParentButtons[focusedItem]

	if IsNil(parentButton) then
		return false
	end

	self:setLeftTabNavigationMode(nil)

	if not navManager:FocusItem(parentButton) then
		self:setLeftTabNavigationMode(parentButton)
	end

	return false
end

function RankBaseCtrl:toggleLeftTabOptionGroup(button, data, listUList, selectedTab2)
	local groupKey = getLeftTabGroupKey(data)
	local shouldExpand = self.expandedLeftTabGroupKey ~= groupKey

	self.expandedLeftTabGroupKey = shouldExpand and groupKey or nil

	local groupButtons = self.view.listLeftTabUList:GetAllButtons()

	if groupButtons then
		for i = 0, groupButtons.Length - 1 do
			local groupButton = groupButtons[i]

			if groupButton ~= button then
				local objectReference = groupButton:GetComponent("ObjectReference")
				local groupListUList = objectReference:GetRefValue("listUList")

				groupListUList:SetActive(false)
			end
		end
	end

	listUList:SetActive(shouldExpand)

	if shouldExpand then
		self:focusLeftTabCell(button, listUList, selectedTab2)
	end
end

function RankBaseCtrl:openRankFilter()
	pg.global.ui:open(UIConst.UI_ID_RANK_FILTER, {
		filterOptions = FILTER_OPTIONS,
		allFilterType = FILTER_TYPE_ALL,
		selectedFilterTypes = self.selectedFilterTypes,
		onFiltersSelected = CallbackHandler(self, "onRankFiltersSelected")
	})
end

function RankBaseCtrl:onRankFiltersSelected(filterTypes)
	self.selectedFilterTypes = filterTypes

	self:refreshRankList()
end

function RankBaseCtrl:openRankReward()
	local data = self.currentRankTabData
	local config = self.model:getRankConfig(data.rankId, data.tab1, data.tab2)

	pg.global.ui:open(UIConst.UI_ID_RANK_REWARD, {
		rankId = data.rankId,
		tab1 = data.tab1,
		tab2 = data.tab2,
		rewardIds = config.rewardId,
		rewardDes = config.rewardDes
	})
end

function RankBaseCtrl:onRankTabSelected(data)
	self:refreshSelectedRank(data)
	self.view.listLeftTabUList:RefreshList()
	self.view.listLeftTabUList:GoToIndex(0)
end

function RankBaseCtrl:refreshSelectedRank(data)
	local config = self.model:getRankConfig(data.rankId, data.tab1, data.tab2)

	self.selectedSecondTabDataByGroupKey[getLeftTabGroupKey(data)] = data
	self.currentRankTabData = data
	self.selectedPeriodRankId = pg.game.rank:getCurrentRankId(data.rankId, data.tab1, data.tab2)

	self.rankInfoComponent:refreshUI(config, data)

	self.rankRefreshPending = true

	self:update()
end

function RankBaseCtrl:onRankPeriodSelected(periodRankId)
	if self.selectedPeriodRankId == periodRankId then
		return
	end

	self.selectedPeriodRankId = periodRankId
	self.rankRefreshPending = true

	self:update()
end

function RankBaseCtrl:update()
	local tabData = self.currentRankTabData

	if tabData == nil then
		return
	end

	local config = self.model:getRankConfig(tabData.rankId, tabData.tab1, tabData.tab2)

	pg.game.rank:refreshRankDataIfNeeded(tabData.rankId, tabData.tab1, tabData.tab2, config, self.selectedPeriodRankId)

	if not self.rankRefreshPending then
		return
	end

	self.rankRefreshPending = nil

	self:refreshRankList()
end

function RankBaseCtrl:refreshRankList()
	local tabData = self.currentRankTabData
	local rankData = pg.game.rank:getCachedRankData(tabData.rankId, tabData.tab1, tabData.tab2, self.selectedPeriodRankId)
	local config = self.model:getRankConfig(tabData.rankId, tabData.tab1, tabData.tab2)
	local displayData = self:getFilteredRankData(rankData, config.displayList)

	self.view.listRankingUList:SetList(displayData)
	self.rankInfoComponent:setSelfRankData(pg.game.rank:getCachedSelfRankData(tabData.rankId, tabData.tab1, tabData.tab2, self.selectedPeriodRankId))
end

function RankBaseCtrl:getFilteredRankData(rankData, displayList)
	local filteredData = {}

	for _, data in ipairs(rankData) do
		if self:isRankDataVisible(data, displayList) then
			filteredData[#filteredData + 1] = data
		end
	end

	return filteredData
end

function RankBaseCtrl:isRankDataVisible(rankData, displayList)
	if rankData.Rank < 1 or displayList < rankData.Rank then
		return false
	end

	if self.selectedFilterTypes[FILTER_TYPE_ALL] == true then
		return true
	end

	return self.selectedFilterTypes[FILTER_TYPE_FRIEND_ONLY] == true and self.rankInfoComponent:isFriendRankData(rankData)
end

function RankBaseCtrl:onRankDataUpdated(rankId)
	if self.currentRankTabData.rankId ~= rankId then
		return
	end

	self.rankRefreshPending = true

	self:update()
end

function RankBaseCtrl:onRankTabMappingUpdated(mappingData)
	local tabData = self.currentRankTabData
	local currentTabMappingUpdated = tabData ~= nil and tabData.rankId == mappingData.rankId and tabData.tab1 == mappingData.tab1 and tabData.tab2 == mappingData.tab2

	if not currentTabMappingUpdated then
		return
	end

	self:refreshSelectedRank(tabData)
	self.view.listLeftTabUList:RefreshList()
end

function RankBaseCtrl:onSelfRankDataUpdated(rankId)
	local tabData = self.currentRankTabData

	self.rankInfoComponent:setSelfRankData(pg.game.rank:getCachedSelfRankData(tabData.rankId, tabData.tab1, tabData.tab2, self.selectedPeriodRankId))
end

function RankBaseCtrl:renderLeftTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local hasSecondTab = #data.secondTabList > 0
	local isSelected = self:isLeftTabSelected(data)
	local groupKey = getLeftTabGroupKey(data)
	local isExpanded = hasSecondTab and self.expandedLeftTabGroupKey == groupKey

	for secondButton, parentButton in pairs(self.optionCellParentButtons) do
		if parentButton == button then
			self.optionCellParentButtons[secondButton] = nil
		end
	end

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.textKey))

	button.interactable = true
	button.luaClick = nil
	button.isSelected = isSelected
	button.navForceNonInteractable = not IsNil(self.activeLeftTabOptionGroupButton)

	if hasSecondTab then
		function button.luaClick()
			local selectedSecondTabData = self:getRestoredSecondTabData(data)

			self:toggleLeftTabOptionGroup(button, data, listUList, selectedSecondTabData.tab2)
			self:onRankTabSelected(selectedSecondTabData)
		end
	else
		function button.luaClick()
			self:onRankTabSelected(data)
		end
	end

	function listUList.luaRenderItem(secondButton, _, secondData)
		self.optionCellParentButtons[secondButton] = button

		self:renderSecondTabItem(secondButton, secondData)

		local activeParentButton = self.activeLeftTabOptionGroupButton

		secondButton.navForceNonInteractable = IsNil(activeParentButton) or button ~= activeParentButton
	end

	listUList.luaSelectedChanged = nil

	listUList:SetList(data.secondTabList)
	listUList:SetActive(isExpanded)
end

function RankBaseCtrl:getRestoredSecondTabData(data)
	return self.selectedSecondTabDataByGroupKey[getLeftTabGroupKey(data)] or data.secondTabList[1]
end

function RankBaseCtrl:isLeftTabSelected(data)
	local selectedData = self.currentRankTabData
	local isSelected = selectedData.rankId == data.rankId and selectedData.tab1 == data.tab1

	if #data.secondTabList == 0 then
		return isSelected and selectedData.tab2 == data.tab2
	end

	return isSelected
end

function RankBaseCtrl:renderSecondTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local isSelected = self:isSecondTabSelected(data)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.textKey))

	button.interactable = true

	function button.luaClick()
		self:onRankTabSelected(data)
	end

	button.isSelected = isSelected
end

function RankBaseCtrl:isSecondTabSelected(data)
	local selectedData = self.currentRankTabData

	return selectedData.rankId == data.rankId and selectedData.tab1 == data.tab1 and selectedData.tab2 == data.tab2
end

function RankBaseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.selectedFilterTypes = {
		[FILTER_TYPE_ALL] = true
	}
	self.selectedSecondTabDataByGroupKey = {}
	self.expandedLeftTabGroupKey = nil
	self.optionCellParentButtons = {}
	self.activeLeftTabOptionGroupButton = nil

	self:refreshRankView(info.rankId)
	self:refreshConsoleBarState()
end

function RankBaseCtrl:refreshRankView(rankId)
	local leftTabList, selectedData, tabCount = self.model:getRankTabData(rankId)
	local noTab = tabCount == 1

	self.expandedLeftTabGroupKey = getLeftTabGroupKey(selectedData)

	self.view.widget:TryChangePage("NoTab", noTab and 1 or 0)
	self:refreshSelectedRank(selectedData)
	self.view.listLeftTabUList:SetList(leftTabList)
	self:focusDefaultLeftTabCell()
end

return RankBaseCtrl
