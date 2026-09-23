-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreatePlayer\\Component\\CreatePlayerGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local CreatePlayerGamePadComponent = Class.LightClass("CreatePlayerGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function CreatePlayerGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)
	self.navigation.AREAS = {
		AREA_TAG = 1,
		AREA_RENAME = 2
	}
	self.navigation.MODE_TAG_CHOSE = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.AREA_TAG,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.AREA_TAG
	}
	self.navigation.MODE_RENAME_CHOSE = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.AREA_RENAME,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.AREA_RENAME
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_TAG_CHOSE,
		self.navigation.MODE_RENAME_CHOSE
	}
	self.enterArea = self.navigation.AREAS.AREA_TAG
end

function CreatePlayerGamePadComponent:initView()
	return
end

function CreatePlayerGamePadComponent:setEnterArea(isTag)
	self.enterArea = isTag and self.navigation.AREAS.AREA_TAG or self.navigation.AREAS.AREA_RENAME

	self:reFocusSlotArea()
end

function CreatePlayerGamePadComponent:bind_TagArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}
	local colNum = 3

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1

		local m = math.floor((i - 1) / colNum) + 1
		local n = (i - 1) % colNum + 1

		t[m] = t[m] or {}
		t[m][n] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.keyList)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end
		}
		t[m][n].Fun3 = function(x, y)
			self.ctrl:close()
		end
		t[m][n].Fun3Name = pg.getGameString("CONSOLE_COMMON_CANCEL")
		t[m][n].Fun4 = function(x, y)
			v:OnClickSimulate()
		end
		t[m][n].Fun4Name = pg.getGameString("CONSOLE_COMMON_CHOOSE")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_TAG_CHOSE, t)
end

function CreatePlayerGamePadComponent:bind_ReNameArea()
	local t = {
		{}
	}

	t[1][1] = {
		Focus = function(x, y)
			self.view.inputField:TryChangePage("GamePadFocus", 1)
			self.view.inputField:ActivateInputField()
			self.navigation:baseFocus(t, x, y, self.view.keyList)
		end,
		DisFocus = function(x, y)
			self.view.inputField:DeactivateInputField()
			self.view.inputField:TryChangePage("GamePadFocus", 0)
		end
	}
	t[1][1].Fun4Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")

	self.navigation:initAreaTableSlots(self.navigation.MODE_RENAME_CHOSE, t)
end

function CreatePlayerGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:reFocusSlotArea()
	else
		self.navigation:clearNavigation()
	end
end

function CreatePlayerGamePadComponent:reFocusSlotArea()
	self:focusArea(self.enterArea, 1, 1)
end

function CreatePlayerGamePadComponent:focusArea(area, x, y)
	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(area, x, y)
	end, 1)
end

function CreatePlayerGamePadComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return CreatePlayerGamePadComponent
