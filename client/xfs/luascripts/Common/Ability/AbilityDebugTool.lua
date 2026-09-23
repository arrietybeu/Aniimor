-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\AbilityDebugTool.lua

local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Switch = require("Core.Common.Switch")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local ActionConst = require("Common.Const.ActionConst")
local AbilityDebugTool = Class.LiteClass("AbilityDebugTool")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local coroutine = require("coroutine")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local Vector3 = Vector3
local Quaternion = Quaternion
local unpack = unpack
local pg = pg
local ToBool = ToBool
local type = type

AbilityDebugTool.debugTimelineIds = {}
AbilityDebugTool.debugCasterEntityId = nil
AbilityDebugTool.debugAbilityObj = nil
AbilityDebugTool.debugActionType = {}

function AbilityDebugTool.switchDebugMode(debugActorId, debugAbilityId, enable)
	if enable then
		AbilityDebugTool.debugAbilityId = debugAbilityId
		AbilityDebugTool.debugCasterEntityId = debugActorId

		AbilityDebugTool.enableDebugMode(debugActorId, debugAbilityId)
	else
		AbilityDebugTool.debugAbilityId = nil
		AbilityDebugTool.debugCasterEntityId = nil

		AbilityDebugTool.disableDebugMode(debugActorId)
	end
end

function AbilityDebugTool.enableDebugMode(actorId, abilityId)
	if not ToBool(AbilityDebugTool.debugActionType) then
		AbilityDebugTool.initDebugActionTypeDict()
	end

	AbilityDebugTool.clearAllCoroutine()

	local GlobalData = require("Core.Client.GlobalData")

	pg.global.abilityMgr:switchRuntimeDebugMode(true)

	local space = GlobalData.Space

	space:enterAbilityRuntimeDebugMode()

	space.projectileMgrFrameId = TimerManager.addRepeatNextFrameCb(function()
		if AbilityDebugTool.checkMainDebugCoroutineSuspended() then
			return
		end

		AbilityDebugTool.startProjectileDebugCoroutine(function()
			space.projectileMgr:tick(Time.unscaledDeltaTime)
		end)
	end)

	local debugEntity = pg.getEntityByActorId(actorId)

	if debugEntity == nil then
		return false
	end

	AbilityDebugTool.debugCasterEntityId = actorId

	if debugEntity.abilityTimer then
		TimerManager.delFrameCb(debugEntity.abilityTimer)
	end

	debugEntity.abilityTimer = TimerManager.addRepeatNextFrameCb(function()
		if AbilityDebugTool.checkDebugAbilityId(debugEntity.debugAbilityId) then
			if AbilityDebugTool.checkMainDebugCoroutineSuspended() then
				return
			end

			AbilityDebugTool.startMainDebugCoroutine(function()
				debugEntity:tickAbility(Time.unscaledDeltaTime)
			end)
		end
	end)

	debugEntity:switchRuntimeDebugMode(true)
end

function AbilityDebugTool.disableDebugMode(actorId)
	local GlobalData = require("Core.Client.GlobalData")

	pg.global.abilityMgr:switchRuntimeDebugMode(false)

	local space = GlobalData.Space

	space:exitAbilityRuntimeDebugMode()

	local debugEntity = pg.getEntityByActorId(actorId)

	if debugEntity == nil then
		return false
	end

	AbilityDebugTool.debugCasterEntityId = actorId

	if debugEntity.abilityTimer then
		TimerManager.delFrameCb(debugEntity.abilityTimer)
	end

	debugEntity.abilityTimer = TimerManager.addRepeatNextFrameCb(function()
		debugEntity:tickAbility(Time.unscaledDeltaTime)
	end)

	debugEntity:switchRuntimeDebugMode(false)
end

function AbilityDebugTool.getCurrentDebugAbilityId(casterEntity)
	if AbilityDebugTool.debugAbilityId ~= nil then
		return AbilityDebugTool.debugAbilityId
	end

	local debugAbilityId

	if pg.me:isControllingPet() and casterEntity == pg.me:getCurPetEntity() then
		debugAbilityId = pg.me.debugAbilityId or casterEntity.debugAbilityId
	else
		debugAbilityId = casterEntity.debugAbilityId
	end

	AbilityDebugTool.debugAbilityId = debugAbilityId
	AbilityDebugTool.debugCasterEntityId = casterEntity.actorId
	casterEntity.debugAbilityId = debugAbilityId

	return debugAbilityId
end

