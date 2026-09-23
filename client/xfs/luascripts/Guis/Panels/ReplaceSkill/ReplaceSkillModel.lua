-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ReplaceSkill\\ReplaceSkillModel.lua

local Class = require("Core.Framework.Class")
local SkillTagData = require("Data.skill_tag_data")
local ElementPropData = require("Data.element_prop_data")
local Lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local PetData = require("Data.pet_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityConst = require("Common.Const.AbilityConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ReplaceSkillModel = Class.LightClass("ReplaceSkillModel", UIModel)
local ATTACK_ABILITYS = {
	AbilityConst.WEAPON_SKILL_ABILITY,
	AbilityConst.WEAPON_SKILL_ABILITY2
}

ReplaceSkillModel.EMPTY_ABILITY_ID = 0

function ReplaceSkillModel:setCurSelectPetId(curSelectPetId)
	self.curSelectPetId = curSelectPetId
	self.pet = pg.me:getPetInfo(self.curSelectPetId)
	self.petPrototypeId = PetData[self.pet.templateId].petPrototypeId
end

function ReplaceSkillModel:getPetUnlockSkill()
	local unlockedAbilityMap = self.pet.unlockedAbilityMap
	local ret = {}

	for paramId, _ in pairs(unlockedAbilityMap) do
		local abilityId = AbilityUtils.getAbilityIdByParamId(self.pet.templateId, paramId)
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
		local abilityInfo = self:getAbilityInfo(abilityParamData)

		abilityInfo.abilityId = abilityId

		local elementList = {}

		elementList[#elementList + 1] = {
			elementName = ElementPropData[abilityParamData.elementType],
			elementTypeId = abilityParamData.elementType
		}
		abilityInfo.elementList = elementList
		abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, self.pet.templateId))

		local petPrototypeId = self.pet.petPrototypeId

		abilityInfo.order = PetSkillData[petPrototypeId][paramId].skillOrder or 999
		ret[#ret + 1] = abilityInfo
	end

	table.sort(ret, function(a, b)
		return a.order < b.order
	end)

	return ret
end

function ReplaceSkillModel:checkEquippedSkill(abilityId)
	local petInfo = pg.me:getPetInfo(self.curSelectPetId)

	if not petInfo or not petInfo.curAbilityMap then
		return false
	end

	for _, abilityType in pairs(ATTACK_ABILITYS) do
		local abilityInfo = petInfo.curAbilityMap[abilityType]

		if abilityInfo and abilityId == abilityInfo.abilityId then
			return true
		end
	end

	return false
end

function ReplaceSkillModel:getCurrentSkillByGroup(idx)
	local preSetInfo = self:getPetsAbilityPlanInfo(idx)
	local ret = {}

	for _, abilityType in pairs(ATTACK_ABILITYS) do
		local abilityId = preSetInfo[abilityType]
		local abilityInfo = {}
		local paramId = AbilityUtils.getAbilityParamId(abilityId)

		abilityInfo.abilityId = self.EMPTY_ABILITY_ID

		if abilityId and abilityId ~= self.EMPTY_ABILITY_ID then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

			abilityInfo = self:getAbilityInfo(abilityParamData, abilityType)
			abilityInfo.abilityId = abilityId

			local elementList = {}

			elementList[#elementList + 1] = {
				elementName = ElementPropData[abilityParamData.elementType],
				elementTypeId = abilityParamData.elementType
			}
			abilityInfo.elementList = elementList
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, self.pet.templateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		else
			abilityInfo.tIndex = 1
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, self.pet.templateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		end
	end

	return ret
end

function ReplaceSkillModel:getAbilityInfo(abilityParamData)
	local abilityInfo = Lume.clone(abilityParamData)
	local numberList = {}

	numberList[#numberList + 1] = {
		number = abilityInfo.power or 0,
		style = self.SKILL_DAMAGE_IDX
	}
	numberList[#numberList + 1] = {
		number = abilityInfo.epCost or 0,
		style = self.SKILL_ENERGY_IDX
	}
	abilityInfo.numberList = numberList

	local tagList = {}

	if abilityInfo.tags then
		for _, tagId in pairs(abilityInfo.tags) do
			tagList[#tagList + 1] = {
				tagName = SkillTagData[tagId].tagName,
				tagId = tagId
			}
		end
	end

	abilityInfo.tagList = tagList
	abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[AbilityConst.WEAPON_SKILL_ABILITY])

	return abilityInfo
end

function ReplaceSkillModel:tryModifyAbility(skillIdx, newAbilityId)
	pg.me:serverMsg("RPC_CS_PetModifyAbilityPreset", self.curSelectPetId, self.curShowPlanIdx, tonumber(skillIdx), tonumber(newAbilityId))
end

function ReplaceSkillModel:getPetsAbilityPlanInfo(presetIdx)
	local petInfo = pg.me:getPetInfo(self.curSelectPetId)

	if not petInfo or not petInfo.curAbilityMap then
		return {}
	end

	local abilityPlanInfo = {
		name = ""
	}

	for _, abilityType in pairs(ATTACK_ABILITYS) do
		local abilityInfo = petInfo.curAbilityMap[abilityType]

		abilityPlanInfo[abilityType] = abilityInfo and abilityInfo.abilityId or self.EMPTY_ABILITY_ID
	end

	return abilityPlanInfo
end

function ReplaceSkillModel:setCurShowPlanIdx(idx)
	self.curShowPlanIdx = 1
end

function ReplaceSkillModel:getCurFightIdx()
	return 1
end

function ReplaceSkillModel:tryRenameAbilityGroup(newName)
	return false
end

return ReplaceSkillModel
