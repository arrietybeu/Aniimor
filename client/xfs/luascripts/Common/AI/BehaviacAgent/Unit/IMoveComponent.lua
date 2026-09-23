-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IMoveComponent.lua

local class = require("Core.Framework.Class")
local CalcUtils = require("Common.Utils.CalcUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local enums = require("Common.AI.Behaviac.Enums")
local PlayableConst = require("Common.Const.PlayableConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AiConst = require("Common.Const.AiConst")
local SysConfigData = require("Data.sys_config_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIUtils = require("Common.Utils.AIUtils")
local VectorPool = require("Common.Container.VectorPool")
local ListPool = require("Common.Container.ListPool")
local AIMoveAbility = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIMoveAbility")
local AIEnvQueryAbility = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIEnvQueryAbility")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local AIAreaData = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIAreaData")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Vector3 = Vector3
local Quaternion = Quaternion
local pg = pg
local math_abs = math.abs
local math_atan2 = math.atan2
local math_ceil = math.ceil
local math_cos = math.cos
local math_deg = math.deg
local math_epsilon = math.epsilon
local math_max = math.max
local math_min = math.min
local math_rad = math.rad
local math_random = math.random
local math_sin = math.sin
local type = type
local EBTStatus = enums.EBTStatus
local IMoveComponent = class.Component("IMoveComponent")

function IMoveComponent:ctor()
	self.moveAbility = AIMoveAbility.new()
	self.envQueryAbility = AIEnvQueryAbility.new()
end

function IMoveComponent:onInit()
	self:setBlackBoardProperty("goBackNextCdTime", 0)
	self:setBlackBoardProperty("sideWalkWeight", 50)
	self.moveAbility:init(self.ent)
	self.envQueryAbility:init(self.ent)
end

function IMoveComponent:onRelease()
	self.moveAbility:release()
	self.envQueryAbility:release()
end

function IMoveComponent:setFaceToTargetPos(targetPosition)
	Vector3.enableCreateFromCache()

	local pos = targetPosition:Clone()
	local ret = AIBaseMethodUtils.Base_TurnToDirection(self.ent, pos:Sub(self.ent:getPosition()))

	Vector3.disableCreateFromCache()

	return ret and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function IMoveComponent:faceToPos(targetPos)
	Vector3.enableCreateFromCache()

	local pos = targetPos:Clone()
	local direction = pos:Sub(self.ent:getPosition())
	local ret = AIBaseMethodUtils.Base_TurnToDirection(self.ent, direction)

	Vector3.disableCreateFromCache()

	return ret and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function IMoveComponent:turnToPos__resetState(resetStateType)
	self:turnToYaw__resetState(resetStateType)
end

function IMoveComponent:turnToPos(pos, deltaYawDegree, useTurnAnim, timeout, instant)
	local myPos = self.ent:getPosition()
	local tgtYaw = math_deg(math_atan2(pos[1] - myPos[1], pos[3] - myPos[3])) + deltaYawDegree

	return self:turnToYaw(tgtYaw, useTurnAnim, timeout, instant)
end

function IMoveComponent:turnToPosEx(posx, posz, deltaYawDegree, useTurnAnim, timeout, instant)
	local myPos = self.ent:getPosition()
	local tgtYaw = math_deg(math_atan2(posx - myPos[1], posz - myPos[3])) + deltaYawDegree

	return self:turnToYaw(tgtYaw, useTurnAnim, timeout, instant)
end

function IMoveComponent:turnToTargetAtYaw__resetState(resetStateType)
	self:turnToPos__resetState(resetStateType)
end

function IMoveComponent:turnToTargetAtYaw(targetActorId, yawAngle, useTurnAnim, timeout, instant)
	local tgt = pg.getEntityByActorId(targetActorId)

	if not tgt then
		return EBTStatus.BT_FAILURE
	end

	return self:turnToPos(tgt:getPosition(), yawAngle, useTurnAnim, timeout, instant)
end

function IMoveComponent:turnToTarget__resetState(resetStateType)
	self:turnToTargetAtYaw__resetState(resetStateType)
end

function IMoveComponent:turnToTarget(targetActorId, useTurnAnim, timeout, instant)
	local tgt = pg.getEntityByActorId(targetActorId)

	if not tgt then
		return EBTStatus.BT_FAILURE
	end

	local pos = tgt:getPosition()
	local myPos = self.ent:getPosition()
	local tgtYaw = math_deg(math_atan2(pos[1] - myPos[1], pos[3] - myPos[3]))

	return self:turnToYaw(tgtYaw, useTurnAnim, timeout, instant)
end

function IMoveComponent:turnToYaw__resetState(resetStateType)
	self.x_turnToYaw_angle = nil
	self.x_turnToYaw_normalizedAngle = nil
	self.x_turnToYaw_AnimationState = nil
	self.x_turnToYaw_timeout = nil

	self:_removeCustomTimeout("turnToYaw")

	if resetStateType == AiConst.ResetStateType.exit then
		AIControllerUtils.setOverrideSteeringTime(self.ent, -1)
	end
end

function IMoveComponent:turnToYaw(yawAngle, useTurnAnim, timeout, instant, steeringTime)
	if self.x_turnToYaw_angle == nil then
		AIBaseMethodUtils.Base_SetYawDegrees(self.ent, yawAngle, instant, steeringTime)

		if useTurnAnim and Utils.checkClient() then
			local currentState = AIControllerUtils.getCurrentAnimationState(self.ent)

			if CharacterStateConst.isChildOfState(currentState, CharacterStateConst.LOCOMOTION) and AnimationUtils.hasPlayableOverrideConfig(self.ent, PlayableConst.TurnBlend) then
				self.x_turnToYaw_AnimationState = AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.TURN)
			end
		end

		self.x_turnToYaw_angle = yawAngle
		self.x_turnToYaw_normalizedAngle = Utils.normalizeAngle(yawAngle)
		self.x_turnToYaw_timeout = timeout < math_epsilon and AiConst.TURN_YAW_MAX_TIME or timeout

		return EBTStatus.BT_RUNNING
	end

	if self.x_turnToYaw_AnimationState then
		if AIControllerUtils.getCurrentAnimationState(self.ent) == CharacterStateConst.TURN then
			return EBTStatus.BT_RUNNING
		end

		local angle1 = Utils.normalizeAngle(self.ent:getYaw())
		local deltaAngle = math_abs(angle1 - (self.x_turnToYaw_normalizedAngle or 0))
		local deltaYawDegree = deltaAngle <= 180 and deltaAngle or 360 - deltaAngle

		if deltaYawDegree < 5 then
			return EBTStatus.BT_SUCCESS
		else
			return EBTStatus.BT_FAILURE
		end
	else
		local angle1 = Utils.normalizeAngle(self.ent:getYaw())
		local deltaAngle = math_abs(angle1 - (self.x_turnToYaw_normalizedAngle or 0))
		local deltaYawDegree = deltaAngle <= 180 and deltaAngle or 360 - deltaAngle

		if deltaYawDegree < 5 then
			return EBTStatus.BT_SUCCESS
		end

		if self:_checkAndSetCustomTimeout("turnToYaw", self.x_turnToYaw_timeout) then
			return EBTStatus.BT_FAILURE
		end

		return EBTStatus.BT_RUNNING
	end
end

function IMoveComponent:turnBack__resetState(resetStateType)
	self.x_turnBack_oldYawDeg = nil

	self:_removeCustomTimeout("turnBack")
	AIBaseMethodUtils.Base_StopAnimation(self.ent, PlayableConst.TurnBack, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function IMoveComponent:turnBack(turnYawAngle, useTurnAnim, timeout, syncPointEnum)
	local curYawDeg = self.ent:getYaw()

	if self.x_turnBack_oldYawDeg == nil then
		self.x_turnBack_oldYawDeg = curYawDeg

		if useTurnAnim then
			Vector3.enableCreateFromCache()

			local newYawDeg = Utils.clampAngle(curYawDeg + turnYawAngle, 0, 360)
			local realTimeout = AIBaseMethodUtils.Base_ChangeToRootMotion(self.ent, PlayableConst.TurnBack, self.ent:getPosition(), Quaternion.Euler(0, newYawDeg, 0), false, syncPointEnum)

			Vector3.disableCreateFromCache()
			self:_settingCustomTimeout("turnBack", realTimeout)
		else
			AIBaseMethodUtils.Base_SetYawDegrees(self.ent, curYawDeg + turnYawAngle)
			self:_settingCustomTimeout("turnBack", timeout)
		end
	end

	if not self:_checkAndRemoveCustomTimeout("turnBack") then
		return EBTStatus.BT_RUNNING
	end

	local deltaYawDegree = Utils.angleDiff(self.x_turnBack_oldYawDeg, curYawDeg)

	if deltaYawDegree < 5 then
		return EBTStatus.BT_SUCCESS
	else
		return EBTStatus.BT_FAILURE
	end
end

function IMoveComponent:teleportToTargetSide__resetState(resetStateType)
	self.moveAbility:resetTeleportPos(resetStateType)
	VectorPool.returnVector(self.x_teleportToTargetSide_targetPos)

	self.x_teleportToTargetSide_targetPos = nil
end

function IMoveComponent:teleportToTargetSide(targetId, minRange, maxRange, forceTeleport)
	local tgtEnt = pg.getEntityByActorId(targetId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if Vector3.SqrDistance(self.ent:getPosition(), tgtEnt:getPosition()) < AiConst.FOLLOW_CLOSE_POW_2 then
		return EBTStatus.BT_SUCCESS
	end

	if not self.x_teleportToTargetSide_targetPos and self.ent.masterActorId == tgtEnt.actorId and Utils.isMainPlayer(tgtEnt) then
		self.x_teleportToTargetSide_targetPos = VectorPool.getVector(3, tgtEnt:getPosition())
	end

	if not self.x_teleportToTargetSide_targetPos then
		local tgtEntPos = tgtEnt:getPosition()
		local ret, x, y, z = VoxelUtils.findVoxelRandomPos(self.ent, tgtEntPos, minRange, maxRange)

		if not ret and not forceTeleport then
			return EBTStatus.BT_FAILURE
		end

		self.x_teleportToTargetSide_targetPos = VectorPool.getVector(3)

		if ret then
			self.x_teleportToTargetSide_targetPos[1] = x
			self.x_teleportToTargetSide_targetPos[2] = y
			self.x_teleportToTargetSide_targetPos[3] = z
		else
			self.x_teleportToTargetSide_targetPos[1] = tgtEntPos[1]
			self.x_teleportToTargetSide_targetPos[2] = tgtEntPos[2]
			self.x_teleportToTargetSide_targetPos[3] = tgtEntPos[3]
		end
	end

	return self.moveAbility:teleportPos(self.x_teleportToTargetSide_targetPos, false)
end

function IMoveComponent:combatTeleportToTarget__resetState(resetStateType)
	self.moveAbility:resetTeleportPos(resetStateType)
	VectorPool.returnVector(self.x_combatTeleportToTarget_targetPos)

	self.x_combatTeleportToTarget_targetPos = nil
end

function IMoveComponent:combatTeleportToTarget(masterId, tgtActorId, targetDistance)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)
	local masterEnt = pg.getEntityByActorId(masterId)

	targetDistance = targetDistance or self:getBlackBoardProperty("attackStopBoxDist")

	if tgtEnt == nil or masterEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if not self.x_combatTeleportToTarget_targetPos then
		self.x_combatTeleportToTarget_targetPos = VectorPool.getVector(3)

		Vector3.enableCreateFromCache()

		local direction = tgtEnt:getPositionClone():Sub(masterEnt:getPosition()):SetNormalize()
		local nearPos = tgtEnt:getPositionClone():Sub(direction * targetDistance)
		local ret, x, y, z = VoxelUtils.findVoxelRandomPos(self.ent, nearPos, 0, AiConst.NAVMESH_RANDOM_RADIUS)
		local targetPos = ret and Vector3.New(x, y, z) or tgtEnt:getPosition()

		self.x_combatTeleportToTarget_targetPos:Copy(targetPos)
		Vector3.disableCreateFromCache()
	end

	return self.moveAbility:teleportPos(self.x_combatTeleportToTarget_targetPos, false)
end

function IMoveComponent:teleportToPosition__resetState(resetStateType)
	self.moveAbility:resetTeleportPos(resetStateType)
end

function IMoveComponent:teleportToPosition(position, useEffect)
	return self.moveAbility:teleportPos(position, useEffect)
end

function IMoveComponent:moveToPos__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:moveToPos(pos, maxTime, faceToPos, stopDist, speedRateType, speed, pathFindType, isRepath, useAccurateArrive, replaceAnimation)
	speedRateType = speedRateType or BaseEnum.SpeedRateType.Slow

	return self.moveAbility:moveToPos(pos, maxTime, faceToPos, stopDist, speedRateType, speed, pathFindType, isRepath, useAccurateArrive, replaceAnimation)
end

function IMoveComponent:moveToPosList__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		if self.x_moveToPosList_posList then
			ListPool.returnList(self.x_moveToPosList_posList)

			self.x_moveToPosList_posList = nil
		end

		if self.x_moveToPosList_normalList then
			ListPool.returnList(self.x_moveToPosList_normalList)

			self.x_moveToPosList_normalList = nil
		end

		if self.x_moveToPosList_targetPosList then
			ListPool.returnList(self.x_moveToPosList_targetPosList)

			self.x_moveToPosList_targetPosList = nil
		end

		self.x_moveToPosList_moveIndex = nil
	end

	if resetStateType == AiConst.ResetStateType.pause then
		self.x_moveToPosList_moveIndex = AutoPathFindUtils.getCurrentPathMoveIndex(self.ent)
	end

	self.moveAbility:resetMoveToPosList(resetStateType)

	if resetStateType == AiConst.ResetStateType.resume and self.x_moveToPosList_moveIndex and self.x_moveToPosList_moveIndex > 0 then
		self.moveAbility:resetMoveToPosList(AiConst.ResetStateType.exit)
		self.moveAbility:resetMoveToPosList(AiConst.ResetStateType.enter)

		if self.x_moveToPosList_moveIndex > 1 then
			for i = 1, #self.x_moveToPosList_posList do
				self.x_moveToPosList_posList[i] = self.x_moveToPosList_posList[i + self.x_moveToPosList_moveIndex - 1]
			end

			if self.x_moveToPosList_normalList then
				for i = 1, #self.x_moveToPosList_normalList do
					self.x_moveToPosList_normalList[i] = self.x_moveToPosList_normalList[i + self.x_moveToPosList_moveIndex - 1]
				end
			end
		end
	end
end

function IMoveComponent:moveToPosList(posList, maxTime, faceToPos, stopDist, speedRateType, speed, normalList, useAccurateArrive)
	local posLen = #posList

	if posLen == 0 then
		return EBTStatus.BT_FAILURE
	end

	if self.x_moveToPosList_posList == nil then
		self.x_moveToPosList_posList = ListPool.getList()

		for i = 1, posLen do
			self.x_moveToPosList_posList[i] = posList[i]
		end
	end

	if normalList and self.x_moveToPosList_normalList == nil then
		self.x_moveToPosList_normalList = ListPool.getList()

		for i = 1, posLen do
			self.x_moveToPosList_normalList[i] = normalList[i]
		end
	end

	if self.x_moveToPosList_targetPosList == nil then
		self.x_moveToPosList_targetPosList = ListPool.getList()
		self.x_moveToPosList_targetPosList[1] = posList[posLen]
	end

	return self.moveAbility:moveToPosList(self.x_moveToPosList_posList, self.x_moveToPosList_targetPosList, maxTime, faceToPos, stopDist, speedRateType, speed, false, self.x_moveToPosList_normalList, useAccurateArrive)
end

function IMoveComponent:moveToTarget__resetState(resetStateType)
	self.x_moveToTarget_targetPos = nil
	self.x_moveToTarget_bodyBias = nil
	self.x_moveToTarget_bodyBias_sqr = nil
	self.x_moveToTarget_cachedTargetId = nil
	self.x_moveToTarget_isEnvObj = nil

	self:_removeCustomTimeout("moveToTarget_moveUpdateLevelTimeout")
	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:moveToTarget(targetActorId, stopDist, maxTime, noBodySize, walkIfNear, faceToPos, speed, moveUpdateLevel, pathFindType, speedRateType, targetEnvPartId, useAccurateArrive)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	maxTime = maxTime or AiConst.MOVE_CD
	stopDist = math_max(stopDist, 0)

	if self.x_moveToTarget_bodyBias == nil or self.x_moveToTarget_cachedTargetId ~= targetActorId then
		self.x_moveToTarget_bodyBias = CalcUtils.getBodySizeBias(tgtEnt, self.ent, not noBodySize, not noBodySize, targetEnvPartId) + stopDist
		self.x_moveToTarget_bodyBias_sqr = self.x_moveToTarget_bodyBias * self.x_moveToTarget_bodyBias
		self.x_moveToTarget_isEnvObj = Utils.isEnvObj(tgtEnt)
		self.x_moveToTarget_cachedTargetId = targetActorId
	end

	if Vector3.SqrDistance(self.ent:getPosition(), tgtEnt:getPosition()) < self.x_moveToTarget_bodyBias_sqr then
		return EBTStatus.BT_SUCCESS
	end

	moveUpdateLevel = moveUpdateLevel or BaseEnum.MoveUpdateLevel.Once

	local isRepath = false

	if self.x_moveToTarget_targetPos == nil or self:_checkAndSetCustomTimeout("moveToTarget_moveUpdateLevelTimeout", AIUtils.getMoveUpdateTimeout(moveUpdateLevel)) then
		isRepath = true
	end

	local targetPos

	if isRepath or faceToPos then
		if self.x_moveToTarget_isEnvObj then
			targetPos = tgtEnt:getLockPartPosition(targetEnvPartId)
		else
			targetPos = tgtEnt:getPosition()
		end
	end

	if isRepath then
		self.x_moveToTarget_targetPos = targetPos

		self:_removeCustomTimeout("moveToTarget_moveUpdateLevelTimeout")
	end

	if walkIfNear and Vector3.Distance(self.ent:getPosition(), targetPos) - self.x_moveToTarget_bodyBias < AiConst.WALK_RANGE then
		speedRateType = BaseEnum.SpeedRateType.Slow
	end

	if faceToPos then
		self:faceToPos(targetPos)
	end

	return self.moveAbility:moveToPos(self.x_moveToTarget_targetPos, maxTime, not faceToPos, self.x_moveToTarget_bodyBias, speedRateType, speed, pathFindType, isRepath, useAccurateArrive)
end

function IMoveComponent:moveToTargetPos__resetState(resetStateType)
	if self.x_moveToTargetPos_targetPos then
		VectorPool.returnVector(self.x_moveToTargetPos_targetPos)

		self.x_moveToTargetPos_targetPos = nil
	end

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:moveToTargetPos(targetActorId, targetYaw, distance, stopDist, maxTime, noBodySize, walkIfNear, faceToTarget, speed, speedRateType, pathFindType, useAccurateArrive, useCameraToTargetYaw)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	maxTime = maxTime or AiConst.MOVE_CD

	local tStopDist = stopDist + (noBodySize and 0 or CalcUtils.getBodySize(self.ent))

	if self.x_moveToTargetPos_targetPos == nil then
		distance = distance + (noBodySize and 0 or CalcUtils.getBodySize(tgtEnt))
		self.x_moveToTargetPos_targetPos = VectorPool.getVector()

		local tgtEntYaw

		if useCameraToTargetYaw and Utils.checkClient() then
			local tmpVector = VectorPool.getVector(3, tgtEnt:getPosition())

			tgtEntYaw = math_deg(tmpVector:Sub(pg.game.camera:getCameraPosition()):ToYaw())

			VectorPool.returnVector(tmpVector)
		else
			tgtEntYaw = tgtEnt:getYaw()
		end

		CalcUtils.getPosOnRayByYawDegree(tgtEnt:getPosition(), tgtEntYaw + targetYaw, distance, self.x_moveToTargetPos_targetPos)
	end

	if walkIfNear and Vector3.Distance(self.ent:getPosition(), self.x_moveToTargetPos_targetPos) - tStopDist < AiConst.WALK_RANGE then
		speedRateType = BaseEnum.SpeedRateType.Slow
	end

	local faceToPos = false

	if faceToTarget then
		self:faceToPos(tgtEnt:getPosition())

		faceToPos = false
	else
		faceToPos = true
	end

	return self.moveAbility:moveToPos(self.x_moveToTargetPos_targetPos, maxTime, faceToPos, tStopDist, speedRateType, speed, pathFindType, nil, useAccurateArrive)
end

function IMoveComponent:moveToProtect__resetState(resetStateType)
	if self.x_moveToProtect_targetPos then
		VectorPool.returnVector(self.x_moveToProtect_targetPos)

		self.x_moveToProtect_targetPos = nil
	end

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:moveToProtect(protectedActorId, enemyActorId, radius, maxTime, noBodySize, speed, speedRateType, pathFindType, useAccurateArrive)
	local protectedEnt = pg.getEntityByActorId(protectedActorId)
	local enemyEnt = pg.getEntityByActorId(enemyActorId)

	if protectedEnt == nil or enemyEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self.x_moveToProtect_targetPos == nil then
		self.x_moveToProtect_targetPos = VectorPool.getVector()
		radius = radius + (noBodySize and 0 or CalcUtils.getBodySize(protectedEnt))

		Vector3.enableCreateFromCache()

		local enemyPos = enemyEnt:getPosition()
		local entPos = protectedEnt:getPosition()
		local targetPos = entPos + Vector3.Normalize(enemyPos - entPos) * radius

		self.x_moveToProtect_targetPos:Copy(targetPos)
		Vector3.disableCreateFromCache()
	end

	return self.moveAbility:moveToPos(self.x_moveToProtect_targetPos, maxTime, true, 0, speedRateType, speed, pathFindType, nil, useAccurateArrive)
end

function IMoveComponent:gotoBornPos__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	self.x_gotoBornPos_pos = nil
end

function IMoveComponent:gotoBornPos(timeout)
	if timeout < math_epsilon then
		timeout = SysConfigData.goHomeTimeOutValue
	end

	if not self.x_gotoBornPos_pos then
		self.x_gotoBornPos_pos = self:getBornPos()
	end

	return self.moveAbility:moveToPos(self.x_gotoBornPos_pos, timeout, true, nil, BaseEnum.SpeedRateType.Mid)
end

function IMoveComponent:getBornPos()
	return AIUtils.getGoHomePos(self.ent)
end

function IMoveComponent:_findDirectionTargetPosList(sourcePos, dir, targetDistance, minDistance, backDistance, tgtBodySize, targetPosList, filterFunc)
	targetDistance = targetDistance or AiConst.LEVEL_DISTANCE
	minDistance = minDistance or AiConst.MIN_LEAVE_DISTANCE
	backDistance = math_max(AiConst.MIN_LEAVE_DISTANCE, backDistance or 0)
	tgtBodySize = tgtBodySize or 0

	local yawAngle = math_deg(CalcUtils.getYawByDir(dir[1], dir[3]))
	local deltaAngle = 0
	local dist = targetDistance + tgtBodySize + CalcUtils.getBodySizeBias(self.ent)
	local deltaDist = -(dist - backDistance) / (180 / AiConst.DIRECTION_ANGLE)
	local deltaHeight = -AiConst.FLY_LEAVE_HEIGHT / (180 / AiConst.DIRECTION_ANGLE)
	local flyHeight = AiConst.FLY_LEAVE_HEIGHT
	local targetPosListLen = #targetPosList

	for i = 1, targetPosListLen do
		VectorPool.returnVector(targetPosList[i])

		targetPosList[i] = nil
	end

	while deltaAngle <= 180 do
		for sign = -1, 1, 2 do
			local basePos = VectorPool.getVector()

			CalcUtils.getPosOnRayByYawDegree(sourcePos, yawAngle + sign * deltaAngle, dist, basePos)

			if CharacterStateConst.isChildOfState(self.ent.characterState, CharacterStateConst.FLYING) then
				basePos[2] = basePos[2] + flyHeight
			end

			if filterFunc == nil or not filterFunc(self.ent, basePos) then
				targetPosList[#targetPosList + 1] = basePos
			end

			if deltaAngle == 0 or deltaAngle == 180 then
				break
			end
		end

		deltaAngle = deltaAngle + AiConst.DIRECTION_ANGLE
		dist = math_max(deltaDist + dist, minDistance)
		flyHeight = flyHeight + deltaHeight
	end

	return targetPosList
end

function IMoveComponent:checkNeedFollow(targetActorId)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return false
	end

	local followTeleportDist = self:getBlackBoardProperty("followTeleportDist")

	return followTeleportDist * followTeleportDist >= Vector3.SqrDistance(self.ent:getPosition(), tgtEnt:getPosition())
end

function IMoveComponent:checkStartFollow(targetActorId)
	if Utils.checkClient() then
		return self:checkStartMoveToAppointedArea(targetActorId, "PetStartArea")
	end

	return true
end

function IMoveComponent:followEntity__resetState(resetStateType)
	if Utils.checkClient() then
		self.moveAbility:resetMoveToPosList(resetStateType)
		self:_removeCustomTimeout("followEntity_animateStateSwapTime")
		self:_removeCustomTimeout("followEntity_slowDownFollow")

		if self.x_followEntity_targetPosList then
			local followEntity_targetPosListLen = #self.x_followEntity_targetPosList

			for i = 1, followEntity_targetPosListLen do
				VectorPool.returnVector(self.x_followEntity_targetPosList[i])

				self.x_followEntity_targetPosList[i] = nil
			end

			ListPool.returnList(self.x_followEntity_targetPosList)

			self.x_followEntity_targetPosList = nil
		end

		self.x_followEntity_speedRate = nil
		self.x_followEntity_speed = nil
		self.x_followEntity_areaData = nil

		if self.x_followEntity_targetOldPos then
			VectorPool.returnVector(self.x_followEntity_targetOldPos)

			self.x_followEntity_targetOldPos = nil
		end

		self:teleportToTargetSide__resetState(resetStateType)
	else
		self:moveToTarget__resetState(resetStateType)
	end
end

function IMoveComponent:followEntity(targetId, needChangeFollowType)
	if Utils.checkClient() then
		local tgtEnt = pg.getEntityByActorId(targetId)

		if tgtEnt == nil then
			return EBTStatus.BT_FAILURE
		end

		local followTeleportDist = self:getBlackBoardProperty("followTeleportDist")
		local followFarDist = self:getBlackBoardProperty("followFarDist")
		local followMidDist = self:getBlackBoardProperty("followMidDist")
		local followCloseDist = self:getBlackBoardProperty("followCloseDist")
		local myPos = self.ent:getPosition()
		local targetPos = tgtEnt:getPosition()
		local targetEntVelocity = tgtEnt:getVelocity()

		if not targetEntVelocity then
			return EBTStatus.BT_FAILURE
		end

		Vector3.enableCreateFromCache()

		local currentSqrDis2Target = Vector3.HoriSqrDistance(myPos, targetPos)
		local targetEntSpeed = targetEntVelocity:Magnitude()
		local me2TargetDegree = CalcUtils.getAngleByEntityPos(tgtEnt, self.ent)

		Vector3.disableCreateFromCache()

		if not self.x_followEntity_targetPosList then
			self.x_followEntity_targetPosList = ListPool.getList()
		end

		if self.x_followEntity_areaData == nil or self:_checkAndSetCustomTimeout("followEntity_animateStateSwapTime", AiConst.FOLLOW_ANIMATION_STATE_SWAP_TIME) then
			self:_removeCustomTimeout("followEntity_animateStateSwapTime")

			if needChangeFollowType then
				if currentSqrDis2Target > followTeleportDist * followTeleportDist or math_abs(myPos[2] - targetPos[2]) > AiConst.FOLLOW_HEIGHT then
					return self:teleportToTargetSide(targetId, AiConst.FOLLOW_CLOSE, AiConst.FOLLOW_MID, true)
				elseif self.x_PetFollowCameraNormalArea == AIAreaData.PetFollowCameraNormalArea or math_abs(me2TargetDegree) > AiConst.FOLLOW_SPEED_SLOWDOWN_DEGREE and targetEntSpeed > AiConst.FOLLOW_MASTER_SPEED_UP_SPEED then
					self.x_followEntity_areaData = AIAreaData.PetFollowSpeedUpArea
				elseif currentSqrDis2Target > followMidDist * followMidDist or (self.x_followEntity_areaData == AIAreaData.PetFollowSpeedUpArea or self.x_followEntity_areaData == AIAreaData.PetFollowNormalArea) and self:_checkAndSetCustomTimeout("followEntity_slowDownFollow", AiConst.FOLLOW_SLOW_DOWN_TIME) then
					self:_removeCustomTimeout("followEntity_slowDownFollow")

					self.x_followEntity_areaData = AIAreaData.PetFollowSlowDownArea
				elseif currentSqrDis2Target > followCloseDist * followCloseDist or targetEntSpeed > AiConst.FOLLOW_MASTER_START_SPEED then
					self.x_followEntity_areaData = AIAreaData.PetFollowNormalArea
				else
					self.x_followEntity_areaData = AIAreaData.PetFollowMoveAwayArea
				end

				Vector3.enableCreateFromCache()

				local cameraPosX, _, cameraPosZ, cameraFwdX, cameraFwdY, cameraFwdZ = pg.global.cameraMgr:GetWorldCameraPositionAndForwardEx()
				local cameraForward = Vector3(cameraFwdX, cameraFwdY, cameraFwdZ)
				local camera2TargetYawDegree = math_deg(CalcUtils.getAngleByDir(cameraForward, tgtEnt:getRotation():Forward()))

				Vector3.disableCreateFromCache()

				if math_abs(camera2TargetYawDegree) > AiConst.PET__FOLLOW_CAMERA_AFFECT_ANGLE and currentSqrDis2Target < followMidDist * followMidDist then
					if Vector3.HoriDistance(myPos, targetPos) < Vector3.HoriDistanceEx(cameraPosX, cameraPosZ, targetPos.x, targetPos.z) * 0.7 then
						self.x_followEntity_areaData = AIAreaData.PetFollowCameraNormalArea
					else
						self.x_followEntity_areaData = AIAreaData.PetFollowCameraChangeSpeedArea
					end
				end
			elseif currentSqrDis2Target > followTeleportDist * followTeleportDist or math_abs(myPos[2] - targetPos[2]) > AiConst.FOLLOW_HEIGHT then
				return self:teleportToTargetSide(targetId, AiConst.FOLLOW_CLOSE, AiConst.FOLLOW_MID, true)
			else
				self.x_followEntity_areaData = AIAreaData.NPCFollowNormalArea
			end
		end

		local isRepath = false

		if self:checkStartMoveToAppointedArea(targetId, "PetCanFollowArea") and not self:checkFollowEntityIsInSamePos(tgtEnt) then
			isRepath = self.moveAbility:movementSelectMovePosList(tgtEnt, self.x_followEntity_areaData, self.x_followEntity_targetPosList)
			self.x_followEntity_speed, self.x_followEntity_speedRate = self.moveAbility:movementGetMovementInfo(tgtEnt, self.x_followEntity_areaData)
		end

		local ret = self.moveAbility:moveToPosList(nil, self.x_followEntity_targetPosList, AiConst.FOLLOW_CD, true, AiConst.TARGET_POINT_STOP_DIST, self.x_followEntity_speedRate, self.x_followEntity_speed, isRepath, nil, nil, AutoPathFindUtils.PathFindType.Physics)

		if ret == EBTStatus.BT_FAILURE then
			if self:checkStartFollow(targetId) then
				return self:teleportToTargetSide(targetId, AiConst.FOLLOW_CLOSE, AiConst.FOLLOW_MID, true)
			else
				return EBTStatus.BT_SUCCESS
			end
		end

		return ret
	else
		return self:moveToTarget(targetId, AiConst.FOLLOW_CLOSE)
	end
end

function IMoveComponent:checkFollowEntityIsInSamePos(followEntity)
	if not self.x_followEntity_targetOldPos then
		self.x_followEntity_targetOldPos = VectorPool.getVector(3, Vector3.constZero)
	end

	local isSame = Vector3.SqrDistance(self.x_followEntity_targetOldPos, followEntity:getPosition()) < 0.1

	if not isSame then
		self.x_followEntity_targetOldPos:Copy(followEntity:getPosition())
	end

	return isSame
end

function IMoveComponent:followEntityInCombat__resetState(resetStateType)
	self:followEntity__resetState(resetStateType)
end

function IMoveComponent:followEntityInCombat(targetId)
	return self:followEntity(targetId)
end

function IMoveComponent:moveAside__resetState(resetStateType)
	if self.x_moveAside_targetPosList then
		local len = #self.x_moveAside_targetPosList

		for i = 1, len do
			VectorPool.returnVector(self.x_moveAside_targetPosList[i])

			self.x_moveAside_targetPosList[i] = nil
		end

		ListPool.returnList(self.x_moveAside_targetPosList)

		self.x_moveAside_targetPosList = nil
	end

	self.moveAbility:resetMoveToPosList(resetStateType)
end

function IMoveComponent:moveAside(targetId)
	local tgtEnt = pg.getEntityByActorId(targetId)

	if not tgtEnt then
		return EBTStatus.BT_FAILURE
	end

	if not self:checkIsCloseToFollowTarget(targetId) then
		return EBTStatus.BT_SUCCESS
	end

	if self.x_moveAside_targetPosList == nil then
		local followMidDist = self:getBlackBoardProperty("followMidDist")
		local followCloseDist = self:getBlackBoardProperty("followCloseDist")
		local tgtEntYaw = tgtEnt:getYaw()

		self.x_moveAside_targetPosList = ListPool.getList()
		self.x_moveAside_targetPosList[1] = CalcUtils.getPosOnRayByYawDegree(tgtEnt:getPosition(), tgtEntYaw, (followCloseDist + followMidDist) / 2, VectorPool.getVector())
		self.x_moveAside_targetPosList[2] = CalcUtils.getPosOnRayByYawDegree(tgtEnt:getPosition(), tgtEntYaw - AiConst.PET_FOLLOW_DEGREE, (followCloseDist + followMidDist) / 2, VectorPool.getVector())
		self.x_moveAside_targetPosList[3] = CalcUtils.getPosOnRayByYawDegree(tgtEnt:getPosition(), tgtEntYaw + AiConst.PET_FOLLOW_DEGREE, (followCloseDist + followMidDist) / 2, VectorPool.getVector())
	end

	return self.moveAbility:moveToPosList(nil, self.x_moveAside_targetPosList, AiConst.MOVE_CD, true, AiConst.TARGET_POINT_STOP_DIST, BaseEnum.SpeedRateType.Slow)
end

function IMoveComponent:checkIsCloseToFollowTarget(followTargetActorId)
	local master = pg.getEntityByActorId(followTargetActorId)

	if master ~= nil then
		local maxDistance = self:getBlackBoardProperty("followCloseDist") or 0.1
		local masterPos = master:getPosition()
		local myPos = self.ent:getPosition()

		return CalcUtils.checkInRange3D(masterPos, myPos, maxDistance + CalcUtils.getBodySizeBias(self.ent, master))
	end

	return false
end

function IMoveComponent:patrolInRange__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	if self.x_patrolInRange_targetPos then
		VectorPool.returnVector(self.x_patrolInRange_targetPos)

		self.x_patrolInRange_targetPos = nil
	end
end

function IMoveComponent:patrolInRange(patrolRange, speedRateType, speed)
	if self.x_patrolInRange_targetPos == nil then
		if patrolRange == nil or patrolRange < math_epsilon then
			patrolRange = self:getBlackBoardProperty("patrolRange")
		end

		if patrolRange < math_epsilon then
			return EBTStatus.BT_FAILURE
		end

		self.x_patrolInRange_targetPos = VectorPool.getVector(3, AIUtils.getGoHomePos(self.ent))
		self.x_patrolInRange_targetPos[1] = self.x_patrolInRange_targetPos[1] + math_random(-patrolRange * 100, patrolRange * 100) / 100
		self.x_patrolInRange_targetPos[3] = self.x_patrolInRange_targetPos[3] + math_random(-patrolRange * 100, patrolRange * 100) / 100
	end

	return self.moveAbility:moveToPos(self.x_patrolInRange_targetPos, AiConst.MOVE_CD, true, nil, speedRateType or BaseEnum.SpeedRateType.Slow, speed)
end

function IMoveComponent:patrolInRangeWithCenter__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	if (resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit) and self.x_patrolInRangeWithCenter_targetPos then
		VectorPool.returnVector(self.x_patrolInRangeWithCenter_targetPos)

		self.x_patrolInRangeWithCenter_targetPos = nil
	end
end

function IMoveComponent:patrolInRangeWithCenter(patrolRange, centerPos, speedRateType, speed)
	if self.x_patrolInRangeWithCenter_targetPos == nil then
		if patrolRange == nil or patrolRange < math_epsilon then
			patrolRange = self:getBlackBoardProperty("patrolRange")
		end

		if patrolRange < math_epsilon then
			return EBTStatus.BT_FAILURE
		end

		if type(centerPos) ~= "table" or #centerPos < 3 then
			return EBTStatus.BT_FAILURE
		end

		self.x_patrolInRangeWithCenter_targetPos = VectorPool.getVector(3, centerPos)
		self.x_patrolInRangeWithCenter_targetPos[1] = self.x_patrolInRangeWithCenter_targetPos[1] + math_random(-patrolRange * 100, patrolRange * 100) / 100
		self.x_patrolInRangeWithCenter_targetPos[3] = self.x_patrolInRangeWithCenter_targetPos[3] + math_random(-patrolRange * 100, patrolRange * 100) / 100
	end

	return self.moveAbility:moveToPos(self.x_patrolInRangeWithCenter_targetPos, AiConst.MOVE_CD, true, nil, speedRateType or BaseEnum.SpeedRateType.Slow, speed)
end

function IMoveComponent:patrolInHomeland__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	if (resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit) and self.x_patrolInHomeland_targetPos then
		VectorPool.returnVector(self.x_patrolInHomeland_targetPos)

		self.x_patrolInHomeland_targetPos = nil
	end
end

function IMoveComponent:patrolInHomeland(minPatrolRange, maxPatrolRange, speedRateType, speed)
	if not Utils.checkClient() then
		return EBTStatus.BT_FAILURE
	end

	if self.x_patrolInHomeland_targetPos == nil then
		local selfPos = self.ent:getPosition()
		local space = self.ent.space
		local isHomeland = Utils.isHomelandBySceneId(space.sceneId)
		local areaId

		if isHomeland then
			areaId = HomeLandUtils.getHomePetAreaId(space, self.ent.id, self.ent)

			if areaId == nil then
				return EBTStatus.BT_RUNNING
			end
		end

		self.x_patrolInHomeland_maxTime = AiConst.MOVE_CD
		self.x_patrolInHomeland_targetPos = VectorPool.getVector(3)
		self.x_patrolInHomeland_targetPos[1] = selfPos[1]
		self.x_patrolInHomeland_targetPos[2] = selfPos[2]
		self.x_patrolInHomeland_targetPos[3] = selfPos[3]

		if isHomeland then
			if not pg.game.home:checkPointLock(areaId, selfPos[1], selfPos[3]) then
				local dist = math_random(minPatrolRange * 100, maxPatrolRange * 100) / 100
				local rad = math_rad(math_random(0, 360))
				local dx = dist * math_cos(rad)
				local dz = dist * math_sin(rad)

				for i = 1, 4 do
					local x = selfPos[1] + dx * (i % 2 * 2 - 1)
					local y = selfPos[3] + dz * (3 - math_ceil(i / 2) * 2)

					if not pg.game.home:checkPointLock(areaId, x, y) then
						self.x_patrolInHomeland_targetPos[1] = x
						self.x_patrolInHomeland_targetPos[3] = y

						break
					end
				end
			else
				local ret, x, y = pg.game.home:getRandomUnlockPoint(areaId)

				if ret then
					self.x_patrolInHomeland_targetPos[1] = x
					self.x_patrolInHomeland_targetPos[3] = y

					local dx = selfPos[1] - x
					local dy = selfPos[3] - y
					local dist = math.sqrt(dx * dx + dy * dy)
					local walkSpeed = speed

					if not walkSpeed or walkSpeed <= 0 then
						walkSpeed = AIControllerUtils.getWalkSpeed(self.ent)
					end

					if walkSpeed > 0 then
						self.x_patrolInHomeland_maxTime = math.max(dist / walkSpeed + 5, self.x_patrolInHomeland_maxTime)
					end
				end
			end
		elseif Utils.isHomeCampBySceneId(space.sceneId) then
			local ret, x, y, z = VoxelUtils.findVoxelRandomPos(self.ent, selfPos, minPatrolRange, maxPatrolRange)

			if ret then
				self.x_patrolInHomeland_targetPos[1] = x
				self.x_patrolInHomeland_targetPos[2] = y
				self.x_patrolInHomeland_targetPos[3] = z
			else
				return EBTStatus.BT_FAILURE
			end
		else
			return EBTStatus.BT_FAILURE
		end
	end

	return self.moveAbility:moveToPos(self.x_patrolInHomeland_targetPos, self.x_patrolInHomeland_maxTime, true, nil, speedRateType or BaseEnum.SpeedRateType.Slow, speed)
end

function IMoveComponent:leaveTarget__resetState(resetStateType)
	if self.x_leaveTarget_targetPosList then
		local len = #self.x_leaveTarget_targetPosList

		for i = 1, len do
			VectorPool.returnVector(self.x_leaveTarget_targetPosList[i])

			self.x_leaveTarget_targetPosList[i] = nil
		end

		ListPool.returnList(self.x_leaveTarget_targetPosList)

		self.x_leaveTarget_targetPosList = nil
	end

	self:_removeCustomTimeout("leaveTarget_eachTimeout")
	self:_removeCustomTimeout("leaveTarget_timeout")
	self.moveAbility:resetMoveToPosList(resetStateType)

	if resetStateType == AiConst.ResetStateType.enter then
		AIControllerUtils.setSteeringDeceleration(self.ent, true, AiConst.DecelerationDisableReason.AIDefault)
	elseif resetStateType == AiConst.ResetStateType.exit then
		AIControllerUtils.setSteeringDeceleration(self.ent, false, AiConst.DecelerationDisableReason.AIDefault)
	end
end

function IMoveComponent._leaveTargetPosFiltFunc(ent, pos)
	local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(ent)

	if CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.LOCOMOTION) or CharacterStateConst.isChildOfState(tCurrentControllerState, CharacterStateConst.SNEAK) then
		return not AIControllerUtils.checkCanSwim(ent) and ent.agent:isPosOnWater(pos[1], pos[2], pos[3])
	end

	return false
end

function IMoveComponent:leaveTarget(tgtActorId, leaveDistance, speed, speedRateType, maxTime, leaveEachDistance, backDistance, minLeaveLeaveEachDistance)
	local tgt = pg.getEntityByActorId(tgtActorId)

	leaveDistance = leaveDistance or AiConst.MAX_LEAVE_DISTANCE
	leaveEachDistance = leaveEachDistance or AiConst.LEVEL_DISTANCE
	backDistance = backDistance or AiConst.LEVEL_BACK_DISTANCE
	minLeaveLeaveEachDistance = minLeaveLeaveEachDistance or AiConst.MIN_LEAVE_DISTANCE

	if tgt == nil or self:_isInPerceivedRangeTgt(tgt, 0, leaveDistance) == false then
		return EBTStatus.BT_SUCCESS
	end

	local me = self.ent
	local selfPos = me:getPosition()
	local isRepath = false

	if self.x_leaveTarget_targetPosList == nil or self:_checkAndSetCustomTimeout("leaveTarget_eachTimeout", AiConst.LEAVE_REPTAH_CD) then
		if self.x_leaveTarget_targetPosList == nil then
			self.x_leaveTarget_targetPosList = ListPool.getList()
		end

		local leaveDir = CalcUtils.getDirByEntity(tgt, me)

		self:_findDirectionTargetPosList(selfPos, leaveDir, leaveEachDistance, minLeaveLeaveEachDistance, backDistance, false, self.x_leaveTarget_targetPosList, IMoveComponent._leaveTargetPosFiltFunc)
		self:_removeCustomTimeout("leaveTarget_eachTimeout")

		isRepath = true
	end

	if not maxTime or maxTime < math_epsilon then
		maxTime = AiConst.MOVE_CD
	end

	if not self:_checkCustomTimeoutExist("leaveTarget_timeout") then
		self:_settingCustomTimeout("leaveTarget_timeout", maxTime)
	end

	if self:_checkCustomTimeout("leaveTarget_timeout") then
		return EBTStatus.BT_FAILURE
	end

	local ret = self.moveAbility:moveToPosList(false, self.x_leaveTarget_targetPosList, AiConst.MOVE_CD, true, AiConst.TARGET_POINT_STOP_DIST, speedRateType, speed, isRepath)

	if ret == EBTStatus.BT_SUCCESS then
		ret = EBTStatus.BT_RUNNING
	end

	return ret
end

function IMoveComponent:_isInPerceivedRangeTgt(tgtEnt, rangeMin, rangeMax, useTgtBodySize, useSelfBodySize)
	useTgtBodySize = useTgtBodySize or false
	useSelfBodySize = useSelfBodySize or false

	local ret = false
	local myPos = self.ent:getPosition()
	local isInPerceivedRange, entPos

	if not tgtEnt.isPerceptibilityResponse then
		entPos = self.ent:getPosition()
	else
		isInPerceivedRange, entPos = tgtEnt:getPerceivedPosition(self.ent.actorId)
	end

	local dist = Vector3.Distance(myPos, entPos) - CalcUtils.getBodySizeBias(self.ent, tgtEnt, useSelfBodySize, useTgtBodySize)

	if dist >= math_min(rangeMin, AiConst.AUTO_PATH_CLOSE_LEN) and dist <= rangeMax then
		ret = true
	end

	return ret
end

function IMoveComponent:leaveTargetInCatchFailure__resetState(resetStateType)
	if self.x_leaveTargetInCatchFailure_targetPosList then
		local len = #self.x_leaveTargetInCatchFailure_targetPosList

		for i = 1, len do
			VectorPool.returnVector(self.x_leaveTargetInCatchFailure_targetPosList[i])

			self.x_leaveTargetInCatchFailure_targetPosList[i] = nil
		end

		ListPool.returnList(self.x_leaveTargetInCatchFailure_targetPosList)

		self.x_leaveTargetInCatchFailure_targetPosList = nil
	end

	self:_removeCustomTimeout("leaveTargetInCatchFailure_eachTimeout")
	self:_removeCustomTimeout("leaveTargetInCatchFailure_timeout")

	if resetStateType == AiConst.ResetStateType.enter then
		AIControllerUtils.setSteeringDeceleration(self.ent, true, AiConst.DecelerationDisableReason.AIDefault)
	elseif resetStateType == AiConst.ResetStateType.exit then
		AIControllerUtils.setSteeringDeceleration(self.ent, false, AiConst.DecelerationDisableReason.AIDefault)
	end

	self.moveAbility:resetMoveToPosList(resetStateType, true)
end

function IMoveComponent:leaveTargetInCatchFailure(tgtActorId, leaveDistance, speed, speedRateType)
	local tgt = pg.getEntityByActorId(tgtActorId)

	leaveDistance = leaveDistance or AiConst.MAX_LEAVE_DISTANCE

	local leaveEachDistance = AiConst.LEVEL_DISTANCE
	local backDistance = AiConst.LEVEL_BACK_DISTANCE
	local minLeaveLeaveEachDistance = AiConst.MIN_LEAVE_DISTANCE

	if tgt == nil or self:_isInPerceivedRangeTgt(tgt, 0, leaveDistance) == false then
		return EBTStatus.BT_SUCCESS
	end

	local me = self.ent
	local selfPos = me:getPosition()
	local isRepath = false

	if self.x_leaveTargetInCatchFailure_targetPosList == nil or self:_checkAndSetCustomTimeout("leaveTargetInCatchFailure_eachTimeout", AiConst.LEAVE_REPTAH_CD) then
		if self.x_leaveTargetInCatchFailure_targetPosList == nil then
			self.x_leaveTargetInCatchFailure_targetPosList = ListPool.getList()
		end

		local leaveDir = CalcUtils.getDirByEntity(tgt, me)

		self:_findDirectionTargetPosList(selfPos, leaveDir, leaveEachDistance, minLeaveLeaveEachDistance, backDistance, false, self.x_leaveTargetInCatchFailure_targetPosList, IMoveComponent._leaveTargetPosFiltFunc)
		self:_removeCustomTimeout("leaveTargetInCatchFailure_eachTimeout")

		isRepath = true
	end

	local maxTime = self:getBlackBoardProperty("catchFailureLeaveTimeout")

	if not self:_checkCustomTimeoutExist("leaveTargetInCatchFailure_timeout") then
		self:_settingCustomTimeout("leaveTargetInCatchFailure_timeout", maxTime)
	end

	if self:_checkCustomTimeout("leaveTargetInCatchFailure_timeout") then
		return EBTStatus.BT_FAILURE
	end

	local ret = self.moveAbility:moveToPosList(false, self.x_leaveTargetInCatchFailure_targetPosList, AiConst.MOVE_CD, true, AiConst.TARGET_POINT_STOP_DIST, speedRateType, speed, isRepath)

	if ret == EBTStatus.BT_SUCCESS then
		ret = EBTStatus.BT_RUNNING
	end

	return ret
end

function IMoveComponent:checkIsInRangeAndSectorTgt(targetActorId, degreeMin, degreeMax, rangeMin, rangeMax, noTgtBodySize, noSelfBodySize)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt then
		local bodySizeBias = CalcUtils.getBodySizeBias(tgtEnt, self.ent, not noTgtBodySize, not noSelfBodySize)

		Vector3.enableCreateFromCache()

		local tgtDirection = tgtEnt:getRotation():Forward():Normalize()
		local myPos = self.ent:getPosition()
		local tgtPos = tgtEnt:getPosition()
		local result = CalcUtils.isPointInAnnularSector(tgtPos[1], tgtPos[3], tgtDirection[1], tgtDirection[3], myPos[1], myPos[3], rangeMin - bodySizeBias, rangeMax + bodySizeBias, degreeMin, degreeMax)

		Vector3.disableCreateFromCache()

		return result
	end

	return false
end

function IMoveComponent:checkIsInRangeTgt(targetId, rangeMin, rangeMax, noTgtBodySize, noSelfBodySize)
	local tgtEnt = pg.getEntityByActorId(targetId)

	if tgtEnt then
		local bodySizeBias = CalcUtils.getBodySizeBias(tgtEnt, self.ent, not noTgtBodySize, not noSelfBodySize)
		local myPos = self.ent:getPosition()
		local tgtPos = tgtEnt:getPosition()

		return CalcUtils.checkInRange3D(myPos, tgtPos, rangeMin - bodySizeBias, rangeMax + bodySizeBias)
	end

	return false
end

function IMoveComponent:checkIsInRangeTgt2D(targetActorId, rangeMin, rangeMax, noTgtBodySize, noSelfBodySize)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt then
		local bodySizeBias = CalcUtils.getBodySizeBias(tgtEnt, self.ent, not noTgtBodySize, not noSelfBodySize)
		local myPos = self.ent:getPosition()
		local tgtPos = tgtEnt:getPosition()

		return CalcUtils.checkInRange2D(myPos, tgtPos, rangeMin - bodySizeBias, rangeMax + bodySizeBias)
	end

	return false
end

function IMoveComponent:checkDistAndHeight(tgtId, dist, height, noTgtBodySize, noSelfBodySize, absHeight)
	height = -height

	local tgtEnt = pg.getEntityByActorId(tgtId)

	if tgtEnt then
		local bodySizeBias = CalcUtils.getBodySizeBias(tgtEnt, self.ent, not noTgtBodySize, not noSelfBodySize)
		local myPos = self.ent:getPosition()
		local tgtPos = tgtEnt:getPosition()

		if CalcUtils.checkInRange2D(myPos, tgtPos, 0, dist + bodySizeBias) then
			local myPosY = not absHeight and myPos[2] + height / 2 or myPos[2]

			return math_abs(tgtPos[2] - myPosY) <= math_abs(height / 2)
		end
	end

	return false
end

function IMoveComponent:getDistByTgt(tgtId, noTgtBodySize, noSelfBodySize, referenceTargetActorId)
	if not referenceTargetActorId or referenceTargetActorId == 0 then
		referenceTargetActorId = self.ent.actorId
	end

	local referenceTargetEnt = pg.getEntityByActorId(referenceTargetActorId)
	local targetEnt = pg.getEntityByActorId(tgtId)
	local ret = 9999

	if targetEnt ~= nil and referenceTargetEnt ~= nil then
		local entPos = targetEnt:getPosition()
		local referenceTargetEntPos = referenceTargetEnt:getPosition()
		local bodySizeBias = CalcUtils.getBodySizeBias(targetEnt, referenceTargetEnt, not noTgtBodySize, not noSelfBodySize)

		ret = math_max(Vector3.Distance(referenceTargetEntPos, entPos) - bodySizeBias, 0)
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.ent.logger:info("该entity不存在：%d,%d,自己的actorId:%d", tgtId, referenceTargetActorId, self.ent.actorId)
	end

	return ret
end

function IMoveComponent:getDistByPos(pos, noBodySize, actorId)
	local targetEnt = actorId and pg.getEntityByActorId(actorId) or self.ent
	local myPos = targetEnt:getPosition()
	local bodySizeBias = CalcUtils.getBodySizeBias(self.ent, nil, not noBodySize, false)

	return math_max(Vector3.Distance(myPos, pos) - bodySizeBias, 0)
end

function IMoveComponent:sideWalk__resetState(resetStateType)
	if self.x_sideWalk_pos then
		VectorPool.returnVector(self.x_sideWalk_pos)

		self.x_sideWalk_pos = nil
	end

	self.x_sideWalk_state = nil

	if self.x_sideWalk_RandomPos then
		VectorPool.returnVector(self.x_sideWalk_RandomPos)

		self.x_sideWalk_RandomPos = nil
	end

	self:_removeCustomTimeout("sideWalk")
	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:sideWalk(targetActorId, maxTime, degree, dist, forceToEnterCombatPos)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self:_checkAndSetCustomTimeout("sideWalk", maxTime) then
		return EBTStatus.BT_FAILURE
	end

	self:faceToPos(tgtEnt:getPosition())

	if not self.x_sideWalk_pos then
		degree = degree or 0

		local selfPos = self.ent:getPosition()
		local targetPos = tgtEnt:getPosition()

		if dist == nil or dist <= 0 then
			dist = Vector3.Distance(targetPos, selfPos)
		end

		dist = math_max(dist, CalcUtils.getBodySizeBias(tgtEnt, self.ent))
		self.x_sideWalk_pos = VectorPool.getVector()

		CalcUtils.getPosByLinkAngle(targetPos, selfPos, degree, dist, self.x_sideWalk_pos)

		if forceToEnterCombatPos then
			local enterCombatPosition = tgtEnt.enterCombatPosition or self.ent.enterCombatPosition

			if enterCombatPosition then
				Vector3.enableCreateFromCache()

				local entToTarget = targetPos - selfPos
				local entToCenter = enterCombatPosition - selfPos
				local entToSideWalk = self.x_sideWalk_pos - selfPos
				local cross = entToCenter[3] * entToTarget[1] - entToCenter[1] * entToTarget[3]
				local cross2 = entToSideWalk[3] * entToTarget[1] - entToSideWalk[1] * entToTarget[3]

				if cross * cross2 < 0 then
					entToTarget[2] = 0

					local x, y, z = CalcUtils.getMirrorPoint(self.x_sideWalk_pos, selfPos, entToTarget:SetNormalize())

					self.x_sideWalk_pos[1] = x
					self.x_sideWalk_pos[2] = y
					self.x_sideWalk_pos[3] = z
				end

				Vector3.disableCreateFromCache()
			end
		end

		self.x_sideWalk_state = 1
	end

	if self.x_sideWalk_state == 1 then
		local ret, x, y, z = VoxelUtils.findVoxelRandomPos(self.ent, self.x_sideWalk_pos, 0, AiConst.NAVMESH_RANDOM_RADIUS)

		if ret then
			self.x_sideWalk_RandomPos = VectorPool.getVector()
			self.x_sideWalk_RandomPos[1] = x
			self.x_sideWalk_RandomPos[2] = y
			self.x_sideWalk_RandomPos[3] = z
			self.x_sideWalk_state = 2
		else
			return EBTStatus.BT_FAILURE
		end
	end

	return self.moveAbility:moveToPos(self.x_sideWalk_RandomPos, maxTime, false, nil, BaseEnum.SpeedRateType.Slow, AIControllerUtils.getSideWalkSpeed(self.ent))
end

function IMoveComponent:_getGoBackPos(tgtActorId, backDist, refTable)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)
	local dirDegree = math_deg(CalcUtils.getYawByPos(tgtEnt:getPosition(), self.ent:getPosition()))

	CalcUtils.getPosOnRayByYawDegree(tgtEnt:getPosition(), dirDegree, backDist + CalcUtils.getBodySizeBias(tgtEnt, self.ent), refTable)
end

function IMoveComponent:isGoBackCd()
	return self.ent:getCurrScaledTime() < self:getBlackBoardProperty("goBackNextCdTime")
end

function IMoveComponent:walkBack__resetState(resetStateType)
	if self.x_walkBackPos then
		VectorPool.returnVector(self.x_walkBackPos)

		self.x_walkBackPos = nil
	end

	self:_removeCustomTimeout("walkBack")
	self:_removeCustomTimeout("keepDistTime")
	self.moveAbility:resetMoveToPos(resetStateType)

	if resetStateType == AiConst.ResetStateType.enter then
		local goBackNextCdTime = self.ent:getCurrScaledTime() + (self:getBlackBoardProperty("walkBackCd") or AiConst.WALK_BACK_CD)

		self:setBlackBoardProperty("goBackNextCdTime", goBackNextCdTime)
	end
end

function IMoveComponent:walkBack(tgtActorId, stopDist, maxTime, keepDistTime)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	if not self:getBlackBoardProperty("canWalkBack") or tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self:_checkAndSetCustomTimeout("walkBack", maxTime) then
		return EBTStatus.BT_FAILURE
	end

	local isRepath = false

	if self.x_walkBackPos == nil or self:_checkCustomTimeout("keepDistTime") then
		if self.x_walkBackPos then
			VectorPool.returnVector(self.x_walkBackPos)
		end

		self.x_walkBackPos = VectorPool.getVector()

		self:_getGoBackPos(tgtActorId, stopDist, self.x_walkBackPos)
		self:_settingCustomTimeout("keepDistTime", keepDistTime)

		isRepath = true
	end

	self:faceToPos(tgtEnt:getPosition())

	return self.moveAbility:moveToPos(self.x_walkBackPos, maxTime, false, nil, BaseEnum.SpeedRateType.Slow, AIControllerUtils.getWalkBackSpeed(self.ent), nil, isRepath)
end

function IMoveComponent:runBack__resetState(resetStateType)
	if self.x_runBackPos then
		VectorPool.returnVector(self.x_runBackPos)

		self.x_runBackPos = nil
	end

	self:_removeCustomTimeout("runBack")
	self:_removeCustomTimeout("keepDistTime")
	self.moveAbility:resetMoveToPos(resetStateType)

	if resetStateType == AiConst.ResetStateType.enter then
		local goBackNextCdTime = self.ent:getCurrScaledTime() + (self:getBlackBoardProperty("walkBackCd") or AiConst.WALK_BACK_CD)

		self:setBlackBoardProperty("goBackNextCdTime", goBackNextCdTime)
	end
end

function IMoveComponent:runBack(tgtActorId, backDist, maxTime, keepDistTime)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self:_checkAndSetCustomTimeout("runBack", maxTime) then
		return EBTStatus.BT_FAILURE
	end

	if self.x_runBackPos == nil or self:_checkCustomTimeout("keepDistTime") then
		if self.x_runBackPos then
			VectorPool.returnVector(self.x_runBackPos)
		end

		self.x_runBackPos = VectorPool.getVector()

		self:_getGoBackPos(tgtActorId, backDist, self.x_runBackPos)
		self:_settingCustomTimeout("keepDistTime", keepDistTime)
	end

	return self.moveAbility:moveToPos(self.x_runBackPos, maxTime, true, nil, BaseEnum.SpeedRateType.Mid)
end

function IMoveComponent:jumpBackByLinkAngle__resetState(resetStateType)
	self:_removeCustomTimeout("jumpBackByLinkAngle")

	if resetStateType == AiConst.ResetStateType.exit then
		AIBaseMethodUtils.Base_StopAnimation(self.ent, PlayableConst.JumpBack, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end
end

function IMoveComponent:jumpBackByLinkAngle(targetActorId, degree, dist, syncPointEnum, ifLimitJumpDist, jumpDistLimit)
	local target = pg.getEntityByActorId(targetActorId)

	if target == nil or not self:getBlackBoardProperty("canJumpBack") then
		return EBTStatus.BT_FAILURE
	end

	if not self:_checkCustomTimeoutExist("jumpBackByLinkAngle") then
		Vector3.enableCreateFromCache()

		local targetPos = Vector3.New()

		CalcUtils.getPosByLinkAngle(target:getPosition(), self.ent:getPosition(), degree, dist + CalcUtils.getBodySizeBias(self.ent, target), targetPos)

		ifLimitJumpDist = ifLimitJumpDist or false
		jumpDistLimit = jumpDistLimit or AiConst.DEFAULT_JUMP_MAX_DIST

		if ifLimitJumpDist then
			local selfPos = self.ent:getPosition()
			local distance = Vector3.Distance(selfPos, targetPos)

			if jumpDistLimit < distance then
				distance = math_max(jumpDistLimit, 0)
				targetPos = selfPos + Vector3.Normalize(targetPos - selfPos) * distance
			end
		end

		local pos = target:getPosition():Clone()
		local targetDirection = pos:Sub(targetPos)
		local targetRotation = Quaternion.LookRotation(targetDirection)
		local jumpBackByLinkAngleTimeout = AIBaseMethodUtils.Base_ChangeToRootMotion(self.ent, PlayableConst.JumpBack, targetPos, targetRotation, false, syncPointEnum)

		self:_settingCustomTimeout("jumpBackByLinkAngle", jumpBackByLinkAngleTimeout)

		local goBackNextCdTime = self.ent:getCurrScaledTime() + (self:getBlackBoardProperty("walkBackCd") or AiConst.WALK_BACK_CD)

		self:setBlackBoardProperty("goBackNextCdTime", goBackNextCdTime)
		Vector3.disableCreateFromCache()
	end

	if self:_checkAndRemoveCustomTimeout("jumpBackByLinkAngle") then
		return EBTStatus.BT_SUCCESS
	end

	return EBTStatus.BT_RUNNING
end

function IMoveComponent:dashToTarget__resetState(resetStateType)
	self.x_dashToTarget_yaw = nil
end

function IMoveComponent:dashToTarget(targetActorId, deltaYawDegree)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if targetEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if self.x_dashToTarget_yaw == nil then
		local pos = targetEnt:getPosition()
		local myPos = self.ent:getPosition()
		local tgtYaw = math_atan2(pos[1] - myPos[1], pos[3] - myPos[3])

		self.x_dashToTarget_yaw = math_deg(tgtYaw) + deltaYawDegree

		AIBaseMethodUtils.Base_SetYawDegrees(self.ent, self.x_dashToTarget_yaw, true)
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.DASH)

		return EBTStatus.BT_RUNNING
	end

	local currentState = AIControllerUtils.getCurrentAnimationState(self.ent)

	if currentState == CharacterStateConst.DASH or currentState == CharacterStateConst.DASHSTOP then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IMoveComponent:dash__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.exit then
		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.IDLE)
	end

	self.x_dash_flag = nil
