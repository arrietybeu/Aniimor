-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\AIAbility\\AIAppointedAreaFunc.lua

local CalcUtils = require("Common.Utils.CalcUtils")
local AiConst = require("Common.Const.AiConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local VectorPool = require("Common.Container.VectorPool")
local AIUtils = require("Common.Utils.AIUtils")
local Vector3 = Vector3
local math_abs = math.abs
local math_max = math.max
local math_lerp = math.lerp
local math_deg = math.deg
local table_insert = table.insert
local AIAppointedAreaFunc = {}

AIAppointedAreaFunc.MovementStrategyFunc = {
	SpeedUp = function(tgtEnt, ent)
		local myRunSpeed = AIControllerUtils.getRunSpeed(ent)
		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()
		local me2TargetDegreeAbs = math_abs(CalcUtils.getAngleByEntityPos(tgtEnt, ent))
		local speed

		if me2TargetDegreeAbs < AiConst.FOLLOW_SPEED_SLOWDOWN_DEGREE then
			speed = math_max(myRunSpeed, targetEntSpeed)
		else
			local sameSpeed = math_max(myRunSpeed, targetEntSpeed)
			local maxSpeed = math_max(myRunSpeed * AiConst.FOLLOW_SPEED_MAX_RATE, targetEntSpeed * AiConst.FOLLOW_SPEED_TARGET_RATE)

			speed = math_lerp(sameSpeed, maxSpeed, (me2TargetDegreeAbs - AiConst.FOLLOW_SPEED_SLOWDOWN_DEGREE) / 180)
		end

		return speed, AIUtils.getFollowSpeedRateType(speed, ent)
	end,
	SlowDown = function(tgtEnt, ent)
		local myRunSpeed = AIControllerUtils.getRunSpeed(ent)
		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()
		local speed = math_max(myRunSpeed, targetEntSpeed) * AiConst.FOLLOW_SPEED_MIN_RATE

		return speed, AIUtils.getFollowSpeedRateType(speed, ent)
	end,
	Normal = function(tgtEnt, ent)
		local myWalkSpeed = AIControllerUtils.getWalkSpeed(ent)
		local myRunSpeed = AIControllerUtils.getRunSpeed(ent)
		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()
		local me2TargetDegree = CalcUtils.getAngleByEntityPos(tgtEnt, ent)
		local speed = math_abs(me2TargetDegree) > AiConst.FOLLOW_SPEED_SLOWDOWN_DEGREE and math_max(myRunSpeed, targetEntSpeed) or math_max(targetEntSpeed, myWalkSpeed)

		return speed, AIUtils.getFollowSpeedRateType(speed, ent)
	end,
	MoveAway = function(tgtEnt, ent)
		return AIControllerUtils.getWalkSpeed(ent), BaseEnum.SpeedRateType.Slow
	end,
	SameMove = function(tgtEnt, ent)
		local myWalkSpeed = AIControllerUtils.getWalkSpeed(ent)
		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()

		if targetEntSpeed > 0.1 then
			local speed = math_max(targetEntSpeed, myWalkSpeed)

			if tgtEnt.characterState == CharacterStateConst.RUN or tgtEnt.characterState == CharacterStateConst.SPRINT then
				return speed, AIUtils.getFollowSpeedRateType(speed, ent)
			end

			return speed, AIUtils.getFollowSpeedRateType(speed, ent)
		else
			return myWalkSpeed, BaseEnum.SpeedRateType.Slow
		end
	end,
	FaceCameraSameMove = function(tgtEnt, ent)
		local myWalkSpeed = AIControllerUtils.getWalkSpeed(ent)
		local myRunSpeed = AIControllerUtils.getRunSpeed(ent)
		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()

		if targetEntSpeed > 0.1 then
			local speed = math_max(targetEntSpeed, myRunSpeed)

			if tgtEnt.characterState == CharacterStateConst.RUN or tgtEnt.characterState == CharacterStateConst.SPRINT then
				return speed, AIUtils.getFollowSpeedRateType(speed, ent)
			end

			return speed, AIUtils.getFollowSpeedRateType(speed, ent)
		else
			return myWalkSpeed, BaseEnum.SpeedRateType.Slow
		end
	end,
	FaceCameraChangeSpeedMove = function(tgtEnt, ent)
		local myRunSpeed = AIControllerUtils.getRunSpeed(ent)
		local myWalkSpeed = AIControllerUtils.getWalkSpeed(ent)

		Vector3.enableCreateFromCache()

		local targetEntVelocity = tgtEnt:getVelocity()
		local targetEntSpeed = targetEntVelocity:Magnitude()
		local ent2TgtVec = tgtEnt:getPosition() - ent:getPosition()
		local speed = myWalkSpeed

		if targetEntSpeed > 0.1 then
			if Vector3.Dot(ent2TgtVec, targetEntVelocity) > 0 then
				speed = math_max(myRunSpeed * AiConst.FOLLOW_SPEED_MAX_RATE, targetEntSpeed * AiConst.FOLLOW_SPEED_MAX_RATE)
			else
				speed = math_max(myRunSpeed, targetEntSpeed) * AiConst.FOLLOW_SPEED_MIN_RATE
			end
		end

		Vector3.disableCreateFromCache()

		return speed, AIUtils.getFollowSpeedRateType(speed, ent)
	end
}
AIAppointedAreaFunc.CheckStartFunc = {
	targetSpeedCompare = function(tgtEnt, ent, params)
		if not tgtEnt or not tgtEnt:getVelocity() then
			return false
		end

		local targetSpeed = tgtEnt:getVelocity():Magnitude()

		return targetSpeed > params[1] and targetSpeed < params[2]
	end,
	me2TargetDegreeAbs = function(tgtEnt, ent, params)
		local me2TargetDegree = math_abs(CalcUtils.getAngleByEntityPos(tgtEnt, ent))

		return me2TargetDegree > params[1] and me2TargetDegree < params[2]
	end,
	me2TargetDistance2d = function(tgtEnt, ent, params)
		local myPos = ent:getPosition()
		local targetPos = tgtEnt:getPosition()
		local currentSqrDis2Target = Vector3.HoriSqrDistance(myPos, targetPos)

		return currentSqrDis2Target >= params[1] * params[1] and currentSqrDis2Target <= params[2] * params[2]
	end,
	me2TargetHeightDistance = function(tgtEnt, ent, params)
		local myPos = ent:getPosition()
		local targetPos = tgtEnt:getPosition()
		local currentHeightDis2Target = math_abs(myPos.y - targetPos.y)

		return currentHeightDis2Target > params[1] and currentHeightDis2Target < params[2]
	end,
	me2TargetDistance3d = function(tgtEnt, ent, params)
		local myPos = ent:getPosition()
		local targetPos = tgtEnt:getPosition()
		local currentHeightDis2Target = Vector3.SqrDistance(myPos, targetPos)

		return currentHeightDis2Target > params[1] * params[1] and currentHeightDis2Target < params[2] * params[2]
	end,
	ignoreCharacterStateList = function(tgtEnt, ent, params)
		local currentAnimationState = AIControllerUtils.getCurrentAnimationState(tgtEnt)

		for i = 1, #params do
			local stateConstInt = CharacterStateConst[params[i]]

			if CharacterStateConst.isChildState(stateConstInt) then
				if currentAnimationState == stateConstInt then
					return false
				end
			elseif CharacterStateConst.isChildOfState(currentAnimationState, stateConstInt) then
				return false
			end
		end

		return true
	end,
	targetEntPropertyCheck = function(tgtEnt, ent, params)
		return tgtEnt[params[1]] == params[2]
	end
}
AIAppointedAreaFunc.SelectPosFunc = {
	RelativeFocusPos = function(targetPos, tgtEntYawDegree, areaData, refPos, radios)
		local tTargetDist = areaData.minDist + (areaData.maxDist - areaData.minDist) * radios

		return CalcUtils.getPosOnRayByYawDegree(targetPos, tgtEntYawDegree + areaData.targetAngle, tTargetDist, refPos)
	end
}
AIAppointedAreaFunc.AreaSelectFunc = {
	FollowSelect = function(targetEnt, myEnt, posSelectStrategyData, refSelectPosList)
		if targetEnt == nil or myEnt == nil then
			return false
		end

		local len = #refSelectPosList

		if len ~= 0 then
			for i = len, 1, -1 do
				VectorPool.returnVector(refSelectPosList[i])

				refSelectPosList[i] = nil
			end
		end

		Vector3.enableCreateFromCache()

		local myPos = myEnt:getPosition()
		local targetPos = targetEnt:getPosition()
		local targetForward = targetEnt:getForward()
		local targetYawDegree = math_deg(CalcUtils.getYawByDir(targetForward.x, targetForward.z))
		local me2TargetDegree = math_deg(CalcUtils.getAngleByDir(targetForward, myPos - targetPos))
		local areaDataList = posSelectStrategyData.areaDataList

		if me2TargetDegree > 0 then
			for i = 1, #areaDataList do
				local tAreaData = areaDataList[i]
				local tSimpleNum = tAreaData.simpleNum

				for j = 1, tSimpleNum do
					local tRefPos = VectorPool.getVector()
					local tRadio = 1 - j * 1 / (tSimpleNum + 1)

					AIAppointedAreaFunc.SelectPosFunc[tAreaData.areaDataType](targetPos, targetYawDegree, tAreaData, tRefPos, tRadio)
					table_insert(refSelectPosList, tRefPos)
				end
			end
		else
			for i = #areaDataList, 1, -1 do
				local tAreaData = areaDataList[i]
				local tSimpleNum = tAreaData.simpleNum

				for j = 1, tSimpleNum do
					local tRefPos = VectorPool.getVector()
					local tRadio = 1 - j * 1 / (tSimpleNum + 1)

					AIAppointedAreaFunc.SelectPosFunc[tAreaData.areaDataType](targetPos, targetYawDegree, tAreaData, tRefPos, tRadio)
					table_insert(refSelectPosList, tRefPos)
				end
			end
		end

		local backupDataList = posSelectStrategyData.backupPosDataList

		if backupDataList then
			for _, tBackupData in ipairs(backupDataList) do
				local tSimpleNum = tBackupData.simpleNum

				for j = 1, tSimpleNum do
					local tRefPos = VectorPool.getVector()
					local tRadio = 1 - j * 1 / (tSimpleNum + 1)

					AIAppointedAreaFunc.SelectPosFunc[tBackupData.areaDataType](targetPos, targetYawDegree, tBackupData, tRefPos, tRadio)
					table_insert(refSelectPosList, tRefPos)
				end
			end
		end

		Vector3.disableCreateFromCache()

		return #refSelectPosList > 0
	end
}

return AIAppointedAreaFunc
