-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IPetMoveComponent.lua

local Class = require("Core.Framework.Class")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local CalcUtils = require("Common.Utils.CalcUtils")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local ListPool = require("Common.Container.ListPool")
local TablePool = require("Common.Container.TablePool")
local VectorPool = require("Common.Container.VectorPool")
local enums = require("Common.AI.Behaviac.Enums")
local Vector3 = Vector3
local Quaternion = Quaternion
local EBTStatus = enums.EBTStatus
local math_cos = math.cos
local math_deg = math.deg
local math_epsilon = math.epsilon
local math_max = math.max
local math_min = math.min
local math_rad = math.rad
local math_random = math.random
local math_sin = math.sin
local math_sqrt = math.sqrt
local table_clearArray = table.clearArray

local function normalizeXZ(x, z)
	local magnitude = math_sqrt(x * x + z * z)

	if magnitude > 1e-05 then
		return x / magnitude, z / magnitude
	end

	return 0, 0
end

local function setVectorListPos(targetPosCache, targetPosList, index, x, y, z)
	local targetPos = targetPosCache[index]

	if targetPos == nil then
		targetPos = VectorPool.getVector()
		targetPosCache[index] = targetPos
	end

	targetPos:Set(x, y, z)

	targetPosList[index] = targetPos
end

local function returnVectorListCache(targetPosCache)
	if targetPosCache == nil then
		return
	end

	for i = 1, #targetPosCache do
		VectorPool.returnVector(targetPosCache[i])

		targetPosCache[i] = nil
	end

	ListPool.returnList(targetPosCache)
end

local IPetMoveComponent = Class.Component("IPetMoveComponent")

function IPetMoveComponent:letGoMove__resetState(resetStateType)
	self:moveToTarget__resetState(resetStateType)
end

function IPetMoveComponent:letGoMove(tgtActorId, stopDist, speedMulti, maxTimeout, targetEnvPartId)
	if maxTimeout == nil or maxTimeout < math_epsilon then
		maxTimeout = AiConst.LET_GO_TIMEOUT
	end

	if speedMulti == nil or speedMulti < math_epsilon then
		speedMulti = 1
	end

	local speed = AIControllerUtils.getRunSpeed(self.ent) * speedMulti

	return self:moveToTarget(tgtActorId, stopDist, maxTimeout, false, false, true, speed, BaseEnum.MoveUpdateLevel.Once, BaseEnum.PathFindType.Voxel, BaseEnum.SpeedRateType.Fast, targetEnvPartId)
end

function IPetMoveComponent:letGoMoveFail__resetState(resetStateType)
	self.moveAbility:resetMoveToPos(resetStateType)

	if self.x_letGoMoveFail_pos then
		VectorPool.returnVector(self.x_letGoMoveFail_pos)

		self.x_letGoMoveFail_pos = nil
	end
end

function IPetMoveComponent:letGoMoveFail(distance, speedMulti, maxTimeout)
	local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)

	if not self.x_letGoMoveFail_pos then
		self.x_letGoMoveFail_pos = VectorPool.getVector(3, masterEnt:getPosition())

		Vector3.enableCreateFromCache()

		local tgtDirection = masterEnt:getRotation():Forward():SetNormalize()

		self.x_letGoMoveFail_pos:Add(tgtDirection:Mul(distance))
		Vector3.disableCreateFromCache()
	end

	local speed = AIControllerUtils.getRunSpeed(self.ent) * (speedMulti or 1)

	if maxTimeout == nil or maxTimeout < math_epsilon then
		maxTimeout = AiConst.LET_GO_TIMEOUT
	end

	local ret = self.moveAbility:moveToPos(self.x_letGoMoveFail_pos, maxTimeout, true, nil, BaseEnum.SpeedRateType.Fast, speed)

	if ret ~= EBTStatus.BT_RUNNING then
		return EBTStatus.BT_SUCCESS
	end

	return ret
end

