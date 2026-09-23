-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrength\\Component\\PetCarrySelectComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetCarrySelectComponent = Class.LightClass("PetCarrySelectComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local CarryStrengthChecker = require("Guis.Panels.PetCarryStrength.Helper.CarryStrengthChecker")
local ItemConst = require("Common.Const.ItemConst")
local NoticeDef = require("Common.NoticeDef")

function PetCarrySelectComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnSort = self.objectReference:GetRefValue("btnSort")
	self.selector = self.objectReference:GetRefValue("selector")
	self.rootComponent = self.transform:GetComponent("UWidget")
end

function PetCarrySelectComponent:initView()
	function self.btnClose.luaClick()
		self:hide()
	end

	function self.listUList.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.listUList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onPropSelectChanged(uList)
	end

	function self.selector.luaSelectedChanged(selector)
		self.model:setSortOption(selector.selectedIndex)
		self:onOptionSelected()
	end

	function self.btnSort.luaClick()
		self.model:switchSortAscending()
		self:onOptionSelected()
	end

	self.isListDirty = false
	self.selector.hideOnClick = true
end

function PetCarrySelectComponent:openSelectPanel()
	self:show()
	self:refreshGroupSelectorOptions()

	if self.isListDirty then
		self:onOptionSelected()
	end

	self.isListDirty = false
end

function PetCarrySelectComponent:refreshGroupSelectorOptions()
	local groupInfos = self.model:getCarrySortOptions()

	self.selector:SetOptions(groupInfos)

	self.selector.selectedIndex = self.model:getSortOption()

	local isAs = self.model:getSortAscending()
end

function PetCarrySelectComponent:onOptionSelected()
	local dataList = self.model:getCarryDataList()

	self.listUList:SetList(dataList)

	if #dataList > 0 then
		self.rootComponent:TryChangePage("Empty", 0)
	else
		self.rootComponent:TryChangePage("Empty", 1)
	end
end

function PetCarrySelectComponent:reselectCarry()
	self.oldSelectIndex = self.oldSelectIndex or 0

	self.listUList:SelectItem(self.oldSelectIndex)
end

function PetCarrySelectComponent:onRenderPropItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local sLv = objectReference:GetRefValue("txtNameUText")
	local cLock = objectReference:GetRefValue("stateLockUWidget")
	local cancelUButton = objectReference:GetRefValue("cancelUButton")

	LuaUIUtils.refreshCarryAssistInfo_Item(objectReference, data)
	button:TryChangePage("Cancel", data.selectedAsExp and 1 or 0)

	button.draggable = false

	if data.type == ItemConst.ITEM_TYPE.CoreCarryCost then
		ClientTextUtils.setText(sLv, data.selectedNum, "/", data.ownNum)
	end

	cLock:SetActive(data.isLocked)

	function button.luaClick(navConfirm)
		self:trySelectItem(data, index, navConfirm)
	end

	function cancelUButton.luaClick()
		self:deselectItem(data, index)
	end

	cancelUButton:SetHotkeyConsoleBar("CONSOLE_BAR_REMOVE", -2, self.view and self.view.consoleBarRectTransform)
end

function PetCarrySelectComponent:trySelectItem(sData, index, navConfirm)
	if navConfirm then
		return
	end

	if not sData.selectedAsExp or sData.type == ItemConst.ITEM_TYPE.CoreCarryCost then
		if not sData.isLocked then
			local selectedCarries = self.model:getSelectedCarries()
			local _, _, isOutOfLv = CarryStrengthChecker.checkAddExpAndLv(self.ctrl.strengthCarry, selectedCarries)

			if isOutOfLv then
				pg.global.showBubbleMessageRaw(pg.getGameString("PET_EQUIPMENT_EXP_MAXED"), 2)
			else
				sData.selectedAsExp = true

				if sData.type == ItemConst.ITEM_TYPE.CoreCarryCost then
					if sData.selectedNum >= sData.ownNum then
						pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)

						return
					else
						sData.selectedNum = sData.selectedNum + 1
					end
				end

				self:refreshSelectState(index)
			end
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("UNLOCK_FIRST"), 2)
		end
	else
		self:deselectItem(sData, index)
	end
end

function PetCarrySelectComponent:deselectItem(sData, index)
	if sData.type == ItemConst.ITEM_TYPE.CoreCarryCost then
		sData.selectedNum = sData.selectedNum - 1

		if sData.selectedNum == 0 then
			sData.selectedAsExp = false
		end
	else
		sData.selectedAsExp = false
	end

	if index then
		self:refreshSelectState(index)
	else
		self.isListDirty = true

		self.ctrl:refreshSelectCarryView()
	end
end

function PetCarrySelectComponent:refreshSelectState(index)
	self.listUList:RefreshElement(index)
	self.ctrl:refreshSelectCarryView()
end

function PetCarrySelectComponent:onPropSelectChanged(uList)
	self.oldSelectIndex = uList.selectedIndex

	local data = uList.selectedItem

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		padding = 160,
		autoClose = false,
		shouldAddGraphicRaycaster = false,
		hierarchyMode = 0,
		autoHor = true,
		checkTouchBegin = false,
		id = data.itemId,
		num = data.ownNum,
		invId = data.invId,
		genID = data.genID,
		targetRect = self.listUList,
		verAlign = CS.XGUI.EVerticalAlignment.Top,
		btnLockFunc = function(tipParam)
			local isLocked = tipParam and tipParam.isLocked

			if isLocked == nil then
				isLocked = data.isLocked
			end

			local isLockNewState = not isLocked

			pg.me:serverMsg("RPC_CS_ModifyItemStatus", data.invId, {
				data.genID
			}, ItemConst.ITEM_STATUS_LOCKED, isLockNewState, function(retCode)
				if retCode == false then
					return
				end

				if tipParam then
					tipParam.isLocked = isLockNewState
				end

				self:onSwitchLockState(data, isLockNewState)
			end)
		end
	})
end

function PetCarrySelectComponent:onSwitchLockState(data, newState)
	local isDirty = false

	data.isLocked = newState

	if newState and data.selectedAsExp then
		data.selectedAsExp = false
		isDirty = true
	end

	self:onOptionSelected()
	self:reselectCarry()

	if isDirty then
		self.ctrl:refreshSelectCarryView()
	end
end

function PetCarrySelectComponent:onHide()
	pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	self.listUList:DeselectAll()
	self.ctrl:refreshSelectCarryView()
end

function PetCarrySelectComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PetCarrySelectComponent
