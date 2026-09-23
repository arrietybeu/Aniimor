-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampChooseExploreArea\\HomeCampChooseExploreAreaCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCampChooseExploreAreaCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HotkeyConst = require("Const.HotkeyConst")
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local HomeCampData = require("Data.home_camp_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local HomeCampChooseExploreAreaCtrl = Class.LightClass("HomeCampChooseExploreAreaCtrl", UICtrl)
local REWARD_TIP_PADDING = 90

HomeCampChooseExploreAreaCtrl.messages = {}

function HomeCampChooseExploreAreaCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.m_tabList = {}
	self.m_areaListByTab = {}
	self.m_selectedTab = nil
	self.m_selectedArea = nil
	self.m_areaButtonByData = {}
	self.m_rewardListByAreaButton = {}
	self.m_currentAreaButton = nil
	self.m_rewardFocusAreaButton = nil
	self.m_focusRequestSerial = 0
end

function HomeCampChooseExploreAreaCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnClose2UButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirm()
	end

	self:setupConfirmHotKey()

	function self.view.tabList.luaRenderItem(button, index, data)
		self:renderTabItem(button, index, data)
	end

	function self.view.listAreaUList.luaRenderItem(button, index, data)
		self:renderAreaItem(button, index, data)
	end

	local bindTarget = self.view.widget and self.view.widget.gameObject

	if bindTarget then
		self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickPress, function()
			self:enterFocusedAreaRewards()

			return false
		end, bindTarget, "homeCampChooseAreaRewardBind")
		self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonEast, function()
			return self:onGamepadBack()
		end, bindTarget, "homeCampChooseAreaBackBind")
	end
end

function HomeCampChooseExploreAreaCtrl:onDestroy()
	self.m_onConfirm = nil
	self.m_selectedTab = nil
	self.m_selectedArea = nil
	self.m_tabList = nil
	self.m_areaListByTab = nil
	self.m_areaButtonByData = nil
	self.m_rewardListByAreaButton = nil
	self.m_currentAreaButton = nil
	self.m_rewardFocusAreaButton = nil

	UICtrl.onDestroy(self)
end

function HomeCampChooseExploreAreaCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = type(info) == "table" and info or {}
	self.m_onConfirm = info.onConfirm
	self.m_closeAfterConfirm = info.closeAfterConfirm ~= false

	self:loadExploreAreaData()
	ClientTextUtils.setText(self.view.titleSDFText, pg.getGameString("HOME_CAMP_CHOOSE_EXPLORE_AREA"))
	self:initSelection(info.selectedTabId, info.selectedAreaId)
	self:refreshUI()
end

function HomeCampChooseExploreAreaCtrl:onShow()
	return
end

function HomeCampChooseExploreAreaCtrl:onHide()
	return
end

function HomeCampChooseExploreAreaCtrl:setupConfirmHotKey()
	local button = self.view.btnConfirmUButton

	if not button or IsNil(button) then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local hotKeyContent = objectReference and objectReference:GetRefValue("keyHotKeyContent")
	local hotKeyContentObject = hotKeyContent and not IsNil(hotKeyContent) and hotKeyContent.gameObject or nil

	if not hotKeyContentObject then
		local keyTransform = button.transform:Find("PanelText/Key") or button.transform:Find("Key")

		hotKeyContentObject = keyTransform and not IsNil(keyTransform) and keyTransform.gameObject or nil
	end

	button:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, hotKeyContentObject)
end

function HomeCampChooseExploreAreaCtrl:onGamepadBack()
	if self.m_backGuard then
		return false
	end

	self.m_backGuard = true

	self:startFrameTimer(function()
		self.m_backGuard = false
	end, 1)

	if self:exitRewardFocus() then
		return false
	end

	self:close()

	return false
end

function HomeCampChooseExploreAreaCtrl:exitRewardFocus()
	local areaButton = self.m_rewardFocusAreaButton

	if not areaButton then
		return false
	end

	self.m_rewardFocusAreaButton = nil

	local navMgr = pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance

	if navMgr and navMgr.PopFocusGroup then
		navMgr:PopFocusGroup()
	end

	if navMgr and navMgr.FocusItem and not IsNil(areaButton) then
		navMgr:FocusItem(areaButton)

		self.m_currentAreaButton = areaButton
	end

	return true
