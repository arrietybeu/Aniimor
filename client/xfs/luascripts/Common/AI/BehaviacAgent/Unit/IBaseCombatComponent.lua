-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBaseCombatComponent.lua

local class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local enums = require("Common.AI.Behaviac.Enums")
local EBTStatus = enums.EBTStatus
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AI")
local CalcUtils = require("Common.Utils.CalcUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AIUtils = require("Common.Utils.AIUtils")
local ListPool = require("Common.Container.ListPool")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local TablePool = require("Common.Container.TablePool")
local Const = require("Common.Const.Const")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local Vector3 = Vector3
local BuffTag2Id = require("Common.Data.SkillBPData.buff_tag_group_data").BUFF_TAG_2_ID
local pg = pg
local math_epsilon = math.epsilon
local math_min = math.min
local math_random = math.random
local table_getCount = table.getCount
local table_insert = table.insert
local pairs = pairs
local ipairs = ipairs
local string = string
local IBaseCombatComponent = class.Component("IBaseCombatComponent")

function IBaseCombatComponent:getPosition(actorId)
	if not actorId or actorId == 0 then
		actorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(actorId)

	return ent and ent:getPosition() or Vector3.constZero
end

function IBaseCombatComponent:getPositionY(actorId)
	if not actorId or actorId == 0 then
		actorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(actorId)

	return ent and ent:getPosition()[2] or 0
end

function IBaseCombatComponent:getPositionYRelativeToGround(actorId, height)
	if not actorId or actorId == 0 then
		actorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(actorId)

	if not ent then
		return 0
	end

	local entPos = ent:getPosition()
	local maxDetectDist = -100
	local hitGroundFlag, groundMaterial, groundX, groundY, groundZ = VoxelUtils.verticalRayCast(ent, entPos[1], entPos[2], entPos[3], maxDetectDist)

	if not hitGroundFlag then
		groundY = entPos[2] + maxDetectDist
	end

	return groundY + height
end

function IBaseCombatComponent:getMasterId(actorId)
	if not actorId or actorId == 0 then
		actorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(actorId)

	return ent and ent.masterActorId or 0
end

function IBaseCombatComponent:getTarget()
	return self:OVERRIDE_getTarget() or 0
end

function IBaseCombatComponent:lockTarget(targetActorId, partId)
	AIUtils.attackTarget(self.ent, targetActorId, partId)

	return EBTStatus.BT_SUCCESS
end

function IBaseCombatComponent:getMasterTarget()
	local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)

	if masterEnt then
		local masterLockedActorId = masterEnt:getAttackTargetActorId()
		local lockedEnt = pg.getEntityByActorId(masterLockedActorId)

		if AIUtils.checkEntCanBeEnemy(lockedEnt) then
			return masterLockedActorId
		end
	end

	return self:getTarget()
end

function IBaseCombatComponent:castNormalAtkCombo__resetState(resetStateType)
	self.ent:cancelAbility()

	if self.OVERRIDE_castNormalAtkCombo__resetState then
		self:OVERRIDE_castNormalAtkCombo__resetState(resetStateType)
	end
end

function IBaseCombatComponent:castNormalAtkCombo(targetId, maxComboCount, skipBackswing, minComboCount, skipCombo, castAbilitySource)
	return self.OVERRIDE_castNormalAtkCombo and self:OVERRIDE_castNormalAtkCombo(targetId, maxComboCount, skipBackswing, minComboCount, skipCombo, castAbilitySource) or EBTStatus.BT_FAILURE
end

function IBaseCombatComponent:checkIsInCapture(tgtActorId)
	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt and lockedEnt.isInCapture then
		return true
	end

	return false
end

function IBaseCombatComponent:checkIsDead(tgtActorId)
	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt == nil or lockedEnt and lockedEnt.isDead and lockedEnt:isDead() then
		return true
	end

	return false
end

function IBaseCombatComponent:checkIsFakeDead(tgtActorId)
	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt and lockedEnt.isFakeDead and lockedEnt:isFakeDead() then
		return true
	end

	return false
end

function IBaseCombatComponent:checkIsBreakST(tgtActorId)
	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt and lockedEnt:inBreak() then
		return true
	end

	return false
end

function IBaseCombatComponent:checkIsChargeSkill(tgtActorId, skillId)
	tgtActorId = tgtActorId == 0 and self.ent.actorId or tgtActorId

	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt and lockedEnt.chargeMap then
		return lockedEnt.chargeMap[skillId] ~= nil
	end

	return false
end

function IBaseCombatComponent:checkIsTrapped(tgtActorId)
	local lockedEnt = pg.getEntityByActorId(tgtActorId)

	if lockedEnt and lockedEnt.isTrapped then
		return true
	end

	return false
end

function IBaseCombatComponent:checkIsCamouflage(tgtActorId)
	tgtActorId = tgtActorId == 0 and self.ent.actorId or tgtActorId

	local targetEnt = pg.getEntityByActorId(tgtActorId)

	if targetEnt then
		return targetEnt:CAMOUFLAGE_ST()
	end

	return false
end

function IBaseCombatComponent:checkDontCombat(tgtActorId)
	return self:checkIsTrapped(tgtActorId) or self:checkIsInCapture(tgtActorId) or self:checkIsDead(tgtActorId) or self:checkIsFakeDead(tgtActorId) or self:checkIsBreakST(tgtActorId)
end

