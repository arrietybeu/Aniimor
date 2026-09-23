-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPetCombatComponent.lua

local class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local enums = require("Common.AI.Behaviac.Enums")
local AIUtils = require("Common.Utils.AIUtils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AI")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local EBTStatus = enums.EBTStatus
local math_min = math.min
local math_random = math.random
local IPetCombatComponent = class.Component("IPetCombatComponent")

function IPetCombatComponent:OVERRIDE_getTarget()
	local lockActorId = self.ent:getAttackTargetActorId()
	local lockedEnt = pg.getEntityByActorId(lockActorId)

	if not AIUtils.checkEntCanBeEnemy(lockedEnt) then
		return self:getNewTargetInCombat(true)
	end

	return Utils.isBotPet(self.ent) and AIUtils.resetCombatTargetPlayerToControllingPet(lockActorId) or lockActorId
end

function IPetCombatComponent:getLetGoTarget()
	local targetActorId = self.ent:getAttackTargetActorId() or 0

	return Utils.isBotPet(self.ent) and AIUtils.resetCombatTargetPlayerToControllingPet(targetActorId) or targetActorId
end

function IPetCombatComponent:getNewTargetInCombat(refreshLockedActorId)
	local tgtActorId = 0

	if Utils.isBotPet(self.ent) then
		tgtActorId = AIUtils.getCombatTargetByHate(self.ent, false, AIUtils.checkEntCanBeEnemy)

		if tgtActorId == 0 then
			tgtActorId = AIUtils.getCombatTargetByBehatredMap(self.ent, nil, AIUtils.checkEntCanBeEnemy)
		end

		if tgtActorId == 0 then
			tgtActorId = AIUtils.getCombatTargetByViewHatredMap(self.ent:getMasterEntity(), AIUtils.checkEntCanBeEnemy)
		end

		tgtActorId = AIUtils.resetCombatTargetPlayerToControllingPet(tgtActorId)
	else
		local petActionMode = self.ent:getMasterEntity().petActionMode

		if petActionMode == Const.PetActionMode.Peace then
			local tCurTargetActorId = self:getLetGoTarget()

			if AIUtils.checkEntCanBeEnemy(pg.getEntityByActorId(tCurTargetActorId)) then
				tgtActorId = tCurTargetActorId
			else
				tgtActorId = AIUtils.getCombatTargetByHate(self.ent, false, AIUtils.checkEntCanBeEnemy)

				if tgtActorId == 0 then
					tgtActorId = AIUtils.getCombatTargetByBehatredMap(self.ent, nil, AIUtils.checkEntCanBeEnemy)
				end
			end
		elseif petActionMode == Const.PetActionMode.Invade then
			local tCurTargetActorId = self:getLetGoTarget()

			if AIUtils.checkEntCanBeEnemy(pg.getEntityByActorId(tCurTargetActorId)) then
				tgtActorId = tCurTargetActorId
			else
				tgtActorId = AIUtils.getCombatTargetByHate(self.ent, false, AIUtils.checkEntCanBeEnemy)

				if tgtActorId == 0 then
					tgtActorId = AIUtils.getCombatTargetByBehatredMap(self.ent, nil, AIUtils.checkEntCanBeEnemy)
				end

				if tgtActorId == 0 then
					tgtActorId = AIUtils.getCombatTargetByMasterAOI(self.ent, AIUtils.checkEntCanBeEnemy)
				end
			end
		elseif petActionMode == Const.PetActionMode.Catch then
			local tCurTargetActorId = self:getLetGoTarget()

			if AIUtils.checkEntCanBeEnemyInCatchMode(pg.getEntityByActorId(tCurTargetActorId)) then
				tgtActorId = tCurTargetActorId
			else
				tgtActorId = AIUtils.getCombatTargetByHate(self.ent, false, AIUtils.checkEntCanBeEnemyInCatchMode)

				if tgtActorId == 0 then
					tgtActorId = AIUtils.getCombatTargetByBehatredMap(self.ent, nil, AIUtils.checkEntCanBeEnemyInCatchMode)
				end
			end
		end
	end

	if refreshLockedActorId then
		AIUtils.attackTarget(self.ent, tgtActorId)
	end

	return tgtActorId
end

function IPetCombatComponent:checkTargetIsLowHpInCatchMode(targetActorId)
	targetActorId = targetActorId ~= 0 and targetActorId or self.ent:getAttackTargetActorId()

	return AIUtils.checkEntCanBeEnemyInCatchMode(pg.getEntityByActorId(targetActorId))
end

function IPetCombatComponent:checkPetActionMode(petActionMode, targetActorId)
	if targetActorId == nil or targetActorId == 0 then
		targetActorId = self.ent.actorId
	end

	local ent = pg.getEntityByActorId(targetActorId)

	if ent and ent.agent and ent.getMasterEntity then
		local master = ent:getMasterEntity()

		return master and master.petActionMode == petActionMode
	end

	return false
end

function IPetCombatComponent:OVERRIDE_castNormalAtkCombo__resetState(resetStateType)
	self.x_currentSkillId = nil
	self.x_isComboLastHit = nil
	self.x_nextComboIndex = nil

	self:castSkill__resetState(resetStateType)
end

function IPetCombatComponent:OVERRIDE_castNormalAtkCombo(targetId, maxComboCount, skipBackswing, minComboCount, skipCombo, castAbilitySource)
	local comboSkills = self.ent.normalAtkAbilityList
	local tgtEnt = pg.getEntityByActorId(targetId)

	if not self.x_currentSkillId and not AIUtils.checkEntCanBeUseSkill(tgtEnt) then
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
			self.x_isComboLastHit = self.x_nextComboIndex == maxComboCount or minComboCount < self.x_nextComboIndex and math_random() > 1 - AiConst.PET_COMBO_INTERRUPT_PROB
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

function IPetCombatComponent:attractHatred()
	self.ent:serverMsgNoGC("RPC_CS_PetAttractHatred")

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("AI", self.ent.actorId, "RPC_CS_PetAttractHatred")
	end

	return EBTStatus.BT_SUCCESS
end

function IPetCombatComponent:trySwitchToSupportPet(petIndex)
	if Utils.checkClient() then
		return EBTStatus.BT_FAILURE
	end

	local masterEnt = self.ent:getMasterEntity()

	if masterEnt and masterEnt:botTrySwitchToSupportPet(petIndex) then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_FAILURE
end

function IPetCombatComponent:isInControl()
	return self.ent.isInControl
end

function IPetCombatComponent:getMasterCombatTactic()
	local masterEnt = self.ent:getMasterEntity()
	local masterAgent = masterEnt and masterEnt.agent

	if masterAgent then
		return masterAgent:getBlackBoardProperty("combatTactic") or AiConst.BotPlayerDefaultCombatTactic
	end

	return AiConst.BotPlayerDefaultCombatTactic
end

function IPetCombatComponent:getPetListIsLowHpCount(lowHpPercent)
	local masterEnt = self.ent:getMasterEntity()
	local count = 0

	if masterEnt then
		for _, id in ipairs(masterEnt.petPrepareList) do
			local petEnt = pg.getEntity(id)

			if petEnt and not AbilityUtils.checkEntityIsDead(petEnt) and lowHpPercent > AbilityUtils.getHpPercent(petEnt) then
				count = count + 1
			end
		end
	end

	return count
end

return IPetCombatComponent
