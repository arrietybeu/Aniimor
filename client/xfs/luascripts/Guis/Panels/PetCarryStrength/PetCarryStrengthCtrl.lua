-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrength\\PetCarryStrengthCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryStrengthCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetCarryStrengthCtrl = Class.LightClass("PetCarryStrengthCtrl", UICtrl)
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemConst = require("Common.Const.ItemConst")
local CarryStrengthChecker = require("Guis.Panels.PetCarryStrength.Helper.CarryStrengthChecker")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local PetCarrySelectComponent = require("Guis.Panels.PetCarryStrength.Component.PetCarrySelectComponent")
local CallbackHandler = require("Core.Common.CallbackHandler")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

PetCarryStrengthCtrl.messages = {
	[MessageName.CARRY_UPGRADE] = {
		"event_CarryUpgrade",
		true
	}
}

function PetCarryStrengthCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petCarrySelect = PetCarrySelectComponent.new(self, self.view.selectPanel)
end

function PetCarryStrengthCtrl:addListener()
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

	function self.view.listAttribute.luaRenderItem(button, index, data)
		self:onRenderAttrItem(button, index, data)
	end

	function self.view.listSelectItem.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:onRenderPropItem(button, index, data)
		else
			self:onRenderEmptyItem(button, index, data)
		end
	end

	function self.view.selector.luaSelectedChanged(selector)
		self.model:setFilterOption(selector.selectedIndex)
		self:onRefreshSelectorWhenSelected(selector)
	end

	function self.view.selector.luaRenderPopup(_, uList)
		self:onRenderSelectorItem(uList)
	end

	function self.view.btnAdd.luaClick()
		self:onBtnAutoSelect()
	end

	function self.view.btnStrength.luaClick()
		self:onBtnStrength()
	end

	self.view.expProgress.value = 0
	self.view.expProgressAdd.value = 0
	self.view.selector.hideOnClick = true

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function PetCarryStrengthCtrl:onNavFocusChange()
	if not pg.global.navMgr then
		return
	end

	self:refreshConsoleBarState()
end

function PetCarryStrengthCtrl:refreshConsoleBarState()
	if pg.global.navMgr then
		local groupName = pg.global.navMgr.CurrentFocusedGroupName
		local ItemName = pg.global.navMgr.CurrentFocusedUContent and pg.global.navMgr.CurrentFocusedUContent.name
		local inListItemUp = groupName == "ListItemUp"
		local inDropdownBar = groupName == "DropdownBar"
		local inListItem = groupName == "Content"
		local inTreeDetail = groupName == "TreeDetail"

		pg.global.navMgr:SetConsoleBarState("CarryStrengthen_In_Bottom_Card", inListItemUp)
		pg.global.navMgr:SetConsoleBarState("CarryStrengthen_In_Top_Card", inListItem and ItemName ~= "BtnEmpty")
		pg.global.navMgr:SetConsoleBarState("CarryStrengthen_In_Selector", inDropdownBar)
		pg.global.navMgr:SetConsoleBarState("CarryStrengthen_In_TreeDetail", inTreeDetail)
	end
end

function PetCarryStrengthCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local carryStrengthInfo = info and info.strengthCarry or {}

	pg.game.petManage:setCoreCarryStrengthRecored(carryStrengthInfo.invId, carryStrengthInfo.genID, carryStrengthInfo)

	self.strengthCarry = info and info.strengthCarry
	self.closeCallback = info and info.closeCallback

	self.model:setStrengthCarry(self.strengthCarry)
	self:initSelector()
	self:resetDefaultView()
	self:resetMaxStateView()
	self:refreshCurrentCarryView()
	self:refreshSelectCarryView()
end

function PetCarryStrengthCtrl:refreshCurrentCarryView()
	local data = self.strengthCarry

	ClientTextUtils.setText(self.view.txtName, data.name)

	self.view.iconCarry.url = data.bigIcon

	self.view.rootComponent:TryChangePage("Quality", data.quality)
end

function PetCarryStrengthCtrl:resetDefaultView()
	local data = self.strengthCarry

	self.view.expProgress.value = data.curExp / data.maxExp
	self.view.expProgressAdd.value = 0
end

