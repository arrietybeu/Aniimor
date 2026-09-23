-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AnimationUtils.lua

local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Utils = require("Common.Utils.Utils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AiConst = require("Common.Const.AiConst")
local logger = LoggerManager.getLogger("AnimationUtils")
local CommonRepo = require("Core.Common.CommonRepo")
local PlayableConst = require("Common.Const.PlayableConst")
local AnimationClipData = require("Common.Data.AnimationData.AnimationClipData")
local AnimControllerData = require("Common.Data.AnimationData.AnimControllerData")
local Bitset = require("Common.Bitset")
local Const = require("Common.Const.Const")
local ipairs = ipairs
local AnimationUtils = {}

local function tryPlayAnimation(entity, animation, restart, timelineTag, isLoop, forceLayer, animationRootMotionType)
	local playState = entity:playAnimation(animation, restart, timelineTag, isLoop, forceLayer)

	if playState then
		if animationRootMotionType then
			playState:OverrideMotionType(animationRootMotionType)
		end

		return playState
	end

	return false
end

function AnimationUtils.playAnimation(entity, animation, forceLayer, restart, timelineTag, isLoop, animationRootMotionType)
	if string.isNilOrEmpty(animation) then
		return false
	end

	if Utils.checkClient() then
		if jit then
			local status, err = xpcall(tryPlayAnimation, debug.traceback, entity, animation, restart, timelineTag, isLoop, forceLayer, animationRootMotionType)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error(entity.templateId .. "playAnimation:" .. animation .. "traceback occurred")
				end

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("playAnimation traceback occurred")
				end

				CommonRepo.exceptionFunc(ex)

				return false
			end

			return err
		else
			local status, err = xpcall(function()
				local playState = entity:playAnimation(animation, restart, timelineTag, isLoop, forceLayer, animationRootMotionType)

				if playState then
					if animationRootMotionType then
						playState:OverrideMotionType(animationRootMotionType)
					end

					return playState
				end

				return false
			end, debug.traceback)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error(entity.templateId .. "playAnimation:" .. animation .. "traceback occurred")
				end

				CommonRepo.exceptionFunc(ex)

				return false
			end

			return err
		end
	else
		if entity.serverPlayAnimation then
			return entity:serverPlayAnimation(animation, isLoop, forceLayer)
		end

		return true
	end

	return false
end

function AnimationUtils.getID(key)
	local t = type(key)

	if t == "number" then
		return key
	end

	if t == "string" then
		key = PlayableConst[key]
	end

	if key then
		return key
	end

	return 0
end

function AnimationUtils.playLipAnimation(entity, key, fadeTime)
	if Utils.checkClient() and entity.playLipAnim then
		return entity:playLipMotionAnim(key, fadeTime)
	end
end

function AnimationUtils.stopLipAnimation(entity, fadeTime)
	if Utils.checkClient() and entity.stopLipAnim then
		return entity:stopLipMotionAnim(fadeTime)
	end
end

function AnimationUtils.playFacialAnimation(entity, facialConst, fadeTime)
	if Utils.checkClient() and entity.playFacialAnim then
		return entity:playFacialAnim(facialConst, fadeTime)
	end

	return true
end

function AnimationUtils.stopFacialAnimation(entity, fadeTime)
	if Utils.checkClient() and entity.stopFacialAnim then
		entity:stopFacialAnim(fadeTime)
	end
end

function AnimationUtils.stopAnimation(entity, key, layer)
	if Utils.checkClient() then
		entity:stopAnimation(key, nil, layer)
	elseif entity.serverStopAnimation then
		entity:serverStopAnimation(key, layer)
	end
end

function AnimationUtils.playAnimationState(entity, state, replaceAnimNameKey, clearWaitState, motionWarpPos)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if not eModel then
			return false
		end

		if Utils.isAIEntity(entity) then
			if clearWaitState == nil then
				clearWaitState = true
			end

			return eModel:ChangeAICharacterState(CommonConst.COMPONENT_AI_CONTROLLER, state, replaceAnimNameKey or 0, clearWaitState)
		elseif entity.hasEModelComponent and entity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
			return eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, state)
		end
	else
		if entity.serverSetTargetCharacterState then
			entity:serverSetTargetCharacterState(state, replaceAnimNameKey, motionWarpPos)
		end

		return true
	end
end

function AnimationUtils.forceChangeState(entity, state, replaceAnimNameKey, motionWarpPos)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if not eModel then
			return false
		end

		if Utils.isAIEntity(entity) then
			return eModel:ForceAICharacterState(CommonConst.COMPONENT_AI_CONTROLLER, state)
		elseif entity.hasEModelComponent and entity:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
			return eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, state)
		end
	else
		if entity.serverSetTargetCharacterState then
			entity:serverSetTargetCharacterState(state, replaceAnimNameKey, motionWarpPos)
		end

		return true
	end
end

function AnimationUtils.cancelAnimationState(entity, state)
	if Utils.checkClient() then
		if not entity.eModel then
			return false
		end

		if Utils.isAIEntity(entity) and state then
			return entity.eModel:CancelAICharacterState(CommonConst.COMPONENT_AI_CONTROLLER, state)
		end
	end

	return false
