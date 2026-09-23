-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\EditorCombatAction.lua

local Class = require("Core.Framework.Class")
local ClientCombatAction = require("GameApp.Ability.ClientCombatAction")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityDebugTool = require("Common.Ability.AbilityDebugTool")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ProjectileParams = require("Common.Ability.Projectile.ProjectileParams")
local ProjectileConst = require("Common.Const.ProjectileConst")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local GuardValue = require("Common.Ability.GuardValue")
local lume = require("Core.Common.lume")
local coroutine = require("coroutine")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local pg = pg
local ToBool = ToBool
local Vector3 = Vector3
local Quaternion = Quaternion
local unpack = unpack
local EditorCombatAction = Class.LiteClass("EditorCombatAction", ClientCombatAction)

function EditorCombatAction:doAction(actionData, combatContext)
	return self:doActionInternal(actionData, combatContext, false)
end

function EditorCombatAction:doActionById(nodeId, combatContext)
	if combatContext.nodeMap == nil then
		CombatActionTool.logError(combatContext, {
			NodeID = nodeId
		}, "combatContext.nodeMap not found")

		return false
	end

	local actionData = combatContext.nodeMap[nodeId]

	if not actionData then
		CombatActionTool.logError(combatContext, {
			NodeID = nodeId
		}, "actionData not found")

		return false
	end

	return self:doActionInternal(actionData, combatContext, true)
end

function EditorCombatAction:doActionInternal(actionData, combatContext, isNodeId)
	if not Utils.isTable(actionData) then
		CombatActionTool.logError(combatContext, {}, "actionData not found")

		return false
	end

	local actionFun = self[actionData.name]

	if actionData.BPName then
		combatContext.BPName = actionData.BPName
	end

	if AbilityDebugTool.checkRuntimeDebug(combatContext) then
		if actionData.NodeID then
			CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.SetRuntimeNodeInfo(actionData.NodeID)
		end

		local triggeredBreakpoint = false

		if actionData.NodeID and CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.IsNodeBreakpoint(actionData.NodeID) then
			triggeredBreakpoint = true

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj triggered breakpoint", combatContext.BPName, actionData.name, actionData.NodeID)
			end

			coroutine.yield()
		end

		triggeredBreakpoint = triggeredBreakpoint and false
	end

	local copyCombatContext = combatContext:clone()
	local ownerEntityActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	if actionFun then
		if AbilityDebugTool.checkRuntimeDebug(combatContext) then
			local resumeFunction, innerActionCoroutine
			local isOk, result = xpcall(function()
				local co = coroutine.create(function()
					combatContext:pushNodeIdToStack(actionData.NodeID)

					local result = actionFun(self, actionData, combatContext)

					if AbilityDebugTool.debugActionType[actionData.name] ~= 1 and isNodeId then
						CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.CallXLuaEntServerMsg(ownerEntityActorId, "RPC_CS_DebugModeCallDoAction", {
							actionData.NodeID,
							combatContext:getDynamicInfo()
						}, function(isOk, result)
							AbilityDebugTool.abilityDebugModeCallBack(actionData.NodeID, isOk, result)
						end)
					end

					combatContext:popNodeIdFromStack()

					return result
				end)

				local function ResumeCoroutine()
					return coroutine.resume(co)
				end

				local status, result = coroutine.resume(co)

				if status then
					if coroutine.status(co) ~= "dead" then
						resumeFunction = ResumeCoroutine
						innerActionCoroutine = co
					end
				else
					error(result)
				end

				return result
			end, debug.traceback)

			if type(resumeFunction) == "function" and innerActionCoroutine then
				coroutine.yield()

				isOk, result = resumeFunction()
			end

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj runtime debug action", combatContext.BPName, actionData.name, actionData.NodeID, isOk)
			end

			local resultText

			if isOk then
				local isRetBool = type(result) == "boolean"

				resultText = string.format("Client Execute result: %s, ret = %s\n", isRetBool and tostring(result) or "true", tostring(result))
				resultText = AbilityDebugTool.getCombinedNecessaryResult(copyCombatContext, actionData, resultText)

				if isRetBool then
					isOk = result
				end
			else
				result = string.gsub(result, "\nstack traceback", "\nlog_error_stack")

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.logException("do action error", combatContext.BPName, actionData.name, actionData.NodeID, result)
				end

				resultText = string.format("Client Execute result: false\n%s\n", result)
				result = false
			end

			if actionData.NodeID then
				CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.SetRuntimeFuncResult(actionData.NodeID, isOk, resultText)
			end

			return result
		else
			combatContext:pushNodeIdToStack(actionData.NodeID)

			local isOk, result = xpcall(function()
				return actionFun(self, actionData, combatContext)
			end, debug.traceback)

			combatContext:popNodeIdFromStack()

			if not isOk then
				result = string.gsub(result, "\nstack traceback", "\nlog_error_stack")

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.logException("do action error", combatContext.BPName, actionData.name, actionData.NodeID, result)
				end

				result = false
			end

			return result
		end
	elseif isNodeId and AbilityDebugTool.debugActionType[actionData.name] == 2 and AbilityDebugTool.checkRuntimeDebug(combatContext) then
		CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.CallXLuaEntServerMsg(ownerEntityActorId, "RPC_CS_DebugModeCallDoAction", {
			actionData.NodeID,
			combatContext:getDynamicInfo()
		}, function(isOk, result)
			AbilityDebugTool.abilityDebugModeCallBack(actionData.NodeID, isOk, result)
		end)
	end

	return false
