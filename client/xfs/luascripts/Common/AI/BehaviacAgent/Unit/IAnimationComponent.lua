-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IAnimationComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local EBTStatus = require("Common.AI.Behaviac.Enums").EBTStatus
local AiConst = require("Common.Const.AiConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PlayableConst = require("Common.Const.PlayableConst")
local CalcUtils = require("Common.Utils.CalcUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local VectorPool = require("Common.Container.VectorPool")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local math_deg = math.deg
local math_epsilon = math.epsilon
local math_min = math.min
local math_random = math.random
local string_isNilOrEmpty = string.isNilOrEmpty
local string_notNilOrEmpty = string.notNilOrEmpty
local ipairs = ipairs
local IAnimationComponent = Class.Component("IAnimationComponent")

function IAnimationComponent:showEmojiBubble(emojiName, timeout, isLoop, matchMultiple)
	if not string_isNilOrEmpty(emojiName) then
		self:hideEmojiBubble()

		if isLoop then
			AIBaseMethodUtils.Base_ShowEmojiBubble(self.ent, emojiName, -1)
		else
			timeout = timeout or AiConst.HIDE_EMOJI_BUBBLE_TIMEOUT

			AIBaseMethodUtils.Base_ShowEmojiBubble(self.ent, emojiName, timeout, matchMultiple)
		end
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:hideEmojiBubble()
	AIBaseMethodUtils.Base_HideEmojiBubble(self.ent)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:showBubbleMsgById(messageId)
	AIBaseMethodUtils.Base_ShowBubbleMsgById(self.ent, messageId)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:hideBubbleMsgById(messageId)
	AIBaseMethodUtils.Base_HideBubbleMsgById(self.ent, messageId)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:showQuestionMark(markType, timeout)
	AIBaseMethodUtils.Base_ShowQuestionMark(self.ent, markType, timeout)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:hideQuestionMark()
	AIBaseMethodUtils.Base_HideQuestionMark(self.ent)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:doIdle()
	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playAction__resetState(resetStateType)
	if self.x_playAction_animStateName then
		AIBaseMethodUtils.Base_StopAnimation(self.ent, self.x_playAction_animStateName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

		self.x_playAction_animStateName = nil
	end

	self:_removeCustomTimeout("playAction")
	self:_removeCustomTimeout("playAction_loop")
end

function IAnimationComponent:playAction(animStateName, timeOut, timelineTag, isLoop, playOnce, defaultTimeout, rootMotionType)
	local actionState = EBTStatus.BT_SUCCESS

	if self:_checkCustomTimeoutExist("playAction") == false and self.x_playAction_animStateName == nil then
		self.x_playAction_animStateName = animStateName

		local playSuccess

		playSuccess = AIBaseMethodUtils.Base_PlayAnimation(self.ent, animStateName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, nil, timelineTag, isLoop, rootMotionType)

		if not playSuccess then
			self:_settingCustomTimeout("playAction", defaultTimeout or AiConst.DefaultAnimationTimeout)
		else
			local clipTime = AnimationUtils.getPlayableClipLength(self.ent, animStateName)

			if playOnce then
				timeOut = clipTime

				self:_settingCustomTimeout("playAction", timeOut)
			elseif not isLoop then
				if timeOut > math_epsilon then
					timeOut = math_min(timeOut, clipTime)
				else
					timeOut = clipTime
				end

				self:_settingCustomTimeout("playAction", timeOut)
			elseif timeOut > math_epsilon then
				self:_settingCustomTimeout("playAction", timeOut)
			end
		end
	end

	if not isLoop then
		if self:_checkAndRemoveCustomTimeout("playAction") then
			actionState = EBTStatus.BT_SUCCESS
		else
			actionState = EBTStatus.BT_RUNNING
		end
	elseif timeOut > math_epsilon then
		if self:_checkAndRemoveCustomTimeout("playAction") then
			actionState = EBTStatus.BT_SUCCESS
		else
			actionState = EBTStatus.BT_RUNNING
		end
	else
		if Utils.isHomePet(self.ent) and self:_checkAndSetCustomTimeout("playAction_loop", 5) then
			AIBaseMethodUtils.Base_PlayAnimation(self.ent, animStateName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, false, timelineTag, isLoop, rootMotionType)
		end

		actionState = EBTStatus.BT_RUNNING
	end

	return actionState
end

function IAnimationComponent:hasAnimState(animStateName)
	return AnimationUtils.hasPlayableOverrideConfig(self.ent, animStateName)
end

function IAnimationComponent:playRawAnimation(animStateName)
	if not string_isNilOrEmpty(animStateName) then
		AIBaseMethodUtils.Base_PlayAnimation(self.ent, animStateName)
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:stopRawAnimation(animStateName)
	if not string_isNilOrEmpty(animStateName) then
		AIBaseMethodUtils.Base_StopAnimation(self.ent, animStateName)
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playPhaseAction__resetState(resetStateType)
	self:playSleAnimationFixTime__resetState(resetStateType)
	self:playSleAnimationOnce__resetState(resetStateType)
end

function IAnimationComponent:playPhaseAction(animStart, animLoop, animEnd, timeout, timelineTag, playOnce, isLoop)
	if isLoop then
		return self:playSleAnimationFixTime(animStart, animLoop, animEnd, 999999, timelineTag)
	elseif playOnce then
		return self:playSleAnimationOnce(animStart, animLoop, animEnd, timelineTag)
	else
		return self:playSleAnimationFixTime(animStart, animLoop, animEnd, timeout, timelineTag)
	end
end

function IAnimationComponent:playSleAnimationOnce__resetState(resetStateType)
	self:_removeCustomTimeout("playSleAnimationOnce")
	AIBaseMethodUtils.Base_StopSleAnimation(self.ent)
end

function IAnimationComponent:playSleAnimationOnce(animStateNameStart, animStateNameLoop, animStateNameEnd, timelineTag)
	if not self:_checkCustomTimeoutExist("playSleAnimationOnce") then
		local timeout = AnimationUtils.getPlayableClipLength(self.ent, animStateNameStart) + AnimationUtils.getPlayableClipLength(self.ent, animStateNameLoop) + AnimationUtils.getPlayableClipLength(self.ent, animStateNameEnd)

		self:_settingCustomTimeout("playSleAnimationOnce", timeout)
		AIBaseMethodUtils.Base_PlaySleAnimation(self.ent, AnimationUtils.getID(animStateNameStart), AnimationUtils.getID(animStateNameLoop), AnimationUtils.getID(animStateNameEnd), true, -1, timelineTag)
	end

	if not self:_checkCustomTimeout("playSleAnimationOnce") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:playSleAnimationFixTime__resetState(resetStateType)
	self:_removeCustomTimeout("playSleAnimationFixTime")
	AIBaseMethodUtils.Base_StopSleAnimation(self.ent)
end

function IAnimationComponent:playSleAnimationFixTime(animStateNameStart, animStateNameLoop, animStateNameEnd, duration, timelineTag)
	if not self:_checkCustomTimeoutExist("playSleAnimationFixTime") then
		self:_settingCustomTimeout("playSleAnimationFixTime", duration)
		AIBaseMethodUtils.Base_PlaySleAnimation(self.ent, AnimationUtils.getID(animStateNameStart), AnimationUtils.getID(animStateNameLoop), AnimationUtils.getID(animStateNameEnd), false, duration, timelineTag)
	end

	if not self:_checkCustomTimeout("playSleAnimationFixTime") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:playSleAnimationMultiTime__resetState(resetStateType)
	self:_removeCustomTimeout("playSleAnimationMultiTime")
	AIBaseMethodUtils.Base_StopSleAnimation(self.ent)
end

function IAnimationComponent:playSleAnimationMultiTime(animStateNameStart, animStateNameLoop, animStateNameEnd, loopCount, timelineTag)
	if not self:_checkCustomTimeoutExist("playSleAnimationMultiTime") then
		local timeout = AnimationUtils.getPlayableClipLength(self.ent, animStateNameStart) + AnimationUtils.getPlayableClipLength(self.ent, animStateNameLoop) * loopCount + AnimationUtils.getPlayableClipLength(self.ent, animStateNameEnd)

		self:_settingCustomTimeout("playSleAnimationMultiTime", timeout)
		AIBaseMethodUtils.Base_PlaySleAnimation(self.ent, AnimationUtils.getID(animStateNameStart), AnimationUtils.getID(animStateNameLoop), AnimationUtils.getID(animStateNameEnd), false, timeout, timelineTag)
	end

	if not self:_checkCustomTimeout("playSleAnimationMultiTime") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:playAfkAnimation__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter then
		self.x_playAfkAnimation_animList = TablePool.getTable()
	elseif resetStateType == AiConst.ResetStateType.exit and self.x_playAfkAnimation_animList then
		TablePool.returnTable(self.x_playAfkAnimation_animList)

		self.x_playAfkAnimation_animList = nil
	end

	self:_removeCustomTimeout("playAfkAnimation")
	AIBaseMethodUtils.Base_StopAnimationList(self.ent)
end

function IAnimationComponent:playAfkAnimation()
	if not self:_checkCustomTimeoutExist("playAfkAnimation") then
		local afkAnimSeqList = self.ent:getConfigData().afkAnimSeqList

		if afkAnimSeqList and #afkAnimSeqList > 0 then
			local randomIndex = math_random(1, #afkAnimSeqList)
			local animList = afkAnimSeqList[randomIndex]
			local totalTime = 0

			for _, animName in ipairs(animList) do
				totalTime = totalTime + AnimationUtils.getPlayableClipLength(self.ent, animName)
				self.x_playAfkAnimation_animList[#self.x_playAfkAnimation_animList + 1] = AnimationUtils.getID(animName)
			end

			self:_settingCustomTimeout("playAfkAnimation", totalTime)
			AIBaseMethodUtils.Base_PlayAnimationList(self.ent, self.x_playAfkAnimation_animList)
		else
			return EBTStatus.BT_SUCCESS
		end
	end

	if not self:_checkCustomTimeout("playAfkAnimation") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:playEffect(effectName, tgtPosition)
	AIBaseMethodUtils.Base_PlayEffect(self.ent, effectName, tgtPosition)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playEffectOnTarget(effectName, targetActorId)
	if targetActorId == 0 then
		targetActorId = self.ent.actorId
	end

	AIBaseMethodUtils.Base_PlayEffectAtTarget(self.ent, effectName, targetActorId)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:stopEffectOnTarget(effectName, targetActorId)
	if targetActorId == 0 then
		targetActorId = self.ent.actorId
	end

	AIBaseMethodUtils.Base_StopEffectAtTarget(self.ent, effectName, targetActorId)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:showDialogue(dialogueId)
	if dialogueId ~= 0 then
		AIBaseMethodUtils.Base_ShowDialogue(self.ent, dialogueId)
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:lerpProperty(enable, lerpTime)
	AIBaseMethodUtils.Base_LerpProperty(self.ent, enable, lerpTime)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:showEmojiBubbleInPetList(emojiName)
	AIBaseMethodUtils.Base_ShowEmojiBubbleInPetList(self.ent, emojiName)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playJumpAction__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		if self.x_playJumpAction_targetPos then
			self.x_playJumpAction_targetPos = VectorPool.returnVector(self.x_playJumpAction_targetPos)
			self.x_playJumpAction_targetPos = nil
		end

		self.x_playJumpAction_targetYaw = nil
	end

	self:playJumpActionToPos__resetState(resetStateType)
end

function IAnimationComponent:playJumpAction(animStateName, timeout, degree, dist, syncPointEnum)
	if self.x_playJumpAction_targetYaw == nil then
		degree = degree or 0
		dist = dist or 0
		self.x_playJumpAction_targetYaw = self.ent:getYaw() + degree
		self.x_playJumpAction_targetPos = VectorPool.getVector()

		CalcUtils.getPosOnRayByYawDegree(self.ent:getPosition(), self.x_playJumpAction_targetYaw, dist, self.x_playJumpAction_targetPos)
	end

	return self:playJumpActionToPos(animStateName, timeout, self.x_playJumpAction_targetPos.x, self.x_playJumpAction_targetPos.y, self.x_playJumpAction_targetPos.z, syncPointEnum, true)
end

function IAnimationComponent:playJumpActionToPos__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		if self.x_playJumpActionToPos_targetPos then
			VectorPool.returnVector(self.x_playJumpActionToPos_targetPos)

			self.x_playJumpActionToPos_targetPos = nil
		end

		if self.x_playJumpActionToPos_animStateName then
			self.x_playJumpActionToPos_animStateName = nil
		end

		self:_removeCustomTimeout("playJumpActionToPos")

		if resetStateType == AiConst.ResetStateType.exit then
			AIControllerUtils.resetJumpInRunWarping(self.ent)
		end
	end
end

function IAnimationComponent:playJumpActionToPos(animStateName, timeout, targetPosX, targetPosY, targetPosZ, syncPointEnum, needAirDumping)
	if self:_checkCustomTimeoutExist("playJumpActionToPos") == false and self.x_playJumpActionToPos_animStateName == nil then
		self.x_playJumpActionToPos_targetPos = VectorPool.getVector()
		self.x_playJumpActionToPos_targetPos.x = targetPosX
		self.x_playJumpActionToPos_targetPos.y = targetPosY
		self.x_playJumpActionToPos_targetPos.z = targetPosZ

		if Utils.checkClient() then
			AIControllerUtils.setJumpInRunWarping(self.ent, self.x_playJumpActionToPos_targetPos, needAirDumping or false)
		end

		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.JUMPINRUN, PlayableConst[animStateName] or 0)

		self.x_playJumpActionToPos_animStateName = animStateName
		timeout = timeout or -1

		if timeout <= AiConst.EPSILON then
			timeout = AiConst.JUMP_TIME_OUT
		end

		self:_settingCustomTimeout("playJumpActionToPos", timeout)

		return EBTStatus.BT_RUNNING
	end

	local curState = AIControllerUtils.getCurrentAnimationState(self.ent)

	if CharacterStateConst.isChildOfState(curState, CharacterStateConst.LOCOMOTION) or CharacterStateConst.isChildOfState(curState, CharacterStateConst.SWIMMING) or self:_checkAndRemoveCustomTimeout("playJumpActionToPos") then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_RUNNING
end

function IAnimationComponent:playJumpGlideAction__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self:_removeCustomTimeout("playJumpGlideAction")
		AIControllerUtils.clearStateInterruptTime(self.ent, CharacterStateConst.JUMP)
		AIControllerUtils.clearStateMotionWarpingSyncPoint(self.ent, CharacterStateConst.JUMP)
	end
end

function IAnimationComponent:playJumpGlideAction(jumpAnimName, jumpTime, glideStartTime, degree, dist, syncPointEnum, timeout)
	if self:_checkCustomTimeoutExist("playJumpGlideAction") == false then
		timeout = jumpTime + glideStartTime

		self:_settingCustomTimeout("playJumpGlideAction", timeout)

		degree = degree or 0
		dist = dist or 0

		Vector3.enableCreateFromCache()

		local pos = self.ent:getPosition():Clone()
		local forwardDegree = math_deg(self.ent:getRotation():ToYaw())
		local targetDegree = forwardDegree + degree
		local targetRotation = Quaternion.Euler(0, targetDegree, 0)
		local jumpPos = Vector3.New()

		CalcUtils.getPosOnRayByYawDegree(pos, targetDegree, dist, jumpPos)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.JUMP, PlayableConst[jumpAnimName] or 0, true)
		AIControllerUtils.setStateInterruptTime(self.ent, CharacterStateConst.JUMP, jumpTime)
		AIControllerUtils.setStateMotionWarpingSyncPoint(self.ent, CharacterStateConst.JUMP, PlayableConst[jumpAnimName] or 0, jumpPos, targetRotation, syncPointEnum, true, false, true, 0, -1)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.GLIDESTART, 0, false)
		AIControllerUtils.setStateInterruptTime(self.ent, CharacterStateConst.GLIDESTART, glideStartTime)
		Vector3.disableCreateFromCache()
	end

	if not self:_checkCustomTimeout("playJumpGlideAction") then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:switchToState__resetState(resetStateType)
	self:_removeCustomTimeout("switchToState")
	AIBaseMethodUtils.Base_CancelAnimationState(self.ent, self.x_switchToState_targetState)

	self.x_switchToState_targetState = nil
end

function IAnimationComponent:switchToState(targetStateName, timeout, replaceAnimName, withEnd)
	local targetState = CharacterStateConst[targetStateName]

	if targetState then
		if CharacterStateConst.isChildOfState(self.ent.characterState, targetState) and not withEnd then
			return EBTStatus.BT_SUCCESS
		end

		if self.x_switchToState_targetState == nil then
			self.x_switchToState_targetState = targetState

			local replaceAnimNameKey = 0

			if string_notNilOrEmpty(replaceAnimName) then
				replaceAnimNameKey = PlayableConst[replaceAnimName]
			end

			AIBaseMethodUtils.Base_PlayAnimationState(self.ent, targetState, replaceAnimNameKey)

			timeout = timeout or 0

			if timeout < math_epsilon then
				timeout = AiConst.DefaultSwitchStateTimeout
			end

			self:_settingCustomTimeout("switchToState", timeout)

			return EBTStatus.BT_RUNNING
		else
			if self:_checkAndRemoveCustomTimeout("switchToState") then
				return EBTStatus.BT_FAILURE
			end

			if self.x_switchToState_targetState == CharacterStateConst.NONE then
				if withEnd then
					if not CharacterStateConst.isChildOfState(self.ent.characterState, targetState) then
						return EBTStatus.BT_SUCCESS
					end
				else
					return EBTStatus.BT_SUCCESS
				end
			end

			return EBTStatus.BT_RUNNING
		end
	else
		return EBTStatus.BT_FAILURE
	end
end

function IAnimationComponent:switchToStateNow(targetStateName, replaceAnimName)
	AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst[targetStateName], string_notNilOrEmpty(replaceAnimName) and PlayableConst[replaceAnimName] or 0)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:switchToPerformStateOnce__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self:_removeCustomTimeout("switchToPerformStateOnce")
		AIBaseMethodUtils.Base_CancelAnimationState(self.ent, CharacterStateConst.PERFORM)

		if resetStateType == AiConst.ResetStateType.exit then
			AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.LOCOMOTION)
		end
	end
