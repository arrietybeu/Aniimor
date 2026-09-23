-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\ActionTimelineParams.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local ObjectPool = require("Common.Container.ObjectPool")
local Vector3 = Vector3
local Quaternion = Quaternion
local HitAnisOMData = require("Common.Data.SkillBPData.HitAnimsOM_Data")
local ImpulseData = require("Data.impulse_data")
local ActionTimelineParams = Class.LiteClass("ActionTimelineParams")
local MAX_CACHE_CNT = 100

if pg.component == "game" then
	MAX_CACHE_CNT = 1000
end

local CombatActionTimelineParam = Class.LiteClass("CombatActionTimelineParam")

ActionTimelineParams.CombatActionTimelineParam = CombatActionTimelineParam

function CombatActionTimelineParam:ctor()
	self.srcActorId = 0
	self.srcAbilityId = 0
	self.srcAbilityStoreType = 0
	self.attackSpeed = nil
	self.randomPointPos = nil
	self.targetActorId = nil
	self.hitPos = nil
	self.hitDir = nil
	self.hitIdx = 0
	self.srcType = AbilityConst.SRC_TYPE_NONE
	self.srcAbility = nil
	self.srcBuff = nil
	self.constCasterInfo = nil
	self.srcCreation = nil
	self.classKind = AbilityConst.TIMELINE_COMBAT
	self.combatContextId = 0
	self.castingCombatContextId = 0
end

local HitActionTimelineParam = Class.LiteClass("HitActionTimelineParam")

ActionTimelineParams.HitActionTimelineParam = HitActionTimelineParam

function HitActionTimelineParam:ctor()
	self.attackerActorId = nil
	self.attackerAbilityId = 0
	self.attackerAbilityStoreType = 0
	self.overrideTimeLength = nil
	self.airAttackLevel = nil
	self.attackData = nil
	self.srcCtxType = nil
	self.srcTemplateId = nil
	self.srcCalcResultNodeId = nil
	self.hurtType = AbilityConst.HURT_TYPE_NONE
	self.attackResult = AbilityConst.ATTACK_RESULT_NORMAL
	self.srcType = AbilityConst.SRC_TYPE_NONE
	self.damageValue = 0
	self.targetActorId = 0
	self.targetHitPos = nil
	self.targetHitDir = nil
	self.hitIdx = 0
	self.elementType = 0
	self.elementFactor = 1
	self.constCasterInfo = nil
	self.impulseH = nil
	self.impulseV = nil
	self.impulseDir = nil
	self.startTime = nil
	self.classKind = AbilityConst.TIMELINE_HIT
	self.targetHitPartIdx = nil
	self.combatContextId = 0
	self.isFromThorns = nil
	self.attackForceType = nil
end

function HitActionTimelineParam.convert(hitActionTimelineParam)
	if not hitActionTimelineParam then
		return
	end

	setmetatable(hitActionTimelineParam, HitActionTimelineParam)

	hitActionTimelineParam.impulseDir = Vector3.Convert(hitActionTimelineParam.impulseDir)

	CombatCasterInfo.convert(hitActionTimelineParam.constCasterInfo)

	hitActionTimelineParam.targetHitPos = Vector3.Convert(hitActionTimelineParam.targetHitPos)
	hitActionTimelineParam.targetHitDir = Quaternion.Convert(hitActionTimelineParam.targetHitDir)
	hitActionTimelineParam.attackPos = Vector3.Convert(hitActionTimelineParam.attackPos)
	hitActionTimelineParam.attackRot = Quaternion.Convert(hitActionTimelineParam.attackRot)
end

function ActionTimelineParams:ctor()
	self.timelineKind = AbilityConst.TIMELINE_INVALID
	self.combatParams = nil
	self.hitParams = nil
	self.basicParams = nil
	self.srcAbilityId = 0
end

function ActionTimelineParams:clear()
	self.timelineKind = AbilityConst.TIMELINE_INVALID
end

function ActionTimelineParams:assign(timelineParam)
	CombatCasterInfo.convert(timelineParam.constCasterInfo)

	if timelineParam.classKind == nil then
		if timelineParam.timelineKind == AbilityConst.TIMELINE_COMBAT then
			self:assign(timelineParam.combatParams)
		elseif timelineParam.timelineKind == AbilityConst.TIMELINE_HIT then
			self:assign(timelineParam.hitParams)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("wrong timelineParam", timelineParam.timelineKind)
		end
	elseif timelineParam.classKind == AbilityConst.TIMELINE_COMBAT then
		self.timelineKind = AbilityConst.TIMELINE_COMBAT
		self.combatParams = timelineParam
		self.hitParams = nil
		self.srcAbilityId = timelineParam.srcAbilityId
	elseif timelineParam.classKind == AbilityConst.TIMELINE_HIT then
		self.timelineKind = AbilityConst.TIMELINE_HIT
		self.hitParams = timelineParam
		self.combatParams = nil
		self.srcAbilityId = timelineParam.attackerAbilityId
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@jqj timelineParam type not supported", timelineParam)
	end
