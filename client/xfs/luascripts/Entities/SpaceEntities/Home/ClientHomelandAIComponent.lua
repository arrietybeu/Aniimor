-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomelandAIComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLandOperateData = require("Data.homeland_operate_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local CTRPool = require("Common.AICt.CTRPool")
local AiConst = require("Common.Const.AiConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Const = require("Common.Const.Const")
local SceneUtils = require("Common.Utils.SceneUtils")
local Time = require("Core.Common.Time")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIUtils = require("Common.Utils.AIUtils")
local HomeLeisureBehaviorData = require("Data.home_leisure_behavior_data")
local PlayableConst = require("Common.Const.PlayableConst")
local VehicleSeatData = require("Data.vehicle_seat_data")
local VehicleSeatAttachData = require("Data.vehicle_seat_attach_data")
local ClientConst = require("Const.ClientConst")
local ClientHomelandAIComponent = Class.Component("ClientHomelandAIComponent")

function ClientHomelandAIComponent:isEntityInHomeArea(entity, areaId)
	if not entity or areaId == nil then
		return nil
	end

	local home = pg.game.home
	local areaInfo = home.areaInfoDict and home.areaInfoDict[areaId]
	local areaRange = areaInfo and home:getAreaRange(areaId)

	if not areaRange then
		return nil
	end

	local localPosition = home:getLocalPosition(areaId, entity:getPosition())

	return areaRange[1] <= localPosition.x and localPosition.x <= areaRange[2] and areaRange[3] <= localPosition.z and localPosition.z <= areaRange[4]
end

function ClientHomelandAIComponent:checkAIHomeWorkState()
	local currentPlan = self:getCurrentAIParmonPlan()

	if not currentPlan and self:_checkAIHasHomelandPlanState() then
		self:refreshHomeLandAIPlan()
	end
end

function ClientHomelandAIComponent:_checkAIHasHomelandPlanState()
	if Utils.isHomePet(self) and Utils.checkClient() and self:isAIRunning() then
		if self.petInfo and not Utils.checkHomePetStateValid(self.petInfo, self.space) then
			local eventData = self.petInfo:getHomeEventTypeData(self.space)

			if eventData then
				return true
			end
		end

		if self.allocationInfo then
			local operId = self.allocationInfo.opId
			local operData = operId and HomeLandOperateData[operId]

			if operData then
				return true
			end
		end

		local leisureState = self.space:isHomeland() and self.space.leisureState
		local leisureInfo = leisureState and leisureState[self.id]

		if leisureInfo and self._lastHomeLeisureRevision ~= leisureInfo.revision then
			return true
		end
	end

	return false
end

function ClientHomelandAIComponent:EVENT_OnAuthorityChanged()
	self:refreshHomeLandAIPlan()
end

function ClientHomelandAIComponent:onHomelandAIPlanChanged()
	self:refreshHomeLandAIPlan()
end

function ClientHomelandAIComponent:onHomelandAIRefresh()
	self:refreshHomeLandAIPlan()
end

function ClientHomelandAIComponent:doHomeLeisureAI(leisureInfo)
	if self._lastHomeLeisureRevision == leisureInfo.revision then
		return
	end

	local config = HomeLeisureBehaviorData[leisureInfo.leisureId]

	if not config then
		HomeLandUtils.homeLeisureFinished(self, leisureInfo.revision)

		return
	end

	local leisureType = config.leisureType
	local processed = false
	local petAreaId = HomeLandUtils.getHomePetAreaId(self.space, self.id, self)

	if petAreaId == nil then
		return
	end

	if leisureType == Const.HOME_LEISURE_TYPE.WANDER then
		local context = CTRPool.getContext()

		context.onlyWalk = false

		if Utils.isTable(config.animKeys) then
			context.isStartLoopEndAnim = true
			context.animationStartKey = config.animKeys[1]
			context.animationLoopKey = config.animKeys[2]
			context.animationEndKey = config.animKeys[3]
		else
			context.isStartLoopEndAnim = false
			context.animationLoopKey = config.animKeys
		end

		context.emojiKey = config.emojiKey
		context.revision = leisureInfo.revision
		processed = true

		AIControllerUtils.sendAIEvent(self, "Msg_Home_Leisure_Walk", context)
	elseif leisureType == Const.HOME_LEISURE_TYPE.PURE_WANDER then
		local context = CTRPool.getContext()

		context.onlyWalk = true
		context.revision = leisureInfo.revision
		processed = true

		AIControllerUtils.sendAIEvent(self, "Msg_Home_Leisure_Walk", context)
	elseif leisureType == Const.HOME_LEISURE_TYPE.RIDE then
		local vehicle = pg.game.home:getHomeEntity(leisureInfo.vehicleOrnamentId)

		if vehicle and vehicle.areaId and vehicle.areaId == petAreaId then
			local pos = vehicle:getSeatWorldPositionBySeatIndex(leisureInfo.vehicleSeatIndex, "homePet")

			if pos then
				local context = CTRPool.getContext()

				context.vehiclePos = pos
				context.vehicleActorId = vehicle.actorId
				context.seatIndex = leisureInfo.vehicleSeatIndex
				context.revision = leisureInfo.revision
				processed = true

				AIControllerUtils.sendAIEvent(self, "Msg_Home_Leisure_Mount", context)
			end
		end
	elseif leisureType == Const.HOME_LEISURE_TYPE.PETTING then
		local ownerPlayer = pg.getEntity(self.space.homeLandOwnerPlayerId)

		if ownerPlayer then
			local isOwnerInPetArea = self:isEntityInHomeArea(ownerPlayer, petAreaId)

			if isOwnerInPetArea then
				local context = CTRPool.getContext()

				context.targetActorId = ownerPlayer.actorId

				if Utils.isTable(config.animKeys) then
					context.isStartLoopEndAnim = true
					context.animationStartKey = config.animKeys[1]
					context.animationLoopKey = config.animKeys[2]
					context.animationEndKey = config.animKeys[3]
				else
					context.isStartLoopEndAnim = false
					context.animationLoopKey = config.animKeys
				end

				context.emojiKey = config.emojiKey
				context.revision = leisureInfo.revision
				processed = true

				AIControllerUtils.sendAIEvent(self, "Msg_Home_Leisure_Petting", context)
			end
		end
	end

	if not processed then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("doHomeLeisureAI failed, leisureInfo: %s", inspect(leisureInfo))
		end

		HomeLandUtils.homeLeisureFinished(self, leisureInfo.revision)
	end
end

function ClientHomelandAIComponent:onLeisurePetActionFinished(revision)
	self._lastHomeLeisureRevision = revision
end

function ClientHomelandAIComponent:finishHomePettingLeisureFailedAnimation(expectedTimerId)
	if self.homePettingFailedAnimFallbackTimer ~= expectedTimerId then
		return
	end

	self:removeTimer(self.homePettingFailedAnimFallbackTimer)

	self.homePettingFailedAnimFallbackTimer = nil
	self.homePettingFailedAnimPending = nil

	AIUtils.ResumeAI(self.id, AiConst.PauseBtReason.PlayAnimationScript)
	self:postComponentMethod("onHomelandAIPlanChanged")
end

function ClientHomelandAIComponent:playHomePettingLeisureFailedAnimation()
	self:exitCurrentAIParmonPlan(true)
	AIUtils.PauseAI(self.id, AiConst.PauseBtReason.PlayAnimationScript)

	local state = self:playAnimation(PlayableConst.Behav_CryLoop, true, nil, false)

	if state then
		local petId = self.id

		state:AddAutoTransition(0)

		local fallbackTimerId

		fallbackTimerId = self:addTimer(state.Length + 0.3, function()
			local petEnt = pg.getEntity(petId)

			if petEnt then
				ClientHomelandAIComponent.finishHomePettingLeisureFailedAnimation(petEnt, fallbackTimerId)
			end
		end)
		self.homePettingFailedAnimFallbackTimer = fallbackTimerId

		state:AddEndCallback(function()
			local petEnt = pg.getEntity(petId)

			if petEnt then
				ClientHomelandAIComponent.finishHomePettingLeisureFailedAnimation(petEnt, fallbackTimerId)
			end
		end)

		return
	end

	self.homePettingFailedAnimPending = nil

	AIUtils.ResumeAI(self.id, AiConst.PauseBtReason.PlayAnimationScript)
	self:refreshHomeLandAIPlan()
end

function ClientHomelandAIComponent:onHomePettingLeisureFailed()
	if self.homePettingFailedAnimPending then
		return
	end

	if self.homePettingFailedConfirmTimer then
		self:removeTimer(self.homePettingFailedConfirmTimer)
	end

	self.homePettingFailedAnimPending = true
	self.homePettingFailedConfirmTimer = self:addTimer(1, function()
		self.homePettingFailedConfirmTimer = nil

		local interactGestureComponent = pg.game.social and pg.game.social.interactGestureComponent
		local touchPetPending = interactGestureComponent and interactGestureComponent:isTouchPetInteractionPending(self.id)

		if touchPetPending then
			self.homePettingFailedAnimPending = nil

			self:refreshHomeLandAIPlan()

			return
		end

		local touchPetPlaying = self.pauseBtInfo and self.pauseBtInfo[AiConst.PauseBtReason.TouchPet]

		if touchPetPlaying then
			self.homePettingFailedAnimPending = nil

			return
		end

		self:playHomePettingLeisureFailedAnimation()
	end)
end

function ClientHomelandAIComponent:doSpecialPetAction(targetActorId, emojiKey, animationKey, animationLoopKey, speed, speedRateType, waitTime, animationTime, emojiTime, isFollow, targetPos, stopDist, isGoTargetPos)
	local extraIntParam = math.round(Time.secondCache)

	animationKey = animationKey or ""
	animationLoopKey = animationLoopKey or {}
	speed = speed or 5
	speedRateType = speedRateType or AIUtils.getFollowSpeedRateType(speed, self)
	self.specialAIActionParam = {
		extraIntParam = extraIntParam,
		actorId = targetActorId,
		emojiKey = emojiKey,
		animationKey = animationKey,
		animationLoopKey = animationLoopKey,
		speed = speed,
		waitTime = waitTime,
		speedRateType = speedRateType,
		animationTime = animationTime,
		emojiTime = emojiTime,
		isFollow = isFollow == true,
		targetPos = targetPos,
		stopDist = stopDist,
		isGoTargetPos = isGoTargetPos == true
	}

	self.space:doSpecialAIPetAction(self.id, Const.HOMELAND_FACILITY_OP_TYPE.SPECIAL_AI_ACTION, extraIntParam)

	return extraIntParam
end

function ClientHomelandAIComponent:onSpecialPetActionFinished()
	local actionParam = self.curSpecialActionAIParam

	if actionParam and actionParam.waitTime ~= nil and self._lastFinishedSpecialActionParam ~= actionParam.extraIntParam then
		self._lastFinishedSpecialActionParam = actionParam.extraIntParam

		local ok, HomelandDemoCmdImplement = pcall(require, "GameApp.CmdSocket.HomelandDemoCmdImplement")

		if ok and HomelandDemoCmdImplement and type(HomelandDemoCmdImplement._onPetActionFinished) == "function" then
			HomelandDemoCmdImplement._onPetActionFinished(self, actionParam)
		end
	end
end

function ClientHomelandAIComponent:doNormalHomeProduceAI(allocationInfo)
	local operId = allocationInfo.opId
	local operData = operId and HomeLandOperateData[operId]

	if operData then
		local aiMsgName = operData.aiMsgName
		local context = CTRPool.getContext()
		local isWorking = operId >= Const.HOMELAND_FACILITY_OP_TYPE.MAX_OPER_STATE
		local isMoving = HomeLandUtils.checkOperIdIsMoving(operId)
		local pos, yawAngle

		if isWorking or isMoving then
			pos, yawAngle = HomeLandUtils.getPosRotByOrnamentId(self, self.allocationInfo.ornamentId, self.allocationInfo.posIndex)
		end

		if isWorking then
			local animeStateDefault = operData.animeStateDefault
			local animeStateOverride = operData.animeStateOverride
			local animationKey = AnimationUtils.hasPlayableOverrideConfig(self, animeStateOverride) and animeStateOverride or animeStateDefault
			local petPrototypeId = self.petPrototypeId
			local home_extra_anime_data = require("Data.home_extra_anime_data")
			local faceAnimationKey = home_extra_anime_data[petPrototypeId] and home_extra_anime_data[petPrototypeId][animationKey] or ""

			context.animationKey = animationKey
			context.faceAnimationKey = faceAnimationKey
			context.pos = Vector3(pos[1], pos[2], pos[3])
			context.yawAngle = yawAngle
			context.workPos = pos
		elseif isMoving then
			local distance = Vector3.HoriDistance(pos, self:getPosition())
			local speed = AiConst.HomePetMoveSpeed

			context.pos = Vector3(pos[1], pos[2], pos[3])
			context.yawAngle = yawAngle
			context.moveMaxTime = distance / speed + AiConst.HomePetMoveMaxTimeDelta
			context.moveSpeed = speed
			context.isTransport = HomeLandUtils.checkOperIdIsTransport(operId)
		elseif operId == Const.HOMELAND_FACILITY_OP_TYPE.WELLCOME then
			local homeLandOwnerPlayerEntity = self.space.homeLandOwnerPlayerId and pg.getEntity(self.space.homeLandOwnerPlayerId)
			local scenePointData = SceneUtils.getSceneCommonBasicsPointData(self.space.sceneId, self.space.id)
			local welcomePoints = HomeLandUtils.getHomePetWelcomePoints()
			local pointId = welcomePoints[self.allocationInfo.posIndex]
			local pointPos = scenePointData[pointId].position

			context.targetActorId = homeLandOwnerPlayerEntity and homeLandOwnerPlayerEntity.actorId or 0
			context.targetPos = Vector3(pointPos[1], pointPos[2], pointPos[3])
		end

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("[AI] HomeLand sendAIEvent", self.actorId, inspect(self.allocationInfo), aiMsgName, inspect(context))
		end

		AIControllerUtils.sendAIEvent(self, aiMsgName, context)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("[AI] HomeLand OperateData operId is not exist, operId =", operId)
	end
end

function ClientHomelandAIComponent:doSpecialPetActionAI(allocationInfo)
	if not self.specialAIActionParam then
		self.space:cancelSpecialAIPetAction(self.id)

		return
	end

	if self.specialAIActionParam.extraIntParam ~= allocationInfo.extraIntParam then
		return
	end

	self.curSpecialActionAIParam = self.specialAIActionParam or {}

	AIControllerUtils.sendAIEvent(self, Const.SPECIAL_AI_ACTION_AI_EVENT_NAME, self.curSpecialActionAIParam)
end

function ClientHomelandAIComponent:refreshHomeLandAIPlan()
	if self.homePettingFailedAnimPending then
		return
	end

	if Utils.isHomePet(self) and Utils.checkClient() and self:isAIRunning() then
		self:exitCurrentAIParmonPlan(true)

		local eventData

		if self.petInfo and not Utils.checkHomePetStateValid(self.petInfo, self.space) then
			eventData = self.petInfo:getHomeEventTypeData(self.space)
		end

		if eventData then
			local context = CTRPool.getContext()
			local aiMsgName = eventData.aiMsgName
			local aiMsgParams = eventData.aiMsgParams or AiConst.DefaultNullTable

			for k, v in pairs(aiMsgParams) do
				context[k] = v
			end

			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:debug("[AI] HomeLand 随机事件", self.actorId, aiMsgName, inspect(eventData))
			end

			AIControllerUtils.sendAIEvent(self, aiMsgName, context)
		elseif self.allocationInfo and self.allocationInfo.opId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
			local operId = self.allocationInfo.opId

			if operId == Const.HOMELAND_FACILITY_OP_TYPE.SPECIAL_AI_ACTION then
				self:doSpecialPetActionAI(self.allocationInfo)
			else
				self:doNormalHomeProduceAI(self.allocationInfo)
			end
		else
			local leisureState = self.space:isHomeland() and self.space.leisureState
			local leisureInfo = leisureState and leisureState[self.id]

			if leisureInfo then
				self:doHomeLeisureAI(leisureInfo)
			end
		end
	end
end

return ClientHomelandAIComponent
