-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityRule\\PetFertilityRuleModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetFertilityRuleModel = Class.LightClass("PetFertilityRuleModel", UIModel)

function PetFertilityRuleModel:getRulesData()
	local result = {}

	for i = 1, 4 do
		result[i] = {}
		result[i].pictures = {}
		result[i].title = nil
		result[i].desc = pg.getGameString(string.format("FERTILITY_RULE_DESC%s", i))
	end

	return result
end

return PetFertilityRuleModel
