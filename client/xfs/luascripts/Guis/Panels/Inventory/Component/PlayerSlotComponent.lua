-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\PlayerSlotComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PlayerSlotComponent = Class.LightClass("PlayerSlotComponent", UIComponent)
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

function PlayerSlotComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")

	function self.listUList.luaRenderItem(button, idx, data)
		self:setUpPropSlot(button, idx, data, ItemConst.QUICK_SLOT_ITEM)
	end

	function self.listUList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		local sData = uList.selectedItem

		self.ctrl:showPropDetails(sData, true)

		self.catchSelect = uList.selectedIndex
	end
end

function PlayerSlotComponent:onSelected()
	self:refreshPropList()
end

function PlayerSlotComponent:refreshPropList()
	local slotProps = self.model:getQuickSlotItemInfos(ItemConst.QUICK_SLOT_ITEM)

	self.listUList:SetList(slotProps)

	if self.catchSelect ~= nil then
		self.listUList:SelectItem(self.catchSelect)
	end
end

function PlayerSlotComponent:setUpPropSlot(button, idx, data, propType)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")

	button.dragMode = 0
	button.gameObject.name = idx + 1

	function button.luaHover()
		if not button.isAnyInstanceInDragging then
			return
		end

		button:TryChangePage("DragState", 4)
	end

	function button.luaUnhover()
		if not button.isAnyInstanceInDragging then
			return
		end

		button:TryChangePage("DragState", 0)
	end

	if data.itemId == 0 then
		LuaUIUtils.setPropCard(button, idx, data, UIConst.INVENTORY_CARD.CARD_EMPTY_IDX)

		button.draggable = false

		btnDelUButton.gameObject:SetActiveEx(false)
	else
		LuaUIUtils.setPropCard(button, idx, data, UIConst.INVENTORY_CARD.CARD_SLOT_IDX)

		local txtNameUText = objectReference:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, ClientUtils.getItemCountById(data.itemId, true))

		button.draggable = true

		function button.luaEndDrag(dropWidget)
			local fromIdx = tonumber(button.name)

			if dropWidget then
				local pointerIdx = tonumber(dropWidget.name)

				if fromIdx ~= pointerIdx then
					self.model:tryModifyGroup(fromIdx, pointerIdx, propType)
				end
			else
				self.model:tryModifyGroup(fromIdx, nil, propType)
			end

			button:TryChangePage("DragState", 0)

			if dropWidget then
				dropWidget:TryChangePage("DragState", 0)
			end
		end
	end

	btnDelUButton.gameObject:SetActiveEx(true)

	function btnDelUButton.luaClick()
		self.model:tryModifyGroup(tonumber(button.name), nil, propType)
	end
end

return PlayerSlotComponent
