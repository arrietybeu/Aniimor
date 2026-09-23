-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LeylineTree\\Component\\LeylineTreeGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LeylineTreeGamePadComponent = Class.LightClass("LeylineTreeGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function LeylineTreeGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function LeylineTreeGamePadComponent:initView()
	return
end

function LeylineTreeGamePadComponent:initAreas()
	return
end

function LeylineTreeGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return LeylineTreeGamePadComponent
