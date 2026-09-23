-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAnimationComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local PlayableTransitionType = CS.FunPlus.WorldX.Animations.PlayableTransitionType
local PlayableReplayMode = CS.FunPlus.WorldX.Animations.PlayableReplayMode
local PlayableComponent = CS.FunPlus.WorldX.Entities.Components.PlayableComponent
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask
local AnimationUtils = require("Common.Utils.AnimationUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local PlayableAnimGroupKey = CS.FunPlus.WorldX.Animations.PlayableAnimGroupKey
local UIConst = require("Const.UIConst")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local vehicle_seat_attach_data = require("Data.vehicle_seat_attach_data")
local ToBool = ToBool
local Vector3 = Vector3
local IKTYPE_BLINK = 6
local ClientAnimationComponent = class.Component("ClientAnimationComponent")

function ClientAnimationComponent:ctor()
	self.animFreezeScaleMap = {}
	self.animFreezeScale = 1
	self.animGroupDatas = {}
	self.animTagStartTime = 0
	self.sprintEffId = nil
	self.removeSprintEffTimer = nil
	self.rootMotionScales = {}
end

function ClientAnimationComponent:start()
	return
end

function ClientAnimationComponent:EVENT_AddEComponent()
	if Utils.isCreation(self) then
		return
	end

	self:addEModelComponent(Const.COMPONENT_IDX_PLAYABLE)

	if not self.isClientEnt then
		self:addEModelComponent(Const.COMPONENT_ANIMATION_SYNC)
	end
end

function ClientAnimationComponent:onAnimBaseLayerStateChanged(tagMasks, animKey)
	self.animTagMasks = tagMasks
	self.animTagStartTime = Time.realSecondCache
	self.animKey = animKey

	if Utils.isPet(self) or Utils.isHomePet(self) then
		self:restoreVehicleBodyMountReport()
	end

	if self == pg.game.camera.targetPlayer then
		pg.game.camera:onPlayerBaseLayerTagChange()
	end

	self:refreshSprintEff()
end

function ClientAnimationComponent:onSkeletonLoaded()
	local fullBodyIdle = self.getConfigData and self:getConfigData().fullbodyIdle

	if self.space then
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)

		if Utils.isPuppet(self) then
			local staticId = self.staticId
			local staticData = sceneEntityData[staticId]

			if staticData and staticData.fullbodyIdle then
				fullBodyIdle = staticData.fullbodyIdle
			end
		end

		if fullBodyIdle then
			AnimationUtils.setLayerDefaultAnimation(self, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY, fullBodyIdle)
		end
	end

	self:refreshRootMotionScale()

	if self.playInitSpPlayable then
		self:playInitSpPlayable()
	end
end

function ClientAnimationComponent:playDefaultAnimation(force)
	if not self.eModel then
		return false
	end

	self.eModel:PlayDefaultAnimation(Const.COMPONENT_IDX_PLAYABLE, force or false)
end

function ClientAnimationComponent:refreshSprintEff()
	local sprintEff = self:getConfigData().sprintEff

	if sprintEff then
		local hasSprintTag = self.eModel:IsRunningTag(Const.COMPONENT_IDX_PLAYABLE, TagMask.Sprint, TagMask.Movement)

		if hasSprintTag then
			if not self.sprintEffId and sprintEff then
				if self.removeSprintEffTimer then
					self:removeTimer(self.removeSprintEffTimer)

					self.removeSprintEffTimer = nil
				end

				self.sprintEffId = self:playEffect(sprintEff)
			end
		elseif not self.removeSprintEffTimer and self.sprintEffId then
			self.removeSprintEffTimer = self:addTimer(0.2, function()
				self:stopEffectById(self.sprintEffId)

				self.sprintEffId = nil
				self.removeSprintEffTimer = nil
			end)
		end
	end
end

function ClientAnimationComponent:onAnimMaskChangeByEvent()
	self:refreshSprintEff()
end

function ClientAnimationComponent:onAnimFullBodyLayerStateChanged(tagMasks, animKey)
	self.fullBodyAnimTagMasks = tagMasks
	self.fullBodyAnimKey = animKey
end

function ClientAnimationComponent:onAnimFullBodyLowPriorityLayerStateChanged(tagMasks, animKey)
	self.fullBodyLowPriorityAnimTagMasks = tagMasks
	self.fullBodyLowPriorityAnimKey = animKey
