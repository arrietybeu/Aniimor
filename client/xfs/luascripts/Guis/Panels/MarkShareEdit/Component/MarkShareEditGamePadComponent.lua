-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareEdit\\Component\\MarkShareEditGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MarkShareEditGamePadComponent = Class.LightClass("MarkShareEditGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function MarkShareEditGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function MarkShareEditGamePadComponent:initView()
	return
end

function MarkShareEditGamePadComponent:initAreas()
	return
end

function MarkShareEditGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return MarkShareEditGamePadComponent
