-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareView\\Component\\MarkShareViewGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MarkShareViewGamePadComponent = Class.LightClass("MarkShareViewGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function MarkShareViewGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function MarkShareViewGamePadComponent:initView()
	return
end

function MarkShareViewGamePadComponent:initAreas()
	return
end

function MarkShareViewGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return MarkShareViewGamePadComponent