end

function ClientAnimationComponent:isCurrentPlayableHasTag(tagMask)
	if not self.eModel then
		return false
	end

	return self.eModel:IsRunningTag(Const.COMPONENT_IDX_PLAYABLE, tagMask)
end

function ClientAnimationComponent:getCurrentTagDuration()
	return Time.realSecondCache - self.animTagStartTime
end

function ClientAnimationComponent:playCfgAnimation(cfg, forceLayer)
	local t = type(cfg)

	forceLayer = forceLayer or PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY

	if t ~= "table" then
		return self:playAnimation(cfg, false, nil, nil, forceLayer)
	end

	local length = #cfg
	local k1 = 0
	local k2 = 0
	local k3 = 0

	if length == 2 then
		k1 = AnimationUtils.getID(cfg[1])
	elseif length == 4 then
		k1 = AnimationUtils.getID(cfg[1])
		k2 = AnimationUtils.getID(cfg[2])
		k3 = AnimationUtils.getID(cfg[3])
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("配置通用动画参数长度错误")
		end

		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	local params = cfg[length]
	local pLength = #params
	local bPlayOnce = true

	if pLength > 0 then
		bPlayOnce = params[1]
	end

	local fDuration = pLength > 1 and params[2] or -1
	local sTimelineTag = pLength > 2 and params[3] or nil

	return self.eModel:PlaySleAnimation(Const.COMPONENT_IDX_PLAYABLE, k1, k2, k3, bPlayOnce, fDuration, sTimelineTag, forceLayer)
end

function ClientAnimationComponent:playSleAnimation(key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, forceLayer, k1DuraMs, k2DuraMs, k3DuraMs)
	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	key1 = key1 or 0
	key2 = key2 or 0
	key3 = key3 or 0
	fDuration = fDuration and fDuration or -1

	if bPlayOnce == nil then
		bPlayOnce = fDuration == -1
	end

	forceLayer = forceLayer and forceLayer or -1

	if k1DuraMs or k2DuraMs or k3DuraMs then
		return self.eModel:PlaySleAnimationExtend(Const.COMPONENT_IDX_PLAYABLE, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, forceLayer, 1, k1DuraMs, k2DuraMs, k3DuraMs)
	else
		return self.eModel:PlaySleAnimation(Const.COMPONENT_IDX_PLAYABLE, key1, key2, key3, bPlayOnce, fDuration, sTimelineTag, forceLayer)
	end
end

function ClientAnimationComponent:playAnimation(key, restart, timelineTag, isLoop, forceLayer)
	if not key then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	key = AnimationUtils.getID(key)

	if forceLayer then
		self.eModel:PresetPlayingLayer(Const.COMPONENT_IDX_PLAYABLE, forceLayer)
	end

	if timelineTag then
		self.eModel:PresetTimelineTag(Const.COMPONENT_IDX_PLAYABLE, key, timelineTag)
	end

	local replayMode = PlayableReplayMode.FromStart

	if restart == false then
		replayMode = PlayableReplayMode.Continue
	end

	local state = self.eModel:PlayAnimation(Const.COMPONENT_IDX_PLAYABLE, key, replayMode)

	if isLoop and NotNil(state) then
		state:SetLogicLoop(true)
	end

	return state
end

function ClientAnimationComponent:playRawAnimation(key, fadeTime, offsetTime, speed, timelineTag, forceLayer)
	if not key then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	key = AnimationUtils.getID(key)
	fadeTime = fadeTime or PlayableComponent.DEFAULT_FADE_TIME
	offsetTime = offsetTime or 0

	if forceLayer then
		self.eModel:PresetPlayingLayer(Const.COMPONENT_IDX_PLAYABLE, forceLayer)
	end

	if timelineTag then
		self.eModel:PresetTimelineTag(Const.COMPONENT_IDX_PLAYABLE, key, timelineTag)
	end

	local state = self.eModel:PlayRawAnimation(Const.COMPONENT_IDX_PLAYABLE, key, fadeTime, PlayableTransitionType.FixedTime, offsetTime)

	if speed and NotNil(state) then
		state:SetSpeed(speed)
	end

	return state
end