function AbilityDebugTool.checkRuntimeDebug(combatContext)
	if Utils.checkClient() and UNITY_EDITOR and Switch.EnableRuntimeDebug then
		local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))

		if casterEntity and AbilityDebugTool.debugCasterEntityId == casterEntity.actorId then
			local debugAbilityId = AbilityDebugTool.getCurrentDebugAbilityId(casterEntity)
			local isAbilityTimeline = combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_ABILITY or combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE or combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE
			local abilityId = isAbilityTimeline and combatContext.abilityId or nil

			if abilityId and debugAbilityId and abilityId == debugAbilityId then
				return true
			end
		end
	end

	return false
end

function AbilityDebugTool.checkClientDebugMode()
	if Switch.EnableRuntimeDebug and Utils.checkClient() and UNITY_EDITOR then
		return true
	end

	return false
end

function AbilityDebugTool.checkDebugAbilityId(debugAbilityId)
	if Utils.checkClient() and UNITY_EDITOR and AbilityDebugTool.debugAbilityId then
		return debugAbilityId == AbilityDebugTool.debugAbilityId
	end

	return false
end

function AbilityDebugTool.startDebugCoroutine(combatContext, actions)
	local casterEntity = pg.getEntityByActorId(AbilityDebugTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER))
	local debugEntity

	if casterEntity then
		debugEntity = casterEntity

		if pg.me:isControllingPet() and casterEntity == pg.me:getCurPetEntity() then
			if pg.me.debugAbilityId then
				debugEntity = pg.me
			elseif casterEntity.debugAbilityId then
				debugEntity = casterEntity
			end
		end
	end

	if not debugEntity then
		return false
	end

	local triggeredBreakpoint = false
	local co = coroutine.create(function()
		local result = true

		for idx, actionData in ipairs(actions) do
			if actionData.NodeID then
				CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.SetRuntimeNodeInfo(actionData.NodeID)
			end

			if actionData.NodeID and CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.IsNodeBreakpoint(actionData.NodeID) then
				triggeredBreakpoint = true
				combatContext:timeline().isPlaying = false

				coroutine.yield()
			end

			if triggeredBreakpoint then
				combatContext:timeline().isPlaying = true
				triggeredBreakpoint = false
			end

			result = ToBool(pg.global.abilityMgr.combatAction:doAction(actionData, combatContext)) and result
		end

		return result
	end)

	debugEntity.debugCoroutine = co

	local ret, result = coroutine.resume(debugEntity.debugCoroutine)

	return result
end

function AbilityDebugTool.startAbilityCastCoroutine(func, debugAbilityId)
	AbilityDebugTool.abilityCastCoroutine = coroutine.create(func)

	local status, ret = coroutine.resume(AbilityDebugTool.abilityCastCoroutine)

	if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@hyj start ability cast coroutine failed", ret)
	end

	return status, ret
end

function AbilityDebugTool.resumeAbilityCastCoroutine()
	if not AbilityDebugTool.abilityCastCoroutine then
		return false
	end

	if coroutine.status(AbilityDebugTool.abilityCastCoroutine) == "dead" then
		return false
	end

	local status, ret = coroutine.resume(AbilityDebugTool.abilityCastCoroutine)

	if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@hyj resume abilityCastCoroutine failed", ret)
	end

	return status, ret
end

function AbilityDebugTool.startMainDebugCoroutine(func)
	if AbilityDebugTool.checkMainDebugCoroutineSuspended() then
		return
	end

	AbilityDebugTool.mainDebugCoroutine = coroutine.create(func)
	AbilityDebugTool.ret, AbilityDebugTool.resumeFunction, AbilityDebugTool.innerDebugCoroutine = coroutine.resume(AbilityDebugTool.mainDebugCoroutine)
end

function AbilityDebugTool.resumeMainDebugCoroutine()
	if AbilityDebugTool.checkMainDebugCoroutineSuspended() then
		AbilityDebugTool.ret, AbilityDebugTool.resumeFunction, AbilityDebugTool.innerDebugCoroutine = coroutine.resume(AbilityDebugTool.mainDebugCoroutine)
	end
end

function AbilityDebugTool.checkMainDebugCoroutineSuspended()
	if AbilityDebugTool.mainDebugCoroutine and coroutine.status(AbilityDebugTool.mainDebugCoroutine) ~= "dead" then
		return true
	end

	return false
end

function AbilityDebugTool.resumeInnerCoroutine()
	return AbilityDebugTool.resumeFunction()
end

function AbilityDebugTool.checkInnerDebugCoroutineSuspended()
	if AbilityDebugTool.innerDebugCoroutine and coroutine.status(AbilityDebugTool.innerDebugCoroutine) ~= "dead" then
		return true
	end

	return false
end