function IPetMoveComponent:petTeleportToTarget__resetState(resetStateType)
	self.moveAbility:resetTeleportPos(resetStateType)

	if self.x_petTeleportToTarget_targetPos then
		VectorPool.returnVector(self.x_petTeleportToTarget_targetPos)

		self.x_petTeleportToTarget_targetPos = nil
	end
end

function IPetMoveComponent:petTeleportToTarget(targetActorId, targetDistance, maxTime)
	local tgtEnt = pg.getEntityByActorId(targetActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	if not self.x_petTeleportToTarget_targetPos and self.ent.masterActorId == tgtEnt.actorId and Utils.isMainPlayer(tgtEnt) then
		self.x_petTeleportToTarget_targetPos = VectorPool.getVector(3, tgtEnt:getPosition())
	end

	if not self.x_petTeleportToTarget_targetPos then
		local rightOrLeft = math_random() > 0.5 and -1 or 1

		Vector3.enableCreateFromCache()

		local masterPos = self.ent.master:getPosition()
		local targetPos = tgtEnt:getPosition()
		local dirDegree = math_deg(CalcUtils.getYawByPos(targetPos, masterPos))
		local currentDegree = rightOrLeft * (AiConst.PET_TELEPORT_DEGREE.MinDegree + AiConst.PET_TELEPORT_DEGREE.MaxDegree) / 2
		local targetPos1 = CalcUtils.getPosOnRayByYawDegree(targetPos, dirDegree + currentDegree, targetDistance, Vector3.New())
		local targetPos2 = CalcUtils.getPosOnRayByYawDegree(targetPos, dirDegree - currentDegree, targetDistance, Vector3.New())
		local targetRandomPosData1 = TablePool.getTable()

		targetRandomPosData1.targetPos = targetPos1
		targetRandomPosData1.minDistance = 0

		local targetRandomPosData2 = TablePool.getTable()

		targetRandomPosData2.targetPos = targetPos2
		targetRandomPosData2.minDistance = 0

		local ret, x, y, z
		local randomRadius = AiConst.NAVMESH_RANDOM_RADIUS

		for i = 1, 5 do
			targetRandomPosData1.maxDistance = randomRadius
			targetRandomPosData2.maxDistance = randomRadius
			ret, x, y, z = self.moveAbility:getRandomPosByList(targetRandomPosData1, targetRandomPosData2)

			if ret then
				break
			end

			randomRadius = randomRadius * 1.2
		end

		TablePool.returnTable(targetRandomPosData1)
		TablePool.returnTable(targetRandomPosData2)

		self.x_petTeleportToTarget_targetPos = VectorPool.getVector(3, masterPos)

		if ret then
			self.x_petTeleportToTarget_targetPos:Set(x, y, z)
		end

		Vector3.disableCreateFromCache()
	end

	return self.moveAbility:teleportPos(self.x_petTeleportToTarget_targetPos, false, maxTime)
end

function IPetMoveComponent:letGoMoveFear__resetState(resetStateType)
	self.moveAbility:resetMoveToPos()

	if self.x_letGoMoveFear_pos then
		VectorPool.returnVector(self.x_letGoMoveFear_pos)

		self.x_letGoMoveFear_pos = nil
	end
end

function IPetMoveComponent:letGoMoveFear(distance, speedMulti, tgtId)
	if not self.x_letGoMoveFear_pos then
		local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)
		local tgtDirection

		if tgtId and tgtId ~= 0 then
			local tgtEnt = pg.getEntityByActorId(tgtId)
			local myPos = self.ent:getPosition()

			tgtDirection = tgtEnt:getPositionClone():Sub(myPos):SetNormalize()
			self.x_letGoMoveFear_pos = VectorPool.getVector(3, myPos)

			self.x_letGoMoveFear_pos:Add(tgtDirection:Mul(distance))
		else
			Vector3.enableCreateFromCache()

			tgtDirection = masterEnt:getRotation():Forward():SetNormalize()
			self.x_letGoMoveFear_pos = VectorPool.getVector(3, masterEnt:getPosition())

			self.x_letGoMoveFear_pos:Add(tgtDirection:Mul(distance))
			Vector3.disableCreateFromCache()
		end
	end

	local speed = AIControllerUtils.getRunSpeed(self.ent) * (speedMulti or 1)
	local ret = self.moveAbility:moveToPos(self.x_letGoMoveFear_pos, AiConst.LET_GO_TIMEOUT, true, nil, BaseEnum.SpeedRateType.Fast, speed)

	if ret ~= EBTStatus.BT_RUNNING then
		return EBTStatus.BT_SUCCESS
	end

	return ret
