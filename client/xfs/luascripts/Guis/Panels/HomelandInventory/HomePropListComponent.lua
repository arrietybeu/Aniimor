-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandInventory\\HomePropListComponent.lua

local ItemConst = require("Common.Const.ItemConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local HomePropListComponent = Class.LightClass("HomePropListComponent", UIComponent)
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function HomePropListComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.propList = self.objectReference:GetRefValue("propList")
	self.sortSelector = self.objectReference:GetRefValue("sortSelector")
	self.doSortBtn = self.objectReference:GetRefValue("doSortBtn")
end

function HomePropListComponent:initView()
	self.doSortBtn:TryChangePage("asc", self.model.sortIsAscending and 0 or 1)

	self.propTypeBag = 0
	self.propTypeInventory = 1

	function self.propList.luaSelectedChanged(uList)
		self:onPropSelected(uList)
	end

	function self.propList.luaFinishRender(_)
		return
	end

	function self.sortSelector.luaSelectedChanged(selector)
		self.ctrl:setSortIdxType(selector.selectedIndex, self.propType)
		self:onTabSelected()
	end

	function self.doSortBtn.luaClick()
		self.ctrl:setSortAscendingOrder(self.propType)
		self.doSortBtn:TryChangePage("asc", self.model.sortIsAscending and 0 or 1)
		self:onTabSelected()
	end
end

function HomePropListComponent:onShow(propType)
	if propType then
		self.propType = propType

		self:setGroupSelectorOptions()
	end
end

function HomePropListComponent:deselectAll()
	self.propList:DeselectAll()
end

function HomePropListComponent:onTabSelected()
	return
end

function HomePropListComponent:onRenderPropItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local uIComPropCardAnimation = objectReference:GetRefValue("uIComPropCardAnimation")

	button.enabledLongPress = false

	if data.type ~= ItemConst.ITEM_TYPE_CARRY_CORE then
		-- block empty
	else
		LuaUIUtils.checkParseCarryInfo(data)
		ClientTextUtils.setText(txtNameUText, "+", tostring(data.carryCoreAttr.lv))
	end

	self:setPropStatus(button, data)

	function button.luaEndDrag(dropWidget)
		self.ctrl:onPropEndDrag(button, dropWidget)
		button:TryChangePage("DragState", 0)

		if dropWidget then
			dropWidget:TryChangePage("DragState", 0)
		end
	end

	function button.luaBeginDrag()
		button:TryChangePage("DragState", 2)
	end

	function button.luaClick()
		return
	end

	button.draggable = data.draggable

	uIComPropCardAnimation:Play("UI_Prefab_Prop_Card_In")
end

function HomePropListComponent:onPropSelected(uList)
	local sData = uList.selectedItem

	if sData == nil then
		return
	end
end

function HomePropListComponent:setPropStatus(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local viewableWidget = objectReference:GetRefValue("viewableWidget")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
end

function HomePropListComponent:setGroupSelectorOptions()
	local groupInfos = self.model:getSortOptions()

	self.sortSelector:SetOptions(groupInfos)

	self.sortSelector.selectedIndex = self.model:getSortIdxType()
end

function HomePropListComponent:refreshPropStatusByGenId(genId)
	local allData = self.propList.itemData

	for idx, data in pairs(allData) do
		if data.index == genId then
			self.propList:RefreshElement(idx)

			break
		end
	end
end

function HomePropListComponent:refreshPropStatusByItemId(itemId)
	local allData = self.propList.itemData

	for idx, data in pairs(allData) do
		if data.itemId == itemId then
			self.model:overridePropData(data)
			self.propList:RefreshElement(idx)

			break
		end
	end
end

function HomePropListComponent:refreshGenCount(genId)
	local allData = self.propList.itemData
	local targetIdx

	for idx, data in pairs(allData) do
		if data.packSlot.genID == genId then
			targetIdx = idx

			break
		end
	end

	if targetIdx then
		self.propList:RefreshElement(targetIdx)
	end
end

function HomePropListComponent:getButtonByIndex(index)
	local _, button = self.propList:TryGetChildAt(index)

	return button
end

return HomePropListComponent
