-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityHatchResult\\PetFertilityHatchResultModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetNatureData = require("Data.pet_nature_data")
local PetData = require("Data.pet_data")
local ElementNameToId = require("Data.element_name_to_id")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local PetLevelData = require("Data.pet_level_data")
local PetTalentData = require("Data.pet_talent_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local PetCharacterData = require("Data.pet_character_data")
local PetFertilityHatchResultModel = Class.LightClass("PetFertilityHatchResultModel", UIModel)

function PetFertilityHatchResultModel:setUpPetInfo(pet)
	local petInfo = {}

	petInfo.empty = pet == nil

	if petInfo.empty then
		return petInfo
	end

	petInfo = pet:getRawTable()

	local pData = PetData[pet.templateId] or {}

	petInfo.gender = pet.gender
	petInfo.name = self:getPetName(pet.id)
	petInfo.iconName = pData.iconName
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
	petInfo.maxExp = PetLevelData[math.min(pet.level + 1, table.maxn(PetLevelData))].needExp

	local prototypeData = PetPrototypeData[pet.templateId]
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.elementType = pData.elementType
	petInfo.time = pet.time
	petInfo.level = string.format("%s %s", pg.getGameString("LEVEL"), pet.level)
	petInfo.templateId = pet.templateId
	petInfo.isFavorite = pet.isFavorite
	petInfo.customName = pet.customName
	petInfo.fetter = pet.fetter
	petInfo.height = pet.height
	petInfo.weight = pet.weight
	petInfo.templateId = pet.templateId
	petInfo.canEvolve = pet:canEvolveAny()
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

	petInfo.breedRemains = PetBallConfigData.canBreedingTimes - pet.breedCount
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

function PetFertilityHatchResultModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pg.getLocalizationText(pet.customName)
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return pg.getLocalizationText(name)
end

return PetFertilityHatchResultModel
