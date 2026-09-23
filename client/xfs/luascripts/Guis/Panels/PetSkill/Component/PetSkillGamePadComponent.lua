-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\Component\\PetSkillGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSkillGamePadComponent = Class.LightClass("PetSkillGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PetSkillGamePadComponent:findObjects()
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetSkillGamePadComponent:initView()
	return
end

function PetSkillGamePadComponent:initAreas()
	return
end

function PetSkillGamePadComponent:onDestroy()
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetSkillGamePadComponent
