-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\PetTrainingNewModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetNatureData = require("Data.pet_nature_data")
local ElementNameToId = require("Data.element_name_to_id")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetLevelData = require("Data.pet_level_data")
local PetTrainAttrShowData = require("Data.pet_trainAttr_show_data")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetTrainingNewModel")
local Lume = require("Core.Common.lume")
local SkillTagData = require("Data.skill_tag_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetCharacterData = require("Data.pet_character_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local TmpPetTemplateData = require("Data.tmp_pet_template_data")
local ActorUtils = require("Common.Utils.ActorUtils")
local AbilityParamData = require("Data.ability_param_data")
local RedDotConst = require("Const.RedDotConst")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FunctionEnum = require("Data.function_unlock_enum")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetConfigData = require("Data.pet_config_data")
local PetTrainingNewModel = Class.LightClass("PetTrainingNewModel", UIModel)

PetTrainingNewModel.EMPTY_ABILITY_ID = 0

function PetTrainingNewModel:ctor()
	self.petMaxLevel = table.maxn(PetLevelData)
end

function PetTrainingNewModel:getTabList(sLimitTabs, canEvolve)
	local tabList = {}

	local function isGrather0TabValid(mSLimitTabs, tabPage)
		if not mSLimitTabs then
			return true
		end

		return mSLimitTabs[tabPage] == true
	end

	local EPages = Const.PetCulPages
	local ENames = Const.PetCulPageIndex2Name
	local tabCfgList = {
		{
			nameKey = "PET_SKILL_PAGE",
			tab = EPages.SKILL,
			tabName = ENames[EPages.SKILL],
			condition = function()
				return true
			end
		},
		{
			nameKey = "PET_RISING_STAR",
			tab = EPages.STARUP,
			tabName = ENames[EPages.STARUP],
			condition = function(mSLimitTabs)
				if not isGrather0TabValid(mSLimitTabs, EPages.STARUP) then
					return false
				end

				return LuaUIUtils.getIsCultivateSubCompUnLocked(ENames[EPages.STARUP])
			end
		},
		{
			nameKey = "PET_TRAINING_PAGE",
			tab = EPages.TALENT,
			tabName = ENames[EPages.TALENT],
			condition = function(mSLimitTabs)
				if not isGrather0TabValid(mSLimitTabs, EPages.TALENT) then
					return false
				end

				return LuaUIUtils.getIsCultivateSubCompUnLocked(ENames[EPages.TALENT])
			end
		},
		{
			nameKey = "PET_EVOLUTION_PAGE",
			tab = EPages.EVOLUTION,
			tabName = ENames[EPages.EVOLUTION],
			condition = function(mSLimitTabNum, mCanEvolve)
				return false
			end
		},
		{
			nameKey = "EQUIP_CARRY",
			tab = EPages.CARRY,
			tabName = ENames[EPages.CARRY],
			condition = function(mSLimitTabs)
				if not isGrather0TabValid(mSLimitTabs, EPages.CARRY) then
					return false
				end

				return LuaUIUtils.getIsCultivateSubCompUnLocked(ENames[EPages.CARRY])
			end
		}
	}

	for cfgIdx, cfg in ipairs(tabCfgList) do
		if cfg and cfg.condition then
			local isShow = cfg.condition(sLimitTabs, canEvolve)

			if isShow then
				table.insert(tabList, cfg)
			end
		end
	end

	local validTabLen = #tabList

	for idx, tab in ipairs(tabList) do
		local tIndex = 1

		if idx == 1 then
			tIndex = 0
		elseif idx == validTabLen then
			tIndex = 2
		end

		tabList[idx] = {
			tab = tab.tab,
			tabName = tab.tabName,
			name = pg.getGameString(tab.nameKey),
			tIndex = tIndex
		}
	end

	self.tabList = tabList

	return tabList
end

function PetTrainingNewModel:getSelectTabIndexByName(tabName)
	if tabName == Const.PetCulPageIndex2Name[Const.PetCulPages.STARUP] then
		local isCanStarUp = LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageIndex2Name[Const.PetCulPages.STARUP])

		if not isCanStarUp then
			tabName = Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT]
		end
	end

	if tabName == Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT] then
		local isCanTalent = LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT])

		if not isCanTalent then
			tabName = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL]
		end
	end

	for idx, tab in ipairs(self.tabList) do
		if tab.tabName == tabName then
			return idx - 1, tabName
		end
	end

	return -1
end

function PetTrainingNewModel:getTabIndex(tab)
	local index = 1

	for i, v in ipairs(self.tabList) do
		if v.tab == tab then
			index = i

			break
		end
	end

	return index - 1
end