function AbilityDebugTool.startProjectileDebugCoroutine(func)
	AbilityDebugTool.projectileDebugCoroutine = coroutine.create(func)

	local status, ret = coroutine.resume(AbilityDebugTool.projectileDebugCoroutine)

	return status, ret
end

function AbilityDebugTool.resumeProjectileDebugCoroutine()
	if not AbilityDebugTool.projectileDebugCoroutine then
		return false
	end

	if coroutine.status(AbilityDebugTool.projectileDebugCoroutine) == "dead" then
		return false
	end

	local status, ret = coroutine.resume(AbilityDebugTool.projectileDebugCoroutine)

	if not status and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@hyj resume abilityCastCoroutine failed", ret)
	end

	return status, ret
end

function AbilityDebugTool.checkProjectileDebugCoroutineSuspended()
	if AbilityDebugTool.projectileDebugCoroutine and coroutine.status(AbilityDebugTool.projectileDebugCoroutine) ~= "dead" then
		return true
	end

	return false
end

function AbilityDebugTool.resumeInnerActionCoroutine()
	return AbilityDebugTool.resumeInnerActionFunction()
end

function AbilityDebugTool.checkInnerActionDebugCoroutineSuspended()
	if AbilityDebugTool.innerActionDebugCoroutine and coroutine.status(AbilityDebugTool.innerActionDebugCoroutine) ~= "dead" then
		return true
	end

	return false
end

function AbilityDebugTool.checkBreakPointReached()
	return AbilityDebugTool.checkMainDebugCoroutineSuspended() or AbilityDebugTool.checkProjectileDebugCoroutineSuspended()
end

function AbilityDebugTool.registerCurrentDebugTimelines(timelineId)
	if AbilityDebugTool.debugTimelineIds == nil then
		AbilityDebugTool.debugTimelineIds = {}
	end

	AbilityDebugTool.debugTimelineIds[timelineId] = true
end

function AbilityDebugTool.checkRuntimeDebugTimeline(timelineId)
	if Utils.checkClient() and UNITY_EDITOR and AbilityDebugTool.debugTimelineIds[timelineId] then
		return true
	end

	return false
end

function AbilityDebugTool.clearAllDebugInfo()
	for idx, value in pairs(AbilityDebugTool.debugTimelineIds) do
		AbilityDebugTool.debugTimelineIds[idx] = false
	end

	AbilityDebugTool.debugAbilityId = nil

	if AbilityDebugTool.debugCasterEntityId then
		local casterEntity = pg.getEntityByActorId(AbilityDebugTool.debugCasterEntityId)

		if casterEntity then
			casterEntity.debugAbilityId = nil
		end
	end

	if pg.me then
		pg.me.debugAbilityId = nil
	end

	AbilityDebugTool.debugCasterEntityId = nil
end

function AbilityDebugTool.clearRuntimeDebugInfo(actorId, abilityId)
	if Utils.checkClient() and UNITY_EDITOR and Switch.EnableRuntimeDebug and abilityId == AbilityDebugTool.debugAbilityId and actorId == AbilityDebugTool.debugCasterEntityId then
		CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.ClearDebugInfo()
	end
end

function AbilityDebugTool.clearAllCoroutine()
	AbilityDebugTool.mainDebugCoroutine = nil
	AbilityDebugTool.innerDebugCoroutine = nil
	AbilityDebugTool.projectileDebugCoroutine = nil
end

function AbilityDebugTool.abilityDebugModeCallBack(nodeId, isOk, result)
	local resultText = string.format("Server Execute result: %s\n", tostring(isOk))

	if result then
		resultText = resultText .. result
	end

	if nodeId then
		CS.FunPlus.WorldX.FlowCanvas.SkillBPRuntimeData.AppendRuntimeFuncResult(nodeId, isOk, resultText)
	end
end

function AbilityDebugTool.getCombinedNecessaryResult(combatContext, actionData, resultText)
	local result = resultText
	local posInfo, rotInfo = AbilityDebugTool.getDebugPosRotInfo(combatContext, actionData)
	local ret, targetInfo = AbilityDebugTool.getDebugTargetInfo(combatContext, actionData)
	local specialTargetInfoResult = AbilityDebugTool.getSepcialTargetInfoResult(combatContext, actionData)

	if targetInfo ~= nil then
		result = result .. string.format("Action TargetActorId = %d\n", targetInfo)
	elseif ret then
		result = result .. string.format("Action with no target[actionData.target = %s]\n", actionData.target)
	end

	if posInfo ~= nil then
		result = result .. string.format("Action Position = {%f, %f, %f}\n", posInfo[1], posInfo[2], posInfo[3])
	end

	if rotInfo ~= nil then
		local rotEulerInfo = rotInfo:ToEulerAngles()

		result = result .. string.format("Action Rotation = {%f, %f, %f}\n", rotEulerInfo[1], rotEulerInfo[2], rotEulerInfo[3])
	end

	if specialTargetInfoResult ~= nil then
		result = result .. specialTargetInfoResult
	end

	return result
