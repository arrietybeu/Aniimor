-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchSPointsRule\\PetBatchSPointsRuleModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetBatchSPointsRuleModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetBatchSPointsRuleModel = Class.LightClass("PetBatchSPointsRuleModel", UIModel)

function PetBatchSPointsRuleModel:getRules(petId)
	local rules = {}

	for propId, _ in pairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		local newPropAtomAttrCfg = PetManagementUtils.getPetNewSixPropAtomAttrCfg(propId)

		if newPropAtomAttrCfg then
			local newRule = {
				propId = propId,
				propL10nName = pg.getGameString(PetManagementDataHelper.NEW_PROP_NAMES[propId]),
				propIcon = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or "",
				baseGainList = {},
				specialGainList = {}
			}

			newRule.baseGainList = PetManagementUtils.getPetNewPropConvertRuleInfo(propId, 1)
			newRule.specialGainList = PetManagementUtils.getPetNewPropConvertRuleInfo(propId, 5)

			table.insert(rules, newRule)
		end
	end

	table.sort(rules, function(a, b)
		return a.propId < b.propId
	end)

	return rules
end

return PetBatchSPointsRuleModel