function PetTrainingNewModel:getTrainingTimesData(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local baseProperty = petInfo.basePropertyList
	local left = baseProperty:getIndividualLearnLevel()
	local right = baseProperty:getIndividualMaxLearnLevel()

	return left, right
end

function PetTrainingNewModel:getPageIndexAndRatingStr(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local pageIndex, ratingStr = petInfo:getPropRatingResult()

	return pageIndex, pg.getGameString(ratingStr)
end

function PetTrainingNewModel:getSinglePetInfo(petId)
	if self.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local petInfo = pvpPetSet.model.petsMap[petId]
		local configData = petInfo.configData
		local res = {
			iconName = configData.icon,
			label = configData.label,
			gender = configData.gender
		}

		return res
	else
		return pg.global.ui.petManagement.model:getSinglePetInfo(petId)
	end
end

function PetTrainingNewModel:setUpPetInfo(petId)
	local pet = pg.me:getPetInfo(petId)
	local petInfo = {}

	petInfo.isEmpty = pet == nil

	if petInfo.isEmpty then
		return petInfo
	end

	petInfo = pet:getRawTable()
	petInfo.isCatchReportingStatus = pet:isCatchReporting()

	local pData = PetData[pet.templateId] or {}

	petInfo.gender = pet.gender
	petInfo.name = self:getPetName(pet.id)
	petInfo.iconName = pData.iconName
	petInfo.recommend_attr = pData.recommend_attr

	local cp = self:getCpValue(pet.id)

	petInfo.cp = cp
	petInfo.maxHp = 100

	local labelInfo = {}

	petInfo.id = pet.id
	petInfo.label = pet.label
	petInfo.isBoss = Utils.isLabelElite(pet.label)
	petInfo.isMini = Utils.isLabelRainbow(pet.label)
	petInfo.isShiny = Utils.isLabelShiny(pet.label)
	petInfo.isVariant = Utils.isLabelVariant(pet.label)
	petInfo.labelInfo = labelInfo
	petInfo.race = pData.species
	petInfo.nature = PetNatureData[pet.nature].name
	petInfo.maxExp = self:getCurMaxExp(pet.level)

	local prototypeData = PetPrototypeData[pet.templateId]
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.elementType = pData.elementType
	petInfo.time = pet.time
	petInfo.level = pet.level
	petInfo.templateId = pet.templateId
	petInfo.isFavorite = pet.isFavorite
	petInfo.customName = pet.customName
	petInfo.fetter = pet.fetter
	petInfo.height = pet.height
	petInfo.weight = pet.weight
	petInfo.templateId = pet.templateId
	petInfo.canEvolve = pet:canEvolveAny()

	return petInfo
end

function PetTrainingNewModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return name
end

function PetTrainingNewModel:getPetLocName(petId)
	return pg.getLocalizationText(self:getPetName(petId))
end

function PetTrainingNewModel:getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function PetTrainingNewModel:getCurMaxExp(level)
	return PetLevelData[math.min(level + 1, self.petMaxLevel)].needExp
end

function PetTrainingNewModel:getPayBackInfo(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local paybackItem = petInfo.basePropertyList:getIndividualResetPayback()
	local ret = {}

	for k, v in pairs(paybackItem) do
		local totalNum = 0

		for _, v1 in pairs(v) do
			totalNum = totalNum + v1
		end

		ret[#ret + 1] = {
			k,
			totalNum,
			hideOwnNum = true
		}
	end

	return ret
end

function PetTrainingNewModel:getIndividualLearnCost(petId, propIndex, toLevel)
	local petInfo = pg.me:getPetInfo(petId)
	local learnCost = petInfo.basePropertyList:getIndividualLearnCost(propIndex, toLevel)
	local ret = {}

	for id, count in pairs(learnCost) do
		ret[#ret + 1] = {
			id = id,
			num = count
		}
	end

	return ret
end

function PetTrainingNewModel:getPetPropLevels(petInfo)
	return pg.game.petManage:getPetPropLevels(petInfo)
end

function PetTrainingNewModel:getPetNameAndInfo(petId)
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

function PetTrainingNewModel:getCurCharacter(petId)
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

function PetTrainingNewModel:getPetSkillInfos(petId, type)
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
		abilityInfo.isUltimate = abilityParamData.skillType == 4

		local petInfo = pg.me:getPetInfo(petId)
		local paramId = AbilityUtils.getAbilityParamId(abilityInfo.abilityId)

		abilityInfo.paramId = paramId

		local basePetPrototypeId = Utils.getRefIdByPetPrototypeId(petInfo.petPrototypeId)
		local skData = PetSkillData[basePetPrototypeId]
		local originParamId = paramId
		local psdd = skData and skData[paramId]

		if not psdd and skData then
			for origId, origData in pairs(skData) do
				if origData.enhancedSkillId == paramId then
					originParamId = origId
					psdd = origData

					break
				end
			end
		end

		abilityInfo.originParamId = originParamId

		local hasGlazePath = psdd and psdd.enhancedSkillId and true or false

		abilityInfo.hasGlazePath = hasGlazePath

		if hasGlazePath then
			abilityInfo.enhancedSkillId = psdd.enhancedSkillId
			abilityInfo.glazeConsume = psdd.upgradeConsume or PetConfigData.skillUpgradeConsume

			local alreadyGlazed = originParamId ~= paramId or petInfo.unlockedAbilityMap[psdd.enhancedSkillId] ~= nil

			abilityInfo.alreadyGlazed = alreadyGlazed
			abilityInfo.canGlaze = petInfo.unlockedAbilityMap[originParamId] ~= nil and not alreadyGlazed
		else
			abilityInfo.canGlaze = false
		end

		return abilityInfo
	end

	return nil
end

function PetTrainingNewModel:getPetAllUnlockedSkill(petId)
	local unlockedAbilityMap, petPrototypeId, petInfo

	if self.IS_PVP_FAIL_MODE then
		local validAbilityMap = Utils.pvpGetValidAbilityMap(petId)

		unlockedAbilityMap = {}

		for k, v in pairs(validAbilityMap) do
			if v == true then
				local abilityId = AbilityUtils.getAbilityIdByParamId(TmpPetTemplateData[petId].templateBaseId, k)

				if abilityId ~= PetTrainingNewModel.EMPTY_ABILITY_ID then
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
				alreadyLearnt = true,
				unLock = true
			})
		end
	else
		local baseProtType = Utils.getRefIdByPetPrototypeId(petPrototypeId)
		local skData = PetSkillData[baseProtType]
		local recordedMap = pg.me and pg.me.petSkillUpgradeMap and pg.me.petSkillUpgradeMap[baseProtType or 0] or {}

		for k, v in pairs(skData) do
			local abParm = AbilityParamData[k] or {}

			if abParm == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("skill param [id:%d] is not exist", k)
			end

			local tp = skData[k] and skData[k].abilityType

			if abParm and tp == "skill" then
				local actualParamId = k

				if v.enhancedSkillId and unlockedAbilityMap[v.enhancedSkillId] ~= nil then
					actualParamId = v.enhancedSkillId
				end

				local abilityId = AbilityUtils.getAbilityIdByParamId(petPrototypeId, actualParamId)

				if abilityId == 0 and LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("skill param [id:%d] is not valid", actualParamId)
				end

				local unLock = Utils.isPetSkillUnlock(pg.me, petPrototypeId, k)
				local alreadyLearnt = unlockedAbilityMap[actualParamId] ~= nil

				self:setupAbilityInfo(ret, abilityId, petPrototypeId, {
					unLock = unLock,
					alreadyLearnt = alreadyLearnt,
					unlockRequirement = v.unlockRequirement,
					unlockedAbilityMap = unlockedAbilityMap,
					originParamId = k
				})
			end
		end
	end

	table.sort(ret, function(a, b)
		return a.order < b.order
	end)
	table.sort(ret, function(a, b)
		return a.tIndex < b.tIndex
	end)

	return ret
end

function PetTrainingNewModel:isAbilityIdLearnt(petId, abilityId)
	local unlockedAbilityMap

	if self.IS_PVP_FAIL_MODE then
		unlockedAbilityMap = {}

		local validAbilityMap = Utils.pvpGetValidAbilityMap(petId)

		for k, v in pairs(validAbilityMap) do
			if v == true then
				local abilityId1 = AbilityUtils.getAbilityIdByParamId(TmpPetTemplateData[petId].templateBaseId, k)

				if abilityId1 ~= PetTrainingNewModel.EMPTY_ABILITY_ID then
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

function PetTrainingNewModel:setupAbilityInfo(ret, abilityId, petPrototypeId, extraParam)
	local paramId = AbilityUtils.getAbilityParamId(abilityId)
	local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(petPrototypeId)]
	local isHideLocked = skData[paramId] and skData[paramId].isHideLocked and skData[paramId].isHideLocked == 1 or false

	if isHideLocked and extraParam and not extraParam.unLock then
		return
	end

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
	abilityInfo.rare = ToInt(AbilityUtils.isRareAbilityByParamId(paramId, petPrototypeId))
	abilityInfo.isRare = abilityInfo.rare == 1
	abilityInfo.isUltimate = abilityParamData.skillType == 4
	abilityInfo.paramId = paramId

	local originParamIdForOrder = extraParam and extraParam.originParamId or paramId

	abilityInfo.order = skData[originParamIdForOrder] and skData[originParamIdForOrder].skillOrder or 999
	abilityInfo.derive = skData[originParamIdForOrder] and skData[originParamIdForOrder].derive or nil

	if extraParam then
		abilityInfo.unLock = extraParam.unLock
		abilityInfo.alreadyLearnt = extraParam.alreadyLearnt
		abilityInfo.unlockRequirement = extraParam.unlockRequirement
	end

	if abilityInfo.rare == 1 then
		abilityInfo.tIndex = 0
	else
		abilityInfo.tIndex = 1
	end

	local originParamId = extraParam and extraParam.originParamId or paramId

	abilityInfo.originParamId = originParamId

	local psdd = skData[originParamId]
	local hasGlazePath = psdd and psdd.enhancedSkillId and true or false

	abilityInfo.hasGlazePath = hasGlazePath

	if hasGlazePath then
		abilityInfo.enhancedSkillId = psdd.enhancedSkillId
		abilityInfo.glazeConsume = psdd.upgradeConsume or PetConfigData.skillUpgradeConsume

		local unlockedAbilityMap = extraParam and extraParam.unlockedAbilityMap
		local alreadyGlazed = originParamId ~= paramId or unlockedAbilityMap and unlockedAbilityMap[psdd.enhancedSkillId] ~= nil or false

		abilityInfo.alreadyGlazed = alreadyGlazed
		abilityInfo.canGlaze = extraParam and extraParam.alreadyLearnt and not alreadyGlazed
	else
		abilityInfo.canGlaze = false
	end

	ret[#ret + 1] = abilityInfo
end

function PetTrainingNewModel:skillDerivation(ret)
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

function PetTrainingNewModel:isSkillEquipment(petId, abilityId)
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

function PetTrainingNewModel:getSkillLearnData(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local petPrototypeId = petInfo.petPrototypeId
	local unlockedAbilityMap = petInfo.unlockedAbilityMap
	local ret = {}
	local skData = PetSkillData[Utils.getRefIdByPetPrototypeId(petPrototypeId)]

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
			item.rare = ToInt(AbilityUtils.isRareAbilityByParamId(k, petPrototypeId))
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

local ItemUtils = require("Common.Utils.ItemUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local PetTalentData = require("Data.pet_talent_data")
local AttributeData = require("Data.attribute_group_data")
local BuffData = require("Data.buff_config_data")
local CoreCarryData = require("Data.core_carry_data")
local CoreCarryLevelData = require("Data.core_carry_level_data")
local AssistCarryData = require("Data.assist_carry_data")

PetTrainingNewModel.CARRY_SORT_DESC = {
	"DEFAULT_SORT",
	"QUALITY",
	"TYPE",
	"STRENGTH_LEVEL"
}

function PetTrainingNewModel:getCarrySortOptions()
	local options = {}

	for idx, sortDesc in ipairs(self.CARRY_SORT_DESC) do
		options[idx] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return options
end

function PetTrainingNewModel:switchSortAscending()
	self.isAscending = not self.isAscending
end

function PetTrainingNewModel:getSortAscending()
	return self.isAscending
end

function PetTrainingNewModel:setSortOption(sortOptionIdx)
	self.sortOptionIdx = sortOptionIdx
end

function PetTrainingNewModel:getSortOption()
	return self.sortOptionIdx or 0
end

function PetTrainingNewModel:setAssistTypeOption(assistType)
	self.assistTab = assistType
end

function PetTrainingNewModel:getAssistTypeOption()
	return self.assistTab or 1
end

function PetTrainingNewModel:setAssistPosInfo(assistPosInfo)
	self.assistPosInfo = assistPosInfo
end

function PetTrainingNewModel:setSelectCarryCore(selectCarryCore)
	self.selectCarryCore = selectCarryCore
end

function PetTrainingNewModel:getSelectCarryCore()
	return self.selectCarryCore
end

function PetTrainingNewModel:setCurPetId(petID)
	self.petID = petID
end

function PetTrainingNewModel:getCarryPropListWithFilter(type)
	local sortId = self.sortOptionIdx + 1
	local assistTab = self:getAssistTypeOption()
	local recommendSuitCoreId
	local recommendEquipmentSet = {}

	if type == ItemConst.ITEM_TYPE_CARRY_CORE then
		local petInfo = pg.me:getPetInfo(self.petID)
		local ppd = petInfo and PetPrototypeData[petInfo.templateId]

		if ppd then
			if ppd.recommendSuit and ppd.recommendSuit[1] then
				recommendSuitCoreId = ppd.recommendSuit[1]
			end

			if ppd.recommendEquipment then
				for _, eid in ipairs(ppd.recommendEquipment) do
					recommendEquipmentSet[eid] = true
				end
			end
		end
	end

	local function getCoreRecommendWeight(item)
		if recommendSuitCoreId and item.itemId == recommendSuitCoreId then
			return 2
		end

		if recommendEquipmentSet[item.itemId] then
			return 1
		end

		return 0
	end

	return self:getCarryPropList(function(item)
		local cData = ItemData[item.id]

		return cData and cData.type == (type or ItemConst.ITEM_TYPE_CARRY_CORE)
	end, function(a, b)
		if type == ItemConst.ITEM_TYPE_CARRY_ASSISTED then
			local equipA = a.ownerCoreCarryPos and next(a.ownerCoreCarryPos) and a.ownerCoreCarryPos[2] ~= 0 or false
			local equipB = b.ownerCoreCarryPos and next(b.ownerCoreCarryPos) and b.ownerCoreCarryPos[2] ~= 0 or false

			if equipA ~= equipB then
				return equipA
			end

			if sortId == 2 then
				if a.quality ~= b.quality then
					if self.isAscending then
						return a.quality < b.quality
					else
						return a.quality > b.quality
					end
				end

				if a.cpValue ~= b.cpValue then
					return a.cpValue > b.cpValue
				end
			elseif sortId == 3 then
				if a.cpValue ~= b.cpValue then
					if self.isAscending then
						return a.cpValue < b.cpValue
					else
						return a.cpValue > b.cpValue
					end
				end
			elseif a.quality ~= b.quality then
				return a.quality > b.quality
			end

			if a.index ~= b.index then
				return a.index < b.index
			end

			return false
		else
			local equipA = a.ownerPetId == self.petID
			local equipB = b.ownerPetId == self.petID

			if equipA ~= equipB then
				return equipA
			end

			if sortId == 1 then
				if a.quality ~= b.quality then
					if self.isAscending then
						return a.quality < b.quality
					else
						return a.quality > b.quality
					end
				end

				if a.cLevel ~= b.cLevel then
					if self.isAscending then
						return a.cLevel < b.cLevel
					else
						return a.cLevel > b.cLevel
					end
				end

				if a.itemId ~= b.itemId then
					if self.isAscending then
						return a.itemId > b.itemId
					else
						return a.itemId < b.itemId
					end
				end

				if a.genID ~= b.genID then
					if self.isAscending then
						return a.genID > b.genID
					else
						return a.genID < b.genID
					end
				end

				if a.index ~= b.index then
					if self.isAscending then
						return a.index > b.index
					else
						return a.index < b.index
					end
				end
			elseif sortId == 2 then
				if a.quality ~= b.quality then
					if self.isAscending then
						return a.quality < b.quality
					else
						return a.quality > b.quality
					end
				end
			elseif sortId == 3 then
				if a.familyId ~= b.familyId then
					if self.isAscending then
						return a.familyId < b.familyId
					else
						return a.familyId > b.familyId
					end
				end
			elseif sortId == 4 and a.cLevel ~= b.cLevel then
				if self.isAscending then
					return a.cLevel < b.cLevel
				else
					return a.cLevel > b.cLevel
				end
			end

			if sortId == 2 or sortId == 3 or sortId == 4 then
				local wA = getCoreRecommendWeight(a)
				local wB = getCoreRecommendWeight(b)

				if wA ~= wB then
					return wB < wA
				end
			end

			return false
		end
	end, function(item)
		if type == ItemConst.ITEM_TYPE_CARRY_CORE then
			return true
		else
			local aCfg = AssistCarryData[item.itemId]

			return aCfg and aCfg.type == assistTab
		end
	end)
end

function PetTrainingNewModel:getCarryPropList(filterFunc, sortFunc, filterFunc2)
	local itemList = {}

	ItemUtils.eachSupportedTypedBag(pg.me, function(invId, itemBag)
		local iList = itemBag:getByFilter(function(item)
			rawset(item, "invId", invId)

			if filterFunc then
				return filterFunc(item)
			end

			return true
		end)

		table.mergeList(itemList, iList)
	end)

	local carryInfoList = Lume.imap(itemList, function(v)
		return self:parseCarryFullInfo(v)
	end)

	if filterFunc2 then
		carryInfoList = Lume.ifilter(carryInfoList, filterFunc2)
	end

	if sortFunc then
		for i, v in ipairs(carryInfoList) do
			v.index = i
		end

		table.sort(carryInfoList, sortFunc)
	end

	return carryInfoList
end

function PetTrainingNewModel:parseAttr(sData, data)
	if data.type == ItemConst.ITEM_TYPE_CARRY_CORE then
		self:parseCarryAttr(sData, data)
	else
		self:parseCarryAssistAttr(sData, data)
	end
end

function PetTrainingNewModel:parseCarryFullInfo(item)
	local sData = ItemUtils.getPropertyWithType(item)

	if not sData then
		return nil
	end

	local data = sData:getRawTable()

	LuaUIUtils.parseItemCfgData(data)
	self:parseItemInfo(data, item)
	self:parseCarryPetInfo(data, sData)
	self:parseAttr(sData, data)

	return data
end

function PetTrainingNewModel:overrideCarryFullInfo(data)
	if not data then
		return
	end

	local itemBag = ItemUtils.getTypedBag(pg.me, data.invId)
	local item = itemBag and itemBag:get(data.genID)
	local sData = item and ItemUtils.getPropertyWithType(item)

	if not sData then
		return
	end

	local nData = sData:getRawTable()

	table.merge(data, nData)

	if data.type == ItemConst.ITEM_TYPE_CARRY_ASSISTED then
		LuaUIUtils.checkParseCarryInfo(data)
	end

	LuaUIUtils.parseItemCfgData(data)
	self:parseItemInfo(data, item)
	self:parseCarryPetInfo(data, sData)
	self:parseAttr(sData, data)
end

function PetTrainingNewModel:overrideCarryList(dataList)
	local count = dataList.Count

	for i = 1, count do
		local data = dataList[i - 1]

		self:overrideCarryFullInfo(data)
	end
end

function PetTrainingNewModel:parseCarryFullInfoWithId(invId, genID)
	local itemBag = ItemUtils.getTypedBag(pg.me, invId)
	local item = itemBag and itemBag:get(genID)

	return self:parseCarryFullInfo(item)
end

function PetTrainingNewModel:parseItemInfo(data, v)
	data.sourceItem = v
	data.genID = v.genID
	data.isLocked = v:isStatusLocked()
	data.invId = v.invId or v.getInvID and v:getInvID()

	local cfg = self:getCarryORCarryAsstCfg(data.itemId)

	data.familyId = cfg and cfg.familyId or cfg.type
	data.ownNum = 1
	data.bigIcon = LuaUIUtils.getIconByItemId(data.itemId, LuaUIUtils.ITEM_ICON_TYPE.ICON_BIG)
	data.icon = LuaUIUtils.getIconByItemId(data.itemId)
	data.l10nName = LuaUIUtils.getNameByItemId(data.itemId)
end

function PetTrainingNewModel:parseCarryPetInfo(data, sData)
	local pId

	if data.type == ItemConst.ITEM_TYPE_CARRY_CORE then
		pId = data.ownerPetId

		local me = pg.me
		local pInfo = me:getPetInfo(pId)

		if pInfo then
			data.isEquipped = true
			data.petIcon = LuaUIUtils.getPetIconByTemplateId(pInfo.templateId, LuaUIUtils.PET_ICON, pInfo.label)
			data.petName = pg.getLocalizationText(LuaUIUtils.getPetName(pId))
		else
			data.isEquipped = false
			data.petIcon = nil
		end
	else
		local coreCarry = sData.ownerCoreCarryPos

		data.isEquipped = false
		data.coreIcon = nil
		data.coreName = nil

		if coreCarry:isValid() then
			local coreCarryData = self:parseCarryFullInfoWithId(coreCarry:invId(), coreCarry:genId())

			if coreCarryData then
				pId = coreCarryData.ownerPetId
				data.isEquipped = true
				data.coreIcon = LuaUIUtils.getIconByItemId(coreCarryData.itemId)
				data.coreName = LuaUIUtils.getNameByItemId(coreCarryData.itemId)
			end
		end

		local me = pg.me
		local pInfo = me:getPetInfo(pId)

		if pInfo then
			data.petIcon = LuaUIUtils.getPetIconByTemplateId(pInfo.templateId, LuaUIUtils.PET_ICON, pInfo.label)
			data.petName = pg.getLocalizationText(LuaUIUtils.getPetName(pId))
		else
			data.petIcon = nil
		end
	end
end

function PetTrainingNewModel:parseCarryAttr(sData, data)
	local sLv, cExp = sData:getLevelAndExp()

	data.cLevel = sLv
	data.curExp = cExp

	local mLv, totalCanAddExp = sData:getMaxLevelAndTotalExp()

	data.mLevel = mLv
	data.maxExp = CoreCarryLevelData[sLv + 1] and CoreCarryLevelData[sLv + 1].needExp or math.maxInt
	data.isMaxLv = mLv <= sLv
	data.addExp = sData.totalExp
	data.totalCanAddExp = totalCanAddExp

	local mainTalents = {}

	for _, tInfo in ipairs(data.talentList) do
		local tId = tInfo.templateId
		local vVa = tInfo.propValues
		local cData = PetTalentData[tId]

		if cData.props then
			for i, v in ipairs(cData.props) do
				mainTalents[#mainTalents + 1] = {
					id = v[1],
					value = vVa[i] or 0
				}
			end
		end
	end

	local cData = CoreCarryData[data.itemId]

	if cData and cData.prop then
		for id, v in pairs(cData.prop) do
			mainTalents[#mainTalents + 1] = {
				id = id,
				value = v or 0
			}
		end
	end

	local addition = sData:getEnhanceRatio()

	for _, v in ipairs(mainTalents) do
		local aData = AttributeData[v.id]

		if aData then
			v.name = pg.getLocalizationText(aData.name)
		end

		if v.value < 0 then
			v.tValue = (1 - addition) * v.value
		else
			v.tValue = (1 + addition) * v.value
		end

		v.tDesc = Utils.formatAttrDesc(v.tValue, 1, true)
		v.icon = aData.icon
	end

	data.mainProperties = mainTalents

	local desc

	if cData.buffId ~= nil then
		for _, v in ipairs(cData.buffId) do
			local bData = BuffData[v]
			local str = pg.getLocalizationText(bData.buffDesc)

			if string.isNilOrEmpty(desc) then
				desc = str
			else
				desc = string.format("%s\n%s", desc, str)
			end
		end
	end

	data.buffDesc = desc

	local assistUnlock = {}

	if cData and cData.slotUnlockLv ~= nil then
		for index, unlockLv in ipairs(cData.slotUnlockLv) do
			assistUnlock[index] = unlockLv <= data.cLevel and 1 or 0
		end
	end

	data.slotUnlockLv = cData.slotUnlockLv
	data.assistUnlock = assistUnlock

	local energyEffects = {}

	if cData and cData.energyEffects ~= nil then
		for index, effCfg in ipairs(cData.energyEffects) do
			local effDesc

			for _, v in ipairs(effCfg[2]) do
				local bData = BuffData[v]
				local str = pg.getLocalizationText(bData.buffDesc)

				if string.isNilOrEmpty(effDesc) then
					effDesc = str
				else
					effDesc = string.format("%s\n%s", effDesc, str)
				end
			end

			energyEffects[index] = {
				energy = effCfg[1],
				effDesc = effDesc,
				enhanceLv = effCfg[3] or 0
			}
		end
	end

	data.energyEffects = energyEffects

	local energySum = 0

	for _, itemPos in ipairs(data.assistCarryPosList) do
		local assistCarryCfg = self:parseCarryAssistCfgWithId(itemPos[1], itemPos[2])

		if assistCarryCfg then
			energySum = energySum + assistCarryCfg.energy
		end
	end

	data.energySum = energySum
end

function PetTrainingNewModel:getCarryORCarryAsstCfg(itemId)
	return ItemUtils.isCoreCarryItem(itemId) and CoreCarryData[itemId] or AssistCarryData[itemId]
end

function PetTrainingNewModel:parseDefaultAttrInfo(data)
	local mainTalents = {}
	local cData = self:getCarryORCarryAsstCfg(data.itemId)
	local prop = cData.prop or cData.baseprop

	if cData and prop then
		for id, v in pairs(prop) do
			mainTalents[#mainTalents + 1] = {
				id = id,
				value = v or 0
			}
		end
	end

	for index, v in ipairs(mainTalents) do
		local aData = AttributeData[v.id]

		if aData then
			v.name = pg.getLocalizationText(aData.name)
		end

		v.tValue = v.value
		v.tDesc = Utils.formatAttrDesc(v.tValue, aData.showType, true)
		v.icon = aData.icon
	end

	local acData = AssistCarryData[data.itemId]

	data.energy = acData and acData.energy or 0
	data.mainProperties = mainTalents

	local desc

	if cData.buffId ~= nil then
		for _, v in ipairs(cData.buffId) do
			local bData = BuffData[v]
			local str = pg.getLocalizationText(bData.buffDesc)

			if string.isNilOrEmpty(desc) then
				desc = str
			else
				desc = string.format("%s\n%s", desc, str)
			end
		end
	end

	data.buffDesc = desc
end

function PetTrainingNewModel:getPetCarryInfo(petId)
	local pCarryInfo = {}
	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return pCarryInfo
	end

	local carryPosMap

	if pg.me.tempPets and pg.me.tempPets[petId] == petInfo then
		carryPosMap = pg.me.tempPetCoreCarryPosMap
	elseif pg.me.pets and pg.me.pets[petId] == petInfo then
		carryPosMap = pg.me.petCoreCarryPosMap
	end

	local carry = carryPosMap and carryPosMap:getItemPos(petId)
	local invId = carry and carry:invId() or 0
	local genId = carry and carry:genId() or 0

	pCarryInfo.isEquipped = genId ~= 0
	pCarryInfo.genID = genId
	pCarryInfo.invId = invId
	self.carryPetInfo = pCarryInfo

	return pCarryInfo
end

function PetTrainingNewModel:getPetEquipCarry(petId)
	local equipInfo = self:getPetCarryInfo(petId)
	local invId = equipInfo.invId
	local genID = equipInfo.genID

	if invId == 0 or genID == 0 then
		return nil
	end

	return self:parseCarryFullInfoWithId(invId, genID)
end

function PetTrainingNewModel:parseDefaultCarryInfo(itemId)
	local data = {
		itemId = itemId
	}

	LuaUIUtils.parseItemCfgData(data)

	data.familyId = CoreCarryData[itemId] and CoreCarryData[itemId].familyId
	data.ownNum = 1
	data.isLocked = false

	self:parseDefaultAttrInfo(data)

	return data
end

function PetTrainingNewModel:parseCarryAssistAttr(sData, data)
	data.energy = sData:getEnergy()
	data.cpValue = sData:getCpValue()
	data.assistType = sData:getAssistType()

	local mainTalents = {}
	local cData = AssistCarryData[data.itemId]

	if cData and cData.baseprop and next(cData.baseprop) then
		for id, v in pairs(cData.baseprop) do
			mainTalents[#mainTalents + 1] = {
				id = id,
				value = v or 0
			}
		end

		for index, v in ipairs(mainTalents) do
			local aData = AttributeData[v.id]

			if aData then
				v.name = pg.getLocalizationText(aData.name)
			end

			v.tValue = v.value
			v.tDesc = Utils.formatAttrDesc(v.tValue, aData.showType, true)
			v.icon = aData.icon
		end
	end

	data.mainProperties = mainTalents

	local randomProperties = {}

	for _, tInfo in ipairs(data.talentList) do
		local tId = tInfo.templateId
		local vVa = tInfo.propValues
		local cData = PetTalentData[tId]

		if cData.props then
			for i, v in ipairs(cData.props) do
				local randomPro = tInfo.scaleFixs and next(tInfo.scaleFixs) and tInfo.scaleFixs[1] or PetConfigData.gemsPropQualityColor[1]
				local attrPro = self:parseCarryAssistValuePro(randomPro)

				randomProperties[#randomProperties + 1] = {
					id = v[1],
					value = vVa[i] or 0,
					quality = self:parseCarryAssistValueQuality(randomPro),
					pro = attrPro,
					isMax = attrPro == 1,
					isRare = cData.rarity == 2
				}
			end
		end
	end

	for index, v in ipairs(randomProperties) do
		local aData = AttributeData[v.id]

		if aData then
			v.name = pg.getLocalizationText(aData.name)
		end

		v.tValue = v.value
		v.tDesc = Utils.formatAttrDesc(v.tValue, aData.showType, true)
		v.icon = aData.icon
	end

	table.sort(randomProperties, function(a, b)
		return a.id < b.id
	end)

	data.randomProperties = randomProperties
end

function PetTrainingNewModel:parseCarryAssistValueQuality(value)
	local quality = 0
	local qualities = PetConfigData.gemsPropQualityColor

	if qualities and next(qualities) then
		for i, v in ipairs(qualities) do
			if v <= value then
				quality = quality + 1
			end
		end
	end

	return math.max(0, quality + 2)
end

function PetTrainingNewModel:parseCarryAssistValuePro(pro)
	local newPro = pro
	local qualities = PetConfigData.gemsPropQualityColor
	local maxNum = qualities and next(qualities) and qualities[#qualities] or 1

	newPro = pro / maxNum

	return newPro
end

function PetTrainingNewModel:parseCarryAssistCfgWithId(invId, genID)
	local itemBag = ItemUtils.getTypedBag(pg.me, invId)
	local item = itemBag and itemBag:get(genID)
	local sData = item and ItemUtils.getPropertyWithType(item)
	local data = sData and sData:getRawTable()

	if data then
		LuaUIUtils.parseItemCfgData(data)

		local asstCfg = AssistCarryData[data.itemId]

		data.energy = asstCfg.energy
	end

	return data or nil
end

function PetTrainingNewModel:getRequiredItems(itemConditions)
	local t = {}
	local success, idNumDict, altIdNumDict, replacedInfo = ItemUtils.getEvolveNeedItemResult(pg.me, itemConditions)

	for itmId, itemNum in pairs(idNumDict) do
		local temp = {}

		if not altIdNumDict[itmId] then
			temp.id = itmId

			local iData = ItemData[itmId]

			temp.name = iData.itemName
			temp.icon = LuaUIUtils.getIconByIconId(iData.icon)
			temp.quality = iData.quality
			temp.ownNum = ItemUtils.getItemCountById(pg.me, itmId)
			temp.requiredNum = itemNum

			for _, v in pairs(replacedInfo) do
				if v.oriItemId == itmId then
					temp.requiredNum = temp.requiredNum + v.oriNum

					break
				end
			end

			t[#t + 1] = temp
		end
	end

	return t, success, replacedInfo
end

function PetTrainingNewModel:getPetPotentialPoints(petId)
	local infos = PetManagementUtils.getPetNewSixPropInfos(petId)

	return infos and infos.remainPotentialPointSum or 0, infos and infos.potentialPointSum or 0
end

function PetTrainingNewModel:getResonanceState(petId)
	return PetManagementUtils.getPetResonanceState(petId)
end

function PetTrainingNewModel:getResonanceCurSLv(petId)
	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0

	return stage, level
end

function PetTrainingNewModel:getStarItemUrl(stage, model)
	return LuaUIUtils.getStarItemUrl(stage, model)
end

function PetTrainingNewModel:getResonanceNextSLvCfg(petId)
	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local curStage = resonanceInfo.resonanceStage or 1
	local curLv = resonanceInfo.resonanceLevel or 0
	local nextResonanceCfg, nextStage, nextLevel = PetManagementUtils.getPetNextResonanceCfg(petId, curStage, curLv)

	return nextResonanceCfg, nextStage, nextLevel
end

function PetTrainingNewModel:getResonanceMaxSLvCfg(petId)
	local maxStage, maxLevel = PetManagementUtils.getResonanceMaxStageLv(petId)

	return maxStage, maxLevel
end

function PetTrainingNewModel:getPetTargeResonanceStagelvDisplayAttrs2(petId, maxLen, isDelNoChangedAttr)
	if not petId then
		return
	end

	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local curStage = resonanceInfo.resonanceStage or 1
	local curLv = resonanceInfo.resonanceLevel or 0
	local allAttrs = PetManagementUtils.getPetTargeResonanceStagelvDisplayAttrs2(petId, curStage, curLv, maxLen) or {}

	return allAttrs
end

function PetTrainingNewModel:getPetTargeResonanceStagelvDisplayAttrs(petId, maxLen, isDelNoChangedAttr)
	if not petId then
		return
	end

	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local curStage = resonanceInfo.resonanceStage or 1
	local curLv = resonanceInfo.resonanceLevel or 0
	local allAttrs = PetManagementUtils.getPetTargeResonanceStagelvDisplayAttrs(petId, curStage, curLv, maxLen) or {}

	isDelNoChangedAttr = isDelNoChangedAttr == nil and true or isDelNoChangedAttr

	if isDelNoChangedAttr then
		for i = #allAttrs, 1, -1 do
			if allAttrs[i].diffV <= 0 then
				table.remove(allAttrs, i)
			end
		end
	end

	return allAttrs
end

function PetTrainingNewModel:getPetNextResonanceSLvCosts(petId)
	if not petId then
		return
	end

	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local curStage = resonanceInfo.resonanceStage or 1
	local curLv = resonanceInfo.resonanceLevel or 0

	return PetManagementUtils.getPetNextResonanceSLvCosts(petId, curStage, curLv)
end

function PetTrainingNewModel:isEnoughCostToUp(petId)
	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not resonanceInfo then
		return false
	end

	local nextSLvCfg = self:getResonanceNextSLvCfg(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if not resonanceInfo:canUpgradeResonance(petInfo, nextSLvCfg) then
		return false
	end

	return true
end

function PetTrainingNewModel:isAssistOpen()
	local isOpen = ClientUtils.checkCondition(PetConfigData.gemsActivationConditions)

	return isOpen
end

function PetTrainingNewModel:getJewelUnlockStateByCoreCarryIds(invId, genId)
	return 1
end

function PetTrainingNewModel:getJewelUnlockState(coreCarryLv)
	if not coreCarryLv then
		return 1
	end

	local isUnlock = pg and pg.me and pg.me:isFunctionAndSwitchEnable(FunctionEnum.PETEQUIPMENTGEM)

	isUnlock = isUnlock and PetManagementUtils.getIsUnlockCarrySlot(coreCarryLv)

	return isUnlock and 0 or 1
end

function PetTrainingNewModel:checkExistUnequippedAssistByType(slotType)
	local playerBag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PLAYER)

	if not playerBag then
		return false
	end

	for _, item in playerBag:items() do
		if AssistCarryData[item.id] then
			local info = ItemUtils.getPropertyWithType(item)

			if info and info:isValid() and not info.ownerCoreCarryPos:isValid() and info:getAssistType() == slotType then
				return true
			end
		end
	end

	return false
end

function PetTrainingNewModel:redDot_SetAssistSlotRedDot(petId, coreGenId, posIndex, button, isShow)
	local treePath = string.format(RedDotConst.RedDotPath.PET_CAN_CARRY_ITEM, petId, coreGenId, posIndex)

	pg.global.setRedDot(treePath, button, isShow and true or false, RedDotConst.RedDotStyle.UP_HIGH)
end

function PetTrainingNewModel:checkExistStrengthMaterial(coreGenId, familyId)
	local expItems = PetConfigData.coreCarryExpItem

	if expItems and next(expItems) then
		for _, expItemId in ipairs(expItems) do
			if ItemUtils.getItemCountById(pg.me, expItemId) > 0 then
				return true
			end
		end
	end

	if familyId then
		local playerBag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PLAYER)

		if playerBag then
			for _, item in playerBag:items() do
				if item.genID ~= coreGenId then
					local ccdd = CoreCarryData[item.id]

					if ccdd and ccdd.familyId == familyId then
						local info = ItemUtils.getPropertyWithType(item)

						if info and info:isValid() and info.ownerPetId == "" then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

function PetTrainingNewModel:redDot_SetStrengthRedDot(petId, coreGenId, button, isShow)
	local treePath = string.format(RedDotConst.RedDotPath.PET_CAN_CARRY_STRENGTH, petId, coreGenId)

	pg.global.setRedDot(treePath, button, isShow and true or false, RedDotConst.RedDotStyle.UP_HIGH)
end

function PetTrainingNewModel:getPetPropNextLvGains(propIndex, toLevel, isMax, isPlayVx)
	local propCfg = PetTrainAttrShowData and PetTrainAttrShowData[propIndex]

	if not propCfg or isMax then
		return {}
	end

	local ret = {}
	local propData = propCfg.addprops

	for j, data in pairs(propData) do
		local addPropNeedLv = data[1]
		local addPropNameKey = data[2]
		local addPropValue = data[3]
		local addPropValueType = data[4]
		local displayValStr = PetManagementUtils.m_getDisplayShowPropTxt(addPropValue, addPropValueType)

		if addPropNeedLv <= 1 then
			ret[#ret + 1] = {
				l18nName = ClientTextUtils.getLocalizationText(addPropNameKey),
				displayValStr = displayValStr,
				isPlayVx = isPlayVx
			}
		elseif toLevel % addPropNeedLv == 0 then
			ret[#ret + 1] = {
				l18nName = ClientTextUtils.getLocalizationText(addPropNameKey),
				displayValStr = displayValStr,
				isPlayVx = isPlayVx
			}
		end
	end

	return ret
end

function PetTrainingNewModel:getNextLvConsumeInfo(petId, propIndex, toLevel)
	local petInfo = pg.me:getPetInfo(petId)
	local costItems = petInfo.basePropertyList:getIndividualLearnCost(propIndex, toLevel) or {}
	local ret = {}

	for id, count in pairs(costItems) do
		ret[#ret + 1] = {
			id = id,
			num = count
		}
	end

	return ret
end

return PetTrainingNewModel