function ClientAnimationComponent:playAbilityAnimation(key, fadeTime, offsetTime, speed, timelineTag)
	if not key then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	key = AnimationUtils.getID(key)

	if timelineTag then
		self.eModel:PresetTimelineTag(Const.COMPONENT_IDX_PLAYABLE, key, timelineTag)
	end

	local state = self.eModel:PlayAbilityAnimation(Const.COMPONENT_IDX_PLAYABLE, key, fadeTime, offsetTime)

	if speed and NotNil(state) then
		state:SetSpeed(speed)
	end

	return state
end

function ClientAnimationComponent:playTrivialAnimation(key, timelineTag)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)
	self.curTrivialAnim = key

	local state = self:playAnimation(key, nil, timelineTag)

	if self.setStateCacheValue then
		self:setStateCacheValue("TRIVIAL_ACTION_ST", true)

		if state and state.AddEndCallback then
			state:AddEndCallback(function(reason)
				if self.curTrivialAnim == key then
					self.curTrivialAnim = nil
				end

				self:setStateCacheValue("TRIVIAL_ACTION_ST", false)
			end)
		end
	end

	return state
end

function ClientAnimationComponent:playTrivialUpperAnimation(key)
	if not key then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) then
		return
	end

	key = AnimationUtils.getID(key)
	self.curUpperTrivialAnim = key

	local state = self:playAnimation(key)

	if state.Time > state.Length and not state.IsLooping then
		state = self:playAnimation(key, true)
	end

	if self.setStateCacheValue then
		self:setStateCacheValue("TRIVIAL_UPPER_ACTION_ST", true)
	end

	state:AddEndCallback(function(reason)
		if self.curUpperTrivialAnim == key then
			self.curUpperTrivialAnim = nil
		end

		if self.setStateCacheValue then
			self:setStateCacheValue("TRIVIAL_UPPER_ACTION_ST", false)
		end
	end)

	return state
end

function ClientAnimationComponent:setAnimationSequence(state, duration, callback)
	if not self.eModel then
		return
	end

	duration = duration or 0

	local success = self.eModel:SetSequenceStepCallback(Const.COMPONENT_IDX_PLAYABLE, state, duration, callback)

	return success or false
end

function ClientAnimationComponent:playFacialAnim(facialConst, fadeTime)
	if not self.eModel then
		return
	end

	fadeTime = fadeTime or 0.2

	return self.eModel:PlayEmotion(Const.COMPONENT_IDX_PLAYABLE, facialConst, fadeTime)
end

function ClientAnimationComponent:stopFacialAnim(fadeTime)
	if not self.eModel then
		return
	end

	fadeTime = fadeTime or 0.1

	self.eModel:StopEmotion(Const.COMPONENT_IDX_PLAYABLE, fadeTime)
end

function ClientAnimationComponent:playLipMotionAnim(name, fadeTime)
	if not self.eModel then
		return
	end

	fadeTime = fadeTime or 0.2

	self.eModel:PlayLip(Const.COMPONENT_IDX_PLAYABLE, name, fadeTime)
end

function ClientAnimationComponent:stopLipMotionAnim(fadeTime)
	if not self.eModel then
		return
	end

	fadeTime = fadeTime or 0.1

	self.eModel:StopLip(Const.COMPONENT_IDX_PLAYABLE, fadeTime)
end

function ClientAnimationComponent:enableAutoBlink(enable, rangeStart, rangeEnd)
	if not self.eModel then
		return
	end

	self.eModel:EnableIK(Const.COMPONENT_INDEX_IK, IKTYPE_BLINK, enable)
	self.eModel:AutoBlink(Const.COMPONENT_IDX_PLAYABLE, enable)

	if enable then
		rangeStart = rangeStart or 3
		rangeEnd = rangeEnd or 5

		self.eModel:SetupAutoBlink(Const.COMPONENT_IDX_PLAYABLE, rangeStart, rangeEnd)
	end
end

function ClientAnimationComponent:refreshAutoBlink()
	if not self.eModel then
		return
	end

	local abandonBlink = self.getSceneEntityCfg and self:getSceneEntityCfg("abandonBlink") or false

	self.eModel:EnableIK(Const.COMPONENT_INDEX_IK, IKTYPE_BLINK, not abandonBlink)
	self.eModel:AutoBlink(Const.COMPONENT_IDX_PLAYABLE, not abandonBlink)
	self.eModel:SetupAutoBlink(Const.COMPONENT_IDX_PLAYABLE, 3, 5)
end