function IBaseCombatComponent:getHateCount(tgtActorId)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	if tgtEnt and tgtEnt.getHatred then
		return table_getCount(tgtEnt:getHatred())
	end

	return 0
end

function IBaseCombatComponent:isInCombat(targetActorId)
	local targetEnt = targetActorId and pg.getEntityByActorId(targetActorId) or self.ent

	return targetEnt and targetEnt.isInCombat and targetEnt:isInCombat()
end

function IBaseCombatComponent:checkIsBossAI()
	return self:getBlackBoardProperty("isBossAI") or false
end

function IBaseCombatComponent:checkCanCombat()
	return not self:getBlackBoardProperty("canNotCombat")
end

function IBaseCombatComponent:isInSkill(tgtActorId, skillId)
	tgtActorId = tgtActorId == 0 and self.ent.actorId or tgtActorId

	local ent = pg.getEntityByActorId(tgtActorId)

	if skillId == 0 then
		return ent and ent.SKILL_ST and ent:SKILL_ST()
	else
		return ent and ent.isCastingAbility and ent:isCastingAbility(skillId)
	end

	return false
end

function IBaseCombatComponent:isInUltimateSkill(tgtActorId)
	tgtActorId = tgtActorId == 0 and self.ent.actorId or tgtActorId

	local ent = pg.getEntityByActorId(tgtActorId)

	if ent and ent.getSkillIdByType and ent.isCastingAbility then
		local skillId = ent:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)

		return ent:isCastingAbility(skillId)
	end

	return false
end

function IBaseCombatComponent:getHpPercent(tgtActorId)
	local tgtEnt

	if tgtActorId == nil or tgtActorId == 0 then
		tgtEnt = self.ent
	else
		tgtEnt = pg.getEntityByActorId(tgtActorId)
	end

	return tgtEnt == nil and 0 or tgtEnt.actorCombatAttribute:getHpRatio()
end

function IBaseCombatComponent:getEp(tgtActorId)
	if tgtActorId == nil or tgtActorId == 0 then
		tgtActorId = self.ent.actorId
	end

	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	return tgtEnt == nil and 0 or tgtEnt.actorCombatAttribute:getEp()
end

function IBaseCombatComponent:getSp(tgtActorId)
	if tgtActorId == nil or tgtActorId == 0 then
		tgtActorId = self.ent.actorId
	end

	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	return tgtEnt == nil and 0 or tgtEnt.actorCombatAttribute:getSp()
end

function IBaseCombatComponent:getBreakPercent(tgtActorId)
	if tgtActorId == nil or tgtActorId == 0 then
		tgtActorId = self.ent.actorId
	end

	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	return tgtEnt == nil and 0 or tgtEnt.actorCombatAttribute:getBPPercent()
end

function IBaseCombatComponent:checkAbilityInFeatures(skillId, featureId)
	return AbilityUtils.checkAbilityInFeatures(skillId, featureId)
end

function IBaseCombatComponent:getSkillIdByFeature(featureId, excludeUltimate, excludeSkillID, useAIWeight, actorId, checkCd, checkEp)
	local skillId = 0
	local targetEnt = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	if targetEnt then
		for tSkillId, _ in pairs(AbilityUtils.getAbilityMap(targetEnt, excludeUltimate)) do
			if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId, useAIWeight) and tSkillId ~= excludeSkillID and (not checkCd or AbilityUtils.checkAbilityNotInCd(tSkillId, targetEnt)) and (not checkEp or AbilityUtils.checkCanUseSkillByCost(tSkillId, targetEnt, true)) then
				if skillId == 0 then
					skillId = tSkillId
				elseif math_random(0, 1) > 0.5 then
					skillId = tSkillId
				end
			end
		end
	end

	return skillId
end

function IBaseCombatComponent:getUltimateSkillId()
	return self.ent:getSkillIdByType(AbilityConst.ULTIMATE_ABILITY)
end

function IBaseCombatComponent:getQSkillId()
	return self.ent:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY)
end

function IBaseCombatComponent:getESkillId()
	return self.ent:getSkillIdByType(AbilityConst.WEAPON_SKILL_ABILITY2)
end

function IBaseCombatComponent:checkAbilityIsCharge(skillId)
	local skill = self.ent:getAbility(skillId)

	if not skill then
		return false
	end

	return skill:getAbilityTemplate().isCharge or false
end

function IBaseCombatComponent:getBestAttackSkill(targetEntActorid, featureId)
	local targetEnt = pg.getEntityByActorId(targetEntActorid)

	if targetEnt == nil then
		return 0
	end

	local selectSkillId, cost = 0, 0

	for skillId, tAbility in pairs(AbilityUtils.getAbilityMap(targetEnt, true)) do
		if not tAbility.isSubAbility and tAbility:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Skill and tAbility.epCost > math_epsilon and (featureId == nil or AbilityUtils.checkAbilityInFeatures(skillId, featureId) and AbilityUtils.checkAbilityNotInCd(skillId, self.ent) and AbilityUtils.checkCanUseSkillByCost(skillId, self.ent, true)) then
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)
			local attributeRestraint = Utils.getElementAgainstValue(abilityParamData.elementType, targetEnt.elementTypes, self.ent, targetEnt)
			local power = AbilityUtils.getAbilityParamPower(abilityParamData, self.ent)
			local powerTick = abilityParamData.powerTick or 1
			local tCost = attributeRestraint * power * powerTick / tAbility.epCost

			if cost < tCost then
				selectSkillId = skillId
				cost = tCost
			elseif cost == tCost and math_random(0, 1) > 0.5 then
				selectSkillId = skillId
			end
		end
	end

	return selectSkillId
