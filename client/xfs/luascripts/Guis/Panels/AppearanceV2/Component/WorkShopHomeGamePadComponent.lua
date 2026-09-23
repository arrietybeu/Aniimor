-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\WorkShopHomeGamePadComponent.lua

local Class = require("Core.Framework.Class")
local GamePadComponent = require("Guis.Helper.GamePadComponent")
local WorkShopHomeGamePadComponent = Class.LightClass("WorkShopHomeGamePadComponent", GamePadComponent)

function WorkShopHomeGamePadComponent:findObjects()
	self:bindHotKeys({
		"X",
		"A",
		"B"
	})
end

function WorkShopHomeGamePadComponent:initView()
	self.navigation.AREAS = {
		MENU = 1
	}
	self.navigation.MODE_SWITCH = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MENU,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MENU
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_SWITCH
	}
end

function WorkShopHomeGamePadComponent:bind_funcList(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {
		{}
	}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		t[1][i] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end
		}
		t[1][i].Fun3 = function(x, y)
			self.ctrl:close()
		end
		t[1][i].Fun3Name = pg.getGameString("CONSOLE_COMMON_CANCEL")
		t[1][i].Fun4 = function(x, y)
			v:OnClickSimulate()
		end
		t[1][i].Fun4Name = pg.getGameString("CONSOLE_COMMON_CHOOSE")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_SWITCH, t)
end

function WorkShopHomeGamePadComponent:onDestroy()
	GamePadComponent.onDestroy(self)
end

return WorkShopHomeGamePadComponent