function ClientAnimationComponent:hasPlayableOverrideConfig(key)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)

	return self.eModel:HasPlayableMotion(Const.COMPONENT_IDX_PLAYABLE, key) or false
end

function ClientAnimationComponent:getPlayableClipConfig(key)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)

	local suc, clipConfig = self.eModel:TryGetPlayableClipConfig(Const.COMPONENT_IDX_PLAYABLE, key)

	return clipConfig
end

function ClientAnimationComponent:getPlayableStateConfigLayer(key)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)

	local succ, layer = self.eModel:TryGetStateConfigLayer(Const.COMPONENT_IDX_PLAYABLE, key)

	return layer
end

function ClientAnimationComponent:getCurrentPlayableState(layer)
	if layer and self.eModel then
		return self.eModel:GetCurrentPlayableState(Const.COMPONENT_IDX_PLAYABLE, layer)
	end
end

function ClientAnimationComponent:isAnimationPlaying(key)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)

	return self.eModel:IsAnimationPlaying(Const.COMPONENT_IDX_PLAYABLE, key) or false
end

function ClientAnimationComponent:isFullBodyDefaultAnimationPlaying()
	if not self.eModel then
		return false
	end

	return self.eModel:IsFullBodyDefaultAnimationPlaying(Const.COMPONENT_IDX_PLAYABLE) or false
end

function ClientAnimationComponent:stopAnimation(key, fadeTime, layer)
	if not key or not self.eModel then
		return
	end

	key = AnimationUtils.getID(key)
	fadeTime = fadeTime or PlayableComponent.DEFAULT_FADE_TIME

	if not layer then
		self.eModel:StopAnimation(Const.COMPONENT_IDX_PLAYABLE, key, fadeTime)
	else
		self.eModel:StopAnimationForceLayer(Const.COMPONENT_IDX_PLAYABLE, layer, key, fadeTime)
	end
end

function ClientAnimationComponent:stopAllAnimation(fadeTime)
	local eModel = self.eModel

	if eModel == nil then
		return
	end

	fadeTime = fadeTime or PlayableComponent.DEFAULT_FADE_TIME

	eModel:StopAllAnimation(Const.COMPONENT_IDX_PLAYABLE, fadeTime)
end

function ClientAnimationComponent:stopLayerAnimation(layer, fadeTime)
	if not layer then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	fadeTime = fadeTime or PlayableComponent.DEFAULT_FADE_TIME

	eModel:StopAnimationByLayer(Const.COMPONENT_IDX_PLAYABLE, layer, fadeTime)
end

function ClientAnimationComponent:stopAnimationByTag(tagMask, fadeTime)
	if not tagMask then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	fadeTime = fadeTime or PlayableComponent.DEFAULT_FADE_TIME

	eModel:StopAnimationByTag(Const.COMPONENT_IDX_PLAYABLE, tagMask, fadeTime)

	if self.setOverrideSteeringTime and tagMask == TagMask.Skill then
		self:setOverrideSteeringTime(-1)
	end
end

function ClientAnimationComponent:stopCfgAnimation()
	local eModel = self.eModel

	if eModel == nil then
		return
	end

	eModel:StopSleAnimation(Const.COMPONENT_IDX_PLAYABLE)
end

function ClientAnimationComponent:setAnimSpeed(speed)
	if not speed then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	eModel.PlayableSpeed = speed
end

function ClientAnimationComponent:setPhotoTimePauseAnimPlaying(playing)
	self.photoTimePauseAnimPlaying = playing

	self:applyAnimSpeed()
end

function ClientAnimationComponent:setRootMotionScale(scale, key)
	if key == nil then
		key = ClientAbilityConst.ROOT_MOTION_SCALE_KEYS.DEFAULT
	end

	if self.rootMotionScales[key] ~= scale then
		self.rootMotionScales[key] = scale
	else
		return
	end

	self:refreshRootMotionScale()
end

function ClientAnimationComponent:refreshRootMotionScale()
	local finalScale = 1

	for _, v in pairs(self.rootMotionScales) do
		finalScale = finalScale * v
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	eModel.RootMotionScale = Vector3(finalScale, finalScale, finalScale)
end