end

function IBaseCombatComponent:getBestAttackSkillByFeature(targetEntActorid, featureId)
	return self:getBestAttackSkill(targetEntActorid, featureId)
end

function IBaseCombatComponent:checkTargetInSKillDist(targetActorId, skillId)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if not tgtEnt then
		return false
	end

	return AbilityUtils.checkTargetSearchRange(pg.global.abilityMgr:getAbilityTemplate(skillId), self.ent:getPosition(), tgtEnt:getPosition(), tgtEnt.bodySize, tgtEnt and tgtEnt.getRealHeight and tgtEnt:getRealHeight() or 0, true)
end

function IBaseCombatComponent:getSkill2DRadius(skillId)
	return pg.global.abilityMgr:getAbilityTemplate(skillId).searchTargetRangeRadius or AiConst.TARGET_POINT_STOP_DIST
end

function IBaseCombatComponent:checkCanUseSkillByCost(skillId)
	return AbilityUtils.checkCanUseSkillByCost(skillId, self.ent, true)
end

function IBaseCombatComponent:isInAbility()
	return self.ent:ABILITY_ST()
end

function IBaseCombatComponent:castSkill__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.resume or resetStateType == AiConst.ResetStateType.pause then
		if not AbilityUtils.isUltimateAbility(self.x_currentSkillId) then
			self.ent:cancelAbility()

			self.x_currentSkillId = nil
		end
	else
		self.ent:cancelAbility()

		self.x_currentSkillId = nil
	end
end

function IBaseCombatComponent:castSkill(targetId, skillId, needCombo, partId, skipBackswing, castSource, skipCombo)
	local ret = EBTStatus.BT_FAILURE
	local me = self.ent

	if not self.x_currentSkillId then
		local tgtEnt, castResult, errMsg

		if targetId ~= nil and targetId ~= 0 then
			tgtEnt = pg.getEntityByActorId(targetId)

			if tgtEnt == nil then
				if AIUtils.checkDebugEnt(self.ent.actorId) and LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:log2Tag("AI", "castSkill fail, target is nil", targetId)
				end

				return EBTStatus.BT_FAILURE
			end

			castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(self.ent, skillId, tgtEnt.actorId, partId, castSource)
		else
			castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityNoTarget(self.ent, skillId, castSource)
		end

		if not castResult then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:log2Tag("AI", "castSkill fail errCode: actorId:", self.ent.actorId, ",templateId:", self.ent.templateId, ",skillId：", skillId, ",errMsg:", AbilityConst.ABILITY_CAST_FAILED_REASONS[errMsg])
			end

			ret = EBTStatus.BT_FAILURE
		else
			self.x_currentSkillId = skillId
			ret = EBTStatus.BT_RUNNING
		end
	elseif me:ABILITY_ST() then
		if me:BACKSWING_ST() and skipBackswing then
			self.x_currentSkillId = nil
			ret = EBTStatus.BT_SUCCESS
		elseif me:COMBO_ST() and skipCombo then
			self.x_currentSkillId = nil
			ret = EBTStatus.BT_SUCCESS
		else
			ret = EBTStatus.BT_RUNNING
		end
	else
		self.x_currentSkillId = nil
		ret = EBTStatus.BT_SUCCESS
	end

	return ret
end

function IBaseCombatComponent:castChargetSkill__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.pause then
		self.x_castChargeSkillState = AiConst.CHARGE_SKILL_STATE.Uncharged
	else
		self.x_castChargeSkillState = nil
	end

	self:_removeCustomTimeout("castChargeSkill")

	self.x_castChargeSkillId = nil

	self.ent:cancelAbility()
end

function IBaseCombatComponent:castChargetSkill(targetActorId, chargeSkillId, chargeTime, partId, skipBackswing, autoCast, castSource)
	if self.x_castChargeSkillState == AiConst.CHARGE_SKILL_STATE.Uncharged then
		self.x_castChargeSkillId = chargeSkillId

		self.ent:startChargeByAbilityId(chargeSkillId)

		local castResult, errMsg

		if pg.getEntityByActorId(targetActorId) then
			castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(self.ent, chargeSkillId, targetActorId, partId, castSource)
		else
			castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityNoTarget(self.ent, chargeSkillId, castSource)
		end

		if not castResult then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:log2Tag("AI", "castSkill fail errCode: actorId:", self.ent.actorId, ",templateId:", self.ent.templateId, ",chargeSkillId：", chargeSkillId, ",errMsg:", AbilityConst.ABILITY_CAST_FAILED_REASONS[errMsg])
			end

			return EBTStatus.BT_FAILURE
		end

		self.x_castChargeSkillState = AiConst.CHARGE_SKILL_STATE.initCharged
	end

	if self.x_castChargeSkillState == AiConst.CHARGE_SKILL_STATE.initCharged and self.ent.maxChargeTime and self.ent.maxChargeTime[1] == chargeSkillId then
		self.x_castChargeSkillState = AiConst.CHARGE_SKILL_STATE.Charge
		chargeTime = math_min(chargeTime, self.ent.maxChargeTime[2])
	end

	if autoCast == nil then
		autoCast = true
	end

	if autoCast and self.x_castChargeSkillState == AiConst.CHARGE_SKILL_STATE.Charge then
		if not self:_checkAndSetCustomTimeout("castChargeSkill", chargeTime) then
			return EBTStatus.BT_RUNNING
		else
			self.ent:stopChargeByAbilityId(chargeSkillId)

			self.x_castChargeSkillState = AiConst.CHARGE_SKILL_STATE.Skill
		end
	end

	if self.ent:ABILITY_ST() then
		if self.ent:BACKSWING_ST() and skipBackswing then
			return EBTStatus.BT_SUCCESS
		end

		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IBaseCombatComponent:castCombo__resetState(resetStateType)
	self.x_currentCastComboIndex = nil
	self.x_interruptCastComboFlag = nil

	self.ent:cancelAbility()
