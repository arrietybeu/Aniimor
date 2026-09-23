-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIBaseMethodUtils.lua

local AIBaseMethodUtils = {}
local Utils = require("Common.Utils.Utils")
local enums = require("Common.AI.Behaviac.Enums")
local AiConst = require("Common.Const.AiConst")
local PlayableConst = require("Common.Const.PlayableConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local Const = require("Common.Const.Const")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local EventConst = require("Const.EventConst")
local EBTStatus = enums.EBTStatus
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local EBTRootState = BaseEnum.EBTRootState
local AbilityConst = require("Common.Const.AbilityConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local Lume = require("Core.Common.lume")
local TablePool = require("Common.Container.TablePool")
local TriggerConst = require("Common.Const.TriggerConst")
local AIUtils = require("Common.Utils.AIUtils")
local Vector3 = Vector3
local Quaternion = Quaternion
local pg = pg
local math_deg = math.deg
local string_isNilOrEmpty = string.isNilOrEmpty
local type = type

function AIBaseMethodUtils.remoteSyncAIAction(entity, methodName, ...)
	if Utils.checkClient() then
		if Utils.isVirtualEntity(entity) then
			return
		end

		if not entity.space then
			return
		end

		if not Utils.checkIsAuthorityMaster(entity) or not entity.space:isMultiPlayerEnv() then
			return
		end

		local globalId = entity:getGlobalId()
		local params = TablePool.getTable(3)

		Lume.push(params, ...)
		entity.space:remoteSyncAIAction(globalId, methodName, params)
		TablePool.returnTable(params, 3)
	elseif entity.space then
		local globalId = entity:getGlobalId()
		local params = TablePool.getTable(3)

		Lume.push(params, ...)
		entity.space:serverAISyncAIAction(globalId, methodName, params)
		TablePool.returnTable(params, 3)
	end
end

function AIBaseMethodUtils.Base_TurnToDirection(entity, turnDirection, instant, steeringTime)
	return AIControllerUtils.setDirection(entity, turnDirection, instant, steeringTime)
end

function AIBaseMethodUtils.Base_SetRotation(entity, rotation, instant)
	instant = instant or false

	return AIControllerUtils.setRotation(entity, rotation, instant)
end

function AIBaseMethodUtils.Base_SetYawRadians(entity, yaw, instant, steeringTime)
	Vector3.enableCreateFromCache()

	local turnDirection = Quaternion.AngleAxis(math_deg(yaw), Vector3.up) * Vector3.forward
	local ret = AIBaseMethodUtils.Base_TurnToDirection(entity, turnDirection, instant, steeringTime)

	Vector3.disableCreateFromCache()

	return ret
end

function AIBaseMethodUtils.Base_SetYawDegrees(entity, yawDeg, instant, steeringTime)
	return AIControllerUtils.setYawDegrees(entity, yawDeg, instant, steeringTime)
end

function AIBaseMethodUtils.Base_TeleportPos(entity, position, callback)
	if Vector3.SqrDistance(entity:getPosition(), position) < AiConst.TeleportMinDistance then
		if callback then
			callback(true)
		end

		return
	end

	AIControllerUtils.teleport(entity, position, callback)

	if Utils.checkClient() and entity.playSwitchAppearEffect then
		entity:playSwitchAppearEffect(0.5)
	end
end

function AIBaseMethodUtils.Base_PlayEffect(entity, effectName, tgtPosition)
	tgtPosition = tgtPosition or entity:getPosition()

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayEffect", effectName, tgtPosition)

	if Utils.checkClient() then
		pg.game.effect:playEffectAt(0, effectName, tgtPosition, nil, entity)
	end
end

function AIBaseMethodUtils.Base_PlayEffectAtTarget(entity, effectName, targetActorId, duration)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayEffectAtTarget", effectName, targetActorId, duration)

	if Utils.checkClient() then
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if targetEnt then
			local tmpTable = TablePool.getTable()

			tmpTable.duration = duration

			targetEnt:playEffect(effectName, tmpTable)
			TablePool.returnTable(tmpTable)
		end
	end
end

function AIBaseMethodUtils.Base_StopEffectAtTarget(entity, effectName, targetActorId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopEffectAtTarget", effectName, targetActorId)

	if Utils.checkClient() then
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if targetEnt then
			targetEnt:stopEffect(effectName)
		end
	end
end

function AIBaseMethodUtils.Base_PlayLipAnimation(entity, fadeTime)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayLipAnimation", fadeTime)
	AnimationUtils.playLipAnimation(entity, nil, fadeTime)
end

function AIBaseMethodUtils.Base_StopLipAnimation(entity, fadeTime)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopLipAnimation", fadeTime)
	AnimationUtils.stopLipAnimation(entity, fadeTime)
end

function AIBaseMethodUtils.Base_PlayFacialAnimation(entity, facialConst, fadeTime)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayFacialAnimation", facialConst, fadeTime)
	AnimationUtils.playFacialAnimation(entity, facialConst, fadeTime)
end

function AIBaseMethodUtils.Base_StopFacialAnimation(entity, fadeTime)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopFacialAnimation", fadeTime)
	AnimationUtils.stopFacialAnimation(entity, fadeTime)
end

function AIBaseMethodUtils.Base_StopAnimation(entity, key, layer)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopAnimation", AnimationUtils.getID(key), layer)
	AnimationUtils.stopAnimation(entity, key, layer)
end

function AIBaseMethodUtils.Base_PlayAnimationState(entity, animState, replaceAnimNameKey, clearWaitState)
	return AnimationUtils.playAnimationState(entity, animState, replaceAnimNameKey, clearWaitState)
end

function AIBaseMethodUtils.Base_CancelAnimationState(entity, animState)
	return AnimationUtils.cancelAnimationState(entity, animState)
end

function AIBaseMethodUtils.Base_PlayAnimation(entity, animation, layer, fromStart, timelineTag, isLoop, animationRootMotionType)
	if fromStart == nil then
		fromStart = true
	end

	local rootMotionType

	if animationRootMotionType ~= nil and animationRootMotionType ~= BaseEnum.AIAnimationRootMotionType.Default then
		rootMotionType = animationRootMotionType - 1
	end

	animation = AnimationUtils.getID(animation)

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayAnimation", animation, layer, fromStart, timelineTag, isLoop, animationRootMotionType)

	return AnimationUtils.playAnimation(entity, animation, layer, fromStart, timelineTag, isLoop, rootMotionType)
end

function AIBaseMethodUtils.Base_ChangeToRootMotion(entity, rootMotionIndex, targetPosition, targetRotation, rotationInstant, syncPointEnum, endCallback, warpXZ, warpY, warpRot)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayAnimation", rootMotionIndex, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, true, "", false, BaseEnum.AIAnimationRootMotionType.RootMotion)

	return AnimationUtils.playRootMotion(entity, rootMotionIndex, targetPosition, targetRotation, rotationInstant, syncPointEnum, endCallback, warpXZ, warpY, warpRot)
end

function AIBaseMethodUtils.Base_PlaySleAnimation(entity, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag)
	key1 = AnimationUtils.getID(key1)
	key2 = AnimationUtils.getID(key2)
	key3 = AnimationUtils.getID(key3)

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlaySleAnimation", key1, key2, key3, bPlayOnce, fDuration, sTimelineTag)
	AnimationUtils.playSleAnimation(entity, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	return EBTStatus.BT_RUNNING
end

function AIBaseMethodUtils.Base_StopSleAnimation(entity)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopSleAnimation")
	AnimationUtils.stopSleAnimation(entity)
end

function AIBaseMethodUtils.Base_PlayAnimationList(entity, animList, callback)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayAnimationList", animList)
	AnimationUtils.playAnimationList(entity, animList, callback, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function AIBaseMethodUtils.Base_StopAnimationList(entity)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopAnimationList")
	AnimationUtils.stopAnimationList(entity)
	AnimationUtils.stopLayerAnimation(entity, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function AIBaseMethodUtils.Base_SetLayerDefaultAnimation(entity, defaultAnimationName)
	defaultAnimationName = string_isNilOrEmpty(defaultAnimationName) and 0 or AnimationUtils.getID(defaultAnimationName)

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_SetLayerDefaultAnimation", defaultAnimationName)
	AnimationUtils.setLayerDefaultAnimation(entity, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, defaultAnimationName)
end

function AIBaseMethodUtils.Base_PlayEmojiOnTeam(entity, targetActorId, emojiStr)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayEmojiOnTeam", targetActorId, emojiStr)

	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(targetActorId)

		if ent == nil then
			return
		end

		local tmpTable = TablePool.getTable()

		tmpTable.petId = ent.id
		tmpTable.emojiName = emojiStr

		pg.me:playTeamEmoji(tmpTable)
		TablePool.returnTable(tmpTable)
	end
end

function AIBaseMethodUtils.Base_ShowEmojiBubble(entity, emojiName, timeout, matchMultiple)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_ShowEmojiBubble", emojiName, timeout, matchMultiple)

	if Utils.checkClient() then
		entity.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, timeout, matchMultiple)
	end
end

function AIBaseMethodUtils.Base_HideEmojiBubble(entity, targetActorId, emojiStr)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_HideEmojiBubble", targetActorId, emojiStr)

	if Utils.checkClient() then
		local ent = targetActorId and pg.getEntityByActorId(targetActorId) or entity
		local emitEventPreCheckCompFunc = ent.emitEventPreCheckComp

		if emitEventPreCheckCompFunc then
			emitEventPreCheckCompFunc(ent, EventConst.TOPLOGO_BUBBLE, false, emojiStr)
		end
	end
end

function AIBaseMethodUtils.Base_ShowDialogue(entity, dialogueId)
	if not entity then
		return
	end

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_ShowDialogue", dialogueId)

	if Utils.checkClient() then
		pg.game.communication:startNpcDialog(dialogueId, entity.id, {
			forbidNextBtnClick = true
		})
	end
end

function AIBaseMethodUtils.Base_ShowQuestionMark(entity, markType, timeout)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_ShowQuestionMark", markType, timeout)

	if Utils.checkClient() then
		if not entity.ensureTopLogoItem or not entity:ensureTopLogoItem("alert") then
			return
		end

		entity.eventEmitter:emit(EventConst.TOPLOGO_ALERT, true, markType, timeout)
	end
end

function AIBaseMethodUtils.Base_HideQuestionMark(entity)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_HideQuestionMark")

	if Utils.checkClient() then
		entity.eventEmitter:emit(EventConst.TOPLOGO_ALERT, false)
	end
end

function AIBaseMethodUtils.Base_ShowBubbleMsgById(entity, messageId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_ShowBubbleMsgById", messageId)

	if Utils.checkClient() then
		pg.global.showBubbleMessageById(messageId)
	end
end

function AIBaseMethodUtils.Base_HideBubbleMsgById(entity, messageId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_HideBubbleMsgById", messageId)

	if Utils.checkClient() then
		pg.global.hideBubbleMessageById(messageId)
	end
end

function AIBaseMethodUtils.Base_LerpProperty(entity, enable, lerpTime)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_LerpProperty", enable, lerpTime)

	if Utils.checkClient() then
		entity.eModel.modelShaderView:LerpProperty(enable, lerpTime)
	end
end

function AIBaseMethodUtils.Base_ShowEmojiBubbleInPetList(entity, emojiName)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_ShowEmojiBubbleInPetList", emojiName)

	if Utils.checkClient() then
		local MessageName = require("Const.MessageName")
		local tmpTable = TablePool.getTable()

		tmpTable.petId = entity.id
		tmpTable.emojiName = emojiName

		facade:SendMessageCommand(MessageName.PET_SHOW_EMOJI, tmpTable)
		TablePool.returnTable(tmpTable)
	end
end

function AIBaseMethodUtils.Base_SetTargetAnimationState(entity, animState, animationKey)
	if not Utils.checkClient() and animationKey then
		AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayAnimation", AnimationUtils.getID(animationKey), true, "", true, BaseEnum.AIAnimationRootMotionType.None, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end

	AutoPathFindUtils.setTargetAnimationState(entity, animState, animationKey)
end

function AIBaseMethodUtils.Base_CombatCastAbilityOnTarget(entity, abilityId, targetId, partId, castSource)
	local castResult, errMsg

	partId = partId or 0
	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL

	if Utils.checkClient() then
		castResult, errMsg = entity:clientCastAbilityOnTarget(abilityId, targetId, castSource)
	else
		castResult, errMsg = entity:serverCastAbility(abilityId, targetId)
	end

	return castResult, errMsg
end

function AIBaseMethodUtils.Base_CombatCastAbilityNoTarget(entity, abilityId, castSource)
	local castResult, errMsg

	castSource = castSource or AbilityConst.CAST_SOURCE.NORMAL

	if Utils.checkClient() then
		castResult, errMsg = entity:clientCastAbilityNoTarget(abilityId, castSource)
	else
		castResult, errMsg = entity:serverCastAbility(abilityId, 0, castSource)
	end

	return castResult, errMsg
end

function AIBaseMethodUtils.Base_SetPetAppearance(entity, individuationId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_SetPetAppearance", individuationId)

	if Utils.checkClient() then
		local eventContext = {
			source = Const.ESM_INTERACT,
			fromEntId = entity.id,
			globalId = entity.getGlobalId and entity:getGlobalId()
		}

		pg.me:doEventByData({
			"setPetAppearance",
			{
				individuationId
			},
			0
		}, eventContext)
	end
end

function AIBaseMethodUtils.Base_DestroyEnvObj(entity, envObjActorId, delaySecond)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_DestroyEnvObj", envObjActorId, delaySecond)

	if Utils.checkClient() then
		local envObj = pg.getEntityByActorId(envObjActorId)

		if envObj and envObj.destroyEntityByAI then
			envObj:destroyEntityByAI(delaySecond)
		end
	end
end

function AIBaseMethodUtils.Base_SetModelActive(entity, entityActorId, objectName, active)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_SetModelActive", entityActorId, objectName, active)

	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(entityActorId)

		if ent == nil or ent.setChildVisible == nil then
			return
		end

		ent:setChildVisible(objectName, active)
	end
end

function AIBaseMethodUtils.Base_PlaySound(entity, targetActorId, soundId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlaySound", targetActorId, soundId)

	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(targetActorId)

		if ent == nil then
			return
		end

		ent:playSoundEvent(soundId)
	end
end

function AIBaseMethodUtils.Base_TriggerBluePrint(entity, entityActorId, eventName)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_TriggerBluePrint", entityActorId, eventName)

	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(entityActorId)

		if ent then
			ent:serverMsgNoGC("RPC_CS_TriggerBlueprint", eventName)
		end
	end
end

function AIBaseMethodUtils.Base_AddSelfHate(entity, targetActorId)
	if entity then
		if Utils.checkClient() then
			entity:serverMsgNoGC("RPC_CS_TryAddHatred", targetActorId)
		else
			local targetEnt = pg.getEntityByActorId(targetActorId)

			if targetEnt then
				entity:addViewHatred(targetEnt, 1)
			end
		end
	end
end

function AIBaseMethodUtils.Base_SendMessageToTrigger(entity, entityActorId, msgId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_SendMessageToTrigger", entityActorId, msgId)

	local ent = pg.getEntityByActorId(entityActorId)

	if Utils.checkClient() then
		local TriggerAiMsgData = require("Data.trigger_ai_msg_data")

		if ent then
			local basePetPrototypeId = ent.basePetPrototypeId or Utils.getBasePetPrototypeId(ent.petPrototypeId)

			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_AI_MSG, ent.petPrototypeId, 1, msgId)
			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_AI_MSG_BASE, basePetPrototypeId, 1, msgId)
		end

		if Utils.isPet(ent) then
			local triggerMap = ent.petInfo.triggerMap
			local isRegister = triggerMap:isRegisterTriggerType(TriggerConst.PET_TRIGGER_SEND_AI_MSG, ent.petPrototypeId) or triggerMap:isRegisterTriggerType(TriggerConst.PET_TRIGGER_SEND_AI_MSG_FORM, ent.basePetPrototypeId)
			local triggerData = TriggerAiMsgData[ent.petPrototypeId] or TriggerAiMsgData[ent.basePetPrototypeId]
			local needTrigger = triggerData and triggerData[msgId]

			if type(msgId) == "number" and isRegister and needTrigger then
				ent:serverMsg("RPC_CS_TriggerAIMsg", msgId)
			end
		end
	elseif Utils.isPet(ent) then
		ent.petInfo.triggerMap:onTrigger(TriggerConst.PET_TRIGGER_SEND_AI_MSG, ent.petPrototypeId, 1, msgId)
		ent.petInfo.triggerMap:onTrigger(TriggerConst.PET_TRIGGER_SEND_AI_MSG_FORM, ent.basePetPrototypeId, 1, msgId)
	end
end

function AIBaseMethodUtils.Base_SendMessageToTriggerSpecial(entity, mainActorId, anotherActorId)
	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_SendMessageToTriggerSpecial", mainActorId, anotherActorId)

	if Utils.checkClient() then
		local mainEnt = pg.getEntityByActorId(mainActorId)
		local otherEnt = pg.getEntityByActorId(anotherActorId)

		if mainEnt and otherEnt then
			local mainPetBaseId = mainEnt.basePetPrototypeId or Utils.getBasePetPrototypeId(mainEnt.petPrototypeId)
			local otherPetPrototypeId = Utils.isPlayer(otherEnt) and -1 or otherEnt.petPrototypeId

			pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_PET_AI_MSG_SPECIAL, mainPetBaseId, 1, otherPetPrototypeId)
		end
	end
end

function AIBaseMethodUtils.Base_PlayPreset(entity, actorId, presetName, duration, disableWhenFinished, loopCount, renderNameList)
	if string_isNilOrEmpty(presetName) then
		return EBTStatus.BT_SUCCESS
	end

	if renderNameList and #renderNameList == 0 then
		renderNameList = nil
	end

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_PlayPreset", actorId, presetName, duration, disableWhenFinished, loopCount, renderNameList)

	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(actorId)

		if not targetEntity then
			return EBTStatus.BT_SUCCESS
		end

		local shaderView = targetEntity.eModel.modelShaderView

		if not shaderView then
			return EBTStatus.BT_SUCCESS
		end

		local configData = targetEntity:getConfigData()

		ClientEffectUtils.PlayPreset(targetEntity, presetName, duration, disableWhenFinished, loopCount or -1, nil, nil, nil, nil, renderNameList or nil)
	end

	return EBTStatus.BT_SUCCESS
end

function AIBaseMethodUtils.Base_StopPreset(entity, actorId, presetName)
	if string_isNilOrEmpty(presetName) then
		return EBTStatus.BT_SUCCESS
	end

	AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopPreset", actorId, presetName)

	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(actorId)

		if not targetEntity then
			return EBTStatus.BT_SUCCESS
		end

		local shaderView = targetEntity.eModel.modelShaderView

		if shaderView then
			ClientEffectUtils.StopPreset(targetEntity, presetName)
		end
	end

	return EBTStatus.BT_SUCCESS
end

function AIBaseMethodUtils.Base_AddBuff(entity, buffId, duration)
	if Utils.checkClient() then
		entity:serverMsgNoGC("RPC_CS_AIAddBuff", buffId, duration)
	else
		entity:addBuffByAIMethod(buffId, duration)
	end
end

function AIBaseMethodUtils.Base_RemoveBuff(entity, buffId)
	if Utils.checkClient() then
		entity:serverMsgNoGC("RPC_CS_AIRemoveBuff", buffId)
	else
		entity:removeBuffByAIMethod(buffId)
	end
end

function AIBaseMethodUtils.Base_StartGrabEntity(entity, beGrabActorId)
	if Utils.checkClient() then
		AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StartGrabEntity", beGrabActorId)

		return AIControllerUtils.startGrabEntity(entity, beGrabActorId)
	end

	return false
end

function AIBaseMethodUtils.Base_StopGrabEntity(entity)
	if Utils.checkClient() then
		AIBaseMethodUtils.remoteSyncAIAction(entity, "Base_StopGrabEntity")

		return AIControllerUtils.stopGrabEntity(entity)
	end

	return false
end

return AIBaseMethodUtils
