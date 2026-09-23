-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ChainAttackInfo.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local CombatLogger = require("Common.Ability.CombatLogger")
local ChainAttackBP = require("Common.Data.SkillBPData.chain_attack_BP")
local Const = require("Common.Const.Const")
local TriggerConst = require("Common.Const.TriggerConst")
local ChainAttackDamageData = require("Data.chain_attack_damage_data")
local SysConfigData = require("Data.sys_config_data")
local NoticeDef = require("Common.NoticeDef")
local pg = pg
local ToBool = ToBool
local ChainAttackInfo = Class.LiteClass("ChainAttackInfo", CustomDict)

function ChainAttackInfo:checkTargetValid(masterEntity)
	local lockEntity = pg.getEntityByActorId(masterEntity.lockedActorId)

	if not lockEntity or not Utils.isPuppet(lockEntity) then
		return false
	end

	return true
end

function ChainAttackInfo:onDamageHit(masterEntity, combatContext, finalDamage)
	if not self:isInChain() and not masterEntity.keepChainBurstDamage then
		return
	end

	if not combatContext.abilityId then
		return
	end

	local abilityId = combatContext.abilityId
	local template = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not template or template.abilityType ~= AbilityConst.EnumAbilityType.Ultimate then
		return
	end

	if combatContext.chainAttackCnt then
		self.inExtreme = true
	end

	self.totalDamage = self.totalDamage + finalDamage
end

function ChainAttackInfo:resetTimeScale(casterEntity)
	local lockEntity = pg.getEntityByActorId(self.lastLockedActorId)

	if lockEntity then
		lockEntity:startFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_CHAIN_CHANCE, 1, 0)
	end

	if casterEntity then
		casterEntity:startFrameFreeze(AbilityConst.FRAME_FREEZE_KEY_CHAIN_CHANCE, 1, 0)
	end
end

function ChainAttackInfo:getChainChanceDuration()
	return self:getCurChainData().duration or 1
end

function ChainAttackInfo:getCurChainData()
	local index = #self.petList

	return ChainAttackBP[index] or {}
end

function ChainAttackInfo:isInChain()
	return self.inChain
end

function ChainAttackInfo:getDamageRatio()
	return self:getCurChainData().damageRatio or 1
end

function ChainAttackInfo:isInPlayerTeamChain()
	return self.inPlayerTeamChain
end

function ChainAttackInfo:startPlayerTeamChainAttack(playerEntity)
	self.lastLockedActorId = playerEntity.lockedActorId
	self.maxChainCnt = self:getMaxPlayerTeamChainCnt()
	self.totalDamage = 0
	self.inPlayerTeamChain = true
	self.isResponded = false
	self.pushedResponse = false
	self.teamChainPetList = {}
	self.curResponderId = playerEntity.uid
end

function ChainAttackInfo:triggerPlayerTeamExtremeChain(masterEntity, abilityId, combatContextId)
	local actionData = ChainAttackBP[#self.teamChainPetList]
	local elementType = pg.global.abilityMgr:getAbilityParamData(abilityId).elementType or 0
	local actionIds = actionData.elementActionIdsMap[elementType]
	local chainAttackCnt = #self.teamChainPetList

	self:doPlayerTeamExtremeChainActions(masterEntity, actionIds, abilityId, combatContextId, self.lastLockedActorId, chainAttackCnt)

	if pg.component == "game" then
		masterEntity:allClientsMsgNoGC("RPC_SC_DoTeamExtremeChainActions", abilityId, combatContextId, self.lastLockedActorId, chainAttackCnt)
	end
end

function ChainAttackInfo:doPlayerTeamExtremeChainActions(masterEntity, actionIds, abilityId, combatContextId, lockedActorId, chainAttackCnt)
	local lockedEntity = pg.getEntityByActorId(lockedActorId)

	if not lockedEntity or lockedEntity:isDead() then
		return
	end

	if ToBool(actionIds) then
		local damageData = ChainAttackDamageData[masterEntity.level] or {}
		local chainAttackCombatContext = masterEntity:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_CHAIN_ATTACK, combatContextId)

		chainAttackCombatContext:setConstCasterInfo(nil, masterEntity.actorId)

		chainAttackCombatContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

		chainAttackCombatContext.runtimeTargetInfo:initTarget(lockedActorId, lockedEntity:getPosition(), 1, 0)

		chainAttackCombatContext.abilityId = abilityId
		chainAttackCombatContext.abilityStoreType = 0
		chainAttackCombatContext.overrideAtk = damageData.damage or 0
		chainAttackCombatContext.isExtremeChainActions = true
		chainAttackCombatContext.chainAttackCnt = chainAttackCnt

		chainAttackCombatContext:initNodeMap()

		chainAttackCombatContext.BPName = "chain_attack_BP"

		pg.global.abilityMgr.combatAction:doActionIds(actionIds, chainAttackCombatContext)
		masterEntity:returnCombatContext(chainAttackCombatContext, true)
	end
end

function ChainAttackInfo:getMaxPlayerTeamChainCnt()
	return 4
end

function ChainAttackInfo:getLeastPlayerTeamChainCnt()
	return 3
end

function ChainAttackInfo:canCastTeamChainBurstOnTimeout()
	local lockedEntity = pg.getEntityByActorId(self.lastLockedActorId)

	if not lockedEntity or lockedEntity:isDead() then
		return false
	end

	return self.teamChainPetList and #self.teamChainPetList >= self:getLeastPlayerTeamChainCnt()
end

function ChainAttackInfo:canCastTeamChainBurst()
	return self.teamChainPetList and #self.teamChainPetList >= self.maxChainCnt
end

function ChainAttackInfo:isPlayerCurResponder(player)
	return player.uid == self.curResponderId
end

function ChainAttackInfo:getTeamChainRespondDuration()
	return SysConfigData.chainAttackRespondDuration or 5
end

function ChainAttackInfo:getChainPetListRawTable()
	local ret = {}

	if self.teamChainPetList then
		for _, petId in ipairs(self.teamChainPetList) do
			table.insert(ret, petId)
		end
	end

	return ret
end

function ChainAttackInfo:onPlayerTeamChainAttackEnd()
	self.inPlayerTeamChain = false
	self.isResponded = false
	self.pushedResponse = false
	self.curResponderId = ""
	self.lastLockedActorId = 0
	self.teamChainPetList = {}
end

return ChainAttackInfo
