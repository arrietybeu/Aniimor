-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AutoPathFindUtils.lua

local CommonConst = require("Common.Const.Const")
local Utils = require("Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local VoxelConst = require("Common.Const.VoxelConst")
local Vector3 = Vector3
local AutoPathFindUtils = {}

AutoPathFindUtils.PathFindType = {
	Voxel = 5,
	Physics = 4,
	ForceMove = 3,
	AirNav = 2,
	Navmesh = 1,
	Auto = 0
}
AutoPathFindUtils.SimpleMoveTargetPathFindType = {
	ForceMove = 0,
	Voxel = 1
}
AutoPathFindUtils.PATH_FINDING_SATE = {
	WaitAsyncPoint = 2,
	InActive = 0,
	Active = 4,
	WaitAsyncLastPoint = 3
}

function AutoPathFindUtils.addPathFindPoint(entity, pos, isLast, normal)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			if normal then
				eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], isLast, normal[1], normal[2], normal[3])
			else
				eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], isLast)
			end
		end
	elseif entity.serverAddPathFindPoint then
		if normal then
			entity:serverAddPathFindPoint(pos[1], pos[2], pos[3], isLast, normal[1], normal[2], normal[3])
		else
			entity:serverAddPathFindPoint(pos[1], pos[2], pos[3], isLast)
		end
	end
end

function AutoPathFindUtils.addOneComputedPathFindPointAtLast(entity, pos)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], true)
		end
	else
		entity:serverAddPathFindPoint(pos[1], pos[2], pos[3], true)
	end
end

function AutoPathFindUtils.addComputedPathFindPoint(entity, preComputePosList, normalList)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel and preComputePosList and #preComputePosList > 0 then
			local myPos = entity:getPosition()

			eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, myPos[1], myPos[2], myPos[3], false)

			for index, pos in ipairs(preComputePosList) do
				local isLast = index == #preComputePosList
				local normal = normalList and normalList[index]

				if normal then
					eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], isLast, normal[1], normal[2], normal[3])
				else
					eModel:AddPathFindPoint(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], isLast)
				end
			end
		end
	elseif preComputePosList and #preComputePosList > 0 then
		local myPos = entity:getPosition()

		entity:serverAddPathFindPoint(myPos[1], myPos[2], myPos[3], false)

		for index, pos in ipairs(preComputePosList) do
			local isLast = index == #preComputePosList
			local normal = normalList and normalList[index]

			if normal then
				entity:serverAddPathFindPoint(pos[1], pos[2], pos[3], isLast, normal[1], normal[2], normal[3])
			else
				entity:serverAddPathFindPoint(pos[1], pos[2], pos[3], isLast)
			end
		end
	end
end

function AutoPathFindUtils.getRealPathFindEndPosition(entity, refVector3)
	local eModel = entity.eModel

	if eModel then
		local x, y, z = eModel:GetPathFindRealEndPosition(CommonConst.COMPONENT_AUTO_PATH_FIND)

		refVector3:Set(x, y, z)

		return refVector3
	end

	return nil
end

function AutoPathFindUtils.startAutoPathFind(entity, pos, pathFindType, stopDist, clearOldEndPositionList, append, useAccurateArrive)
	clearOldEndPositionList = clearOldEndPositionList == nil and true or clearOldEndPositionList
	append = append == nil and true or append
	stopDist = stopDist == nil and 0.2 or stopDist

	if clearOldEndPositionList then
		entity:clearEndPosition()
	end

	entity:addEndPosition(pos)

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			if not pathFindType or pathFindType == AutoPathFindUtils.PathFindType.Auto then
				if Utils.isPet(entity, true) then
					pathFindType = AutoPathFindUtils.PathFindType.Physics
				elseif Utils.isVirtualPet(entity) or Utils.isVirtualPuppet(entity) then
					pathFindType = AutoPathFindUtils.PathFindType.Physics
				else
					pathFindType = AutoPathFindUtils.PathFindType.Auto
				end
			end

			eModel:StartAutoPathFind(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3], pathFindType, stopDist, clearOldEndPositionList, append, useAccurateArrive or false)
		end
	else
		entity:serverStartAutoPathFind(stopDist, append, pathFindType)
	end
end

function AutoPathFindUtils.startAutoPathFindWithMultiEndPos(entity, endPosList, pathFindType, stopDist, clearOldEndPositionList, append, useAccurateArrive)
	for index, pos in ipairs(endPosList) do
		if index == 1 then
			AutoPathFindUtils.startAutoPathFind(entity, pos, pathFindType, stopDist, clearOldEndPositionList, append, useAccurateArrive)
		else
			local eModel = entity.eModel

			if eModel then
				eModel:AddBackEndPosition(CommonConst.COMPONENT_AUTO_PATH_FIND, pos[1], pos[2], pos[3])
			end

			entity:addEndPosition(pos)
		end
	end
end

function AutoPathFindUtils.checkTwoPosClose(entity, x, y, z, x2, y2, z2)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			return eModel:CheckTwoPosClose(CommonConst.COMPONENT_AUTO_PATH_FIND, x, y, z, x2, y2, z2)
		end

		return false
	else
		return entity:serverCheckTwoPosClose(x, y, z, x2, y2, z2)
	end
end

function AutoPathFindUtils.isAutoPathFinding(entity)
	return entity.checkAutoPathFindingState and not entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.InActive)
end

function AutoPathFindUtils.reachEndPosition(entity)
	return entity.checkReachEndPos and entity:checkReachEndPos()
end

function AutoPathFindUtils.stopAutoPathFind(entity)
	if not Utils.checkIsAuthorityMaster(entity) then
		return
	end

	if entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.InActive) then
		return
	end

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:StopAutoPath(CommonConst.COMPONENT_AUTO_PATH_FIND, false)
		end
	else
		entity:serverStopAutoPath(false)
	end
end

function AutoPathFindUtils.isWaitAsyncResponse(entity)
	return entity.checkAutoPathFindingState and entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.WaitAsyncLastPoint)
end

function AutoPathFindUtils.getPathFindingFlags(entity)
	if not entity.checkAutoPathFindingState then
		return false, false
	end

	local isActive = not entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.InActive)

	if not isActive then
		return false, false
	end

	local isWaitAsync = entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.WaitAsyncLastPoint)

	return true, isWaitAsync
end

function AutoPathFindUtils.registerOnceMovingStartCallback(entity, func)
	local eModel = entity.eModel

	if eModel and func then
		eModel:RegisterOnceMovingStartCallback(CommonConst.COMPONENT_AUTO_PATH_FIND, func)
	end
end

function AutoPathFindUtils.registerOnceMovingEndCallback(entity, func)
	local eModel = entity.eModel

	if eModel and func then
		eModel:RegisterOnceMovingEndCallback(CommonConst.COMPONENT_AUTO_PATH_FIND, func)
	end
end

function AutoPathFindUtils.getCurrentPathFindId(entity)
	if entity.pathFindData then
		return entity.pathFindData.currentPathFindId
	end

	return AiConst.DefaultPathFindInvalidId
end

function AutoPathFindUtils.getCurrentPathMoveIndex(entity)
	if not Utils.checkIsAuthorityMaster(entity) then
		return -1
	end

	if not entity:checkAutoPathFindingState(AutoPathFindUtils.PATH_FINDING_SATE.Active) then
		return -1
	end

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			local segmentIndex = eModel:GetPathSegmentIndex(CommonConst.COMPONENT_AUTO_PATH_FIND)

			if segmentIndex >= 0 then
				segmentIndex = segmentIndex + 1
			end

			return segmentIndex
		end
	else
		return entity:serverGetPathMoveIndex()
	end

	return -1
end

function AutoPathFindUtils.setTargetAnimationState(entity, moveState, animationKey)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			animationKey = animationKey or 0

			eModel:SetTargetAnimationState(CommonConst.COMPONENT_AUTO_PATH_FIND, moveState, animationKey)
		end
	else
		entity:serverSetTargetAnimationState(moveState, animationKey)
	end
