-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\NavMeshServiceUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local NavMeshServiceUtils = Class.OldLightClass("NavMeshServiceUtils", nil, true)
local Utils = require("Common.Utils.Utils")
local bit = require("bit")
local logger = LoggerManager.getLogger("NavMeshServiceUtils")
local sqrt = math.sqrt
local errorNavMeshRequestList = {}
local isOpenErrorProcess = false

NavMeshServiceUtils.AreaMaskType = {
	ConditionPath_ButterflyRoad = 64,
	ConditionPath_HideCave = 128
}

function NavMeshServiceUtils:ctor()
	self.navMeshServiceRequestId = AiConst.NAVMESH_SERVICE.REQ_MIN_ID
	errorNavMeshRequestList[AiConst.SERVICE_REQUEST_TYPE.FIND_PATH] = {}
	errorNavMeshRequestList[AiConst.SERVICE_REQUEST_TYPE.FIDN_RANDOM_POINT] = {}
	errorNavMeshRequestList[AiConst.SERVICE_REQUEST_TYPE.FIND_SAMPLE_POSITION] = {}
	errorNavMeshRequestList[AiConst.SERVICE_REQUEST_TYPE.RAYCAST_HIT] = {}
	self.areaCosts = {
		0.8,
		1,
		2,
		0.4,
		10,
		1
	}
	self.areaMask = 63
end

function NavMeshServiceUtils.ensureAreaMaskNotNil(singleton)
	if singleton.areaMask == nil then
		singleton.areaMask = 63
	end
end

function NavMeshServiceUtils.switchOnAreaMask(areaMaskValue)
	if not areaMaskValue then
		return
	end

	local singleton = NavMeshServiceUtils.GetInstance()

	NavMeshServiceUtils.ensureAreaMaskNotNil(singleton)

	singleton.areaMask = bit.bor(singleton.areaMask, areaMaskValue)
end

function NavMeshServiceUtils.switchOffAreaMask(areaMaskValue)
	if not areaMaskValue then
		return
	end

	local singleton = NavMeshServiceUtils.GetInstance()

	NavMeshServiceUtils.ensureAreaMaskNotNil(singleton)

	singleton.areaMask = bit.band(singleton.areaMask, bit.bnot(areaMaskValue))
end

function NavMeshServiceUtils.getNewReqId()
	local singleton = NavMeshServiceUtils.GetInstance()

	if singleton.navMeshServiceRequestId == AiConst.NAVMESH_SERVICE.REQ_MAX_ID then
		singleton.navMeshServiceRequestId = AiConst.NAVMESH_SERVICE.REQ_MIN_ID
	end

	singleton.navMeshServiceRequestId = singleton.navMeshServiceRequestId + 1

	return singleton.navMeshServiceRequestId
end

function NavMeshServiceUtils.checkRequestData(startPos, endPos)
	for _, errorPos in ipairs(errorNavMeshRequestList[AiConst.SERVICE_REQUEST_TYPE.FIND_PATH]) do
		local distance1 = sqrt((startPos[1] - errorPos[1][1])^2 + (startPos[2] - errorPos[1][2])^2 + (startPos[3] - errorPos[1][3])^2)
		local distance2 = sqrt((endPos[1] - errorPos[2][1])^2 + (endPos[2] - errorPos[2][2])^2 + (endPos[3] - errorPos[2][3])^2)

		if distance1 <= 1 and distance2 <= 1 then
			return false
		end
	end

	return true
end

