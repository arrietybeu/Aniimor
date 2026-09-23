-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\InventoryCtrl.lua

local MessageName = require("Const.MessageName")
local ItemConst = require("Common.Const.ItemConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local InventoryCtrl = Class.LightClass("InventoryCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local Utils = require("Common.Utils.Utils")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local PropListComponent = require("Guis.Panels.Inventory.Component.PropListComponent")
local PropDetailComponent = require("Guis.Panels.Inventory.Component.PropDetailComponent")
local DecomposeComponent = require("Guis.Panels.Inventory.Component.DecomposeComponent")
local CatchBallSlotComponent = require("Guis.Panels.Inventory.Component.CatchBallSlotComponent")

InventoryCtrl.messages = {
	[MessageName.ON_BACKPACK_QUICK_BALL_CHANGE] = {
		"event_CatchBallSlotChanged",
		true
	},
	[MessageName.ON_BACKPACK_QUICK_PLAYER_ITEM_CHANGE] = {
		"event_PlayerPropSlotChanged",
		true
	},
	[MessageName.ITEM_GEN_STATUS_LOCKED] = {
		"event_ItemLockStatusChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"event_PropCountChanged",
		true
	},
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"event_PropGenCountChanged",
		true
	},
	[MessageName.PET_LEVEL_CHANGED] = {
		"event_PetLevelChange",
		true
	},
	[MessageName.PREPARE_PETS_UPDATE] = {
		"event_PetListChanged",
		true
	},
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarry",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"event_CurrencyChange",
		true
	},
	[MessageName.BATTLEPASS_CHANGE] = {
		"onBattlePassChange",
		true
	},
	[MessageName.CARRY_EQUIP] = {
		"event_CarryDataChanged",
		true
	},
	[MessageName.CARRY_UNLOAD] = {
		"event_CarryDataChanged",
		true
	},
	[MessageName.CARRY_ASSIST_CHANGE] = {
		"event_CarryDataChanged",
		true
	},
	[MessageName.CARRY_UPGRADE] = {
		"event_CarryDataChanged",
		true
	},
	[MessageName.PET_CARRY_BATCH_EQUIP_SUCCESS] = {
		"event_CarryDataChanged",
		true
	},
	[MessageName.CAPTURE_LOGIN_ITEM_CHANGE] = {
		"event_RefreshInvPropList",
		true
	}
}

function InventoryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.decompose = DecomposeComponent.new(self, self.view.recyclePanel)
	self.propDetail = PropDetailComponent.new(self, self.view.propInfoUContainer)
	self.propInventory = PropListComponent.new(self, self.view.listProp)
	self.catchBallSlot = CatchBallSlotComponent.new(self, self.view.ballPanel)
end

function InventoryCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function InventoryCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("Inventory")
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaBeforeDragBeginListener("Inventory")
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaDragEndListener("Inventory")

		CS.XGUI.Navigation.NavManager.Instance.IsOffsetOverride = false
	end

	UICtrl.onDestroy(self)

	self.decompose = nil
	self.propDetail = nil
	self.propInventory = nil

	self.model:redDot_CheckSaveDirty()
	self.model:setOperationState(self.model.STATE_NORMAL)
end

function InventoryCtrl:onPlayerStartCarry()
	pg.global.ui:closeAllNormalPanel()
end

function InventoryCtrl:addListener()
	self.closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "closeBind")
	self.closeBind.isVirtual = true
	self.closeBind.priority = -1
	self.closeBind.actionPath = "Common/ClosePanelCommon"

	function self.closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
				self:exitDecomposeState()
			else
				self:closePanel()
			end
		end
	end

	function self.view.btnBack.luaClick()
		self:closePanel()
	end

	function self.view.btnRecycle.luaClick()
		self.decompose:onEnterDecomposeSate()
	end

	function self.view.listTabIconUList.luaRenderItem(button, index, data)
		self:onRenderTabItem(button, data)
	end

	function self.view.listTabIconUList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onTabSelectChanged()
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("Inventory", function()
			self:refreshConsoleBarState()
		end)
		CS.XGUI.Navigation.NavManager.Instance:AddLuaBeforeDragBeginListener("Inventory", function()
			CS.XGUI.Navigation.NavManager.Instance.IsOffsetOverride = true
			CS.XGUI.Navigation.NavManager.Instance.OffsetOverrideValue = Vector2(0.7, 0.7)
		end)
		CS.XGUI.Navigation.NavManager.Instance:AddLuaDragEndListener("Inventory", function()
			CS.XGUI.Navigation.NavManager.Instance.IsOffsetOverride = false
		end)
	end
end

function InventoryCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local isInCurrency = groupName == "ListCurrency"
		local isInTreeDetail = groupName == "TreeDetail"

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInCurrency", isInCurrency)
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInTreeDetail", isInTreeDetail)

		local focusedItem = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedUContent
		local canChangePos = NotNil(focusedItem) and focusedItem.draggable == true

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canChangePos", canChangePos)
	end
