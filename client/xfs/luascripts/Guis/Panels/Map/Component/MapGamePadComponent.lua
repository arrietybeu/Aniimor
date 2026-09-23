-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MapGamePadComponent = Class.LightClass("MapGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function MapGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function MapGamePadComponent:initView()
	return
end

function MapGamePadComponent:initAreas()
	return
end

function MapGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return MapGamePadComponent
