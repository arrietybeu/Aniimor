-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityGot\\VitalityGotCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityGotCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local VitalityGotCtrl = Class.LightClass("VitalityGotCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local ItemSelectionTipsUtils = require("Common.Utils.ItemSelectionTipsUtils")

VitalityGotCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItemsCallback",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onPropChangedCallback",
		true
	}
}

function VitalityGotCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function VitalityGotCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnClose2.luaClick()
		self:dismiss()
	end

	function self.view.btnCancel.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirm.luaClick()
		self:onBtnConfirm()
	end

	function self.view.itemList.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.view.itemList.luaSelectedChanged(uList, select)
		if select then
			uList:SelectItem(-1, false)
		end
	end

	function self.view.itemList.luaClick(button, data)
		if ItemSelectionTipsUtils.consumeLongPressClick(button) then
			return
		end

		if not data then
			return
		end

		if ItemSelectionTipsUtils.isUsingGamepad() then
			return
		end

		self.view.itemList:SelectItem(-1, false)

		button.isSelected = false

		ItemSelectionTipsUtils.showItemTips(button, data.id, data.ownNum)
	end

	if self.view.itemListNew then
		function self.view.itemListNew.luaRenderItem(button, index, data)
			self:onRenderSelectablePropItem(button, index, data)
		end

		function self.view.itemListNew.luaSelectedChanged(uList, select)
			if select and not self.selectedPropId then
				uList:SelectItem(-1, false)
			end
		end

		function self.view.itemListNew.luaClick(button, data)
			if ItemSelectionTipsUtils.consumeLongPressClick(button) then
				return
			end

			self:onSelectablePropClick(data)
		end
	end
end

function VitalityGotCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.timer then
		self:killTimer(self.timer)
	end
end

function VitalityGotCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.itemId = info and info.itemId

	if not self.itemId then
		return
	end

	self.restoreData = LuaUIUtils.getVitalityData(self.itemId)
	self.timer = self:startTimer(function()
		self:refreshTimeView()
	end, 0.02, true)

	self:refreshCurrencyView()

	local propList, defaultIdx = self.model:getPropDataList(self.itemId)

	self.propList = propList

	local isMultiItem = ItemSelectionTipsUtils.isMultiItem(#propList)
	local useMultiList = isMultiItem and self.view.itemListNew ~= nil

	if self.view.btnClose2 then
		self.view.btnClose2:RemoveLuaGamepadHotkey()

		if useMultiList then
			self.view.btnClose2:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, function()
				return true
			end)
			self.view.btnClose2:SetHotkeyConsoleBar("CONSOLE_BAR_SELECT_DESELECT", 1)
		end
	end

	self.view.itemList.gameObject:SetActiveEx(not useMultiList)

	if self.view.itemListNew then
		self.view.itemListNew.gameObject:SetActiveEx(useMultiList)
	end

	self.selectedPropData = propList[(defaultIdx or 0) + 1] or propList[1]
	self.selectedPropId = self.selectedPropData and self.selectedPropData.id or nil

	if useMultiList then
		self.view.itemListNew:SetList(propList)
	else
		self.view.itemList:SetList(propList)
	end

	self:onPropSelectChanged(self.selectedPropData)

	self.view.btnConfirm.interactable = not self.restoreData.isLimit
end

function VitalityGotCtrl:onShow()
	return
end

function VitalityGotCtrl:refreshTimeView()
	LuaUIUtils.parseVitalityTime(self.restoreData)

	local timeStr

	if not self.restoreData.isFull then
		timeStr = pg.getGameString("ENERGY_RESTORE_TIME_TIP")
		timeStr = pg.getFormatText(timeStr, self.restoreData.nextRestoreEndTimeStr, self.restoreData.totalRestoreEndTimeStr)
	elseif self.restoreData.isLimit then
		timeStr = pg.getGameString("ENERGY_RESTORE_LIMIT")
	else
		timeStr = pg.getGameString("ENERGY_RESTORE_FULL")
	end

	ClientTextUtils.setText(self.view.recoverTime, timeStr)
end

