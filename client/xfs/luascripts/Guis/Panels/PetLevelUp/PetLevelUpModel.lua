-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetLevelUp\\PetLevelUpModel.lua

local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local Class = require("Core.Framework.Class")
local PetLevelUpModel = Class.LightClass("PetLevelUpModel", UIModel)

function PetLevelUpModel:getPetName(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		return pet.customName
	end

	local pData = PetData[pet.templateId] or {}
	local name = pData.name

	return name
end

function PetLevelUpModel:getPetIcon(petId)
	local pet = pg.me:getPetInfo(petId)
	local pData = PetData[pet.templateId] or {}

	return LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON, pet.label, pet.gender)
end

return PetLevelUpModel