end

function IBaseCombatComponent:castCombo(tgtActorId, abilityId, maxCombo, interruptRate, partId, skipBackswing, castSource)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	if self.ent:ATTACK_ST() then
		if not self.x_interruptCastComboFlag and self.ent:inCombo() then
			local nextComboTimeline = self.ent.nextComboTimeline
			local probability = lume.random(0, 1)

			if probability < interruptRate or maxCombo <= self.x_currentCastComboIndex and maxCombo ~= 0 or not nextComboTimeline and #self.ent.normalAtkAbilityList == 1 or #self.ent.normalAtkAbilityList > 1 and #self.ent.normalAtkAbilityList < self.x_currentCastComboIndex then
				self.x_interruptCastComboFlag = true
			elseif not nextComboTimeline or abilityId == 0 and #self.ent.normalAtkAbilityList > 1 then
				local castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(self.ent, self.ent.normalAtkAbilityList[self.x_currentCastComboIndex + 1], tgtActorId, partId, castSource)

				if not castResult then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:log2Tag("AI", "castSkill fail errCode: actorId:", self.ent.actorId, ",templateId:", self.ent.templateId, ",abilityId：", abilityId, ",errMsg:", AbilityConst.ABILITY_CAST_FAILED_REASONS[errMsg])
					end
				else
					self.x_currentCastComboIndex = self.x_currentCastComboIndex + 1
				end
			else
				local timelineId = pg.global.abilityMgr.combatAction:getVal(nextComboTimeline[2], nextComboTimeline[3])

				if Utils.checkClient() then
					self.ent:serverMsg("RPC_CS_JumpToNextTimeline", nextComboTimeline[1].layer, nextComboTimeline[1].timelineId, timelineId)
				end

				nextComboTimeline[1]:continueTimeline(timelineId)

				self.x_currentCastComboIndex = self.x_currentCastComboIndex + 1
			end
		end

		if self.x_interruptCastComboFlag and skipBackswing and self.ent:BACKSWING_ST() then
			return EBTStatus.BT_SUCCESS
		end

		return EBTStatus.BT_RUNNING
	elseif self.ent:SKILL_ST() then
		if self.ent:BACKSWING_ST() and AbilityUtils.hasAbilityTag(abilityId, AbilityConst.ABILITY_PARAM_TAG_COMBO2) then
			local probability = lume.random(0, 1)

			if probability < interruptRate or maxCombo <= self.x_currentCastComboIndex and maxCombo ~= 0 then
				self.x_interruptCastComboFlag = true
			else
				local castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(self.ent, abilityId, tgtActorId, partId, castSource)

				if not castResult and LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:log2Tag("AI", "castSkill fail errCode: actorId:", self.ent.actorId, ",templateId:", self.ent.templateId, ",abilityId：", abilityId, ",errMsg:", AbilityConst.ABILITY_CAST_FAILED_REASONS[errMsg])
				else
					self.x_currentCastComboIndex = self.x_currentCastComboIndex + 1
				end
			end

			if self.x_interruptCastComboFlag and skipBackswing and self.ent:BACKSWING_ST() then
				return EBTStatus.BT_SUCCESS
			end
		end

		return EBTStatus.BT_RUNNING
	end

	if not AIUtils.checkEntCanBeUseSkill(tgtEnt) then
		if not self.x_currentCastComboIndex then
			return EBTStatus.BT_FAILURE
		end

		return EBTStatus.BT_SUCCESS
	end

	if not self.x_currentCastComboIndex then
		local currentCastComboAbilityId = abilityId == 0 and self.ent.normalAtkAbilityList[1] or abilityId
		local castResult, errMsg = AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(self.ent, currentCastComboAbilityId, tgtActorId, partId, castSource)

		if not castResult then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:log2Tag("AI", "castSkill fail errCode: actorId:", self.ent.actorId, ",templateId:", self.ent.templateId, ",abilityId：", currentCastComboAbilityId, ",errMsg:", AbilityConst.ABILITY_CAST_FAILED_REASONS[errMsg])
			end

			return EBTStatus.BT_FAILURE
		end

		self.x_currentCastComboIndex = 1

		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IBaseCombatComponent:randomCastSkill__resetState(resetStateType)
	self:castSkill__resetState(resetStateType)

	if resetStateType == AiConst.ResetStateType.enter then
		local tbSelectedSkills = ListPool.getList()

		for skillId, tAbility in pairs(AbilityUtils.getAbilityMap(self.ent, true)) do
			if not tAbility.isSubAbility and tAbility:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Skill and AbilityUtils.checkCanUseSkillByCost(skillId, self.ent, true) and AbilityUtils.checkAbilityNotInCd(skillId, self.ent) then
				table_insert(tbSelectedSkills, skillId)
			end
		end

		if #tbSelectedSkills == 0 then
			return
		end

		local randomIndex = math_random(1, #tbSelectedSkills)

		self.x_tRandomSkillId = tbSelectedSkills[randomIndex]

		ListPool.returnList(tbSelectedSkills)
	else
		self.x_tRandomSkillId = nil
	end

	self.ent:cancelAbility()
end

function IBaseCombatComponent:randomCastSkill(targetId)
	if self.x_tRandomSkillId == nil then
		return EBTStatus.BT_FAILURE
	end

	return self:castSkill(targetId, self.x_tRandomSkillId, false)
end

function IBaseCombatComponent:selectSkillByWeight(targetId)
	local ent = pg.getEntityByActorId(targetId)

	if not ent then
		return 0
	end

	local targetElementTypes = ent.elementTypes
	local maxFactor = 0
	local tbSelectedSkills = ListPool.getList()
	local abilityMap = AbilityUtils.getAbilityMap(ent, true)

	for skillId, tAbility in pairs(abilityMap) do
		if not tAbility.isSubAbility and AbilityUtils.checkCanUseSkillByCost(skillId, self.ent, true) and AbilityUtils.checkAbilityNotInCd(skillId, self.ent) then
			local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(skillId)
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)
			local weight = abilityTemplate.aiSelectWeight or 0

			if weight > 0 then
				local srcElementType = abilityParamData.elementType or 0
				local factor = Utils.getElementAgainstValue(srcElementType, targetElementTypes, self.ent, ent) * weight

				if maxFactor < factor then
					maxFactor = factor

					table.clearArray(tbSelectedSkills)

					tbSelectedSkills[#tbSelectedSkills + 1] = skillId
				elseif factor == maxFactor then
					tbSelectedSkills[#tbSelectedSkills + 1] = skillId
				end
			end
		end
	end

	local len = #tbSelectedSkills
	local ret = len > 0 and math_random(1, len) or 0

	ListPool.returnList(tbSelectedSkills)

	return ret
end

function IBaseCombatComponent:checkCanUseSkill(tgtActorId, skillId)
	if tgtActorId == nil or tgtActorId == 0 then
		tgtActorId = self.ent.actorId
	end

	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	return tgtEnt ~= nil and not tgtEnt:isDead() and AbilityUtils.checkCanUseSkillByCost(skillId, self.ent, true) and AbilityUtils.checkAbilityNotInCd(skillId, self.ent)
end

function IBaseCombatComponent:checkSkillNotInCd(skillId, tgtActorId)
	local ent = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)

	return AbilityUtils.checkAbilityNotInCd(skillId, ent)
end

function IBaseCombatComponent:checkSkillCanCast(tgtActorId, skillId, castAbilitySource)
	if tgtActorId == nil or tgtActorId == 0 then
		tgtActorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(tgtActorId)

	if ent and ent.agent then
		castAbilitySource = castAbilitySource or AbilityConst.CAST_SOURCE.NORMAL

		local result, _ = ent:checkCanCastAbilityNoTarget(skillId, castAbilitySource)

		return result
	end

	return false
end

function IBaseCombatComponent:CheckTargetHasBuff(tgtActorId, buffTag)
	local tgtEnt = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)
	local actorBuff = tgtEnt and tgtEnt.actorBuff

	return actorBuff and actorBuff:hasTag(buffTag) or false
