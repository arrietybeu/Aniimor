-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandInventory\\HomelandInventoryCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandInventoryCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandInventoryCtrl = Class.LightClass("HomelandInventoryCtrl", UICtrl)
local HomeObjectData = require("Data.home_object_data")
local HomeMaterialConfigData = require("Data.homeland_material_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local PropListComponent = require("Guis.Panels.HomelandInventory.HomePropListComponent")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local AudioConst = require("Const.AudioConst")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local NAV_GROUP_BAG = "PanelBagTop"
local NAV_GROUP_WAREHOUSE = "PanelWareHouseTop"
local ITEM_TIP_PADDING = 8

HomelandInventoryCtrl.messages = {
	[MessageName.HOMELAND_STORE_ITEMS_SUCC] = {
		"refreshItemList",
		true
	},
	[MessageName.HOMELAND_TAKE_ITEMS_SUCC] = {
		"refreshItemList",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"refreshInventoryItemList",
		true
	}
}

function HomelandInventoryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.inBagMultiSelect = false
	self.inInventoryMultiSelect = false
	self.pendingInventoryRefresh = false
	self.isBagSortDESC = true
	self.isInventorySortDESC = true
	self.isStore = true
	self.isTake = false
	self.propTypeBag = 0
	self.propTypeInventory = 1
	self.bagIdxType = 0
	self.inventoryIdxType = 0

	self:initUI()
end

function HomelandInventoryCtrl:syncModeByFocusedGroup()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return false
	end

	local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
	local isStore, isTake

	if groupName == NAV_GROUP_BAG then
		isStore = true
		isTake = false
	elseif groupName == NAV_GROUP_WAREHOUSE then
		isStore = false
		isTake = true
	else
		return false
	end

	if self.isStore == isStore and self.isTake == isTake then
		return false
	end

	self.isStore = isStore
	self.isTake = isTake

	return true
end

function HomelandInventoryCtrl:refreshModeHotkeyByFocusedGroup()
	self:syncModeByFocusedGroup()
	self:refreshModeHotkey()
end

function HomelandInventoryCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnPutInBag.luaClick()
		if self.inInventoryMultiSelect then
			return
		end

		if self.inBagMultiSelect then
			local itemInfo = {}

			for _, data in pairs(self.bagItemData) do
				if data.enableChecked then
					itemInfo[data.id] = data.num
				end
			end

			pg.space:reqStoreHomelandItems(itemInfo)
			pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
			self.view.panelWareHouseRectTransform:SetParent(self.view.panelWareHouseTopRectTransform)
			ClientTextUtils.setText(self.view.txtNamePutIn, pg.getGameString("HOME_BULK_STORE"))
			self.view.maskRectTransform.gameObject:SetActiveEx(false)

			self.inBagMultiSelect = false

			self.view.uIPbHomeWareHouse:TryChangePage("State", 0)
			self:refreshModeHotkey()
		else
			self.inBagMultiSelect = true

			self.view.listBag:RefreshList()
			self.view.uIPbHomeWareHouse:TryChangePage("State", 1)

			self.isStore = true
			self.isTake = false

			self:refreshModeHotkey()
			self.view.panelWareHouseRectTransform:SetParent(self.view.panelWareHouseBottomRectTransform)
			ClientTextUtils.setText(self.view.txtNamePutIn, pg.getGameString("COMMON_CONFIRM"))
			self.view.maskRectTransform.gameObject:SetActiveEx(true)
		end
	end

	function self.view.btnTakeOutInventory.luaClick()
		if self.inBagMultiSelect then
			return
		end

		if self.inInventoryMultiSelect then
			local itemInfo = {}

			for _, data in pairs(self.inventoryItemData) do
				if data.enableChecked then
					itemInfo[data.id] = data.num
				end
			end

			pg.space:reqTakeHomelandItems(itemInfo)
			pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
			self.view.panelBagRectTransform:SetParent(self.view.panelBagTopRectTransform)
			ClientTextUtils.setText(self.view.txtNameTakeOut, pg.getGameString("HOME_BULK_TAKE"))
			self.view.maskRectTransform.gameObject:SetActiveEx(false)

			self.inInventoryMultiSelect = false

			self.view.uIPbHomeWareHouse:TryChangePage("State", 0)
			self:refreshModeHotkey()
		else
			self.inInventoryMultiSelect = true

			self.view.listInventory:RefreshList()
			self.view.uIPbHomeWareHouse:TryChangePage("State", 2)

			self.isStore = false
			self.isTake = true

			self:refreshModeHotkey()
			self.view.panelBagRectTransform:SetParent(self.view.panelBagBottomRectTransform)
			ClientTextUtils.setText(self.view.txtNameTakeOut, pg.getGameString("COMMON_CONFIRM"))
			self.view.maskRectTransform.gameObject:SetActiveEx(true)
		end
	end

	function self.view.btnCancelBag.luaClick()
		self:cancelBagSelect()
		self.view.listBag:DeselectAll()
	end

	function self.view.btnCancelInventory.luaClick()
		self:cancelInventorySelect()
		self.view.listInventory:DeselectAll()
	end

	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, function()
		if self.isStore and self.view.btnPutInBag then
			self.view.btnPutInBag:OnClickSimulate()
		elseif self.isTake and self.view.btnTakeOutInventory then
			self.view.btnTakeOutInventory:OnClickSimulate()
		end
	end)
	self:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, function()
		if self.inBagMultiSelect and self.view.btnPutInBag then
			self.view.btnPutInBag:OnClickSimulate()

			return
		elseif self.inInventoryMultiSelect and self.view.btnTakeOutInventory then
			self.view.btnTakeOutInventory:OnClickSimulate()

			return
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			return
		end

		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if not navMgr then
			return
		end

		local navItem = navMgr.CurrentFocusedUContent

		if not navItem then
			return
		end

		if self.isStore and self.bagItemData then
			local idx = self.view.listBag:GetChildIndex(navItem)

			if idx and idx >= 0 then
				local data = self.bagItemData[idx + 1]

				if data then
					pg.space:reqStoreHomelandItems({
						[data.id] = data.num
					})
					pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
				end
			end
		elseif self.isTake and self.inventoryItemData then
			local idx = self.view.listInventory:GetChildIndex(navItem)

			if idx and idx >= 0 then
				local data = self.inventoryItemData[idx + 1]

				if data then
					pg.space:reqTakeHomelandItems({
						[data.id] = data.num
					})
					pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
				end
			end
		end
	end)

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("HomelandInventory", function()
			self:refreshModeHotkeyByFocusedGroup()
		end)
		CS.XGUI.Navigation.NavManager.Instance:AddLuaHotkeyActivationChangedListener("HomelandInventory", function()
			self:refreshModeHotkeyByFocusedGroup()
		end)
		CS.XGUI.Navigation.NavManager.Instance:AddLuaDragEndListener("HomelandInventory", function()
			if self.pendingInventoryRefresh then
				self:refreshInventoryItemList()
			end
		end)
	end
