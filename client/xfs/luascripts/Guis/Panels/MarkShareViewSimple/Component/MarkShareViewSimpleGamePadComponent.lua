-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareViewSimple\\Component\\MarkShareViewSimpleGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MarkShareViewSimpleGamePadComponent = Class.LightClass("MarkShareViewSimpleGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function MarkShareViewSimpleGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function MarkShareViewSimpleGamePadComponent:initView()
	return
end

function MarkShareViewSimpleGamePadComponent:initAreas()
	return
end

function MarkShareViewSimpleGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return MarkShareViewSimpleGamePadComponent
