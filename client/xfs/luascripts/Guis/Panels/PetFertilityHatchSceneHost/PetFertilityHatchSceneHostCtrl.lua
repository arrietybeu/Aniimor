-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityHatchSceneHost\\PetFertilityHatchSceneHostCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetFertilityHatchSceneHostCtrl = Class.LightClass("PetFertilityHatchSceneHostCtrl", UICtrl)

function PetFertilityHatchSceneHostCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetFertilityHatchSceneHostCtrl:setViewVisible(visible)
	if self.view then
		self.view:setViewVisible(false)
	end
end

function PetFertilityHatchSceneHostCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return PetFertilityHatchSceneHostCtrl