end

function IBaseCombatComponent:checkTargetHasBuffTag(tgtActorId, buffTag)
	local tgtEnt = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)
	local actorBuff = tgtEnt and tgtEnt.actorBuff

	return actorBuff and actorBuff:hasTag(BuffTag2Id[buffTag]) or false
end

function IBaseCombatComponent:checkTargetHasBuffFromSource(tgtActorId, buffTag, sourceActorId)
	local buffTagId = BuffTag2Id[buffTag]
	local tgtEnt = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)
	local actorBuff = tgtEnt and tgtEnt.actorBuff

	if actorBuff then
		sourceActorId = sourceActorId == 0 and self.ent.actorId or sourceActorId

		return actorBuff:hasSourceTag(buffTagId, sourceActorId)
	end

	return false
end

function IBaseCombatComponent:checkTargetHasBuffById(tgtActorId, buffId, layerCount)
	local tgtEnt = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)
	local actorBuff = tgtEnt and tgtEnt.actorBuff

	if actorBuff then
		local buff = actorBuff:findOneBuffByTemplateId(buffId)

		return buff and buff.buffData.layer == layerCount or false
	end

	return false
end

function IBaseCombatComponent:getTargetBuffLayerCount(tgtActorId, buffId)
	local tgtEnt = tgtActorId == 0 and self.ent or pg.getEntityByActorId(tgtActorId)
	local actorBuff = tgtEnt and tgtEnt.actorBuff

	if actorBuff then
		local buff = actorBuff:findOneBuffByTemplateId(buffId)

		return buff and buff.buffData.layer or 0
	end

	return 0
end

function IBaseCombatComponent:combatDodge__resetState(resetStateType)
	self.x_combatDodge_flag = nil

	self:_removeCustomTimeout("combatDodge")
	self:dash__resetState(resetStateType)
end

