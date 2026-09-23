-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\CTREventFunc.lua

local Class = require("Core.Framework.Class")
local CTREventFuc = Class.LiteClass("CTREventFunc")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CTREventFunc")
local EventConst = require("Const.EventConst")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local AiConst = require("Common.Const.AiConst")
local TriggerConst = require("Common.Const.TriggerConst")
local CTRPool = require("Common.AICt.CTRPool")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")

function CTREventFuc.RecruitBeginFollowOneByOne(context)
	if Utils.checkClient() then
		local ownerEntity = pg.getEntityByActorId(context.ownerActorId)

		if ownerEntity and ownerEntity.beginFollowOneByOne then
			ownerEntity:beginFollowOneByOne()
		end
	end
end

function CTREventFuc.LerpProperty(context)
	local ent = pg.getEntityByActorId(context.targetActorId)

	if ent then
		AIBaseMethodUtils.Base_LerpProperty(ent, context.enable, context.lerpTime)
	end
end

function CTREventFuc.SetPetAppearance(context)
	local ent = pg.getEntityByActorId(context.targetActorId)

	if ent then
		AIBaseMethodUtils.Base_SetPetAppearance(ent, context.individuationId)
	end
end

function CTREventFuc.DestroyEnvObj(context)
	AIBaseMethodUtils.Base_DestroyEnvObj(pg.getEntityByActorId(context._entActorId), context.envObjActorId, context.delaySecond)
end

function CTREventFuc.SetModelActive(context)
	AIBaseMethodUtils.Base_SetModelActive(pg.getEntityByActorId(context._entActorId), context.active, context.entityActorId, context.objectName, context.active)
end

