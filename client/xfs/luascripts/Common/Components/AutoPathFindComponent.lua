-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AutoPathFindComponent.lua

local class = require("Core.Framework.Class")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local NavMeshServiceUtils = require("Common.Utils.NavMeshServiceUtils")
local AiConst = require("Common.Const.AiConst")
local Time = require("Core.Common.Time")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Const = require("Common.Const.Const")
local AutoPathFindComponent = class.Component("AutoPathFindComponent")
local AUTOPATHSTATE = {
	WaitNavmeshRandomPositionService = 3,
	WaitNavmeshRaycastHitService = 2,
	WaitNavmeshFindClosePositionService = 1
}
local navmeshServiceRequestTimeOut = 500

function AutoPathFindComponent:ctor()
	self.pathFindData = {
		currentPathFindId = 0,
		reachEndPos = false,
		navmeshServiceLastTimeStampMap = {},
		pathFindState = AutoPathFindUtils.PATH_FINDING_SATE.InActive,
		endPosList = {}
	}
end

function AutoPathFindComponent:destroy()
	return
end

function AutoPathFindComponent:startNavmeshPathFind(reqId)
	NavMeshServiceUtils.findPath(self.space.sceneId, self:getPosition(), self.pathFindData.endPosList, CallbackHandlerNoGC.newOnce(self, self._navmeshPathFindCallback, reqId, self.pathFindData.endPosList))
end

function AutoPathFindComponent:_navmeshPathFindCallback(reqId, endPosList, aiAutoPathReqState, path)
	if reqId ~= AutoPathFindUtils.getCurrentPathFindId(self) then
		return
	end

	if aiAutoPathReqState == AiConst.AUTO_PATH_REQ_STATE.Success then
		AutoPathFindUtils.addComputedPathFindPoint(self, path)
	end
end

function AutoPathFindComponent:checkNavmeshServiceRequestNoTimeout(serverState)
	local serverStateTimeStamp = self.pathFindData.navmeshServiceLastTimeStampMap[serverState] or 0
	local currentTimeStamp = Time.realSecondCache * 1000

	return currentTimeStamp < serverStateTimeStamp or currentTimeStamp > serverStateTimeStamp + navmeshServiceRequestTimeOut
end

function AutoPathFindComponent:setNavmeshServiceLastRequestTimestamp(serverState)
	self.pathFindData.navmeshServiceLastTimeStampMap[serverState] = Time.realSecondCache * 1000
end

function AutoPathFindComponent:onAutoPathStateChange(oldState, newState, pathFindReqId, pathFindType, reachEndPos)
	if self.pathFindData then
		self.pathFindData.pathFindState = newState
		self.pathFindData.currentPathFindId = pathFindReqId

		self:setReachEndPos(reachEndPos)
	end

	if newState == AutoPathFindUtils.PATH_FINDING_SATE.WaitAsyncPoint and pathFindType == AutoPathFindUtils.PathFindType.Navmesh then
		self:startNavmeshPathFind(pathFindReqId)
	end

	if newState == AutoPathFindUtils.PATH_FINDING_SATE.InActive then
		self:clearEndPosition()
	end
end

function AutoPathFindComponent:checkAutoPathFindingState(state)
	return self.pathFindData.pathFindState == state
end

function AutoPathFindComponent:checkReachEndPos()
	return self.pathFindData.reachEndPos
end

function AutoPathFindComponent:setReachEndPos(reachEndPos)
	self.pathFindData.reachEndPos = reachEndPos or false
end

function AutoPathFindComponent:pawnAutoPathFinding(endPos, arriveCallback, pathFindType, posList, targetState, useAccurateArrive, stopDist)
	if self.authority ~= Const.AUTHORITY_MASTER then
		return false
	end

	if not self:checkStatus_check("PATHFINDING", true) then
		return false
	end

	pathFindType = pathFindType or AutoPathFindUtils.PathFindType.Voxel

	AutoPathFindUtils.startAutoPathFind(self, endPos, pathFindType, stopDist, true, true, useAccurateArrive)

	if targetState then
		AnimationUtils.playAnimationState(self, targetState)
		AutoPathFindUtils.setTargetAnimationState(self, targetState)
	end

	AutoPathFindUtils.registerOnceMovingEndCallback(self, function(arrived)
		if arriveCallback then
			arriveCallback(arrived)
		end
	end)

	if pathFindType == AutoPathFindUtils.PathFindType.ForceMove then
		if posList then
			AutoPathFindUtils.addComputedPathFindPoint(self, posList)
		else
			AutoPathFindUtils.addOneComputedPathFindPointAtLast(self, endPos)
		end
	end

	AutoPathFindUtils.setFaceToPos(self, true)

	return true
end

function AutoPathFindComponent:clearEndPosition()
	if self.pathFindData then
		for index, _ in ipairs(self.pathFindData.endPosList) do
			self.pathFindData.endPosList[index] = nil
		end
	end
end

function AutoPathFindComponent:addEndPosition(pos)
	self.pathFindData.endPosList[#self.pathFindData.endPosList + 1] = pos
end

return AutoPathFindComponent