end

function IMoveComponent:dash()
	if self.x_dash_flag == nil then
		self.x_dash_flag = true

		AIBaseMethodUtils.Base_PlayAnimationState(self.ent, CharacterStateConst.DASH)

		return EBTStatus.BT_RUNNING
	end

	local currentState = AIControllerUtils.getCurrentAnimationState(self.ent)

	if currentState == CharacterStateConst.DASH or currentState == CharacterStateConst.DASHSTOP then
		return EBTStatus.BT_RUNNING
	end

	return EBTStatus.BT_SUCCESS
end

function IMoveComponent:combatMoveAround__resetState(resetStateType)
	self:_removeCustomTimeout("combatMoveAround_timeout")
	self:_removeCustomTimeout("combatMoveAround_repath")

	if self.x_combatMoveAround_targetPos then
		VectorPool.returnVector(self.x_combatMoveAround_targetPos)

		self.x_combatMoveAround_targetPos = nil
	end

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IMoveComponent:combatMoveAround(tgtActorId, speed, speedRateType, timeout, faceToTarget)
	local targetEnt = pg.getEntityByActorId(tgtActorId)

	if not targetEnt then
		return EBTStatus.BT_FAILURE
	end

	if not self:_checkCustomTimeoutExist("combatMoveAround_timeout") then
		self:_settingCustomTimeout("combatMoveAround_timeout", timeout)
	end

	if self:_checkCustomTimeout("combatMoveAround_timeout") then
		return EBTStatus.BT_SUCCESS
	end

	local isRepath = false

	if self:_checkCustomTimeout("combatMoveAround_repath") then
		local stopDist = self:getBlackBoardProperty("attackStopBoxDist") + CalcUtils.getBodySizeBias(targetEnt, self.ent, true, true)
		local targetPos = targetEnt:getPosition()
		local center = targetEnt.enterCombatPosition

		self.x_combatMoveAround_targetPos = VectorPool.getVector(3, center)

		if Vector3.SqrDistance(targetPos, center) < AbilitySettingGlobalConstData.petDashMoveDis * AbilitySettingGlobalConstData.petDashMoveDis then
			return EBTStatus.BT_SUCCESS
		end

		Vector3.enableCreateFromCache()
		self.x_combatMoveAround_targetPos:Copy((center - targetPos):SetNormalize():Mul(stopDist):Add(targetPos))
		Vector3.disableCreateFromCache()

		if self:_checkCustomTimeoutExist("combatMoveAround_repath") then
			isRepath = true
		end

		self:_settingCustomTimeout("combatMoveAround_repath", AiConst.PET_MOVE_REPATH_CD)
	end

	if faceToTarget then
		self:faceToPos(targetEnt:getPosition())
	end

	return self.moveAbility:moveToPos(self.x_combatMoveAround_targetPos, timeout, not faceToTarget, 0, speedRateType, speed, nil, isRepath)
end

function IMoveComponent:moveToAppointedArea__resetState(resetStateType)
	self.x_moveToAppointedArea_areaData = nil

	if self.x_moveToAppointedArea_targetPosList then
		for i = 1, #self.x_moveToAppointedArea_targetPosList do
			VectorPool.returnVector(self.x_moveToAppointedArea_targetPosList[i])
		end

		ListPool.returnList(self.x_moveToAppointedArea_targetPosList, 2)

		self.x_moveToAppointedArea_targetPosList = nil
	end

	self.moveAbility:resetMoveToPosList(resetStateType)
end

function IMoveComponent:moveToAppointedArea(tgtId, appointedAreaId, checkAppointedAreaId)
	local tgtEnt = pg.getEntityByActorId(tgtId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	local areaData = AIAreaData[appointedAreaId]

	if not self.x_moveToAppointedArea_targetPosList then
		self.x_moveToAppointedArea_targetPosList = ListPool.getList(2)
	end

	local isRepath = self.moveAbility:movementSelectMovePosList(tgtEnt, areaData, self.x_moveToAppointedArea_targetPosList)
	local speed, speedRate = self.moveAbility:movementGetMovementInfo(tgtEnt, areaData)
	local ret = self.moveAbility:moveToPosList(nil, self.x_moveToAppointedArea_targetPosList, AiConst.FOLLOW_CD, true, AiConst.TARGET_POINT_STOP_DIST, speedRate, speed, isRepath, nil, true, AutoPathFindUtils.PathFindType.Physics)

	if ret ~= EBTStatus.BT_RUNNING and self:checkStartMoveToAppointedArea(tgtId, checkAppointedAreaId) then
		return EBTStatus.BT_RUNNING
	end

	return ret
end

function IMoveComponent:checkStartMoveToAppointedArea(tgtId, checkAppointedAreaId)
	local tgtEnt = pg.getEntityByActorId(tgtId)

	if tgtEnt == nil then
		return false
	end

	return self.moveAbility:movementCheckAIStartArea(tgtEnt, checkAppointedAreaId)
end

function IMoveComponent:moveAroundTarget__resetState(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter then
		self.x_moveAroundTarget_posList = ListPool.getList(2)
		self.x_moveAroundTarget_endPosList = ListPool.getList(2)

		for i = 1, AiConst.MOVE_AROUND_POS_NUM do
			self.x_moveAroundTarget_posList[i] = VectorPool.getVector()
		end
	elseif resetStateType == AiConst.ResetStateType.exit then
		if self.x_moveAroundTarget_endPosList then
			ListPool.returnList(self.x_moveAroundTarget_endPosList, 2)

			self.x_moveAroundTarget_endPosList = nil
		end

		if self.x_moveAroundTarget_posList then
			for i = 1, AiConst.MOVE_AROUND_POS_NUM do
				VectorPool.returnVector(self.x_moveAroundTarget_posList[i])
			end

			ListPool.returnList(self.x_moveAroundTarget_posList, 2)

			self.x_moveAroundTarget_posList = nil
		end
	end

	self.moveAbility:resetMoveToPosList(resetStateType)
	self:_removeCustomTimeout("moveAroundTarget_timeout")
	self:_removeCustomTimeout("moveAroundTarget_repath")
end

function IMoveComponent:moveAroundTarget(targetActorId, radius, speed, speedRateType, clockwise, timeout)
	timeout = CalcUtils.getValidPositiveValue(timeout, AiConst.MOVE_CD)

	if not self:_checkCustomTimeoutExist("moveAroundTarget_timeout") then
		self:_settingCustomTimeout("moveAroundTarget_timeout", timeout)
	end

	if self:_checkCustomTimeout("moveAroundTarget_timeout") then
		return EBTStatus.BT_SUCCESS
	end

	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return EBTStatus.BT_FAILURE
	end

	local isRepath = false

	if self:_checkCustomTimeout("moveAroundTarget_repath") then
		isRepath = self:_checkCustomTimeoutExist("moveAroundTarget_repath")

		self:_settingCustomTimeout("moveAroundTarget_repath", AiConst.DEFAULT_REPATH_CD)

		local sign = clockwise and -1 or 1
		local center = targetEnt:getPosition()
		local selfPos = self.ent:getPosition()
		local dist = Vector3.Distance(center, selfPos)
		local dirX = CalcUtils.getHoriDirection(center, selfPos)
		local dirY = Vector3(-dirX[3], dirX[2], dirX[1])
		local angle, sin, cos, r
		local deltaDist = (radius - dist) / AiConst.MOVE_AROUND_FADE_POS_NUM

		for i = 1, AiConst.MOVE_AROUND_POS_NUM do
			angle = i * AiConst.MOVE_AROUND_POS_DELTA_ANGLE
			sin = CalcUtils.quickSin(angle) * sign
			cos = CalcUtils.quickCos(angle)
			r = i < AiConst.MOVE_AROUND_FADE_POS_NUM and dist + deltaDist * i or radius
			self.x_moveAroundTarget_posList[i][1] = center[1] + (dirX[1] * cos + dirY[1] * sin) * r
			self.x_moveAroundTarget_posList[i][2] = center[2]
			self.x_moveAroundTarget_posList[i][3] = center[3] + (dirX[3] * cos + dirY[3] * sin) * r
		end

		self.x_moveAroundTarget_endPosList[1] = self.x_moveAroundTarget_posList[AiConst.MOVE_AROUND_POS_NUM]

		if isRepath then
			AutoPathFindUtils.clearPath(self.ent)
		end

		self.moveAbility:moveToPosList(self.x_moveAroundTarget_posList, self.x_moveAroundTarget_endPosList, AiConst.MOVE_CD, true, AiConst.TARGET_POINT_STOP_DIST, speedRateType, speed, isRepath, nil, nil, AutoPathFindUtils.PathFindType.ForceMove)
	end

	return EBTStatus.BT_RUNNING
end

function IMoveComponent:checkCanMoveToTarget(targetActorId, stopDist)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return false
	end

	local targetEntPos = targetEnt:getPosition()

	return AutoPathFindUtils.findPathToPos(self.ent, targetEntPos[1], targetEntPos[2], targetEntPos[3], stopDist, AutoPathFindUtils.PathFindType.Auto)
end

function IMoveComponent:checkInViewport(targetActorId)
	if Utils.checkClient() then
		local targetEnt = pg.getEntityByActorId(targetActorId)

		if targetEnt then
			local targetEntPos = VectorPool.getVector(3, targetEnt:getPosition())

			targetEntPos[2] = targetEntPos[2] + targetEnt:getRealHeight() * 0.5

			local ret = pg.game.camera:checkInViewport(targetEntPos)

			VectorPool.returnVector(targetEntPos)

			return ret
		end
	end

	return true
end

function IMoveComponent:calcQualifiedPosByTarget__resetState(resetStateType)
	self.x_calcQualifiedPos_step = nil

	if resetStateType == AiConst.ResetStateType.exit then
		self.envQueryAbility:stopCalcQualifiedPos()
	end
end

function IMoveComponent:calcQualifiedPosByTarget(targetActorId, rangeMin, rangeMax, queryType, simpleNum, unobstructedActorId, outOfWater, findPath)
	local targetEnt = targetActorId == 0 and self.ent or pg.getEntityByActorId(targetActorId)

	if not self.x_calcQualifiedPos_step then
		self.x_calcQualifiedPos_step = 1

		self.envQueryAbility:startCalcQualifiedPos(targetEnt:getPosition(), rangeMin, rangeMax, queryType, simpleNum)
	end

	local oneTickStepNum = 4

	while not self.envQueryAbility:isCalcQualifiedPosFinished(self.x_calcQualifiedPos_step) and oneTickStepNum > 0 do
		self.envQueryAbility:oneStepCheckQualifiedPos(self.x_calcQualifiedPos_step, unobstructedActorId, outOfWater, findPath)

		self.x_calcQualifiedPos_step = self.x_calcQualifiedPos_step + 1
		oneTickStepNum = oneTickStepNum - 1
	end

	if self.envQueryAbility:isCalcQualifiedPosFinished(self.x_calcQualifiedPos_step) then
		return self.envQueryAbility:hasCalcQualifiedFilterQueryPos() and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
	end

	return EBTStatus.BT_RUNNING
end

function IMoveComponent:moveToQualifiedPos__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	self.x_moveToQualifiedPos_targetPos = nil
end

function IMoveComponent:moveToQualifiedPos(targetActorId, maxTime, stopDist, speedRateType, faceToPos)
	if not self.x_moveToQualifiedPos_targetPos then
		self.x_moveToQualifiedPos_targetPos = self.envQueryAbility:queryBestPosByTarget(targetActorId)
	end

	return self.moveAbility:moveToPos(self.x_moveToQualifiedPos_targetPos, maxTime, faceToPos, stopDist, speedRateType)
end

function IMoveComponent:moveToQualifiedPosAwayFromTeammates__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)
	VectorPool.returnVector(self.x_qualifiedPosAwayFromTeammates_targetPos)

	self.x_qualifiedPosAwayFromTeammates_targetPos = nil
end

function IMoveComponent:moveToQualifiedPosAwayFromTeammates(bossActorId, dangerRadius, splitSegment, circleNum, maxTime, stopDist, speedRateType, faceToPos)
	if not self.x_qualifiedPosAwayFromTeammates_targetPos then
		local bossEnt = pg.getEntityByActorId(bossActorId)

		if not bossEnt then
			return EBTStatus.BT_FAILURE
		end

		local center = bossEnt.bornPosition

		if not center then
			return EBTStatus.BT_FAILURE
		end

		local battleFieldRadius = AiConst.BattleFieldRadius

		splitSegment = splitSegment or 12
		circleNum = circleNum or 2

		if dangerRadius == nil or splitSegment <= 0 or circleNum <= 0 then
			return EBTStatus.BT_FAILURE
		end

		local teamMemberEntIdList = Utils.getTeamMemberEntIdWithBot(pg.me) or AiConst.DefaultNullTable
		local teammatePetEntList = ListPool.getList(1)
		local selfId = self.ent.id

		for i = 1, #teamMemberEntIdList do
			local teammateEnt = pg.getEntity(teamMemberEntIdList[i])
			local teammatePetEnt = teammateEnt and teammateEnt:getCurPetEntity()

			if teammatePetEnt and teammatePetEnt.id ~= selfId then
				teammatePetEntList[#teammatePetEntList + 1] = teammatePetEnt
			end
		end

		local selfPosition = self.ent:getPosition()

		Vector3.enableCreateFromCache()

		local forceVectorTeammate = VectorPool.getVector()

		for i = 1, #teammatePetEntList do
			local teammatePetEnt = teammatePetEntList[i]
			local v = selfPosition - teammatePetEnt:getPosition()

			forceVectorTeammate:Add(v)
		end

		local segmentAngle = 360 / splitSegment

		if forceVectorTeammate.x < 0 then
			segmentAngle = -segmentAngle
		end

		local startVec = Vector3.Normalize(center - selfPosition)
		local outerCircleR = battleFieldRadius * 0.9
		local currPos = selfPosition
		local isFindedTargetPos = false

		for i = 1, splitSegment do
			local rX, rZ = CalcUtils.rotationVector(startVec[1], startVec[3], segmentAngle * (i - 1))
			local rotatedVector = Vector3(rX, 0, rZ)

			for j = 1, circleNum do
				currPos = center + rotatedVector * ((circleNum - j + 1) / circleNum) * outerCircleR

				local isSafe = true

				for k = 1, #teammatePetEntList do
					local teammatePetEnt = teammatePetEntList[k]
					local sqrDisWithTeammate = Vector3.SqrDistance(currPos, teammatePetEnt:getPosition())

					if sqrDisWithTeammate <= dangerRadius * dangerRadius then
						isSafe = false

						break
					end
				end

				if isSafe then
					isFindedTargetPos = true

					break
				end
			end

			if isFindedTargetPos then
				break
			end
		end

		local targetPos = VectorPool.getVector(3, currPos)

		VectorPool.returnVector(forceVectorTeammate)
		ListPool.returnList(teammatePetEntList, 1)
		Vector3.disableCreateFromCache()

		self.x_qualifiedPosAwayFromTeammates_targetPos = targetPos
	end

	return self.moveAbility:moveToPos(self.x_qualifiedPosAwayFromTeammates_targetPos, maxTime, faceToPos, stopDist, speedRateType)
end

function IMoveComponent:getVerticalDis(targetActorId1, targetActorId2)
	local targetEnt = targetActorId1 == 0 and self.ent or pg.getEntityByActorId(targetActorId1)
	local targetEnt2 = targetActorId2 == 0 and self.ent or pg.getEntityByActorId(targetActorId2)

	if targetEnt and targetEnt2 then
		return targetEnt:getPosition()[2] - targetEnt2:getPosition()[2]
	end

	return 0
end

function IMoveComponent:checkTargetBlocked(targetActorId1, targetActorId2)
	targetActorId1 = targetActorId1 == 0 and self.ent.actorId or targetActorId1
	targetActorId2 = targetActorId2 == 0 and self.ent.actorId or targetActorId2

	return PhysicsUtils.checkTargetBlocked(targetActorId1, targetActorId2)
end

function IMoveComponent:judgeSpeedRateTypeByTarget(targetActorId, slow, mid, default)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if not tgtEnt then
		return default
	end

	if Utils.isPlayer(tgtEnt) and tgtEnt:isControllingPet() then
		tgtEnt = tgtEnt:getCurPetEntity()
	end

	local targetEntVelocity = tgtEnt:getVelocity()
	local targetEntSpeed = targetEntVelocity:Magnitude()

	if mid < targetEntSpeed then
		return BaseEnum.SpeedRateType.Fast
	elseif slow < targetEntSpeed then
		return BaseEnum.SpeedRateType.Fast
	else
		return BaseEnum.SpeedRateType.Slow
	end
end

function IMoveComponent:followTargetByRelativePos__resetState(resetStateType)
	self.moveAbility:resetFollowTargetByRelativePos(resetStateType)
end

function IMoveComponent:followTargetByRelativePos(targetActorId, maxTime, stopDist, relativeX, relativeY, relativeZ, walkDist, sprintDist)
	return self.moveAbility:followTargetByRelativePos(targetActorId, maxTime, stopDist, relativeX, relativeY, relativeZ, walkDist, sprintDist)
end

return IMoveComponent