end

function HomeCampChooseExploreAreaCtrl:enterFocusedAreaRewards()
	if self.m_rewardFocusAreaButton then
		return
	end

	local navMgr = pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local areaButton = navMgr.CurrentFocusedUContent

	if not areaButton or IsNil(areaButton) or not self.m_rewardListByAreaButton[areaButton] then
		areaButton = self.m_currentAreaButton or self.m_areaButtonByData[self.m_selectedArea]
	end

	if not areaButton or IsNil(areaButton) then
		return
	end

	local rewardList = self.m_rewardListByAreaButton[areaButton]

	if not rewardList or IsNil(rewardList) then
		return
	end

	local success, rewardButton = rewardList:TryGetChildAt(0)

	if not success or not rewardButton or IsNil(rewardButton) then
		return
	end

	self.m_rewardFocusAreaButton = areaButton

	navMgr:PushFocusItem(rewardButton)
	rewardButton:OnClickSimulate(true)
end

function HomeCampChooseExploreAreaCtrl:requestFocusSelectedArea()
	self.m_focusRequestSerial = self.m_focusRequestSerial + 1

	local requestSerial = self.m_focusRequestSerial

	self:startFrameTimer(function()
		if requestSerial ~= self.m_focusRequestSerial or not pg.game.input or not pg.game.input:isUsingGamepad() then
			return
		end

		local areaList = self:getAreaList(self.m_selectedTab)
		local selectedIndex = self:findDataIndex(areaList, self.m_selectedArea)

		if not selectedIndex or selectedIndex <= 0 then
			return
		end

		self.view.listAreaUList:GoToIndex(selectedIndex - 1)

		local success, areaButton = self.view.listAreaUList:TryGetChildAt(selectedIndex - 1)

		if not success or not areaButton or IsNil(areaButton) then
			return
		end

		local navMgr = pg.global.navMgr or CS.XGUI.Navigation.NavManager.Instance

		if navMgr and navMgr.FocusItem then
			navMgr:FocusItem(areaButton)

			self.m_currentAreaButton = areaButton
		end
	end, 1)
end

function HomeCampChooseExploreAreaCtrl:prepareTabList()
	local tabCount = #self.m_tabList

	for index, data in ipairs(self.m_tabList) do
		if data.tIndex == nil then
			if index == 1 then
				data.tIndex = 0
			elseif index == tabCount then
				data.tIndex = 2
			else
				data.tIndex = 1
			end
		end
	end
end

function HomeCampChooseExploreAreaCtrl.sortExploreAreaData(left, right)
	local leftSort = left.sort or left.id or 0
	local rightSort = right.sort or right.id or 0

	return leftSort < rightSort
end

function HomeCampChooseExploreAreaCtrl:buildExploreAreaRewardItems(campId, itemIds)
	local rewardItems = {}

	for _, itemId in ipairs(itemIds or EMPTY_TABLE) do
		local itemCfg = ItemData[itemId] or {}

		table.insert(rewardItems, {
			id = itemId,
			iconUrl = itemCfg.icon or "",
			unkownInfoText = pg.getGameString("HOME_CAMP_UNKOWN_REWARD_TIP")
		})
	end

	HomeCampUtils.trySetUnknownDispatchItem(rewardItems, true)

	local extraRewardItemIds = HomeCampUtils.getCampDisplayExtraRewardList(campId)

	for index, itemId in ipairs(extraRewardItemIds) do
		local itemCfg = ItemData[itemId] or {}

		table.insert(rewardItems, index, {
			id = itemId,
			iconUrl = itemCfg.icon or ""
		})
	end

	return rewardItems
end