function ClientAnimationComponent:canPlaySpecialAnim()
	if self.isInCombat and self:isInCombat() then
		return false
	end

	if self.inAbility and self:inAbility() then
		return false
	end

	if ToBool(self.specialAttackModeData) then
		return false
	end

	if ToBool(self.isInDialogue) then
		return false
	end

	if ToBool(self.isInDialogueGraph) then
		return false
	end

	if self.actorBuff and self.actorBuff:findOneBuffByTemplateId(AbilityConst.BUFF_10222_SWITCH_SUBMODEL_ID) ~= nil then
		return false
	end

	return not self:isInCombat()
end

function ClientAnimationComponent:EVENT_TimeScaleChanged(timeScale)
	self:applyAnimSpeed()
end

function ClientAnimationComponent:setAnimFreezeScale(key, scale)
	self.animFreezeScaleMap[key] = scale

	local realScale = 1

	for k, v in pairs(self.animFreezeScaleMap) do
		realScale = realScale * v
	end

	self.animFreezeScale = realScale

	self:applyAnimSpeed()
end

function ClientAnimationComponent:setAnimScaleByDialogueGraph(scale)
	self.animDialogueGraphScale = scale ~= nil and scale >= 0 and scale or nil

	self:applyAnimSpeed()
end

function ClientAnimationComponent:applyAnimSpeed()
	local gameTimeScale = self:getGameTimeScale()

	if self.animDialogueGraphScale ~= nil then
		self.animSpeed = (self.timeScale or 1) * gameTimeScale * self.animDialogueGraphScale
	else
		self.animSpeed = (self.timeScale or 1) * gameTimeScale * self.animFreezeScale
	end

	if self:checkIsPhotoTimePause() then
		if self.photoTimePauseAnimPlaying ~= nil then
			self.animSpeed = self.photoTimePauseAnimPlaying and 1 or 0
		elseif self.isMainPlayer or self.isMainPet then
			self.animSpeed = 0
		end
	elseif self.photoTimePauseAnimPlaying ~= nil then
		self.photoTimePauseAnimPlaying = nil
	end

	self:setAnimSpeed(self.animSpeed)

	if self.refCameraAnim then
		self.refCameraAnim:refreshAnimSpeed()
	end
end

function ClientAnimationComponent:checkIsPhotoTimePause()
	return pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) and pg.global.ui.photo:checkTimePause()
end

function ClientAnimationComponent:getCameraAnimSpeed()
	return self.animSpeed or 1
end

function ClientAnimationComponent:setAnimGroupData(key, groupInfo)
	self.animGroupDatas[key] = groupInfo

	self:refreshPlayableAnimGroup()
end

function ClientAnimationComponent:refreshPlayableAnimGroup()
	if not self.eModel then
		return
	end

	local resultAnimGroupData

	for i = PlayableConst.AnimGroupKey.Max, 1, -1 do
		local animGroupData = self.animGroupDatas[i]

		if animGroupData then
			resultAnimGroupData = animGroupData

			break
		end
	end

	local animGroup = self.eModel.animGroup

	animGroup:ResetData()

	if resultAnimGroupData then
		animGroup.canDash = resultAnimGroupData.canDash or false
		animGroup.canJump = resultAnimGroupData.canJump or false
		animGroup.playSpecialIdle = resultAnimGroupData.playSpecialIdle or false

		local overrideData = resultAnimGroupData.overrideData or {}

		animGroup:SetAnimOverrideData(overrideData)
	end
end

function ClientAnimationComponent:setOverrideAnimation(srcKey, dstKey)
	if not srcKey then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	srcKey = AnimationUtils.getID(srcKey)
	dstKey = AnimationUtils.getID(dstKey)

	eModel:SetupOverrideAnimation(Const.COMPONENT_IDX_PLAYABLE, srcKey, dstKey)
end

function ClientAnimationComponent:clearOverrideAnimation(srcKey)
	if not srcKey then
		return
	end

	local eModel = self.eModel

	if eModel == nil then
		return
	end

	srcKey = AnimationUtils.getID(srcKey)

	eModel:SetupOverrideAnimation(Const.COMPONENT_IDX_PLAYABLE, srcKey, 0)
end

function ClientAnimationComponent:syncAnimationManually(animKey)
	self:serverMsg("RPC_CS_SyncAnimation", animKey)
end

