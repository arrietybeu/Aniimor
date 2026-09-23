-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AbilityLevelTemplate.lua

local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local AbilityLevelTemplate = Class.LiteClass("AbilityLevelTemplate")

function AbilityLevelTemplate:init(abilityManager, id, baseTemplate, level)
	for k, v in pairs(baseTemplate) do
		self[k] = v
	end

	self.id = id
	self.level = level

	for _, levelCurveKey in ipairs(AbilityConst.LEVEL_CURVE_TYPES) do
		local newCurve = abilityManager:getCurve(self.id, levelCurveKey, baseTemplate[levelCurveKey])

		self[levelCurveKey] = newCurve ~= nil and newCurve:getVal(level) or 0
	end

	self.subAbilityIds = {}

	if baseTemplate.subAbilityIds ~= nil then
		for idx, subAbilityId in ipairs(baseTemplate.subAbilityIds) do
			self.subAbilityIds[idx] = subAbilityId
		end
	end
end

function AbilityLevelTemplate:getSubAbilityIds()
	return self.subAbilityIds
end

return AbilityLevelTemplate