end

function IPetMoveComponent:letGoAttractMove__resetState(resetStateType)
	if self.x_letGoAttractMove_pos then
		VectorPool.returnVector(self.x_letGoAttractMove_pos)

		self.x_letGoAttractMove_pos = nil
	end

	self.x_letGoAttractMove_moveToTarget = nil

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IPetMoveComponent:letGoAttractMove(tgtActorId, speedMulti)
	local tgtEnt = pg.getEntityByActorId(tgtActorId)

	if tgtEnt == nil then
		return EBTStatus.BT_FAILURE
	end

	local attackStopBoxDist = self:getBlackBoardProperty("attackStopBoxDist")
	local targetPos = tgtEnt:getPosition()

	if self.x_letGoAttractMove_pos == nil then
		local masterEnt = pg.getEntityByActorId(self:getMasterId())
		local dist = Vector3.Distance(masterEnt:getPosition(), tgtEnt:getPosition()) - CalcUtils.getBodySizeBias(masterEnt)
		local meAndTargetBodySize = CalcUtils.getBodySizeBias(self.ent, tgtEnt)
		local maxDist = self:getBlackBoardProperty("attackStopBoxDist") + meAndTargetBodySize
		local minDist = self:getBlackBoardProperty("minBoxDist") + meAndTargetBodySize
		local masterPos = masterEnt:getPosition()

		self.x_letGoAttractMove_pos = VectorPool.getVector()

		if maxDist <= dist then
			self.x_letGoAttractMove_pos:Set(targetPos.x, targetPos.y, targetPos.z)

			local tmpMasterPos = VectorPool.getVector()

			tmpMasterPos:Set(masterPos.x, masterPos.y, masterPos.z)
			self.x_letGoAttractMove_pos:Add((tmpMasterPos:Sub(tgtEnt:getPosition()):SetNormalize():Mul(attackStopBoxDist)))
			VectorPool.returnVector(tmpMasterPos)
		elseif minDist < dist and dist < maxDist then
			self.x_letGoAttractMove_pos:Set(masterPos.x, masterPos.y, masterPos.z)

			local tmpTgtPos = VectorPool.getVector()

			tmpTgtPos:Set(targetPos.x, targetPos.y, targetPos.z)
			self.x_letGoAttractMove_pos:Add((tmpTgtPos:Sub(masterPos):SetNormalize():Mul(minDist)))
			VectorPool.returnVector(tmpTgtPos)
		else
			self.x_letGoAttractMove_moveToTarget = true
		end
	end

	local speed = AIControllerUtils.getRunSpeed(self.ent) * speedMulti
	local ret

	if self.x_letGoAttractMove_moveToTarget then
		ret = self.moveAbility:moveToPos(targetPos, AiConst.LET_GO_TIMEOUT, true, attackStopBoxDist, BaseEnum.SpeedRateType.Fast, speed)
	else
		ret = self.moveAbility:moveToPos(self.x_letGoAttractMove_pos, AiConst.LET_GO_TIMEOUT, true, nil, BaseEnum.SpeedRateType.Fast, speed)
	end

	if ret == EBTStatus.BT_FAILURE then
		ret = EBTStatus.BT_SUCCESS
	end

	return ret
end

function IPetMoveComponent:petPatrolInRange__resetState(resetStateType)
	if self.x_petPatrolInRange_targetPos then
		VectorPool.returnVector(self.x_petPatrolInRange_targetPos)

		self.x_petPatrolInRange_targetPos = nil
	end

	self.moveAbility:resetMoveToPos(resetStateType)