function IBaseCombatComponent:combatDodge(tgtActorId)
	if self.x_combatDodge_flag == nil then
		self.x_combatDodge_flag = true

		local targetEnt = pg.getEntityByActorId(tgtActorId)

		if not targetEnt then
			return EBTStatus.BT_FAILURE
		end

		local entPos = self.ent:getPosition()
		local enterCombatPosition = targetEnt.enterCombatPosition or self.ent.enterCombatPosition

		if not enterCombatPosition then
			return EBTStatus.BT_FAILURE
		end

		Vector3.enableCreateFromCache()

		local entToCenter = enterCombatPosition - entPos
		local entToTargetDir = Vector3.Normalize(targetEnt:getPosition() - entPos)
		local verticalDir = Vector3(-entToTargetDir.z, entToTargetDir.y, entToTargetDir.x)
		local sign = Vector3.Dot(entToCenter, verticalDir) >= 0 and 1 or -1
		local turnDir = verticalDir * sign

		AIBaseMethodUtils.Base_TurnToDirection(self.ent, turnDir, true)
		Vector3.disableCreateFromCache()
		self:_settingCustomTimeout("combatDodge", AiConst.CombatDodgeMaxTime)
	end

	if self:_checkCustomTimeout("combatDodge") then
		return EBTStatus.BT_SUCCESS
	end

	return self:dash()
end

function IBaseCombatComponent:getOwnerActorId()
	return self.ent:getSummonHost()
end

function IBaseCombatComponent:getTargetEntityMostHatredEntity(targetActorId, range, filterFunc)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if targetEnt then
		if targetEnt.forceLock ~= 0 then
			local targetEnt = pg.getEntityByActorId(targetEnt.forceLock)

			if targetEnt ~= nil then
				return targetEnt.forceLock
			end
		end

		local entId = 0
		local hatredMap = targetEnt:getHatred()
		local maxHateValue = 0

		for id, hateValue in pairs(hatredMap) do
			local targetEnt = pg.getEntityByActorId(id)

			if AIUtils.checkEntCanBeEnemy(targetEnt) then
				local entPos = targetEnt:getPosition()

				if maxHateValue < hateValue and (not filterFunc or filterFunc(targetEnt)) and (not range or range >= 0 or Utils.squareDist(self.ent:getPosition(), entPos) < range * range) then
					maxHateValue = hateValue
					entId = id
				end
			end
		end

		return entId
	end

	return 0
end

function IBaseCombatComponent:getSkillElementType(skillId)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)

	return abilityParamData.elementType
end

function IBaseCombatComponent:getSameTypeSkillId(skillId)
	return skillId
end

function IBaseCombatComponent:getShieldValue(actorId)
	local targetEnt = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	return targetEnt.shieldDataList:getCurPoint(targetEnt)
end

function IBaseCombatComponent:getMaxAttackDist(actorId)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	if ent then
		return ent.maxAttackDist or -1
	end

	return -1
end

function IBaseCombatComponent:getMinAttackDist(actorId)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return -1
	end

	local bodySize = CalcUtils.getBodySize(ent)
	local minDist = self:getBlackBoardProperty("minBoxDist")

	return bodySize + minDist + (self:getMaxAttackDist(actorId) - minDist - bodySize) * 0.2
end

function IBaseCombatComponent:getSkillStopBoxDist(skillId)
	local skill = pg.global.abilityMgr:getAbilityParamData(skillId)

	if not skill then
		return -1
	end

	local minDist = self:getBlackBoardProperty("minBoxDist")
	local maxSkillDist = self:getMaxSkillDist(skillId)

	return minDist + (maxSkillDist - minDist) * 0.6
end

function IBaseCombatComponent:getMaxSkillDist(skillId)
	local scale = self.ent.curModelScale or 1
	local skill = pg.global.abilityMgr:getAbilityParamData(skillId)

	if not skill then
		return -1
	end

	local maxSkillDist = skill.searchTargetRangeRadius or 0

	return maxSkillDist * scale
end

function IBaseCombatComponent:getCreatedPuppetCount(actorId, templateId)
	local targetEnt

	if actorId == 0 then
		targetEnt = self.ent
	else
		targetEnt = pg.getEntityByActorId(actorId)
	end

	if targetEnt and targetEnt.createdPuppetList then
		local count = 0

		for _, tActorId in ipairs(targetEnt.createdPuppetList) do
			local tEnt = pg.getEntityByActorId(tActorId)

			if tEnt and (templateId == 0 or templateId == tEnt.templateId) then
				count = count + 1
			end
		end

		return count
	end

	return 0
end

function IBaseCombatComponent:getCreatedCreationCount(actorId, templateId)
	local targetEnt

	if actorId == 0 then
		targetEnt = self.ent
	else
		targetEnt = pg.getEntityByActorId(actorId)
	end

	if targetEnt and targetEnt.createdCreationList then
		local count = 0

		for _, tActorId in ipairs(targetEnt.createdCreationList) do
			local tEnt = pg.getEntityByActorId(tActorId)

			if tEnt and (templateId == 0 or templateId == tEnt.templateId) then
				count = count + 1
			end
		end

		return count
	end

	return 0
end

