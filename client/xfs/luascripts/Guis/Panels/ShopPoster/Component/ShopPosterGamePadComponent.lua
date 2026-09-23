-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopPoster\\Component\\ShopPosterGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ShopPosterGamePadComponent = Class.LightClass("ShopPosterGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function ShopPosterGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function ShopPosterGamePadComponent:initView()
	return
end

function ShopPosterGamePadComponent:initAreas()
	return
end

function ShopPosterGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return ShopPosterGamePadComponent
