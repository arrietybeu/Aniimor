-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Nourish\\Component\\NourishGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NourishGamePadComponent = Class.LightClass("NourishGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function NourishGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function NourishGamePadComponent:initView()
	return
end

function NourishGamePadComponent:initAreas()
	return
end

function NourishGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return NourishGamePadComponent