end

function AnimationUtils.setAnimationSequence(entity, state, duration, callback)
	if Utils.checkClient() then
		return entity:setAnimationSequence(state, duration, callback)
	end
end

function AnimationUtils.checkCurrentAllStateHasTag(entity, tag)
	if Utils.checkClient() and entity.eModel then
		return entity.eModel:CheckCurrentAllStateHasTag(Const.COMPONENT_IDX_PLAYABLE, tag) or false
	end

	return false
end

function AnimationUtils.hasPlayableOverrideConfig(entity, key)
	local playableHash = AnimationUtils.getID(key)

	if not playableHash then
		return false
	end

	local animControllerName = entity:getConfigData().animController
	local stateInfo = AnimationUtils.getAnimationStateInfo(animControllerName, playableHash)

	return stateInfo ~= nil
end

function AnimationUtils.getPlayableClipLength(entity, key, defaultLength)
	local playableHash = AnimationUtils.getID(key)

	if not ToBool(playableHash) then
		return defaultLength or AiConst.DefaultAnimationClipLength
	end

	local animControllerName = entity:getConfigData().animController
	local stateInfo = AnimationUtils.getAnimationStateInfo(animControllerName, playableHash)

	if stateInfo and stateInfo.clipHashList then
		local maxClipTime = 0

		for _, value in ipairs(stateInfo.clipHashList) do
			local animationValue = AnimationClipData[value]

			maxClipTime = math.max(animationValue and animationValue.clipLength or 0, maxClipTime)
		end

		return maxClipTime
	end

	return defaultLength or AiConst.DefaultAnimationClipLength
end

function AnimationUtils.setLayerDefaultAnimation(entity, layer, animationKey)
	if Utils.checkClient() and entity.eModel then
		if string.isNilOrEmpty(animationKey) then
			entity.eModel:SetLayerDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, layer, 0)

			return true
		else
			local animationId = AnimationUtils.getID(animationKey)

			if animationId then
				entity.eModel:SetLayerDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, layer, animationId, true)

				return true
			end
		end
	end

	return false
end

function AnimationUtils.playTurnAnimation(entity, targetRotation)
	if Utils.checkClient() then
		local EModelUtils = require("Entities.Utils.EModelUtils")
		local eModel = entity.eModel

		if eModel and eModel:CheckComponentIsEnable(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
			EModelUtils.setMotionTargetRotation(entity, targetRotation)
			eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.STORYTURN)
		elseif eModel and entity.hasEModelComponent and entity:hasEModelComponent(CommonConst.COMPONENT_AI_CONTROLLER) then
			eModel:PlayTurnAnimation(Const.COMPONENT_IDX_PLAYABLE, targetRotation)
		else
			EModelUtils.setAgentRotation(entity, targetRotation)
		end

		return true
	end

	return false
end

function AnimationUtils.getAnimationTurnTime(entity, targetRotation)
	if not entity or not targetRotation then
		return 0
	end

	local eModel = entity.eModel

	if not eModel or not eModel:HasPlayableMotion(Const.COMPONENT_IDX_PLAYABLE, PlayableConst.TurnBlend) then
		return 0
	end

	local currentAngle

	if entity.eModel then
		currentAngle = entity:getPositionAgentRotation():GetEulerAnglesY()
	else
		currentAngle = entity:getRotation():GetEulerAnglesY()
	end

	local targetAngle = targetRotation:GetEulerAnglesY()
	local deltaAngle = (targetAngle - currentAngle) % 360

	if deltaAngle < 0 then
		deltaAngle = deltaAngle + 360
	end

	if deltaAngle > 180 then
		deltaAngle = deltaAngle - 360
	end

	if deltaAngle < 0 then
		deltaAngle = -deltaAngle
	end

	if deltaAngle <= 1 then
		return 0
	end

	local speedRatio = deltaAngle / 180

	if speedRatio > 0.01 then
		speedRatio = math.clamp(1 / speedRatio, 1, 5)
	else
		speedRatio = 5
	end

	local turnDefaultTime = 1.5

	return turnDefaultTime / speedRatio
end

function AnimationUtils.playSleAnimation(entity, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, forceLayer, callback, k1DuraMs, k2DuraMs, k3DuraMs)
	if Utils.checkClient() then
		local playSleAnimationFunc = entity.playSleAnimation

		if playSleAnimationFunc and playSleAnimationFunc(entity, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, forceLayer, k1DuraMs, k2DuraMs, k3DuraMs) then
			if callback then
				entity.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, callback)
			end

			return true
		end
	end
end

function AnimationUtils.stopSleAnimation(entity)
	if Utils.checkClient() and entity.eModel then
		entity.eModel:StopSleAnimation(Const.COMPONENT_IDX_PLAYABLE)
	end
end

function AnimationUtils.sleAnimationEndHold(entity)
	if Utils.checkClient() and entity.eModel then
		entity.eModel:SleEndHold(Const.COMPONENT_IDX_PLAYABLE)
	end
end

