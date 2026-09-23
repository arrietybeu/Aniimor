-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\GamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local GamePadComponent = Class.LightClass("GamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function GamePadComponent:onCtor(info)
	self.navigation = GamePadNavigation.new(self)
end

function GamePadComponent:bindHotKeys(keys)
	if IsNil(self.gameObject) or keys == nil or #keys == 0 then
		return
	end

	for _, v in ipairs(keys) do
		if v == "LEFT_STICK" then
			self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.gameObject))
		elseif v == "RIGHT_STICK" then
			self.navigation:addConsoleEvent(self.navigation:initCommonRightStickMoveData(self.gameObject))
		else
			self.navigation:addConsoleEvent(self.navigation:initCommonKeyData(v, self.gameObject))
		end
	end
end

function GamePadComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return GamePadComponent
