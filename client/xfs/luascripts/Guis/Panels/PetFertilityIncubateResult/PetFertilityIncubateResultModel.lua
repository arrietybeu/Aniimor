-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityIncubateResult\\PetFertilityIncubateResultModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetData = require("Data.pet_data")
local PetFertilityIncubateResultModel = Class.LightClass("PetFertilityIncubateResultModel", UIModel)

function PetFertilityIncubateResultModel:setUpPetInfo(pet)
	return pg.global.ui.PetFertilityIncubate.model:setUpPetInfo(pet)
end

function PetFertilityIncubateResultModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pg.getLocalizationText(pet.customName)
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return pg.getLocalizationText(name)
end

return PetFertilityIncubateResultModel