end

function IPetMoveComponent:petPatrolInRange(maxTime)
	if self.x_petPatrolInRange_targetPos == nil then
		local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)
		local followMidDist = self:getBlackBoardProperty("followMidDist")
		local followCloseDist = self:getBlackBoardProperty("followCloseDist")
		local followDistance = (followMidDist + followCloseDist) / 2
		local currentLocalAngle = CalcUtils.getAngleByEntityPos(masterEnt, self.ent)
		local tgtEntYaw = math_deg(masterEnt:getRotation():ToYaw())

		self.x_petPatrolInRange_targetPos = CalcUtils.getPosOnRayByYawDegree(masterEnt:getPosition(), math_random(-AiConst.PET_PATROL_RANGE_DEGREE, AiConst.PET_PATROL_RANGE_DEGREE) + currentLocalAngle + tgtEntYaw, followDistance, VectorPool.getVector())
	end

	return self.moveAbility:moveToPos(self.x_petPatrolInRange_targetPos, maxTime, true, nil, BaseEnum.SpeedRateType.Slow)
end

function IPetMoveComponent:masterIsInCrouch()
	local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)

	if masterEnt then
		return masterEnt:CROUCH_ST()
	end

	return false
end

function IPetMoveComponent:masterIsInCatchMode()
	local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)

	if masterEnt then
		return masterEnt:CATCH_MODE_ST()
	end

	return false
end

function IPetMoveComponent:masterIsInMagnesisMode()
	local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)

	if masterEnt and masterEnt.isInMagnesisMode then
		return masterEnt:isInMagnesisMode()
	end

	return false
end

function IPetMoveComponent:petMoveWithMasterCrouchAndCatchMode__resetState(resetStateType)
	self.moveAbility:resetMoveToPosList(resetStateType)

	if resetStateType == AiConst.ResetStateType.enter or resetStateType == AiConst.ResetStateType.exit then
		self.x_petMoveWithMasterCrouchAndCatchMode_speed = nil

		self:_removeCustomTimeout("petMoveWithMasterCrouchAndCatchMode_repath")

		if resetStateType == AiConst.ResetStateType.enter then
			if self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList == nil then
				self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList = ListPool.getList()
			end
		else
			if self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList ~= nil then
				ListPool.returnList(self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList)

				self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList = nil
			end

			if self.x_petMoveWithMasterCrouchAndCatchMode_targetPosCache ~= nil then
				returnVectorListCache(self.x_petMoveWithMasterCrouchAndCatchMode_targetPosCache)

				self.x_petMoveWithMasterCrouchAndCatchMode_targetPosCache = nil
			end
		end
	end
end

function IPetMoveComponent:petMoveWithMasterCrouchAndCatchMode(crouchSpeed, crouchSpeedRateType, catchModeSpeed, catchModeSpeedRateType)
	local isRepath = false

	if self:_checkCustomTimeout("petMoveWithMasterCrouchAndCatchMode_repath") then
		local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)
		local masterPos = masterEnt:getPosition()
		local entPos = self.ent:getPosition()
		local cameraFwdX, _, cameraFwdZ = pg.global.cameraMgr:GetWorldCameraForwardEx()
		local cameraForwardX, cameraForwardZ = normalizeXZ(cameraFwdX, cameraFwdZ)
		local masterToEntX = entPos[1] - masterPos[1]
		local masterToEntY = entPos[2] - masterPos[2]
		local masterToEntZ = entPos[3] - masterPos[3]
		local masterToEntDirX, masterToEntDirZ = normalizeXZ(masterToEntX, masterToEntZ)
		local halfRad = math_rad(AiConst.PET_MOVE_ASIDE_ANGLE_RANGE * 0.5)
		local sqrDist = masterToEntX * masterToEntX + masterToEntY * masterToEntY + masterToEntZ * masterToEntZ
		local needToNear

		if self:masterIsInCrouch() then
			needToNear = sqrDist > AiConst.PET_MOVE_NEAR_DIST * AiConst.PET_MOVE_NEAR_DIST
		end

		local needToAside

		if self:masterIsInCatchMode() or self:masterIsInMagnesisMode() then
			local tooNear = sqrDist < AiConst.PET_MOVE_ASIDE_MIN_DIST * AiConst.PET_MOVE_ASIDE_MIN_DIST
			local tooFar = sqrDist > AiConst.PET_MOVE_ASIDE_MAX_DIST * AiConst.PET_MOVE_ASIDE_MAX_DIST

			needToAside = tooNear or not tooFar and cameraForwardX * masterToEntDirX + cameraForwardZ * masterToEntDirZ > math_cos(halfRad)
		end

		local targetPosCache

		if needToAside or needToNear then
			targetPosCache = self.x_petMoveWithMasterCrouchAndCatchMode_targetPosCache

			if targetPosCache == nil then
				targetPosCache = ListPool.getList()
				self.x_petMoveWithMasterCrouchAndCatchMode_targetPosCache = targetPosCache
			end
		end

		if needToAside then
			local masterSideDirX = -cameraForwardZ
			local masterSideDirZ = cameraForwardX
			local sign = masterSideDirX * masterToEntDirX + masterSideDirZ * masterToEntDirZ >= 0 and 1 or -1
			local delta = 0.04
			local asideSin = math_sin(halfRad + delta) * sign
			local asideCos = math_cos(halfRad + delta)
			local targetLineDirXX = masterSideDirX * asideSin
			local targetLineDirXZ = masterSideDirZ * asideSin
			local targetLineDirYX = cameraForwardX * asideCos
			local targetLineDirYZ = cameraForwardZ * asideCos
			local dist = math_sqrt(sqrDist) + AiConst.PET_MOVE_ASIDE_EXTEND_DIST

			self.x_petMoveWithMasterCrouchAndCatchMode_speed = catchModeSpeed

			table_clearArray(self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList, 1, masterPos[1] + (targetLineDirYX + targetLineDirXX) * dist, masterPos[2], masterPos[3] + (targetLineDirYZ + targetLineDirXZ) * dist)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList, 2, masterPos[1] + (targetLineDirYX - targetLineDirXX) * dist, masterPos[2], masterPos[3] + (targetLineDirYZ - targetLineDirXZ) * dist)
		elseif needToNear then
			self.x_petMoveWithMasterCrouchAndCatchMode_speed = crouchSpeed

			table_clearArray(self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList, 1, masterPos[1] + masterToEntDirX * AiConst.PET_MOVE_NEAR_DIST, masterPos[2], masterPos[3] + masterToEntDirZ * AiConst.PET_MOVE_NEAR_DIST)
		else
			self.x_petMoveWithMasterCrouchAndCatchMode_speed = nil

			table_clearArray(self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList)
		end

		if self:_checkCustomTimeoutExist("petMoveWithMasterCrouchAndCatchMode_repath") then
			isRepath = true
		end

		self:_settingCustomTimeout("petMoveWithMasterCrouchAndCatchMode_repath", AiConst.PET_MOVE_REPATH_CD)
	end

	if #self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList > 0 then
		return self.moveAbility:moveToPosList(nil, self.x_petMoveWithMasterCrouchAndCatchMode_targetPosList, AiConst.MOVE_CD, true, 0, catchModeSpeedRateType, self.x_petMoveWithMasterCrouchAndCatchMode_speed, isRepath)
	end

	return EBTStatus.BT_RUNNING
end

function IPetMoveComponent:masterIsInSelfieMode()
	return pg.global.ui.photo:isInSelfie()
end

