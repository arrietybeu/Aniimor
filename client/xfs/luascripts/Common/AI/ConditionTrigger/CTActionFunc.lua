-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ConditionTrigger\\CTActionFunc.lua

local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local AIUtils = require("Common.Utils.AIUtils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("CTActionFunc")
local CTActionFunc = {}

function CTActionFunc.AddAITag(flow, entityActorId, tagName)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.addAITag then
		ent:addAITag(tagName)
	end
end

function CTActionFunc.AddBuff(flow, entityActorId, buffId, duration)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		AIBaseMethodUtils.Base_AddBuff(ent, buffId, duration)
	end
end

function CTActionFunc.AddEntityTag(flow, entityActorId, tag)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	Utils.addEntityTag(ent, tag)
end

function CTActionFunc.BlendToFov(flow, fov, blendTime, blendType)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:blendToFov(fov, blendTime, blendType)
	end
end

function CTActionFunc.CancelFovBlend(flow, blendOutTime, blendType)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovBlend(blendOutTime, blendType)
	end
end

function CTActionFunc.CancelFovCurveAnim(flow)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovCurveAnim()
	end
end

function CTActionFunc.CancelLookAtEntity(flow)
	if Utils.checkClient() then
		flow.__owner:cancelLookAtRole()
	end
end

function CTActionFunc.ClearNotTargetLetGoCD(flow)
	if Utils.checkClient() then
		pg.me:clearNotTargetLetGoCD()
	end
end

function CTActionFunc.DebugVar(flow, strVar, floatVar, intVar, boolVar, tableVar)
	logger:info("strVar:%s, floatVar:%s, intVar:%s, boolVar:%s, tableVar:%s", strVar, tostring(floatVar), tostring(intVar), tostring(boolVar), inspect(tableVar))
end

function CTActionFunc.DestroyEnvObj(flow, envObjActorId, delaySecond)
	AIBaseMethodUtils.Base_DestroyEnvObj(flow.__owner, envObjActorId, delaySecond)
end

function CTActionFunc.DoSysEvent(flow, entityActorId, eventId)
	if Utils.checkClient() then
		entityActorId = flow:getValidActorId(entityActorId)

		local ent = pg.getEntityByActorId(entityActorId)

		if ent then
			pg.me:doEvent(eventId, {
				globalId = ent:getGlobalId()
			})
		end
	end
end

function CTActionFunc.DynamicAddBehavior(flow, entityActorId, behaviorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.dynamicAddBehavior then
		ent:dynamicAddBehavior(behaviorId)
	end
end

function CTActionFunc.DynamicRemoveBehavior(flow, entityActorId, behaviorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.dynamicRemoveBehavior then
		ent:dynamicRemoveBehavior(behaviorId)
	end
end

function CTActionFunc.EnterCombat(flow, entityActorId, targetActorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	AIUtils.enterCombat(ent, targetActorId)
end

function CTActionFunc.EnterFollow(flow, entityActorId, targetActorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	AIUtils.enterFollow(ent, targetActorId)
end

function CTActionFunc.EnterPetGuide(flow, entityActorId, targetActorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and Utils.isPet(ent) then
		AIUtils.enterGuide(ent, targetActorId)
	end
end

function CTActionFunc.EnterPhotoEcology(flow, pointId)
	ResPointUtils.EnterPhotoEcology(pointId, flow.__actorId)
end

function CTActionFunc.ExitPetGuide(flow, entityActorId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and Utils.isPet(ent) then
		AIUtils.exitGuide(ent)
	end
end

function CTActionFunc.ExitPhotoEcology(flow, pointId)
	ResPointUtils.ExitPhotoEcology(pointId)
end

function CTActionFunc.ExitResPointPort(flow, entityActorId, targetPointId, targetPortId, delayTime, exitDistance)
	entityActorId = flow:getValidActorId(entityActorId)

	local actorId, pointId = ResPointUtils.FromFixPointId(targetPointId)

	ResPointUtils.ExitPort(entityActorId, actorId, pointId, targetPortId, delayTime, exitDistance)
end

function CTActionFunc.FinishHomeLandLeisure(flow, revision)
	HomeLandUtils.homeLeisureFinished(flow.__owner, revision)
end

function CTActionFunc.FinishHomeLandOperation(flow, needResetHomeWork)
	if needResetHomeWork then
		HomeLandUtils.deAllocateHomePetWork(flow.__owner)
	end

	HomeLandUtils.homeOperationFinished(flow.__owner)
end

function CTActionFunc.HideEmojiOnTarget(flow, targetActorId, emojiStr)
	targetActorId = flow:getValidActorId(targetActorId)

	AIBaseMethodUtils.Base_HideEmojiBubble(flow.__owner, targetActorId, emojiStr)
end

function CTActionFunc.HideQuestionMark(flow, entityActorId)
	entityActorId = flow:getValidActorId(entityActorId)

	AIBaseMethodUtils.Base_HideQuestionMark(pg.getEntityByActorId(entityActorId))
end

function CTActionFunc.JoinResPointBehaviour(flow, entityActorId, targetPointId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)
	local actorId, pointId = ResPointUtils.FromFixPointId(targetPointId)
	local groupBehaviour = ResPointUtils.GetGroupBehaviourFromResPoint(actorId, pointId)

	if ent and ent.joinGroupBehaviour and groupBehaviour then
		ent:joinGroupBehaviour(groupBehaviour)
	end
end

function CTActionFunc.JoinResPointPort(flow, entityActorId, targetPointId, targetPortId)
	entityActorId = flow:getValidActorId(entityActorId)

	local actorId, pointId = ResPointUtils.FromFixPointId(targetPointId)

	ResPointUtils.JoinPort(entityActorId, actorId, pointId, targetPortId)
end

function CTActionFunc.LerpProperty(flow, enable, lerpTime, targetActorId)
	local ent = pg.getEntityByActorId(targetActorId)

	if ent then
		AIBaseMethodUtils.Base_LerpProperty(ent, enable, lerpTime)
	end
end

function CTActionFunc.LookAtEntity(flow, targetActorId, force)
	if Utils.checkClient() then
		flow.__owner:lookAtRole(pg.getEntityByActorId(targetActorId), force)
	end
end

function CTActionFunc.PlayEffectOnTarget(flow, targetActorId, effectStr, duration)
	targetActorId = flow:getValidActorId(targetActorId)

	AIBaseMethodUtils.Base_PlayEffectAtTarget(flow.__owner, effectStr, targetActorId, duration or 1)
end

function CTActionFunc.PlayEmojiOnTarget(flow, targetActorId, emojiStr, duration)
	targetActorId = flow:getValidActorId(targetActorId)

	AIBaseMethodUtils.Base_ShowEmojiBubble(flow.__owner, emojiStr, duration)
end

function CTActionFunc.PlayFovCurveAnim(flow, fovCurveName, blendInTime, duration, blendOutTime)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:playFovCurveAnim(fovCurveName, blendInTime, duration, blendOutTime)
	end
end

function CTActionFunc.PreJoinResPointPort(flow, entityActorId, targetPointId, targetPortId)
	entityActorId = flow:getValidActorId(entityActorId)

	local actorId, pointId = ResPointUtils.FromFixPointId(targetPointId)

	ResPointUtils.PreJoinPort(entityActorId, actorId, pointId, targetPortId)
end

function CTActionFunc.RecruitBeginFollowOneByOne(flow, ownerActorId)
	if Utils.checkClient() then
		local ownerEntity = pg.getEntityByActorId(ownerActorId)

		if ownerEntity and ownerEntity.beginFollowOneByOne then
			ownerEntity:beginFollowOneByOne()
		end
	end
end

function CTActionFunc.RemoveAITag(flow, entityActorId, tagName)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.removeAITag then
		ent:removeAITag(tagName)
	end
end

function CTActionFunc.RemoveBuff(flow, entityActorId, buffId)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		AIBaseMethodUtils.Base_RemoveBuff(ent, buffId)
	end
end

function CTActionFunc.RemoveEntityTag(flow, entityActorId, tag)
	entityActorId = flow:getValidActorId(entityActorId)

	local ent = pg.getEntityByActorId(entityActorId)

	Utils.removeEntityTag(ent, tag)
end

function CTActionFunc.SendMessageToTrigger(flow, entityActorId, msgId)
	entityActorId = flow:getValidActorId(entityActorId)

	AIBaseMethodUtils.Base_SendMessageToTrigger(flow.__owner, entityActorId, msgId)
end

function CTActionFunc.SendMessageToTriggerSpecial(flow, mainActorId, anotherActorId)
	mainActorId = flow:getValidActorId(mainActorId)
	anotherActorId = flow:getValidActorId(anotherActorId)

	AIBaseMethodUtils.Base_SendMessageToTriggerSpecial(flow.__owner, mainActorId, anotherActorId)
end

function CTActionFunc.SetAFKScreen(flow, enable)
	if Utils.checkClient() then
		local ent = flow.__owner
		local afkScreenDist = ent:getConfigData().afkScreenDist

		if afkScreenDist then
			if enable then
				Vector3.enableCreateFromCache()

				local curForward = ent:getRotation():Forward()
				local planeDist = ent:getPosition() + curForward * afkScreenDist * ent.curModelScale
				local normal = curForward

				ent.eModel.modelShaderView:SetAFKBodyScreenDeform(true, planeDist[1], planeDist[2], planeDist[3], normal[1], normal[2], normal[3])
				Vector3.disableCreateFromCache()
			else
				ent.eModel.modelShaderView:SetAFKBodyScreenDeform(false)
			end
		end
	end
end

function CTActionFunc.SetModelActive(flow, entityActorId, objectName, active)
	AIBaseMethodUtils.Base_SetModelActive(flow.__owner, entityActorId, objectName, active)
end

function CTActionFunc.SetNpcStatus(flow, staticId, key, val, forceRefresh)
	if Utils.checkClient() then
		pg.me:requestSetNpcBehaviorStatus(staticId, key, val, forceRefresh)
	end
end

function CTActionFunc.SetPetAppearance(flow, targetActorId, individuationId)
	local ent = pg.getEntityByActorId(targetActorId)

	if ent then
		AIBaseMethodUtils.Base_SetPetAppearance(ent, individuationId)
	end
end

function CTActionFunc.SetPlayerFaceToTarget(flow, targetActorId, duration)
	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if targetEntity and pg.game.camera:isInBaseCamera() then
			pg.game.camera:cameraFaceToTarget(targetEntity, targetEntity:getHeight() * 0.5, duration)
		end
	end
end

function CTActionFunc.SetPlayerVar(flow, key, val)
	if Utils.checkClient() then
		pg.me:requestSetCustomVariable(key, val)
	end
end

function CTActionFunc.SetVisionAreaOverride(flow, areaName)
	local ent = flow.__owner

	if ent and ent.setVisualPerceptibilityGroup then
		ent:setVisualPerceptibilityGroup(areaName)
	end
end

function CTActionFunc.ShowQuestionMark(flow, entityActorId, markType)
	entityActorId = flow:getValidActorId(entityActorId)

	AIBaseMethodUtils.Base_ShowQuestionMark(pg.getEntityByActorId(entityActorId), markType)
end

function CTActionFunc.StartNpcDialog(flow, dialogId, actorId)
	actorId = flow:getValidActorId(actorId)

	AIBaseMethodUtils.Base_ShowDialogue(pg.getEntityByActorId(actorId), dialogId)
end

function CTActionFunc.StopEffectOnTarget(flow, targetActorId, effectKey)
	targetActorId = flow:getValidActorId(targetActorId)

	AIBaseMethodUtils.Base_StopEffectAtTarget(flow.__owner, effectKey, targetActorId)
end

function CTActionFunc.TriggerBluePrint(flow, eventName)
	AIBaseMethodUtils.Base_TriggerBluePrint(flow.__owner, flow.__actorId, eventName)
end

function CTActionFunc.TryHomeLeisureMount(flow, vehicleActorId, seatIndex, revision)
	HomeLandUtils.tryMountHomeLeisureRide(flow.__owner, vehicleActorId, seatIndex, revision)
end

function CTActionFunc.playEmojiOnTeam(flow, targetActorId, emojiStr, duration)
	AIBaseMethodUtils.Base_PlayEmojiOnTeam(flow.__owner, targetActorId, emojiStr)
end

function CTActionFunc.playSound(flow, targetActorId, soundId, duration)
	AIBaseMethodUtils.Base_PlaySound(flow.__owner, targetActorId, soundId)
end

function CTActionFunc.ReqEnterRecruit(flow, targetActorId)
	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(targetActorId)

		if targetEntity and targetEntity.doCallFriend then
			targetEntity:doCallFriend(flow.__actorId)
		end
	end
end

return CTActionFunc
