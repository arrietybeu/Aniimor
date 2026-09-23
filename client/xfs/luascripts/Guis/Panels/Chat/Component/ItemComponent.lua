-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\ItemComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ItemComponent = Class.LightClass("ItemComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")

function ItemComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.itemListUList = objectReference:GetRefValue("itemListUList")
	self.buttonSearchUButton = objectReference:GetRefValue("buttonSearchUButton")
	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.selectorNameUSDFText = objectReference:GetRefValue("selectorNameUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.inputField = objectReference:GetRefValue("inputField")
	self.propInfoUComponent = objectReference:GetRefValue("propInfoUComponent")
	self.btnScreenUButton = objectReference:GetRefValue("btnScreenUButton")
end

function ItemComponent:initView()
	function self.bgCloseUButton.luaClick()
		self:onClose()
	end

	function self.btnCloseUButton.luaClick()
		self:onClose()
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.btnCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self:onClose()
	end

	function self.itemListUList.luaRenderItem(button, index, data)
		self:renderPropItem(button, index, data)
	end

	function self.btnConfirmUButton.luaClick()
		if not self.selectedPropData then
			return
		end

		local channelId = self.view.channelListUList.selectedItem.channelId

		if pg.game.chat:getWorldMessageCD() > 0 and pg.game.chat:isWorldChatGroupId(channelId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_SEND_CD"), 2)

			return
		end

		local text = pg.getGameString("PROP")
		local curSelectedChannelData = self.view.channelListUList.selectedItem

		pg.game.chat:sendMessage(text, pg.game.chat.subMessageType.Text, curSelectedChannelData.type, curSelectedChannelData.channelId or curSelectedChannelData.playerId, {
			[Const.CHAT_EXTRA_TYPE.Item] = self.selectedPropData
		})
		self.ctrl.chatComponent:checkSendButtonState()
		self:onClose(true)
	end

	function self.buttonSearchUButton.luaClick()
		self.uWidget:TryChangePage("Search", 1)
	end

	function self.btnScreenUButton.luaClick()
		self.uWidget:TryChangePage("Search", 0)

		self.inputField.text = ""

		self:refreshInputDeleteButton()
	end

	function self.inputField.luaEndEdit(text)
		self:doSearch(text)
	end

	function self.inputField.luaValueChanged(text)
		self:refreshInputDeleteButton(text)
		self:doSearch(text)
	end

	local inputObjectReference = self.inputField:GetComponent("ObjectReference")
	local placeHolderUSDFText = inputObjectReference:GetRefValue("placeHolderUSDFText")

	self.btnDeleteUButton = inputObjectReference:GetRefValue("btnDeleteUButton")

	local keyHotKeyContent = inputObjectReference:GetRefValue("keyHotKeyContent")

	LuaUIUtils.bindInputFieldGamepad(self.inputField, keyHotKeyContent, self.btnDeleteUButton)
	ClientTextUtils.setText(placeHolderUSDFText, pg.getGameString("CHAT_TIP_INPUT_ITEM_NAME"))
	self:refreshInputDeleteButton()

	self.btnConfirmUButton.interactable = false
	self.selectorTabs = pg.global.ui.inventory.model:getTabList()

	function self.selectorUSelector.luaRenderPopup(popup, uList)
		function uList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			ClientTextUtils.setText(txtUText, pg.getLocalizationText(data.name))
		end

		function uList.luaSelectedChanged(selectorList)
			ClientTextUtils.setText(self.selectorNameUSDFText, selectorList.selectedItem.name)

			self.selectedPropTypeName = selectorList.selectedItem.name

			self.selectorUSelector:ClosePopup()
			self:refreshItemList(selectorList.selectedItem.invId)

			self.curInvId = selectorList.selectedItem.invId
			self.curSelectedIndex = selectorList.selectedIndex
		end

		uList:SetList(self.selectorTabs)
		uList:SelectItem(self.curSelectedIndex or 0)
	end

	function self.uWidget.luaTryChangePage(controllerName, pageIndex, lastPageIndex)
		if controllerName == "ShowProp" then
			if pageIndex == 0 then
				CS.XGUI.Navigation.ConsoleBar.SetManualDimForAll(false)
				self.buttonSearchUButton:SetHotkeyForceHidden(false)
				self.inputField:SetHotkeyForceHidden(false)
				self.selectorUSelector:SetHotkeyForceHidden(false)
				CS.XGUI.Navigation.NavManager.Instance:UpdateHotkeyActivationState()
			else
				CS.XGUI.Navigation.ConsoleBar.SetManualDimForAll(true)
				self.buttonSearchUButton:SetHotkeyForceHidden(true)
				self.inputField:SetHotkeyForceHidden(true)
				self.selectorUSelector:SetHotkeyForceHidden(true)
				CS.XGUI.Navigation.NavManager.Instance:UpdateHotkeyActivationState()
			end
		end
	end
end

function ItemComponent:refreshItemList(invId)
	self.view.panelUComponent:TryChangePage("ShowPopup", 3)
	self.uWidget:TryChangePage("ShowProp", 0)

	if not invId then
		invId = self.selectorTabs[1].invId

		ClientTextUtils.setText(self.selectorNameUSDFText, self.selectorTabs[1].name)

		self.selectedPropTypeName = self.selectorTabs[1].name
		self.curSelectedIndex = 0

		for _, tab in pairs(self.selectorTabs) do
			tab.selected = false
		end
	end

	local itemsData = LuaUIUtils.getInventoryProps(invId)

	table.sort(itemsData, function(c1, c2)
		local slot1 = c1.bindCatchBallSlot and c1.bindCatchBallSlot or math.maxInt
		local slot2 = c2.bindCatchBallSlot and c2.bindCatchBallSlot or math.maxInt

		if slot1 ~= slot2 then
			return slot1 < slot2
		end

		if c1.quality ~= c2.quality then
			if self.sortIsAscending == true then
				return c1.quality < c2.quality
			else
				return c1.quality > c2.quality
			end
		end

		return c1.itemId < c2.itemId
	end)

	if itemsData and #itemsData > 0 then
		self.itemListUList:SetList(itemsData)
		self.uWidget:TryChangePage("Empty", 0)
	else
		self.itemListUList:SetList({})
		self.uWidget:TryChangePage("Empty", 1)
	end
end

function ItemComponent:renderPropItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	ClientTextUtils.setText(txtNumUText, tostring(data.packSlot.count))

	itemIconUImage.url = data.icon

	button:TryChangePage("Quality", data.quality)

	function button.luaNavFocused()
		if not pg.game.input:isUsingGamepad() then
			return
		end

		self:selectPropItem(button, data)
	end

	function button.luaClick()
		self:selectPropItem(button, data)
		self.uWidget:TryChangePage("ShowProp", 1)
		LuaUIUtils.refreshItemInfo(self.propInfoUComponent, self.selectedPropData, button)
	end
end

function ItemComponent:selectPropItem(button, data)
	self.selectedPropData = {
		name = data.name,
		itemId = data.itemId,
		itemCount = data.count,
		genID = data.genID
	}
	self.btnConfirmUButton.interactable = true
	self.curSelectedButton = button
end

function ItemComponent:doSearch(text)
	local ret = {}

	if string.isNilOrEmpty(text) then
		self:refreshItemList(self.curInvId)

		return
	end

	for _, tab in pairs(self.selectorTabs) do
		local props = LuaUIUtils.getInventoryProps(tab.invId)

		for _, prop in pairs(props) do
			if string.find(pg.getLocalizationText(prop.name), text) then
				table.insert(ret, prop)
			end
		end
	end

	self.uWidget:TryChangePage("Empty", #ret > 0 and 0 or 1)
	self.itemListUList:SetList(ret)
end

function ItemComponent:refreshInputDeleteButton(text)
	text = text or self.inputField.text

	self.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
end

function ItemComponent:onClose(force)
	local _, page = self.uWidget:TryGetCurrentPage("ShowProp")

	if page == 1 then
		self.uWidget:TryChangePage("ShowProp", 0)

		self.curSelectedButton.isSelected = false

		if not force then
			return
		end
	end

	self.uWidget:TryChangePage("Search", 0)

	self.inputField.text = ""

	self:refreshInputDeleteButton()

	self.curSelectedButton = nil
	self.curInvId = nil
	self.selectedPropData = nil

	self.view.panelUComponent:TryChangePage("ShowPopup", 0)

	self.btnConfirmUButton.interactable = false
end

return ItemComponent
