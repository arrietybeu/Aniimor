-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ClientCombatAction.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local AbilityConst = require("Common.Const.AbilityConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Const = require("Common.Const.Const")
local ProjectileConst = require("Common.Const.ProjectileConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local CombatLogger = require("Common.Ability.CombatLogger")
local CombatAction = require("Common.Ability.CombatAction")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local EffectConst = require("Const.EffectConst")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local AttributeConst = require("Common.Const.AttributeConst")
local Time = require("Core.Common.Time")
local ECSConst = require("Const.ECSConst")
local ClientUtils = require("Utils.ClientUtils")
local GuardValue = require("Common.Ability.GuardValue")
local MessageName = require("Const.MessageName")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local DamageData = require("Common.Ability.DamageData")
local ClientSwitch = require("Common.ClientSwitch")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EventConst = require("Const.EventConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local HotkeyConst = require("Const.HotkeyConst")
local DialogueConst = require("Const.DialogueConst")
local CameraShakeData = require("Data.camera_shake_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local EmojiData = require("Data.emoji_data")
local elementPropData = require("Data.element_prop_data")
local AbilityVoiceData = require("Data.ability_voice_data")
local PlayableConst = require("Common.Const.PlayableConst")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local UIConst = require("Const.UIConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local AoiLodConst = require("Common.Const.AoiLodConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local TimerManager = require("Core.Timer.TimerManager")
local HitDisplacementData = require("Data.skill_hit_displacement_data")
local NoticeDef = require("Common.NoticeDef")
local CTRPool = require("Common.AICt.CTRPool")
local ListPool = require("Common.Container.ListPool")
local lume = require("Core.Common.lume")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientPresetActionHelper = require("GameApp.Ability.ClientPresetActionHelper")
local pg = pg
local ToBool = ToBool
local Vector3 = Vector3
local Vector4 = Vector4
local Quaternion = Quaternion
local unpack = unpack
local VEC3_CONST_UP = Vector3.constUp
local VEC3_CONST_LEFT = Vector3.constLeft
local VEC3_CONST_FORWARD = Vector3.constForward
local IsNil = IsNil
local NotNil = NotNil
local PhysxComponent = CS.FunPlus.WorldX.Entities.Components.PhysxComponent
local EffectShaderViewComponent = CS.FunPlus.WorldX.Effect.EffectShaderViewComponent
local AbsorbMotor = CS.FunPlus.WorldX.GameApp.Capture.AbsorbMotor
local typeof = typeof
local cameraShakeCache = {}
local cameraShakeEffectExtInfo = {}
local ClientCombatAction = Class.LiteClass("ClientCombatAction", CombatAction)

function ClientCombatAction:doAction(actionData, combatContext)
	if actionData and ClientAbilityConst.TIMELINE_FAST_FORWARD_SKIP_ACTIONS[actionData.name] and combatContext.isCutSceneFastForwarding then
		return true
	end

	return CombatAction.doAction(self, actionData, combatContext)
end

function ClientCombatAction:playAnimation(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local animId = actionData.animId
		local abilityAnimState = CombatActionTool.isSpecialAbilityAnim(animId)

		if abilityAnimState ~= nil then
			local controllerComponent = targetEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

			if NotNil(controllerComponent) then
				local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

				abilityCharacterStateInfo.abilityStateMachine = abilityAnimState
				abilityCharacterStateInfo.abilityStateFadeTime = actionData.fadeTime or 0.5
			end
		end

		local disableMotion = actionData.disableMotion

		if ToBool(disableMotion) and targetEntity.disableMotionByAnim then
			targetEntity:disableMotionByAnim(animId)
		end

		local offsetTime = actionData.offsetTime or -1
		local fastForwardOffsetTime = ClientAbilityUtils.getSkipCutSceneOffsetTime(combatContext)

		if fastForwardOffsetTime > 0 then
			if offsetTime == -1 then
				offsetTime = fastForwardOffsetTime
			else
				offsetTime = offsetTime + fastForwardOffsetTime
			end
		end

		local warpStartTime = actionData.warpStartTime or 0
		local fadeTime = actionData.fadeTime or -1
		local attackSpeed = targetActorId == combatContext.actorId and combatContext.attackSpeed or 1
		local animSpeed = actionData.speed or 1

		animSpeed = animSpeed * attackSpeed

		local state = targetEntity:playAbilityAnimation(animId, fadeTime, offsetTime, animSpeed, actionData.timelineTag)
		local rootMotionScale = actionData.rootMotionScale

		if rootMotionScale and targetEntity:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
			targetEntity:setRootMotionScale(rootMotionScale)
			state:AddEndCallback(function()
				targetEntity:setRootMotionScale(1)
			end)
		end

		if actionData.motionWarpingTarget ~= nil then
			local clipConfig = targetEntity:getPlayableClipConfig(actionData.animId)

			if clipConfig then
				Vector3.enableCreateFromCache()

				local warpXZ = true
				local warpY = true
				local targetPos = Vector3(0, 0, 0)
				local groundValid = true
				local motionOffset = clipConfig:ExtractDeltaPos(0, clipConfig.clipLength, {
					1,
					1,
					1
				})
				local xzEndPoint = Vector3(motionOffset.x, 0, motionOffset.z)
				local yEndPoint = Vector3(0, motionOffset.y, 0)
				local fromPos = targetEntity:getPosition()

				if CombatActionTool.parsePosition(combatContext, actionData.motionWarpingTarget, targetPos) then
					local motionWarpingTargetActorId = CombatActionTool.parseActorId(combatContext, actionData.motionWarpingTarget)
					local ent

					if type(motionWarpingTargetActorId) == "number" then
						ent = pg.getEntityByActorId(motionWarpingTargetActorId)
					end

					local inSearchRange = AbilityUtils.checkTargetSearchRange(combatContext:getAbilityTemplate(), fromPos, targetPos, ent and ent.bodySize or 0, ent and ent.bodyHeight or 0)

					if inSearchRange then
						if ent and ToBool(actionData.motionWarpingTargetHead) then
							local heightPos = CombatActionTool.getHeightPosition(ent)

							targetPos:Set(heightPos.x, heightPos.y, heightPos.z)
						end

						local dir = targetPos - fromPos

						dir.y = 0

						local len = Vector3.Magnitude(dir)

						if ToBool(actionData.motionWarpingXZMaxLen) then
							len = math.min(len, actionData.motionWarpingXZMaxLen * math.max(1, targetEntity.curModelScale))
						end

						if ToBool(actionData.motionWarpingXZMinLen) then
							len = math.max(len, actionData.motionWarpingXZMinLen * math.max(1, targetEntity.curModelScale))
						end

						dir:SetNormalize()

						if ToBool(actionData.backOffset) then
							len = len - actionData.backOffset
						elseif not ToBool(actionData.notAvoidOverlap) then
							len = len - (targetEntity.eModel.radius + (ent and ent.eModel.radius or 0))
						end

						len = math.max(0, len)

						local xzEndPos = fromPos + dir * len

						if ToBool(actionData.motionWarpingTargetHead) then
							targetPos:Set(xzEndPos.x, fromPos.y, xzEndPos.z)
						elseif actionData.modifyToGround ~= false then
							targetPos, groundValid = PhysicsUtils.getGroundPos(Vector3(xzEndPos.x, targetPos.y, xzEndPos.z), 2, nil, nil, false, 6)
						else
							targetPos = Vector3(xzEndPos.x, targetPos.y, xzEndPos.z)
						end
					else
						local motionWarpingPos = Vector3(xzEndPoint.x, yEndPoint.y, xzEndPoint.z)

						motionWarpingPos = targetEntity:getPosition() + targetEntity:getRotation():MulVec3(motionWarpingPos)
						targetPos = PhysicsUtils.getGroundPos(motionWarpingPos) or motionWarpingPos

						if LoggerManager.checkLogger(LoggerConst.DEBUG) then
							CombatLogger.debug("target not in range motionWarping")
						end
					end
				else
					local motionWarpingPos = Vector3(xzEndPoint.x, yEndPoint.y, xzEndPoint.z)

					motionWarpingPos = targetEntity:getPosition() + targetEntity:getRotation():MulVec3(motionWarpingPos)

					if actionData.modifyToGround ~= false then
						targetPos = PhysicsUtils.getGroundPos(motionWarpingPos, 2, nil, nil, false, 6) or motionWarpingPos
					else
						targetPos = motionWarpingPos
					end
				end

				if ClientSwitch.EnableDrawAbilityGizmo then
					ClientDebugUtils.drawDebugHitBoxMesh(targetPos, Quaternion(0, 0, 0, 1), AbilityConst.LX_GEOMETRY_TYPE_SPHERE, {
						0.5
					})
				end

				if groundValid then
					if actionData.warpEndTime ~= nil then
						local warpEndTime = actionData.warpEndTime

						state:ModifyEndPosition(targetPos, warpStartTime, warpEndTime, warpXZ, warpY)
					else
						state:ModifyEndPosition(targetPos, warpStartTime, warpXZ, warpY)
					end
				end

				Vector3.disableCreateFromCache()
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("can not found root motion data", actionData.animId)
			end
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:callLua failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:setEffectExtraData(extraData, combatContext, targetEntity, isHit)
	ClientAbilityUtils.setCombatAudioInfo(extraData, combatContext, targetEntity, isHit)

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if ability and ability.abilityId then
		local elementType = combatContext.overrideElementType or pg.global.abilityMgr:getAbilityParamData(ability.abilityId).elementType

		if elementType then
			local customHue = (elementPropData[elementType] or EMPTY_TABLE).skillHValue or 0

			extraData.customHue = customHue
		end
	end
end

function ClientCombatAction:playEffectStr(actionData, combatContext)
	local effectStr = self:getVal(actionData.effectId, combatContext)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playEffectStr", effectStr)
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local casterEntity = pg.getEntityByActorId(casterActorId)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not casterEntity then
		return false
	end

	if actionData.isAbilityEndRemove == true and ToBool(combatContext.abilityId) and (not ownerEntity or not ownerEntity.isCastingAbility or not ownerEntity:isCastingAbility(combatContext.abilityId)) then
		return false
	end

	if targetEntity ~= nil then
		if combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_FINISH or combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_HIT then
			local runtimeTarget = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

			if runtimeTarget and runtimeTarget.replaceHitEffect then
				effectStr = runtimeTarget.replaceHitEffect
			end
		end

		local attackSpeed = targetActorId == combatContext.actorId and combatContext.attackSpeed or 1
		local speed = (actionData.speed or 1) * attackSpeed
		local endTargetType = actionData.endTarget
		local offsetXYZ

		if actionData.offsetXYZ then
			offsetXYZ = actionData.offsetXYZ.name == nil and Vector3(unpack(actionData.offsetXYZ)) or self:doAction(actionData.offsetXYZ, combatContext)

			Vector3.Mul(offsetXYZ, targetEntity.curModelScale or 1)
		end

		local offsetRotation

		if actionData.offsetRotation then
			offsetRotation = actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)
		end

		if offsetRotation and offsetRotation.class == "Quaternion" then
			offsetRotation = offsetRotation:ToEulerAngles()
		end

		local scale = self:getVal(actionData.scale, combatContext)
		local duration = actionData.duration
		local endActorId = CombatActionTool.parseActorId(combatContext, endTargetType)
		local extraData = {
			speed = speed and speed > 0 and speed or nil,
			position = offsetXYZ,
			rotation = offsetRotation,
			bone = actionData.bone,
			scale = scale and scale > 0 and scale or nil,
			duration = duration and (duration > 0 or duration == -1) and duration or nil
		}

		self:setEffectExtraData(extraData, combatContext, targetEntity, combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_HIT)
		ClientAbilityUtils.setEffectMpeLodInfo(extraData, targetEntity, casterEntity)

		if actionData.postFollowType == ClientAbilityConst.EFFECT_POST_FOLLOW_TYPE.RotationTowardsAimPos then
			extraData.alwaysTowardsCameraCenter = true
			extraData.linkEndDist = self:getVal(actionData.aimMaxDist, combatContext)
		elseif actionData.postFollowType == ClientAbilityConst.EFFECT_POST_FOLLOW_TYPE.CustomTransformPosAndStickGround then
			local followTransform = self:getVal(actionData.followTransform, combatContext)

			if NotNil(followTransform) then
				extraData.mountType = EffectConst.MountType.Custom
				extraData.targetTrans = followTransform
			end

			extraData.enableStickGround = true
		end

		if endActorId ~= 0 or endTargetType == AbilityConst.COMBAT_TARGET_TYPE_PROJECTILE then
			local linkTargetEntity = endActorId ~= 0 and pg.getEntityByActorId(endActorId) or combatContext:projectile()

			if linkTargetEntity ~= nil then
				local effectId = casterEntity:playLinkEffect(effectStr, linkTargetEntity, extraData)

				if actionData.isAbilityEndRemove == true then
					local ability = CombatActionTool.getCasterAbility(combatContext)

					if ability and ownerEntity and ownerEntity.addAbilityEffect then
						ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability.abilityId, effectId, false)
					end
				end

				if linkTargetEntity.subject then
					local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

					if not abilityObject then
						return false
					end

					abilityObject:getObserver():listen(linkTargetEntity.subject, AbilityConst.COMBAT_EVENT_DEAD, function()
						if ownerEntity then
							ownerEntity:stopEffect(effectStr)
						end
					end)
				end
			end
		else
			if combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_FINISH or combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_HIT then
				local runtimeTarget = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

				if runtimeTarget and runtimeTarget.replaceHitEffect then
					effectStr = runtimeTarget.replaceHitEffect
				end
			end

			if actionData.isSwitchPetInherit then
				local masterEntity = targetEntity.getMasterEntity and targetEntity:getMasterEntity() or targetEntity

				if masterEntity.inheritEffectMap == nil then
					masterEntity.inheritEffectMap = {}
				end

				extraData.startTime = 0
				masterEntity.inheritEffectMap[effectStr] = extraData
			end

			local effectId

			if actionData.applyInCharacterStates then
				local canPlayImmediately = false

				for _, state in pairs(actionData.applyInCharacterStates) do
					if CharacterStateConst.isChildOfState(targetEntity.characterState, CharacterStateConst[state]) then
						canPlayImmediately = true

						break
					end
				end

				if canPlayImmediately then
					effectId = targetEntity:playEffect(effectStr, extraData)
				end

				targetEntity.characterStateConditionalEffects[effectStr] = {
					effectId = effectId,
					extraData = extraData,
					applyInState = actionData.applyInCharacterStates
				}

				local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

				if not abilityObject then
					return false
				end

				abilityObject:addExitCallback(function()
					if targetEntity.characterStateConditionalEffects[effectStr] ~= nil then
						local curEffectId = targetEntity.characterStateConditionalEffects[effectStr].effectId

						if curEffectId ~= nil then
							targetEntity:stopEffectById(curEffectId)
						end
					end

					targetEntity.characterStateConditionalEffects[effectStr] = nil
				end)
			else
				effectId = targetEntity:playEffect(effectStr, extraData)
			end

			if actionData.isAbilityEndRemove == true then
				local ability = CombatActionTool.getCasterAbility(combatContext)

				if ability and ownerEntity.addAbilityEffect then
					ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability.abilityId, effectId, false)
				end
			end

			return true
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playEffectStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:stopEffectStr(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local effectStr = self:getVal(actionData.effectId, combatContext)
		local reclaim = actionData.reclaim
		local linkTarget = actionData.linkTarget
		local linkActorId = 0

		if linkTarget ~= nil then
			linkActorId = CombatActionTool.parseActorId(combatContext, linkTarget)

			if linkActorId and linkActorId ~= 0 then
				-- block empty
			elseif LoggerManager.checkLogger(LoggerConst.WARN) then
				CombatLogger.warn("@dl targetEntity:stopEffectStr linkTargetEntity is nil", actionData.linkTarget)
			end
		end

		local masterEntity = targetEntity.getMasterEntity and targetEntity:getMasterEntity() or targetEntity

		if masterEntity.inheritEffectMap and masterEntity.inheritEffectMap[effectStr] then
			for _, petId in ipairs(masterEntity.petPrepareList) do
				local petEntity = pg.getEntity(petId)

				if petEntity ~= targetEntity and petEntity then
					petEntity:stopEffect(effectStr, reclaim, nil, true, linkActorId)
				end
			end

			masterEntity.inheritEffectMap[effectStr] = nil
		end

		targetEntity:stopEffect(effectStr, reclaim, nil, true, linkActorId)

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:stopEffectStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:dropEffectStr(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local effectStr = actionData.effectId
		local masterEntity = targetEntity.getMasterEntity and targetEntity:getMasterEntity() or targetEntity

		if masterEntity.inheritEffectMap and masterEntity.inheritEffectMap[effectStr] then
			masterEntity.inheritEffectMap[effectStr] = nil
		end

		targetEntity:dropEffect(effectStr)

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:dropEffectStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:setEffectAnimTrigger(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local effectKey = actionData.effectId
		local triggerName = actionData.triggerName

		targetEntity:setEffectAnimTrigger(effectKey, triggerName)

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:setEffectAnimTrigger failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:playSoundStr(actionData, combatContext)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playSoundStr", actionData.soundId)
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		local buff = combatContext:buff()

		targetEntity = buff and buff.buffData and buff.buffData.isTeamBuff and targetEntity.getCurPetEntity and targetEntity:getCurPetEntity() or targetEntity
	end

	if targetEntity ~= nil then
		local soundId = self:getVal(actionData.soundId, combatContext)

		targetEntity:playSoundEvent(soundId)

		if ToBool(combatContext.abilityId) and actionData.isAbilityEndRemove ~= false then
			local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)

			if targetEntity.addAbilitySound then
				targetEntity:addAbilitySound(casterActorId, targetEntity.actorId, combatContext.abilityId, soundId)
			end
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playSoundStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:stopSoundStr(actionData, combatContext)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("stopSoundStr", actionData.soundId)
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local soundId = actionData.soundId

		targetEntity:stopSoundEvent(soundId)

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("ClientCombatAction:stopSoundStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:playHitAnimation(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local animId = actionData.animId

		if targetEntity.useHitBox and animId == "Hit_Shake" then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("playHitAnimation ignore, play Hit_Shake by playHitPartAnimation")
			end

			return false
		end

		local state = targetEntity:playAbilityAnimation(animId, 0, 0)

		if state then
			state:AddAutoTransition(0)

			local hitStat = animId == "Hit_L" and "HIT_L_ST" or animId == "Hit_H" and "HIT_H_ST" or nil

			if hitStat and targetEntity.setStateCacheValue then
				targetEntity:setStateCacheValue(hitStat, true)
				state:AddEndCallback(function()
					targetEntity:setStateCacheValue(hitStat, false)
				end)
			end

			local rootMotionScale = actionData.rootMotionScale

			if rootMotionScale and targetEntity:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
				targetEntity:setRootMotionScale(rootMotionScale)
				state:AddEndCallback(function()
					targetEntity:setRootMotionScale(1)
				end)
			end
		end

		local hitParams = combatContext:getHitActionTimelineParam()

		if state and hitParams.attackData and hitParams.attackData.applyRootMotion == false then
			state:OverrideMotionType(0)
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playHitAnimation failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:playHitPartAnimation(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		if targetEntity.useHitBox then
			local partData = ClientAbilityUtils.getPartData(targetEntity, combatContext.runtimeTargetInfo.hitActorPartIdx)
			local hitAni = ClientAbilityConst.HIT_BOX_PART_ANIS[partData and partData.part]

			if not hitAni then
				return false
			end

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("play hitbox ani", hitAni, combatContext.runtimeTargetInfo.hitActorPartIdx)
			end

			targetEntity:playAbilityAnimation(hitAni, 0, 0)

			local eModel = targetEntity.eModel
			local modelShaderView = eModel and eModel.modelShaderView

			if NotNil(modelShaderView) then
				modelShaderView:PlayHitFlash(partData.shaderPartIndex)
			end

			return true
		end
	else
		return false
	end
end

function ClientCombatAction:playHitEffect(actionData, combatContext)
	if CombatActionTool.isCasterAuthorityMaster(combatContext) then
		return true
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		if combatContext:timeline() == nil then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("playHitEffect must in hitTimeline")
			end

			return false
		end

		local hitParams = combatContext:getHitActionTimelineParam()

		if not hitParams then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@jqj hitParams not found")
			end

			return false
		end

		local attackData = hitParams.attackData

		if not attackData then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("@jqj attackData not found")
			end

			return false
		end

		local hitEffectList

		if ToBool(actionData.hitEffect) then
			hitEffectList = actionData.hitEffect
		elseif ToBool(attackData.hitEffect) then
			hitEffectList = attackData.hitEffect
		end

		if hitParams.targetHitPos == nil then
			CombatActionTool.logDebug(combatContext, actionData, "targetHitPos not found")

			return false
		end

		ClientAbilityUtils.playHitEffects(hitEffectList or {}, attackData.defaultHitEffect, attackData.hitEffectByAction, hitParams.targetHitPos, targetEntity, combatContext, attackData)

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playHitEffect failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:playHitSound(actionData, combatContext)
	local hitParams = combatContext:getHitActionTimelineParam()

	if not hitParams then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj hitParams not found")
		end

		return false
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@jqj ClientCombatAction:playHitSound, targetEntity is nil", targetActorId)
	end

	local attackData = hitParams.attackData
	local hitPos = hitParams.targetHitPos

	if hitPos == nil then
		CombatActionTool.logDebug(combatContext, actionData, "targetHitPos not found")

		return false
	end

	local entityConfigData = Utils.getEntityConfigData(targetEntity)
	local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext, targetEntity, true)

	if not CombatActionTool.isCasterAuthorityMaster(combatContext) then
		local soundProjectile = combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE and not combatContext.inActOnTargets

		if attackData.soundRangeType ~= nil then
			soundProjectile = attackData.soundRangeType == ClientAbilityConst.SOUND_RANGE_TYPE.Projectile
		end

		if soundProjectile then
			local elementType = CombatActionTool.getAttackElementType(attackData, combatContext)

			pg.game.audio:playProjectileHit(elementType, attackData.hitSoundType, hitPos, combatRTPCType)
		else
			pg.game.audio:playHit(attackData.weaponSoundType, attackData.hitSoundType, entityConfigData.bodyMatType, hitPos, combatRTPCType)
		end

		local hitSoundStr = attackData and attackData.hitSoundStr

		pg.game.audio:playHitById(hitSoundStr, hitParams.targetHitPos, combatRTPCType)
	end

	if combatContext:timeline() == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("@jqj must be base type COMBAT_CONTEXT_CLASS_FLAG_ActionTimelineBase")
	end

	return true
end

function ClientCombatAction:applyHitCameraImpulse(actionData, combatContext)
	if CombatActionTool.isCasterAuthorityMaster(combatContext) then
		return true
	end

	if not pg.pawn then
		return false
	end

	if combatContext:timeline() == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj ctx type error", combatContext.className)
		end

		return false
	end

	local hitParams = combatContext:getHitActionTimelineParam()

	if not hitParams then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj hitParams not found")
		end

		return false
	end

	local attackData = hitParams.attackData

	if not attackData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj attackData not found")
		end

		return false
	end

	lume.clear(cameraShakeCache)

	local cameraShakeData = Utils.deepCopyTable(CameraShakeData[AbilityUtils.getAttackDataHitCameraShakeId(attackData)], nil, cameraShakeCache)

	if cameraShakeData then
		cameraShakeData.affectCameraAnim = true

		self:innerPlayerCameraImpulse(attackData, combatContext, cameraShakeData, true)
	end
end

function ClientCombatAction:playRumble(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj playRumble targetEntity not found", targetActorId)
		end

		return false
	end

	if targetEntity ~= pg.pawn then
		return false
	end

	local layerId = actionData.layerId
	local rumbleName = actionData.rumbleName

	if string.isNilOrEmpty(rumbleName) then
		return false
	end

	pg.game.input:playRumbleByName(layerId, rumbleName)
end

function ClientCombatAction:stopRumble(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj playRumble targetEntity not found", targetActorId)
		end

		return false
	end

	if targetEntity ~= pg.pawn then
		return false
	end

	local layerId = actionData.layerId

	pg.game.input:stopRumble(layerId)
end

function ClientCombatAction:playEffectOnPosRot(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	Vector3.enableCreateFromCache()

	local effectId = self:getVal(actionData.effectId, combatContext)
	local posType = actionData.pos
	local rotFromType = actionData.rot
	local rotToType = actionData.rotTo
	local attackSpeed = targetActorId == combatContext.actorId and combatContext.attackSpeed or 1
	local speed = (actionData.speed or 1) * attackSpeed
	local scale = self:getVal(actionData.scale, combatContext)
	local global = actionData.global
	local offsetXYZ = Vector3()

	if actionData.offsetXYZ then
		offsetXYZ = actionData.offsetXYZ.name == nil and Vector3(unpack(actionData.offsetXYZ)) or self:doAction(actionData.offsetXYZ, combatContext)
	end

	local offsetRotation = Vector3()

	if actionData.offsetRotation then
		offsetRotation = actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)
	end

	local originPos = targetEntity:getPosition():Clone()

	CombatActionTool.parsePosition(combatContext, posType, originPos)

	local originRot = targetEntity:getRotation():Clone()

	CombatActionTool.parseRotationFromTo(combatContext, rotFromType, rotToType, originRot)

	originPos = CombatActionTool.translatePoint(originPos, originRot, offsetXYZ * (targetEntity.curModelScale or 1))

	if offsetRotation.x ~= 0 and offsetRotation.x ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT)
	end

	if offsetRotation.y ~= 0 and offsetRotation.y ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP)
	end

	if offsetRotation.z ~= 0 and offsetRotation.z ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD)
	end

	local effectPos = originPos:Clone()
	local effectRotation = originRot:ToEulerAngles()
	local extInfo = {
		position = effectPos,
		rotation = effectRotation,
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global,
		speed = speed,
		scale = scale and scale > 0 and scale or nil
	}

	self:setEffectExtraData(extInfo, combatContext, targetEntity)

	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	ClientAbilityUtils.setEffectMpeLodInfo(extInfo, targetEntity, casterEntity)

	if combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_FINISH or combatContext.triggerType == AbilityConst.TRIGGER_ON_PROJECT_HIT then
		local runtimeTarget = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

		if runtimeTarget and runtimeTarget.replaceHitEffect then
			effectId = runtimeTarget.replaceHitEffect
		end
	end

	local effectInsId, ownerEntity

	if not global then
		effectInsId = targetEntity:playEffect(effectId, extInfo)

		if actionData.isAbilityEndRemove then
			ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

			local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
			local ability = CombatActionTool.getCasterAbility(combatContext)

			if ability and ownerEntity and ownerEntity.addAbilityEffect then
				ownerEntity:addAbilityEffect(targetActorId, casterActorId, ability.abilityId, effectInsId, false)
			end
		end
	else
		local realEffectId = targetEntity:getRealEffectKey(effectId)

		pg.game.effect:worldEffectApplyScale(realEffectId, extInfo, targetEntity)

		effectInsId = pg.game.effect:playEffect(0, realEffectId, extInfo)

		if actionData.isAbilityEndRemove then
			ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

			local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
			local ability = CombatActionTool.getCasterAbility(combatContext)

			if ability and ownerEntity and ownerEntity.addAbilityEffect then
				ownerEntity:addAbilityEffect(targetActorId, casterActorId, ability.abilityId, effectInsId, true)
			end
		end
	end

	local effectStoreKey = self:getVal(actionData.effectStoreKey, combatContext)

	if effectStoreKey and ownerEntity then
		ownerEntity[effectStoreKey] = effectInsId
	end

	Vector3.disableCreateFromCache()

	return true
end

function ClientCombatAction:playCameraImpulseById(actionData, combatContext)
	local cameraShakeData = CameraShakeData[actionData.cameraShakeId]

	if not cameraShakeData then
		return false
	end

	local shakeInfo = {}

	table.merge(shakeInfo, cameraShakeData)

	shakeInfo.checkCasterIsPlayer = actionData.checkCasterIsPlayer
	shakeInfo.affectCameraAnim = actionData.affectCameraAnim

	self:innerPlayerCameraImpulse(actionData, combatContext, shakeInfo, false)
end

function ClientCombatAction:innerPlayerCameraImpulse(actionData, combatContext, shakeInfo, isHit)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target or "OWNER")
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local shakeCenter = pg.pawn:getPosition()

	if targetEntity ~= nil then
		shakeCenter = targetEntity:getPosition()
	end

	local checkCasterIsPlayer = true

	if actionData.checkCasterIsPlayer ~= nil then
		checkCasterIsPlayer = actionData.checkCasterIsPlayer
	end

	local casterId = CombatActionTool.parseActorIdSrc(combatContext)

	if isHit then
		if checkCasterIsPlayer then
			if casterId ~= pg.pawn.actorId then
				return false
			end
		elseif targetActorId ~= pg.pawn.actorId then
			return false
		end
	elseif checkCasterIsPlayer and casterId ~= pg.pawn.actorId then
		return false
	end

	if not actionData.ignoreShakeCD and casterId == pg.pawn.actorId then
		local lastPawnImpulseTime = pg.pawn.lastPawnImpulseTime
		local playerImpulseCD = AbilitySettingGlobalConstData.playerCameraImpulseCD or AbilityConst.PLAYER_IMPULSE_CD

		if lastPawnImpulseTime and lastPawnImpulseTime + playerImpulseCD > Time.realSecondCache then
			return false
		end

		pg.pawn.lastPawnImpulseTime = Time.realSecondCache
	end

	shakeInfo.shakePos = shakeCenter:Clone()

	if ToBool(shakeInfo.cameraShakePrefab) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("ClientCombatAction:innerPlayerCameraImpulse", shakeInfo.cameraShakePrefab)
		end

		local entity = pg.pawn or pg.me or targetEntity
		local originRot = pg.pawn:getRotation()

		if targetEntity ~= nil then
			originRot = targetEntity:getRotation()
		end

		lume.clear(cameraShakeEffectExtInfo)

		cameraShakeEffectExtInfo = {
			position = shakeInfo.shakePos,
			rotation = originRot:Clone():ToEulerAngles(),
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global
		}

		entity:playEffect(shakeInfo.cameraShakePrefab, cameraShakeEffectExtInfo)

		return
	end

	pg.game.camera:playCameraShake(targetEntity, shakeInfo)

	return true
end

function ClientCombatAction:playCameraImpulse(actionData, combatContext, isHit)
	local impulseInfo = {}

	impulseInfo.shakeType = CameraConst.CameraShakeType.Circular

	if type(actionData.dirMode) == "number" then
		impulseInfo.dirMode = actionData.dirMode
	else
		impulseInfo.dirMode = actionData.dirMode and AbilityConst.CAMERA_IMPULSE_DIR_ENUM[actionData.dirMode] or AbilitySettingGlobalConstData.cameraImpulseDirMode
	end

	impulseInfo.shakeTime = actionData.shakeTime or AbilitySettingGlobalConstData.cameraImpulseShakeTime
	impulseInfo.shakeKeepTime = actionData.shakeKeepTime or 0.1
	impulseInfo.shakeDissipation = actionData.shakeDissipationDistance or AbilitySettingGlobalConstData.cameraImpulseShakeDistance
	impulseInfo.shakeRadius = actionData.shakeRadius or AbilitySettingGlobalConstData.cameraImpulseShakeRadius
	impulseInfo.affectCameraAnim = actionData.affectCameraAnim
	impulseInfo.shakeFrequency = actionData.shakeFrequency or AbilitySettingGlobalConstData.cameraImpulseShakeFrequency
	impulseInfo.shakeAmplitude = actionData.shakeAmplitude or AbilitySettingGlobalConstData.cameraImpulseShakeAmplitude

	local isCenter = actionData.isCenter or AbilitySettingGlobalConstData.cameraImpulseIsCenter
	local offset = isCenter and isCenter ~= 0 and 0 or 1

	impulseInfo.offset = offset
	impulseInfo.shakeDir = actionData.shakeDir or {
		0,
		0,
		1
	}
	impulseInfo.random = actionData.random or false

	return self:innerPlayerCameraImpulse(actionData, combatContext, impulseInfo, isHit)
end

function ClientCombatAction:playCameraImpulseAnim(actionData, combatContext)
	if not pg.pawn then
		return false
	end

	local impulseInfo = {}

	impulseInfo.shakeType = CameraConst.CameraShakeType.ShakeAnim
	impulseInfo.shakeTime = actionData.shakeTime or AbilitySettingGlobalConstData.cameraImpulseShakeTime
	impulseInfo.shakeKeepTime = actionData.shakeKeepTime or 0
	impulseInfo.shakeDissipation = actionData.shakeDissipationDistance or AbilitySettingGlobalConstData.cameraImpulseShakeDistance
	impulseInfo.shakeRadius = actionData.shakeRadius or AbilitySettingGlobalConstData.cameraImpulseShakeRadius
	impulseInfo.affectCameraAnim = actionData.affectCameraAnim
	impulseInfo.cameraShakeAnimName = actionData.cameraShakeAnimName

	return self:innerPlayerCameraImpulse(actionData, combatContext, impulseInfo)
end

function ClientCombatAction:playCameraPerlinNoiseImpulse(actionData, combatContext)
	if not pg.pawn then
		return false
	end

	local impulseInfo = {}

	impulseInfo.shakeType = CameraConst.CameraShakeType.PerlinNoise
	impulseInfo.shakeTime = actionData.shakeTime or AbilitySettingGlobalConstData.cameraImpulseShakeTime
	impulseInfo.shakeKeepTime = actionData.shakeKeepTime or 0
	impulseInfo.shakeDissipation = actionData.shakeDissipationDistance or AbilitySettingGlobalConstData.cameraImpulseShakeDistance
	impulseInfo.shakeRadius = actionData.shakeRadius or AbilitySettingGlobalConstData.cameraImpulseShakeRadius
	impulseInfo.affectCameraAnim = actionData.affectCameraAnim
	impulseInfo.noisePosSeeds = actionData.noisePosSeeds or {
		0,
		0,
		0
	}
	impulseInfo.noiseRotSeeds = actionData.noiseRotSeeds or {
		0,
		0,
		0
	}
	impulseInfo.shakeFrequency = actionData.shakeFrequency or AbilitySettingGlobalConstData.cameraImpulseShakeFrequency
	impulseInfo.noisePosAmplitudes = actionData.noisePosAmplitudes or {
		0,
		0,
		0
	}
	impulseInfo.noiseRotAmplitudes = actionData.noiseRotAmplitudes or {
		0,
		0,
		0
	}

	return self:innerPlayerCameraImpulse(actionData, combatContext, impulseInfo)
end

function ClientCombatAction:setCameraDistanceScale(actionData, combatContext)
	local distanceScale = actionData.distanceScale
	local maxTime = actionData.maxTime

	pg.game.camera:overrideCameraDistanceScale(distanceScale, maxTime)
end

function ClientCombatAction:resetCameraDistanceScale(actionData, combatContext)
	pg.game.camera:resetCameraDistanceScale()
end

function ClientCombatAction:cameraEvent(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	if pg.pawn == targetEntity then
		local params = string.split(actionData.param, ",")
		local eventName = params[1]

		if not eventName then
			return false
		end

		local needReset, resetEventName = pg.game.camera.playerCameraMode:onCameraEvent(params)
		local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

		if ownerEntity then
			local ability = CombatActionTool.getCasterAbility(combatContext)

			if needReset then
				if ownerEntity.addAbilityCameraResetEvent then
					ownerEntity:addAbilityCameraResetEvent(ability and ability.abilityId, resetEventName)
				end
			elseif resetEventName and ownerEntity.removeAbilityCameraResetEvent then
				ownerEntity:removeAbilityCameraResetEvent(ability and ability.abilityId, resetEventName)
			end
		end
	end

	return true
end

function ClientCombatAction:lockTarget(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local timeline = combatContext:timeline()

	if timeline and timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		local entityConfigData = targetEntity:getConfigData()
		local attackData = timeline.timelineParams.hitParams.attackData

		if attackData and attackData.ignoreHitLockTarget or entityConfigData and ToBool(entityConfigData.ignoreHitLockTarget) then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("ignore lockTarget", targetActorId)
			end

			return false
		end
	end

	local instantTurn = false

	if targetEntity.isBTPaused and not targetEntity:isBTPaused() then
		instantTurn = true
	elseif timeline and timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		instantTurn = true
	end

	local lockTargetId = CombatActionTool.parseActorId(combatContext, actionData.lockTarget or AbilityConst.COMBAT_TARGET_TYPE_TARGET)

	if not ToBool(lockTargetId) then
		lockTargetId = combatContext.constCasterInfo.chaseActorId
	end

	if targetEntity.actorLockTarget then
		local partId = combatContext.constCasterInfo and combatContext.constCasterInfo.partId

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("lockTarget", lockTargetId)
		end

		targetEntity:actorLockTarget(lockTargetId, partId, instantTurn)
	end

	return true
end

function ClientCombatAction:teleport(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	Vector3.enableCreateFromCache()

	local teleportPosTarget = actionData.target
	local rotationRefTarget = actionData.rotRefTarget or teleportPosTarget
	local offsetXYZ = Vector3.New(unpack(actionData.offsetXYZ))
	local offsetRotation = Vector3.New(unpack(actionData.offsetRotation))
	local originPos = Vector3(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, teleportPosTarget, originPos) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("teleport, target not found", teleportPosTarget, combatContext.BPName, actionData.NodeID)
		end

		if actionData.failedActionIds then
			Vector3.disableCreateFromCache()

			return self:doActionIds(actionData.failedActionIds, combatContext)
		end

		Vector3.disableCreateFromCache()

		return false
	end

	local originRot = ownerEntity:getRotation():Clone()

	if (not Utils.isTable(rotationRefTarget) or rotationRefTarget ~= teleportPosTarget) and CombatActionTool.parseRotation(combatContext, rotationRefTarget, originRot) then
		local eulerAngles = Quaternion.ToEulerAngles(originRot)

		Quaternion.SetEuler(originRot, 0, eulerAngles.y, 0)
	end

	originPos = CombatActionTool.translatePoint(originPos, originRot, offsetXYZ)
	originPos = PhysicsUtils.getGroundPos(originPos, 2) or originPos

	if offsetRotation.x ~= 0 and offsetRotation.x ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT)
	end

	if offsetRotation.y ~= 0 and offsetRotation.y ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP)
	end

	if offsetRotation.z ~= 0 and offsetRotation.z ~= nil then
		originRot = originRot * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD)
	end

	local performerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.performer or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if performerEntity ~= nil and performerEntity.eModel then
		local findValidPos, teleportPos = performerEntity.eModel:GetTeleportPos(Const.COMPONENT_AUTO_PATH_FIND, originPos, actionData.checkGroundLayer, actionData.raycastBlockedHandle or 0)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("GetTeleportPos, valid, teleportPos, originPos", findValidPos, inspect(teleportPos), inspect(originPos))
		end

		if findValidPos then
			if actionData.faceToTarget then
				local faceToPos = Vector3.zero

				if CombatActionTool.parsePosition(combatContext, actionData.faceToTarget, faceToPos) then
					local dir = faceToPos - teleportPos

					dir.y = 0

					if dir:Magnitude() > 0.01 then
						dir:SetNormalize()

						originRot = Quaternion.LookRotation(dir, VEC3_CONST_UP)
					end
				end
			end

			if actionData.maintainHeight then
				local originHeight = performerEntity:getPositionAgentPosition().y

				teleportPos.y = originHeight
			end

			performerEntity:serverMsgNoGC("RPC_CS_NotifyAbilityTeleport", combatContext.id, combatContext.nodeStack, teleportPos, originRot)
			EModelUtils.setAgentPositionAndRotation(performerEntity, teleportPos, originRot, true, Const.AgentTransformReasonConst.TeleportFromLua)
			pg.world.setIsSyncPosThisFrame(performerEntity.actorId, true)

			if ownerEntity and ownerEntity.authority == Const.AUTHORITY_MASTER and combatContext.castingCombatContextId then
				ownerEntity:serverMsg("RPC_CS_DisableReturnAbilityConsumes", combatContext.castingCombatContextId)
			end

			Vector3.disableCreateFromCache()

			return true
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("valid teleport pos not found", performerEntity.space.sceneId, inspect(originPos))
		end
	end

	if ownerEntity and ownerEntity.authority == Const.AUTHORITY_MASTER and combatContext.castingCombatContextId then
		ownerEntity:serverMsg("RPC_CS_DisableReturnAbilityConsumes", combatContext.castingCombatContextId)
	end

	if actionData.failedActionIds then
		Vector3.disableCreateFromCache()

		return self:doActionIds(actionData.failedActionIds, combatContext)
	end

	Vector3.disableCreateFromCache()
end

function ClientCombatAction:setSkillHitDistance(actionData, combatContext)
	local skillHitDisplacementId = actionData.skillHitDisplacementId

	if not ToBool(skillHitDisplacementId) then
		return false
	end

	local target = actionData.target
	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	if targetEntity.isDummyClone then
		return false
	end

	local lockedActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)

	if not ToBool(lockedActorId) then
		lockedActorId = combatContext.constCasterInfo.chaseActorId
	end

	if targetEntity.skillHitDisplacementCtrl and ToBool(lockedActorId) then
		local lockedEnt = pg.getEntityByActorId(lockedActorId)

		if lockedEnt ~= nil then
			local skillHitDisplacementData = HitDisplacementData[skillHitDisplacementId]

			if not skillHitDisplacementData then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("skillHitDisplacementData not found", skillHitDisplacementId)
				end

				return false
			end

			local lockedEntPos = Vector3.Clone(lockedEnt:getLockPartPosition(pg.me.lockedPartId))
			local targetEntityPos = targetEntity:getPosition()
			local combatContextClone = combatContext:clone()
			local abilityObject = combatContext:ability():getAbilityObject()
			local overridePos = abilityObject and abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_PUPPET_SKILL_HIT_DISTANCE]

			if overridePos then
				CombatActionTool.parsePosition(combatContext, overridePos, lockedEntPos)
			end

			local dir = Vector3.SetNormalize(lockedEntPos - targetEntityPos)

			dir.y = 0

			Vector3.SetNormalize(dir)
			targetEntity.skillHitDisplacementCtrl:setupDisplacementData(skillHitDisplacementId, lockedEnt, combatContextClone, dir)
		end
	end

	return false
end

function ClientCombatAction:playSkillCameraAnim(actionData, combatContext)
	local animResId = actionData.animResId
	local target = actionData.target
	local forcePlay = actionData.forcePlay
	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		return false
	end

	local pivotOffset = Vector3(0, targetEntity:getHeight() * 0.5, 0)

	if targetEntity == nil then
		return false
	end

	local needPlay = false
	local inheritDir = false

	if targetEntity == pg.pawn then
		needPlay = true
		inheritDir = true
	elseif Utils.isPlayerPet(targetEntity) and targetEntity.master == pg.me then
		needPlay = true
		inheritDir = false
	elseif forcePlay then
		needPlay = true
		inheritDir = true
	end

	if actionData.noInheritDir then
		inheritDir = false
	end

	if not needPlay then
		return false
	end

	local player = AbilityUtils.getPlayer(targetEntity)
	local abilityTemplate = combatContext:getAbilityTemplate()
	local cutSceneDuration = abilityTemplate and abilityTemplate.cutSceneDuration or 0

	if cutSceneDuration > 0 then
		if player and player.isCutSceneFastforward then
			return true
		end

		if player and player.space and player.space:checkSkipSkillCutScene() then
			return true
		end
	end

	pg.game.camera.playerCameraMode:interruptNormalAttackLockOnCamera()

	local scale = 1

	if targetEntity.getBaseModelScale then
		scale = targetEntity:getBaseModelScale()
	end

	local whiteList = {}

	whiteList[UIConst.UI_ID_QTE] = true
	whiteList[UIConst.UI_ID_CHAIN_ATTACK] = true
	whiteList[UIConst.UI_ID_DAMAGE_NUMBER] = true

	local function endCallback()
		if not targetEntity.CHAIN_ATTACK_ST or not targetEntity:CHAIN_ATTACK_ST() then
			pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.ULTIMATE)
		end

		if pg.game.camera.playerCameraMode.lockOnExtendCamera:isActive() then
			local lockEnt = pg.getEntityByActorId(pg.me.lockedActorId)

			if lockEnt then
				pg.game.camera.playerCameraMode:setLockOnCameraTarget(lockEnt, pg.me.lockedPartId)
			end
		end
	end

	local checkCollide = true

	if actionData.noCollideCheck then
		checkCollide = false
	end

	targetEntity.isSkillCameraAnimInvincible = true

	AbilityUtils.setAbilityInvalidTarget(targetEntity, AbilityConst.INVALID_TARGET_REASONS.SKILL_CAMERA_ANIM_INVINCIBLE, targetEntity.isSkillCameraAnimInvincible == true)
	targetEntity:addTimer(0.5, function()
		targetEntity.isSkillCameraAnimInvincible = nil

		AbilityUtils.setAbilityInvalidTarget(targetEntity, AbilityConst.INVALID_TARGET_REASONS.SKILL_CAMERA_ANIM_INVINCIBLE, targetEntity.isSkillCameraAnimInvincible == true)
	end)

	local checkFirstFrameCollide = actionData.checkFirstFrameCollide or false

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.ULTIMATE, whiteList)
	pg.game.camera:playCameraAnimByEntity(targetEntity, animResId, actionData.blendInTime or 0, actionData.blendOutTime or 1, inheritDir, nil, pivotOffset, checkFirstFrameCollide, checkCollide, scale, endCallback)

	if not ToBool(actionData.notStopOnExit) then
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			pg.game.camera:stopCameraAnim()

			targetEntity.isSkillCameraAnimInvincible = nil

			AbilityUtils.setAbilityInvalidTarget(targetEntity, AbilityConst.INVALID_TARGET_REASONS.SKILL_CAMERA_ANIM_INVINCIBLE, targetEntity.isSkillCameraAnimInvincible == true)
		end)
	end

	return true