end

function IAnimationComponent:switchToPerformStateOnce(animStart, animLoop, animEnd)
	if not self:_checkCustomTimeoutExist("switchToPerformStateOnce") then
		local loopAnimTime = AnimationUtils.getPlayableClipLength(self.ent, animLoop)
		local timeout = AnimationUtils.getPlayableClipLength(self.ent, animStart) + loopAnimTime + AnimationUtils.getPlayableClipLength(self.ent, animEnd)

		self:_settingCustomTimeout("switchToPerformStateOnce", timeout)
		AIControllerUtils.setPerformParams(self.ent, AnimationUtils.getID(animStart), AnimationUtils.getID(animLoop), AnimationUtils.getID(animEnd), loopAnimTime)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.PERFORM)
	end

	if not self:_checkCustomTimeout("switchToPerformStateOnce") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:switchToPerformStateMultiTime__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self:_removeCustomTimeout("switchToPerformStateMultiTime")
		AIBaseMethodUtils.Base_CancelAnimationState(self.ent, CharacterStateConst.PERFORM)

		if resetStateType == AiConst.ResetStateType.exit then
			AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.LOCOMOTION)
		end
	end
end

function IAnimationComponent:switchToPerformStateMultiTime(animStart, animLoop, animEnd, loopCount)
	if not self:_checkCustomTimeoutExist("switchToPerformStateMultiTime") then
		local loopAnimTime = AnimationUtils.getPlayableClipLength(self.ent, animLoop) * loopCount
		local timeout = AnimationUtils.getPlayableClipLength(self.ent, animStart) + loopAnimTime + AnimationUtils.getPlayableClipLength(self.ent, animEnd)

		self:_settingCustomTimeout("switchToPerformStateMultiTime", timeout)
		AIControllerUtils.setPerformParams(self.ent, AnimationUtils.getID(animStart), AnimationUtils.getID(animLoop), AnimationUtils.getID(animEnd), loopAnimTime)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.PERFORM)
	end

	if not self:_checkCustomTimeout("switchToPerformStateMultiTime") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:switchToPerformStateFixTime__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self:_removeCustomTimeout("switchToPerformStateFixTime")
		AIBaseMethodUtils.Base_CancelAnimationState(self.ent, CharacterStateConst.PERFORM)

		if resetStateType == AiConst.ResetStateType.exit then
			AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.LOCOMOTION)
		end
	end