function PetCarryStrengthCtrl:resetMaxStateView()
	local data = self.strengthCarry

	if data.isMaxLv then
		self.view.rootComponent:TryChangePage("Max", 1)
		self.view.rootComponent:TryChangePage("MaxOp", 1)
	else
		self.view.rootComponent:TryChangePage("Max", 0)
		self.view.rootComponent:TryChangePage("MaxOp", 0)
	end
end

function PetCarryStrengthCtrl:refreshPropertyView()
	local data = self.strengthCarry
	local selectedCarries = self.model:getSelectedCarries()
	local addExp, newLv, _ = CarryStrengthChecker.checkAddExpAndLv(data, selectedCarries)

	ClientTextUtils.setText(self.view.txtLvNow, string.format(" +%d", data.cLevel))
	ClientTextUtils.setText(self.view.txtExpNow, string.format("%d/%d", data.curExp, data.maxExp))
	self.view.expProgress:ProgressToValue(data.curExp / data.maxExp, nil, 0.5)
	self.view.expProgressAdd:ProgressToValue((data.curExp + addExp) / data.maxExp, nil, 0.5)

	if addExp == 0 then
		self.view.rootComponent:TryChangePage("State", 0)
	elseif newLv - data.cLevel > 0 then
		self.view.rootComponent:TryChangePage("State", 2)
		ClientTextUtils.setText(self.view.txtLvAfter, string.format("+%d", newLv))
	else
		self.view.rootComponent:TryChangePage("State", 1)
	end

	ClientTextUtils.setText(self.view.txtExpAdd, string.format("+%d", addExp))

	if newLv >= data.mLevel then
		self.view.rootComponent:TryChangePage("Max", 1)
	else
		self.view.rootComponent:TryChangePage("Max", 0)
	end

	local recordOldInfo = pg.game.petManage:getCoreCarryStrengthRecored(data.invId, data.genID)
	local refreshInfo = recordOldInfo and recordOldInfo or data
	local oldAssistUnlock = refreshInfo and refreshInfo.assistUnlock or {}

	self.asstAdd = 0

	for i, v in ipairs(oldAssistUnlock) do
		if v == 0 and data.slotUnlockLv and data.slotUnlockLv[i] and newLv >= data.slotUnlockLv[i] then
			self.asstAdd = self.asstAdd + 1
		end
	end

	self.carryAttrs = self.model:getPropertyUpInfo(data, newLv, self.asstAdd)

	self.view.listAttribute:SetList(self.carryAttrs)
	self.view.listAttribute:SetActive(false)
	TimerManager.addNextFrameCb(function()
		if NotNil(self.view) and NotNil(self.view.listAttribute) then
			self.view.listAttribute:SetActive(true)
		end
	end)

	local showAddDesc = addExp > 0 and pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_CLEAR_BUTTON") or pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_AUTO_ADD_BUTTON")

	ClientTextUtils.setText(self.view.txtAdd, showAddDesc)
end

function PetCarryStrengthCtrl:refreshBtnState()
	local itemData = self.view.listSelectItem.itemData

	if itemData.Count == 0 then
		-- block empty
	end
end

function PetCarryStrengthCtrl:initSelector()
	local groupInfos = self.model:getCarryFilterOptions()

	self.view.selector:SetOptions(groupInfos)

	self.view.selector.selectedIndex = self.model:getFilterOption()

	self:onRefreshSelectorWhenSelected(self.view.selector)
end

function PetCarryStrengthCtrl:refreshSelectCarryView()
	local selectCarries = self.model:getSelectedCarries()

	self.view.listSelectItem:SetList(selectCarries)
	self:refreshPropertyView()
end

function PetCarryStrengthCtrl:onRenderAttrItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if data.tIndex == 0 then
		local txtName = objectReference:GetRefValue("txtName")
		local txtNumNow = objectReference:GetRefValue("txtNumNow")
		local txtNumAfter = objectReference:GetRefValue("txtNumAfter")

		ClientTextUtils.setText(txtName, data.name)
		ClientTextUtils.setText(txtNumNow, data.tDesc)
		ClientTextUtils.setText(txtNumAfter, data.nDesc)
	else
		local txtName = objectReference:GetRefValue("txtName")
		local txtNum = objectReference:GetRefValue("txtNum")

		ClientTextUtils.setText(txtName, pg.getGameString("PET_EQUIPMENT_NEW_GEM_SLOT_UNLOCK"))
		ClientTextUtils.setText(txtNum, string.format("x%s", data.assistAdd))
	end