end

function AutoPathFindUtils.setTempSpeed(entity, speed)
	if speed < math.epsilon then
		return
	end

	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel.targetAutoPathSpeed = speed
		end
	else
		entity:serverSetMoveSpeed(speed)
	end
end

function AutoPathFindUtils.clearPath(entity)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:ClearPath(CommonConst.COMPONENT_AUTO_PATH_FIND)
		end
	else
		entity:serverClearPath()
	end
end

function AutoPathFindUtils.findPathToPos(entity, x, y, z, stopDist)
	Vector3.enableCreateFromCache()

	local pathFindResult = VoxelUtils.findPathToPos(entity, entity:getPosition(), Vector3(x, y, z), false)

	Vector3.disableCreateFromCache()

	if pathFindResult then
		if pathFindResult.result == VoxelConst.VoxelPathFindResultCode.PATHFIND_SUCCESS then
			return true
		elseif pathFindResult.result == VoxelConst.VoxelPathFindResultCode.PATHFIND_PART_SUCCESS and #pathFindResult.path > 0 and Vector3.HoriSqrDistance(entity:getPosition(), pathFindResult.path[#pathFindResult.path]) < (stopDist and stopDist * stopDist or AiConst.SQUARE_TARGET_POINT_STOP_DIST) then
			return true
		end
	end

	return false
end

function AutoPathFindUtils.setFaceToPos(entity, faceToPos)
	if Utils.checkClient() then
		local eModel = entity.eModel

		if eModel then
			eModel:SetFaceToPos(CommonConst.COMPONENT_AUTO_PATH_FIND, faceToPos)
		end
	else
		entity:serverSetFaceToPos(faceToPos)
	end
end

function AutoPathFindUtils.findDisplacement(srcEnt, targetEnt, placeRange, checkCollide)
	if not Utils.checkClient() then
		return false, srcEnt:getPosition()
	end

	if not srcEnt or not targetEnt then
		return false, nil
	end

	local srcPos = srcEnt:getPosition()
	local srcYaw = srcEnt:getRotation():GetEulerAnglesY()
	local srcHeight = srcEnt:getHeight() * 0.5
	local targetHeight = targetEnt:getHeight() * 0.5

	placeRange = placeRange or (srcEnt.bodySize or 0.5) + (targetEnt.bodySize or 0.5) + 1

	local checkRange = math.min(placeRange * 0.5, 1)
	local checkYaws = {
		-135,
		135,
		180,
		-90,
		90,
		-45,
		45,
		0
	}
	local resultPos = CS.FunPlus.WorldX.Navigate.NavigateUtils.FindDisplacement(srcPos, srcYaw, srcHeight, targetHeight, placeRange, checkRange, checkYaws, checkCollide)

	return true, resultPos
end

function AutoPathFindUtils.checkEntityBlock(srcEntity, targetEntity)
	if not Utils.checkClient() then
		return false
	end

	if not srcEntity or not targetEntity then
		return false
	end

	local srcEModel = srcEntity.eModel
	local targetEModel = targetEntity.eModel

	if not srcEModel or not targetEModel then
		return false
	end

	local isBlock = CS.FunPlus.WorldX.Navigate.NavigateUtils.CheckEntityBlock(srcEModel, targetEModel)

	return isBlock
end

function AutoPathFindUtils.findPhysicsDisplacement(targetEntity, srcEntity, targetPosition, targetSize)
	if not Utils.checkClient() then
		return false
	end

	if not srcEntity or not targetEntity then
		return false
	end

	local srcEModel = srcEntity.eModel
	local targetEModel = targetEntity.eModel

	if not srcEModel or not targetEModel then
		return false
	end

	local isValid, resultPos = CS.FunPlus.WorldX.Navigate.NavigateUtils.FindPhysicsDisplacement(targetEModel, srcEModel, targetPosition, targetSize)

	if isValid then
		return isValid, resultPos
	end

	return false, srcEntity:getPosition()
end

return AutoPathFindUtils