end

function HomelandInventoryCtrl:refreshConsoleBarState()
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
	local canSwitchToBag = false
	local canSwitchToStoreHouse = false
	local canShowCheck = false
	local canQuickTakeOut = false

	if groupName == NAV_GROUP_BAG or groupName ~= NAV_GROUP_WAREHOUSE and self.isStore then
		canSwitchToStoreHouse = true
		canShowCheck = true
		canQuickTakeOut = true
	elseif groupName == NAV_GROUP_WAREHOUSE or groupName ~= NAV_GROUP_BAG and self.isTake then
		canSwitchToBag = true
		canShowCheck = true
		canQuickTakeOut = true
	end

	local canSelect = false

	if self.inBagMultiSelect or self.inInventoryMultiSelect then
		canSelect = true
		canShowCheck = false
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSwitchToBag", canSwitchToBag)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSwitchToStoreHouse", canSwitchToStoreHouse)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canShowCheck", canShowCheck)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canQuickTakeOut", canQuickTakeOut)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelect", canSelect)
end

function HomelandInventoryCtrl:refreshModeHotkey()
	if not self.view.keyHotKeyPutInBag or not self.view.keyHotKeyTakeOutInventory then
		return
	end

	local westPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	local northPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth
	local nonoPath = HotkeyConst.HOTKEY_DEF.None

	if self.inBagMultiSelect then
		self.view.keyHotKeyPutInBag:SetHotKeyPaths(northPath)
		self.view.keyHotKeyTakeOutInventory:SetHotKeyPaths(nonoPath)
	elseif self.inInventoryMultiSelect then
		self.view.keyHotKeyPutInBag:SetHotKeyPaths(nonoPath)
		self.view.keyHotKeyTakeOutInventory:SetHotKeyPaths(northPath)
	elseif self.isStore then
		self.view.keyHotKeyPutInBag:SetHotKeyPaths(westPath)
		self.view.keyHotKeyTakeOutInventory:SetHotKeyPaths(nonoPath)
	elseif self.isTake then
		self.view.keyHotKeyPutInBag:SetHotKeyPaths(nonoPath)
		self.view.keyHotKeyTakeOutInventory:SetHotKeyPaths(westPath)
	else
		self.view.keyHotKeyPutInBag:SetHotKeyPaths(nonoPath)
		self.view.keyHotKeyTakeOutInventory:SetHotKeyPaths(nonoPath)
	end

	self:refreshConsoleBarState()
