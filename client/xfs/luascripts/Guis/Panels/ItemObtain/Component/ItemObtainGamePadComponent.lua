-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemObtain\\Component\\ItemObtainGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ItemObtainGamePadComponent = Class.LightClass("ItemObtainGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local UIConst = require("Const.UIConst")

function ItemObtainGamePadComponent:findObjects()
	self.root = self.view.root
	self.itemList = self.view.itemList
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function ItemObtainGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.root.gameObject))
end

function ItemObtainGamePadComponent:initAreas()
	self.navigation.AREAS = {
		ITEM_LIST_AREA = 1
	}
	self.navigation.ITEM_LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.ITEM_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.ITEM_LIST_AREA
	}
	self.navigation.AREA_TABLES = {
		self.navigation.ITEM_LIST_AREA
	}
end

function ItemObtainGamePadComponent:initItemListArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {
		{}
	}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		t[1][i + 1] = {
			Focus = function(x, y)
				if pg.global.ui:checkUIVisible(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
				end

				v:TryChangePage("GamePadFocus", 1)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end
		}
		t[1][i + 1].Fun6Name = ""
		t[1][i + 1].Fun6 = function(x1, y1)
			if pg.global.ui:checkUIVisible(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			else
				v:OnClickSimulate()
			end
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.ITEM_LIST_AREA, t)
end

function ItemObtainGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.ITEM_LIST_AREA, 1, 1)
		self.navigation:reFocus()
	else
		self.navigation:clearNavigation()
	end
end

function ItemObtainGamePadComponent:onDestroy()
	self.root = nil
	self.itemList = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return ItemObtainGamePadComponent