function IPetMoveComponent:petMoveWithMasterSelfieMode__resetState(resetStateType)
	self.x_petMoveWithMasterSelfieMode_isMove = nil

	if self.x_petMoveWithMasterSelfieMode_targetPosList then
		ListPool.returnList(self.x_petMoveWithMasterSelfieMode_targetPosList)

		self.x_petMoveWithMasterSelfieMode_targetPosList = nil
	end

	self.x_petMoveWithMasterSelfieMode_speed = nil

	self:_removeCustomTimeout("petMoveWithMasterSelfieMode_repath")
	self.moveAbility:resetMoveToPosList(resetStateType)
	self:turnToPos__resetState(resetStateType)

	if self.x_petMoveWithMasterSelfieMode_targetPosCache then
		returnVectorListCache(self.x_petMoveWithMasterSelfieMode_targetPosCache)

		self.x_petMoveWithMasterSelfieMode_targetPosCache = nil
	end
end

function IPetMoveComponent:petMoveWithMasterSelfieMode(speed, speedRateType)
	local isRepath = false

	if self:_checkCustomTimeout("petMoveWithMasterSelfieMode_repath") then
		local masterEnt = pg.getEntityByActorId(self.ent.masterActorId)
		local masterPos = masterEnt:getPosition()
		local entPos = self.ent:getPosition()
		local cameraPosX, _, cameraPosZ, cameraFwdX, _, cameraFwdZ = pg.global.cameraMgr:GetWorldCameraPositionAndForwardEx()
		local cameraPosY = masterPos[2]
		local cameraForwardX, cameraForwardZ = normalizeXZ(cameraFwdX, cameraFwdZ)
		local cameraToMasterX = masterPos[1] - cameraPosX
		local cameraToMasterZ = masterPos[3] - cameraPosZ
		local cameraToMasterDist = math_sqrt(cameraToMasterX * cameraToMasterX + cameraToMasterZ * cameraToMasterZ)
		local maxDist = cameraToMasterDist + AiConst.PET_MOVE_EXTRA_DIST_IN_SELFIE + self.ent.bodySize or 0
		local minDist = math_max(maxDist - AiConst.PET_MOVE_RANGE_LENGTH_IN_SELFIE, 0)
		local cameraToEntX = entPos[1] - cameraPosX
		local cameraToEntY = entPos[2] - cameraPosY
		local cameraToEntZ = entPos[3] - cameraPosZ
		local sqrDist = cameraToEntX * cameraToEntX + cameraToEntY * cameraToEntY + cameraToEntZ * cameraToEntZ
		local needMove = sqrDist < minDist * minDist or sqrDist > maxDist * maxDist

		if not needMove then
			local cameraToEntDirX, cameraToEntDirZ = normalizeXZ(cameraToEntX, cameraToEntZ)
			local halfRad = math_rad(AiConst.PET_MOVE_RANGE_ANGLE_IN_SELFIE * 0.5)

			needMove = cameraForwardX * cameraToEntDirX + cameraForwardZ * cameraToEntDirZ < math_cos(halfRad)
		end

		if needMove then
			local cameraRightX = cameraForwardZ
			local cameraRightZ = -cameraForwardX
			local masterInRight = cameraRightX * cameraToMasterX + cameraRightZ * cameraToMasterZ > 0
			local optionRad = math_rad(math_min(AiConst.PET_MOVE_OPTION_ANGLE_IN_SELFIE, AiConst.PET_MOVE_RANGE_ANGLE_IN_SELFIE * 0.5))
			local optionCos = math_cos(optionRad)
			local optionSin = math_sin(optionRad)
			local optionForwardX = cameraForwardX * optionCos
			local optionForwardZ = cameraForwardZ * optionCos
			local optionRightX = cameraRightX * optionSin
			local optionRightZ = cameraRightZ * optionSin
			local preSign = masterInRight and -1 or 1
			local optionSign = -preSign
			local dist = (minDist + maxDist) * 0.5

			if self.x_petMoveWithMasterSelfieMode_targetPosList == nil then
				self.x_petMoveWithMasterSelfieMode_targetPosList = ListPool.getList()
			end

			local targetPosCache = self.x_petMoveWithMasterSelfieMode_targetPosCache

			if targetPosCache == nil then
				targetPosCache = ListPool.getList()
				self.x_petMoveWithMasterSelfieMode_targetPosCache = targetPosCache
			end

			table_clearArray(self.x_petMoveWithMasterSelfieMode_targetPosList)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 1, cameraPosX + (optionForwardX + optionRightX * preSign) * dist, cameraPosY, cameraPosZ + (optionForwardZ + optionRightZ * preSign) * dist)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 2, cameraPosX + cameraForwardX * dist, cameraPosY, cameraPosZ + cameraForwardZ * dist)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 3, cameraPosX + (optionForwardX + optionRightX * optionSign) * dist, cameraPosY, cameraPosZ + (optionForwardZ + optionRightZ * optionSign) * dist)
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 4, cameraPosX + cameraRightX * (dist * preSign), cameraPosY, cameraPosZ + cameraRightZ * (dist * preSign))
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 5, cameraPosX + cameraRightX * (dist * optionSign), cameraPosY, cameraPosZ + cameraRightZ * (dist * optionSign))
			setVectorListPos(targetPosCache, self.x_petMoveWithMasterSelfieMode_targetPosList, 6, cameraPosX - cameraForwardX * dist, cameraPosY, cameraPosZ - cameraForwardZ * dist)

			self.x_petMoveWithMasterSelfieMode_speed = speed
		end

		if self:_checkCustomTimeoutExist("petMoveWithMasterSelfieMode_repath") then
			isRepath = true
		end

		self:_settingCustomTimeout("petMoveWithMasterSelfieMode_repath", AiConst.PET_MOVE_REPATH_CD)

		if AiConst.AI_DEBUG.SELFIE then
			local shape_kind = 7
			local dirColor = {
				r = 0,
				b = 1,
				g = 0,
				a = 0.6274509803921569
			}
			local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

			Vector3.enableCreateFromCache()

			local cameraPos = Vector3(cameraPosX, cameraPosY, cameraPosZ)
			local cameraForward = Vector3(cameraForwardX, 0, cameraForwardZ)

			LxGeometryMesh.DrawMesh(cameraPos, Quaternion.LookRotation(cameraForward, Vector3.constUp), shape_kind, {
				minDist,
				maxDist,
				AiConst.PET_MOVE_RANGE_ANGLE_IN_SELFIE * 0.5,
				1,
				1
			}, AiConst.PET_MOVE_REPATH_CD, dirColor)
			Vector3.disableCreateFromCache()
		end
	end

	if self.x_petMoveWithMasterSelfieMode_targetPosList then
		local status = self.moveAbility:moveToPosList(nil, self.x_petMoveWithMasterSelfieMode_targetPosList, AiConst.MOVE_CD, true, 0, speedRateType, self.x_petMoveWithMasterSelfieMode_speed, isRepath)

		if Utils.checkClient() then
			local MessageName = require("Const.MessageName")

			if status == EBTStatus.BT_RUNNING then
				if not self.x_petMoveWithMasterSelfieMode_isMove then
					self.x_petMoveWithMasterSelfieMode_isMove = true

					facade:sendMsgToUI(MessageName.PHOTO_PET_START_MOVE, AiConst.DefaultNullTable)
				end
			else
				ListPool.returnList(self.x_petMoveWithMasterSelfieMode_targetPosList)

				self.x_petMoveWithMasterSelfieMode_targetPosList = nil

				if self.x_petMoveWithMasterSelfieMode_isMove then
					self.x_petMoveWithMasterSelfieMode_isMove = false

					local cameraPosX, _, cameraPosZ = pg.global.cameraMgr:GetWorldCameraPositionEx()

					self:turnToPosEx(cameraPosX, cameraPosZ, 0, true, -1, false)
					facade:sendMsgToUI(MessageName.PHOTO_PET_END_MOVE, AiConst.DefaultNullTable)
				end
			end
		end

		return status
	end

	return EBTStatus.BT_RUNNING
end

return IPetMoveComponent