end

function ClientCombatAction:stopSkillCameraAnim(actionData, combatContext)
	local target = actionData.target
	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or AbilityUtils.getPlayer(targetEntity) ~= pg.me then
		return false
	end

	if self.delayStopCameraAnimTimer then
		TimerManager.removeTimer(self.delayStopCameraAnimTimer)

		self.delayStopCameraAnimTimer = nil
	end

	if pg.global.abilityMgr.isPlayingCutScene then
		pg.global.abilityMgr.stopCameraAniEnt = targetEntity
	else
		self.delayStopCameraAnimTimer = TimerManager.addTimer(0.1, function()
			self.delayStopCameraAnimTimer = nil

			ClientCombatAction:doStopSkillCameraAnim(targetEntity)
		end)
	end

	return true
end

function ClientCombatAction:doStopSkillCameraAnim(targetEntity)
	pg.game.camera:stopCameraAnim()

	targetEntity.isSkillCameraAnimInvincible = nil

	AbilityUtils.setAbilityInvalidTarget(targetEntity, AbilityConst.INVALID_TARGET_REASONS.SKILL_CAMERA_ANIM_INVINCIBLE, targetEntity.isSkillCameraAnimInvincible == true)
end

function ClientCombatAction:playPitchYawCameraAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or targetEntity ~= pg.pawn then
		return false
	end

	local blendInTime = actionData.blendInTime
	local duration = actionData.duration or -1
	local pitchCurveName = actionData.pitchCurveName
	local yawCurveName = actionData.yawCurveName

	pg.game.camera.playerCameraMode:playPitchYawCurveAnim(blendInTime, duration, pitchCurveName, yawCurveName)
end

function ClientCombatAction:cancelPitchYawCameraAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or targetEntity ~= pg.pawn then
		return false
	end

	pg.game.camera.playerCameraMode:cancelPitchYawCurveAnim()
end

function ClientCombatAction:playFovCameraAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or targetEntity ~= pg.pawn then
		return false
	end

	local blendInTime = actionData.blendInTime
	local duration = actionData.duration or -1
	local blendOutTime = actionData.blendOutTime
	local fovCurveName = actionData.fovCurveName
	local forbidFovCameraOnRepeat = actionData.forbidFovCameraOnRepeat

	pg.game.camera.playerCameraMode:playFovCurveAnim(fovCurveName, blendInTime, duration, blendOutTime, forbidFovCameraOnRepeat)
end

function ClientCombatAction:cancelFovCameraAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or targetEntity ~= pg.pawn then
		return false
	end

	pg.game.camera.playerCameraMode:cancelFovCurveAnim()
end

function ClientCombatAction:cameraBlendToPitch(actionData, combatContext)
	local targetPitch = actionData.targetPitch

	pg.game.camera.playerCameraMode:blendToPitch(targetPitch, 2)
end

function ClientCombatAction:lockOnCameraSetExtraYAngle(actionData, combatContext)
	local extraAngle = actionData.extraAngle
	local keepTime = actionData.keepTime

	pg.game.camera.playerCameraMode:setLockOnCameraExtraYAngle(extraAngle, keepTime)
end

function ClientCombatAction:resetLockOnCameraExtraYAngle()
	pg.game.camera.playerCameraMode:resetLockOnCameraExtraYAngle()
end

function ClientCombatAction:forceNotGroundCheck(actionData, combatContext)
	local notCheckTime = actionData.notCheckTime
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity or not targetEntity.eModel then
		return false
	end

	targetEntity.eModel:ForceNotGroundCheck(Const.COMPONENT_MOTION, notCheckTime)
end