function NavMeshServiceUtils.findPath(sceneId, startPos, endPosList, callback, disableMultiPassPoint, exceedDistance)
	exceedDistance = exceedDistance or 30

	if disableMultiPassPoint == nil then
		disableMultiPassPoint = true
	end

	if AiConst.AI_DEBUG.NAVMESH_LOG and LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("====== findPathCallback: ", startPos, endPosList)
	end

	if not Utils.checkClient() then
		return
	end

	if isOpenErrorProcess and NavMeshServiceUtils.checkRequestData(startPos, endPosList) then
		return false
	end

	local mainPlayer = pg.me
	local singleton = NavMeshServiceUtils.GetInstance()

	if mainPlayer then
		if startPos and type(startPos) == "table" and #startPos ~= 3 then
			startPos = {
				startPos[1] or 0,
				startPos[2] or 0,
				startPos[3] or 0
			}
		end

		NavMeshServiceUtils.ensureAreaMaskNotNil(singleton)
		mainPlayer:callService("NavmeshService", "findPath", {
			sceneId,
			startPos,
			endPosList,
			disableMultiPassPoint,
			singleton.areaCosts,
			singleton.areaMask
		}, function(status, response)
			if AiConst.AI_DEBUG.NAVMESH_LOG and LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("###### sceneId=%s, startPos=%s, endPosList=%s, disableMultiPassPoint=%s, areaCosts=%s, areaMask=%s, status=%s, response=%s", sceneId, inspect(startPos), inspect(endPosList), disableMultiPassPoint, inspect(singleton.areaCosts), inspect(singleton.areaMask), inspect(status), inspect(response))
			end

			local GlobalData = require("Core.Client.GlobalData")

			if GlobalData.Space == nil then
				return
			end

			local curSceneId = GlobalData.Space.sceneId

			if status.status ~= true then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("====== findPathCallback service error: ", status.errmsg)
				end

				callback(AiConst.AUTO_PATH_REQ_STATE.ServiceError, response and response.Path or nil)
			elseif not response or not response.Path or #response.Path == 0 then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("====== findPathCallback service path error...: ", inspect(startPos))
				end

				callback(AiConst.AUTO_PATH_REQ_STATE.ServicePathNotFound, response and response.Path or nil)
			else
				local state = AiConst.AUTO_PATH_REQ_STATE.Success

				if response.IsPartial and response.Path and #response.Path >= 2 then
					local lastPoint = response.Path[#response.Path]
					local prevPoint = response.Path[#response.Path - 1]
					local dx = lastPoint[1] - prevPoint[1]
					local dy = lastPoint[2] - prevPoint[2]
					local dz = lastPoint[3] - prevPoint[3]
					local distance = sqrt(dx * dx + dy * dy + dz * dz)

					if distance > exceedDistance then
						state = AiConst.AUTO_PATH_REQ_STATE.PartialSuccessExceedDistance
					else
						state = AiConst.AUTO_PATH_REQ_STATE.PartialSuccess
					end
				end

				callback(state, response.Path)
			end
		end)

		return true
	end

	return false
end

function NavMeshServiceUtils.isResponseStateSuccess(state)
	return state == AiConst.AUTO_PATH_REQ_STATE.Success or state == AiConst.AUTO_PATH_REQ_STATE.PartialSuccess
end

function NavMeshServiceUtils.findHighestNavMeshPoint(sceneId, startPos, callback)
	if AiConst.AI_DEBUG.NAVMESH_LOG and LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("====== findHighestNavMeshPoint: ", startPos)
	end

	if not Utils.checkClient() then
		return
	end

	local mainPlayer = pg.me

	if mainPlayer then
		mainPlayer:callService("NavmeshService", "findHighestPointInNavMesh", {
			sceneId,
			startPos
		}, function(status, response)
			local curSceneId = require("Core.Client.GlobalData").Space.sceneId

			if status.status ~= true then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("====== findHighestNavMeshPoint service error: ", status.errmsg)
				end

				callback(AiConst.AUTO_PATH_REQ_STATE.ServiceError, response.HighestPoint)
			elseif not response.HighestPoint or #response.HighestPoint == 0 then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("====== findHighestPointInNavMesh service path error...: ", inspect(startPos))
				end

				callback(AiConst.AUTO_PATH_REQ_STATE.ServicePathNotFound, response.HighestPoint)
			elseif sceneId ~= curSceneId then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("====== findHighestPointInNavMesh scene has changed ", curSceneId, sceneId)
				end

				callback(AiConst.AUTO_PATH_REQ_STATE.SceneIdNotMatch, response.HighestPoint)
			else
				callback(AiConst.AUTO_PATH_REQ_STATE.Success, response.HighestPoint)
			end
		end)

		return true
	end

	return false
end

return NavMeshServiceUtils
