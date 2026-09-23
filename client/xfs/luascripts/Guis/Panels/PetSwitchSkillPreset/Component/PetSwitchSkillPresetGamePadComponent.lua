-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSwitchSkillPreset\\Component\\PetSwitchSkillPresetGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSwitchSkillPresetGamePadComponent = Class.LightClass("PetSwitchSkillPresetGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetSwitchSkillPresetGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetSwitchSkillPresetGamePadComponent:initView()
	return
end

function PetSwitchSkillPresetGamePadComponent:initAreas()
	return
end

function PetSwitchSkillPresetGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetSwitchSkillPresetGamePadComponent
