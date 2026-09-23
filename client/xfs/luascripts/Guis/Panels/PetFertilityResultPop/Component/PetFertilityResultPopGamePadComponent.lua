-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResultPop\\Component\\PetFertilityResultPopGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFertilityResultPopGamePadComponent = Class.LightClass("PetFertilityResultPopGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetFertilityResultPopGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetFertilityResultPopGamePadComponent:initView()
	return
end

function PetFertilityResultPopGamePadComponent:initAreas()
	return
end

function PetFertilityResultPopGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetFertilityResultPopGamePadComponent
