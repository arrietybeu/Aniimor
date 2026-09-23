-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSwitchSkillPreset\\PetSwitchSkillPresetModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local SkillTagData = require("Data.skill_tag_data")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetSwitchSkillPresetModel = Class.LightClass("PetSwitchSkillPresetModel", UIModel)
local ATTACK_ABILITYS = {
	AbilityConst.WEAPON_SKILL_ABILITY,
	AbilityConst.WEAPON_SKILL_ABILITY2
}

PetSwitchSkillPresetModel.EMPTY_ABILITY_ID = 0

function PetSwitchSkillPresetModel:getPresetName(petId, index)
	if self.IS_PVP_FAIL_MODE ~= nil then
		if self.IS_PVP_FAIL_MODE then
			return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), index)
		else
			local pvpPetSet = pg.global.ui.pvpPetSet
			local serverData = pvpPetSet.model.petsMap[petId].serverData
			local presetName = serverData.abilityPresetMap[index].name

			if presetName and presetName ~= "" then
				return presetName
			else
				return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), index)
			end
		end
	else
		local petInfo = pg.me:getPetInfo(petId)

		if not petInfo or not petInfo.abilityPresetMap then
			return
		end

		local presetName = petInfo.abilityPresetMap[index].name

		if presetName and presetName ~= "" then
			return presetName
		else
			return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), index)
		end
	end
end

function PetSwitchSkillPresetModel:getAllPresetSkills(petId)
	local ret = {}

	for i = 1, Const.PET_ABILITY_PRESET_COUNT do
		ret[#ret + 1] = self:getPresetSkillByGroup(petId, i)
	end

	return ret
end

function PetSwitchSkillPresetModel:getPresetSkillByGroup(petId, idx)
	local preSetInfo, petInfo

	if self.IS_PVP_FAIL_MODE ~= nil then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[petId].serverData

		petInfo = serverData.templateId
		preSetInfo = petInfo.abilityPresetMap[idx]
	else
		petInfo = pg.me:getPetInfo(petId)

		if not petInfo or not petInfo.abilityPresetMap then
			return {}
		end

		preSetInfo = petInfo.abilityPresetMap[idx]
	end

	local ret = {}

	for _, abilityType in pairs(ATTACK_ABILITYS) do
		local abilityId = preSetInfo[abilityType]
		local abilityInfo = {}
		local paramId = AbilityUtils.getAbilityParamId(abilityId)

		abilityInfo.abilityId = self.EMPTY_ABILITY_ID

		if abilityId and abilityId ~= self.EMPTY_ABILITY_ID then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

			abilityInfo = self:getAbilityInfo(abilityParamData, abilityId, abilityType)
			abilityInfo.abilityId = abilityId

			local elementList = {}

			elementList[#elementList + 1] = {
				elementName = ElementPropData[abilityParamData.elementType],
				elementTypeId = abilityParamData.elementType
			}
			abilityInfo.elementList = elementList
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, petInfo.templateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		else
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, petInfo.templateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		end
	end

	return ret
end

function PetSwitchSkillPresetModel:getAbilityInfo(abilityParamData, abilityId, abilityType)
	local abilityInfo = Lume.clone(abilityParamData)

	abilityInfo.abilityId = abilityId
	abilityInfo.abilityType = abilityType

	local numberList = {}

	numberList[#numberList + 1] = {
		number = abilityInfo.epCost or 0
	}
	numberList[#numberList + 1] = {
		number = abilityInfo.power or 0
	}
	abilityInfo.numberList = numberList

	local tagList = {}

	if abilityInfo.tags then
		for _, tagId in pairs(abilityInfo.tags) do
			tagList[#tagList + 1] = {
				tagName = SkillTagData[tagId].tagName
			}
		end
	end

	abilityInfo.tagList = tagList

	if #tagList > 0 then
		local tagShowList = {
			{
				tagName = tagList[1].tagName
			}
		}

		abilityInfo.tagShowList = tagShowList
	end

	abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[abilityType])

	return abilityInfo
end

return PetSwitchSkillPresetModel
