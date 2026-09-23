-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\Component\\PetFertilityGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFertilityGamePadComponent = Class.LightClass("PetFertilityGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetFertilityGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetFertilityGamePadComponent:initView()
	return
end

function PetFertilityGamePadComponent:initAreas()
	return
end

function PetFertilityGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetFertilityGamePadComponent
