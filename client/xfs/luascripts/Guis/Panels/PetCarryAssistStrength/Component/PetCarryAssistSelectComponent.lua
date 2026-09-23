-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrength\\Component\\PetCarryAssistSelectComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetCarryAssistSelectComponent = Class.LightClass("PetCarryAssistSelectComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local PetConfigData = require("Data.pet_config_data")

function PetCarryAssistSelectComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.assistTab1 = objectReference:GetRefValue("assistTab1")
	self.assistTab2 = objectReference:GetRefValue("assistTab2")
	self.assistTab3 = objectReference:GetRefValue("assistTab3")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnSort = objectReference:GetRefValue("btnSort")
	self.selector = objectReference:GetRefValue("selector")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.txtEmpty = objectReference:GetRefValue("txtEmpty")
end

function PetCarryAssistSelectComponent:initView()
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

	for i = 1, 3 do
		self["assistTab" .. i].luaClick = function()
			self.model:setAssistTypeOption(i)
			self:onOptionSelected()

			if pg.game.input:isUsingGamepad() then
				pg.global.ui:closePanel(34)
			end
		end
	end

	function self.btnSort.luaClick()
		self.model:switchSortAscending()
		self:onOptionSelected()
	end

	self.isListDirty = false
	self.selector.hideOnClick = true

	self.btnSort:TryChangePage("Sort", not self.model.isAscending and 1 or 0)
	ClientTextUtils.setText(self.txtEmpty, pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_NO_GEM_DEFAULT"))
	LuaUIUtils.setSourceSeekButton(self.view.btnToGetUButton, PetConfigData.PETCARRY_SOURCE_ID_2, true)
	ClientTextUtils.setText(self.view.btnToGetTxtNameUSDFText, pg.getGameString("PETCARRY_TO_GET_GEM_TIP"))
	ClientTextUtils.setText(self.view.txtToGetUSDFText, pg.getGameString("PETCARRY_GOTTO_SOURCE"))
end

function PetCarryAssistSelectComponent:openSelectPanel()
	self:refreshGroupSelectorOptions()

	if self.isListDirty then
		self:onOptionSelected()
	end

	self.isListDirty = false
end

function PetCarryAssistSelectComponent:refreshGroupSelectorOptions()
	local groupInfos = self.model:getCarrySortOptions()

	self.selector:SetOptions(groupInfos)

	self.selector.selectedIndex = self.model:getSortOption()

	local isAs = self.model:getSortAscending()
end

function PetCarryAssistSelectComponent:onOptionSelected()
	local dataList = self.model:getCarryDataList()

	self.listUList:SetList(dataList)

	if #dataList > 0 then
		self.rootComponent:TryChangePage("Empty", 0)
	else
		self.rootComponent:TryChangePage("Empty", 1)
	end

	for i = 1, 3 do
		self["assistTab" .. i]:SetSelected(i == self.model:getAssistTypeOption())
	end
end

function PetCarryAssistSelectComponent:reselectCarry()
	self.oldSelectIndex = self.oldSelectIndex or 0

	self.listUList:SelectItem(self.oldSelectIndex)
end

function PetCarryAssistSelectComponent:onRenderPropItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")

	LuaUIUtils.refreshCarryAssistInfo_Item(objectReference, data)

	local cLock = objectReference:GetRefValue("stateLockUWidget")
	local checkedUButton = objectReference:GetRefValue("checkedUButton")

	button.draggable = false

	cLock:SetActive(data.isLocked)

	if data.selectedAsExp then
		checkedUButton:SetActive(true)
	else
		checkedUButton:SetActive(false)
	end

	local strengthType = self.model:getStrengthType()

	button:TryChangePage("DragState", data.quality == strengthType and 0 or 2)

	button.draggable = false

	function button.luaClick(navConfirm)
		self:trySelectItem(data, index, navConfirm)
	end
end

function PetCarryAssistSelectComponent:trySelectItem(sData, index, navConfirm)
	if navConfirm then
		return
	end

	if not sData.selectedAsExp then
		if not sData.isLocked then
			local canAdd = self.model:canAddSelectedCarries()

			if not canAdd then
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_SELECT_MAX"))
			else
				local strengthType = self.model:getStrengthType()
				local sameType = sData.quality == strengthType

				if not sameType then
					pg.global.ui.tips:showTextTip(pg.getGameString("PET_EQUIPMENT_GEM_UPGRADE_SELECT_QUALITY_MISMATC"))
				else
					self.model:setSelected(true, sData, self.model.selectIndex)
					self:refreshSelectState(index)
					self.ctrl:setSelectItem()
				end
			end
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("UNLOCK_FIRST"), 2)
		end
	else
		self.model:setSelected(false, sData)
		self:refreshSelectState(index)
		self.ctrl:setSelectItem()
	end
end

function PetCarryAssistSelectComponent:refreshSelectState(index)
	self.listUList:RefreshElement(index)
	self.ctrl:refreshSelectCarryAssistView()
end

function PetCarryAssistSelectComponent:onPropSelectChanged(uList)
	self.oldSelectIndex = uList.selectedIndex

	local data = uList.selectedItem

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		autoHor = true,
		autoClose = true,
		checkTouchBegin = false,
		padding = 160,
		shouldAddGraphicRaycaster = false,
		hierarchyMode = 0,
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
	}, nil, function()
		self.oldSelectIndex = nil

		uList:DeselectAll()
	end)
end

function PetCarryAssistSelectComponent:onSwitchLockState(data, newState)
	local isDirty = false

	data.isLocked = newState

	if newState and data.selectedAsExp then
		self.model:setSelected(false, data)

		isDirty = true
	end

	self:onOptionSelected()
	self:reselectCarry()

	if isDirty then
		self.ctrl:refreshSelectCarryAssistView()
	end
end

function PetCarryAssistSelectComponent:onHide()
	pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	self.listUList:DeselectAll()
end

function PetCarryAssistSelectComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PetCarryAssistSelectComponent