end

function PetCarryStrengthCtrl:onRenderPropItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local sLv = objectReference:GetRefValue("txtNameUText")
	local cLock = objectReference:GetRefValue("stateLockUWidget")
	local carryItem = objectReference:GetRefValue("carryItem")
	local cancelUButton = objectReference:GetRefValue("cancelUButton")

	LuaUIUtils.refreshCarryAssistInfo_Item(objectReference, data)
	button:TryChangePage("Cancel", 1)

	button.draggable = false

	if data.type == ItemConst.ITEM_TYPE.CoreCarryCost then
		ClientTextUtils.setText(sLv, data.selectedNum, "/", data.ownNum)
	end

	carryItem:SetActive(false)
	cLock:SetActive(data.isLocked)

	function button.luaClick()
		self.petCarrySelect:openSelectPanel()
	end

	function cancelUButton.luaClick()
		self.petCarrySelect:deselectItem(data)
	end
end

function PetCarryStrengthCtrl:onRenderEmptyItem(button, index, data)
	button.draggable = false

	function button.luaClick()
		self.petCarrySelect:openSelectPanel()
	end
end

function PetCarryStrengthCtrl:onBtnAutoSelect()
	self.petCarrySelect.isListDirty = true

	self.model:autoSelectedCarries(self.strengthCarry)
	self:refreshSelectCarryView()
end

function PetCarryStrengthCtrl:onBtnStrength()
	local consumeList, consumeDict, containHighLv = self.model:getConsumeDataList()

	if #consumeList == 0 and table.getCount(consumeDict) == 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("ADD_MAT_FIRST"), 3)

		return
	end

	local sData = self.strengthCarry

	if containHighLv then
		pg.global.showConfirmMsgRaw(pg.getGameString("CARRY_STRENGTH"), pg.getGameString("CARRY_CONSUME_DOUBLE_CONFIRMATION_TIP"), function()
			pg.game.petManage:sendCoreCarryStrengthRpc(sData.invId, sData.genID, consumeList, consumeDict, self.strengthCarry)
		end)
	else
		pg.game.petManage:sendCoreCarryStrengthRpc(sData.invId, sData.genID, consumeList, consumeDict, self.strengthCarry)
	end
end

function PetCarryStrengthCtrl:event_CarryUpgrade()
	local sData = self.strengthCarry
	local oldLv = sData.cLevel
	local oldExp = sData.curExp

	self.model:overrideCarryData(sData)

	if oldLv < sData.cLevel then
		local res = {
			oldLv = oldLv,
			newLv = sData.cLevel,
			itemId = sData.itemId,
			carryAttrs = self.carryAttrs,
			assistAdd = self.asstAdd,
			isMaxLv = sData.isMaxLv
		}

		pg.global.ui:open(UIConst.UI_ID_PET_CARRY_STRENGTH_RESULT, res)
	else
		self.view.expProgress.value = oldExp / sData.maxExp

		self.view.expProgress:ProgressToValue(sData.curExp / sData.maxExp, nil, 0.5)
	end

	self.model:clearData()

	self.petCarrySelect.isListDirty = true

	self:startTimer(function()
		self:refreshSelectCarryView()
	end, 0.6)
	self:resetMaxStateView()
end

function PetCarryStrengthCtrl:onClosePanel()
	self:doColseCallback()
	self:dismiss()
end

function PetCarryStrengthCtrl:onHide()
	return
end

function PetCarryStrengthCtrl:onDestroy()
	self:doColseCallback()
	self.model:clearData()
	UICtrl.onDestroy(self)
end

function PetCarryStrengthCtrl:doColseCallback()
	if self.closeCallback then
		self.closeCallback()

		self.closeCallback = nil
	end
end

function PetCarryStrengthCtrl:onRenderSelectorItem(uList)
	function uList.luaRenderItem(uButton, idx, data)
		uButton:TryChangePage("Quality", data.quality)
	end
end

function PetCarryStrengthCtrl:onRefreshSelectorWhenSelected(selector)
	local selectedIndex = selector and selector.selectedIndex or -1

	if selectedIndex >= 0 then
		local options = self.model:getCarryFilterOptions()

		if options and options[selectedIndex + 1] then
			self.view.selector:TryChangePage("Quality", options[selectedIndex + 1].quality)
		end
	end
end

return PetCarryStrengthCtrl