end

function HomelandInventoryCtrl:setSortAscendingOrder(propType)
	if propType == self.propTypeBag then
		self.isBagSortDESC = not self.isBagSortDESC
		self.bagItemData = self.model:getBagList(self.bagIdxType, self.isBagSortDESC)

		self.view.listBag:SetList(self.bagItemData)
	else
		self.isInventorySortDESC = not self.isInventorySortDESC
		self.inventoryItemData = self.model:getInventoryList(self.inventoryIdxType, self.isInventorySortDESC)

		self.view.listInventory:SetList(self.inventoryItemData)
	end
end

function HomelandInventoryCtrl:setSortIdxType(idxType, propType)
	if propType == self.propTypeBag then
		self.bagIdxType = idxType
		self.bagItemData = self.model:getBagList(self.bagIdxType, self.isBagSortDESC)

		self.view.listBag:SetList(self.bagItemData)
	else
		self.inventoryIdxType = idxType
		self.inventoryItemData = self.model:getInventoryList(self.inventoryIdxType, self.isInventorySortDESC)

		self.view.listInventory:SetList(self.inventoryItemData)
	end
end

function HomelandInventoryCtrl:cancelBagSelect()
	for _, data in pairs(self.bagItemData) do
		data.enableChecked = false
	end

	self.view.listBag:RefreshList()

	self.inBagMultiSelect = false

	self.view.uIPbHomeWareHouse:TryChangePage("State", 0)
	self.view.panelWareHouseRectTransform:SetParent(self.view.panelWareHouseTopRectTransform)
	ClientTextUtils.setText(self.view.txtNamePutIn, pg.getGameString("HOME_BULK_STORE"))
	self.view.maskRectTransform.gameObject:SetActiveEx(false)
	self:refreshModeHotkey()
end

function HomelandInventoryCtrl:cancelInventorySelect()
	for _, data in pairs(self.inventoryItemData) do
		data.enableChecked = false
	end

	self.inInventoryMultiSelect = false

	self.view.listInventory:RefreshList()
	self.view.uIPbHomeWareHouse:TryChangePage("State", 0)
	self.view.panelBagRectTransform:SetParent(self.view.panelBagTopRectTransform)
	ClientTextUtils.setText(self.view.txtNameTakeOut, pg.getGameString("HOME_BULK_TAKE"))
	self.view.maskRectTransform.gameObject:SetActiveEx(false)
	self:refreshModeHotkey()
end