function HomeCampChooseExploreAreaCtrl:loadExploreAreaData()
	self.m_tabList = {}
	self.m_areaListByTab = {}

	local tabByMainSceneId = {}

	for mapAreaId, mapAreaCfg in pairs(MapAreaConfigData) do
		if mapAreaCfg.Campid and mapAreaCfg.Campid ~= 0 then
			local tabData = {
				unlocked = false,
				id = mapAreaId,
				name = mapAreaCfg.areaName,
				sort = mapAreaCfg.sort or mapAreaId
			}

			table.insert(self.m_tabList, tabData)

			self.m_areaListByTab[mapAreaId] = {}
			tabByMainSceneId[mapAreaCfg.Mapid] = tabData
		end
	end

	for campStaticId, campCfg in pairs(HomeCampData) do
		local mainSceneId = HomeLandUtils.getHomeCampMainSceneId(campStaticId)
		local tabData = tabByMainSceneId[mainSceneId]

		if tabData then
			local unlocked = ClientUtils.checkHomeCampUnlock(campStaticId)

			table.insert(self.m_areaListByTab[tabData.id], {
				id = campStaticId,
				campStaticId = campStaticId,
				name = campCfg.name,
				sort = campCfg.areaId or campStaticId,
				unlocked = unlocked,
				rewardItems = self:buildExploreAreaRewardItems(campStaticId, campCfg.rewardItemList)
			})

			tabData.unlocked = tabData.unlocked or unlocked
		end
	end

	table.sort(self.m_tabList, HomeCampChooseExploreAreaCtrl.sortExploreAreaData)

	for _, areaList in pairs(self.m_areaListByTab) do
		table.sort(areaList, HomeCampChooseExploreAreaCtrl.sortExploreAreaData)
	end

	self:prepareTabList()
end

function HomeCampChooseExploreAreaCtrl:getDataId(data, index)
	if not data then
		return nil
	end

	return data.id or data.areaId or data.tabId or index
end

function HomeCampChooseExploreAreaCtrl:isUnlocked(data)
	if not data then
		return false
	end

	if data.unlocked ~= nil then
		return data.unlocked ~= false and data.unlocked ~= 0
	end

	if data.isUnlock ~= nil then
		return data.isUnlock ~= false and data.isUnlock ~= 0
	end

	if data.isLocked ~= nil then
		return data.isLocked == false or data.isLocked == 0
	end

	return true
end

function HomeCampChooseExploreAreaCtrl:getAreaList(tabData)
	if not tabData then
		return {}
	end

	return self.m_areaListByTab[tabData.id] or {}
end

function HomeCampChooseExploreAreaCtrl:findDataById(dataList, targetId)
	if targetId == nil then
		return nil
	end

	for index, data in ipairs(dataList or EMPTY_TABLE) do
		if self:getDataId(data, index) == targetId then
			return data
		end
	end

	return nil
end

function HomeCampChooseExploreAreaCtrl:findDataIndex(dataList, targetData)
	for index, data in ipairs(dataList or EMPTY_TABLE) do
		if data == targetData then
			return index
		end
	end

	return nil
end

function HomeCampChooseExploreAreaCtrl:findFirstUnlocked(dataList)
	for _, data in ipairs(dataList or EMPTY_TABLE) do
		if self:isUnlocked(data) then
			return data
		end
	end

	return nil
end

function HomeCampChooseExploreAreaCtrl:initSelection(selectedTabId, selectedAreaId)
	self.m_selectedTab = self:findDataById(self.m_tabList, selectedTabId)
	self.m_selectedArea = nil

	if selectedAreaId ~= nil then
		for _, tabData in ipairs(self.m_tabList) do
			local selectedArea = self:findDataById(self:getAreaList(tabData), selectedAreaId)

			if selectedArea and self:isUnlocked(tabData) and self:isUnlocked(selectedArea) then
				self.m_selectedTab = tabData
				self.m_selectedArea = selectedArea

				break
			end
		end
	end

	if not self:isUnlocked(self.m_selectedTab) then
		self.m_selectedTab = self:findFirstUnlocked(self.m_tabList)
	end

	local selectedAreaList = self:getAreaList(self.m_selectedTab)

	if not self:isUnlocked(self.m_selectedArea) or not table.contains(selectedAreaList, self.m_selectedArea) then
		self.m_selectedArea = self:findFirstUnlocked(selectedAreaList)
	end
end

function HomeCampChooseExploreAreaCtrl:refreshUI()
	self.view.tabList:SetList(self.m_tabList)
	self:refreshAreaList()
