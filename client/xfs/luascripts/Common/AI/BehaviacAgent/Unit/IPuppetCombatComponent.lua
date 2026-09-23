-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPuppetCombatComponent.lua

local class = require("Core.Framework.Class")
local enums = require("Common.AI.Behaviac.Enums")
local AiConst = require("Common.Const.AiConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("IPuppetCombatComponent")
local AIUtils = require("Common.Utils.AIUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local LoggerConst = require("Core.Log.LoggerConst")
local EBTRootState = BaseEnum.EBTRootState
local EBTStatus = enums.EBTStatus
local PuppetData = require("Data.puppet_data")
local math_max = math.max
local math_min = math.min
local math_random = math.random
local IPuppetCombatComponent = class.Component("IPuppetCombatComponent")

function IPuppetCombatComponent:OVERRIDE_getTarget(range)
	local lockActorId = AIUtils.getPuppetTarget(self.ent, range)

	AIUtils.attackTarget(self.ent, lockActorId)

	return self.ent:getAttackTargetActorId()
end

function IPuppetCombatComponent:OVERRIDE_castNormalAtkCombo__resetState(resetStateType)
	self.x_currentSkillId = nil
	self.x_isComboLastHit = nil
	self.x_nextComboIndex = nil
end

function IPuppetCombatComponent:OVERRIDE_castNormalAtkCombo(targetId, maxComboCount, skipBackswing, minComboCount, skipCombo, castAbilitySource)
	local comboSkills = self.ent.normalAtkAbilityList
	local tgtEnt = pg.getEntityByActorId(targetId)

	if not self.x_currentSkillId and self:getRootState() == EBTRootState.ST_Root_Combat and self:getTarget() ~= targetId then
		return EBTStatus.BT_FAILURE
	elseif comboSkills ~= nil and tgtEnt then
		if not self.x_currentSkillId then
			if maxComboCount == nil or maxComboCount <= 0 then
				maxComboCount = #comboSkills
			else
				maxComboCount = math_min(#comboSkills, maxComboCount)
			end

			if minComboCount == nil or minComboCount <= 0 then
				minComboCount = 0
			end

			self.x_nextComboIndex = self.x_nextComboIndex or 1
			self.x_isComboLastHit = self.x_nextComboIndex == maxComboCount or minComboCount < self.x_nextComboIndex and math_random() > 1 - AiConst.COMBO_INTERRUPT_PROB
		end

		if self.x_isComboLastHit then
			return self:castSkill(targetId, comboSkills[self.x_nextComboIndex], false, nil, skipBackswing, castAbilitySource, skipCombo)
		else
			local ret = self:castSkill(targetId, comboSkills[self.x_nextComboIndex], true, nil, skipBackswing, castAbilitySource, skipCombo)

			if ret == EBTStatus.BT_SUCCESS then
				self.x_nextComboIndex = self.x_nextComboIndex + 1
				ret = EBTStatus.BT_RUNNING
			end

			return ret
		end
	end

	return EBTStatus.BT_FAILURE
end

function IPuppetCombatComponent:getPropertyCd(propertyName)
	if propertyName == "fightCd" then
		return self:_getFightCd()
	elseif propertyName == "atkCd" then
		return self:_getAtkCd()
	elseif propertyName == "skillCd" then
		return self:_getSkillCd()
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("Invalid property:", propertyName)
	end

	return 0
end

function IPuppetCombatComponent:_getFightCd()
	local pdd = PuppetData[self.ent.templateId]

	return pdd.fightCdInterval + pdd.hateCoefficient * math_max(self:getHateCount(self:getTarget()) - 1, 1)
end

function IPuppetCombatComponent:_getAtkCd()
	local pdd = PuppetData[self.ent.templateId]

	return pdd.atkCdInterval + pdd.hateCoefficient * math_max(self:getHateCount(self:getTarget()) - 1, 1)
end

function IPuppetCombatComponent:_getSkillCd()
	local pdd = PuppetData[self.ent.templateId]

	return pdd.skillCdInterval + pdd.hateCoefficient * math_max(self:getHateCount(self:getTarget()) - 1, 1)
end

return IPuppetCombatComponent