function IBaseCombatComponent:selectOneCreatedPuppetList(actorId, templateId)
	local targetEnt

	if actorId == 0 then
		targetEnt = self.ent
	else
		targetEnt = pg.getEntityByActorId(actorId)
	end

	if targetEnt and targetEnt.createdPuppetList then
		local tList = ListPool.getList()

		for _, tActorId in ipairs(targetEnt.createdPuppetList) do
			local tEnt = pg.getEntityByActorId(tActorId)

			if tEnt and (templateId == 0 or templateId == tEnt.templateId) then
				tList[#tList + 1] = tActorId
			end
		end

		local len = #tList
		local retActorId = len > 0 and tList[math_random(1, len)] or 0

		ListPool.returnList(tList)

		return retActorId
	end

	return 0
end

function IBaseCombatComponent:selectOneCreatedCreationList(actorId, templateId)
	local targetEnt

	if actorId == 0 then
		targetEnt = self.ent
	else
		targetEnt = pg.getEntityByActorId(actorId)
	end

	if targetEnt and targetEnt.createdCreationList then
		local tList = ListPool.getList()

		for _, tActorId in ipairs(targetEnt.createdCreationList) do
			local tEnt = pg.getEntityByActorId(tActorId)

			if tEnt and (templateId == 0 or templateId == tEnt.templateId) then
				tList[#tList + 1] = tActorId
			end
		end

		local len = #tList
		local retActorId = len > 0 and tList[math_random(1, len)] or 0

		ListPool.returnList(tList)

		return retActorId
	end

	return 0
end

function IBaseCombatComponent:getInteractEnvObj(tgtActorId)
	return AIUtils.searchInteractEnvObj(tgtActorId)
end

function IBaseCombatComponent:addBuff__resetState(resetStateType)
	self:_removeCustomTimeout("addBuff")
end

function IBaseCombatComponent:addBuff(buffId, duration)
	local buff = self.ent.actorBuff:findOneBuffByTemplateId(buffId)

	if buff then
		return EBTStatus.BT_SUCCESS
	end

	if not self:_checkCustomTimeoutExist("addBuff") then
		self:_settingCustomTimeout("addBuff", AiConst.RequestBuffTimeout)
		AIBaseMethodUtils.Base_AddBuff(self.ent, buffId, duration)
	end

	if self:_checkCustomTimeout("addBuff") then
		return EBTStatus.BT_FAILURE
	end

	return EBTStatus.BT_RUNNING
end

function IBaseCombatComponent:removeBuff__resetState(resetStateType)
	self:_removeCustomTimeout("removeBuff")
end

function IBaseCombatComponent:removeBuff(buffId)
	local buff = self.ent.actorBuff:findOneBuffByTemplateId(buffId)

	if not buff then
		return EBTStatus.BT_SUCCESS
	end

	if not self:_checkCustomTimeoutExist("removeBuff") then
		self:_settingCustomTimeout("removeBuff", AiConst.RequestBuffTimeout)
		AIBaseMethodUtils.Base_RemoveBuff(self.ent, buffId)
	end

	if self:_checkCustomTimeout("removeBuff") then
		return EBTStatus.BT_FAILURE
	end

	return EBTStatus.BT_RUNNING
end

function IBaseCombatComponent:getRangeLowHPTarget(dist, lowHpPercent, relation)
	local targetEnt = self.ent

	if targetEnt.aoi then
		local tmpList = ListPool.getList(3)
		local count = AIUtils.SearchEntitiesInRangeWithTable(targetEnt, dist, Const.SEARCH_USR_TYPE_ACTOR_CREATION, 10, tmpList)

		for i = 1, count do
			local tEntActorId = tmpList[i]

			if tEntActorId ~= targetEnt.actorId and lowHpPercent >= self:getHpPercent(tEntActorId) and Utils.checkRelation(targetEnt, pg.getEntityByActorId(tEntActorId), relation) then
				ListPool.returnList(tmpList)

				return tEntActorId
			end
		end

		ListPool.returnList(tmpList)
	end

	return 0
end

function IBaseCombatComponent:getParmonSkillPlanSubtreePath()
	local skillTree = self.ent:getConfigData().Param_ST_Pet_SkillCombo_SubTree

	return BehaviorPathMapData.EnumNameMap[skillTree] and skillTree or BehaviorPathMapData.EnumMap[BehaviorPathMapData.EnumNameMap.PBT_Noop_Failure]
end

function IBaseCombatComponent:checkLinkSkillCanCast(actorId, featureId1, featureId2)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	local abilityMap = AbilityUtils.getAbilityMap(ent, true)
	local isPet = Utils.isPet(ent)
	local set1, set2 = TablePool.getTable(), TablePool.getTable()

	for tSkillId, _ in pairs(abilityMap or AiConst.DefaultNullTable) do
		if not isPet or AbilityUtils.checkAbilityNotInCd(tSkillId, ent) then
			local tSkillEp = isPet and AbilityUtils.getAbilityEp(tSkillId, ent) or 0

			if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId1) then
				set1[tSkillId] = tSkillEp
			end

			if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId2) then
				set2[tSkillId] = tSkillEp
			end
		end
	end

	local unionCount = 0

	for _ in pairs(set1) do
		unionCount = unionCount + 1
	end

	for tSkillId in pairs(set2) do
		if not set1[tSkillId] then
			unionCount = unionCount + 1
		end
	end

	local result = false

	if next(set1) ~= nil and next(set2) ~= nil and unionCount >= 2 then
		if not isPet then
			result = true
		else
			local currentEp = ent.actorCombatAttribute:getEp()

			for s1, ep1 in pairs(set1) do
				for s2, ep2 in pairs(set2) do
					if s1 ~= s2 and currentEp >= ep1 + ep2 then
						result = true

						break
					end
				end

				if result then
					break
				end
			end
		end
	end

	TablePool.returnTable(set1)
	TablePool.returnTable(set2)

	return result
end