function AnimationUtils.playAnimationList(entity, animList, callback, forceLayer)
	if Utils.checkClient() and entity.eModel then
		entity.eModel:PlayList(Const.COMPONENT_IDX_PLAYABLE, callback, animList, forceLayer)
	end
end

function AnimationUtils.stopAnimationList(entity)
	if Utils.checkClient() and entity.eModel then
		entity.eModel:StopList(Const.COMPONENT_IDX_PLAYABLE)
	end
end

function AnimationUtils.stopLayerAnimation(entity, layer)
	if Utils.checkClient() and entity and entity.stopLayerAnimation then
		entity:stopLayerAnimation(layer)
	end
end

function AnimationUtils.exitMimicry(entity)
	if CharacterStateConst.isChildOfState(entity.characterState, CharacterStateConst.MIMICRY) then
		AnimationUtils.playAnimationState(entity, CharacterStateConst.LOCOMOTION)
	elseif CharacterStateConst.isChildOfState(entity.characterState, CharacterStateConst.SWIMMIMICRY) then
		AnimationUtils.playAnimationState(entity, CharacterStateConst.SWIMMING)
	end
end

function AnimationUtils.getAnimationStateInfo(controllerName, stateHash)
	if controllerName then
		local controllerData = AnimControllerData[controllerName]

		while controllerData do
			local stateInfo = controllerData.State2ClipHashDictionary[stateHash]

			if stateInfo then
				return stateInfo
			end

			if controllerData.BaseOMConfigName then
				controllerData = AnimControllerData[controllerData.BaseOMConfigName]
			else
				break
			end
		end
	end
end

function AnimationUtils.packAnimationSyncMode2Transition(fadeTime, transitionType, offsetTime)
	local mode2 = PlayableConst.PackType.Transition

	mode2 = Bitset.bor(mode2, Bitset.lshift(AnimationUtils.PackFloat(fadeTime, 0, 1, Bitset.lshift(1, 10)), 1))
	mode2 = Bitset.bor(mode2, Bitset.lshift(transitionType, 11))
	mode2 = Bitset.bor(mode2, Bitset.lshift(AnimationUtils.PackFloat(offsetTime, 0, 1, Bitset.lshift(1, 10)), 13))

	return mode2
end

function AnimationUtils.packAnimationSyncMode2State(normalizeTime, bsType, param1, param2)
	local mode2 = PlayableConst.PackType.State

	mode2 = Bitset.bor(mode2, Bitset.lshift(AnimationUtils.PackFloat(normalizeTime, 0, 1, Bitset.lshift(1, 10)), 1))
	mode2 = Bitset.bor(mode2, Bitset.lshift(bsType, 11))
	mode2 = Bitset.bor(mode2, Bitset.lshift(AnimationUtils.PackFloat(param1, -1, 1, Bitset.lshift(1, 8)), 15))
	mode2 = Bitset.bor(mode2, Bitset.lshift(AnimationUtils.PackFloat(param2, -1, 1, Bitset.lshift(1, 8)), 23))

	return mode2
end

function AnimationUtils.PackFloat(value, min, max, map)
	return math.floor((value - min) / (max - min) * (map - 1) + 0.5)
end

function AnimationUtils.playRootMotion(entity, rootMotionAnimationHash, targetPosition, targetRotation, rotationInstant, syncPointEnum, endCallback, warpXZ, warpY, warpRot, motionWarpStartTime, motionWarpEndTime, layer, speed)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			syncPointEnum = syncPointEnum or AiConst.SYNC_POINT_CUSTOM_INDEX

			if warpXZ == nil then
				warpXZ = true
			end

			if warpY == nil then
				warpY = false
			end

			if warpRot == nil then
				warpRot = true
			end

			return eModel:ChangeToRootMotion(CommonConst.COMPONENT_AI_CONTROLLER, rootMotionAnimationHash, targetPosition, targetRotation, rotationInstant, syncPointEnum, endCallback, warpXZ, warpY, warpRot) or 0
		end

		return 0
	else
		if entity.serverPlayAnimation then
			entity:serverPlayAnimation(rootMotionAnimationHash, false, layer or PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, endCallback, nil, speed, targetPosition, targetRotation, motionWarpStartTime, motionWarpEndTime)

			return entity:serverGetAnimationClipLength(rootMotionAnimationHash, layer or PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
		end

		return 0
	end
end

function AnimationUtils.stopAnimationByTagMask(entity, tagMask)
	if Utils.checkClient() then
		-- block empty
	else
		entity:serverStopAnimationByTagMask(tagMask)
	end
end

function AnimationUtils.isAnimationPlaying(entity, animStateName)
	if not entity then
		return false
	end

	if Utils.checkClient() then
		return entity:isAnimationPlaying(animStateName)
	end

	return entity:ServerIsAnimationPlaying(animStateName)
end

function AnimationUtils.isInAnimTag(entity, animTag)
	if not entity then
		return false
	end

	if Utils.checkClient() then
		local tagMask = require("Const.ClientConst").AnimationTagMask[animTag]

		if tagMask then
			return entity:isCurrentPlayableHasTag(tagMask)
		end
	else
		return false
	end
end

return AnimationUtils