function ClientCombatAction:cameraFaceTo(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	pg.game.camera:cameraFaceToTarget(targetEntity, actionData.heightOffset, actionData.maxLockTime)
end

function ClientCombatAction:cancelCameraFaceTo(actionData, combatContext)
	pg.game.camera:cameraFaceToTarget(nil)
end

function ClientCombatAction:cameraLockOnTarget(actionData, combatContext)
	local casterId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local caster = pg.getEntityByActorId(casterId)

	if actionData.checkCaster ~= false and (caster == nil or caster ~= pg.pawn) then
		return false
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	pg.game.camera.playerCameraMode:lockOnTargetThirdPerson(targetEntity, actionData.shoulder, actionData.pitch)
end

function ClientCombatAction:cancelCameraLockOnTarget(actionData, combatContext)
	local casterId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local caster = pg.getEntityByActorId(casterId)

	if actionData.checkCaster ~= false and (caster == nil or caster ~= pg.pawn) then
		return false
	end

	pg.game.camera.playerCameraMode:lockOnTargetThirdPerson(nil)
end

function ClientCombatAction:playRadialBlur(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity ~= pg.pawn then
		return false
	end

	local duration = actionData.duration or -1

	pg.game.camera:playRadialBlur(actionData.configName, duration)

	return true
end

function ClientCombatAction:changeControlState(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("Target not found", actionData.target)
		end

		return false
	end

	AnimationUtils.playAnimationState(targetEntity, CharacterStateConst[actionData.controlState])
end

function ClientCombatAction:fly(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if actionData.flyHeight and ownerEntity.setEntityCacheVal then
		ownerEntity:setEntityCacheVal(AbilityConst.ABILITY_FLY_OVERRIDE_FLY_HEIGHT, actionData.flyHeight)
	end

	ownerEntity.overrideFlyRiseAnim = nil

	if actionData.overrideFlyRiseAnim then
		local key = AnimationUtils.getID(actionData.overrideFlyRiseAnim)

		if key then
			ownerEntity.overrideFlyRiseAnim = key
		end
	end

	if ownerEntity.fly then
		ownerEntity:fly()
	end
end

function ClientCombatAction:stopFly(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity then
		if targetEntity.stopFly then
			targetEntity:stopFly()
		end

		targetEntity.overrideFlyRiseAnim = nil
	end
end

function ClientCombatAction:refreshOverrideFlyHeight(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and ownerEntity.isMainPet and ownerEntity:FLY_ST() and ownerEntity.eModel then
		ownerEntity.eModel:RefreshOverrideFlyHeight(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, actionData.flyHeight)
	end
end

function ClientCombatAction:switchInflateState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity.eModel then
		return
	end

	local eModel = ownerEntity.eModel

	if not ownerEntity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		return
	end

	local isInFlate = eModel.controllerData.inflateDuration > 0

	if actionData.enable then
		eModel.controllerData.inflateBsChannel = 0
		CS.FunPlus.WorldX.ControllerData.inflateBsFadeIn = SysConfigData.inflateFadeInTime
		CS.FunPlus.WorldX.ControllerData.inflateBsFadeOut = SysConfigData.inflateFadeOutTime

		eModel:SwitchInflate(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, SysConfigData.inflateStateDuration)

		if not isInFlate and ownerEntity.callInflateStateChange then
			ownerEntity:callInflateStateChange(true)
		end
	else
		eModel:SwitchInflate(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, 0)

		if isInFlate and ownerEntity.callInflateStateChange then
			ownerEntity:callInflateStateChange(false)
		end
	end
end

function ClientCombatAction:setIgnoreActorCollisionEnabled(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity and targetEntity.eModel and targetEntity:hasEModelComponent(Const.COMPONENT_MOTION) then
		local ignoreSelf = true

		if actionData.ignoreSelf ~= nil then
			ignoreSelf = actionData.ignoreSelf
		end

		targetEntity.eModel:SetIgnoreActorCollision(Const.COMPONENT_MOTION, actionData.value, ignoreSelf)

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			targetEntity.eModel:SetIgnoreActorCollision(Const.COMPONENT_MOTION, false)
		end)
	end
end

function ClientCombatAction:preDoHitAction(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))
	local attackData = actionData.attackData

	if not attackData then
		return
	end

	if not targetEntity then
		return false
	end

	local hitPos = Vector3.getFromCache()

	CombatActionTool.parseHitPos(combatContext, hitPos)

	local rawOwnerActorId = combatContext.actorId

	combatContext.actorId = targetEntity.actorId

	local entityConfigData = Utils.getEntityConfigData(targetEntity)
	local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext, targetEntity, true)
	local soundProjectile = combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE and not combatContext.inActOnTargets

	if attackData.soundRangeType ~= nil then
		soundProjectile = attackData.soundRangeType == ClientAbilityConst.SOUND_RANGE_TYPE.Projectile
	end

	local elementType = CombatActionTool.getAttackElementType(attackData, combatContext)

	if soundProjectile then
		pg.game.audio:playProjectileHit(elementType, attackData.hitSoundType, hitPos, combatRTPCType)
	else
		pg.game.audio:playHit(attackData.weaponSoundType, attackData.hitSoundType, entityConfigData.bodyMatType, hitPos, combatRTPCType)
	end

	if attackData.hitSoundStr then
		pg.game.audio:playHitById(attackData.hitSoundStr, hitPos, combatRTPCType)
	end

	local playScarDecal = combatContext.inActOnTargets and not AbilityConst.SCAR_DECAL_INVALID_TYPE[combatContext.ctxType]

	ClientAbilityUtils.playHitEffects(attackData.hitEffect, attackData.defaultHitEffect, attackData.hitEffectByAction, hitPos, targetEntity, combatContext, attackData, playScarDecal)

	if pg.game.setting:getEnableHitCameraShake() then
		lume.clear(cameraShakeCache)

		local cameraShakeData = Utils.deepCopyTable(CameraShakeData[AbilityUtils.getAttackDataHitCameraShakeId(attackData)], nil, cameraShakeCache)

		if cameraShakeData then
			cameraShakeData.affectCameraAnim = true

			self:innerPlayerCameraImpulse(actionData.attackData, combatContext, cameraShakeData, true, actionData.cameraShakeCheckCastIsPlayer)
		end
	end

	if ownerEntity == pg.pawn and attackData.isPlayRadialBlur then
		pg.game.camera:playRadialBlur(nil, nil)
	end

	combatContext.actorId = rawOwnerActorId

	local casterEntity = ClientAbilityUtils.getDamageSourceEntity(combatContext)
	local isLocalPawnAttack = ownerEntity == pg.pawn or casterEntity == pg.pawn

	if isLocalPawnAttack or pg.me and pg.me.enableHitRippleAll == true then
		local isBigBody = Utils.isBoss(targetEntity) or Utils.isElite(targetEntity)

		targetEntity:playHitRippleEffect(ClientAbilityUtils.parseElementType2HitRippleStr(CombatActionTool.getAttackElementType(attackData, combatContext), isBigBody), hitPos)
	end

	Vector3.returnToCache(hitPos)
end

function ClientCombatAction:calcResult(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return false
	end

	if targetEntity.isDead and targetEntity:isDead() then
		return false
	end

	if Utils.isEnvObj(targetEntity) then
		return false
	end

	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.overrideCaster or AbilityConst.COMBAT_TARGET_TYPE_CASTER))

	if not targetEntity or not casterEntity then
		return false
	end

	if casterEntity.isDummyClone and not casterEntity.enableDummyCloneHitTimeline then
		return false
	end

	if ToBool(combatContext.castingCombatContextId) then
		pg.me:doHitTriggerRecord(combatContext.castingCombatContextId, targetEntity.actorId)
	end

	if ToBool(casterEntity.srcCastingCombatContextId) then
		pg.me:doHitTriggerRecord(casterEntity.srcCastingCombatContextId, targetEntity.actorId)
	end

	local mimicryState = AIUtils.getMimicryState(targetEntity)

	if mimicryState == AiConst.MimicryState.Defense then
		self:preDoHitAction(actionData, combatContext)
		targetEntity:postComponentMethod("EVENT_OnHit", casterEntity.actorId, combatContext.abilityId)

		return false
	end

	if targetEntity.canBeHit == false then
		return false
	end

	self:preDoHitAction(actionData, combatContext)

	local attackData = actionData.attackData

	if ToBool(attackData) then
		targetEntity:postComponentMethod("EVENT_OnHit", casterEntity.actorId, combatContext.abilityId)
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local damageData
	local elementType = 0

	if attackData then
		elementType = CombatActionTool.getAttackElementType(attackData, combatContext)
		damageData = DamageData()
		combatContext.overrideElementType = elementType
		damageData.elementType = elementType
		combatContext.damageData = damageData

		local targetElementTypes = targetEntity.elementTypes
		local shieldDataList = targetEntity.shieldDataList
		local shieldData = shieldDataList and shieldDataList[1]

		if shieldData and shieldData.elementType > 0 then
			targetElementTypes = {
				shieldData.elementType
			}
		end

		local elementDamageFactor = Utils.getElementAgainstValue(elementType, targetElementTypes, casterEntity, targetEntity)

		combatContext.isElementAdvantage = elementDamageFactor > 1
	end

	local overrideAbilityType = ToBool(attackData) and attackData.overrideAbilityType or nil

	combatContext.overrideAbilityType = casterEntity.entityOverrideDamageAbilityType or overrideAbilityType

	local calcInfo = CombatActionTool.getCalcInfo(actionData.calcInfo, actionData.calcInfoByLuaConfig, combatContext, nil, pg.me.space:isMultiPlayerEnv())

	if ToBool(calcInfo) then
		local modifier = pg.global.abilityMgr.actorAttributeModifier
		local abilityLevelAttribute = pg.global.abilityMgr.calcInfoTablePool:get(true)

		for name, value in pairs(calcInfo) do
			local attributeId = AttributeConst[name]

			if attributeId and modifier.ClientPreModifyAttributes[attributeId] then
				abilityLevelAttribute[name] = value
			end
		end

		local lvDiff = 0

		if casterEntity then
			lvDiff = (casterEntity.level or 0) - (targetEntity.level or 0)
		end

		combatContext.lvModifyData = modifier:getLvModifyData(lvDiff)

		self:calcAttributeResult(targetEntity, abilityLevelAttribute, combatContext)
		pg.global.abilityMgr.calcInfoTablePool:returnObject(abilityLevelAttribute)
	end

	pg.global.abilityMgr.calcInfoTablePool:returnObject(calcInfo)

	if not ToBool(attackData) then
		combatContext.overrideAbilityType = nil

		return false
	end

	combatContext.beAttackActorId = targetEntity.actorId

	CombatActionTool.notifyCasterEvent(casterEntity, AbilityConst.COMBAT_EVENT_ATTACK, combatContext)

	if (casterEntity.isMainPet or Utils.isPuppet(casterEntity)) and combatContext.id == casterEntity.castingCombatContextId and combatContext.inActOnTargets then
		casterEntity.castingAbilityActOnTargetHit = true
	end

	targetEntity.subject:notify(AbilityConst.COMBAT_EVENT_RECEIVE_BE_ATTACKED, combatContext)

	local srcEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_SRC))

	if srcEntity == pg.pawn then
		local lockHelper = pg.game.controller.lockHelper

		if not ToBool(lockHelper.forceLockActorId) and pg.game.setting:getAttackForceLock() and targetEntity.actorId == pg.me.lockedActorId then
			lockHelper:tryForceLockTarget(pg.me.lockedActorId, pg.me.lockedPartId)
		end
	end

	if combatContext.isImmuteDamage then
		combatContext.overrideElementType = nil
		combatContext.overrideAbilityType = nil
		combatContext.isElementAdvantage = nil

		return false
	end

	if pg.me.space:isMultiPlayerEnv() or targetEntity.authority == Const.AUTHORITY_AUTONOMOUS_PROXY then
		CombatActionTool.notifyCasterEvent(casterEntity, AbilityConst.COMBAT_EVENT_ON_POST_ATTACK, combatContext)

		combatContext.overrideElementType = nil
		combatContext.overrideAbilityType = nil
		combatContext.isElementAdvantage = nil

		return true
	end

	local projectile = combatContext:projectile()
	local casterCombatAttribute = projectile and projectile.attributeSnapshot or casterEntity.actorCombatAttribute
	local targetCombatAttribute = targetEntity and targetEntity.actorCombatAttribute
	local elementDamageAddRatio = CombatActionTool.getElementDamageAddRatio(casterCombatAttribute, targetCombatAttribute, elementType)

	if elementDamageAddRatio <= 0 then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("elementDamageAddRatio <= 0, ignore damage", casterEntity.actorId, targetEntity.actorId)
		end

		combatContext.overrideElementType = nil
		combatContext.overrideAbilityType = nil
		combatContext.isElementAdvantage = nil

		return
	end

	local finalHitTimelineId, impulseId, dir, attackForceType

	if targetEntity.calcHitActionTimelineIdAndImpulse then
		finalHitTimelineId, impulseId, dir, attackForceType = targetEntity:calcHitActionTimelineIdAndImpulse(combatContext, attackData)
	end

	local hitActionTimelineParam = pg.global.abilityMgr.hitParamsPool:get(true)

	hitActionTimelineParam.combatContextId = targetEntity.genCombatContextId and targetEntity:genCombatContextId()

	hitActionTimelineParam:init(impulseId, dir, attackForceType, targetEntity, combatContext, attackData)

	hitActionTimelineParam.airAttackLevel = attackData.airAttackLevel

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("set hit timeline", targetEntity.actorId, finalHitTimelineId)
	end

	targetEntity:serverMsgNoGC("RPC_CS_SetHitActionTimeline", finalHitTimelineId, attackForceType, hitActionTimelineParam.combatContextId)

	if not targetEntity.actorTimeline:setTimeline(finalHitTimelineId, 1, hitActionTimelineParam) then
		pg.global.abilityMgr.hitParamsPool:returnObject(hitActionTimelineParam)
	end

	CombatActionTool.notifyCasterEvent(casterEntity, AbilityConst.COMBAT_EVENT_ON_POST_ATTACK, combatContext)

	combatContext.overrideElementType = nil
	combatContext.overrideAbilityType = nil
	combatContext.isElementAdvantage = nil
end

function ClientCombatAction:showStaminaAddFx(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == pg.pawn or ownerEntity == pg.me then
		ClientUtils.showStaminaAddFx()
	end

	return true
end

function ClientCombatAction:showBubble(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", actionData.target)
		end

		return false
	end

	targetEntity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, actionData.emojiName)

	return true
end

function ClientCombatAction:hideBubble(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", actionData.target)
		end

		return false
	end

	targetEntity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)

	return true
end

function ClientCombatAction:showEmojiBubbleByRef(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj targetEntity not found", actionData.target)
		end

		return false
	end

	if not targetEntity.ensureTopLogoItem or not targetEntity:ensureTopLogoItem("bubble") then
		return false
	end

	local emojiInfo = EmojiData[actionData.emojiId]

	targetEntity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE_WITH_INFO, emojiInfo)

	return true
end

function ClientCombatAction:forceUngrounded(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if targetEntity.forceUngrounded then
		targetEntity:forceUngrounded(actionData.value, Const.ForceUnGroundReasons.Ability)
	end

	if actionData.value then
		local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObj then
			return false
		end

		abilityObj:addExitCallback(function()
			if targetEntity.forceUngrounded then
				targetEntity:forceUngrounded(false, Const.ForceUnGroundReasons.Ability)
			end
		end)
	end

	return true
end

function ClientCombatAction:isInViewport(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterEntity = pg.getEntityByActorId(targetActorId)

	if not casterEntity or not casterEntity.space then
		return false
	end

	local casterEntPos = casterEntity:getPosition():Clone()

	casterEntPos.y = casterEntPos.y + casterEntity:getHeight() * 0.5

	local cameraPos = pg.game.camera:getCameraPosition()

	if Vector3.Distance(cameraPos, casterEntPos) > 25 then
		return false
	end

	return pg.game.camera:checkInViewport(casterEntPos)
end

function ClientCombatAction:checkInControl(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if Utils.isPet(targetEntity) then
		return targetEntity == pg.pawn
	end

	if Utils.isPlayer(targetEntity) then
		return targetEntity ~= pg.pawn
	end

	return false
end

function ClientCombatAction:globalFreeze(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterEntity = pg.getEntityByActorId(targetActorId)

	if not casterEntity or not casterEntity.space then
		return false
	end

	local inTime = actionData.inTime or 0
	local outTime = actionData.outTime or 0
	local keepTime = actionData.keepTime or 0.5
	local freezeScale = actionData.freezeScale or 0.3

	if casterEntity.space.timeScaleMgr then
		casterEntity.space.timeScaleMgr:startGlobalFreeze(freezeScale, inTime, outTime, keepTime)
	end

	local relatedBuff = combatContext:buff()
	local srcAbility = CombatActionTool.getCasterAbility(combatContext)
	local abilityId = srcAbility and srcAbility.abilityId or 0

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@jqj globalFreeze", abilityId, relatedBuff and relatedBuff.buffData.templateId or 0, casterEntity.actorId, casterEntity.id, casterEntity.staticId)
	end

	return true
end

function ClientCombatAction:castAbility(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local targetActorId = 0

	if actionData.abilityTarget then
		targetActorId = CombatActionTool.parseActorId(combatContext, actionData.abilityTarget)

		if actionData.abilityTarget == AbilityConst.COMBAT_TARGET_TYPE_TARGET and not ToBool(targetActorId) then
			targetActorId = Utils.getEntityLockedActorId(targetEntity)
		end
	end

	local isAIRunning = targetEntity.isAIRunning and targetEntity:isAIRunning()

	if isAIRunning then
		local context = CTRPool.getContext()

		context.tSkillTargetActorId = targetActorId
		context.tSkillId = actionData.abilityId

		AIControllerUtils.sendAIEvent(targetEntity, "CastSkillMsgTrigger", context)

		return true
	end

	if not actionData.abilityTarget or not ToBool(targetActorId) and ToBool(actionData.forceCast) then
		local result = targetEntity.clientCastAbilityNoTarget and targetEntity:clientCastAbilityNoTarget(actionData.abilityId, AbilityConst.CAST_SOURCE.SKILL)

		return result
	else
		local result = targetEntity.clientCastAbilityOnTarget and targetEntity:clientCastAbilityOnTarget(actionData.abilityId, targetActorId, AbilityConst.CAST_SOURCE.SKILL)

		return result
	end
end

function ClientCombatAction:rotateTo(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local targetPos = Vector3(0, -99999, 0)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local positionResult = CombatActionTool.parsePosition(combatContext, actionData.target, targetPos)

	if ToBool(targetActorId) then
		if actionData.isTargetTypePos and positionResult then
			targetActorId = nil
		end
	elseif Utils.isTable(targetPos) and targetPos.className == "Vector3" and targetPos.y ~= -99999 then
		targetActorId = nil
	else
		targetPos = nil
	end

	local rotateSpeed = actionData.rotateSpeed
	local time = actionData.time
	local referenceOffsetRotY = actionData.referenceOffsetRotY

	if time <= 0 then
		if targetActorId then
			if ownerEntity.turnToTarget then
				ownerEntity:turnToTarget(targetActorId)
			end
		elseif targetPos and ownerEntity.turnToPos then
			ownerEntity:turnToPos(targetPos, true)
		end
	elseif ownerEntity.startRotateTo then
		ownerEntity:startRotateTo(targetActorId, targetPos, rotateSpeed, time, referenceOffsetRotY)
	end
end

function ClientCombatAction:stopRotateTo(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and ownerEntity.stopRotateTo then
		ownerEntity:stopRotateTo()
	end
end

function ClientCombatAction:isSkillLongPress(actionData, combatContext)
	return pg.game.controller.longPressMap[combatContext.abilityId] ~= nil
end

function ClientCombatAction:setIsInAim(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.inSkillAim = actionData.val

	if ownerEntity.updateStateCache then
		ownerEntity:updateStateCache("SKILL_AIM_ST")
	end

	if actionData.val then
		ownerEntity.aimParam = actionData

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		if ownerEntity.subject:isEventListening(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM) then
			abilityObject:getObserver():unlisten(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM)
			ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM, nil)
		elseif abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_ON_SKILL_AUTO_AIM] ~= nil then
			return
		end
	end

	if ownerEntity and ownerEntity == pg.pawn then
		local abilityId = combatContext.abilityId

		if actionData.showAimUI then
			if actionData.checkHookClawReachDistance then
				facade:sendMsgToUI(actionData.val and MessageName.ENTER_HOOK_SKILL_AIM or MessageName.LEAVE_HOOK_SKILL_AIM)

				if actionData.val then
					ownerEntity.timerHookHandler = TimerManager.addRepeatTimer(0, function()
						local succ = pg.global.physicsMgr:CameraRaycast(SysConfigData.hookClawMaxDistance, CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_AND_ENTITY_LAYERS, ownerEntity.eModel)
						local state = MessageName.ENTER_HOOK_NORMAL_STATE

						if succ then
							state = MessageName.ENTER_HOOK_FOCUS_STATE
						end

						facade:sendMsgToUI(state)
					end)
				elseif ownerEntity.timerHookHandler then
					TimerManager.removeTimer(ownerEntity.timerHookHandler)

					ownerEntity.timerHookHandler = nil
				end
			else
				pg.global.ui.hudV2:setIsInAim(ToBool(actionData.val), abilityId)
			end
		end

		if pg.game.camera.playerCameraMode.isInAim ~= actionData.val then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("setIsInAim", actionData.val, actionData.aimOffsetAnim, actionData.aimAnim)
			end

			pg.game.camera.playerCameraMode:setInAim(ownerEntity.inSkillAim, actionData)
			ownerEntity.eModel:SetAimOffset(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, actionData.val, actionData.aimOffsetAnim, actionData.aimOffsetParam, actionData.aimOffsetMaxPitch, actionData.aimAnim)

			if actionData.val and ToBool(pg.game.controller.lockHelper.forceLockActorId) and pg.game.controller.lockHelper.isUseLockOnExtendCamera then
				local targetEnt = pg.getEntityByActorId(pg.game.controller.lockHelper.forceLockActorId)

				if targetEnt then
					pg.game.camera.playerCameraMode.aimCamera.cameraMode:SetControlDir(targetEnt.eModel)
				end

				ownerEntity.eModel.AlwaysLookScreenCenter = true
			else
				ownerEntity.eModel.AlwaysLookScreenCenter = false
			end

			if actionData.showAimUI ~= false and (ownerEntity.isMainPlayer or ownerEntity.isMainPet) then
				facade:sendMsgToUI(actionData.val and MessageName.ENTER_SKILL_AIM or MessageName.LEAVE_SKILL_AIM)
			end

			if actionData.val then
				if actionData.enableLookAtCameraCenter then
					ownerEntity:enableLookAtCameraCenter(true)
				end
			else
				ownerEntity:enableLookAtCameraCenter(false)
			end
		end
	end
end

function ClientCombatAction:isInLift(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	local isInLift = false

	if targetEntity and targetEntity.isInLiftState then
		isInLift = targetEntity:isInLiftState()
	end

	return isNot and not isInLift or isInLift
end

function ClientCombatAction:isInAir(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	local isInAir = targetEntity.isInAir and targetEntity:isInAir()

	return isNot and not isInAir or isInAir
end

function ClientCombatAction:isGrounded(actionData, combatContext)
	local isNot = actionData["not"]
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj targetEntity not found", targetActorId)
		end

		return false
	end

	local isGrounded = targetEntity.isGrounded and targetEntity:isGrounded()

	return isNot and not isGrounded or isGrounded
end

function ClientCombatAction:actOnActors(ownerEntity, combatContext, multiTargetsInfo, conditionTypes, actionData, center, rot, maxRange, targetData)
	local actionIds = actionData.actionIds
	local abilityId = combatContext.abilityId or 0

	multiTargetsInfo.actionData = actionData
	multiTargetsInfo.ownerEntity = ownerEntity
	multiTargetsInfo.abilityId = abilityId
	multiTargetsInfo.conditionTypes = conditionTypes
	multiTargetsInfo.combatContext = combatContext
	multiTargetsInfo.centerPos = center
	multiTargetsInfo.actionIds = actionIds
	multiTargetsInfo.actOnEcsSensorActionIds = actionData.actOnEcsSensorActionIds

	local ClientSwitch = require("Common.ClientSwitch")

	if ClientSwitch.EnableDrawAbilityGizmo then
		if ClientSwitch.OnlyDrawLatestAttackBox then
			ownerEntity:drawUniqueAbilityGizmo(tostring(combatContext.BPName) .. "#" .. tostring(actionData.NodeID), multiTargetsInfo.shapeKind, center:getRawTable(), rot:getRawTable(), multiTargetsInfo.shapeArgs)
		else
			ownerEntity:drawAbilityGizmo(multiTargetsInfo.shapeKind, center:getRawTable(), rot:getRawTable(), multiTargetsInfo.shapeArgs)
		end
	end

	local function operationFun(actorId, partIdx, hitPosX, hitPosY, hitPosZ)
		return multiTargetsInfo:actOnTargetsOperatorFun(actorId, partIdx, hitPosX, hitPosY, hitPosZ)
	end

	local searchAoi = ownerEntity.aoi

	if not ownerEntity.aoiState and Utils.isPlayerPet(ownerEntity) then
		local playerEnt = ownerEntity:getMasterEntity()

		if playerEnt and playerEnt.aoi then
			searchAoi = playerEnt.aoi
		end
	end

	local result = pg.world.traverseNearby(searchAoi, Const.SEARCH_USR_TYPE_ACTOR_CREATION, operationFun, maxRange, center, Quaternion.ToYaw(rot), multiTargetsInfo.shapeKind, #multiTargetsInfo.shapeArgs, multiTargetsInfo.shapeArgs)

	if pg.global.abilityMgr.physicsTraverseNearby then
		pg.global.abilityMgr:physicsTraverseNearby(targetData, center, rot, ownerEntity.actorId, multiTargetsInfo)
	end

	if actionData.endActionIds then
		ownerEntity:serverMsgNoGC("RPC_CS_ActOnActorsEnd", actionData.NodeID, combatContext:getRPCDynamicInfo())
		self:doActionIds(actionData.endActionIds, combatContext)
	end

	return result
end

local checkSensorTargetCache = {}

function ClientCombatAction.checkSensorHitTargetSetFunc(sensorHashId)
	local ownerEntity = checkSensorTargetCache.ownerEntity
	local abilityId = checkSensorTargetCache.abilityId
	local actionData = checkSensorTargetCache.actionData

	if ownerEntity:checkHitTargetSet(sensorHashId, abilityId, actionData) then
		ownerEntity:addHitTargetActorId(sensorHashId, abilityId, actionData)

		return true
	end

	return false
end

function ClientCombatAction:actOnTargets(actionData, combatContext, overrideCenterPos, overrideRot)
	local chemElementId = CombatActionTool.getChemElementId(actionData, combatContext)
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(actorId)

	if not ownerEntity then
		return false
	end

	local impulseId = AbilityUtils.getAttackDataImpulseId(actionData)
	local physicsImpulse = ClientAbilityUtils.getImpulse(combatContext.abilityId, impulseId)
	local elementLevel = ClientAbilityUtils.getElementLevel(ownerEntity, combatContext, chemElementId)
	local elementValue, ecsElementValue, instanceDmgRateV = ClientAbilityUtils.getElementValue(actionData, combatContext)

	pg.global.physicsMgr:SetChemHitInfo(actorId, combatContext.abilityId or 0, chemElementId or 0, physicsImpulse or 0, elementLevel, elementValue, ecsElementValue, instanceDmgRateV)

	local result, centerData, rotData, multiTargetsInfo, argsData = CombatAction.actOnTargets(self, actionData, combatContext, overrideCenterPos, overrideRot)
	local casterEntity = CombatActionTool.getCasterEnt(combatContext)

	if casterEntity and casterEntity.authority == Const.AUTHORITY_MASTER and combatContext.castingCombatContextId then
		casterEntity:serverMsg("RPC_CS_DisableReturnAbilityConsumes", combatContext.castingCombatContextId)
	end

	if not result then
		pg.global.physicsMgr:ClearChemHitInfo()

		return false
	end

	local targetData = actionData.target
	local abilityId = combatContext.abilityId or 0

	checkSensorTargetCache.ownerEntity = ownerEntity
	checkSensorTargetCache.abilityId = abilityId
	checkSensorTargetCache.actionData = actionData

	local checkSensorHitTargetSetFunc = ClientCombatAction.checkSensorHitTargetSetFunc
	local operationFun

	if ToBool(multiTargetsInfo.actOnEcsSensorActionIds) then
		function operationFun(actorId)
			return multiTargetsInfo:actOnEcsSensorOperatorFun(actorId)
		end
	end

	local center = Vector3.GetFromPool(0, 0, 0)
	local rot = Quaternion.GetFromPool(0, 0, 0, 1)

	for idx, tgt in ipairs(targetData) do
		local centerDataIdx = (idx - 1) * 3

		center:Set(centerData[centerDataIdx + 1], centerData[centerDataIdx + 2], centerData[centerDataIdx + 3])

		local rotDataIdx = (idx - 1) * 4

		rot:Set(rotData[rotDataIdx + 1], rotData[rotDataIdx + 2], rotData[rotDataIdx + 3], rotData[rotDataIdx + 4])

		local args

		if idx == 1 then
			args = multiTargetsInfo.shapeArgs
		else
			args = argsData[idx - 1]
		end

		local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[tgt.shapeKind]

		if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
			pg.global.physicsMgr:TraverseElementCircle3D(center, rot, args, checkSensorHitTargetSetFunc, operationFun)
		elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
			pg.global.physicsMgr:TraverseElementSector3D(center, rot, args, checkSensorHitTargetSetFunc, operationFun)
		elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
			pg.global.physicsMgr:TraverseElementTrapezoid3D(center, rot, args, checkSensorHitTargetSetFunc, operationFun)
		elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
			pg.global.physicsMgr:TraverseElementAnnularSector3D(center, rot, args, checkSensorHitTargetSetFunc, operationFun)
		end

		if chemElementId == ECSConst.ELEMENT_TYPE_ICE and ownerEntity.castIce then
			ownerEntity:castIce(combatContext.abilityId, center, rot, shapeKind, args)
		end
	end

	Vector3.returnToPool(center)
	Quaternion.returnToPool(rot)
	pg.global.physicsMgr:ClearChemHitInfo()
	pg.global.abilityMgr.multiTargetInfoPool:returnObject(multiTargetsInfo)

	return result
end

function ClientCombatAction:moveByDirection(actionData, combatContext)
	local velocity = actionData.velocity.name == nil and actionData.velocity or self:doAction(actionData.velocity, combatContext)
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local duration = actionData.duration
	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("moveByDirection entity not find", targetActorId)
		end

		return false
	end

	if targetEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	if targetEntity.moveByDirection then
		local targetPos = Vector3()
		local trackTargetActorId = actionData.trackTarget and CombatActionTool.parseActorId(combatContext, actionData.trackTarget) or 0
		local hasTargetPos = CombatActionTool.parsePosition(combatContext, actionData.targetPos, targetPos)
		local copyCombatContext = combatContext:clone()

		targetPos = hasTargetPos and actionData.needForceOnGround and PhysicsUtils.getGroundPos(targetPos) or targetPos

		targetEntity:moveByDirection(Vector3(velocity[1], velocity[2], velocity[3]), duration, actionData.isLocalDir, actionData.needForceOnGround, actionData.collisionTestDistance, hasTargetPos and targetPos or nil, trackTargetActorId ~= 0 and trackTargetActorId or nil, function()
			if actionData.endActionIds then
				targetEntity:serverMsgNoGC("RPC_CS_MoveByDirectionEnd", actionData.NodeID, combatContext:getRPCDynamicInfo())
				self:doActionIds(actionData.endActionIds, copyCombatContext)
			end
		end)

		local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObj then
			return false
		end

		abilityObj:addExitCallback(function()
			targetEntity:stopMoveByDirection()
		end)

		return true
	end

	return false
end

function ClientCombatAction:stopMoveByDirection(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("stopMoveByDirection target not found", actionData.target)
		end

		return false
	end

	if targetEntity.stopMoveByDirection then
		targetEntity:stopMoveByDirection()

		return true
	end

	return false
end

function ClientCombatAction:registerMoveByInput(actionData, combatContext)
	local velocity = actionData.velocity
	local angleVelocity = actionData.angleVelocity
	local autoMove = actionData.autoMove
	local refCameraDir = actionData.refCameraDir
	local canRotate = actionData.canRotate == nil and true or actionData.canRotate
	local target = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local targetActorId = CombatActionTool.parseActorId(combatContext, target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("registerMoveByInput entity not find", targetActorId)
		end

		return false
	end

	if targetEntity.registerMoveByInput then
		targetEntity:registerMoveByInput(velocity, angleVelocity, autoMove, refCameraDir, canRotate, actionData)

		local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObj then
			return false
		end

		abilityObj:addExitCallback(function()
			targetEntity:stopMoveByInput()
		end)

		return true
	end

	return false
end

function ClientCombatAction:stopMoveByInput(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("stopMoveByDirection target not found", actionData.target)
		end

		return false
	end

	if targetEntity.stopMoveByInput then
		targetEntity:stopMoveByInput()

		return true
	end

	return false
end

function ClientCombatAction:setMaterialPropertyFloat(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local value = self:getVal(actionData.value, combatContext)

	if ownerEntity.eModel and ownerEntity.eModel.modelModelView then
		if ToBool(actionData.materialName) then
			ownerEntity.eModel.modelShaderView:SetMaterialProperty(actionData.materialName, actionData.propertyName, value)
		else
			ownerEntity.eModel.modelShaderView:SetMaterialProperty(actionData.propertyName, value)
		end
	end
end

function ClientCombatAction:startQteTimeline(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == nil or ownerEntity ~= pg.pawn and ownerEntity ~= pg.me then
		return false
	end

	local qteGroupId = actionData.qteGroupId
	local abilityId = actionData.overrideAbilityId or combatContext.abilityId or 0
	local context = {
		abilityId = abilityId,
		triggerCallback = CallbackHandler(ownerEntity, "notifyCustomEvent")
	}

	pg.game.qte:startQte(ownerEntity.actorId, qteGroupId, context)
end

function ClientCombatAction:stopQteTimeline(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == nil then
		return
	end

	local qteGroupId = actionData.qteGroupId

	pg.game.qte:stopQte(ownerEntity.actorId, qteGroupId)
end

function ClientCombatAction:startChargeQte(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == nil or ownerEntity ~= pg.pawn then
		return false
	end

	local chargeQteId = actionData.chargeQteId
	local context = {}
	local abilityId = combatContext.abilityId

	context.abilityId = abilityId
	context.duration = actionData.duration
	context.goodStartTime = actionData.goodStartTime
	context.goodDuration = actionData.goodDuration
	context.perfectStartTime = actionData.perfectStartTime
	context.perfectDuration = actionData.perfectDuration

	pg.game.qte:startChargeQte(ownerEntity.actorId, chargeQteId, context)
end

function ClientCombatAction:stopChargeQte(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == nil then
		return false
	end

	local chargeQteId = actionData.chargeQteId

	pg.game.qte:stopChargeQte(ownerEntity.actorId, chargeQteId)
end

function ClientCombatAction:pushChargeQteResult(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == nil then
		return false
	end

	local chargeQteId = actionData.chargeQteId
	local result = actionData.result

	pg.game.qte:pushChargeQteResult(ownerEntity.actorId, chargeQteId, result)
end

function ClientCombatAction:cancelSkill(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity.authority == Const.AUTHORITY_MASTER then
		if actionData.force then
			if ownerEntity.cancelAbility then
				ownerEntity:cancelAbility()
			end
		else
			ownerEntity.actorTimeline:resetCombatActionTimeline()
		end
	end
end

function ClientCombatAction:getCameraForwardPos(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local aimMaxDist = self:getVal(actionData.aimMaxDist, combatContext)

	if not ownerEntity then
		return PhysicsUtils.getScreenCenterPos(aimMaxDist)
	else
		return PhysicsUtils.getScreenCenterPosFurtherThanEntity(ownerEntity, aimMaxDist)
	end
end

function ClientCombatAction:changeEffectMaterial(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	targetEntity.eModel.modelShaderView:ChangeEffectMaterial(actionData.materialName or "")
end

function ClientCombatAction:setPetState(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	local petState = actionData.petState

	if owner and owner.setPetState then
		owner:setPetState(petState, targetActorId, true)
	end
end

function ClientCombatAction:setAnimFreezeScale(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	owner:setAnimFreezeScale(ClientConst.ANIM_FREEZE_KEY_NORMAL, actionData.scale)
end

function ClientCombatAction:playStartLoopEndAni(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local startAni = actionData.startAni
	local loopAni = actionData.loopAni
	local endAni = actionData.endAni
	local duration = actionData.duration
	local endTime

	if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		endTime = combatContext:buff().buffData.expiredTime
	elseif combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		endTime = combatContext:timeline():getRemainingTime() + owner:getGameTime()
	else
		CombatActionTool.logError(combatContext, actionData, "only support timeline or buff")

		return false
	end

	local playableState = owner:playAnimation(startAni)

	if not playableState then
		CombatActionTool.logError(combatContext, actionData, "playStartLoopEndAni failed startAni not exist:" .. tostring(startAni))

		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local abilityDuration = endTime and endTime - owner:getGameTime() or 0
	local startClipLength, endClipLength
	local startClipConfig = owner:getPlayableClipConfig(startAni)
	local endClipConfig = owner:getPlayableClipConfig(endAni)

	if startClipConfig then
		startClipLength = startClipConfig.clipLength
	end

	if endClipConfig then
		endClipLength = endClipConfig.clipLength
	end

	local durationValid = ToBool(duration) and duration <= abilityDuration
	local jumpToEnd = false

	if durationValid then
		jumpToEnd = not startClipLength or not endClipLength or duration <= startClipLength + endClipLength
	else
		duration = ToBool(abilityDuration)
	end

	playableState:AddEndCallback(function(reason)
		if reason == PlayableConst.END_REASON.PLAYBACK then
			if not durationValid or not jumpToEnd then
				playableState = owner:playAnimation(loopAni)

				if endAni and duration and endClipLength then
					local loopTime = not durationValid and endTime - endClipLength - owner:getGameTime() or duration - endClipLength

					abilityObject:addTimer("playStartLoopEndAni", loopTime, function()
						playableState = owner:playAnimation(endAni)
					end)
				end
			elseif endAni then
				playableState = owner:playAnimation(endAni)
			end
		end
	end)
	abilityObject:addExitCallback(function()
		owner:stopAnimation(startAni)
		owner:stopAnimation(loopAni)
		owner:stopAnimation(endAni)
	end)
end

function ClientCombatAction:showSkillCountDown(actionData, combatContext)
	local target = AbilityConst.COMBAT_TARGET_TYPE_CASTER
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, target))

	if not targetEntity then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("targetEntity not found", target)
		end

		return false
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if not ability then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("ability not found", ability)
		end

		return false
	end

	local now = targetEntity:getGameTime()
	local timeline = combatContext:timeline()
	local buff = combatContext:buff()

	if timeline then
		local duration = timeline:getRemainingTime()

		targetEntity:showSkillCountDown(ability.abilityId, true, now + duration)
		timeline:addExitCallback(function()
			targetEntity:showSkillCountDown(ability.abilityId, false, now)
		end)
	elseif buff then
		local duration = buff:getRemainingTime()

		targetEntity:showSkillCountDown(ability.abilityId, true, now + duration)
		buff:addExitCallback(function()
			targetEntity:showSkillCountDown(ability.abilityId, false, now)
		end)
	end
end

function ClientCombatAction:setLinearProjDestination(actionData, combatContext)
	local projectile = combatContext:projectile()

	if projectile and projectile.projectileType == ProjectileConst.PROJECTILE_TYPE_LINEAR then
		local destination = self:getVal(actionData.destination, combatContext)

		projectile.destination = destination

		return true
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("setLinearProjDestination, not supported projectile type", projectile and projectile:getCurType())
	end

	return false
end

function ClientCombatAction:setProjectileFinalDestination(actionData, combatContext)
	local projectile = combatContext:projectile()

	if projectile then
		local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if not targetEntity then
			return false
		end

		local originPos = targetEntity:getPosition()
		local originRot = targetEntity:getRotation():Clone()
		local destinationOffset = Vector3(unpack(actionData.destinationOffset))
		local finalDestination = originPos + originRot:MulVec3(destinationOffset)

		projectile.finalDestination = finalDestination

		return true
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("setProjectileFinalDestination, no projectile", projectile)
	end

	return false
end

function ClientCombatAction:changeProjEffectSpeed(actionData, combatContext)
	if combatContext:projectile() then
		combatContext:projectile():changeEffectSpeed(actionData.speed)

		return true
	end

	return false
end

function ClientCombatAction:chainChance(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	if Utils.isPet(owner) then
		local masterEntity = owner:getMasterEntity()

		if masterEntity then
			if Utils.isBotPlayer(masterEntity) then
				return
			end

			if CombatActionTool.isCasterAuthorityMaster(combatContext) then
				if masterEntity:tryTriggerPlayerTeamChainAttack() then
					return true
				end

				if masterEntity.chainAttackInfo:isInPlayerTeamChain() then
					local result = false

					if masterEntity.chainAttackInfo:canCastTeamChainBurst() then
						if masterEntity.chainAttackInfo:isPlayerCurResponder(masterEntity) then
							masterEntity:serverMsgNoGC("RPC_CS_TriggerPlayerTeamExtremeChain", combatContext.abilityId)
						end

						result = true
					elseif masterEntity.chainAttackInfo:isPlayerCurResponder(masterEntity) then
						masterEntity:serverMsgNoGC("RPC_CS_StartNextPlayerTeamChainRespond", combatContext.abilityId)

						result = true
					end

					return result
				end
			end
		end
	end

	return false
end

function ClientCombatAction:chainPropagation(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local target = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if not owner then
		return false
	end

	if not target then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("chainPropagation, target not found")
		end

		return false
	end

	local radius = actionData.radius
	local propagationMaxCnt = actionData.propagationMaxCnt
	local targetActorMap = {}
	local targetActorIdList = {}

	targetActorMap[target.actorId] = target:getPosition():Clone()
	targetActorIdList[1] = target.actorId
	combatContext.multiTargetsInfo.maxNum = 1

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("chainPropagation, change max num to one")
	end

	local curEnt = target

	for i = 1, propagationMaxCnt do
		local actorIdList = curEnt:entitiesInRange(radius, Const.SEARCH_USR_TYPE_ACTOR)
		local closestEnt
		local closestSqrLen = 0
		local curEntPos = curEnt:getPosition()

		for _, actorId in ipairs(actorIdList) do
			if targetActorMap[actorId] == nil then
				local ent = pg.getEntityByActorId(actorId)

				if ent and Utils.checkValidTarget(ent, owner) and Utils.checkRelation(owner, ent, combatContext.multiTargetsInfo.relation) then
					if closestEnt == nil then
						closestEnt = ent
					else
						local sqrDis = Vector3.SqrDistance(ent:getPosition(), curEntPos)

						if sqrDis < closestSqrLen then
							closestEnt = ent
							closestSqrLen = sqrDis
						end
					end
				end
			end
		end

		if closestEnt == nil then
			break
		end

		curEnt = closestEnt
		targetActorMap[curEnt.actorId] = true

		table.insert(targetActorIdList, curEnt.actorId)
	end

	for i = 1, #targetActorIdList do
		local entity = pg.getEntityByActorId(targetActorIdList[i])

		if not entity then
			return false
		end

		local combatHitTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, entity.actorId)

		combatHitTargetInfo:initTarget(entity.actorId, Vector3(0, 0, 0), i - 1, 0)

		local guardRuntimeTargetInfo = GuardValue(combatContext, "runtimeTargetInfo", combatHitTargetInfo)

		if owner.authority == Const.AUTHORITY_MASTER then
			owner:serverMsgNoGC("RPC_CS_ChainPropagation", actionData.NodeID, combatContext:getRPCDynamicInfo())
		end

		self:doActions(actionData, combatContext)
		guardRuntimeTargetInfo:recover()
		pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(combatHitTargetInfo)

		if actionData.chainEffect and i ~= 1 then
			local fromEnt = pg.getEntityByActorId(targetActorIdList[i - 1])

			if fromEnt then
				local extraInfo = {}

				self:setEffectExtraData(extraInfo, combatContext, entity)
				fromEnt:playLinkEffect(actionData.chainEffect, entity, extraInfo)
			end
		end
	end
end

function ClientCombatAction:enableMagnesisState(actionData, combatContext)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if casterEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	if casterEntity.MAGNESIS_READY_ST and casterEntity:MAGNESIS_READY_ST() or casterEntity.MAGNESIS_ST and casterEntity:MAGNESIS_ST() then
		return
	end

	local triggerActions = actionData.onTriggerHit
	local onStartActions = actionData.onMagnesisStart
	local onFinishActions = actionData.onMagnesisFinish

	if casterEntity.registerMagnesisAbilityActions then
		casterEntity:registerMagnesisAbilityActions(combatContext, triggerActions, onStartActions, onFinishActions)
	end

	if casterEntity.setMagnesisModeEnable then
		casterEntity:setMagnesisModeEnable(true)
	end

	if actionData.enableQuickGrab then
		local distance = actionData.distance or 10

		if casterEntity.doQuickMagnesisGrab then
			casterEntity:doQuickMagnesisGrab(distance)
		end
	end
end

function ClientCombatAction:showBubbleMsg(actionData, combatContext)
	if actionData.checkPlayer then
		local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

		if AbilityUtils.getPlayer(ownerEntity) ~= pg.me then
			return
		end
	end

	pg.global.showBubbleMessageById(actionData.msgId)
end

function ClientCombatAction:setModelSwitchTag(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("dxk setModelSwitchTag", owner, actionData.groupKey, actionData.switchTag)
	end

	if owner and owner.setModelSwitchTag then
		owner:setModelSwitchTag(actionData.groupKey, actionData.switchTag)
	end
end

function ClientCombatAction:setModelOpacity(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner then
		owner:setModelOpacity(actionData.opacity or 1)
	end
end

function ClientCombatAction:addVolumeEffect(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner.isMainPlayer or owner.isMainPet then
		local index = actionData.index

		pg.game.camera:addVolumeEffect(index)

		if actionData.applyInCharacterStates then
			local curPawn = owner

			if Utils.isPlayer(owner) and owner:isControllingPet() then
				curPawn = owner:getCurPetEntity()
			end

			local canPlayImmediately = false

			for _, state in pairs(actionData.applyInCharacterStates) do
				if CharacterStateConst.isChildOfState(curPawn.characterState, CharacterStateConst[state]) then
					canPlayImmediately = true

					break
				end
			end

			if not canPlayImmediately then
				pg.game.camera:enableVolumeEffect(index, false)
			end

			local masterEntity = owner

			if Utils.isPet(owner) then
				masterEntity = owner:getMasterEntity()
			end

			if masterEntity then
				masterEntity.characterStateConditionalVolumes[index] = actionData.applyInCharacterStates

				local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

				if not abilityObject then
					return false
				end

				abilityObject:addExitCallback(function()
					if masterEntity.characterStateConditionalVolumes[index] ~= nil then
						pg.game.camera:delVolumeEffect(index)
					end

					masterEntity.characterStateConditionalVolumes[index] = nil
				end)
			end
		end

		return true
	end

	return false
end

function ClientCombatAction:delVolumeEffect(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner == pg.me or Utils.isPet(owner) and owner:getMasterEntity() == pg.me then
		pg.game.camera:delVolumeEffect(actionData.index)

		return true
	end

	return false
end

function ClientCombatAction:addSceneDim(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner == pg.me or Utils.isPet(owner) and owner:getMasterEntity() == pg.me then
		pg.game.camera:addSceneDim(actionData.darkenValue)

		return true
	end

	return false
end

function ClientCombatAction:delSceneDim(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner == pg.me or Utils.isPet(owner) and owner:getMasterEntity() == pg.me then
		pg.game.camera:delSceneDim()

		return true
	end

	return false
end

function ClientCombatAction:setMoveImpulse(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity.authority == Const.AUTHORITY_MASTER and ownerEntity:hasEModelComponent(Const.COMPONENT_MOTION) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("setMoveImpulse", ownerEntity.actorId, actionData.moveImpulse)
		end

		ownerEntity.eModel.moveImpulseBySkill = actionData.moveImpulse

		if actionData.autoRecover ~= false then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				ownerEntity.eModel.moveImpulseBySkill = 0
			end)
		end

		return true
	end

	return false
end

function ClientCombatAction:petUseAbility(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or Utils.isPlayer(ownerEntity) == false then
		CombatActionTool.logError(combatContext, actionData, "only player can use petSkill")

		return false
	end

	local ability = CombatActionTool.getCasterAbility(combatContext)

	if not ability then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("ability not found")
		end

		return false
	end

	local result, reason, petAbilityId

	if ownerEntity.checkCanUsePetAbility then
		result, reason, petAbilityId = ownerEntity:checkCanUsePetAbility(ability.abilityId)
	end

	if not result then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			CombatLogger.info("petUseSkill pet cast ability failed, reason", reason)
		end

		return false
	end

	if ownerEntity.petUseAbility then
		ownerEntity:petUseAbility(petAbilityId)
	end

	return true
end

function ClientCombatAction:actOnSweepTargets(actionData, combatContext)
	combatContext.inActOnTargets = true

	local chemElementId = CombatActionTool.getChemElementId(actionData, combatContext)
	local startPos = self:doActionById(actionData.startPosNodeId, combatContext)

	if not startPos then
		return false
	end

	local rotation = self:doActionById(actionData.rotationNodeId, combatContext)
	local offsetRotation = actionData.offsetRotation and (actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)) or Vector3(0, 0, 0)

	if offsetRotation.w ~= nil then
		offsetRotation = Quaternion.ToEulerAngles(offsetRotation)
	end

	if offsetRotation.x ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT))
	end

	if offsetRotation.y ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP))
	end

	if offsetRotation.z ~= 0 then
		rotation:Copy(rotation * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD))
	end

	local sweepDistance = self:getVal(actionData.sweepDistance, combatContext)
	local impulseId = AbilityUtils.getAttackDataImpulseId(actionData)
	local physicsImpulse = ClientAbilityUtils.getImpulse(combatContext.abilityId, impulseId)
	local hitActorMap = {}
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(actorId)

	if not ownerEntity then
		return false
	end

	local elementLevel = ClientAbilityUtils.getElementLevel(ownerEntity, combatContext, chemElementId)
	local elementValue, ecsElementValue, instanceDmgRateV = ClientAbilityUtils.getElementValue(actionData, combatContext)

	pg.global.physicsMgr:SetChemHitInfo(actorId, combatContext.abilityId or 0, chemElementId or 0, physicsImpulse or 0, elementLevel, elementValue, ecsElementValue, instanceDmgRateV)

	local scale = actionData.isScaleWithModel ~= false and ownerEntity.curModelScale or 1
	local hitResults = pg.global.abilityMgr:boxSweep(startPos, rotation, actionData.boxExtends[1] * scale, actionData.boxExtends[2] * scale, actionData.boxExtends[3] * scale, sweepDistance * scale, actionData, combatContext)

	for _, hitResult in ipairs(hitResults) do
		hitActorMap[hitResult.hitActorId] = true
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("actOnSweepTargets", inspect(hitResults))
	end

	if actionData.checkContinueSweep then
		local lastSweepData = ownerEntity.getSweepData and ownerEntity:getSweepData(combatContext.abilityId, actionData.NodeID)

		if ownerEntity.recordSweepData then
			ownerEntity:recordSweepData(combatContext.abilityId, actionData.NodeID, startPos:Clone(), rotation:Clone())
		end

		if lastSweepData then
			local lastForward = Quaternion.MulVec3(lastSweepData.rotation, VEC3_CONST_FORWARD)
			local nowForward = Quaternion.MulVec3(rotation, VEC3_CONST_FORWARD)
			local deltaAngle = Vector3.Angle(lastForward, nowForward)

			if deltaAngle > 1 then
				local radius = sweepDistance + actionData.boxExtends[3]
				local minDelta = math.atan(actionData.boxExtends[1] / radius) * math.rad2Deg
				local interNumYaw = math.ceil(deltaAngle / minDelta)

				if interNumYaw > 1 then
					for i = 1, interNumYaw - 1 do
						local iterPos = Vector3.Lerp(lastSweepData.position, startPos, i * 1 / interNumYaw)
						local iterRot = Quaternion.Lerp(lastSweepData.rotation, rotation, i * 1 / interNumYaw)
						local iterHitResults = pg.global.abilityMgr:boxSweep(iterPos, iterRot, actionData.boxExtends[1], actionData.boxExtends[2], actionData.boxExtends[3], sweepDistance, actionData, combatContext)

						for _, hitResult in ipairs(iterHitResults) do
							if hitActorMap[hitResult.hitActorId] == nil then
								hitActorMap[hitResult.hitActorId] = true
								hitResults[#hitResults + 1] = hitResult
							end
						end
					end
				end
			end
		end
	end

	local hitDistance = sweepDistance + actionData.boxExtends[3]

	if ToBool(hitResults) then
		if ownerEntity.authority == Const.AUTHORITY_MASTER then
			ownerEntity:serverMsgNoGC("RPC_CS_DoActOnSweepTargetsActions", hitResults, actionData.NodeID, combatContext:getRPCDynamicInfo())
		elseif ownerEntity.authority == Const.AUTHORITY_AUTONOMOUS_PROXY then
			local isSendHit = false
			local closestPlayerList = ListPool.getList(1)

			ownerEntity:entitiesInRangeWithTable(AoiLodConst.default_aoi_range / 100, Const.SEARCH_USR_TYPE_PLAYER, 3, closestPlayerList)

			for _, combatHitResult in ipairs(hitResults) do
				local hitEnt = pg.getEntityByActorId(combatHitResult.hitActorId)

				if hitEnt.authorityId == pg.me.id then
					isSendHit = true
				else
					for i = 1, 3 do
						if closestPlayerList[i] == pg.me.actorId then
							isSendHit = true

							break
						end
					end
				end

				if isSendHit then
					local hitEventName = AbilityUtils.getHitEventName(combatContext)

					combatHitResult.actorId = combatHitResult.hitActorId

					pg.me:serverMsgNoGC("RPC_CS_NotifyActOnSweepTargets", ownerEntity.actorId, combatContext.id, hitEventName, combatHitResult)
				end
			end

			ListPool.returnList(closestPlayerList, 1)
		end

		CombatActionTool.doSweepActions(combatContext, actionData, hitResults, pg.global.abilityMgr.combatAction)
	end

	if chemElementId == ECSConst.ELEMENT_TYPE_ICE and ownerEntity.castIce then
		local upDir = rotation * VEC3_CONST_UP
		local center = startPos + upDir * actionData.boxExtends[3] * 0.5
		local startRadius = actionData.boxExtends[1] * 0.5
		local endRadius = startRadius
		local heightUp = 0
		local heightDown = actionData.boxExtends[2]

		ownerEntity:castIce(combatContext.abilityId, center, rotation, AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D, {
			startRadius,
			endRadius,
			hitDistance,
			heightUp,
			heightDown
		})
	end

	pg.global.physicsMgr:ClearChemHitInfo()

	combatContext.inActOnTargets = false

	return true
end

function ClientCombatAction:getBonePosition(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local target = pg.getEntityByActorId(targetActorId)

	if not target then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ClientCombatAction[getBonePosition]: not found targetEntity", actionData.target, targetActorId, target)
		end

		return false
	end

	local valid, pos, rot = target.eModel.skeletonView:TryGetBonePosRot(actionData.boneName)

	if not valid then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ClientCombatAction[getBonePosition]: boneTransform not found", actionData.target, targetActorId, actionData.boneName)
		end

		return target:getPosition()
	end

	if actionData.positionOffset then
		if actionData.isRootDir then
			local targetRotation = target:getRotation()

			return pos + Quaternion.MulVec3(targetRotation, Vector3.Clone(actionData.positionOffset))
		end

		return pos + Quaternion.MulVec3(rot, Vector3.Clone(actionData.positionOffset))
	end

	return pos
end

function ClientCombatAction:getBoneRotation(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local target = pg.getEntityByActorId(targetActorId)

	if not target then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ClientCombatAction[getBoneRotation]: not found targetEntity", actionData.target, targetActorId, target)
		end

		return false
	end

	local valid, rotation = target.eModel.skeletonView:TryGetBoneRot(actionData.boneName)

	if not valid then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ClientCombatAction[getBoneRotation]: boneTransform not found", actionData.target, targetActorId, actionData.boneName)
		end

		return target:getRotation()
	end

	if actionData.rotationOffset then
		rotation = rotation * Quaternion.Euler(unpack(actionData.rotationOffset))
	end

	return rotation
end

function ClientCombatAction:playMainPlayerSkillVoice(actionData, combatContext)
	local ability = CombatActionTool.getCasterAbility(combatContext)

	if ability and ability.abilityId then
		local functionType = pg.global.abilityMgr:getAbilityParamData(ability.abilityId).functionType

		if functionType then
			local eventName = AbilityVoiceData[functionType].EventName

			if eventName then
				pg.pawn:playSoundEvent(eventName)
			end
		end
	end
end

function ClientCombatAction:registerCheckEnclosedRegionEvent(actionData, combatContext)
	CombatAction.registerCheckEnclosedRegionEvent(self, actionData, combatContext)

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity or not targetEntity.moveByInputData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj registerCheckEnclosedRegionEvent: not found targetEntity Or moveByInputData", actionData.target, targetActorId, targetEntity)
		end

		return false
	end

	if targetEntity.registerCheckEnclosedRegionEvent then
		targetEntity:registerCheckEnclosedRegionEvent()

		local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObj then
			return false
		end

		abilityObj:addExitCallback(function()
			targetEntity:clearCheckEnclosedRegionEvent()
		end)

		return true
	end

	return false
end

function ClientCombatAction:setShaderSquash(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity or not targetEntity.eModel then
		return false
	end

	local modelView = targetEntity.eModel.modelModelView
	local configData = targetEntity:getConfigData()
	local petProtoTypeId = configData and configData.petPrototypeId or 0
	local duration

	if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_BUFF then
		duration = combatContext:buff().buffData.expiredTime - targetEntity:getGameTime()
	elseif combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE then
		local timeline = combatContext:timeline()

		duration = timeline:getRemainingTime()
	else
		CombatActionTool.logError(combatContext, actionData, "only support timeline or buff")

		return false
	end

	local stayTime = math.max(0, duration - (actionData.enterTime + actionData.exitTime))

	if modelView then
		modelView:SetSquash(true, actionData.enterTime, stayTime, actionData.exitTime, actionData.degree)

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			modelView:SetSquash(false, -1, -1, actionData.exitTime, -1)
		end)
	end
end

function ClientCombatAction:scrollWithInput(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("scrollWithInput entity not find", targetActorId)
		end

		return false
	end

	if targetEntity.registerScrollWithInput then
		targetEntity:registerScrollWithInput(actionData, combatContext)

		local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObj then
			return false
		end

		abilityObj:addExitCallback(function()
			targetEntity:clearScrollWithInputData()
		end)

		return true
	end

	return false
end

function ClientCombatAction:absorbProj(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return
	end

	local projInstanceId = combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_INTERACT_PROJ]
	local proj = targetEntity.space.projectileMgr:getProjectile(projInstanceId)

	if not proj then
		return
	end

	if ToBool(actionData.absorbEffect) then
		local extInfo = {
			position = proj.pos:Clone(),
			rotation = proj.rot:ToEulerAngles(),
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global
		}

		self:setEffectExtraData(extInfo, combatContext, targetEntity)
		targetEntity:playEffect(actionData.absorbEffect, extInfo)
	end

	proj:destroy(true)
end

function ClientCombatAction:destroyProjectile(actionData, combatContext)
	if not CombatActionTool.isCasterAuthorityMaster(combatContext) then
		return false
	end

	local projInstanceId = self:getVal(actionData.projInstanceId, combatContext)

	if not ToBool(projInstanceId) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction[destroyProjectile]: projectileInstanceId not valid ", projInstanceId)
		end

		return false
	end

	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local casterEntity = pg.getEntityByActorId(casterActorId)

	if not casterEntity then
		return false
	end

	local srcAbility = CombatActionTool.getCasterAbility(combatContext)
	local abilityId = srcAbility and srcAbility.abilityId or 0
	local projectileMgr = casterEntity.space.projectileMgr
	local projectile = projectileMgr:getProjectile(projInstanceId)

	if projectile ~= nil then
		if projectile.srcAbilityId == abilityId then
			projectile:destroy()

			return true
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction[destroyProjectile]: projectile abilityId check failed ", projectile.srcAbilityId, abilityId)
		end
	end

	return false
end

function ClientCombatAction:playEffectStrRandomAsync(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local casterEntity = pg.getEntityByActorId(casterActorId)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not casterEntity then
		return false
	end

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

		self:setEffectExtraData(extraData, combatContext, targetEntity)

		if endActorId ~= 0 or endTargetType == AbilityConst.COMBAT_TARGET_TYPE_PROJECTILE then
			local linkTargetEntity = endActorId ~= 0 and pg.getEntityByActorId(endActorId) or combatContext:projectile()

			if linkTargetEntity ~= nil then
				local effectId = casterEntity:playLinkEffect(effectStr, linkTargetEntity, extraData)

				if actionData.isAbilityEndRemove == true then
					local ability = CombatActionTool.getCasterAbility(combatContext)

					if ability and ownerEntity and ownerEntity.addAbilityEffect then
						ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability.abilityId, effectId, false)
					end
				end
			end
		else
			local effectId = targetEntity:playEffect(effectStr, extraData)

			if actionData.isAbilityEndRemove == true then
				local ability = CombatActionTool.getCasterAbility(combatContext)

				if ability and ownerEntity.addAbilityEffect then
					ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability.abilityId, effectId, false)
				end
			end

			return true
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playEffectStrRandomAsync failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:burrow(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity.BURROW_ST and ownerEntity:BURROW_ST() then
		return
	end

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		CombatAction.burrow(self, actionData, combatContext)

		return
	end

	local eModel = ownerEntity.eModel
	local canBurrow = eModel:IsOnCanSneakLayer(Const.COMPONENT_MOTION)

	if not canBurrow then
		if ownerEntity.isMainPlayer or ownerEntity.isMainPet then
			pg.global.showBubbleMessageById(NoticeDef.CANNOT_BURROW_AT_CUR_POS)
		end

		if ownerEntity.cancelAbility then
			ownerEntity:cancelAbility()
		end

		return
	end

	local master = ownerEntity:getMasterEntity()

	if master == pg.me then
		local TagMask = CS.FunPlus.WorldX.Animations.TagMask

		if not master:checkStaminaCost(TagMask.Sneak, TagMask.None) then
			pg.global.showBubbleMessageById(NoticeDef.STAMINA_SNEAK_NOT_ENOUGH)

			if ownerEntity.cancelAbility then
				ownerEntity:cancelAbility()
			end

			return
		end
	end

	CombatAction.burrow(self, actionData, combatContext)

	local velocity = actionData.velocity
	local duration = actionData.duration
	local burrowInAnim = actionData.burrowInAnim
	local controllerComponent = ownerEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if NotNil(controllerComponent) then
		local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

		abilityCharacterStateInfo.abilityVelocity = velocity
		abilityCharacterStateInfo.abilityStateDuration = duration
	end

	local burrowActionData = ownerEntity:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)

	if burrowActionData then
		burrowActionData.enableTurnInstant = actionData.enableTurnInstant
		burrowActionData.burrowInAnim = burrowInAnim
	end

	if ownerEntity.burrow then
		ownerEntity:burrow()
	end
end

function ClientCombatAction:stopBurrow(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local burrowOutAnim = actionData.burrowOutAnim
	local burrowActionData = ownerEntity:getEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE)

	if burrowActionData then
		burrowActionData.burrowOutAnim = burrowOutAnim
	end

	if ownerEntity.stopBurrow then
		ownerEntity:stopBurrow(true)
	end
end

function ClientCombatAction:stopBurrowByHit(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.stopBurrowByHit then
		ownerEntity:stopBurrowByHit()
	end
end

function ClientCombatAction:setIgnoreLockDistanceCheck(actionData, combatContext)
	local me = pg.me
	local value = ToBool(actionData.value)

	me.ignoreLockDistanceCheck = value
end

function ClientCombatAction:hideAllUI(actionData, combatContext)
	local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObj then
		return false
	end

	local maxTime = actionData.maxTime
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOPLOGO] = true
	whiteList[UIConst.UI_ID_DAMAGE_NUMBER] = true
	whiteList[UIConst.UI_ID_BOSS_TITLE] = true

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.Skill, whiteList, maxTime)

	if actionData.resetInput then
		pg.game.input:resetAllActions()
	end

	if actionData.disableAllInput then
		pg.game.input:setAllInputMapEnabled(false, HotkeyConst.INPUT_BLOCK_FLAG.Skill)
	end

	abilityObj:addExitCallback(function()
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.Skill)
		pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Skill)
	end)
end

function ClientCombatAction:restoreAllUI(actionData, combatContext)
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.Skill)
	pg.game.input:setAllInputMapEnabled(true, HotkeyConst.INPUT_BLOCK_FLAG.Skill)
end

function ClientCombatAction:petProfileShowEmoji(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity or not Utils.isPlayerPet(targetEntity) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction[petProfileShowEmoji]: target is not PlayerPet", targetActorId)
		end

		return
	end

	local tmpTable = TablePool.getTable()

	tmpTable.petId = targetEntity.id
	tmpTable.emojiName = actionData.emojiName

	facade:SendMessageCommand(MessageName.PET_SHOW_EMOJI, tmpTable)
	TablePool.returnTable(tmpTable)
end

function ClientCombatAction:lerpProperty(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity and targetEntity.eModel then
		targetEntity.eModel.modelShaderView:LerpProperty(actionData.enable, actionData.lerpTime)
	end
end

function ClientCombatAction:playerForceLock(actionData, combatContext)
	local playerInLock = ToBool(pg.game.controller.lockHelper.forceLockActorId)

	if actionData.lockState ~= nil and playerInLock ~= actionData.lockState then
		return false
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if Utils.isPet(ownerEntity) or Utils.isPlayer(ownerEntity) then
		return false
	end

	if Vector3.SqrDistance(ownerEntity:getPosition(), pg.me:getPosition()) < (actionData.distance + 1) * (actionData.distance + 1) then
		pg.game.controller.lockHelper:tryForceLockTarget(ownerEntity.actorId, 0, actionData.distance + 1, actionData.isTemp, true)

		if not pg.me:isControllingPet() then
			local petEnt = pg.me:getCurPetEntity()

			if petEnt then
				petEnt:lockTarget(ownerEntity.actorId)
			end
		end

		return true
	end

	return false
end

function ClientCombatAction:sendWxFlowGlobalEvent(actionData, combatContext)
	facade:sendLuaEvent(MessageName.WX_FLOW_GLOBAL_EVENT, actionData.eventName)
end

function ClientCombatAction:enableFourWayMove(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if actionData.enable and (not targetEntity.FOUR_WAY_MOVE_ST or not targetEntity:FOUR_WAY_MOVE_ST()) then
		AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.FOURWAYMOVE)
	elseif targetEntity.FOUR_WAY_MOVE_ST and targetEntity:FOUR_WAY_MOVE_ST() then
		AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.IDLE)
	end
end

function ClientCombatAction:hideBubbleMsg(actionData, combatContext)
	pg.global.hideBubbleMessageById(actionData.msgId)
end

function ClientCombatAction:darkScreen(actionData, combatContext)
	return
end

function ClientCombatAction:vfxEmissiveExposure(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if actionData.enable then
		pg.global.effectMgr:StartTweenVfxEmissiveExposure(actionData.lerpTime, actionData.exposureVal, actionData.curveName)

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			pg.global.effectMgr:StopVfxEmissiveExposureTween()
		end)
	else
		pg.global.effectMgr:StopVfxEmissiveExposureTween()
	end
end

function ClientCombatAction:setShaderFrozen(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity or not targetEntity.playShaderEffect then
		return
	end

	if actionData.enable then
		targetEntity:playShaderEffect("shaderFrozen")
	else
		targetEntity:stopShaderEffect("shaderFrozen")
	end
end

function ClientCombatAction:playInteractableEffect(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local casterActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity ~= nil then
		local effectStr = actionData.effectId
		local speed = actionData.speed
		local offsetXYZ = actionData.offsetXYZ
		local offsetRotation = actionData.offsetRotation
		local extraData = {
			speed = speed and speed > 0 and speed or nil,
			position = offsetXYZ,
			rotation = offsetRotation
		}

		self:setEffectExtraData(extraData, combatContext, targetEntity)

		local casterEntity = pg.getEntityByActorId(casterActorId)

		ClientAbilityUtils.setEffectMpeLodInfo(extraData, targetEntity, casterEntity)

		local effectId = targetEntity:playEffect(effectStr, extraData, true)

		if actionData.isAbilityEndRemove == true then
			local ability = CombatActionTool.getCasterAbility(combatContext)

			if ability and ownerEntity and ownerEntity.addAbilityEffect then
				ownerEntity:addAbilityEffect(targetEntity.actorId, casterActorId, ability.abilityId, effectId, false)
			end
		end

		local effShaderView

		if actionData.hitEffectId then
			self:setEffectExtraData(extraData, combatContext, targetEntity, true)

			local hitEffectId = targetEntity:playEffect(actionData.hitEffectId, extraData, true)

			if ToBool(hitEffectId) then
				local hitEffTrans = targetEntity:getEffectTransform(hitEffectId)

				if NotNil(hitEffTrans) then
					effShaderView = hitEffTrans:GetComponentInChildren(typeof(EffectShaderViewComponent))

					if IsNil(effShaderView) then
						effShaderView = hitEffTrans.gameObject:AddComponent(typeof(EffectShaderViewComponent))
						effShaderView.onlyShowOnHit = true

						hitEffTrans.gameObject:SetActiveEx(false)
					end
				end
			end
		end

		if ToBool(effectId) then
			local trans = targetEntity:getEffectTransform(effectId)

			if NotNil(trans) then
				local physxCom = trans:GetComponentInChildren(typeof(PhysxComponent))

				if IsNil(physxCom) then
					physxCom = trans.gameObject:AddComponent(typeof(PhysxComponent))
				end

				for _, collider in ipairs(actionData.collider) do
					CombatActionTool.genPhysxCollider(physxCom, collider, true)
				end

				local combatContextClone = combatContext:clone()
				local startTime = ownerEntity:getGameTime()

				if actionData.interactType == AbilityConst.INTERACT_EFFECT_TYPE.ABSORB_PROJ then
					physxCom.tagType = Const.TAG_INTERACT_PROJ

					function physxCom.onProjectileHit(proj)
						if ownerEntity:getGameTime() - startTime > actionData.interactDuration then
							if LoggerManager.checkLogger(LoggerConst.DEBUG) then
								CombatLogger.debug("onProjectileHit over time", ownerEntity:getGameTime() - startTime, actionData.interactDuration)
							end

							return
						end

						if not Utils.checkRelation(targetEntity, proj.owner, Const.WORLD_PAIRS_CAMP_ENEMY) then
							return
						end

						combatContextClone:setEventData(AbilityConst.COMBAT_EVENT_ON_INTERACT_PROJ, proj.instanceId)
						targetEntity:serverMsgNoGC("RPC_CS_OnInteractProj", proj.instanceId, proj.pos)
						self:doActionIds(actionData.interactActionIds, combatContextClone)
					end
				elseif actionData.interactType == AbilityConst.INTERACT_EFFECT_TYPE.RECEIVE_ATK then
					physxCom.tagType = Const.TAG_INTERACT_ATTACK

					function physxCom.onAttackHit(actorId, x, y, z)
						if ownerEntity:getGameTime() - startTime > actionData.interactDuration then
							if LoggerManager.checkLogger(LoggerConst.DEBUG) then
								CombatLogger.debug("onAttackHit over time", ownerEntity:getGameTime() - startTime, actionData.interactDuration)
							end

							return
						end

						local attackEntity = pg.getEntityByActorId(actorId)

						if not attackEntity then
							return
						end

						if not Utils.checkRelation(targetEntity, attackEntity, Const.WORLD_PAIRS_CAMP_ENEMY) then
							return
						end

						self:doActionIds(actionData.interactActionIds, combatContextClone)

						if NotNil(effShaderView) then
							effShaderView:TweenHitRippleEffect(Vector3(x, y, z))
						end
					end
				end
			end
		end

		return true
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playEffectStr failed, targetEntity is nil", targetActorId, actionData.target)
		end

		return false
	end
end

function ClientCombatAction:getAimPos(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return CombatActionTool.INVALID_POS
	end

	if (ownerEntity.isMainPlayer or ownerEntity.isMainPet) and pg.game.camera.playerCameraMode.isInAim then
		return PhysicsUtils.getScreenCenterPos()
	else
		local refPos = ownerEntity:getPosition()

		CombatActionTool.parsePosition(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET_HIT, refPos)

		return refPos
	end
end

function ClientCombatAction:enableSkillMotionAnimState(actionData, combatContext)
	CombatAction.enableSkillMotionAnimState(self, actionData, combatContext)

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	if actionData.enable and (not targetEntity.SKILL_MOTION_ST or not targetEntity:SKILL_MOTION_ST()) then
		targetEntity.abilityMotionInfos = Utils.deepCopyTable(actionData)
		targetEntity.abilityMotionInfos.templateId = combatContext:getTemplateId()

		local isAIRunning = AbilityUtils.isAiPet(targetEntity)

		if isAIRunning then
			targetEntity:playAbilityAnimation(actionData.moveAnimId, -1, -1)
		else
			AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.SKILLMOTION)
		end

		if actionData.abilityEndExit then
			local abilityObj = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObj then
				return false
			end

			abilityObj:addExitCallback(function()
				if targetEntity.SKILL_MOTION_ST and targetEntity:SKILL_MOTION_ST() then
					AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.IDLE)
				end

				targetEntity.abilityMotionInfos = {}
			end)
		end
	else
		if targetEntity.SKILL_MOTION_ST and targetEntity:SKILL_MOTION_ST() then
			AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.IDLE)
		end

		targetEntity.abilityMotionInfos = {}
	end
end

function ClientCombatAction:stopAnimation(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and ownerEntity.stopAnimation then
		ownerEntity:stopAnimation(actionData.anim)
	end

	return true
end

function ClientCombatAction:setSubModelVisible(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.eModel.modelModelView:SetSubModelVisible(actionData.subModelName, actionData.visible)

	return true
end

function ClientCombatAction:enablePlayerSkateboardState(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local controllerComponent = targetEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if NotNil(controllerComponent) then
		local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

		abilityCharacterStateInfo.abilityStateMachine = AbilityConst.ABILITY_SKATEBOARD_STATE
		abilityCharacterStateInfo.abilityStateFadeTime = actionData.leanTransitionTime or 0.5
	end

	if Utils.isPlayer(targetEntity) then
		if actionData.enable then
			AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.SKATEBOARD)

			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				if targetEntity then
					local exitControllerComponent = targetEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

					if NotNil(exitControllerComponent) then
						exitControllerComponent.abilityCharacterStateInfo.abilityStateMachine = 0
					end
				end
			end)
		elseif targetEntity.SKATEBOARD_ST and targetEntity:SKATEBOARD_ST() then
			AnimationUtils.playAnimationState(targetEntity, CharacterStateConst.IDLE)
		end
	end
end

function ClientCombatAction:registerMoveByInputEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_MOVE_BY_INPUT, function()
		self:doActions(actionData, copyCombatContext)
	end)
end

function ClientCombatAction:playPreset(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	return ClientPresetActionHelper.playPreset(targetEntity, actionData)
end

function ClientCombatAction:stopPreset(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	return ClientPresetActionHelper.stopPreset(targetEntity, actionData)
end

function ClientCombatAction:ignoreVelocityProjection(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity and targetEntity:hasEModelComponent(Const.COMPONENT_MOTION) then
		targetEntity.eModel:SetIgnoreVelocityProjection(Const.COMPONENT_MOTION, actionData.enable)

		if actionData.enable then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				targetEntity.eModel:SetIgnoreVelocityProjection(Const.COMPONENT_MOTION, false)
			end)
		end
	end
end

function ClientCombatAction:swapPositionWithVirtualEntity(actionData, combatContext)
	return
end

function ClientCombatAction:playSoundAtPos(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refPos = Vector3(0, 0, 0)

	if CombatActionTool.parsePosition(combatContext, actionData.targetPos, refPos) then
		local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext)

		pg.game.audio:playSoundAtPos(actionData.soundId, refPos, combatRTPCType)
	else
		CombatActionTool.logError(combatContext, actionData, "pos not found", actionData.targetPos)
		Vector3.disableCreateFromCache()

		return false
	end

	Vector3.disableCreateFromCache()
end

function ClientCombatAction:sendAIMsg(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("sendAIMsg", targetEntity.actorId, actionData.eventName)
		end

		local context = CTRPool.getContext()

		context.sourceActorId = combatContext.actorId

		AIControllerUtils.sendAIEvent(targetEntity, actionData.eventName, context)

		return true
	else
		return false
	end
end

function ClientCombatAction:rotateBySelf(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity.startRotateBySelf then
		targetEntity:startRotateBySelf(actionData.rotateSpeed, actionData.time)
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		if targetEntity.stopRotateTo then
			targetEntity:stopRotateTo()
		end
	end)
end

function ClientCombatAction:puppetPreCastAction(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return
	end

	if not Utils.isPuppet(targetEntity) then
		return
	end

	CombatAction.puppetPreCastAction(self, actionData, combatContext, true)

	local beAttackedTargetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if beAttackedTargetEntity then
		local context = CTRPool.getContext()

		context.tTargetActorId = targetEntity.actorId

		AIControllerUtils.sendAIEvent(beAttackedTargetEntity, "CombatDodgeTrigger", context)
	end

	if ToBool(actionData.enablePlayEffectStr) then
		self:playEffectStr(actionData, combatContext)
	end

	if ToBool(actionData.enableOverrideSkillHitPos) then
		local abilityObject = combatContext:ability():getAbilityObject()

		abilityObject.cacheValMap[AbilityConst.COMBAT_EVENT_PUPPET_SKILL_HIT_DISTANCE] = actionData.overridePos
	end
end

function ClientCombatAction:sendAIDodgeMsg(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if not ownerEntity then
		return false
	end

	if not targetEntity then
		return false
	end

	local context = CTRPool.getContext()

	context.tTargetActorId = ownerEntity.actorId

	AIControllerUtils.sendAIEvent(targetEntity, "CombatDodgeTrigger", context)
end

function ClientCombatAction:getGroundTangentRotation(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return Quaternion(0, 0, 0, 1)
	end

	Vector3.enableCreateFromCache()

	local refPos = ownerEntity:getPosition():Clone()
	local refYawRot = ownerEntity:getRotation():Clone()

	CombatActionTool.parsePosition(combatContext, actionData.refPos, refPos)
	CombatActionTool.parseRotation(combatContext, actionData.refYawRot, refYawRot)

	if actionData.simpleTest then
		local result = PhysicsUtils.getGroundTangentRotation(refPos)

		if result then
			Quaternion.removeTempQuaterion(result)
		end

		Vector3.disableCreateFromCache()

		return result
	else
		local radius = 0.5

		if ownerEntity.eModel and ownerEntity.eModel.radius then
			radius = ownerEntity.eModel.radius
		end

		local result = PhysicsUtils.getGroundTangentRotationEx(refPos, refYawRot, radius)

		if result then
			Quaternion.removeTempQuaterion(result)
		end

		Vector3.disableCreateFromCache()

		return result
	end
end

function ClientCombatAction:replaceHitEffect(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.replaceHitEffect = actionData.effect

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		ownerEntity.replaceHitEffect = nil
	end)
end

function ClientCombatAction:hideEffectThisFrame(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		return false
	end

	ownerEntity.eModel:SetEffectVisible(Const.COMPONENT_INDEX_EFFECT, actionData.effectId, false)
	TimerManager.addNextFrameCb(function()
		if ownerEntity.eModel then
			ownerEntity.eModel:SetEffectVisible(Const.COMPONENT_INDEX_EFFECT, actionData.key, true)
		end
	end)

	return true
end

function ClientCombatAction:enableEffectChildTransform(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity:setEffectChildTransformActive(actionData.effectId, actionData.childTransformName, actionData.enable)
end

function ClientCombatAction:getSkinnedMeshRenderer(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity and targetEntity.eModel then
		return targetEntity.eModel.modelShaderView.vfxRender
	end

	return false
end

function ClientCombatAction:playCutScene(actionData, combatContext)
	return self:doPlayCutScene(actionData, combatContext, actionData.resId)
end

function ClientCombatAction:playCutSceneBySuit(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local suitId = AbilityUtils.getSuitId(owner)
	local resId = suitId and actionData.suitResIdMap and actionData.suitResIdMap[suitId]

	resId = suitId and resId or actionData.defaultResId

	return self:doPlayCutScene(actionData, combatContext, resId)
end

local cutSceneStopTimer

function ClientCombatAction:doPlayCutScene(actionData, combatContext, resId)
	if not string.notNilOrEmpty(resId) then
		return false
	end

	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local player = AbilityUtils.getPlayer(owner)
	local abilityTemplate = combatContext:getAbilityTemplate()
	local cutSceneDuration = abilityTemplate and abilityTemplate.cutSceneDuration or 0

	if cutSceneDuration > 0 then
		if player and player.isCutSceneFastforward then
			owner.needFastForwardTimelineId = combatContext.timelineId

			return true
		end

		if owner.space and owner.space:checkSkipSkillCutScene() then
			owner.needFastForwardTimelineId = combatContext.timelineId

			return true
		end
	end

	if owner.authority ~= Const.AUTHORITY_MASTER or player ~= pg.me then
		return
	end

	pg.game.camera.playerCameraMode:interruptNormalAttackLockOnCamera()
	pg.global.abilityMgr:setIsPlayingCutScene(true)

	local cutSceneTimer

	local function stopCallback(cutscene)
		if cutSceneStopTimer then
			TimerManager.removeTimer(cutSceneStopTimer)

			cutSceneStopTimer = nil
		end

		if cutSceneTimer then
			TimerManager.removeTimer(cutSceneTimer)

			cutSceneTimer = nil
		end

		pg.global.abilityMgr:setIsPlayingCutScene(false)
		pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.AbilityCutScene)
		pg.game.camera:setAnimCameraTime(actionData.cameraAnimSyncTime or actionData.duration)

		if player.space then
			local petEnt = player:getCurPetEntity()

			if petEnt then
				for _, virtualEnt in ipairs(cutscene.virtualEntities) do
					if virtualEnt then
						petEnt.eModel.modelView:RemoveSubModelVisibleSyncEnt(virtualEnt.eModel)
						petEnt.eModel.shaderView:RemoveMatEffSyncEnt(virtualEnt.eModel)
						virtualEnt.eModel:SetActive(false)
					end
				end
			end

			if pg.me and pg.me.space then
				pg.me.space:CheckAndSetGameTimeStatus()
			end
		end
	end

	local cutSceneName = string.format("%s_%s", owner.actorId, resId)

	local function playCallback(cutscene)
		cutSceneStopTimer = TimerManager.addTimer(actionData.duration + 1, function()
			stopCallback(cutscene)
		end)
		cutSceneTimer = TimerManager.addTimer(0.2, function()
			cutSceneTimer = nil

			pg.game.camera:setWorldCameraEnable(false, ClientConst.CameraDisableReason.AbilityCutScene)
		end)

		local petEnt = player:getCurPetEntity()

		if petEnt then
			for _, virtualEnt in ipairs(cutscene.virtualEntities) do
				if virtualEnt then
					petEnt.eModel.modelView:AddSubModelVisibleSyncEnt(virtualEnt.eModel)
					petEnt.eModel.shaderView:AddMatEffSyncEnt(virtualEnt.eModel)
					virtualEnt.eModel:SetActive(true)
				end
			end
		end
	end

	if cutSceneStopTimer then
		TimerManager.removeTimer(cutSceneStopTimer)

		cutSceneStopTimer = nil
	end

	if not pg.game.cutscene:playPreloadCutscene(cutSceneName, actionData.duration, stopCallback, playCallback) then
		return pg.game.cutscene:playCutscene(cutSceneName, resId, ClientAbilityConst.PLAY_CUT_SCENE_POS, nil, actionData.duration, false, ClientAbilityUtils.getSkillExCutSceneExtraData(owner), stopCallback, playCallback)
	else
		return true
	end
end

function ClientCombatAction:setSMRBlendShapeWeight(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner and owner.eModel then
		owner.eModel:SetBsValue(Const.COMPONENT_INDEX_MODEL, actionData.blendShapeName, actionData.weight)
	end
end

function ClientCombatAction:tweenSMRBlendShapeWeight(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner and owner.eModel then
		owner.eModel:TweenBlendShapeWeight(Const.COMPONENT_INDEX_MODEL, actionData.blendShapeName, actionData.fromWeight, actionData.targetWeight, actionData.transitionDuration)
	end
end

function ClientCombatAction:enableTakeRootState(actionData, combatContext)
	CombatAction.enableTakeRootState(self, actionData, combatContext)

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local enable = actionData.enable
	local duration = actionData.duration

	if enable then
		if ownerEntity.eModel and NotNil(ownerEntity.eModel.controller) then
			ownerEntity.eModel.controller.abilityCharacterStateInfo.abilityStateDuration = duration
		end

		ownerEntity:takeRoot()
	else
		ownerEntity:stopTakeRoot()
	end
end

function ClientCombatAction:playIndicatorEff(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	Vector3.enableCreateFromCache()

	local targetData = actionData.target
	local pos = Vector3()
	local rot = ownerEntity:getRotation():Clone()
	local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[targetData.shapeKind]
	local scale = actionData.isScaleWithModel ~= false and ownerEntity.curModelScale or 1

	if combatContext.ctxType == AbilityConst.COMBAT_CONTEXT_TYPE_PROJECTILE then
		local projectile = combatContext:projectile()
		local groundSweepRadius = projectile.groundSweepRadius or projectile.sweepRadius
		local succ, raycastResult = pg.global.physicsMgr:SphereCast(projectile.pos, groundSweepRadius, Vector3.Normalize(projectile.velocity), 100)

		if not succ then
			Vector3.disableCreateFromCache()

			return false
		end

		pos = raycastResult.point
		rot = projectile.rot
	else
		pos = ownerEntity:getPosition():Clone()

		CombatActionTool.parsePosition(combatContext, targetData.center, pos)
		CombatActionTool.parseRotationFromTo(combatContext, targetData.rotFrom, targetData.rotTo, rot)

		local offsetXYZ

		if not targetData.offsetXYZ then
			offsetXYZ = Vector3.zero
		else
			offsetXYZ = targetData.offsetXYZ.name == nil and Vector3(unpack(targetData.offsetXYZ)) or self:doAction(targetData.offsetXYZ, combatContext)
		end

		local offsetRotation

		if not targetData.offsetRotation then
			offsetRotation = Vector3.zero
		else
			offsetRotation = targetData.offsetRotation.name == nil and Vector3(unpack(targetData.offsetRotation)) or self:doAction(targetData.offsetRotation, combatContext)
		end

		pos = CombatActionTool.translatePoint(pos, rot, offsetXYZ * scale)

		if offsetRotation.x ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.x, VEC3_CONST_LEFT)
		end

		if offsetRotation.y ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.y, VEC3_CONST_UP)
		end

		if offsetRotation.z ~= 0 then
			rot = rot * Quaternion.AngleAxis(offsetRotation.z, VEC3_CONST_FORWARD)
		end
	end

	local shapeArgs = targetData.shapeArgs

	if targetData.shapeArgs.name ~= nil then
		shapeArgs = pg.global.abilityMgr.combatAction:doAction(targetData.shapeArgs, combatContext)
	end

	local effectRotation = Quaternion.ToEulerAngles(rot)
	local extInfo = {
		position = pos,
		rotation = effectRotation,
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global,
		duration = actionData.playTime + actionData.stayTime,
		loadCallback = function(effectItem)
			if not effectItem then
				return
			end

			if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
				local radius, _, _ = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, actionData.playTime, actionData.stayTime, radius * scale, 0, 180)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
				local radius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, actionData.playTime, actionData.stayTime, radius * scale, 0, theta)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
				local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, actionData.playTime, actionData.stayTime, distance * scale, startRadius * scale * 2, -181)
			elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
				local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)

				effectItem:IndicatorDisp(0, actionData.playTime, actionData.stayTime, outerRadius * scale, innerRadius * scale, theta)
			end
		end
	}

	self:setEffectExtraData(extInfo, combatContext, ownerEntity)
	ownerEntity:playEffect("Eff_SkillIndicator_Comm", extInfo, true)
	Vector3.disableCreateFromCache()
end

function ClientCombatAction:playLaserEffect(actionData, combatContext)
	local effectStr = self:getVal(actionData.effectId, combatContext)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("playLaserEffect", effectStr)
	end

	local effectOwnerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.performer or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if actionData.forceLinkPlayer then
		effectOwnerEntity = Utils.getMasterPlayer(effectOwnerEntity)
	end

	if not effectOwnerEntity then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ClientCombatAction:playLaserEffect failed, performerEntity is nil", actionData.performer)
		end

		return false
	end

	local linkTarget = actionData.linkTarget
	local linkTargetDir = actionData.linkTargetDir
	local linkTargetPos = actionData.linkTargetPos

	if not linkTarget and not linkTargetDir and not linkTargetPos then
		return false
	end

	local offsetXYZ

	if actionData.offsetXYZ then
		offsetXYZ = actionData.offsetXYZ.name == nil and Vector3(unpack(actionData.offsetXYZ)) or self:doAction(actionData.offsetXYZ, combatContext)

		Vector3.Mul(offsetXYZ, effectOwnerEntity.curModelScale or 1)
	end

	local offsetRotation

	if actionData.offsetRotation then
		offsetRotation = actionData.offsetRotation.name == nil and Vector3(unpack(actionData.offsetRotation)) or self:doAction(actionData.offsetRotation, combatContext)
	end

	if offsetRotation and offsetRotation.class == "Quaternion" then
		offsetRotation = offsetRotation:ToEulerAngles()
	end

	local scale = self:getVal(actionData.scale, combatContext)
	local duration = actionData.duration
	local linkEndEffectId

	if actionData.linkEndEffectId then
		local linkEndEffectExtraData = {
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global
		}

		self:setEffectExtraData(linkEndEffectExtraData, combatContext, effectOwnerEntity)

		linkEndEffectId = effectOwnerEntity:playEffect(actionData.linkEndEffectId, linkEndEffectExtraData)
	end

	local extraData = {
		position = offsetXYZ,
		rotation = offsetRotation,
		bone = actionData.bone,
		scale = scale and scale > 0 and scale or nil,
		duration = duration and (duration > 0 or duration == -1) and duration or nil,
		useLinkRaycastTest = not ToBool(linkTargetPos),
		linkRaycastTestLayers = actionData.raycastTestLayer,
		linkEndEffectId = linkEndEffectId
	}

	ClientAbilityUtils.setEffectMpeLodInfo(extraData, effectOwnerEntity, effectOwnerEntity)
	self:setEffectExtraData(extraData, combatContext, effectOwnerEntity)

	local forceSync = actionData.forceSync
	local abilityOwnerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if linkTarget then
		local linkTargetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, linkTarget))

		if actionData.forceLinkPlayer then
			linkTargetEntity = Utils.getMasterPlayer(linkTargetEntity)
		end

		if not linkTargetEntity then
			return false
		end

		local effectId = effectOwnerEntity:playLinkEffect(effectStr, linkTargetEntity, extraData)
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)
		local observer = abilityObject and abilityObject:getObserver()

		if observer then
			if effectOwnerEntity.subject then
				observer:listen(effectOwnerEntity.subject, AbilityConst.COMBAT_EVENT_DEAD, function()
					if abilityOwnerEntity and abilityOwnerEntity.stopEffect then
						abilityOwnerEntity:stopEffect(effectStr)
					end
				end)
			end

			if linkTargetEntity.subject then
				observer:listen(linkTargetEntity.subject, AbilityConst.COMBAT_EVENT_DEAD, function()
					if abilityOwnerEntity and abilityOwnerEntity.stopEffect then
						abilityOwnerEntity:stopEffect(effectStr)
					end
				end)
			end
		end
	elseif linkTargetDir then
		local dir = self:doAction(linkTargetDir, combatContext)

		dir:SetNormalize()

		local distance = self:getVal(actionData.distance, combatContext)
		local effectId = effectOwnerEntity:playLinkEffectByDir(effectStr, dir, distance, extraData)
	elseif linkTargetPos then
		local linkEndPos = Vector3(0, 0, 0)

		extraData.useLinkEndWorldPos = true

		CombatActionTool.parsePosition(combatContext, linkTargetPos, linkEndPos)

		local effectId = effectOwnerEntity:playLinkEffectToPos(effectStr, linkEndPos, extraData)
	end

	return true
end

function ClientCombatAction:hookSprint(actionData, combatContext)
	CombatAction.hookSprint(self, actionData, combatContext)

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity.HOOK_SPRINT_ST or not ownerEntity:HOOK_SPRINT_ST() then
		if ownerEntity.prepareHookSprint then
			ownerEntity:prepareHookSprint(actionData)
		end

		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.HOOKSPRINT)
	end
end

function ClientCombatAction:notifyTransitionToHookStart(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and ownerEntity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		ownerEntity.eModel:NotifyTransitionToHookStart(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	end
end

function ClientCombatAction:enableUIBubbleLockHp(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		return
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local endTime = combatContext:buff() and combatContext:buff().buffData.expiredTime or 0

	if endTime then
		local leftTime = endTime - ownerEntity:getGameTime()
		local timer = ownerEntity:addTimer(math.max(0, leftTime - actionData.outTime), function()
			ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_OUT_TIME, true, 1)
			facade:sendMsgToUI(MessageName.ON_FREEZE_HP_OUT_TIME, {
				true,
				1
			})

			local startTime = ownerEntity:getGameTime()
			local fadeTimer = TimerManager.addRepeatNextFrameCb(function()
				if not ownerEntity.eModel then
					return
				end

				local now = ownerEntity:getGameTime() - startTime
				local timers = actionData.times
				local endFactor = actionData.endFactor
				local e = 2.7
				local f = actionData.f
				local d = math.log(1 / endFactor, e) / actionData.outTime
				local a = math.min(1, math.pow(e, -d * now))
				local percent = now / actionData.outTime
				local x = math.pow(percent, f) * 0.25 + 0.75 * percent
				local alpha = a * (math.cos(math.pi * x * timers) + 1) * 0.5

				ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_OUT_TIME, true, alpha)
				facade:sendMsgToUI(MessageName.ON_FREEZE_HP_OUT_TIME, {
					true,
					alpha
				})
				ownerEntity.eModel.shaderView:SetFresnelColorFade(alpha)
			end)

			abilityObject:addExitCallback(function()
				TimerManager.delFrameCb(fadeTimer)
			end)
		end)

		abilityObject:addExitCallback(function()
			ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_OUT_TIME, false, 0)
			facade:sendMsgToUI(MessageName.ON_FREEZE_HP_OUT_TIME, {
				false,
				0
			})
			ownerEntity:removeTimer(timer)
		end)
	end

	ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_CHANGED, true)
	facade:sendMsgToUI(MessageName.ON_FREEZE_HP_CHANGED, {
		isFreezeHp = true,
		actorId = ownerActorId
	})
	abilityObject:addExitCallback(function()
		ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_CHANGED, false)
		facade:sendMsgToUI(MessageName.ON_FREEZE_HP_CHANGED, {
			isFreezeHp = false,
			actorId = ownerActorId
		})
	end)

	local observer = CombatActionTool.getContextObserver(combatContext)

	if observer == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("observer not found")
		end

		return
	end

	observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_BUFF_TAG_CHANGE, function(tagId, isAdd)
		if isAdd and tagId == AbilityConst.BUFF_TAG_IMMUNE_DAMAGE then
			observer:listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_RECEIVE_DAMAGE, function()
				ownerEntity.eventEmitter:emit(EventConst.ON_FREEZE_HP_HIT)
				facade:sendMsgToUI(MessageName.ON_FREEZE_HP_HIT, {
					actorId = ownerActorId
				})
			end)
		end
	end)
end

function ClientCombatAction:enablePetProtectState(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(ownerActorId)

	if not ownerEntity then
		return
	end

	local curPet = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CURPET))

	if not curPet then
		return
	end

	if curPet:isDead() then
		return
	end

	if actionData.enable then
		if curPet.cancelAbility then
			curPet:cancelAbility()
		end

		AIUtils.PauseAI(curPet.id, AiConst.PauseBtReason.Visible)

		local posOffset = Vector3(unpack(actionData.absorbEffPosOffsetXYZ))
		local hitPos = ownerEntity:getPosition() + posOffset

		if curPet.playCaptureDissolveEffect then
			curPet:playCaptureDissolveEffect(hitPos, actionData.dissolveEffectDuration, function()
				local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

				if not abilityObject then
					return
				end

				if curPet.setVisible then
					curPet:setVisible(ClientConst.MODEL_VISIBLE_KEY.SKILL, false)
				end

				curPet.isPetAbilityProtected = true

				if curPet.updateStateCache then
					curPet:updateStateCache("PET_PROTECTED_ST")
				end
			end)
		end
	else
		local isAIRunning = curPet.isAIRunning and curPet:isAIRunning()

		if curPet.isPetAbilityProtected or not isAIRunning then
			if curPet.playTeleportAppearEffect then
				curPet:playTeleportAppearEffect(actionData.appearEffectDuration or 0.6)
			end

			if curPet.setVisible then
				curPet:setVisible(ClientConst.MODEL_VISIBLE_KEY.SKILL, true)
			end

			AIUtils.ResumeAI(curPet.id, AiConst.PauseBtReason.Visible)

			curPet.isPetAbilityProtected = false

			if curPet.updateStateCache then
				curPet:updateStateCache("PET_PROTECTED_ST")
			end
		end
	end
end

function ClientCombatAction:getEntityEffectPosition(actionData, combatContext)
	local effectId = actionData.effectId

	if not ToBool(effectId) then
		return CombatActionTool.INVALID_POS
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return CombatActionTool.INVALID_POS
	end

	local trans = targetEntity:getEffectTransform(effectId)

	if IsNil(trans) then
		return CombatActionTool.INVALID_POS
	end

	if ToBool(actionData.childName) then
		trans = trans:FindRecursive(actionData.childName)
	end

	return trans.position
end

function ClientCombatAction:getEntityEffectRotation(actionData, combatContext)
	local effectId = actionData.effectId

	if not ToBool(effectId) then
		return Quaternion.identity
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return Quaternion.identity
	end

	local trans = targetEntity:getEffectTransform(effectId)

	if IsNil(trans) then
		return Quaternion.identity
	end

	if ToBool(actionData.childName) then
		trans = trans:FindRecursive(actionData.childName)
	end

	return trans.rotation
end

function ClientCombatAction:createGhostEffect(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	return owner:createGhostEffect(actionData.effect, actionData.offsetPos, actionData.fadeoutTime, actionData.alpha, actionData.presetName)
end

function ClientCombatAction:playModelScaleAnim(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if targetEntity then
		local bornScale = targetEntity.bornScale or 1
		local targetScale = actionData.targetScale * bornScale

		if ToBool(actionData.curve) and targetEntity.playModelScaleAnim then
			targetEntity:playModelScaleAnim(targetScale, actionData.duration, actionData.curve)

			return true
		elseif targetEntity.playModelScaleXYZAnim and ToBool(actionData.curveX) and ToBool(actionData.curveY) and ToBool(actionData.curveZ) then
			targetEntity:playModelScaleXYZAnim(targetScale, actionData.duration, actionData.curveX, actionData.curveY, actionData.curveZ)

			return true
		end
	end

	return false
end

function ClientCombatAction:setEffectMaterialPropertyInt(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner ~= nil then
		owner:setEffectMaterialPropertyInt(actionData.effectKey, actionData.propertyId, actionData.value, actionData.materialName)
	end
end

function ClientCombatAction:setEffectMaterialProperty(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner ~= nil then
		local value = 0

		if ToBool(actionData.color) then
			value = Color(unpack(actionData.color))
		else
			value = actionData.value
		end

		owner:setEffectMaterialProperty(actionData.effectKey, actionData.propertyId, value, actionData.materialName)
	end
end

function ClientCombatAction:setEffectMaterialPropertyVector(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner ~= nil then
		owner:setEffectMaterialPropertyVector(actionData.effectKey, actionData.propertyId, Vector4(unpack(actionData.value)), actionData.materialName)
	end
end

function ClientCombatAction:tweenEffectMaterialProperty(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner ~= nil then
		local fromValue = 0
		local toValue = 0

		if ToBool(actionData.fromColor) then
			fromValue = Color(unpack(actionData.fromColor))
			toValue = Color(unpack(actionData.toColor))
		else
			fromValue = actionData.fromValue
			toValue = actionData.toValue
		end

		owner:tweenEffectMaterialProperty(actionData.effectKey, actionData.propertyId, fromValue, toValue, actionData.duration, actionData.materialName)
	end
end

function ClientCombatAction:enableSkillThrowState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not Utils.isPlayer(ownerEntity) then
		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local function leaveSkillThrowFun()
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.IDLE)
	end

	if actionData.enable then
		if not CharacterStateConst.isChildOfState(ownerEntity.characterState, CharacterStateConst.SKILLTHROWING) then
			abilityObject:addExitCallback(function()
				leaveSkillThrowFun()
			end)
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SKILLTHROWING)
		end
	elseif CharacterStateConst.isChildOfState(ownerEntity.characterState, CharacterStateConst.SKILLTHROWING) then
		leaveSkillThrowFun()
	end
end

function ClientCombatAction:enableFishingCaptureState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if actionData.enable and not CharacterStateConst.isChildOfState(ownerEntity.characterState, CharacterStateConst.FISHINGCAPTURE) then
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.FISHINGCAPTURE)

		ownerEntity.eModel.lockedTargetActorId = ownerEntity.lockedActorId
		ownerEntity.eModel.attackTargetActorId = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.actorId or 0

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_LOCKED_TARGET_CHANGE, function(lockedActorId)
			ownerEntity.eModel.lockedTargetActorId = lockedActorId
		end)
	end
end

function ClientCombatAction:createFollowingPhantom(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return
	end

	if not Utils.isPet(owner) then
		return
	end

	local masterEntity = owner:getMasterEntity()

	if masterEntity == nil then
		pg.global.abilityMgr:addMasterEntityLoadedCallback(owner, function()
			local masterEntity = owner:getMasterEntity()
			local ent = masterEntity:addFollowingPhantom(actionData, owner.templateId)

			local function callback()
				ent:playAnimation(actionData.skillState)
			end

			if not CombatAction.createFollowingPhantom(self, actionData, combatContext, callback) then
				masterEntity:removeFollowingPhantom(actionData)

				return false
			end

			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				masterEntity:removeFollowingPhantom(actionData)
			end)
		end)

		return true
	end

	local ent = masterEntity:addFollowingPhantom(actionData, owner.templateId)

	local function callback()
		ent:playAnimation(actionData.skillState)
	end

	if not CombatAction.createFollowingPhantom(self, actionData, combatContext, callback, ent) then
		masterEntity:removeFollowingPhantom(actionData)

		return false
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		masterEntity:removeFollowingPhantom(actionData)
	end)

	return true
end

function ClientCombatAction:setPhantomOverrideOffset(actionData, combatContext)
	local phantomEntity = pg.getEntityByActorId(combatContext.followPhantomActorId)

	if phantomEntity then
		phantomEntity:setPhantomOverrideOffset(actionData.offset)
	end
end

function ClientCombatAction:clearPhantomOverrideOffset(actionData, combatContext)
	local phantomEntity = pg.getEntityByActorId(combatContext.followPhantomActorId)

	if phantomEntity then
		phantomEntity:clearPhantomOverrideOffset()
	end
end

function ClientCombatAction:setIntensitySkillStyle(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return
	end

	local isOpen = actionData.isOpen
	local intensityStyle = actionData.intensityStyle
	local openDuration = actionData.openDuration or 0
	local applyToNormalSkill = actionData.applyToNormalSkill

	if applyToNormalSkill == nil then
		applyToNormalSkill = actionData.applyToAll
	end

	local applyToNormalAttack = actionData.applyToNormalAttack
	local applyToFinalSkill = actionData.applyToFinalSkill
	local applyAbilityIds = actionData.applyAbilityIds
	local tagId = actionData.tagId
	local needSkillByType = applyToNormalSkill or applyToNormalAttack or applyToFinalSkill

	if needSkillByType and not owner.getSkillIdByType then
		return
	end

	local abilityIds = {}

	for abilityId, _ in pairs(owner.abilityMap or EMPTY_TABLE) do
		if applyToNormalSkill and AbilityUtils.isNormalSkill(abilityId) then
			table.insert(abilityIds, abilityId)
		elseif applyToNormalAttack and AbilityUtils.isNormalAttack(abilityId) then
			table.insert(abilityIds, abilityId)
		elseif applyToFinalSkill and AbilityUtils.isUltimateAbility(abilityId) then
			table.insert(abilityIds, abilityId)
		end
	end

	for i, v in ipairs(applyAbilityIds or EMPTY_TABLE) do
		if not table.contains(abilityIds, v) then
			table.insert(abilityIds, v)
		end
	end

	facade:sendMsgToUI(MessageName.SKILL_INTENSITY_CHANGE, {
		actorId = owner.actorId,
		isOpen = isOpen,
		abilityIds = abilityIds,
		intensityStyle = intensityStyle,
		endTime = openDuration > 0 and Time.realSecondCache + openDuration or 0,
		tagId = tagId
	})
end

function ClientCombatAction:setNormalAttackShow(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return
	end

	facade:sendMsgToUI(MessageName.NORMAL_ATTACK_SHOW_CHANGE, {
		actorId = owner.actorId,
		show = actionData.show
	})
end

function ClientCombatAction:setGhostEyeState(actionData, combatContext)
	local master = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))
	local ghostEyeState = actionData.ghostEyeState
	local entityTagList = actionData.entityTagList
	local outlineRemainTimeTag = actionData.outlineRemainTimeTag
	local outlineRemainTimeCamouflage = actionData.outlineRemainTimeCamouflage

	if master and master.setGhostEyeState then
		master:setGhostEyeState(ghostEyeState, combatContext.abilityId, entityTagList, outlineRemainTimeTag, outlineRemainTimeCamouflage)
	end
end

function ClientCombatAction:getGhostEyeState(actionData, combatContext)
	local master = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if master and master.getGhostEyeState then
		return master:getGhostEyeState()
	end

	return Const.GHOST_EYE_STATE_OFF
end

function ClientCombatAction:switchSkillOnlyClient(actionData, combatContext)
	self:switchSkill(actionData, combatContext)
end

function ClientCombatAction:enableSupportAimEffect(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local rawOwner = owner

	if Utils.isPlayerPet(owner) then
		owner = owner:getMasterEntity()
	end

	local color = Color(AbilitySettingGlobalConstData.abilityIndicatorColor[1] or 0, AbilitySettingGlobalConstData.abilityIndicatorColor[2] or 1, AbilitySettingGlobalConstData.abilityIndicatorColor[3] or 0)
	local updatePosCallback

	if rawOwner == pg.pawn and actionData.damageIndicator then
		function updatePosCallback(pos)
			if rawOwner.supportAimDamageIndicatorEffect then
				rawOwner.eModel:UpdateEffectPosRot(Const.COMPONENT_INDEX_EFFECT, rawOwner.supportAimDamageIndicatorEffect, pos, rawOwner:getRotation())
			end
		end
	end

	if owner and owner.eModel then
		owner.eModel:EnableDrawThrowTrajectory(Const.COMPONENT_MAGNESIS_CONTROLLER, actionData.enable, actionData.startPosOffset, actionData.rotationOffset, actionData.moveSpeed, actionData.duration, actionData.gravityRatio, actionData.acceleration, actionData.startNoGravityTime, updatePosCallback)
	end

	if rawOwner == pg.pawn and actionData.damageIndicator and actionData.enable then
		local damageIndicator = actionData.damageIndicator
		local stayTime = 99999
		local shapeKind = AbilityConst.LX_GEOMETRY_TYPE_PARSER[damageIndicator.shapeKind]
		local scale = self.curModelScale or 1
		local shapeArgs = damageIndicator.shapeArgs

		if shapeArgs.name then
			shapeArgs = self.combatAction:doAction(shapeArgs, combatContext)
		end

		local extInfo = {
			position = rawOwner:getPosition(),
			rotation = Quaternion.ToEulerAngles(rawOwner:getRotation()),
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global,
			stayTime,
			loadCallback = function(effectItem)
				if not effectItem then
					return
				end

				if shapeKind == AbilityConst.LX_GEOMETRY_TYPE_CIRCLE3D then
					local radius, _, _ = unpack(shapeArgs)

					effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, 180, false, color)
				elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_SECTOR3D then
					local radius, theta, heightUp, heightDown = unpack(shapeArgs)

					effectItem:IndicatorDisp(0, 0, stayTime, radius * scale, 0, theta, false, color)
				elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_TRAPEZOID3D then
					local startRadius, endRadius, distance, heightUp, heightDown = unpack(shapeArgs)

					effectItem:IndicatorDisp(0, 0, stayTime, distance * scale, startRadius * scale * 2, -181, false, color)
				elseif shapeKind == AbilityConst.LX_GEOMETRY_TYPE_ANNULARSECTOR3D then
					local innerRadius, outerRadius, theta, heightUp, heightDown = unpack(shapeArgs)

					effectItem:IndicatorDisp(0, 0, stayTime, outerRadius * scale, innerRadius * scale, theta, false, color)
				end
			end
		}

		self:setEffectExtraData(extInfo, combatContext, rawOwner)

		rawOwner.supportAimDamageIndicatorEffect = rawOwner:playEffect("Eff_SkillIndicator_Precast", extInfo, true)
	end

	if not actionData.enable and rawOwner.supportAimDamageIndicatorEffect then
		rawOwner:stopEffectById(rawOwner.supportAimDamageIndicatorEffect)

		rawOwner.supportAimDamageIndicatorEffect = nil
	end
end

function ClientCombatAction:isInAimCameraMode(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	if owner ~= pg.pawn then
		return false
	end

	if not owner.isMainPlayer and not owner.isMainPet then
		return false
	end

	local cameraMode = pg.game.camera.playerCameraMode

	return cameraMode and cameraMode.isInAim
end

function ClientCombatAction:getEffectTransform(actionData, combatContext)
	local effectId = actionData.effectId

	if not ToBool(effectId) then
		return nil
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return nil
	end

	local trans = targetEntity:getEffectTransform(effectId)

	if IsNil(trans) then
		return nil
	end

	if ToBool(actionData.childName) then
		return trans:FindRecursive(actionData.childName)
	end

	return trans
end

function ClientCombatAction:getEffectAnimator(actionData, combatContext)
	local effectId = actionData.effectId

	if not ToBool(effectId) then
		return nil
	end

	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return nil
	end

	return targetEntity:getEffectAnimator(effectId)
end

function ClientCombatAction:enableVineChainIK(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner or not owner:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	local vineChainRigComponent = owner.dynamicRigMap[AbilityConst.RIG_TYPE_VINE_CHAIN]

	if IsNil(vineChainRigComponent) then
		return
	end

	if actionData.enable then
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.trackTarget))

		if not targetEntity or not targetEntity.eModel then
			return
		end

		local velocityConstraint = actionData.trackVelocityConstraint
		local offsetY = actionData.targetOffsetY
		local abilityTemplateData = pg.global.abilityMgr:getAbilityTemplate(combatContext.abilityId)

		if abilityTemplateData and abilityTemplateData.rigBoneData then
			local rigEffectId = abilityTemplateData.rigAnimatorEffectId

			if rigEffectId then
				local rootBone, tipBone = unpack(abilityTemplateData.rigBoneData)
				local vineTargetAnimator = owner:getEffectAnimator(rigEffectId)

				if NotNil(vineTargetAnimator) then
					vineChainRigComponent:Setup(vineTargetAnimator, rootBone, tipBone)
				end
			end
		end

		vineChainRigComponent:SetupTrackTargetByActorId(targetEntity.actorId, offsetY, velocityConstraint, actionData.vineTraceRadiusMin, actionData.vineTraceRadiusMax)
		owner.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, vineChainRigComponent, true)

		local observer = CombatActionTool.getContextObserver(combatContext)

		if observer then
			local trackTargetEntity = targetEntity

			if Utils.isPet(targetEntity) then
				local masterEntity = targetEntity:getMasterEntity()

				trackTargetEntity = masterEntity or targetEntity
			end

			local copyCombatContext = combatContext:clone()

			observer:listen(trackTargetEntity.subject, AbilityConst.COMBAT_EVENT_ON_PLAYER_SWITCH_CONTROL, function()
				local curTargetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(copyCombatContext, actionData.trackTarget))

				if not curTargetEntity then
					return
				end

				vineChainRigComponent:SetTargetByActorId(curTargetEntity.actorId)
			end)
		end
	else
		owner.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, vineChainRigComponent, false)
	end
end

function ClientCombatAction:enableVineChainTraceTarget(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner or not owner:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	local vineChainRigComponent = owner.dynamicRigMap[AbilityConst.RIG_TYPE_VINE_CHAIN]

	if IsNil(vineChainRigComponent) then
		return
	end

	vineChainRigComponent.traceTarget = actionData.enable
end

function ClientCombatAction:enableChainIK(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner or not owner:hasEModelComponent(Const.COMPONENT_INDEX_IK) then
		return
	end

	local chainRigComponent = owner.dynamicRigMap[AbilityConst.RIG_TYPE_HOOK_SPRINT]

	if IsNil(chainRigComponent) then
		return
	end

	if actionData.enable then
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

		if not targetEntity then
			return
		end

		owner.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, chainRigComponent, true)
		chainRigComponent:SetTargetPosition(CombatActionTool.getHitPosition(targetEntity))

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			owner.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, chainRigComponent, false)
		end)
	else
		owner.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, chainRigComponent, false)
	end
end

function ClientCombatAction:createProjFromAniEvent(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local copyCombatContext = combatContext:clone()

	abilityObject.owner.createProjFromAniCallback[actionData.templateId] = function(projId, startPos, startRot)
		if projId ~= actionData.templateId then
			return
		end

		copyCombatContext.overrideProjStartPos = startPos
		copyCombatContext.overrideProjStartQua = startRot

		self:createProjectile(actionData, copyCombatContext)
	end

	abilityObject:addExitCallback(function()
		abilityObject.owner.createProjFromAniCallback[actionData.templateId] = nil
	end)
end

function ClientCombatAction:prepareDataForServerActions(actionData, combatContext)
	if not actionData.dataActions then
		return false
	end

	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local iterNumber = self:getVal(actionData.iterNumber, combatContext)
	local eventName = AbilityConst.COMBAT_EVENT_ON_CLIENT_DATA_PREPARED

	if iterNumber then
		eventName = eventName .. iterNumber
	end

	local clientDatas = {}

	for idx, data in ipairs(actionData.dataActions) do
		clientDatas[tostring(idx)] = self:getVal(data, combatContext)
	end

	ownerEntity:setEntityCacheVal(eventName, clientDatas)
	ownerEntity:serverMsgNoGC("RPC_CS_OnClientCombatDataPrepared", clientDatas, eventName)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@hyj onClientCombatDataPrepared", inspect(clientDatas), eventName)
	end
end

function ClientCombatAction:enableCamouFlage(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity.refreshCamouFlageMats then
		ownerEntity:refreshCamouFlageMats(actionData.enable, actionData.lerpTime, actionData.leaveLerpTime)
	end

	if actionData.enable then
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			if ownerEntity.refreshCamouFlageMats then
				ownerEntity:refreshCamouFlageMats(false, 0)
			end
		end)
	end
end

function ClientCombatAction:addSpecialTemporaryEp(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if not ownerEntity.isMainPlayer and not ownerEntity.isMainPet then
		return false
	end

	local buff = combatContext:buff()

	if not buff then
		return false
	end

	local fadeTime = actionData.startFlashTime
	local fadeInterval = actionData.flashInterval

	facade:sendMsgToUI(MessageName.ON_SPECIAL_TEMPORARY_EP_CHANGED, {
		enable = true,
		buffInsId = buff.buffData.instanceId,
		epCount = actionData.epCount,
		fadeTime = fadeTime,
		fadeInterval = fadeInterval
	})

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		facade:sendMsgToUI(MessageName.ON_SPECIAL_TEMPORARY_EP_CHANGED, {
			enable = false,
			buffInsId = buff.buffData.instanceId,
			epCount = actionData.epCount
		})
	end)
end

function ClientCombatAction:rotateYawImmediately(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	local rotation = ownerEntity:getRotation() * Quaternion.AngleAxis(actionData.yaw, VEC3_CONST_UP)

	EModelUtils.setAgentRotation(ownerEntity, rotation, true)
end

function ClientCombatAction:setHudInSkillExState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == pg.pawn or ownerEntity == pg.me then
		pg.me.isHudInSkillExState = actionData.value

		pg.global.ui:setUIHideConfig(UIConst.UI_HIDE_KEY.ULTIMATE, UIConst.UI_ID_HUD_V2, actionData.value)
		facade:sendMsgToUI(MessageName.CHANGE_HUD_SKILL_EX)

		if actionData.value then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				pg.me.isHudInSkillExState = false

				facade:sendMsgToUI(MessageName.CHANGE_HUD_SKILL_EX)
			end)
		end
	end
end

function ClientCombatAction:enableScentTrackingState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local master = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_MASTER))

	if ownerEntity and master and master.enableScentTrackingState then
		master:enableScentTrackingState(actionData.enable, ownerEntity.actorId)
	end
end

function ClientCombatAction:enableVignette(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity == pg.pawn then
		pg.global.cameraMgr:EnableVignette(actionData.enable, actionData.lerpTime, actionData.startWidth, actionData.endWidth, actionData.curveName or "")
	end
end

function ClientCombatAction:enableBoneScaleActive(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity and targetEntity.eModel then
		targetEntity.eModel.skeletonView:SetBoneScaleActive(actionData.boneName, actionData.enable)
	end

	return false
end

function ClientCombatAction:getHookSprintHitPos(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity then
		return ownerEntity:getEntityCacheVal(AbilityConst.HOOK_SPRINT_HIT_POS)
	end
end

function ClientCombatAction:getAnimationClipLength(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEntity then
		local animClipConfig = targetEntity:getPlayableClipConfig(actionData.animName)

		if animClipConfig then
			return animClipConfig.clipLength
		end
	end

	return 0
end

function ClientCombatAction:setScarDecalData(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE, function(changeContext)
		if changeContext.attributeId == AttributeConst.hp_cur then
			local hpRatio = abilityObject.owner.actorCombatAttribute:getHpRatio()

			if hpRatio >= actionData.hpRatioRange[1] and hpRatio <= actionData.hpRatioRange[2] and not abilityObject.owner.scarDecalEffs then
				abilityObject.owner.enableSpawnDecal = true
			end
		end
	end)
	abilityObject:addExitCallback(function()
		abilityObject.owner.scarDecalEffs = nil
	end)
end

function ClientCombatAction:disableWeightPush(actionData, combatContext)
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if abilityObject.owner:hasEModelComponent(Const.COMPONENT_MOTION) then
		abilityObject.owner.eModel.isDisableWeightPush = true

		abilityObject:addExitCallback(function()
			abilityObject.owner.eModel.isDisableWeightPush = false
		end)
	end
end

function ClientCombatAction:removeGhostEffect(actionData, combatContext)
	local instanceId = self:getVal(actionData.instanceId, combatContext)
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if targetEnt and type(instanceId) == "number" and NotNil(targetEnt.eModel.modelView) then
		targetEnt:stopEffectById(instanceId)
	end

	return true
end

function ClientCombatAction:enableSpecialDefenseST(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ownerEntity.isInSpecialDefense = actionData.enable

	if ownerEntity.updateStateCache then
		ownerEntity:updateStateCache("SPECIAL_DEFENSE_ST")
	end

	if actionData.enable then
		local inputAcceleration = actionData.inputAcceleration or 10
		local maxVelocity = actionData.maxVelocity or 45
		local drag = actionData.drag or 0.05

		ownerEntity:setEntityCacheVal(AbilityConst.SPECIAL_BALL_DEFENSE_STATE_DATA, {
			inputAcceleration,
			maxVelocity,
			drag
		})

		if ownerEntity.addDynamicRPCState then
			ownerEntity:addDynamicRPCState(nil, {
				CharacterStateConst.SPECIALDEFENSE
			})
		end

		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SPECIALDEFENSE)

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			ownerEntity.isInSpecialDefense = false

			if ownerEntity.updateStateCache then
				ownerEntity:updateStateCache("SPECIAL_DEFENSE_ST")
			end

			if not ownerEntity:isDead() then
				AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.LOCOMOTION)
			end

			ownerEntity:setEntityCacheVal(AbilityConst.SPECIAL_BALL_DEFENSE_STATE_DATA, nil)
		end)
	elseif ownerEntity.characterState == CharacterStateConst.SPECIALDEFENSE then
		if not ownerEntity:isDead() then
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.LOCOMOTION)
		end

		ownerEntity:setEntityCacheVal(AbilityConst.SPECIAL_BALL_DEFENSE_STATE_DATA, nil)
	end
end

function ClientCombatAction:fadeFovCameraAnimOnVelocityChange(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity == nil or targetEntity ~= pg.pawn then
		return false
	end

	local fadeTime = actionData.fadeTime
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	local lastMoveInput = false

	if pg.game.controller ~= nil then
		lastMoveInput = pg.game.controller.lastMoveInput
	end

	if lastMoveInput then
		pg.game.camera.playerCameraMode:startFadeCurveAnim(1, fadeTime)
	else
		pg.game.camera.playerCameraMode:startFadeCurveAnim(0, fadeTime)
	end

	abilityObject:getObserver():listen(targetEntity.subject, AbilityConst.COMBAT_EVENT_ON_PAWN_MOVE_INPUT_CHANGE, function(curMoveInput)
		if curMoveInput then
			pg.game.camera.playerCameraMode:startFadeCurveAnim(1, fadeTime)
		else
			pg.game.camera.playerCameraMode:startFadeCurveAnim(0, fadeTime)
		end
	end)
end

function ClientCombatAction:getGroundPosByDirection(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local posType = actionData.fromPos
	local pos = Vector3(0, 0, 0)

	if not CombatActionTool.parsePosition(combatContext, posType, pos) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@hyj ClientCombatAction[getGroundPosByDirection]: parse fromPos failed", posType)
		end

		Vector3.disableCreateFromCache()

		return CombatActionTool.INVALID_POS
	end

	local raycastToPosType = actionData.toPos
	local rotation = Quaternion(0, 0, 0, 1)

	if raycastToPosType ~= nil and CombatActionTool.parseProjectileEmitRotationFromTo(combatContext, nil, raycastToPosType, pos, rotation) then
		local ret = PhysicsUtils.getGroundPosByDirection(pos, rotation * VEC3_CONST_FORWARD)

		if ret ~= nil then
			Vector3.disableCreateFromCache(ret)

			return ret
		end
	end

	Vector3.disableCreateFromCache()

	return CombatActionTool.INVALID_POS
end

function ClientCombatAction:checkClientCustomCDValid(actionData, combatContext)
	local customKey = actionData.customKey or "Default"
	local cd = actionData.cd or 0.1

	if not pg.me.abilityCustomCDInfo then
		pg.me.abilityCustomCDInfo = {}
	end

	local lastTime = pg.me.abilityCustomCDInfo[customKey] or 0
	local curGameTime = pg.me:getGameTime()

	if curGameTime > lastTime + cd then
		pg.me.abilityCustomCDInfo[customKey] = curGameTime

		return true
	end

	return false
end

function ClientCombatAction:getSMRBlendShapeWeight(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if owner and owner.eModel then
		return owner.eModel.modelModelView:GetFirstBlendShapeWeight(actionData.blendShapeName)
	end

	return 0
end

function ClientCombatAction:lockTargetBySearchRadius(actionData, combatContext)
	local owner = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not owner then
		return false
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	local isAuthorityMaster = owner.authority == Const.AUTHORITY_MASTER
	local forceSearch = actionData.forceSearch

	if (not ToBool(targetActorId) or forceSearch) and isAuthorityMaster then
		local abilityTemplate = combatContext:getAbilityTemplate()
		local searchTargetRangeRadius = actionData.searchRadius or abilityTemplate.searchTargetRangeRadius
		local actorIdList = owner:entitiesInRange(searchTargetRangeRadius, Const.SEARCH_USR_TYPE_ACTOR)
		local ownerPosition = owner:getPosition()
		local minDistance = searchTargetRangeRadius * searchTargetRangeRadius + 1

		for _, actorId in ipairs(actorIdList) do
			local entity = pg.getEntityByActorId(actorId)

			if entity ~= nil and not entity:isDead() and Utils.checkRelation(owner, entity, Const.WORLD_PAIRS_CAMP_ENEMY) then
				local distance = Vector3.SqrDistance(ownerPosition, entity:getPosition())

				if distance < minDistance then
					minDistance = distance
					targetActorId = actorId
				end
			end
		end

		local combatContextId = combatContext.id

		owner:serverMsgNoGC("RPC_CS_SyncCombatContextTarget", combatContextId, targetActorId)

		if combatContext.runtimeTargetInfo then
			combatContext.runtimeTargetInfo.actorId = targetActorId
		else
			combatContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:getWithCtor(true, targetActorId)
		end
	end

	if ToBool(targetActorId) and owner.actorLockTarget then
		local partId = combatContext.constCasterInfo and combatContext.constCasterInfo.partId

		owner:actorLockTarget(targetActorId, partId, true)
	end
end

function ClientCombatAction:showDialog(actionData, combatContext)
	local npcEntityId

	if actionData.target then
		local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

		npcEntityId = targetEntity and targetEntity.id
	end

	pg.game.communication:startNpcDialog(actionData.dialogId, npcEntityId, {
		forbidNextBtnClick = true,
		src = DialogueConst.SrcType.COMBAT
	})
end

function ClientCombatAction:cancelLock(actionData, combatContext)
	pg.game.controller.lockHelper:cancelForceLockTarget()
end

function ClientCombatAction:hideBattleDialog(actionData, combatContext)
	pg.game.communication:stopCombatDialogue(actionData.dialogId)
end

function ClientCombatAction:waterAbsorb(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	local radius = actionData.radius

	radius = math.min(radius, 8)

	local startPos = ownerEntity:getPosition()
	local pos = Vector3.Clone(startPos)
	local waterPosList = {}

	Vector3.enableCreateFromCache()

	local posX = startPos.x - radius

	while posX < startPos.x + radius do
		local posZ = startPos.z - radius

		while posZ < startPos.z + radius do
			pos:Set(posX, startPos.y, posZ)

			if Vector3.SqrDistance(pos, startPos) < radius * radius then
				local findWater, posY = ownerEntity.eModel:GetGroundWaterPosY(Const.COMPONENT_VOXEL, pos, 4, 4)

				if findWater then
					table.insert(waterPosList, Vector3(posX, posY, posZ))

					posZ = posZ + 1
				end
			end

			posZ = posZ + 0.5
		end

		posX = posX + 0.5
	end

	if #waterPosList > 0 then
		local function cmpFun(posA, posB)
			local disA = math.abs(Vector3.Distance(posA, startPos) - 9)
			local disB = math.abs(Vector3.Distance(posB, startPos) - 9)

			return disA < disB
		end

		table.sort(waterPosList, cmpFun)
	end

	if #waterPosList > actionData.maxCount then
		for i = #waterPosList, actionData.maxCount + 1, -1 do
			waterPosList[i] = nil
		end
	end

	for i = 1, #waterPosList do
		ClientDebugUtils.drawDebugHitBoxMesh(waterPosList[i], Quaternion(0, 0, 0, 1), AbilityConst.LX_GEOMETRY_TYPE_SPHERE, {
			0.2
		})
	end

	ownerEntity:serverMsgNoGC("RPC_CS_WaterAbsorbDataReady", waterPosList, combatContext.id, actionData.NodeID, ownerEntity:getGameTime())
	Vector3.disableCreateFromCache()
end

function ClientCombatAction:setEntityAnimatorTrigger(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		CombatLogger.error("ClientCombatAction:setEntityAnimatorTrigger failed, targetEntity is nil", targetActorId, actionData.target)

		return false
	end

	if not targetEntity.setAnimatorTrigger then
		CombatLogger.error("ClientCombatAction:setEntityAnimatorTrigger failed, targetEntity not has AnimatorComponent", targetActorId, actionData.target)

		return false
	end

	local triggerName = actionData.triggerName

	targetEntity:setAnimatorTrigger(triggerName)

	return true
end

function ClientCombatAction:setPetLockedActorId(actionData, combatContext)
	local pet = pg.me:getCurPetEntity()

	if pet then
		local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)

		pet:lockTarget(targetActorId)

		return true
	end

	return false
end

function ClientCombatAction:enableWalkingAttackMode(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not CombatActionTool.isCasterAuthorityMaster(combatContext) or Utils.isPuppet(ownerEntity) then
		return false
	end

	local controllerComponent = ownerEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if IsNil(controllerComponent) then
		return false
	end

	local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

	if actionData.enable then
		abilityCharacterStateInfo.abilityStateMachine = AbilityConst.ABILITY_WALKING_ATTACK_STATE

		if not ownerEntity.WALKING_ATTACK_ST or not ownerEntity:WALKING_ATTACK_ST() then
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.WALKINGATTACK)
		end

		ownerEntity.eModel.lockedTargetActorId = ownerEntity.lockedActorId
		ownerEntity.eModel.attackTargetActorId = combatContext.runtimeTargetInfo and combatContext.runtimeTargetInfo.actorId or 0

		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:getObserver():listen(abilityObject.owner.subject, AbilityConst.COMBAT_EVENT_ON_LOCKED_TARGET_CHANGE, function(lockedActorId)
			ownerEntity.eModel.lockedTargetActorId = lockedActorId
		end)
	else
		if ownerEntity.WALKING_ATTACK_ST and ownerEntity:WALKING_ATTACK_ST() then
			abilityCharacterStateInfo.abilityStateMachine = 0
		end

		ownerEntity.eModel:ResetAvatarMask(Const.COMPONENT_IDX_PLAYABLE, 4)
	end
end

function ClientCombatAction:showBossMechanismTip(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local ownerPlayer = Utils.getMasterPlayer(ownerEntity)

	if ownerPlayer ~= nil and not ownerPlayer.isMainPlayer then
		return
	end

	ClientUtils.showBossMechanismTip(actionData.id, actionData.duration, actionData.hasCountDown)
end

function ClientCombatAction:hideBossMechanismTip(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local ownerPlayer = Utils.getMasterPlayer(ownerEntity)

	if ownerPlayer ~= nil and not ownerPlayer.isMainPlayer then
		return
	end

	ClientUtils.hideBossMechanismTip(actionData.id, actionData.hasCountDown)
end

function ClientCombatAction:initBossMechanismIcon(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_INIT_CLIENT, {
		actorId = ownerActorId,
		assetId = actionData.assetId,
		type = actionData.type,
		needFlash = actionData.needFlash
	})
end

function ClientCombatAction:destroyBossMechanismIcon(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_DESTROY, {
		actorId = ownerActorId
	})
end

function ClientCombatAction:showBossMechanismIconVX(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_SHOW_VX, {
		actorId = ownerActorId
	})
end

function ClientCombatAction:hideBossMechanismIconVX(actionData, combatContext)
	local ownerActorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)

	facade:SendMessageCommand(MessageName.BOSS_MECHANISM_ICON_HIDE_VX, {
		actorId = ownerActorId
	})
end

function ClientCombatAction:getGroundPosFromRefClientPos(actionData, combatContext)
	Vector3.enableCreateFromCache()

	local refPos
	local refPosType = actionData.refPos

	if refPosType then
		if Utils.isTable(refPosType) and not refPosType.name then
			refPos = Vector3(unpack(refPosType))
		else
			refPos = Vector3(0, 0, 0)

			local isValid = CombatActionTool.parsePosition(combatContext, refPosType, refPos)

			if not isValid then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.error("@hyj Convert refPosType failed, check refPos", inspect(refPosType), inspect(refPos))
				end

				Vector3.disableCreateFromCache()

				return CombatActionTool.INVALID_POS
			end
		end
	end

	local result = PhysicsUtils.getGroundPos(refPos, nil, nil, nil, false) or refPos

	Vector3.disableCreateFromCache(result)

	return result
end

function ClientCombatAction:getStableGroundPos(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return CombatActionTool.INVALID_POS
	end

	Vector3.enableCreateFromCache()

	local targetPos = Vector3.Clone(ownerEntity:getPosition())

	CombatActionTool.parsePosition(combatContext, actionData.pos, targetPos)

	local _, teleportPos = ownerEntity.eModel:GetTeleportPos(Const.COMPONENT_AUTO_PATH_FIND, targetPos)

	Vector3.disableCreateFromCache(teleportPos)

	return teleportPos
end

function ClientCombatAction:clearAbilityVelocity(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local controllerComponent = ownerEntity and ownerEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if NotNil(controllerComponent) then
		controllerComponent.abilityCharacterStateInfo.abilityVelocity = 0
	end
end

function ClientCombatAction:setWalkingAttackAnimIndex(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if Utils.isPuppet(ownerEntity) then
		if ownerEntity.playAbilityAnimation then
			ownerEntity:playAbilityAnimation(actionData.fullbodyAnimId, -1, -1)
		end

		return true
	end

	if not CombatActionTool.isCasterAuthorityMaster(combatContext) then
		return false
	end

	local moveAxis = pg.game.controller.moveAxis
	local forceFullbodyTime = actionData.forceFullbodyTime
	local useFullbodyAvatarMask = forceFullbodyTime and forceFullbodyTime > 0

	if ownerEntity.characterState == CharacterStateConst.WALKINGATTACKMOVE or moveAxis ~= nil and (moveAxis[1] ~= 0 or moveAxis[2] ~= 0) then
		if ownerEntity.playAbilityAnimation then
			ownerEntity:playAbilityAnimation(actionData.upperAnimId, -1, -1)
		end

		if ownerEntity.notifyOtherClientPlayAbilityAnimation then
			ownerEntity:notifyOtherClientPlayAbilityAnimation(actionData.upperAnimId)
		end
	else
		ownerEntity:stopLayerAnimation(4)

		if ownerEntity.playAbilityAnimation then
			ownerEntity:playAbilityAnimation(actionData.fullbodyAnimId, -1, -1)
		end
	end

	local controllerComponent = ownerEntity:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)

	if IsNil(controllerComponent) then
		return false
	end

	local abilityCharacterStateInfo = controllerComponent.abilityCharacterStateInfo

	if actionData.forceFullbodyMoveVelocity and actionData.forceFullbodyMoveVelocity > 0 then
		abilityCharacterStateInfo.abilityVelocity = actionData.forceFullbodyMoveVelocity
	else
		abilityCharacterStateInfo.abilityVelocity = 0
	end

	abilityCharacterStateInfo.abilityStateMachine = AbilityConst.ABILITY_WALKING_ATTACK_STATE + actionData.index
end

function ClientCombatAction:enableSkillGliding(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if actionData.enable then
		if not ownerEntity.SKILL_GLIDING_ST or not ownerEntity:SKILL_GLIDING_ST() then
			ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_SKILL_GLIDING_STATE_CHANGE, {
				actionData.leaveGroundOffset,
				actionData.velocity
			})
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SKILLGLIDING)
		end
	elseif ownerEntity.SKILL_GLIDING_ST and ownerEntity:SKILL_GLIDING_ST() then
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SKILLGLIDINGEND)
	end
end

function ClientCombatAction:disableMotion(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity then
		local value = actionData.value

		if targetEntity.disableMotion then
			targetEntity:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_CONTROL, value)
		end

		if value then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				if targetEntity.disableMotion then
					targetEntity:disableMotion(ClientConst.DISABLE_MOTION_KEY.SKILL_CONTROL, false)
				end
			end)
		end
	end
end

function ClientCombatAction:doActionsByVoxelThreshold(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity.space then
		return false
	end

	local voxelTag = AbilityConst.TAG_STR_TO_NUM[actionData.voxelTag]
	local radius = actionData.radius
	local position = ownerEntity:getPosition()
	local count = 0

	if ownerEntity.abilityOverrideVoxelState ~= 0 then
		if voxelTag == ownerEntity.abilityOverrideVoxelState then
			for _, element in pairs(AbilityConst.TAG_ABILITY_ELEMENT_LIST) do
				count = count + VoxelUtils.countVoxelByTag(ownerEntity.space.id, element, position[1], position[2], position[3], radius, radius, radius)
			end
		else
			count = 0
		end
	else
		count = VoxelUtils.countVoxelByTag(ownerEntity.space.id, voxelTag, position[1], position[2], position[3], radius, radius, radius)
	end

	local isServerPuppetCreation = AbilityUtils.isServerPuppetCreation(ownerEntity)

	if not isServerPuppetCreation then
		ownerEntity:serverMsgNoGC("RPC_CS_SyncVoxelTagNum", combatContext.id, count)
	elseif isServerPuppetCreation and ownerEntity.authority == Const.AUTHORITY_AUTONOMOUS_PROXY and pg.me then
		local isSendVoxelTagNum = ownerEntity.authorityId == pg.me.id

		if not isSendVoxelTagNum then
			local closestPlayerList = ListPool.getList(1)

			ownerEntity:entitiesInRangeWithTable(AoiLodConst.default_aoi_range / 100, Const.SEARCH_USR_TYPE_PLAYER, 3, closestPlayerList)

			for i = 1, 3 do
				if closestPlayerList[i] == pg.me.actorId then
					isSendVoxelTagNum = true

					break
				end
			end

			ListPool.returnList(closestPlayerList, 1)
		end

		if isSendVoxelTagNum then
			local voxelEventName = AbilityUtils.getHitEventName(combatContext)

			pg.me:serverMsgNoGC("RPC_CS_SyncServerPuppetCreationVoxelTagNum", ownerEntity.actorId, combatContext.id, voxelEventName, count)
		end
	end

	if count >= actionData.threshold then
		if actionData.thresholdActionIds then
			for _, nodeId in ipairs(actionData.thresholdActionIds) do
				self:doActionById(nodeId, combatContext)
			end
		end
	elseif actionData.failedActionIds then
		for _, nodeId in ipairs(actionData.failedActionIds) do
			self:doActionById(nodeId, combatContext)
		end
	end

	return true
end

function ClientCombatAction:setEffectOpacityByPerformanceTag(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not ownerEntity:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		return false
	end

	local opacityValue = actionData.opacity

	ownerEntity.eModel:SetEffectOpacityByPerformanceTag(Const.COMPONENT_INDEX_EFFECT, actionData.tags, opacityValue)

	if opacityValue >= 0 then
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			ownerEntity.eModel:SetEffectOpacityByPerformanceTag(Const.COMPONENT_INDEX_EFFECT, actionData.tags, -1)
		end)
	end

	return true
end

function ClientCombatAction:enterSpeedBurst(actionData, combatContext)
	CombatAction.enterSpeedBurst(self, actionData, combatContext)

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SPEEDBURST)

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if ownerEntity.setRePressAbilitySlotInfo then
		ownerEntity:setRePressAbilitySlotInfo(combatContext.abilityId, ownerEntity:getGameTime() + actionData.duration, actionData.showCountDown)
	end

	abilityObject:getObserver():listen(ownerEntity.subject, AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT, function(abilityId)
		if abilityId == combatContext.abilityId and (ownerEntity.characterState == CharacterStateConst.SPEEDBURSTLOOP or ownerEntity.characterState == CharacterStateConst.SPEEDBURSTSTART) then
			AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SPEEDBURSTEND)
		end
	end)
	ownerEntity:refreshStepHeight()

	return true
end

function ClientCombatAction:leaveSpeedBurst(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if ownerEntity.characterState == CharacterStateConst.SPEEDBURSTLOOP or ownerEntity.characterState == CharacterStateConst.SPEEDBURSTSTART then
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.SPEEDBURSTEND)
	else
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.IDLE)
	end

	ownerEntity:refreshStepHeight()

	return true
end

function ClientCombatAction:reflectOnSkillMoveBlocked(actionData, combatContext)
	local hitInfo = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED]

	Vector3.enableCreateFromCache()

	local hitNormal = hitInfo and hitInfo.hitNormal or combatContext.scrollHitNormal

	if not hitNormal then
		Vector3.disableCreateFromCache()

		return false
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local moveDir = ownerEntity:getRotation():MulVec3(VEC3_CONST_FORWARD)

	hitNormal.y = 0
	moveDir.y = 0

	hitNormal:SetNormalize()
	moveDir:SetNormalize()

	local reflectNormal = Vector3.Reflect(moveDir, hitNormal)
	local targetRotation = Quaternion.LookRotation(reflectNormal, VEC3_CONST_UP)

	ownerEntity:faceToRotation(targetRotation)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("ClientCombatAction[reflectOnSkillMoveBlocked]: moveDir - hitNormal - reflectDir", inspect(moveDir), inspect(hitNormal), inspect(reflectNormal))
	end

	Vector3.disableCreateFromCache()

	return true
end

function ClientCombatAction:getSkillMoveBlockedHitPos(actionData, combatContext)
	local hitInfo = combatContext.eventData and combatContext.eventData[AbilityConst.COMBAT_EVENT_ON_SKILL_MOVE_BLOCKED]
	local hitPoint = hitInfo and hitInfo.hitPoint

	if not hitPoint then
		return CombatActionTool.INVALID_POS
	end

	return hitPoint
end

function ClientCombatAction:enterHighJump(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity:getConfigData().canHighJump then
		CombatLogger.error("entity config data canHighJump is false", ownerEntity.actorId, ownerEntity.templateId)

		return false
	end

	if ownerEntity ~= pg.pawn then
		CombatLogger.error("entity not pg.pawn", ownerEntity.actorId)

		return false
	end

	ownerEntity.highJumpInfo = actionData

	pg.game.controller.curController:performJump(true, false)
end

function ClientCombatAction:leaveHighJump(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity:getConfigData().canHighJump then
		CombatLogger.error("entity config data canHighJump is false", ownerEntity.actorId, ownerEntity.templateId)

		return false
	end

	ownerEntity.highJumpInfo = nil
end

function ClientCombatAction:disableSkinnedMeshBatch(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity or not ownerEntity:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		return false
	end

	local disable = actionData.disable

	ownerEntity.eModel:EnableSkinnedMeshBatch(Const.COMPONENT_INDEX_MODEL, not disable)

	if disable then
		local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

		if not abilityObject then
			return false
		end

		abilityObject:addExitCallback(function()
			ownerEntity.eModel:EnableSkinnedMeshBatch(Const.COMPONENT_INDEX_MODEL, true)
		end)
	end
end

function ClientCombatAction:playSurfaceEffect(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target))

	if not targetEntity then
		return
	end

	targetEntity.eModel.shaderView:PlaySurfaceEffect(actionData.preset, actionData.duration, actionData.disableWhenFinished, actionData.loopCount)

	return true
end

function ClientCombatAction:setAlwaysLookScreenCenter(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if ownerEntity and (ownerEntity.isMainPlayer or ownerEntity.isMainPet) then
		local enable = actionData.enable

		ownerEntity.eModel.AlwaysLookScreenCenter = enable

		if enable then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				ownerEntity.eModel.AlwaysLookScreenCenter = false
			end)
		end
	end
end

function ClientCombatAction:setExtraTempPet(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))
	local player = AbilityUtils.getPlayer(ownerEntity)

	if player and ToBool(actionData.templateId) then
		local curPet = player:getCurPetEntity()

		player.appearPresetDuration = actionData.appearPresetDuration
		player.loopPresetDuration = actionData.loopPresetDuration

		local combatContextClone = combatContext:clone()

		function player.appearExtraTempPetCallback()
			self:doActionIds(actionData.delayActionIds, combatContextClone)
		end

		local delayTime = actionData.delayTime or 2

		if curPet then
			ClientEffectUtils.PlayPreset(curPet, AbilitySettingGlobalConstData.switchToExtraTempPetPreset, delayTime, true)
		end
	end

	return true
end

function ClientCombatAction:applyMaterialEffect(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ClientEffectUtils.ApplyMaterialEffect(ownerEntity, actionData.key, actionData.isFullBodyReplaceMaterial == true)

	return true
end

function ClientCombatAction:removeMaterialEffect(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	ClientEffectUtils.StopMaterialEffect(ownerEntity, actionData.key)
end

function ClientCombatAction:clientGenRandomInt(actionData, combatContext)
	local randomMinVal = actionData.randomMinVal
	local randomMaxVal = actionData.randomMaxVal
	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	if actionData.forbidSameAsPrev then
		local prevVal = abilityObject.cacheValMap[actionData.key]

		if prevVal then
			if randomMinVal < prevVal - 1 then
				randomMaxVal = math.min(randomMaxVal, prevVal - 1)
			elseif randomMaxVal > prevVal + 1 then
				randomMinVal = math.max(randomMinVal, prevVal + 1)
			end
		end
	end

	local val = math.random(randomMinVal, randomMaxVal)

	abilityObject.cacheValMap[actionData.key] = val

	return val
end

function ClientCombatAction:setAnimController(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if ToBool(actionData.animController) then
		ownerEntity.eModel:SetControllerAsset(Const.COMPONENT_IDX_PLAYABLE, actionData.animController)
	else
		ClientModelUtils.applyAnimController(ownerEntity, ownerEntity.eModel, ownerEntity:getConfigData())
	end

	return true
end

function ClientCombatAction:setPlayerSightOfViewRange(actionData, combatContext)
	local buff = combatContext:buff()
	local layer = buff.buffData.layer or 0

	if buff.isDestroyed then
		layer = 0
	end

	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if Utils.isMainPlayer(ownerEntity) then
		ownerEntity:setSightOfViewRange(layer)
	end
end

function ClientCombatAction:getFollowPhantom(actionData, combatContext)
	return combatContext.followPhantomActorId
end

function ClientCombatAction:createSpiralProjectiles(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local rotation = Quaternion(0, 0, 0, 1)

	CombatActionTool.parseRotation(combatContext, actionData.rotation, rotation)

	local startPos = Vector3.Clone(ownerEntity:getPosition())

	CombatActionTool.parsePosition(combatContext, actionData.position, startPos)

	local groundPos = PhysicsUtils.getGroundPos(startPos, nil, nil, false, false)

	pg.global.csAbilityMgr.projectileSystem.groundPosY = groundPos.y

	local copyCombatContext = combatContext:clone()
	local projectileSystem = pg.global.csAbilityMgr.projectileSystem
	local effectData = {
		duration = 200,
		rotation = {
			0,
			0
		},
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global
	}

	self:setEffectExtraData(effectData, combatContext)
	ownerEntity:addCombatContextRefCnt(combatContext)
	ownerEntity:addTimer(120, function()
		ownerEntity:returnCombatContext(combatContext)
	end)

	local projectileData = actionData.projectile
	local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext)
	local projectileSoundId

	if ToBool(projectileData.soundId) or ToBool(actionData.soundId) then
		projectileSoundId = self:getVal(projectileData.soundId or actionData.soundId, combatContext)
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target) or 0
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local targetHitPos = targetEntity and CombatActionTool.getHitPosition(targetEntity) or Vector3(0, 0, 0)

	projectileSystem:CreateSpiralProjectiles(actionData.radius, actionData.count, startPos, rotation, actionData.radiusSpeed, actionData.rotateSpeed, actionData.tickInterval, actionData.generateCount, function(pos)
		local projectile

		if projectileData.name == "free3dProjectile" then
			projectile = projectileSystem:CreateFree3DProjectile(ownerEntity.eModel, pos, Quaternion(0, 0, 0, 1), projectileData.velocity, projectileData.duration, projectileData.sleepTime, projectileData.radius, projectileSoundId)
		elseif projectileData.name == "bezierProjectile" then
			projectile = projectileSystem:CreateBezierProjectile(ownerEntity.eModel, pos, Quaternion(0, 0, 0, 1), targetHitPos, projectileData.refStartPos, projectileData.refEndPos, projectileData.refControlPos, Vector3(0, 0, 0), targetActorId, projectileData.sleepTime, projectileData.duration, projectileData.radius, projectileSoundId)
		end

		ClientAbilityUtils.setProjectileCombatInfo(projectile, combatRTPCType)

		effectData.position = pos

		local effectId = ownerEntity:playEffect(projectileData.effectId, effectData)

		projectile.effectId = effectId

		function projectile.onProjectileHit(pos, actorId)
			local ent = pg.getEntityByActorId(actorId)

			if not ent then
				return
			end

			if ent ~= pg.me and ent ~= pg.pawn then
				return
			end

			pg.me:serverMsgNoGC("RPC_CS_OnCSProjectileHit", ownerEntity.actorId, copyCombatContext.id, actorId, pos)
			ownerEntity:onCSProjectileHit(copyCombatContext, actorId, pos, projectileData)
		end

		return projectile
	end)
end

function ClientCombatAction:createOffsetRotProjectiles(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local rotation = Quaternion(0, 0, 0, 1)

	CombatActionTool.parseRotation(combatContext, actionData.rotation, rotation)

	local startPos = Vector3.Clone(ownerEntity:getPosition())

	CombatActionTool.parsePosition(combatContext, actionData.position, startPos)

	local groundPos = PhysicsUtils.getGroundPos(startPos, nil, nil, false, false)

	pg.global.csAbilityMgr.projectileSystem.groundPosY = groundPos.y

	local copyCombatContext = combatContext:clone()
	local projectileSystem = pg.global.csAbilityMgr.projectileSystem
	local effectData = {
		duration = 200,
		rotation = {
			0,
			0
		},
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global
	}

	self:setEffectExtraData(effectData, combatContext)
	ownerEntity:addCombatContextRefCnt(combatContext)
	ownerEntity:addTimer(120, function()
		ownerEntity:returnCombatContext(combatContext)
	end)

	local projectileData = actionData.projectile
	local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext)
	local projectileSoundId

	if ToBool(projectileData.soundId) or ToBool(actionData.soundId) then
		projectileSoundId = self:getVal(projectileData.soundId or actionData.soundId, combatContext)
	end

	local startOffsetRotation = Quaternion.Euler(unpack(actionData.startOffsetRotation))
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target) or 0
	local targetEntity = pg.getEntityByActorId(targetActorId)
	local targetHitPos = targetEntity and CombatActionTool.getHitPosition(targetEntity) or Vector3(0, 0, 0)

	CS.FunPlus.WorldX.Utils.DebugDraw.DrawWireSphere(targetHitPos, Color(1, 0, 0), 0.1, 10)

	local dir = targetHitPos - startPos
	local startRot = Quaternion.LookRotation(dir, VEC3_CONST_UP)

	startRot = startRot * startOffsetRotation

	projectileSystem:CreateOffsetRotationProjectiles(startPos, startOffsetRotation, actionData.offsetRotation, actionData.count, actionData.tickInterval, actionData.generateCount, function(pos, offsetRotation)
		local projectile

		if projectileData.name == "bezierProjectile" then
			projectile = projectileSystem:CreateBezierProjectile(ownerEntity.eModel, pos, startRot * Quaternion.Euler(unpack(offsetRotation)), targetHitPos, projectileData.refStartPos, projectileData.refEndPos, projectileData.refControlPos, offsetRotation, targetActorId, projectileData.sleepTime, projectileData.duration, projectileData.radius, projectileSoundId)
		end

		ClientAbilityUtils.setProjectileCombatInfo(projectile, combatRTPCType)

		effectData.position = pos

		local effectId = ownerEntity:playEffect(projectileData.effectId, effectData)

		projectile.effectId = effectId

		function projectile.onProjectileHit(pos, actorId)
			local ent = pg.getEntityByActorId(actorId)

			if not ent then
				return
			end

			if ent ~= pg.me and ent ~= pg.pawn then
				return
			end

			pg.me:serverMsgNoGC("RPC_CS_OnCSProjectileHit", ownerEntity.actorId, copyCombatContext.id, actorId, pos)
			ownerEntity:onCSProjectileHit(copyCombatContext, actorId, pos, projectileData)
		end

		return projectile
	end)
end

function ClientCombatAction:createCatchBallProjectile(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local ownerPos = ownerEntity:getPosition()
	local rotation = Quaternion(0, 0, 0, 1)

	CombatActionTool.parseRotation(combatContext, actionData.rotation, rotation)

	local startPos = Vector3.Clone(ownerPos)

	CombatActionTool.parsePosition(combatContext, actionData.pos, startPos)

	local flyDuration = actionData.flyDuration
	local bounceDuration = actionData.bounceDuration
	local totalDuration = flyDuration + bounceDuration
	local copyCombatContext = combatContext:clone()
	local projectileSystem = pg.global.csAbilityMgr.projectileSystem
	local effectData = {
		position = startPos,
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global,
		duration = totalDuration
	}

	self:setEffectExtraData(effectData, combatContext)
	ownerEntity:addCombatContextRefCnt(combatContext)
	ownerEntity:addTimer(totalDuration, function()
		ownerEntity:returnCombatContext(combatContext)
	end)

	local accuracy = actionData.accuracy
	local arcHeight = actionData.arcHeight
	local bounceSpeed = actionData.bounceSpeed
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target) or 0
	local projectileData = actionData.projectile
	local radius = projectileData.radius
	local sleepTime = projectileData.sleepTime
	local projectile = projectileSystem:CreateCatchBallProjectile(ownerEntity.eModel, startPos, rotation, targetActorId, accuracy, arcHeight, flyDuration, bounceSpeed, bounceDuration, sleepTime, radius)

	if projectile then
		local combatRTPCType = ClientAbilityUtils.getCombatRTPCType(combatContext)

		ClientAbilityUtils.setProjectileCombatInfo(projectile, combatRTPCType)

		local effectId = ownerEntity:playEffect(projectileData.effectId, effectData)

		projectile.effectId = effectId

		function projectile.onProjectileHit(pos, actorId)
			local ent = pg.getEntityByActorId(actorId)

			if not ent then
				return
			end

			if ent.actorId ~= targetActorId then
				return
			end

			pg.me:serverMsgNoGC("RPC_CS_OnCSProjectileHit", ownerEntity.actorId, copyCombatContext.id, actorId, pos)
			ownerEntity:onCSProjectileHit(copyCombatContext, actorId, pos, projectileData)
		end
	end
end

function ClientCombatAction:followPhantomLockTarget(actionData, combatContext)
	local lockTargetId = CombatActionTool.parseActorId(combatContext, actionData.lockTarget or AbilityConst.COMBAT_TARGET_TYPE_TARGET)
	local targetEntity = pg.getEntityByActorId(combatContext.followPhantomActorId)

	if targetEntity and targetEntity.followPhantomLockTarget then
		targetEntity:followPhantomLockTarget(lockTargetId, actionData.duration)
	end
end

function ClientCombatAction:enableLateralAttackState(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity or not CombatActionTool.isCasterAuthorityMaster(combatContext) or Utils.isPuppet(ownerEntity) then
		return false
	end

	if actionData.enable and (not ownerEntity.LATERAL_ATTACK_ST or not ownerEntity:LATERAL_ATTACK_ST()) then
		local frontSideAttackAnim = actionData.frontSideAttackAnim
		local backSideAttackAnim = actionData.backSideAttackAnim
		local leftSideAttackAnim = actionData.leftSideAttackAnim
		local normalAttackAnim = actionData.normalAttackAnim
		local rightSideAttackAnim = actionData.rightSideAttackAnim

		ownerEntity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_LATERAL_ATTACK_STATE_CHANGE, {
			leftSideAttackAnim = leftSideAttackAnim,
			normalAttackAnim = normalAttackAnim,
			rightSideAttackAnim = rightSideAttackAnim,
			frontSideAttackAnim = frontSideAttackAnim,
			backSideAttackAnim = backSideAttackAnim
		})
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.LATERALATTACK)
	elseif ownerEntity.LATERAL_ATTACK_ST and ownerEntity:LATERAL_ATTACK_ST() then
		AnimationUtils.playAnimationState(ownerEntity, CharacterStateConst.IDLE)
	end
end

function ClientCombatAction:playGroundFlowerEffect(actionData, combatContext)
	local effectId = actionData.effectId
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local extraData = {
		customUpdateCallback = function(effectItem)
			local succ, groundHeight = PhysicsUtils.getGroundHeight(ownerEntity:getPosition())
			local inGround = succ and groundHeight < 0.5

			effectItem:SetXParticles("_FlowerDanceTrails_OnGround", inGround and 1 or 0)
		end
	}

	self:setEffectExtraData(extraData, combatContext, ownerEntity)
	ownerEntity:playEffect(effectId, extraData)
end

function ClientCombatAction:followPhantomRotateTo(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(combatContext.followPhantomActorId)

	if not ownerEntity then
		return false
	end

	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetPos

	if Utils.isTable(targetActorId) and targetActorId.className == "Vector3" then
		targetPos = targetActorId
		targetActorId = nil
	else
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if not targetEntity then
			return false
		end

		targetPos = targetEntity:getPosition()
	end

	local rotateSpeed = actionData.rotateSpeed
	local time = actionData.time

	if ownerEntity.startRotateTo then
		ownerEntity:startRotateTo(targetActorId, targetPos, rotateSpeed, time, actionData.boneName or "")
	end
end

function ClientCombatAction:tweenEffectLocalEnvWeight(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local from = self:getVal(actionData.from, combatContext)
	local to = self:getVal(actionData.to, combatContext)
	local duration = self:getVal(actionData.duration, combatContext)

	ownerEntity.eModel:TweenLocalEnvWeight(Const.COMPONENT_INDEX_EFFECT, actionData.effectId, from, to, duration)
end

function ClientCombatAction:switchSkillIcon(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not ownerEntity.switchSkillIconData then
		ownerEntity.switchSkillIconData = {}
	end

	if ToBool(actionData.icon) then
		ownerEntity.switchSkillIconData[actionData.abilityId] = actionData.icon
	else
		ownerEntity.switchSkillIconData[actionData.abilityId] = false
	end

	if ownerEntity == pg.pawn then
		facade:SendMessageCommand(MessageName.SKILL_SWITCH_UPDATE, actionData.abilityId)
	end
end

function ClientCombatAction:enableFreeAimMode(actionData, combatContext)
	local enable = actionData.enable
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if ownerEntity == pg.pawn then
		pg.game.camera.playerCameraMode:enableMagnesisCameraMode(enable)
		facade:sendMsgToUI(MessageName.SKILL_FREE_AIM, enable)
	end

	CombatAction.enableFreeAimMode(self, actionData, combatContext)
end

function ClientCombatAction:setBallProperty(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if ownerEntity.timelineInputConfig == nil then
		return false
	end

	local data = self:getVal(actionData.data)

	ownerEntity.timelineInputConfig[actionData.propertyName] = data

	return true
end

function ClientCombatAction:captureAbsorbEffect(actionData, combatContext)
	local startPosition = self:getVal(actionData.startPosition, combatContext)
	local targetEntityActorId = self:getVal(actionData.targetActorId, combatContext)
	local speed = actionData.speed
	local resId = actionData.resId

	pg.global.resMgr:GetInstanceFromCacheByLua(resId, function(gameObj, userData)
		if IsNil(gameObj) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("captureAbsorbEffect gameObj is nil!")
			end

			return
		end

		local ent = pg.getEntityByActorId(targetEntityActorId)
		local absorbMotor = gameObj:GetComponent(typeof(AbsorbMotor))

		if ent and absorbMotor then
			absorbMotor:Play(startPosition, ent.eModel, speed)
		end
	end)
end

function ClientCombatAction:captureDissolveEffect(actionData, combatContext)
	local ent = pg.getEntityByActorId(self:getVal(actionData.entActorId, combatContext))

	if not ent then
		return
	end

	local eModel = ent.eModel
	local shaderView = eModel and eModel.modelShaderView

	if not shaderView then
		return
	end

	local matResId = self:getVal(actionData.matResId, combatContext)
	local duration = actionData.duration or 1.5

	shaderView:TweenCaptureDissolveEffect(matResId, self:getVal(actionData.hitPos, combatContext), self:getVal(actionData.startValue, combatContext) or 0, self:getVal(actionData.endValue, combatContext) or 1, self:getVal(actionData.border, combatContext) or 0.1, duration, nil, actionData.disableWhenFinished)
end

function ClientCombatAction:tweenEffectPos(actionData, combatContext)
	local effectStoreKey = self:getVal(actionData.effectStoreKey, combatContext)
	local startPosV3 = self:getVal(actionData.startPos, combatContext)
	local endPosV3 = self:getVal(actionData.endPos, combatContext)
	local duration = actionData.duration
	local easeType = actionData.easeType
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)
	local effectId = ownerEntity[effectStoreKey]
	local effectItem = effectId and pg.global.effectMgr:GetEffectItem(0, effectId)

	if not effectItem then
		return
	end

	effectItem:TweenPos(startPosV3, endPosV3, duration, 0, CS.DG.Tweening.Ease.__CastFrom(easeType))
end

function ClientCombatAction:hideCatchBall(actionData, combatContext)
	local ownerEntity = CombatActionTool.getOwnerEntity(combatContext)

	if not Utils.isCatchBall(ownerEntity) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("hideCatchBall can not operate on NON-CATCHBALL entity!")
		end

		return
	end

	if not ownerEntity.eModel or IsNil(ownerEntity.eModel.modelView) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("hideCatchBall can not find modelView!")
		end

		return
	end

	ownerEntity:setScaleNumber(0.01)
end

function ClientCombatAction:stopEffectByEffectStoreKey(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if targetEntity ~= nil then
		local effectStoreKey = self:getVal(actionData.effectStoreKey, combatContext)
		local reclaim = actionData.reclaim
		local effectId = targetEntity[effectStoreKey]

		if effectId then
			pg.game.effect:stopEffect(0, effectId, reclaim, true)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("stopEffectByEffectStoreKey can not find effectId effectStoreKey:", effectStoreKey)
		end
	end
end

function ClientCombatAction:registerPassiveEnergyInfo(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if not ownerEntity.isMainPlayer and not ownerEntity.isMainPet then
		return false
	end

	if ownerEntity.spEnergyInfo == nil then
		ownerEntity.spEnergyInfo = {}
	end

	ownerEntity.spEnergyInfo.normalIcon = actionData.normalIcon
	ownerEntity.spEnergyInfo.fullEnergyIcon = actionData.fullEnergyIcon
	ownerEntity.spEnergyInfo.superBoosted = actionData.superBoosted
	ownerEntity.spEnergyInfo.triggeredFull = false
	ownerEntity.spEnergyInfo.triggeredSuperBoosted = false
	ownerEntity.spEnergyInfo.gridCount = actionData.spEnergyGridCount or 1

	if actionData.uiOffsetXYZ ~= nil then
		ownerEntity.spEnergyInfo.uiOffsetXYZ = actionData.uiOffsetXYZ.name == nil and Vector3(unpack(actionData.uiOffsetXYZ)) or self:doAction(actionData.uiOffsetXYZ, combatContext)
	end

	pg.me.spEnergyBarRefCnt = (pg.me.spEnergyBarRefCnt or 0) + 1

	if pg.global.ui.specialEnergyBar:checkUIClosing() then
		pg.global.ui.specialEnergyBar:open()
	end

	local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

	if not abilityObject then
		return false
	end

	abilityObject:addExitCallback(function()
		pg.me.spEnergyBarRefCnt = pg.me.spEnergyBarRefCnt - 1

		if pg.me.spEnergyBarRefCnt == 0 then
			pg.global.ui.specialEnergyBar:close()
		end
	end)
end

function ClientCombatAction:notifyPassiveEnergySuperBoosted(actionData, combatContext)
	local ownerEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not ownerEntity then
		return false
	end

	if not ownerEntity.isMainPlayer and not ownerEntity.isMainPet then
		return false
	end

	if ownerEntity.spEnergyInfo == nil then
		return false
	end

	ownerEntity.spEnergyInfo.triggeredSuperBoosted = actionData.enable

	facade:sendMsgToUI(MessageName.NOTIFY_PASSIVE_ENERGY_SUPER_BOOSTED)
end

function ClientCombatAction:setOverrideAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	if targetEntity.setOverrideAnimation then
		local srcAnimKey = actionData.srcAnimKey
		local dstAnimKey = actionData.dstAnimKey

		targetEntity:setOverrideAnimation(srcAnimKey, dstAnimKey)

		if targetEntity.isAnimationPlaying and targetEntity:isAnimationPlaying(srcAnimKey) and targetEntity.playAnimation then
			targetEntity:playAnimation(srcAnimKey)
		end

		if not ToBool(actionData.disableRecoverOnExit) then
			local abilityObject = CombatActionTool.getCombatContextAbilityObject(combatContext)

			if not abilityObject then
				return false
			end

			abilityObject:addExitCallback(function()
				if targetEntity.clearOverrideAnimation then
					targetEntity:clearOverrideAnimation(srcAnimKey)
				end

				if targetEntity.isAnimationPlaying and targetEntity:isAnimationPlaying(dstAnimKey) and targetEntity.playAnimation then
					targetEntity:playAnimation(srcAnimKey)
				end
			end)
		end
	end
end

function ClientCombatAction:clearOverrideAnim(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	if targetEntity.clearOverrideAnimation then
		local animKey = actionData.animKey

		targetEntity:clearOverrideAnimation(animKey)
	end
end

function ClientCombatAction:addFlashlightLockTargetByContext(actionData, combatContext)
	local actorId = combatContext.trapTargetActorId

	if not actorId or actorId == 0 then
		return false
	end

	pg.game.controller.lockHelper:addFlashlightLockTarget(actorId)

	return true
end

function ClientCombatAction:removeFlashlightLockTargetByContext(actionData, combatContext)
	local actorId = combatContext.trapTargetActorId

	if not actorId or actorId == 0 then
		return false
	end

	pg.game.controller.lockHelper:removeFlashlightLockTarget(actorId)

	return true
end

function ClientCombatAction:costStamina(actionData, combatContext)
	local targetActorId = CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local targetEntity = pg.getEntityByActorId(targetActorId)

	if not targetEntity then
		return false
	end

	local playerEnt = Utils.convertPlayerEntity(targetEntity)

	if not playerEnt or not playerEnt.actorCombatAttribute or not playerEnt.staminaTickData then
		return false
	end

	if actionData.force or not playerEnt.staminaTickData.freelanceMode then
		local value = self:getVal(actionData.value, combatContext)

		if not actionData.isFix then
			local costRatio = playerEnt.actorCombatAttribute:getStaminaCostRatio()

			value = value * costRatio
		end

		playerEnt.actorCombatAttribute:changeStamina(-value)
	end

	return true
end

function ClientCombatAction:costWater(actionData, combatContext)
	local targetEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	if not targetEntity then
		return false
	end

	local costVal = self:getVal(actionData.value, combatContext)

	if actionData.getParamByLuaConfig then
		local configVal = self:getParamByLuaConfig(actionData.getParamByLuaConfig, combatContext)

		if configVal and configVal ~= 0 then
			costVal = configVal
		end
	end

	if costVal > 0 then
		costVal = -costVal
	end

	if targetEntity.costWater then
		targetEntity:costWater(costVal)
	end
end

function ClientCombatAction:getWater(actionData, combatContext)
	local targetType = actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, targetType))

	if targetEnt then
		return targetEnt.actorCombatAttribute:getCurWater()
	end
end

function ClientCombatAction:isMainPlayer(actionData, combatContext)
	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, actionData.target or AbilityConst.COMBAT_TARGET_TYPE_OWNER))

	return targetEnt and (targetEnt.isMainPlayer or targetEnt.isMainPet)
end

return ClientCombatAction
