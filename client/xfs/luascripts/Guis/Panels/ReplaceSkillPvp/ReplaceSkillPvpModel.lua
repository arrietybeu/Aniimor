-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ReplaceSkillPvp\\ReplaceSkillPvpModel.lua

local Class = require("Core.Framework.Class")
local SkillTagData = require("Data.skill_tag_data")
local ElementPropData = require("Data.element_prop_data")
local Lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local PetSkillData = require("Data.pet_skill_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ReplaceSkillPvpModel = Class.LightClass("ReplaceSkillPvpModel", UIModel)
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local ATTACK_ABILITYS = {
	AbilityConst.WEAPON_SKILL_ABILITY,
	AbilityConst.WEAPON_SKILL_ABILITY2
}

ReplaceSkillPvpModel.EMPTY_ABILITY_ID = 0

function ReplaceSkillPvpModel:setCurSelectPetTemplateId(templateId)
	self.curSelectPetTemplateId = templateId
	self.templateBaseId = TmpPetTemplateData[self.curSelectPetTemplateId].templateBaseId
end

function ReplaceSkillPvpModel:getPetUnlockSkill()
	local validAbilityMap = Utils.pvpGetValidAbilityMap(self.curSelectPetTemplateId)
	local abilities = {}

	for k, v in pairs(validAbilityMap) do
		if v == true then
			local abilityId = AbilityUtils.getAbilityIdByParamId(self.templateBaseId, k)

			if abilityId ~= 0 then
				abilities[#abilities + 1] = abilityId
			end
		end
	end

	local ret = {}

	for idx, unlockInfo in pairs(abilities) do
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(unlockInfo)
		local abilityInfo = self:getAbilityInfo(abilityParamData)

		abilityInfo.abilityId = unlockInfo

		local elementList = {}

		elementList[#elementList + 1] = {
			elementName = ElementPropData[abilityParamData.elementType],
			elementTypeId = abilityParamData.elementType
		}
		abilityInfo.elementList = elementList
		abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityId(unlockInfo, self.curSelectPetTemplateId))

		local paramId = AbilityUtils.getAbilityParamId(unlockInfo)
		local petPrototypeId = Utils.getPetPetPrototypeId(self.curSelectPetTemplateId)

		abilityInfo.order = PetSkillData[petPrototypeId][paramId].skillOrder or 999
		ret[#ret + 1] = abilityInfo
	end

	table.sort(ret, function(a, b)
		return a.order < b.order
	end)

	return ret
end

function ReplaceSkillPvpModel:checkEquippedSkill(abilityId)
	local pvpPetSet = pg.global.ui.pvpPetSet
	local serverData = pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData
	local curAbilityMap = serverData.abilityPresetMap[self.curShowPlanIdx]

	for idx, abilityType in pairs(ATTACK_ABILITYS) do
		if abilityId == curAbilityMap[abilityType] then
			return true
		end
	end

	return false
end

function ReplaceSkillPvpModel:getCurrentSkillByGroup(idx)
	local preSetInfo = self:getPetsAbilityPlanInfo(idx)
	local ret = {}

	for _, abilityType in pairs(ATTACK_ABILITYS) do
		local abilityId = preSetInfo[abilityType]
		local abilityInfo = {}

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
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityId(abilityId, self.curSelectPetTemplateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		else
			abilityInfo.tIndex = 1
			abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityId(abilityId, self.curSelectPetTemplateId))
			abilityInfo.abilityType = abilityType
			ret[#ret + 1] = abilityInfo
		end
	end

	return ret
end

function ReplaceSkillPvpModel:getAbilityInfo(abilityParamData)
	local abilityInfo = Lume.clone(abilityParamData)
	local numberList = {}

	if abilityInfo.power then
		numberList[#numberList + 1] = {
			number = abilityInfo.power,
			style = self.SKILL_DAMAGE_IDX
		}
	end

	if abilityInfo.epCost then
		numberList[#numberList + 1] = {
			number = abilityInfo.epCost,
			style = self.SKILL_ENERGY_IDX
		}
	end

	abilityInfo.numberList = numberList

	local tagList = {}

	if abilityInfo.tags then
		for idx, tagId in pairs(abilityInfo.tags) do
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

function ReplaceSkillPvpModel:tryModifyAbility(skillIdx, newAbilityId, oriIdx, newAbilityId1)
	local pvpPetSet = pg.global.ui.pvpPetSet
	local serverData = pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData

	if (skillIdx == 1 or skillIdx == 2) and (oriIdx == 1 or oriIdx == 2) then
		serverData.abilityPresetMap[self.curShowPlanIdx][oriIdx] = newAbilityId1
		serverData.abilityPresetMap[self.curShowPlanIdx][skillIdx] = newAbilityId

		pvpPetSet:sendSavePetInfoMsg(self.curSelectPetTemplateId, 2)

		return
	end

	if skillIdx == nil then
		serverData.abilityPresetMap[self.curShowPlanIdx][oriIdx] = newAbilityId1
	else
		serverData.abilityPresetMap[self.curShowPlanIdx][skillIdx] = newAbilityId
	end

	pvpPetSet:sendSavePetInfoMsg(self.curSelectPetTemplateId, 2)
end

function ReplaceSkillPvpModel:getPetsAbilityPlanInfo(presetIdx)
	local pvpPetSet = pg.global.ui.pvpPetSet
	local serverData = pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData
	local curAbilityMap = serverData.abilityPresetMap[presetIdx]

	return curAbilityMap
end

function ReplaceSkillPvpModel:setCurShowPlanIdx(idx)
	self.curShowPlanIdx = idx

	local pvpPetSet = pg.global.ui.pvpPetSet

	pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData.curAbilityPreset = self.curShowPlanIdx

	pvpPetSet:sendSavePetInfoMsg(self.curSelectPetTemplateId, 2)
end

function ReplaceSkillPvpModel:getCurFightIdx()
	local pvpPetSet = pg.global.ui.pvpPetSet
	local serverData = pvpPetSet.model.petsMap[self.curSelectPetTemplateId].serverData

	return serverData.curAbilityPreset
end

return ReplaceSkillPvpModel
