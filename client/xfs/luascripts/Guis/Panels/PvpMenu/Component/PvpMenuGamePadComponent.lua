-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpMenu\\Component\\PvpMenuGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PvpMenuGamePadComponent = Class.LightClass("PvpMenuGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PvpMenuGamePadComponent:findObjects()
	self.root = self.view.root
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PvpMenuGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("Y", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("LSD", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RSD", self.root.gameObject))
end

function PvpMenuGamePadComponent:initAreas()
	self.navigation.AREAS = {
		MODE_3D_PET_CHOSE = 1
	}
	self.navigation.MODE_3D_PET_CHOSE = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_3D_PET_CHOSE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_3D_PET_CHOSE
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_3D_PET_CHOSE
	}
end

function PvpMenuGamePadComponent:modeChooseAreaSupplement(data, matching)
	local t = {
		{}
	}
	local keys = t[1]

	for i, v in ipairs(data) do
		keys[i] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)

				for j, c in ipairs(data) do
					if j ~= i then
						c:TryChangePage("GamePadFocus", 0)
					end
				end

				self.navigation:baseFocus(t, x, y, self.ctrl.linkModeComponent.keyList)
			end
		}

		if not matching then
			keys[i].Fun2 = function(x, y)
				v.luaClick()
			end
			keys[i].Fun2Name = pg.getGameString("PVP_ADJUST_TEAM")
			keys[i].Fun4 = function(x, y)
				v.luaClick()
			end
			keys[i].Fun4Name = pg.getGameString("PVP_CONFIRM")
		end

		keys[i].Fun3 = function(x, y)
			return
		end
		keys[i].Fun3Name = pg.getGameString("PVP_CANCEL")
	end

	self.navigation:initAreaTableSlots(self.navigation.MODE_3D_PET_CHOSE, t)
	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(self.navigation.AREAS.MODE_3D_PET_CHOSE, 1, 1)
	end, 1)

	self.btnList = data
end

function PvpMenuGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:laterFramesFocus(function()
			self.navigation:specificSet(self.navigation.AREAS.MODE_3D_PET_CHOSE, 1, 1)
		end, 1)
	elseif self.btnList ~= nil then
		for _, v in ipairs(self.btnList) do
			v:TryChangePage("GamePadFocus", 0)
		end
	end
end

function PvpMenuGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PvpMenuGamePadComponent
