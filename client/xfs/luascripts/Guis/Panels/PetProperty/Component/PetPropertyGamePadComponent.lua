-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetProperty\\Component\\PetPropertyGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetPropertyGamePadComponent = Class.LightClass("PetPropertyGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetPropertyGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetPropertyGamePadComponent:initView()
	return
end

function PetPropertyGamePadComponent:initAreas()
	return
end

function PetPropertyGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetPropertyGamePadComponent
