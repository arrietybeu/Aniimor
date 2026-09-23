-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIMoveAbility.lua

local Class = require("Core.Framework.Class")
local AIBaseAbility = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIBaseAbility")
local enums = require("Common.AI.Behaviac.Enums")
local Utils = require("Common.Utils.Utils")
local CalcUtils = require("Common.Utils.CalcUtils")
local AiConst = require("Common.Const.AiConst")
local MovementConst = AiConst.MovementConst
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local PlayableConst = require("Common.Const.PlayableConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AIMoveAbility")
local lume = require("Core.Common.lume")
local AIStartAppointedAreaData = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIStartAppointedAreaData")
local AIAppointedAreaFunc = require("Common.AI.BehaviacAgent.Unit.AIAbility.AIAppointedAreaFunc")
local AIBaseMethodUtils = require("Common.AI.BehaviacAgent.Unit.AIBaseMethodUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local VectorPool = require("Common.Container.VectorPool")
local Vector3 = Vector3
local Quaternion = Quaternion
local pg = pg
local EBTStatus = enums.EBTStatus
local AIMoveAbility = Class.LiteClass("AIMoveAbility", AIBaseAbility)

function AIMoveAbility:resetMoveToPos(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter then
		self:_removeCustomTimeout("ns_moveToPos")
		self:_removeCustomTimeout("ns_moveToPos_waitNSPathFind")

		if self.x_moveToPos_LastEndPos == nil then
			self.x_moveToPos_LastEndPos = VectorPool.getVector(3)
		end

		self.x_lastMoveAnimSpeedRateType = nil
		self.x_lastMoveAnimReplaceAnimation = nil
		self.x_lastMoveAnimSpeed = nil
		self.x_lastMoveAnimPathFindId = nil
	elseif resetStateType == AiConst.ResetStateType.exit then
		VectorPool.returnVector(self.x_moveToPos_LastEndPos)

		self.x_moveToPos_LastEndPos = nil

		self:_removeCustomTimeout("ns_moveToPos")
		self:_removeCustomTimeout("ns_moveToPos_waitNSPathFind")

		self.x_lastMoveAnimSpeedRateType = nil
		self.x_lastMoveAnimReplaceAnimation = nil
		self.x_lastMoveAnimSpeed = nil
		self.x_lastMoveAnimPathFindId = nil
	end

	AutoPathFindUtils.stopAutoPathFind(self.ent)
end

function AIMoveAbility:moveToPos(endPos, maxTime, faceToPos, stopDist, speedRateType, speed, pathFindType, isRepath, useAccurateArrive, replaceAnimation)
	local ret = EBTStatus.BT_RUNNING

	if self:_checkCustomTimeoutExist("ns_moveToPos") then
		if isRepath and Utils.tableIsValidVector3(endPos) and Vector3.SqrDistance(self.x_moveToPos_LastEndPos, endPos) > AiConst.FOLLOW_SAME_POS_SQR_DELTA then
			if not useAccurateArrive then
				stopDist = CalcUtils.getValidPositiveValue(stopDist, AiConst.TARGET_POINT_STOP_DIST)
			end

			AutoPathFindUtils.startAutoPathFind(self.ent, endPos, pathFindType, stopDist, true, false, useAccurateArrive)
			Vector3.Copy(self.x_moveToPos_LastEndPos, endPos)
			self:_settingCustomTimeout("ns_moveToPos_waitNSPathFind", AiConst.NAVMESH_SERVICE_DEFAULIT_TIME)
			self:_settingCustomTimeout("ns_moveToPos", CalcUtils.getValidPositiveValue(maxTime, AiConst.MOVE_CD))
		end

		if self:_checkCustomTimeout("ns_moveToPos") then
			ret = EBTStatus.BT_FAILURE
		else
			local isPathFinding, isWaitAsync = AutoPathFindUtils.getPathFindingFlags(self.ent)

			if isWaitAsync and self:_checkCustomTimeout("ns_moveToPos_waitNSPathFind") then
				ret = EBTStatus.BT_FAILURE
			elseif not isPathFinding then
				ret = AutoPathFindUtils.reachEndPosition(self.ent) and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
			else
				ret = EBTStatus.BT_RUNNING

				self:_handleMoveAnimation(speedRateType, speed, replaceAnimation)
			end
		end
	elseif not Utils.tableIsValidVector3(endPos) then
		ret = EBTStatus.BT_FAILURE
	else
		stopDist = useAccurateArrive and AiConst.FOLLOW_SAME_POS_SQR_DELTA or CalcUtils.getValidPositiveValue(stopDist, AiConst.TARGET_POINT_STOP_DIST)

		local myPos = self.ent:getPosition()

		if Vector3.SqrDistance(endPos, myPos) < stopDist * stopDist then
			ret = EBTStatus.BT_SUCCESS
		else
			AutoPathFindUtils.setFaceToPos(self.ent, faceToPos)
			self:_settingCustomTimeout("ns_moveToPos", CalcUtils.getValidPositiveValue(maxTime, AiConst.MOVE_CD))
			self:_settingCustomTimeout("ns_moveToPos_waitNSPathFind", AiConst.NAVMESH_SERVICE_DEFAULIT_TIME)
			AutoPathFindUtils.startAutoPathFind(self.ent, endPos, pathFindType, stopDist, nil, nil, useAccurateArrive)
			Vector3.Copy(self.x_moveToPos_LastEndPos, endPos)
			self:_handleMoveAnimation(speedRateType, speed, replaceAnimation)

			if pathFindType == AutoPathFindUtils.PathFindType.ForceMove then
				AutoPathFindUtils.addPathFindPoint(self.ent, endPos, true)
			end

			ret = EBTStatus.BT_RUNNING
		end
	end

	return ret
end

function AIMoveAbility:_handleMoveAnimation(speedRateType, speed, replaceAnimation)
	local tCurrentControllerState = AIControllerUtils.getCurrentAnimationState(self.ent)

	if CharacterStateConst.isMidTransitionState(tCurrentControllerState) then
		return
	end

	local currentPathFindId = AutoPathFindUtils.getCurrentPathFindId(self.ent)

	if self.x_lastMoveAnimPathFindId ~= currentPathFindId then
		self.x_lastMoveAnimSpeedRateType = nil
		self.x_lastMoveAnimReplaceAnimation = nil
		self.x_lastMoveAnimSpeed = nil
		self.x_lastMoveAnimPathFindId = currentPathFindId
	end

	local effectiveSpeedRateType = speedRateType or BaseEnum.SpeedRateType.Mid

	if self.x_lastMoveAnimSpeedRateType ~= effectiveSpeedRateType or self.x_lastMoveAnimReplaceAnimation ~= replaceAnimation or not AutoPathFindUtils.isAutoPathFinding(self.ent) then
		local animationType = AIControllerUtils.getMoveState(self.ent, effectiveSpeedRateType)

		AutoPathFindUtils.setTargetAnimationState(self.ent, animationType, replaceAnimation and PlayableConst[replaceAnimation])

		self.x_lastMoveAnimSpeedRateType = effectiveSpeedRateType
		self.x_lastMoveAnimReplaceAnimation = replaceAnimation
	end

	if speed and speed ~= self.x_lastMoveAnimSpeed then
		AutoPathFindUtils.setTempSpeed(self.ent, speed)

		self.x_lastMoveAnimSpeed = speed
	end
end

function AIMoveAbility:resetMoveToPosList(resetStateType, forceReset)
	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit or forceReset then
		self:_removeCustomTimeout("ns_moveToPosList")
		self:_removeCustomTimeout("ns_moveToPosList_waitNSPathFind")

		self.x_lastMoveAnimSpeedRateType = nil
		self.x_lastMoveAnimReplaceAnimation = nil
		self.x_lastMoveAnimSpeed = nil
		self.x_lastMoveAnimPathFindId = nil
	end

	AutoPathFindUtils.stopAutoPathFind(self.ent)
end

function AIMoveAbility:moveToPosList(startPosList, endPosList, maxTime, faceToPos, stopDist, speedRateType, speed, isRepath, startNormalList, useAccurateArrive, pathFindType)
	if not useAccurateArrive then
		stopDist = CalcUtils.getValidPositiveValue(stopDist, AiConst.TARGET_POINT_STOP_DIST)
	end

	local ret = EBTStatus.BT_RUNNING

	if self:_checkCustomTimeoutExist("ns_moveToPosList") then
		if isRepath and endPosList and #endPosList > 0 then
			AutoPathFindUtils.startAutoPathFindWithMultiEndPos(self.ent, endPosList, pathFindType, stopDist, true, false, useAccurateArrive)
			AutoPathFindUtils.addComputedPathFindPoint(self.ent, startPosList)
			self:_settingCustomTimeout("ns_moveToPosList_waitNSPathFind", AiConst.NAVMESH_SERVICE_DEFAULIT_TIME)
			self:_settingCustomTimeout("ns_moveToPosList", maxTime)
		end

		if self:_checkCustomTimeout("ns_moveToPosList") then
			ret = EBTStatus.BT_FAILURE
		elseif AutoPathFindUtils.isWaitAsyncResponse(self.ent) and self:_checkCustomTimeout("ns_moveToPosList_waitNSPathFind") then
			ret = EBTStatus.BT_FAILURE
		elseif not AutoPathFindUtils.isAutoPathFinding(self.ent) then
			if AutoPathFindUtils.reachEndPosition(self.ent) then
				ret = EBTStatus.BT_SUCCESS
			else
				ret = EBTStatus.BT_FAILURE
			end
		else
			ret = EBTStatus.BT_RUNNING
		end
	else
		if not endPosList or #endPosList == 0 then
			return EBTStatus.BT_FAILURE
		end

		AutoPathFindUtils.setFaceToPos(self.ent, faceToPos)

		maxTime = maxTime or AiConst.MOVE_CD

		self:_settingCustomTimeout("ns_moveToPosList", maxTime)
		self:_settingCustomTimeout("ns_moveToPosList_waitNSPathFind", AiConst.NAVMESH_SERVICE_DEFAULIT_TIME)

		if not startPosList then
			AutoPathFindUtils.startAutoPathFindWithMultiEndPos(self.ent, endPosList, pathFindType, stopDist, nil, nil, useAccurateArrive)
		else
			AutoPathFindUtils.startAutoPathFindWithMultiEndPos(self.ent, endPosList, AutoPathFindUtils.PathFindType.ForceMove, stopDist, nil, nil, useAccurateArrive)
			AutoPathFindUtils.addComputedPathFindPoint(self.ent, startPosList, startNormalList)
		end

		ret = EBTStatus.BT_RUNNING
	end

	if ret == EBTStatus.BT_RUNNING then
		self:_handleMoveAnimation(speedRateType, speed)
	end

	return ret
end

function AIMoveAbility:getRandomPosByList(...)
	for i = 1, select("#", ...) do
		local tmpRandomData = select(i, ...)
		local find, x, y, z = self:getRandomPos(tmpRandomData.targetPos, tmpRandomData.minDistance, tmpRandomData.maxDistance, tmpRandomData.minDegree, tmpRandomData.maxDegree)

		if find then
			return find, x, y, z
		end
	end

	return false
end

function AIMoveAbility:getRandomPos(targetPos, minDistance, maxDistance, minDegree, maxDegree)
	minDistance = minDistance > 0 and minDistance or 0

	if minDegree == nil or maxDegree == nil then
		return VoxelUtils.findVoxelRandomPos(self.ent, targetPos, minDistance, maxDistance)
	else
		minDegree = minDegree > 0 and minDegree or 0
		maxDegree = maxDegree < 360 and maxDegree or 360

		local tRandomDegree = lume.random(minDegree, maxDegree)
		local tRandomDistance = lume.random(minDistance, maxDistance)
		local tmpRefPos = VectorPool.getVector()

		CalcUtils.getPosOnRayByYawDegree(targetPos, tRandomDegree, tRandomDistance, tmpRefPos)

		local tMaxDistance = math.min(maxDistance - tRandomDistance, tRandomDistance - minDistance)
		local find, x, y, z = VoxelUtils.findVoxelRandomPos(self.ent, tmpRefPos, 0, tMaxDistance)

		VectorPool.returnVector(tmpRefPos)

		return find, x, y, z
	end
end

function AIMoveAbility:movementSelectMovePosList(targetEnt, posSelectStrategyData, refSelectPosList)
	return AIAppointedAreaFunc.AreaSelectFunc[posSelectStrategyData.areaSelectStrategyType](targetEnt, self.ent, posSelectStrategyData, refSelectPosList)
end

function AIMoveAbility:movementGetMovementInfo(targetEnt, posSelectStrategyData)
	return AIAppointedAreaFunc.MovementStrategyFunc[posSelectStrategyData.movementStrategyType](targetEnt, self.ent)
end

function AIMoveAbility:movementCheckAIStartArea(targetEnt, startAreaDataID)
	if not Utils.checkClient() then
		return false
	end

	local startAreaData = AIStartAppointedAreaData[startAreaDataID]

	if not startAreaData then
		return false
	end

	local curIndex = 1
	local curRelativeValue
	local relative = false
	local preRelativeValue = 0

	while curIndex <= #startAreaData.relativeList do
		curRelativeValue = startAreaData.relativeList[curIndex]
		relative = false

		repeat
			if not relative then
				local curStartAreaData = startAreaData.areaDataList[curIndex]

				relative = AIAppointedAreaFunc.CheckStartFunc[curStartAreaData.funcName](targetEnt, self.ent, curStartAreaData.params)
			end

			preRelativeValue = startAreaData.relativeList[curIndex]
			curIndex = curIndex + 1
			curRelativeValue = startAreaData.relativeList[curIndex]
		until curRelativeValue ~= preRelativeValue

		if not relative then
			return false
		end
	end

	return relative
end

function AIMoveAbility:resetTeleportPos(resetStateType)
	if resetStateType == AiConst.ResetStateType.enter then
		self:_removeCustomTimeout("teleportPos")
	end

	self.x_teleportSuccess = nil
end

function AIMoveAbility:teleportPos(position, useEffect, maxTime)
	if not self:_checkCustomTimeoutExist("teleportPos") then
		self:_settingCustomTimeout("teleportPos", maxTime or 2)
		AIBaseMethodUtils.Base_TeleportPos(self.ent, position, function(success)
			if self:_checkCustomTimeoutExist("teleportPos") then
				self.x_teleportSuccess = success
			end
		end)

		if useEffect == nil then
			useEffect = true
		end

		if useEffect then
			-- block empty
		end
	end

	if not self:_checkCustomTimeout("teleportPos") and not self.x_teleportSuccess then
		return EBTStatus.BT_RUNNING
	end

	return self.x_teleportSuccess and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function AIMoveAbility:resetFollowTargetByRelativePos(resetStateType)
	self:_removeCustomTimeout("followTargetByRelativePos")

	if resetStateType == AiConst.ResetStateType.enter then
		if self.x_followTargetByRelativePos_pos == nil then
			self.x_followTargetByRelativePos_pos = VectorPool.getVector()
		end
	elseif resetStateType == AiConst.ResetStateType.exit and self.x_followTargetByRelativePos_pos then
		VectorPool.returnVector(self.x_followTargetByRelativePos_pos)

		self.x_followTargetByRelativePos_pos = nil
	end

	self.x_followTargetByRelativePos_speedRateType = nil
	self.x_followTargetByRelativePos_speed = nil

	self:resetMoveToPos(resetStateType)
end

function AIMoveAbility:followTargetByRelativePos(targetActorId, maxTime, stopDist, relativeX, relativeY, relativeZ, walkDist, sprintDist)
	local targetEnt = pg.getEntityByActorId(targetActorId)

	if not targetEnt then
		return EBTStatus.BT_FAILURE
	end

	if Utils.isPlayer(targetEnt) and targetEnt:isControllingPet() then
		targetEnt = targetEnt:getCurPetEntity()
	end

	local targetPos = targetEnt:getPosition()
	local targetYawRad = targetEnt:getYawRad()

	Vector3.Copy(self.x_followTargetByRelativePos_pos, targetPos)

	relativeX, relativeY, relativeZ = CalcUtils.clockwiseRotateRad(relativeX, relativeY, relativeZ, targetYawRad)
	self.x_followTargetByRelativePos_pos[1] = self.x_followTargetByRelativePos_pos[1] + relativeX
	self.x_followTargetByRelativePos_pos[2] = self.x_followTargetByRelativePos_pos[2] + relativeY
	self.x_followTargetByRelativePos_pos[3] = self.x_followTargetByRelativePos_pos[3] + relativeZ

	if not self:_checkCustomTimeoutExist("followTargetByRelativePos") or self:_checkCustomTimeout("followTargetByRelativePos") then
		local dist = Vector3.Distance(self.ent:getPosition(), self.x_followTargetByRelativePos_pos)

		if dist < walkDist then
			self.x_followTargetByRelativePos_speedRateType = BaseEnum.SpeedRateType.Slow
			self.x_followTargetByRelativePos_speed = AIControllerUtils.getWalkSpeed(self.ent)

			self:_settingCustomTimeout("followTargetByRelativePos", 0.5)
		elseif sprintDist < dist then
			self.x_followTargetByRelativePos_speedRateType = BaseEnum.SpeedRateType.Fast
			self.x_followTargetByRelativePos_speed = math.max(AIControllerUtils.getSprintSpeed(self.ent), targetEnt:getVelocity():Magnitude()) * AiConst.FOLLOW_SPEED_MAX_RATE

			local fastTimeout = math.max(dist / self.x_followTargetByRelativePos_speed - 0.5, 0.5)

			self:_settingCustomTimeout("followTargetByRelativePos", fastTimeout)
		else
			self.x_followTargetByRelativePos_speedRateType = BaseEnum.SpeedRateType.Mid
			self.x_followTargetByRelativePos_speed = math.max(AIControllerUtils.getRunSpeed(self.ent), targetEnt:getVelocity():Magnitude())

			self:_settingCustomTimeout("followTargetByRelativePos", 1)
		end
	end

	return self:moveToPos(self.x_followTargetByRelativePos_pos, maxTime, true, stopDist, self.x_followTargetByRelativePos_speedRateType, self.x_followTargetByRelativePos_speed, AutoPathFindUtils.PathFindType.Voxel, true)
end

return AIMoveAbility