end

function EditorCombatAction:setCombatActionTimeline(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity ~= nil then
		if targetEntity.authority ~= Const.AUTHORITY_MASTER then
			return false
		end

		local srcAbility = CombatActionTool.getCasterAbility(combatContext)
		local abilityId = srcAbility and srcAbility.abilityId or 0
		local realTimelineId = self:getVal(actionData.timelineId, combatContext)
		local realPlayRate = actionData.playRate or 1
		local attackSpeed = combatContext.attackSpeed or 1

		realPlayRate = realPlayRate * attackSpeed

		local combatActionTimelineParam = ActionTimelineParams.CombatActionTimelineParam()

		combatActionTimelineParam.combatContextId = targetEntity:genCombatContextId()
		combatActionTimelineParam.attackSpeed = attackSpeed

		local castingCombatContextId

		if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY then
			castingCombatContextId = combatActionTimelineParam.combatContextId

			targetEntity:startHitTriggerRecord(castingCombatContextId, combatContext)
		else
			castingCombatContextId = combatContext.castingCombatContextId
		end

		combatActionTimelineParam.castingCombatContextId = castingCombatContextId
		combatActionTimelineParam.srcActorId = combatContext.constCasterInfo and combatContext.constCasterInfo.actorId or CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
		combatActionTimelineParam.srcAbilityId = abilityId
		combatActionTimelineParam.srcAbilityStoreType = combatContext.abilityStoreType
		combatActionTimelineParam.randomPointPos = combatContext.randomPointPos
		combatActionTimelineParam.targetActorId = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.actorId
		combatActionTimelineParam.hitPos = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitPos
		combatActionTimelineParam.hitDir = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitDir
		combatActionTimelineParam.hitIdx = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.hitIdx
		combatActionTimelineParam.srcType = combatContext.srcType
		combatActionTimelineParam.constCasterInfo = combatContext.constCasterInfo and combatContext.constCasterInfo:clone()

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("setCombatActionTimeline", targetEntity.actorId, realTimelineId)
		end

		if AbilityDebugTool.checkRuntimeDebug(combatContext) then
			AbilityDebugTool.registerCurrentDebugTimelines(realTimelineId)
		end

		CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.CallXLuaEntServerMsgNoCb(targetEntity.actorId, "RPC_CS_SetCombatActionTimeline", {
			realTimelineId,
			realPlayRate,
			combatActionTimelineParam,
			combatContext.id,
			combatContext.nodeStack or {}
		})
		targetEntity.actorTimeline:setTimeline(realTimelineId, realPlayRate, combatActionTimelineParam)
	end

	return true
end

function EditorCombatAction:addTimer(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)
	local duration = self:getVal(actionData.duration, combatContext)

	if abilityObject then
		local runtimeTargetInfo = combatContext.runtimeTargetInfo

		abilityObject:addTimer(actionData.key, duration, function()
			local guardVal = GuardValue(combatContext, "runtimeTargetInfo", runtimeTargetInfo)

			pg.global.abilityMgr.combatAction:doActions(actionData, combatContext)
			guardVal:recover()
		end)

		return true
	end

	return false
end

function EditorCombatAction:actOnSweepTargets(actionData, combatContext)
	local chemElementId = 0

	if combatContext.abilityId then
		chemElementId = pg.global.abilityMgr:getEcsElement(combatContext.abilityId)
	end

	local startPos = self:doActionById(actionData.startPosNodeId, combatContext)
	local rotation = self:doActionById(actionData.rotationNodeId, combatContext)
	local impulseId = AbilityUtils.getAttackDataImpulseId(actionData, false)
	local physicsImpulse = ClientAbilityUtils.getImpulse(combatContext.abilityId, impulseId)
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(actorId)
	local elementLevel = ClientAbilityUtils.getElementLevel(ownerEntity, combatContext, chemElementId)
	local elementValue, ecsElementValue, instanceDmgRateV = ClientAbilityUtils.getElementValue(actionData, combatContext)

	pg.global.physicsMgr:SetChemHitInfo(actorId, combatContext.abilityId or 0, chemElementId or 0, physicsImpulse or 0, elementLevel, elementValue, ecsElementValue, instanceDmgRateV)

	local hitResults = pg.global.abilityMgr:boxSweep(startPos, rotation, actionData.boxExtends[1], actionData.boxExtends[2], actionData.boxExtends[3], actionData.sweepDistance, actionData, combatContext)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("actOnSweepTargets", inspect(hitResults))
	end

	if ToBool(hitResults) then
		ownerEntity:serverMsg("RPC_CS_DoActOnSweepTargetsActions", hitResults, actionData.NodeID, combatContext:getRPCDynamicInfo())
		CombatActionTool.doSweepActions(combatContext, actionData, hitResults, pg.global.abilityMgr.combatAction)
	end

	pg.global.physicsMgr:ClearChemHitInfo()

	return true
end

function EditorCombatAction:playEffectStrRandomAsync(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local casterEntity = pg.getEntityByActorId(casterActorId)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity ~= nil then
		local effectStr = pg.global.abilityMgr.combatAction:doAction(actionData.effectId, combatContext)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("playEffectStrRandomAsync", effectStr)
		end

		local attackSpeed = targetActorId == combatContext.actorId and combatContext.attackSpeed or 1
		local speed = (actionData.speed or 1) * attackSpeed
		local endTargetType = actionData.endTarget
		local offsetXYZ = actionData.offsetXYZ
		local offsetRotation = actionData.offsetRotation
		local endActorId = CombatActionTool.parseActorId(combatContext, endTargetType)
		local extraData = {
			speed = speed and speed > 0 and speed or nil,
			position = offsetXYZ,
			rotation = offsetRotation
		}

		self:setEffectExtraData(extraData, combatContext)

		if endActorId ~= 0 or endTargetType == AbilityConst.COMBAT_TARGET_TYPE_PROJECTILE then
			local linkTargetEntity = endActorId ~= 0 and pg.getEntityByActorId(endActorId) or combatContext:projectile()

			if linkTargetEntity ~= nil then
				local effectId = casterEntity:playLinkEffect(effectStr, linkTargetEntity, extraData)

				if actionData.isAbilityEndRemove == true then
					local ability = CombatActionTool.getCasterAbility(combatContext)

					ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability and ability.abilityId, effectId, false)
				end
			end
		else
			local effectId = targetEntity:playEffect(effectStr, extraData)

			if actionData.isAbilityEndRemove == true then
				local ability = CombatActionTool.getCasterAbility(combatContext)

				ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability and ability.abilityId, effectId, false)
			end

			return true
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("EditorCombatAction:playEffectStrRandomAsync failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

return EditorCombatAction