end

function IAnimationComponent:switchToPerformStateFixTime(animStart, animLoop, animEnd, duration)
	if not self:_checkCustomTimeoutExist("switchToPerformStateFixTime") then
		local startAnimTime = AnimationUtils.getPlayableClipLength(self.ent, animStart)
		local endAnimTime = AnimationUtils.getPlayableClipLength(self.ent, animEnd)
		local loopAnimTime = duration - startAnimTime - endAnimTime
		local timeout = duration

		self:_settingCustomTimeout("switchToPerformStateFixTime", timeout)
		AIControllerUtils.setPerformParams(self.ent, AnimationUtils.getID(animStart), AnimationUtils.getID(animLoop), AnimationUtils.getID(animEnd), loopAnimTime)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.PERFORM)
	end

	if not self:_checkCustomTimeout("switchToPerformStateFixTime") then
		return EBTStatus.BT_RUNNING
	else
		return EBTStatus.BT_SUCCESS
	end
end

function IAnimationComponent:checkCharacterState(stateName, targetActorId)
	local targetEnt = targetActorId and pg.getEntityByActorId(targetActorId) or self.ent
	local targetState = CharacterStateConst[stateName]
	local currentState = AIControllerUtils.getCurrentAnimationState(targetEnt)

	if currentState and CharacterStateConst.isChildOfState(currentState, targetState) then
		return true
	end

	return false
