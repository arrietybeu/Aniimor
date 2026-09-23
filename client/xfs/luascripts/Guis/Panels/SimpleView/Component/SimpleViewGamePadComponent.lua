-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SimpleView\\Component\\SimpleViewGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SimpleViewGamePadComponent = Class.LightClass("SimpleViewGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function SimpleViewGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function SimpleViewGamePadComponent:initView()
	return
end

function SimpleViewGamePadComponent:initAreas()
	return
end

function SimpleViewGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return SimpleViewGamePadComponent