end

function InventoryCtrl:checkCanOpen(showNotice, info)
	return UICtrl.checkCanOpen(self, showNotice, info)
end

function InventoryCtrl:closePanel()
	self:dismiss()

	if self.closeCallback then
		self.closeCallback()
	end
end

function InventoryCtrl:onOpen(info)
	pg.game.controller:setCatchModeEnable(false)
end

function InventoryCtrl:onShow()
	self:refreshCommonView()
end

function InventoryCtrl:refreshCommonView()
	self:refreshCurrencyView()

	local defaultTabIndex = 0
	local restoreLastSelection = self.oldTabIndex ~= nil
	local tabData = self.model:getTabList()

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		restoreLastSelection = false

		for index, data in ipairs(tabData) do
			if data.invId == ItemConst.INV_TYPE_BALL then
				defaultTabIndex = index - 1

				self.view.listTabIconUList:SelectItem(index - 1)
			end
		end

		self.view.listTabIconUList:SetActive(false)
		self.view.btnRecycle:SetActive(false)
	else
		self.oldTabIndex = self.oldTabIndex or 0
		defaultTabIndex = self.oldTabIndex
	end

	function self.view.listTabIconUList.luaFinishRender()
		if not pg.game.input:isUsingGamepad() then
			return
		end
	end

	self.view.listTabIconUList:SetList(tabData)

	self.restoreLastSelection = restoreLastSelection

	self.view.listTabIconUList:SelectItem(defaultTabIndex)

	self.restoreLastSelection = nil
end

function InventoryCtrl:refreshCurrencyView()
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrency, UIConst.UI_ID_INVENTORY)
end

function InventoryCtrl:onRenderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local hasIcon = not string.isNilOrEmpty(data.icon)

	if iconUImage then
		iconUImage:SetActive(hasIcon)

		if hasIcon then
			iconUImage.url = data.icon
		end
	end

	if textUBaseText then
		ClientTextUtils.setText(textUBaseText, data.name)
	end
end

function InventoryCtrl:onTabSelectChanged()
	local sData = self.view.listTabIconUList.selectedItem
	local restoreLastSelection = self.restoreLastSelection

	ClientTextUtils.setText(self.view.txtTitle, sData.name)

	self.oldTabIndex = self.view.listTabIconUList.selectedIndex or 0

	self.model:setCurInvType(sData.invId)
	self.propInventory:onTabSelectChanged(restoreLastSelection)
	self.decompose:onTabSelectChanged()
	self:refreshCapacity()
	self.catchBallSlot:onExitCatchBallState()

	if pg.game.input:isUsingGamepad() then
		TimerManager.addNextFrameCb(function()
			if not self.view then
				return
			end

			self:refreshConsoleBarState()
		end)
	end
end

function InventoryCtrl:onThirdTabSelectedChange()
	self.decompose:onTabSelectChanged(true)
end

function InventoryCtrl:refreshCapacity()
	local curCount = self.model:getPropsCount()
	local capacity = self.model:getCapacity()
	local showCapacity = curCount >= capacity * 0.9

	self.view.txtCapacity:SetActive(showCapacity)

	if showCapacity then
		ClientTextUtils.setText(self.view.txtCapacity, string.format("%s/%s", self.model:getPropsCount(), self.model:getCapacity()))
	end
end

function InventoryCtrl:showPropDetails(propData, fromSlot)
	if not fromSlot then
		self.model:tryCancelSelectPropNewStatus(propData.index)
		self.model:setSelectPropData(propData)
	else
		self.model:setSelectPropData(nil)
	end

	self.propDetail:showPropDetails(propData, fromSlot)
end

function InventoryCtrl:tryAddDecompose(button, propData, navConfirm)
	self.decompose:tryAddDecompose(button, propData, navConfirm)
end

function InventoryCtrl:noAddDecompose(propData)
	self.decompose:noAddDecompose(propData)
end

function InventoryCtrl:onDecomposeNavToDisabled()
	self.decompose:onNavToDisabled()
end

function InventoryCtrl:exitDecomposeState()
	self.decompose:onExitDecomposeSate()
end

function InventoryCtrl:enterCatchBallState()
	self.catchBallSlot:onEnterCatchBallState()
end

function InventoryCtrl:refreshPropList(resetSelect)
	self.propInventory:refreshPropList(resetSelect)
end

function InventoryCtrl:refreshCatchBallBtnState()
	self.catchBallSlot:refreshEquipBtnState()
end

function InventoryCtrl:switchListBtnState(flag)
	self.propInventory:switchListBtnState(flag)
end