function VitalityGotCtrl:refreshCurrencyView()
	local data = LuaUIUtils.getVitalityData()
	local objectReference = self.view.currencyItem:GetComponent("ObjectReference")
	local countUText = objectReference:GetRefValue("countUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnAdd = objectReference:GetRefValue("btnAdd")

	ClientTextUtils.setText(countUText, string.format("%d/%d", data.num, data.maxRestoreNum))

	iconUImage.url = data.icon

	self.view.currencyItem:TryChangePage("IsAdd", 0)

	function btnAdd.luaClick()
		LuaUIUtils.openVitalityGot(self.itemId)
	end
end

function VitalityGotCtrl:onRenderPropItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	button.gameObject.name = tostring(data.id)

	ClientTextUtils.setText(txtNameUText, data.ownNum)

	button.isSelected = false

	ItemSelectionTipsUtils.bindLongPressTips(button, function()
		ItemSelectionTipsUtils.showItemTips(button, data.id, data.ownNum)
	end)
end

function VitalityGotCtrl:onRenderSelectablePropItem(button, index, data)
	LuaUIUtils.renderItem(button, {
		num = -1,
		id = data.id
	})

	button.gameObject.name = tostring(data.id)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNumUBaseText = objectReference and objectReference:GetRefValue("txtNumUBaseText")

	if txtNumUBaseText then
		ClientTextUtils.setText(txtNumUBaseText, data.ownNum)
	end

	button.isSelected = self.selectedPropId == data.id

	ItemSelectionTipsUtils.bindLongPressTips(button, function()
		ItemSelectionTipsUtils.showItemTips(button, data.id, data.ownNum)
	end)
end

function VitalityGotCtrl:onSelectablePropClick(data)
	if not data then
		return
	end

	self.selectedPropId = ItemSelectionTipsUtils.toggleSelectedId(self.selectedPropId, data.id)
	self.selectedPropData = self.selectedPropId and data or nil

	if self.view.itemListNew and self.view.itemListNew.RefreshList then
		self.view.itemListNew:RefreshList()
	end

	self:onPropSelectChanged(self.selectedPropData)
end

function VitalityGotCtrl:onPropSelectChanged(selectData)
	if not selectData then
		ClientTextUtils.setText(self.view.consumeTip, "")

		return
	end

	if selectData.isShop or selectData.isMoneyShop then
		local costText = LuaUIUtils.getItemCountConsumeShowText(selectData.id, selectData.costNum, true)
		local obtainText = LuaUIUtils.getItemObtainShowText(self.itemId, selectData.obtainNum, true)
		local resetText = LuaUIUtils.getItemBuyResetText(selectData.limitType)

		if resetText then
			ClientTextUtils.setText(self.view.consumeTip, pg.getFormatText(pg.getGameString("CONSUME_PYROXENE_RESTORE_ENERGY"), costText, obtainText, resetText, selectData.limitCount))
		else
			ClientTextUtils.setText(self.view.consumeTip, pg.getFormatText(pg.getGameString("CONSUME_PYROXENE_RESTORE_ENERGY_NO_LIMIT"), costText, obtainText))
		end
	else
		local obtainText = LuaUIUtils.getItemObtainShowText(self.itemId, selectData.itemEffect, true)

		ClientTextUtils.setText(self.view.consumeTip, pg.getFormatText(pg.getGameString("CONSUME_BATTERY_RESTORE_ENERGY"), selectData.name, obtainText))
	end
end

function VitalityGotCtrl:onBtnConfirm()
	if self.restoreData.isLimit then
		return
	end

	local selectData = self.selectedPropData

	if selectData == nil then
		return
	end

	if selectData.isMoneyShop then
		if selectData.limitCount <= 0 then
			pg.global.showBubbleMessage(NoticeDef.SHOP_COMMODITY_LIMITNUM)

			return
		end

		ClientCashShopUtils.openBuyConfirm(selectData.moneyShopItemId, {
			selectData.id,
			selectData.costNum
		}, 1, nil, nil, function(retStatus)
			if retStatus == 0 then
				self:close()
			end
		end)
	elseif selectData.isShop then
		if selectData.limitCount <= 0 then
			pg.global.showBubbleMessage(NoticeDef.SHOP_COMMODITY_LIMITNUM)

			return
		end

		if selectData.ownNum < selectData.costNum then
			pg.global.showBubbleMessage(NoticeDef.ITEM_COUNT_LACK)

			return
		end

		pg.global.showConfirmMsgRaw(pg.getGameString("ENERGY_EXCHANGE_TITLE"), pg.getGameString("ENERGY_EXCHANGE_TIP"), function()
			pg.me:buyCommodity(0, selectData.shopItemId, 1)
			self:close()
		end)
	else
		pg.global.ui:open(UIConst.UI_ID_VITALITY_REDEEM, selectData.id)
	end
end

function VitalityGotCtrl:onBuyItemsCallback(data)
	self:onShow()
end

function VitalityGotCtrl:onPropChangedCallback(data)
	self:onShow()
end

function VitalityGotCtrl:onHide()
	return
end

return VitalityGotCtrl