function HomelandInventoryCtrl:refreshInventoryItemList(info)
	if info and info.changeType == ItemConst.INV_GEN_CHANGE then
		for _, data in ipairs(self.inventoryItemData) do
			if data.id == info.genId then
				data.num = info.newNum

				self.view.listInventory:RefreshElement(data.index)

				return
			end
		end
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if navMgr and navMgr.IsDragging then
		self.pendingInventoryRefresh = true

		return
	end

	self.pendingInventoryRefresh = false

	local focusedItemId, focusedIndex

	if navMgr and self:checkUIVisible() and navMgr.CurrentFocusedUContent then
		focusedIndex = self.view.listInventory:GetChildIndex(navMgr.CurrentFocusedUContent)

		local focusedData = self.inventoryItemData[focusedIndex + 1]

		focusedItemId = focusedData and focusedData.id
	end

	local checkedItems = {}

	for _, data in ipairs(self.inventoryItemData) do
		if data.enableChecked then
			checkedItems[data.id] = true
		end
	end

	local restoreIndex

	self.inventoryItemData = self.model:getInventoryList(self.inventoryIdxType, self.isInventorySortDESC)

	for _, data in ipairs(self.inventoryItemData) do
		data.enableChecked = checkedItems[data.id] == true

		if data.id == focusedItemId then
			restoreIndex = data.index
		end
	end

	self.view.listInventory:SetList(self.inventoryItemData)

	if focusedItemId then
		restoreIndex = restoreIndex or math.min(focusedIndex, #self.inventoryItemData - 1)

		if restoreIndex >= 0 then
			local ok, button = self.view.listInventory:TryGetChildAt(restoreIndex)

			if ok and button then
				navMgr:FocusItem(button, CS.XGUI.Navigation.FocusEntryMode.Restore)
			end
		else
			navMgr:ClearFocus()
		end
	end
end

function HomelandInventoryCtrl:refreshItemList()
	self.bagItemData = self.model:getBagList(self.bagIdxType, self.isBagSortDESC)

	self.view.listBag:SetList(self.bagItemData)

	self.inventoryItemData = self.model:getInventoryList(self.inventoryIdxType, self.isInventorySortDESC)

	self.view.listInventory:SetList(self.inventoryItemData)

	if self.inBagMultiSelect then
		self:cancelBagSelect()
	end

	if self.inInventoryMultiSelect then
		self:cancelInventorySelect()
	end

	self:refreshModeHotkey()
end

function HomelandInventoryCtrl:dragPanelIndex(targetName)
	if not targetName then
		return
	end

	local info = string.split(targetName, self.model.HOME_SPLIT) or {}

	if info[1] == self.model.LISTBAG_TAG then
		return info[1]
	elseif info[1] == self.model.LISTINVENTORY_TAG then
		return info[1]
	end
end

function HomelandInventoryCtrl:openItemTip(data, button, isStore)
	local itemList = isStore and self.view.listBag or self.view.listInventory

	local function confirmClick(itemInfo)
		if isStore then
			pg.space:reqStoreHomelandItems(itemInfo)
		else
			pg.space:reqTakeHomelandItems(itemInfo)
		end

		pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	local function cancelClick()
		if self.view and self.lastButton then
			itemList:DeselectAll()
		end
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		fromParamCount = true,
		inHome = true,
		autoHor = true,
		id = data.id,
		num = data.num,
		itemCount = data.num,
		price = Utils.getHomeItemPrice(data.id),
		targetRect = button,
		padding = ITEM_TIP_PADDING,
		confirmClickSoundUrl = AudioConst.EVENT_HOME_STOREHOUSE_CONFIRM,
		confirmClick = confirmClick,
		cancelClick = cancelClick
	})
end