function InventoryCtrl:resetDecomposeStateList()
	local buttons = self.view.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local data = buttons[i].dataFromUList

		if data and data.tIndex == 0 then
			local objectReference = buttons[i]:GetComponent("ObjectReference")
			local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
			local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
			local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
			local txtNameUText = objectReference:GetRefValue("selectedName")

			btnDelUButton.gameObject:SetActiveEx(false)

			btnDelUButton.luaClick = nil

			ClientTextUtils.setText(txtNameUText, 0)
			selectedULayoutBox.gameObject:SetActiveEx(false)
			imgCheckOneUImage.gameObject:SetActiveEx(false)
			txtNameUText.gameObject:SetActiveEx(false)
		end
	end
end

function InventoryCtrl:refreshBtnDecomposeState(selectedGensTable)
	local buttons = self.view.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local data = buttons[i].dataFromUList

		if data and data.tIndex == 0 then
			local objectReference = buttons[i]:GetComponent("ObjectReference")
			local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
			local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
			local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
			local txtNameUText = objectReference:GetRefValue("selectedName")
			local num = selectedGensTable[data.genID] or 0

			btnDelUButton.gameObject:SetActiveEx(num > 0)

			if num > 0 then
				function btnDelUButton.luaClick()
					self.decompose:decreaseSelected(data.genID, true)
				end
			else
				btnDelUButton.luaClick = nil
			end

			ClientTextUtils.setText(txtNameUText, num)
			selectedULayoutBox.gameObject:SetActiveEx(num > 0)

			local stackCount = ItemUtils.getItemStackCount(data.itemId)

			if stackCount == 1 then
				imgCheckOneUImage.gameObject:SetActiveEx(true)
				txtNameUText.gameObject:SetActiveEx(false)
			else
				imgCheckOneUImage.gameObject:SetActiveEx(false)
				txtNameUText.gameObject:SetActiveEx(true)
			end
		end
	end
end

function InventoryCtrl:event_RefreshInvPropList()
	return
end

function InventoryCtrl:event_CarryDataChanged()
	self.propInventory:refreshPropList(false)
end

function InventoryCtrl:event_PropCountChanged(info)
	self:refreshCapacity()
end

function InventoryCtrl:event_CurrencyChange()
	self:refreshCurrencyView()
end

function InventoryCtrl:onBattlePassChange(data)
	LuaUIUtils.tryOpenBattlePassUnlockPopup(data)
end

function InventoryCtrl:event_PropGenCountChanged(info)
	local invId = info.invId
	local genId = info.genId
	local changeType = info.changeType

	if invId == self.model.curInvType then
		if changeType == ItemConst.INV_GEN_CHANGE then
			self.propInventory:refreshGenCount(genId, changeType)
		else
			self.propInventory:refreshPropList(false)
		end
	end

	self:refreshCapacity()
end

function InventoryCtrl:event_ItemLockStatusChanged(info)
	local invId = info.invId
	local genId = info.genId

	if invId == self.model.curInvType then
		self.propInventory:refreshPropStatusByGenId(genId)
	end

	self.propDetail:refreshLockStatus()
end

function InventoryCtrl:event_PlayerPropSlotChanged()
	return
end

function InventoryCtrl:event_CatchBallSlotChanged(info)
	if self.pendingCatchBallSlotChanged then
		self.pendingCatchBallSlotChangedInfo = info

		return
	end

	self.pendingCatchBallSlotChanged = true
	self.pendingCatchBallSlotChangedInfo = info
	self.pendingCatchBallFocusItemId = self.propInventory:getFocusedListItemId() or info.itemId

	TimerManager.addNextFrameCb(function()
		local changeInfo = self.pendingCatchBallSlotChangedInfo
		local focusItemId = self.pendingCatchBallFocusItemId

		self.pendingCatchBallSlotChanged = nil
		self.pendingCatchBallSlotChangedInfo = nil
		self.pendingCatchBallFocusItemId = nil

		if not self.propInventory or not self.catchBallSlot then
			return
		end

		if not self.propInventory:refreshChangedBallItems() then
			self.propInventory:refreshPropList(false)
		end

		self.catchBallSlot:refreshBallList(true)
		self.catchBallSlot:playEquipAnim(changeInfo.itemId)
		self.propInventory:tryRestoreFocusToItem(focusItemId)
	end)
end

function InventoryCtrl:event_PetLevelChange(info)
	self:startTimer(function()
		pg.global.ui:open(UIConst.UI_ID_PET_LEVEL_UP, info)
	end, 0.1)
end

function InventoryCtrl:event_PetListChanged()
	return
end

function InventoryCtrl:showDetailLockBtn(show)
	if self.propDetail then
		self.propDetail:showLockBtn(show)
	end
end

function InventoryCtrl:onClickLockBtn(sData)
	local sDataTab = self.view.listTabIconUList.selectedItem

	if sDataTab.funcType == 3 and self.model:getSelectPropLockStatus() ~= true then
		self.catchBallSlot:delCatchBall(sData)
	end
end

return InventoryCtrl
