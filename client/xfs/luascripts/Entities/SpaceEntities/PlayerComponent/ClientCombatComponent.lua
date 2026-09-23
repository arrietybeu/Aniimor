-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientCombatComponent.lua

local class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local ClientCombatComponent = class.Component("ClientCombatComponent")

function ClientCombatComponent:ctor()
	return
end

function ClientCombatComponent:getSkillIdBySkillType(skillType)
	local skillData = self.curAbilityMap and self.curAbilityMap[skillType]

	if skillData then
		return skillData.abilityId
	end

	return 0
end

function ClientCombatComponent:getSkillInfoBySkillType(skillType)
	local skillInfo = self.curAbilityMap[skillType]

	return skillInfo
end

function ClientCombatComponent:getRealSkillIdBySkillType(skillType)
	local skillInfo = self.curAbilityMap[skillType]
	local skillId = skillInfo and skillInfo.abilityId or 0

	if ToBool(self.switchSkillData[skillId]) then
		skillId = self.switchSkillData[skillId]
	end

	return skillId
end

function ClientCombatComponent:getSkillInfoById(skillId)
	return self.abilityMap[skillId]
end

return ClientCombatComponent
