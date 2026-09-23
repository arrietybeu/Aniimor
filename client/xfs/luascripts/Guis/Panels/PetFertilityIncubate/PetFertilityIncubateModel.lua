-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubate\\PetFertilityIncubateModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetNatureData = require("Data.pet_nature_data")
local PetData = require("Data.pet_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local Const = require("Common.Const.Const")
local ElementNameToId = require("Data.element_name_to_id")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local PetLevelData = require("Data.pet_level_data")
local PetTalentData = require("Data.pet_talent_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local PetCharacterData = require("Data.pet_character_data")
local PetConfigData = require("Data.pet_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local PetFertilityIncubateModel = Class.LightClass("PetFertilityIncubateModel", UIModel)

PetFertilityIncubateModel.BubbleType = {
	Grow = 2,
	Char = 1,
	Element = 0,
	Quality = 3
}
PetFertilityIncubateModel.index2BubbleType = {
	PetFertilityIncubateModel.BubbleType.Char,
	PetFertilityIncubateModel.BubbleType.Grow,
	PetFertilityIncubateModel.BubbleType.Element,
	PetFertilityIncubateModel.BubbleType.Quality
}
PetFertilityIncubateModel.ratingPageIdx2QualityIcon = {
	[0] = AddressDataConst.INCUBATE_PET_QUALITY.GREEN,
	AddressDataConst.INCUBATE_PET_QUALITY.BLUE,
	AddressDataConst.INCUBATE_PET_QUALITY.PURPLE,
	AddressDataConst.INCUBATE_PET_QUALITY.ORANGE
}

function PetFertilityIncubateModel:getBubbleTypeByIndex(index)
	return PetFertilityIncubateModel.index2BubbleType[index]
end

function PetFertilityIncubateModel:getPetRaingIcon(ratingPageIdx)
	if not ratingPageIdx then
		return AddressDataConst.INCUBATE_PET_QUALITY.GREEN
	end

	return self.ratingPageIdx2QualityIcon[ratingPageIdx] or AddressDataConst.INCUBATE_PET_QUALITY.GREEN
end

function PetFertilityIncubateModel:getPetStageIcon(stage)
	if not AddressDataConst.INCUBATE_PET_AGE or not next(AddressDataConst.INCUBATE_PET_AGE) then
		return ""
	end

	if not stage then
		return AddressDataConst.INCUBATE_PET_AGE[1] or ""
	end

	local stage = math.clamp(stage, 1, #(AddressDataConst.INCUBATE_PET_AGE or {}))

	return AddressDataConst.INCUBATE_PET_AGE[stage] or AddressDataConst.INCUBATE_PET_AGE[1] or ""
end

function PetFertilityIncubateModel:setUpPetInfo(pet)
	local petInfo = {}

	petInfo.empty = pet == nil

	if petInfo.empty then
		return petInfo
	end

	petInfo = pet.getRawTable and pet:getRawTable() or pet

	local pData = PetData[pet.templateId] or {}

	petInfo.petType = pData.functionId
	petInfo.petFunctionIcon = PetConfigData.petFunctionIcon[petInfo.petType]
	petInfo.petFunctionText = pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petInfo.petType)])
	petInfo.ratingPageIdx, petInfo.ratingStr = (pet.getPropRatingResult and function()
		return pet:getPropRatingResult()
	end or function()
		return 0, ""
	end)()
	petInfo.ratingIconUrl = self:getPetRaingIcon(petInfo.ratingPageIdx)
	petInfo.stage = pData.stage
	petInfo.stageIcon = self:getPetStageIcon(petInfo.stage)
	petInfo.gender = pet.gender
	petInfo.name = self:getPetName(pet.id)
	petInfo.iconName = pData.iconName
	petInfo.maxHp = 100
	petInfo.id = pet.id
	petInfo.label = pet.label
	petInfo.isBoss = Utils.isLabelElite(pet.label)
	petInfo.isMini = Utils.isLabelRainbow(pet.label)
	petInfo.isShiny = Utils.isLabelShiny(pet.label)
	petInfo.isDark = Utils.isLabelDark(pet.label)
	petInfo.isVariant = Utils.isLabelVariant(pet.label)
	petInfo.race = pData.species
	petInfo.nature = pet.nature and PetNatureData[pet.nature] and PetNatureData[pet.nature].name

	local curLv = pet.level

	if type(curLv) == "string" then
		curLv = 0
	end

	curLv = curLv + 1

	local level = math.min(curLv, table.maxn(PetLevelData))

	petInfo.maxExp = PetLevelData[level] and PetLevelData[level].needExp or 0

	local prototypeData = PetPrototypeData[pet.templateId]
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.elementType = pData.elementType
	petInfo.mainElementType = pData.mainElementType
	petInfo.time = pet.time
	petInfo.level = string.format("%s %s", pg.getGameString("LEVEL"), pet.level)
	petInfo.templateId = pet.templateId
	petInfo.isFavorite = pet.isFavorite
	petInfo.customName = pet.customName
	petInfo.fetter = pet.fetter
	petInfo.height = pet.height
	petInfo.weight = pet.weight
	petInfo.templateId = pet.templateId
	petInfo.canEvolve = pet.canEvolveAny and pet:canEvolveAny() or false
	petInfo.exploreSkillsLevel = {
		canClimb = pData.canClimb ~= nil and pData.canClimb or nil,
		canGlide = pData.canGlide ~= nil and pData.canGlide or nil,
		canSwim = pData.canSwim ~= nil and pData.canSwim or nil
	}
	petInfo.climbLevel = petInfo.exploreSkillsLevel.canClimb or 0
	petInfo.glideLevel = petInfo.exploreSkillsLevel.canGlide or 0
	petInfo.swimLevel = petInfo.exploreSkillsLevel.canSwim or 0

	local num = 999

	if PetResearchIdToNumber[pet.templateId] then
		num = PetResearchIdToNumber[pet.templateId]
	end

	petInfo.bookNum = num
	petInfo.ethnicGroup = pData.ethnicGroup

	local controlFeatureId = petInfo.characterInfo.curCharacter
	local featureInfo = PetCharacterData[controlFeatureId]

	if featureInfo then
		petInfo.featureInfo = {
			rare = featureInfo.rare or 0,
			desc = pg.getLocalizationText(featureInfo.desc),
			name = pg.getLocalizationText(featureInfo.name),
			icon = featureInfo.icon,
			characterId = controlFeatureId
		}
	else
		petInfo.featureInfo = featureInfo
	end

	petInfo.breedRemains = PetBallConfigData.canBreedingTimes - (pet.breedCount or 0)
	petInfo.breedCountMax = PetBallConfigData.canBreedingTimes
	petInfo.breedTalent = {}

	local talentList = petInfo.talentList

	for i = 1, #talentList do
		local talentTemplateId = talentList[i].templateId

		if talentTemplateId and PetTalentData[talentTemplateId] then
			local name = PetTalentData[talentTemplateId].talentName
			local icon = PetTalentData[talentTemplateId].talentIcon
			local quality = PetTalentData[talentTemplateId].rarity
			local id = talentTemplateId
			local group = PetTalentData[talentTemplateId].group
			local desc = PetTalentData[talentTemplateId].dec
			local homeDesc = PetTalentData[talentTemplateId].homeDesc

			petInfo.breedTalent[#petInfo.breedTalent + 1] = {
				name = name,
				icon = icon,
				quality = quality,
				id = id,
				group = group,
				desc = desc,
				homeDesc = homeDesc
			}
		end
	end

	table.sort(petInfo.breedTalent, function(a, b)
		return a.id < b.id
	end)

	local baseProperty = pet.basePropertyList

	local function getTotal(index)
		return baseProperty.getTotal and baseProperty:getTotal(index) or baseProperty[index].total
	end

	petInfo.props = {
		{
			title = pg.getGameString("ATTRIBUTE_HP_SIMPLE"),
			value = getTotal(Const.BASE_PROPERTY_HP_IDX)
		},
		{
			title = pg.getGameString("ATTRIBUTE_ATTACK"),
			value = getTotal(Const.BASE_PROPERTY_ATK_IDX)
		},
		{
			title = pg.getGameString("ATTRIBUTE_DEFINE"),
			value = getTotal(Const.BASE_PROPERTY_DEF_IDX)
		},
		{
			title = pg.getGameString("ATTRIBUTE_NAT"),
			value = getTotal(Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX)
		},
		{
			title = pg.getGameString("ATTRIBUTE_SP_DEFINE"),
			value = getTotal(Const.BASE_PROPERTY_DEF_MAG_IDX)
		},
		{
			title = pg.getGameString("ATTRIBUTE_SP_ATTACK"),
			value = getTotal(Const.BASE_PROPERTY_ATK_MAG_IDX)
		}
	}

	return petInfo
end

function PetFertilityIncubateModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pg.getLocalizationText(pet.customName)
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return pg.getLocalizationText(name)
end

return PetFertilityIncubateModel
