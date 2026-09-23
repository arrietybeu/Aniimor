-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityRule\\Component\\PetFertilityRuleGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFertilityRuleGamePadComponent = Class.LightClass("PetFertilityRuleGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetFertilityRuleGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetFertilityRuleGamePadComponent:initView()
	return
end

function PetFertilityRuleGamePadComponent:initAreas()
	return
end

function PetFertilityRuleGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetFertilityRuleGamePadComponent
