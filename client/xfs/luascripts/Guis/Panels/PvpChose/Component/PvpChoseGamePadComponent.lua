-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\Component\\PvpChoseGamePadComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local PvpChoseGamePadComponent = Class.LightClass("PvpChoseGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PvpChoseGamePadComponent:findObjects()
	self.root = self.view.component
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PvpChoseGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("X", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
end

function PvpChoseGamePadComponent:initAreas()
	self.navigation.AREAS = {
		MODE_PET_CHOSE = 1
	}
	self.navigation.MODE_PET_CHOSE = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_PET_CHOSE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_PET_CHOSE
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_PET_CHOSE
	}
end

function PvpChoseGamePadComponent:modeChooseAreaSupplement(data)
	local t = {}

	for i, v in ipairs(data) do
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				v:TryChangePage("button", 3)

				for _, c in ipairs(data) do
					if c ~= v then
						c:TryChangePage("button", 0)
					end
				end

				self.navigation:baseFocus(t, x, y, self.view.keyList)
			end
		}
		t[i][1].Fun4 = function(x, y)
			v.luaClick()
		end
		t[i][1].Fun4Name = pg.getGameString("PVP_CONFIRM")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_PET_CHOSE, t)
	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(self.navigation.AREAS.MODE_PET_CHOSE, 1, 1)
	end, 1)

	self.btnList = data
end

function PvpChoseGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:laterFramesFocus(function()
			self.navigation:specificSet(self.navigation.AREAS.MODE_PET_CHOSE, 1, 1)
		end, 1)
	elseif self.btnList ~= nil then
		for _, v in ipairs(self.btnList) do
			v:TryChangePage("button", 0)
		end
	end
end

function PvpChoseGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PvpChoseGamePadComponent