end

function AbilityDebugTool.getDebugPosRotInfo(combatContext, actionData)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		return nil
	end

	local projectileType = actionData.projectileType
	local posTarget = actionData.pos or actionData.target
	local offsetXYZ = actionData.offsetXYZ
	local rotFrom = actionData.rot
	local rotTo = actionData.rotTo
	local rotation = actionData.rotation
	local offsetRotation = actionData.offsetRotation

	if actionData.name == ActionConst.COMMON_ACTIONS.COMBAT_ACTION_REGISTER_TRAP_EVENT then
		posTarget = actionData.center
		offsetXYZ = nil
	elseif actionData.name == ActionConst.CLIENT_ACTIONS.COMBAT_ACTION_CREATE_SEGMENTED_CIRCLE_PROJECTILE then
		offsetXYZ = actionData.centerOffsetXYZ
	end

	if posTarget == nil then
		return nil
	end

	if offsetXYZ ~= nil then
		offsetXYZ = Vector3(unpack(offsetXYZ))
	else
		if actionData.pos == nil then
			return nil
		end

		offsetXYZ = Vector3(0, 0, 0)
	end

	local oriScale = ownerEntity.curModelScale or 1

	if actionData.name == ActionConst.SERVER_ACTIONS.COMBAT_ACTION_CREATE_ENTITY or ActionConst.SERVER_ACTIONS.COMBAT_ACTION_CREATE_SUMMONED_ENTITY then
		oriScale = 1
	end

	local rot
	local originPos = ownerEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, posTarget, originPos)

	local originRot = ownerEntity:getRotation():Clone()

	if rotation ~= nil then
		CombatActionTool.parseRotationTowards(combatContext, rotation, originPos, originRot, {
			posType = actionData.rotationTowardsPos,
			targetRotation = actionData.targetRotation
		})

		rot = originRot:Clone()
	elseif rotFrom ~= nil or rotTo ~= nil then
		CombatActionTool.parseRotationFromTo(combatContext, rotFrom, rotTo, originRot)

		rot = originRot:Clone()
	else
		rot = nil
	end

	local pos = CombatActionTool.translatePoint(originPos, originRot, offsetXYZ * oriScale)

	if offsetRotation ~= nil then
		offsetRotation = Vector3(unpack(offsetRotation))

		if offsetRotation.x ~= 0 and offsetRotation.x ~= nil then
			rot = originRot * Quaternion.AngleAxis(offsetRotation.x, Vector3.left)
		end

		if offsetRotation.y ~= 0 and offsetRotation.y ~= nil then
			rot = originRot * Quaternion.AngleAxis(offsetRotation.y, Vector3.up)
		end

		if offsetRotation.z ~= 0 and offsetRotation.z ~= nil then
			rot = originRot * Quaternion.AngleAxis(offsetRotation.z, Vector3.forward)
		end
	end

	return pos, rot
end

function AbilityDebugTool.getDebugTargetInfo(combatContext, actionData)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		return false, nil
	end

	local target = actionData.target

	if actionData.name == ActionConst.COMMON_ACTIONS.COMBAT_ACTION_REGISTER_TRAP_EVENT then
		target = actionData.center
	end

	if target == nil then
		return false, nil
	end

	if Utils.isTable(target) and target.NodeID then
		local targetActionData = combatContext.nodeMap[target.NodeID]

		if targetActionData == nil or AbilityDebugTool.debugActionType[targetActionData.name] == 2 then
			return false, nil
		end
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		return true, nil
	end

	return true, targetActorId
end

function AbilityDebugTool.getDebugTargetPosInfo(combatContext, actionData)
	return
end