function HomelandInventoryCtrl:initUI()
	self.bagItemData = self.model:getBagList(self.propTypeBag, true)

	function self.view.listBag.luaRenderItem(button, index, data)
		function data.extraFunc()
			self.lastButton = button

			if self.inBagMultiSelect then
				data.enableChecked = not data.enableChecked

				self.view.listBag:RefreshElement(data.index)
			else
				self.lastSelectId = data.id
				self.isStore = true
				self.isTake = false

				self:refreshModeHotkey()

				if self._suppressTipOnSelect then
					return
				end

				self:openItemTip(data, button, true)
			end
		end

		button.name = self.model.LISTBAG_TAG .. self.model.HOME_SPLIT .. data.id
		button.draggable = not self.inBagMultiSelect
		button.dragMode = 0

		LuaUIUtils.renderItem(button, data)

		button.clickSoundUrl = AudioConst.EVENT_HOME_STOREHOUSE_CLICK

		function button.luaClick(isFromNavigation)
			if self.inBagMultiSelect and isFromNavigation then
				return
			end

			self._suppressTipOnSelect = isFromNavigation == true

			data.extraFunc()

			self._suppressTipOnSelect = false
		end

		function button.luaEndDrag(dropWidget, pointerWidget)
			if not dropWidget then
				return
			end

			if dropWidget.gameObject == self.view.panelWareHouseRectTransform.gameObject or self:dragPanelIndex(dropWidget.gameObject.name) == self.model.LISTINVENTORY_TAG then
				local itemInfo = {}

				itemInfo[data.id] = data.num

				pg.space:reqStoreHomelandItems(itemInfo)
				pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
			end
		end
	end

	self.view.listBag:SetList(self.bagItemData)

	self.inventoryItemData = self.model:getInventoryList(self.propTypeInventory, true)

	function self.view.listInventory.luaRenderItem(button, index, data)
		function data.extraFunc()
			self.lastButton = button

			if self.inInventoryMultiSelect then
				data.enableChecked = not data.enableChecked

				self.view.listInventory:RefreshElement(data.index)
			else
				self.lastSelectId = data.id
				self.isTake = true
				self.isStore = false

				self:refreshModeHotkey()

				if self._suppressTipOnSelect then
					return
				end

				self:openItemTip(data, button, false)
			end
		end

		button.name = self.model.LISTINVENTORY_TAG .. self.model.HOME_SPLIT .. data.id
		button.draggable = not self.inInventoryMultiSelect
		button.dragMode = 0

		LuaUIUtils.renderItem(button, data)

		button.clickSoundUrl = AudioConst.EVENT_HOME_STOREHOUSE_CLICK

		function button.luaClick(isFromNavigation)
			if self.inInventoryMultiSelect and isFromNavigation then
				return
			end

			self._suppressTipOnSelect = isFromNavigation == true

			data.extraFunc()

			self._suppressTipOnSelect = false
		end

		function button.luaBeginDrag()
			function button.luaEndDrag(dropWidget, pointerWidget)
				if not dropWidget then
					return
				end

				if dropWidget.gameObject == self.view.panelBagRectTransform.gameObject or self:dragPanelIndex(dropWidget.gameObject.name) == self.model.LISTBAG_TAG then
					local num = pg.space.itemMap[data.id]

					if not num or num <= 0 then
						return
					end

					pg.space:reqTakeHomelandItems({
						[data.id] = num
					})
					pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_TRANSFER)
				end
			end
		end
	end

	self.view.listInventory:SetList(self.inventoryItemData)

	self.propBag = PropListComponent.new(self, self.view.panelBagRectTransform)

	self.propBag:onShow(self.propTypeBag)

	self.propInventory = PropListComponent.new(self, self.view.panelWareHouseRectTransform)

	self.propInventory:onShow(self.propTypeInventory)

	local currencyData = {}
	local currencyInfo = {
		itemId = Const.HomeCoinItemId
	}

	table.insert(currencyData, currencyInfo)

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	self.view.listCurrencyUList:SetList(currencyData)
	ClientTextUtils.setText(self.view.txtNamePutIn, pg.getGameString("HOME_BULK_STORE"))
	ClientTextUtils.setText(self.view.txtNameTakeOut, pg.getGameString("HOME_BULK_TAKE"))
	ClientTextUtils.setText(self.view.txtDragTipsUSDFText, pg.getGameString("HOMELAND_WAREHOUSE_TIPS"))
	self.view.maskRectTransform.gameObject:SetActiveEx(false)
end

function HomelandInventoryCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("HomelandInventory")
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaHotkeyActivationChangedListener("HomelandInventory")
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaDragEndListener("HomelandInventory")
	end

	UICtrl.onDestroy(self)

	self.propInventory = nil
	self.propBag = nil
end

function HomelandInventoryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandInventoryCtrl:close()
	pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_STOREHOUSE_CLOSE)
	UICtrl.close(self)
end

function HomelandInventoryCtrl:setInitialFocus()
	local function tryFocusFirstChild(uList)
		if not uList then
			return false
		end

		local ok, btn = uList:TryGetChildAt(0)

		if ok and btn then
			pg.global.navMgr:FocusItem(btn, CS.XGUI.Navigation.FocusEntryMode.Restore)

			return true
		end

		return false
	end

	if self.bagItemData and #self.bagItemData > 0 and tryFocusFirstChild(self.view.listBag) then
		self.isStore = true
		self.isTake = false

		self:refreshModeHotkey()

		return
	end

	if self.inventoryItemData and #self.inventoryItemData > 0 and tryFocusFirstChild(self.view.listInventory) then
		self.isStore = false
		self.isTake = true

		self:refreshModeHotkey()
	end
end

function HomelandInventoryCtrl:onShow()
	self:setInitialFocus()
end

function HomelandInventoryCtrl:onHide()
	return
end

return HomelandInventoryCtrl
