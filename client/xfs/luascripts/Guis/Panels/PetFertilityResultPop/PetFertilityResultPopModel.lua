-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResultPop\\PetFertilityResultPopModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetCharacterData = require("Data.pet_character_data")
local PetFertilityResultPopModel = Class.LightClass("PetFertilityResultPopModel", UIModel)

function PetFertilityResultPopModel:getFeatrueInfo(featureId)
	local result
	local featureInfo = PetCharacterData[featureId]

	if featureInfo then
		result = {
			rare = featureInfo.rare or 0,
			desc = featureInfo.desc,
			name = featureInfo.name,
			icon = featureInfo.icon,
			characterId = featureId
		}
	end

	return result
end

return PetFertilityResultPopModel