function AbilityDebugTool.getSepcialTargetInfoResult(combatContext, actionData)
	if actionData.name == ActionConst.CLIENT_ACTIONS.COMBAT_ACTION_LOCK_TARGET then
		local lockTargetId = CombatActionTool.parseActorId(combatContext, actionData.lockTarget or AbilityConst.COMBAT_TARGET_TYPE_TARGET)

		if ToBool(lockTargetId) then
			return string.format("LockTarget: LockTargetActorId = %d\n", lockTargetId)
		else
			return "LockTarget: lockTarget not found!\n"
		end
	elseif actionData.name == ActionConst.CLIENT_ACTIONS.COMBAT_ACTION_PLAY_ANIMATION then
		local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if targetEntity ~= nil and actionData.motionWarpingTarget ~= nil then
			local clipConfig = targetEntity:getPlayableClipConfig(actionData.animId)

			if clipConfig then
				local targetPos = Vector3(0, 0, 0)
				local xzEndPoint = clipConfig:GetMotionXZEndPoint()
				local yEndPoint = clipConfig:GetMotionYEndPoint()

				if Vector3.SqrMagnitude(xzEndPoint) < 0.1 and Vector3.SqrMagnitude(yEndPoint) < 0.1 then
					return "motionWarpingTarget: root motion not bake!\n"
				end

				local fromPos = targetEntity:getPosition()

				if CombatActionTool.parsePosition(combatContext, actionData.motionWarpingTarget, targetPos) then
					local positionInfo = string.format("motionWarpingTarget: TargetPosition = {%f, %f, %f}\n", targetPos[1], targetPos[2], targetPos[3])
					local motionWarpingTargetActorId = CombatActionTool.parseActorId(combatContext, actionData.motionWarpingTarget)
					local ent

					if type(motionWarpingTargetActorId) == "number" then
						ent = pg.getEntityByActorId(motionWarpingTargetActorId)
					end

					local inSearchRange = AbilityUtils.checkTargetSearchRange(pg.global.abilityMgr:getAbilityTemplate(combatContext.abilityId), fromPos, targetPos, ent and ent.bodySize or 0, ent and ent.bodyHeight or 0)

					if inSearchRange then
						return positionInfo .. "motionWarpingTarget: target check success, use Alt+x -> \"显示技能攻击盒\" to see final position\n"
					else
						return positionInfo .. "motionWarpingTarget: target not in range motionWarping!\n"
					end
				else
					return "motionWarpingTarget: motionWarpingTarget not found!\n"
				end
			else
				return "motionWarpingTarget: playable clip info not found!\n"
			end
		end
	elseif actionData.name == ActionConst.COMMON_ACTIONS.COMBAT_ACTION_CAST_ABILITY then
		local abilityTargetId = CombatActionTool.parseActorId(combatContext, actionData.abilityTarget)

		if ToBool(abilityTargetId) then
			return string.format("AbilityTarget: AbilityTargetId = %d\n", abilityTargetId)
		else
			return "AbilityTarget: AbilityTargetId not found!\n"
		end
	elseif actionData.name == ActionConst.COMMON_ACTIONS.COMBAT_ACTION_PLAY_EFFECT_STR then
		if actionData.endTarget ~= nil then
			local endTargetType = actionData.endTarget
			local endActorId = CombatActionTool.parseActorId(combatContext, endTargetType)

			if endTargetType == AbilityConst.COMBAT_TARGET_TYPE_PROJECTILE then
				return string.format("EndTarget: EndTarget is projectile and id = %s\n", combatContext.id)
			elseif ToBool(endActorId) then
				return string.format("EndTarget: EndTargetActorId = %d\n", endActorId)
			else
				return "EndTarget: EndTarget not found!\n"
			end
		end
	elseif actionData.name == ActionConst.SERVER_ACTIONS.COMBAT_ACTION_FORCE_DISPLACEMENT then
		-- block empty
	end

	return nil
end

function AbilityDebugTool.initDebugActionTypeDict()
	for _, funcName in pairs(ActionConst.COMMON_ACTIONS) do
		AbilityDebugTool.debugActionType[funcName] = 0
	end

	for _, funcName in pairs(ActionConst.CLIENT_ACTIONS) do
		AbilityDebugTool.debugActionType[funcName] = 1
	end

	for _, funcName in pairs(ActionConst.SERVER_ACTIONS) do
		AbilityDebugTool.debugActionType[funcName] = 2
	end
end

function AbilityDebugTool.getCacheValElementDesc(entity, key, isServerCacheVal)
	local val = isServerCacheVal and EntityCacheValueUtils.getCacheValue(entity, key) or entity.getEntityCacheVal and entity:getEntityCacheVal(key)

	if val == nil then
		return "nil"
	elseif val == type("function") then
		return "unknown function"
	elseif val == type("table") then
		if val.className == "Vector3" then
			return string.format("Vector3(%.2f, %.2f, %.2f)", val[1] or 0, val[2] or 0, val[3] or 0)
		elseif val.class == "Quaternion" then
			return tostring(val)
		elseif val.actorId ~= nil and val.actorId > 0 then
			return string.format("Entity(actorId = %d)", val.actorId)
		elseif val.className ~= nil then
			return val.className
		else
			return "unknown table"
		end
	else
		return tostring(val)
	end
end

return AbilityDebugTool
