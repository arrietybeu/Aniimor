-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionSwitchAbility.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local InteractionConst = require("Common.Const.InteractionConst")
local PetData = require("Data.pet_data")
local AbilityConst = require("Common.Const.AbilityConst")
local InteractData = require("Data.interact_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractionSwitchAbility = Class.LightClass("InteractionSwitchAbility", InteractionUnitBase)

function InteractionSwitchAbility:ctor(info, interactId)
	InteractionSwitchAbility.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.switchGlobalId = info.switchGlobalId
	self.abilityIndex = info.abilityIndex
end

function InteractionSwitchAbility:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	return true
end

function InteractionSwitchAbility:interactive()
	if self.interactFunc then
		self.interactFunc(self.switchGlobalId, self.abilityIndex)
	end
end

function InteractionSwitchAbility:getInteractBtnStyle()
	local pet = pg.me:getPetInfo(self.switchGlobalId)
	local petData = PetData[pet.templateId]
	local styleId

	if self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB then
		styleId = 19
	elseif self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE then
		styleId = 20
	elseif self.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM then
		styleId = 21
	end

	return {
		{
			styleId = InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID,
			iconId = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON) or "",
			actionName = styleId and InteractData[styleId].actionName or "",
			hotkeyType = InteractData[styleId].hotkeyType
		}
	}
end

return InteractionSwitchAbility