function ClientAnimationComponent:RPC_SC_PlayAnimClip(animName)
	AnimationUtils.playAnimation(self, animName, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function ClientAnimationComponent:RPC_SC_SyncAnimation(animKey)
	self:playAnimation(animKey)
end

function ClientAnimationComponent:resetAnimController()
	local configData = self:getConfigData()

	ClientModelUtils.applyAnimController(self, self.eModel, configData)
end

function ClientAnimationComponent:EVENT_OnAuthorityChanged()
	if self.authority ~= Const.AUTHORITY_MASTER then
		self:stopLayerAnimation(PlayableConst.AnimationLayer.LAYER_FULLBODY, 0.2)
	end

	self:restoreVehicleBodyMountReport()
end

function ClientAnimationComponent:getSeatAttachData(seatId)
	local seatData = vehicle_seat_data[seatId]

	if not seatData then
		return
	end

	local attachData

	if Utils.isPlayer(self) then
		attachData = vehicle_seat_attach_data[seatData.playerAttachId]
	elseif Utils.isHomePet(self) then
		attachData = vehicle_seat_attach_data[seatData.homePetAttachId]

		if attachData == nil then
			attachData = vehicle_seat_attach_data[seatData.petAttachId]
		end
	else
		attachData = vehicle_seat_attach_data[seatData.petAttachId]
	end

	return attachData
end

function ClientAnimationComponent:EVENT_OnEnterVehicle(vehicle, seatId)
	local previousReport = self.vehicleBodyMountReport

	self.vehicleBodyMountReport = {
		exiting = false,
		vehicle = vehicle,
		sessionId = self.vehicleBodyMountSessionId,
		seatId = seatId
	}
	self.pendingMountExitVehicle = nil
	self.pendingMountExitSeatId = nil

	self:addEModelComponent(Const.COMPONENT_MOUNT)

	local attachData = self:getSeatAttachData(seatId)

	if not attachData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientAnimationComponent:EVENT_OnEnterVehicle attachData is nil, seatId %s", seatId)
		end

		return
	end

	self:syncMountAnimState()

	local seatBone = attachData.seatHP and ClientEffectUtils.getBestFitCommonMountBoneName(vehicle, attachData.seatHP)
	local passengerBone = attachData.passengerHP and ClientEffectUtils.getBestFitCommonMountBoneName(self, attachData.passengerHP)

	self.eModel:SetMountAnimInfo(Const.COMPONENT_MOUNT, attachData.enterAnim, attachData.loopAnim, attachData.exitAnim, {
		isPhysics = false,
		offset = attachData.offset,
		rotate = attachData.rotationOffset,
		actorId = vehicle.actorId,
		targetHP = seatBone,
		selfHP = passengerBone,
		freeRotation = vehicle:isFreeRotation()
	}, attachData.loopAnimAlter)
	self.eModel:Mount(Const.COMPONENT_MOUNT)

	if not previousReport then
		self:restoreVehicleBodyMountReport()
	end
end

function ClientAnimationComponent:EVENT_OnExitVehicle(vehicle, seatId)
	self.pendingMountExitVehicle = vehicle

	local report = self.vehicleBodyMountReport

	if report and report.vehicle == vehicle then
		report.exiting = true
	end

	self.pendingMountExitSeatId = seatId

	if self.suppressNextHomeRestVehicleDropPosition then
		self.suppressNextHomeRestVehicleDropPosition = nil

		self.eModel:Dismount(Const.COMPONENT_MOUNT, false, Vector3.zero)
		self.eModel:Detach(Const.COMPONENT_ATTACH)
		self:onVehicleMountExitFinished()

		return
	end

	local attachData = self:getSeatAttachData(seatId)

	if not attachData then
		return
	end

	if attachData.dropHP then
		if not vehicle.eModel then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				self.logger:warn("EVENT_OnExitVehicle vehicle eModel is nil, drop in place, vehicleId %s, seatId %s", vehicle.actorId, seatId)
			end

			self.eModel:Dismount(Const.COMPONENT_MOUNT, false, Vector3.zero)
		else
			local dropBone = ClientEffectUtils.getBestFitCommonMountBoneName(vehicle, attachData.dropHP)
			local valid, pos = vehicle.eModel.skeletonView:TryGetBonePos(dropBone)

			if valid then
				self:forbidPositionCheck({
					Const.FORBID_POSITION_REASON.VEHICLE_DROP
				})
			end

			self.eModel:Dismount(Const.COMPONENT_MOUNT, valid, Vector3(unpack(pos)))
		end
	else
		self.eModel:Dismount(Const.COMPONENT_MOUNT, false, Vector3.zero)
	end

	if Utils.isPet(self) or Utils.isHomePet(self) then
		self:restoreVehicleBodyMountReport()
	end
end

function ClientAnimationComponent:syncMountAnimState(useCustomState, animState)
	if useCustomState then
		if animState and not self:checkSeatNeedSyncAnimState() then
			animState = nil
		end

		self.eModel:SetMountSyncAnimTarget(Const.COMPONENT_MOUNT, animState)

		return
	end

	if self.curVehicle and self.curVehicle.getMountAnimSyncState then
		if self.curVehicle:checkEnableMountAnimState() then
			local syncState

			if self:checkSeatNeedSyncAnimState() then
				syncState = self.curVehicle:getMountAnimSyncState()
			end

			self.eModel:SetMountSyncAnimTarget(Const.COMPONENT_MOUNT, syncState)
		else
			self.eModel:SetMountSyncAnimTarget(Const.COMPONENT_MOUNT, nil)
		end
	else
		self.eModel:SetMountSyncAnimTarget(Const.COMPONENT_MOUNT, nil)
	end
end

function ClientAnimationComponent:checkSeatNeedSyncAnimState()
	local attachData = self:getSeatAttachData(self.curSeatId)

	return not attachData.disableSyncAnimState
end

function ClientAnimationComponent:playVehicleOverrideAnim(config)
	self.eModel:PlaySpecial(Const.COMPONENT_MOUNT, config.startAnim, config.loopAnim, config.endAnim)
end

function ClientAnimationComponent:stopVehicleSpecial()
	self.eModel:StopSpecial(Const.COMPONENT_MOUNT)
end

function ClientAnimationComponent:onVehicleMountLoopEntered()
	local vehicle = self.curVehicle
	local report = self.vehicleBodyMountReport

	if not report or report.vehicle ~= vehicle or report.exiting then
		return
	end

	if vehicle and vehicle.onVehicleMountLoopEntered then
		vehicle:onVehicleMountLoopEntered(self, report.sessionId)
	end
end

function ClientAnimationComponent:onVehicleMountExitFinished()
	local vehicle = self.pendingMountExitVehicle
	local report = self.vehicleBodyMountReport

	if not vehicle or not report or report.vehicle ~= vehicle then
		return
	end

	self.vehicleBodyMountReport = nil
	self.pendingMountExitVehicle = nil
	self.pendingMountExitSeatId = nil

	if vehicle and not vehicle.isDestroyed and vehicle.onVehicleMountExitFinished then
		vehicle:onVehicleMountExitFinished(self, report.sessionId)
	end
end

function ClientAnimationComponent:restoreVehicleBodyMountReport()
	local report = self.vehicleBodyMountReport

	if not self.isMainAuthority or not report then
		return
	end

	local attachData = self:getSeatAttachData(report.seatId)

	if not attachData then
		return
	end

	local animKey = self.animKey
	local isLoop = animKey ~= nil and animKey ~= 0 and (animKey == AnimationUtils.getID(attachData.loopAnim) or animKey == AnimationUtils.getID(attachData.loopAnimAlter))

	if report.exiting then
		local hasLeftMountAnimation = animKey ~= nil and animKey ~= 0 and not isLoop and animKey ~= AnimationUtils.getID(attachData.enterAnim) and animKey ~= AnimationUtils.getID(attachData.exitAnim)

		if hasLeftMountAnimation then
			self:onVehicleMountExitFinished()
		end
	elseif isLoop then
		self:onVehicleMountLoopEntered()
	end
end

function ClientAnimationComponent:EVENT_OnCharacterStateChange(oldState, newState)
	local isPetVehiclePassenger = Utils.isPet(self) or Utils.isHomePet(self)

	if not isPetVehiclePassenger then
		return
	end

	if newState == CharacterStateConst.MOUNT then
		self:onVehicleMountLoopEntered()

		return
	end

	local exitedMounting = CharacterStateConst.isChildOfState(oldState, CharacterStateConst.MOUNTING) and not CharacterStateConst.isChildOfState(newState, CharacterStateConst.MOUNTING)

	if exitedMounting then
		self:onVehicleMountExitFinished()
	end
end

function ClientAnimationComponent:EVENT_OnCloseUI(uid)
	if uid == UIConst.UI_ID_ITEM_VIEWER then
		self:stopVehicleSpecial()
	end
end

return ClientAnimationComponent