end

function HitActionTimelineParam:init(impulseId, dir, attackForceType, targetEntity, combatContext, attackData)
	self.impulseId = impulseId
	self.impulseDir = dir
	self.constCasterInfo = combatContext and combatContext.constCasterInfo and combatContext.constCasterInfo:getRawTable() or {}
	self.attackerActorId = combatContext and combatContext.constCasterInfo and combatContext.constCasterInfo.actorId or 0
	self.attackerAbilityId = combatContext and combatContext.abilityId
	self.attackerAbilityStoreType = combatContext and combatContext.abilityStoreType
	self.attackData = attackData or {}
	self.srcType = combatContext and combatContext.srcType
	self.targetActorId = targetEntity.actorId

	if combatContext and combatContext.runtimeTargetInfo then
		self.targetHitPos = combatContext.runtimeTargetInfo.hitPos
		self.targetHitDir = combatContext.runtimeTargetInfo.hitDir
		self.targetHitPartIdx = combatContext.runtimeTargetInfo.hitActorPartIdx
	end

	self.attackForceType = attackForceType

	local stateName = AbilityConst.ATTACK_FORCE_TYPE_TO_HIT_ANIM[attackForceType]

	if stateName then
		local controller = targetEntity:getConfigData().animController

		self.overrideTimeLength = HitAnisOMData[controller] and HitAnisOMData[controller][stateName]
	end
end

function HitActionTimelineParam:getAttackDataByServerRef(ctxType, templateId, calcResultNodeId)
	if not ctxType or not templateId or not calcResultNodeId then
		return nil
	end

	local template

	if ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY then
		template = pg.global.abilityMgr:getAbilityTemplate(templateId)
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		template = pg.global.abilityMgr:getTimelineTemplate(templateId)
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		template = pg.global.abilityMgr:getProjectileTemplate(templateId)
	elseif ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		template = pg.global.abilityMgr:getBuffTemplate(templateId)
	end

	if not template or not template.nodeMap then
		return nil
	end

	local calcResultNode = template.nodeMap[calcResultNodeId]

	if not calcResultNode then
		return nil
	end

	return calcResultNode.attackData
end

function HitActionTimelineParam:getImpulse(isInAir)
	local impulseH = self.impulseH
	local impulseV = self.impulseV

	if self.attackForceType == AbilityConst.ATTACK_FORCE_KNOCK_UP and self.impulseId then
		local impulseData = ImpulseData[self.impulseId] or {}

		impulseH = isInAir and impulseData.airHorizontalImpulse or impulseData.horizontalImpulse
		impulseV = isInAir and impulseData.airVerticalImpulse or impulseData.verticalImpulse
	end

	return impulseH, impulseV
end

local PendingTimelineCmdParams = Class.LiteClass("PendingTimelineCmdParams")

ActionTimelineParams.PendingTimelineCmdParams = PendingTimelineCmdParams

function PendingTimelineCmdParams:ctor()
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_NONE
	self.timelineId = 0
	self.playRate = 0
	self.timelineParams = ActionTimelineParams.new()
end

function PendingTimelineCmdParams:pushCmdSet(timelineId, playRate, timelineParams)
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_SET
	self.timelineId = timelineId
	self.playRate = playRate or 1

	self.timelineParams:assign(timelineParams)
end

function PendingTimelineCmdParams:pushCmdStop()
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_STOP
	self.timelineId = 0
	self.playRate = 0
end

function PendingTimelineCmdParams:pushCmdContinue(timelineId, playRate, timelineParams)
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_CONTINUE
	self.timelineId = timelineId
	self.playRate = playRate or 1

	self.timelineParams:assign(timelineParams)
end

function PendingTimelineCmdParams:pushCmdReset()
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_RESET
	self.timelineId = 0
	self.playRate = 0
end

function PendingTimelineCmdParams:clear()
	self.cmd = AbilityConst.ACTION_TIMELINE_CMD_NONE
	self.timelineId = 0
	self.playRate = 0

	self.timelineParams:clear()
end

return ActionTimelineParams