function IBaseCombatComponent:checkLinkSkillExist(actorId, featureId1, featureId2)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	local abilityMap = AbilityUtils.getAbilityMap(ent, true)
	local set1, set2 = TablePool.getTable(), TablePool.getTable()

	for tSkillId, _ in pairs(abilityMap or AiConst.DefaultNullTable) do
		if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId1) then
			set1[tSkillId] = true
		end

		if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId2) then
			set2[tSkillId] = true
		end
	end

	local hasSkill1 = next(set1) ~= nil
	local hasSkill2 = next(set2) ~= nil
	local unionCount = 0

	for _ in pairs(set1) do
		unionCount = unionCount + 1
	end

	for tSkillId in pairs(set2) do
		if not set1[tSkillId] then
			unionCount = unionCount + 1
		end
	end

	TablePool.returnTable(set1)
	TablePool.returnTable(set2)

	return hasSkill1 and hasSkill2 and unionCount >= 2
end

function IBaseCombatComponent:getSkillEP(skillId)
	return AbilityUtils.getAbilityEp(skillId, self.ent)
end

function IBaseCombatComponent:checkSkillExistByFeatureId(actorId, featureId, excludeUltimate)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	local abilityMap = AbilityUtils.getAbilityMap(ent, excludeUltimate)

	for tSkillId, _ in pairs(abilityMap or AiConst.DefaultNullTable) do
		if AbilityUtils.checkAbilityInFeatures(tSkillId, featureId) then
			return true
		end
	end

	return false
end

function IBaseCombatComponent:checkSkillExist(actorId, skillId, excludeUltimate)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	local abilityMap = AbilityUtils.getAbilityMap(ent, excludeUltimate)

	return abilityMap[skillId] ~= nil
end

function IBaseCombatComponent:checkNormalAttackByTags(actorId, tag)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	local skillId = ent.normalAtkAbilityList[1] or 0
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)

	if not abilityParamData then
		return false
	end

	for i = 1, #abilityParamData.tags do
		if abilityParamData.tags[i] == tag then
			return true
		end
	end

	return false
end

function IBaseCombatComponent:checkTargetIsTemplate(actorId, templateId)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return false
	end

	return ent:getTemplateId() == templateId
end

function IBaseCombatComponent:searchRangeCreationCountByTemplateId(actorId, templateId, range, maxSearchCount)
	local ent = (not actorId or actorId == 0) and self.ent or pg.getEntityByActorId(actorId)

	if not ent then
		return 0
	end

	local tmpList = ListPool.getList(3)
	local searchCount = AIUtils.SearchEntitiesInRangeWithTable(ent, range, Const.SEARCH_USR_TYPE_CREATION, maxSearchCount, tmpList)
	local count = 0

	for i = 1, searchCount do
		local tEnt = pg.getEntityByActorId(tmpList[i])

		if tEnt and tEnt:getTemplateId() == templateId then
			count = count + 1
		end
	end

	ListPool.returnList(tmpList, 3)

	return count
end

function IBaseCombatComponent:checkSupportSkillCanCast(playerActorId, supportTag, featureId, checkCD, checkEp)
	local playerEnt = playerActorId == 0 and self.ent or pg.getEntityByActorId(playerActorId)

	if not playerEnt or not Utils.isPlayerOrBotPlayer(playerEnt) then
		return false
	end

	for _, id in ipairs(playerEnt.petPrepareList) do
		local petEnt = pg.getEntity(id)

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) then
			local curPetCoreAbilityId = petEnt.coreAbilityId

			if (string.isNilOrEmpty(supportTag) or AbilityUtils.checkPetHasSupportTag(petEnt, supportTag)) and (featureId < 0 or AbilityUtils.checkAbilityInFeatures(curPetCoreAbilityId, featureId)) and (not checkCD or AbilityUtils.checkAbilityNotInCd(curPetCoreAbilityId, petEnt)) and (not checkEp or AbilityUtils.checkCanUseSkillByCost(curPetCoreAbilityId, petEnt, true)) then
				return true
			end
		end
	end

	return false
end

function IBaseCombatComponent:getCanCastSupportSkillId(playerActorId, supportTag, featureId, checkCD, checkEp)
	local playerEnt = playerActorId == 0 and self.ent or pg.getEntityByActorId(playerActorId)

	if not playerEnt or not Utils.isPlayerOrBotPlayer(playerEnt) then
		return 0
	end

	for _, id in ipairs(playerEnt.petPrepareList) do
		local petEnt = pg.getEntity(id)

		if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) then
			local curPetCoreAbilityId = petEnt.coreAbilityId

			if (string.isNilOrEmpty(supportTag) or AbilityUtils.checkPetHasSupportTag(petEnt, supportTag)) and (featureId < 0 or AbilityUtils.checkAbilityInFeatures(curPetCoreAbilityId, featureId)) and (not checkCD or AbilityUtils.checkAbilityNotInCd(curPetCoreAbilityId, petEnt)) and (not checkEp or AbilityUtils.checkCanUseSkillByCost(curPetCoreAbilityId, petEnt, true)) then
				return curPetCoreAbilityId
			end
		end
	end

	return 0
end

function IBaseCombatComponent:checkIsInBreakRecover(actorId)
	local ent = actorId == 0 and self.ent or pg.getEntityByActorId(actorId)

	return ent and ent:inBreakRecover() or false
end

function IBaseCombatComponent:getEnvSkillTimer(skillId)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(skillId)

	if abilityParamData and abilityParamData.envSkillTimer then
		return abilityParamData.envSkillTimer
	end

	return 0
end

return IBaseCombatComponent