end

function IAnimationComponent:setFullBodyIdle(defaultAnimation)
	AIBaseMethodUtils.Base_SetLayerDefaultAnimation(self.ent, defaultAnimation)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playNPCWaitAnimation__resetState(resetStateType)
	self.x_playNPCWaitAnimation_animationKey = nil

	self:playAction__resetState(resetStateType)
end

function IAnimationComponent:playNPCWaitAnimation()
	if self.x_playNPCWaitAnimation_animationKey == nil then
		local configData = self.ent:getConfigData()

		if configData and configData.NPCFollowWaitAnimStateList then
			local count = #configData.NPCFollowWaitAnimStateList
			local index = math_random(1, count)
			local animName = configData.NPCFollowWaitAnimStateList[index]

			if animName then
				self.x_playNPCWaitAnimation_animationKey = animName

				return self:playAction(animName, 0, "", false, true)
			end
		end

		return EBTStatus.BT_SUCCESS
	end

	return self:playAction(self.x_playNPCWaitAnimation_animationKey, 0, "", false, true)
end

function IAnimationComponent:playNPCFollowDialog()
	local configData = self.ent:getConfigData()

	if configData and configData.NPCFollowDialogList then
		local count = #configData.NPCFollowDialogList
		local index = math_random(1, count)
		local dialogueId = configData.NPCFollowDialogList[index]

		if dialogueId then
			return self:showDialogue(dialogueId)
		end
	end

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playFaceAnimation(faceName, fadeTime)
	if PlayableConst.FacialConst[faceName] and AIBaseMethodUtils.Base_PlayFacialAnimation(self.ent, PlayableConst.FacialConst[faceName], fadeTime) then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_FAILURE
end

function IAnimationComponent:stopFaceAnimation(fadeTime)
	AIBaseMethodUtils.Base_StopFacialAnimation(self.ent, fadeTime)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:playLipAnimation(fadeTime)
	AIBaseMethodUtils.Base_PlayLipAnimation(fadeTime)

	return EBTStatus.BT_SUCCESS
end

function IAnimationComponent:stopLipAnimation(fadeTime)
	AIBaseMethodUtils.Base_StopLipAnimation(fadeTime)

	return EBTStatus.BT_SUCCESS
end

return IAnimationComponent