function CTREventFuc.PreJoinResPointPort(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local actorId, pointId = ResPointUtils.FromFixPointId(context.targetPointId)

	ResPointUtils.PreJoinPort(entityActorId, actorId, pointId, context.targetPortId)
end

function CTREventFuc.JoinResPointPort(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local actorId, pointId = ResPointUtils.FromFixPointId(context.targetPointId)

	ResPointUtils.JoinPort(entityActorId, actorId, pointId, context.targetPortId)
end

function CTREventFuc.ExitResPointPort(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local actorId, pointId = ResPointUtils.FromFixPointId(context.targetPointId)

	ResPointUtils.ExitPort(entityActorId, actorId, pointId, context.targetPortId, context.delayTime, context.exitDistance)
end

function CTREventFuc.PlayEffectOnTarget(context)
	local targetActorId = context.targetActorId == 0 and context._entActorId or context.targetActorId

	AIBaseMethodUtils.Base_PlayEffectAtTarget(pg.getEntityByActorId(context._entActorId), context.effectStr, targetActorId, context.duration or 1)
end

function CTREventFuc.StopEffectOnTarget(context)
	local targetActorId = context.targetActorId == 0 and context._entActorId or context.targetActorId

	AIBaseMethodUtils.Base_StopEffectAtTarget(pg.getEntityByActorId(context._entActorId), context.effectKey, targetActorId)
end

function CTREventFuc.PlayFovCurveAnim(context)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:playFovCurveAnim(context.fovCurveName, context.blendInTime, context.duration, context.blendOutTime)
	end
end

function CTREventFuc.CancelFovCurveAnim(context)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovCurveAnim()
	end
end

function CTREventFuc.BlendToFov(context)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:blendToFov(context.fov, context.blendTime, context.blendType)
	end
end

function CTREventFuc.CancelFovBlend(context)
	if Utils.checkClient() then
		pg.game.camera.playerCameraMode:cancelFovBlend(context.blendOutTime, context.blendType)
	end
end

function CTREventFuc.PlayEmojiOnTarget(context)
	local targetActorId = context.targetActorId == 0 and context._entActorId or context.targetActorId

	AIBaseMethodUtils.Base_ShowEmojiBubble(pg.getEntityByActorId(context._entActorId), context.emojiStr, context.duration)
end

function CTREventFuc.HideEmojiOnTarget(context)
	local targetActorId = context.targetActorId == 0 and context._entActorId or context.targetActorId

	AIBaseMethodUtils.Base_HideEmojiBubble(pg.getEntityByActorId(context._entActorId), targetActorId, context.emojiStr)
end

function CTREventFuc.playEmojiOnTeam(context)
	AIBaseMethodUtils.Base_PlayEmojiOnTeam(pg.getEntityByActorId(context._entActorId), context.targetActorId, context.emojiStr)
end

function CTREventFuc.playSound(context)
	AIBaseMethodUtils.Base_PlaySound(pg.getEntityByActorId(context._entActorId), context.targetActorId, context.soundId)
end

function CTREventFuc.AddBuff(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		AIBaseMethodUtils.Base_AddBuff(ent, context.buffId, context.duration)
	end
end

function CTREventFuc.RemoveBuff(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		AIBaseMethodUtils.Base_RemoveBuff(ent, context.buffId)
	end
end

function CTREventFuc.EnterFollow(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)
	local targetActorId = context.targetActorId

	AIUtils.enterFollow(ent, targetActorId)
end

function CTREventFuc.EnterCombat(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)
	local targetActorId = context.targetActorId

	AIUtils.enterCombat(ent, targetActorId)
end

function CTREventFuc.EnterPetGuide(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and Utils.isPet(ent) then
		AIUtils.enterGuide(ent, context.targetActorId)
	end
end

function CTREventFuc.ExitPetGuide(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and Utils.isPet(ent) then
		AIUtils.exitGuide(ent)
	end
end

function CTREventFuc.AddAITag(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.addAITag then
		ent:addAITag(context.tagName, context)
	end
end

function CTREventFuc.RemoveAITag(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.removeAITag then
		ent:removeAITag(context.tagName)
	end
end

function CTREventFuc.JoinResPointBehaviour(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)
	local actorId, pointId = ResPointUtils.FromFixPointId(context.targetPointId)
	local groupBehaviour = ResPointUtils.GetGroupBehaviourFromResPoint(actorId, pointId)

	if ent and ent.joinGroupBehaviour and groupBehaviour then
		ent:joinGroupBehaviour(groupBehaviour)
	end
end

function CTREventFuc.SetPlayerVar(context)
	if Utils.checkClient() then
		pg.me:requestSetCustomVariable(context.key, context.val)
	end
end

function CTREventFuc.SetNpcStatus(context)
	if Utils.checkClient() then
		pg.me:requestSetNpcBehaviorStatus(context.staticId, context.key, context.val, context.forceRefresh)
	end
end

function CTREventFuc.DebugVar(context)
	logger:info("strVar:%s, floatVar:%s, intVar:%s, boolVar:%s, tableVar:%s", context.strVar, tostring(context.floatVar), tostring(context.intVar), tostring(context.boolVar), inspect(context.tableVar))
end

function CTREventFuc.EnterPhotoEcology(context)
	ResPointUtils.EnterPhotoEcology(context.pointId, context._entActorId)
end

function CTREventFuc.ExitPhotoEcology(context)
	ResPointUtils.ExitPhotoEcology(context.pointId)
end

function CTREventFuc.SetPlayerFaceToTarget(context)
	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(context.targetActorId)

		if targetEntity and pg.game.camera:isInBaseCamera() then
			pg.game.camera:cameraFaceToTarget(targetEntity, targetEntity:getHeight() * 0.5, context.duration)
		end
	end
end

function CTREventFuc.StartNpcDialog(context)
	local actorId = AIUtils.getActorIdFromContext(context.entityActorId, context)

	AIBaseMethodUtils.Base_ShowDialogue(pg.getEntityByActorId(actorId), context.dialogId)
end

function CTREventFuc.DynamicAddBehavior(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.dynamicAddBehavior then
		ent:dynamicAddBehavior(context.behaviorId)
	end
end

function CTREventFuc.DynamicRemoveBehavior(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.dynamicRemoveBehavior then
		ent:dynamicRemoveBehavior(context.behaviorId)
	end
end

function CTREventFuc.AddEntityTag(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	Utils.addEntityTag(ent, context.tag)
end

function CTREventFuc.RemoveEntityTag(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	Utils.removeEntityTag(ent, context.tag)
end

function CTREventFuc.TriggerBluePrint(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)

	AIBaseMethodUtils.Base_TriggerBluePrint(pg.getEntityByActorId(context._entActorId), entityActorId, context.eventName)
end

function CTREventFuc.SetVisionAreaOverride(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.setVisualPerceptibilityGroup then
		ent:setVisualPerceptibilityGroup(context.areaName)
	end
end

function CTREventFuc.SendMessageToTrigger(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)

	AIBaseMethodUtils.Base_SendMessageToTrigger(pg.getEntityByActorId(context._entActorId), entityActorId, context.msgId)
end

function CTREventFuc.SendMessageToTriggerSpecial(context)
	local mainActorId = AIUtils.getActorIdFromContext(context.mainActorId, context)
	local anotherActorId = AIUtils.getActorIdFromContext(context.anotherActorId, context)

	AIBaseMethodUtils.Base_SendMessageToTriggerSpecial(pg.getEntityByActorId(context._entActorId), mainActorId, anotherActorId)
end

function CTREventFuc.ShowQuestionMark(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)

	AIBaseMethodUtils.Base_ShowQuestionMark(pg.getEntityByActorId(entityActorId), context.markType)
end

function CTREventFuc.HideQuestionMark(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)

	AIBaseMethodUtils.Base_HideQuestionMark(pg.getEntityByActorId(entityActorId))
end

function CTREventFuc.SetAFKScreen(context)
	if Utils.checkClient() then
		local enable = context.enable
		local ent = pg.getEntityByActorId(context._entActorId)

		if not ent then
			return
		end

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

function CTREventFuc.LookAtEntity(context)
	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(context._entActorId)

		if ent then
			ent:lookAtRole(pg.getEntityByActorId(context.targetActorId), context.force)
		end
	end
end

function CTREventFuc.CancelLookAtEntity(context)
	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(context._entActorId)

		if ent then
			ent:cancelLookAtRole()
		end
	end
end

function CTREventFuc.ClearNotTargetLetGoCD(context)
	if Utils.checkClient() then
		pg.me:clearNotTargetLetGoCD()
	end
end

function CTREventFuc.TryHomeLeisureMount(context)
	local ent = pg.getEntityByActorId(context._entActorId)

	if ent then
		HomeLandUtils.tryMountHomeLeisureRide(ent, context.vehicleActorId, context.seatIndex, context.revision)
	end
end

function CTREventFuc.FinishHomeLandLeisure(context)
	local ent = pg.getEntityByActorId(context._entActorId)

	if ent then
		HomeLandUtils.homeLeisureFinished(ent, context.revision)
	end
end

function CTREventFuc.FinishHomeLandOperation(context)
	local ent = pg.getEntityByActorId(context._entActorId)

	if ent then
		if context.needResetHomeWork then
			HomeLandUtils.deAllocateHomePetWork(ent)
		end

		HomeLandUtils.homeOperationFinished(ent)
	end
end

function CTREventFuc.DoSysEvent(context)
	if Utils.checkClient() then
		local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
		local ent = pg.getEntityByActorId(entityActorId)

		if ent then
			pg.me:doEvent(context.eventId, {
				globalId = ent:getGlobalId()
			})
		end
	end
end

function CTREventFuc.SetAIBlackboardValue(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.targetActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent and ent.agent then
		ent.agent:setBlackBoardProperty(context.blackboardName, context.value)
	end
end

function CTREventFuc.SetEntityCacheValue(context)
	local entityActorId = AIUtils.getActorIdFromContext(context.entityActorId, context)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent then
		EntityCacheValueUtils.setCacheValue(ent, context.keyName, context.value)
	end
end

function CTREventFuc.CreateEntityGroupBehaviour(context)
	if Utils.checkClient() then
		local ent = pg.getEntityByActorId(context._entActorId)

		if ent and ent.space and ent.space.aiMgr and ent.isInGroupBehaviour and not ent:isInGroupBehaviour(true) then
			local groupBehav = ent.space.aiMgr:createBehaviour(context.behavName, ent)

			groupBehav:start()
			ent:joinGroupBehaviour(groupBehav)
		end
	end
end

function CTREventFuc.ReqEnterRecruit(context)
	if Utils.checkClient() then
		local targetEntity = pg.getEntityByActorId(context.targetActorId)

		if targetEntity and targetEntity.doCallFriend then
			targetEntity:doCallFriend(context._entActorId)
		end
	end
end

function CTREventFuc.DoTrigger(targetActorId, triggerName, context)
	AIControllerUtils.sendAIEvent(pg.getEntityByActorId(targetActorId), triggerName, context)
end

function CTREventFuc.PlayPreset(context)
	if Utils.checkClient() then
		AIBaseMethodUtils.Base_PlayPreset(pg.getEntityByActorId(context._entActorId), context.actorId, context.presetName, context.duration, context.disableWhenFinished, context.loopCount)
	end
end

function CTREventFuc.StopPreset(context)
	if Utils.checkClient() then
		AIBaseMethodUtils.Base_StopPreset(pg.getEntityByActorId(context._entActorId), context.actorId, context.presetName)
	end
end

return CTREventFuc
