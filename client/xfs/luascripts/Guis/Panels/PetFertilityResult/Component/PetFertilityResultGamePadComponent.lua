-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResult\\Component\\PetFertilityResultGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFertilityResultGamePadComponent = Class.LightClass("PetFertilityResultGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetFertilityResultGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetFertilityResultGamePadComponent:initView()
	return
end

function PetFertilityResultGamePadComponent:initAreas()
	return
end

function PetFertilityResultGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetFertilityResultGamePadComponent
