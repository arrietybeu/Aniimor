-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityHatchResult\\Component\\PetFertilityHatchResultGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFertilityHatchResultGamePadComponent = Class.LightClass("PetFertilityHatchResultGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetFertilityHatchResultGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetFertilityHatchResultGamePadComponent:initView()
	return
end

function PetFertilityHatchResultGamePadComponent:initAreas()
	return
end

function PetFertilityHatchResultGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetFertilityHatchResultGamePadComponent
