-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolution\\PetEvolutionModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetEvolutionModel")
local Utils = require("Common.Utils.Utils")
local ElementNameToId = require("Data.element_name_to_id")
local Class = require("Core.Framework.Class")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetNatureData = require("Data.pet_nature_data")
local PetLevelData = require("Data.pet_level_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local UIModel = require("Guis.UIModel")
local PetEvolutionModel = Class.LightClass("PetEvolutionModel", UIModel)

function PetEvolutionModel:ctor()
	self.petMaxLevel = table.maxn(PetLevelData)
end

function PetEvolutionModel:setUpPetInfo(petId)
	local pet = pg.me:getPetInfo(petId)
	local petInfo = {}

	petInfo.isEmpty = pet == nil

	if petInfo.isEmpty then
		return petInfo
	end

	petInfo = pet:getRawTable()

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
	petInfo.isDark = Utils.isLabelDark(pet.label)
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

function PetEvolutionModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return name
end

function PetEvolutionModel:getCpValue(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet and pet:getCpValue() or 0
end

function PetEvolutionModel:getCurMaxExp(level)
	return PetLevelData[math.min(level + 1, self.petMaxLevel)].needExp
end

function PetEvolutionModel:getSinglePetInfo(petId)
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

function PetEvolutionModel:getRequiredItems(itemConditions)
	return pg.global.ui.petTrainingNew.model:getRequiredItems(itemConditions)
end

return PetEvolutionModel
