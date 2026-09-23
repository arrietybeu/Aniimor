-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopDesign\\Component\\WorkShopDesignGamePadComponent.lua

local Class = require("Core.Framework.Class")
local GamePadComponent = require("Guis.Helper.GamePadComponent")
local WorkShopDesignGamePadComponent = Class.LightClass("WorkShopDesignGamePadComponent", GamePadComponent)

function WorkShopDesignGamePadComponent:findObjects()
	self:bindHotKeys({
		"X",
		"A",
		"B"
	})
end

function WorkShopDesignGamePadComponent:initView()
	self.navigation.AREAS = {
		SUB_ITEM = 2,
		TAB = 1
	}
	self.navigation.MODE_TAB = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SUB_ITEM,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SUB_ITEM
	}
	self.navigation.SUB_ITEM = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.TAB,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.TAB
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_TAB,
		self.navigation.SUB_ITEM
	}
end

function WorkShopDesignGamePadComponent:bind_TabList(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end
		}
		t[i][1].Fun3 = function(x, y)
			self.ctrl:close()
		end
		t[i][1].Fun3Name = pg.getGameString("CONSOLE_COMMON_CANCEL")
		t[i][1].Fun4 = function(x, y)
			v:OnClickSimulate()
		end
		t[i][1].Fun4Name = pg.getGameString("CONSOLE_COMMON_CHOOSE")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_TAB, t)
end

function WorkShopDesignGamePadComponent:onDestroy()
	GamePadComponent.onDestroy(self)
end

return WorkShopDesignGamePadComponent
