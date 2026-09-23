-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrength\\PetCarryAssistStrengthCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryAssistStrengthCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetCarryAssistStrengthCtrl = Class.LightClass("PetCarryAssistStrengthCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local CarryStrengthChecker = require("Guis.Panels.PetCarryStrength.Helper.CarryStrengthChecker")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local PetCarryAssistSelectComponent = require("Guis.Panels.PetCarryAssistStrength.Component.PetCarryAssistSelectComponent")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local CallbackHandler = require("Core.Common.CallbackHandler")

PetCarryAssistStrengthCtrl.messages = {
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"event_ItemChaneg",
		true
	}
}

function PetCarryAssistStrengthCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petCarryAssistSelect = PetCarryAssistSelectComponent.new(self, self.view.selectPanel)
end

function PetCarryAssistStrengthCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBack.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onClosePanel()
		end
	end

	function self.view.btnBack.luaClick()
		self:onClosePanel()
	end

	function self.view.listSelectItem.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.view.listTab.luaRenderItem(button, index, data)
		self:onRenderStrengthTypeItem(button, index, data)
	end

	function self.view.btnFastAdd.luaClick()
		self:onBtnAutoSelect()
	end

	function self.view.btnCompound.luaClick()
		self:onBtnCompound()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = 216
		})
	end

	function self.view.btnDesc.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_AUTO_ADD_DESC"))
	end

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function PetCarryAssistStrengthCtrl:onNavFocusChange()
	local groupName = pg.global.navMgr.CurrentFocusedGroupName
	local inDropdownBar = groupName == "DropdownBar"
	local inTreeDetail = groupName == "TreeDetail"
	local inListProps = groupName == "ListProps"
	local inCircleLoopList = groupName == "CircleLoopList"

	pg.global.navMgr:SetConsoleBarState("PetCarryAssistStrength_In_DropdownBar", inDropdownBar)
	pg.global.navMgr:SetConsoleBarState("PetCarryAssistStrength_In_ListProps", inListProps)
	pg.global.navMgr:SetConsoleBarState("PetCarryAssistStrength_In_CircleLoopList", inCircleLoopList)
	pg.global.navMgr:SetConsoleBarState("PetCarryAssistStrength_In_TreeDetail", inTreeDetail)
end

function PetCarryAssistStrengthCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.showSelect = false
	self.selectItems = {}
	self.closeCallback = info and info.closeCallback

	self.model:setStrengthType(2)
	self:refreshStrengthType()
	self:refreshSelectCarryAssistView()
	self.view.rootUComponent:TryChangePage("CostItem", 0)
end

function PetCarryAssistStrengthCtrl:refreshStrengthType()
	local dataList = self.model:getCarryStrengthTypes()

	self.view.listTab:SetList(dataList)
	self.view.listTab:SelectItem(0)
end

