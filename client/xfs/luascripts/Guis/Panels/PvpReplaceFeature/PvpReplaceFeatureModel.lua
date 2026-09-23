-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReplaceFeature\\PvpReplaceFeatureModel.lua

local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetCharacterData = require("Data.pet_character_data")
local Class = require("Core.Framework.Class")
local PvpReplaceFeatureModel = Class.LightClass("PvpReplaceFeatureModel", UIModel)

function PvpReplaceFeatureModel:getAllFeatures(templateId)
	local validMap = Utils.pvpGetValidFeatureMap(templateId)
	local result = {}

	for k, v in pairs(validMap) do
		if v == true then
			local t = {}

			t.featureData = PetCharacterData[k]
			t.featureId = k
			result[#result + 1] = t
		end
	end

	return result
end

return PvpReplaceFeatureModel
