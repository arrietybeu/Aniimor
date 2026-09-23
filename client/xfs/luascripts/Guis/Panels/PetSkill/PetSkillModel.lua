-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\PetSkillModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetSkillModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Lume = require("Core.Common.lume")
local PetData = require("Data.pet_data")
local SkillTagData = require("Data.skill_tag_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetCharacterData = require("Data.pet_character_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local ActorUtils = require("Common.Utils.ActorUtils")
local Utils = require("Common.Utils.Utils")
local AbilityParamData = require("Data.ability_param_data")
local ClientConst = require("Const.ClientConst")
local PetSkillModel = Class.LightClass("PetSkillModel", UIModel)

PetSkillModel.EMPTY_ABILITY_ID = 0

function PetSkillModel:getPetNameAndInfo(petId)
	if self.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local petInfo = pvpPetSet.model.petsMap[petId]
		local configData = petInfo.configData

		return configData.name, petInfo
	else
		local pet = pg.me:getPetInfo(petId)

		if pet.customName and pet.customName ~= "" then
			return pet.customName, pet
		end

		local pData = PetData[pet.templateId] or {}
		local name = pData.name

		return pg.getLocalizationText(name), pet
	end
end

function PetSkillModel:getCurCharacter(petId)
	local controlFeatureId

	if self.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[petId].serverData

		controlFeatureId = serverData.curCharacter
	else
		local pet = pg.me:getPetInfo(petId)

		controlFeatureId = pet.characterInfo.curCharacter
	end

	local featureInfo = PetCharacterData[controlFeatureId]

	if featureInfo then
		return featureInfo
	end
end

function PetSkillModel:getPetSkillInfos(petId, type)
	local abilityType, ability

	if type == AbilityConst.EXPLORE_ABILITY then
		if self.IS_PVP_FAIL_MODE ~= nil then
			return nil
		end

		abilityType = AbilityConst.EXPLORE_ABILITY

		local curAbilityMap = pg.me:getPetInfo(petId).exploreAbilityList:getRawTable()

		if next(curAbilityMap) then
			ability = {
				abilityId = curAbilityMap[next(curAbilityMap)]
			}
		end
	else
		abilityType = type

		if self.IS_PVP_FAIL_MODE then
			local tpdd = TmpPetTemplateData[petId]
			local curAbilityMap = ActorUtils.genPvpAbility(tpdd.templateBaseId) or {}
			local abilities = {}

			for k, v in pairs(curAbilityMap) do
				abilities[k] = AbilityUtils.getAbilityIdByParamId(tpdd.templateBaseId, v)
			end

			local pvpPetSet = pg.global.ui.pvpPetSet
			local serverData = pvpPetSet.model.petsMap[petId].serverData
			local skill1 = serverData.abilityPresetMap[serverData.curAbilityPreset][AbilityConst.WEAPON_SKILL_ABILITY]
			local skill2 = serverData.abilityPresetMap[serverData.curAbilityPreset][AbilityConst.WEAPON_SKILL_ABILITY2]

			abilities[AbilityConst.WEAPON_SKILL_ABILITY] = skill1 ~= 0 and skill1 or abilities[AbilityConst.WEAPON_SKILL_ABILITY]
			abilities[AbilityConst.WEAPON_SKILL_ABILITY2] = skill2 ~= 0 and skill2 or abilities[AbilityConst.WEAPON_SKILL_ABILITY2]
			ability = abilities[abilityType]
		else
			local curAbilityMap = pg.me:getPetInfo(petId).curAbilityMap

			ability = curAbilityMap[abilityType]
		end
	end

	if ability then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(self.IS_PVP_FAIL_MODE and ability or ability.abilityId)
		local abilityInfo = Lume.clone(abilityParamData)

		abilityInfo.abilityId = self.IS_PVP_FAIL_MODE and ability or ability.abilityId
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

	return nil
end

function PetSkillModel:getPetAllUnlockedSkill(petId)
	local unlockedAbilityMap, petPrototypeId, petInfo

	if self.IS_PVP_FAIL_MODE then
		local validAbilityMap = Utils.pvpGetValidAbilityMap(petId)

		unlockedAbilityMap = {}

		for k, v in pairs(validAbilityMap) do
			if v == true then
				local abilityId = AbilityUtils.getAbilityIdByParamId(TmpPetTemplateData[petId].templateBaseId, k)

				if abilityId ~= PetSkillModel.EMPTY_ABILITY_ID then
					unlockedAbilityMap[#unlockedAbilityMap + 1] = abilityId
				end
			end
		end

		petPrototypeId = Utils.getPetPetPrototypeId(TmpPetTemplateData[petId].templateBaseId)
	else
		petInfo = pg.me:getPetInfo(petId)
		unlockedAbilityMap = petInfo.unlockedAbilityMap
		petPrototypeId = petInfo.petPrototypeId
	end

	local ret = {}

	if self.IS_PVP_FAIL_MODE then
		for _, unlockInfo in pairs(unlockedAbilityMap) do
			self:setupAbilityInfo(ret, unlockInfo, petPrototypeId, {
				unLock = true,
				alreadyLearnt = true
			})
		end
	else
		local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(petPrototypeId)]
		local playerHandBookMap = pg.me.petHandbookMap
		local hb = playerHandBookMap[petPrototypeId]

		for k, _ in pairs(skData) do
			local abParm = AbilityParamData[k] or {}

			if abParm == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("skill param [id:%d] is not exist", k)
			end

			local tp = skData[k] and skData[k].abilityType

			if abParm and tp == "skill" then
				local abilityId = AbilityUtils.getAbilityIdByParamId(petPrototypeId, k)

				if abilityId == 0 and LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("skill param [id:%d] is not valid", k)
				end

				local unLock = Utils.isPetSkillUnlock(pg.me, petPrototypeId, k)
				local alreadyLearnt = unlockedAbilityMap[k] ~= nil

				self:setupAbilityInfo(ret, abilityId, petPrototypeId, {
					unLock = unLock,
					alreadyLearnt = alreadyLearnt
				})
			end
		end
	end

	table.sort(ret, function(a, b)
		return a.order < b.order
	end)

	local derivation = self:skillDerivation(ret)
	local newT = {}

	for _, v in pairs(derivation) do
		newT[#newT + 1] = v
	end

	if #newT < 7 then
		for i = #newT + 1, 7 do
			newT[i] = {}
		end
	end

	return newT
end

function PetSkillModel:isAbilityIdLearnt(petId, abilityId)
	local unlockedAbilityMap

	if self.IS_PVP_FAIL_MODE then
		unlockedAbilityMap = {}

		local validAbilityMap = Utils.pvpGetValidAbilityMap(petId)

		for k, v in pairs(validAbilityMap) do
			if v == true then
				local abilityId1 = AbilityUtils.getAbilityIdByParamId(TmpPetTemplateData[petId].templateBaseId, k)

				if abilityId1 ~= PetSkillModel.EMPTY_ABILITY_ID then
					unlockedAbilityMap[#unlockedAbilityMap + 1] = abilityId1
				end
			end
		end
	else
		local petInfo = pg.me:getPetInfo(petId)

		unlockedAbilityMap = petInfo.unlockedAbilityMap
	end

	local paramId = AbilityUtils.getAbilityParamId(abilityId)
	local alreadyLearnt = unlockedAbilityMap[paramId] ~= nil

	return alreadyLearnt
end

function PetSkillModel:setupAbilityInfo(ret, abilityId, petPrototypeId, extraParam)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local abilityInfo = Lume.clone(abilityParamData)
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

	abilityInfo.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[AbilityConst.WEAPON_SKILL_ABILITY])
	abilityInfo.abilityId = abilityId

	local elementList = {}

	elementList[#elementList + 1] = {
		elementName = ElementPropData[abilityParamData.elementType],
		elementTypeId = abilityParamData.elementType
	}
	abilityInfo.elementList = elementList

	local paramId = AbilityUtils.getAbilityParamId(abilityId)

	abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId))

	local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(petPrototypeId)]

	abilityInfo.order = skData[paramId].skillOrder or 999
	abilityInfo.derive = skData[paramId].derive

	if extraParam then
		abilityInfo.unLock = extraParam.unLock
		abilityInfo.alreadyLearnt = extraParam.alreadyLearnt
	end

	ret[#ret + 1] = abilityInfo
end

function PetSkillModel:skillDerivation(ret)
	local result = {}

	for _, v in pairs(ret) do
		if not v.derive then
			local key = AbilityUtils.getAbilityParamId(v.abilityId)

			if not result[key] then
				result[key] = {}
			end

			result[key][1] = v
		else
			if not result[v.derive] then
				result[v.derive] = {}
			end

			if #result[v.derive] <= 0 then
				result[v.derive][2] = v
			else
				result[v.derive][#result[v.derive] + 1] = v
			end
		end
	end

	return result
end

function PetSkillModel:isSkillEquipment(petId, abilityId)
	local curAbilityMap

	if self.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[petId].serverData

		curAbilityMap = serverData.abilityPresetMap[serverData.curAbilityPreset]

		for _, v in pairs(curAbilityMap) do
			if v == abilityId then
				return true
			end
		end

		return false
	else
		curAbilityMap = pg.me:getPetInfo(petId).curAbilityMap

		for _, v in pairs(curAbilityMap) do
			if v.abilityId == abilityId then
				return true
			end
		end

		return false
	end
end

function PetSkillModel:getSkillLearnData(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local petPrototypeId = petInfo.petPrototypeId
	local unlockedAbilityMap = petInfo.unlockedAbilityMap
	local ret = {}
	local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(petPrototypeId)]
	local playerHandBookMap = pg.me.petHandbookMap
	local hb = playerHandBookMap[petPrototypeId]

	for k, v in pairs(skData) do
		local abParm = AbilityParamData[k] or {}

		if abParm == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("skill param [id:%d] is not exist", k)
		end

		local tp = v.abilityType

		if abParm and tp == "skill" then
			local item = Lume.clone(abParm)
			local numberList = {}

			numberList[#numberList + 1] = {
				number = item.epCost or 0
			}
			numberList[#numberList + 1] = {
				number = item.power or 0
			}
			item.numberList = numberList

			local tagList = {}

			if item.tags then
				for _, tagId in pairs(item.tags) do
					tagList[#tagList + 1] = {
						tagName = SkillTagData[tagId].tagName
					}
				end
			end

			item.tagList = tagList

			if #tagList > 0 then
				local tagShowList = {
					{
						tagName = tagList[1].tagName
					}
				}

				item.tagShowList = tagShowList
			end

			item.typeName = pg.getGameString(AbilityConst.ABILITY_TYPE_NAME[AbilityConst.WEAPON_SKILL_ABILITY])

			local elementList = {}

			elementList[#elementList + 1] = {
				elementName = ElementPropData[abParm.elementType],
				elementTypeId = abParm.elementType
			}
			item.elementList = elementList
			item.rare = ToInt(AbilityUtils.isRareAbilityByParamId(k, petInfo.templateId))
			item.order = v.skillOrder or 999
			item.derive = v.derive
			item.unlockRequirement = v.unlockRequirement
			item.unLock = Utils.isPetSkillUnlock(pg.me, petPrototypeId, k)
			item.alreadyLearnt = unlockedAbilityMap[k] ~= nil
			item.consume = v.learnSkillConsume
			item.paramId = k
			item.abilityId = AbilityUtils.getAbilityIdByParamId(petInfo.templateId, k)
			ret[#ret + 1] = item
		end
	end

	table.sort(ret, function(a, b)
		return a.order < b.order
	end)

	local derivation = self:skillDerivation(ret)
	local newT = {}

	for _, v in pairs(derivation) do
		newT[#newT + 1] = v
	end

	if #newT < 7 then
		for i = #newT + 1, 7 do
			newT[i] = {}
		end
	end

	return newT
end

return PetSkillModel