end

function HomeCampChooseExploreAreaCtrl:refreshAreaList()
	local areaList = self:getAreaList(self.m_selectedTab)

	self.m_areaButtonByData = {}
	self.m_rewardListByAreaButton = {}
	self.m_currentAreaButton = nil

	self.view.listAreaUList:SetList(areaList)

	self.view.btnConfirmUButton.interactable = self.m_selectedArea ~= nil and self:isUnlocked(self.m_selectedArea)

	self:requestFocusSelectedArea()
end

function HomeCampChooseExploreAreaCtrl:renderTabItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))

	local unlocked = self:isUnlocked(data)

	button:TryChangePage("Locked", unlocked and 0 or 1)

	button.interactable = true
	button.visualInteractable = unlocked
	button.isSelected = data == self.m_selectedTab

	function button.luaClick()
		self:selectTab(data)
	end
end

function HomeCampChooseExploreAreaCtrl:selectTab(tabData)
	if self.m_rewardFocusAreaButton or tabData == self.m_selectedTab then
		return
	end

	if not self:isUnlocked(tabData) then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_WORLD_LOCKED)

		return
	end

	self.m_selectedTab = tabData
	self.m_selectedArea = self:findFirstUnlocked(self:getAreaList(tabData))

	self.view.tabList:RefreshList()
	self:refreshAreaList()
end

function HomeCampChooseExploreAreaCtrl:showRewardItemTip(rewardButton, rewardData, navConfirm)
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) and not navConfirm then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

		return
	end

	local targetRect = self.view.btnClose2UButton

	if not targetRect or IsNil(targetRect) then
		targetRect = self.view.btnCloseUButton
	end

	if not targetRect or IsNil(targetRect) then
		targetRect = rewardButton
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		autoHor = true,
		originData = rewardData,
		id = rewardData.id,
		num = rewardData.num,
		price = rewardData.price,
		targetRect = targetRect,
		navigationPopupOwner = navConfirm and rewardButton or nil,
		verAlign = CS.XGUI.EVerticalAlignment.Top,
		padding = REWARD_TIP_PADDING,
		hierarchyMode = rewardData.hierarchyMode,
		sortingOrder = rewardData.sortingOrder
	})
end

function HomeCampChooseExploreAreaCtrl:renderAreaItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	function listRewardUList.luaRenderItem(rewardButton, rewardIndex, rewardData)
		if rewardData then
			LuaUIUtils.renderRewardItem(rewardButton, rewardData, rewardData.num or 1)

			if rewardData.isUnknow ~= true then
				function rewardButton.luaClick(navConfirm)
					self:showRewardItemTip(rewardButton, rewardData, navConfirm)
				end
			end
		end
	end

	listRewardUList:SetList(data.rewardItems or data.rewards or data.rewardList or {})

	self.m_areaButtonByData[data] = button
	self.m_rewardListByAreaButton[button] = listRewardUList

	local unlocked = self:isUnlocked(data)

	button:TryChangePage("Unlock", unlocked and 0 or 1)

	button.interactable = true
	button.visualInteractable = unlocked
	button.isSelected = data == self.m_selectedArea

	function button.luaClick()
		self.m_currentAreaButton = button

		self:selectArea(data)
	end

	function button.luaHover()
		self.m_currentAreaButton = button
	end
end

function HomeCampChooseExploreAreaCtrl:selectArea(areaData)
	if areaData == self.m_selectedArea then
		return
	end

	if not self:isUnlocked(areaData) then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_LOCKED)

		return
	end

	self.m_selectedArea = areaData

	self.view.listAreaUList:RefreshList()

	self.view.btnConfirmUButton.interactable = true
end

function HomeCampChooseExploreAreaCtrl:onConfirm()
	if self.m_rewardFocusAreaButton or not self.m_selectedArea or not self:isUnlocked(self.m_selectedArea) then
		return
	end

	if type(self.m_onConfirm) == "function" then
		self.m_onConfirm(self.m_selectedArea, self.m_selectedTab)
	end

	if self.m_closeAfterConfirm then
		self:close()
	end
end

return HomeCampChooseExploreAreaCtrl