function PetCarryAssistStrengthCtrl:refreshSelectCarryAssistView()
	local selectCarries = self.model:getSelectedCarries()

	self.view.listSelectItem.itemData = selectCarries

	self.view.listSelectItem:RefreshList()

	local strengthType = self.model:getStrengthType()
	local curAdd, needNum = self.model:getAddSelectedCarries()
	local costDesc = pg.getGameString("PET_EQUIPMENT_GEM_QUALITY_NAME_" .. strengthType)
	local tex = string.format(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_CONSUME_DESC"), costDesc, curAdd, needNum)

	ClientTextUtils.setText(self.view.txtAddInfo, tex)

	local isSameAssist, rewardName = self.model:isSameAssist(selectCarries)
	local getTex

	if isSameAssist then
		getTex = string.format(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_GET_DESC"), pg.getLocalizationText(rewardName))
	else
		getTex = pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_GET_DESC_RANDOM")
	end

	ClientTextUtils.setText(self.view.txtResult, getTex)
	ClientTextUtils.setText(self.view.txtCompoundName, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_BUTTON"))

	local showAddDesc = curAdd > 0 and pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_CLEAR_BUTTON") or pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_AUTO_ADD_BUTTON")

	ClientTextUtils.setText(self.view.txtFastAddName, showAddDesc)
	ClientTextUtils.setText(self.view.txtEmpty, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_NO_GEM_DEFAULT"))
end

function PetCarryAssistStrengthCtrl:onRenderStrengthTypeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	button:TryChangePage("Quality", data.quality)
	ClientTextUtils.setText(txtNameUBaseText, data.label)

	function button.luaClick()
		self.view.jewelResultUComponent:TryChangePage("Quality", data.type + 1)
		self.model:setStrengthType(data.type)
		self.model:clearSelectedCarries()
		self:refreshView()
		self.petCarryAssistSelect:onOptionSelected()

		if pg.game.input:isUsingGamepad() then
			pg.global.ui:closePanel(34)
		end
	end
end

function PetCarryAssistStrengthCtrl:setSelectItem(index)
	if index then
		if not self.showSelect then
			self.petCarryAssistSelect:openSelectPanel()
			self.view.rootUComponent:TryChangePage("CostItem", 1)

			self.showSelect = true
		end

		self.model:setSelectedIndex(index)
	end

	for i, v in ipairs(self.selectItems) do
		v:TryChangePage("Selected", i == index and 5 or 0)
	end
end

function PetCarryAssistStrengthCtrl:onRenderPropItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgAdd = objectReference:GetRefValue("imgAdd")
	local btnDelete = objectReference:GetRefValue("btnDelete")

	button.draggable = false

	function button.luaClick()
		self:setSelectItem(data.index)
	end

	function btnDelete.luaClick()
		if data.carryData then
			self.model:setSelected(false, data.carryData, data.index)
			self:refreshView()
		end
	end

	if data.carryData then
		imgAdd.url = data.carryData.icon
	end

	button:TryChangePage("State", data.carryData and 1 or 0)

	local strengthType = self.model:getStrengthType()

	button:TryChangePage("Quality", strengthType)

	if not self.selectItems[data.index] then
		self.selectItems[data.index] = button
	end
end

function PetCarryAssistStrengthCtrl:onBtnAutoSelect()
	self:setSelectItem()

	self.petCarryAssistSelect.isListDirty = true

	self.model:autoSelectedCarries()
	self:refreshView()
end

function PetCarryAssistStrengthCtrl:onBtnCompound()
	local canAdd = self.model:canAddSelectedCarries()

	if canAdd then
		pg.global.showBubbleMessageRaw(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_NOT_ENOUGH"), 3)

		return
	end

	local selectCarries = self.model:getSelectedCarries()
	local compoundList = {}

	for i, v in ipairs(selectCarries) do
		compoundList[#compoundList + 1] = {
			v.carryData.invId,
			v.carryData.genID
		}
	end

	pg.me:serverMsg("RPC_CS_ComposeAssistCarry", compoundList)
end

function PetCarryAssistStrengthCtrl:event_ItemChaneg(info)
	if info and info.changeType == 1 then
		local invId = info.invId
		local genId = info.genId
		local data = pg.global.ui.petTrainingNew.model:parseCarryFullInfoWithId(invId, genId)

		if data then
			self:setSelectItem()
			self.model:onCompoundAssist()
			pg.global.ui:open(UIConst.UI_ID_PET_CARRY_ASSIST_STRENGTH_RESULT, {
				data = data,
				closeCallback = function()
					self:refreshView()
				end
			})
		end
	end
end

function PetCarryAssistStrengthCtrl:refreshView()
	self.petCarryAssistSelect:onOptionSelected()
	self:refreshSelectCarryAssistView()
end

function PetCarryAssistStrengthCtrl:onClosePanel()
	if self.closeCallback then
		self.closeCallback()
	end

	self:dismiss()
end

function PetCarryAssistStrengthCtrl:onDestroy()
	self.model:clearData()
	UICtrl.onDestroy(self)
end

return PetCarryAssistStrengthCtrl
