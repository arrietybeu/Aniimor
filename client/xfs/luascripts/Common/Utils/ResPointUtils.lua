-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ResPointUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ResPointConst = require("Common.Const.ResPointConst")
local SceneUtils = require("Common.Utils.SceneUtils")
local logger = LoggerManager.getLogger("ResPoint")
local TimerManager = require("Core.Timer.TimerManager")
local ListPool = require("Common.Container.ListPool")
local AIUtils = require("Common.Utils.AIUtils")
local ResPointUtils = {}
local EMPTY_TABLE = {}
local id_multiplier = 1024
local actor_id_offset = 524288
local point_id_offset = 512

function ResPointUtils.ToFixPointId(actorId, pointId)
	if Utils.checkClient() and UNITY_EDITOR and (math.abs(actorId) >= actor_id_offset or math.abs(pointId) >= point_id_offset) then
		ResPointUtils.LogError("资源点ID超限! actorId: %d, pointId: %d", actorId, pointId)
	end

	return (actorId + actor_id_offset) * id_multiplier + (pointId + point_id_offset)
end

function ResPointUtils.FromFixPointId(fixPointId)
	if not fixPointId then
		return 0, 0
	end

	local fixId1 = math.modf(fixPointId / id_multiplier)
	local fixId2 = fixPointId - fixId1 * id_multiplier
	local actorId = fixId1 - actor_id_offset
	local pointId = fixId2 - point_id_offset
	local ent = pg and pg.getEntityByActorId(actorId)

	if ent and ent.resPoints and ent.resPoints[pointId] then
		return actorId, pointId
	end

	if not Utils.checkClient() then
		return actorId, pointId
	end

	local int32_cycle = 4294967296
	local actor_id_cycle = 4194304
	local int32FixPointId = fixPointId

	if int32FixPointId < 0 then
		int32FixPointId = int32FixPointId + int32_cycle
	end

	if int32FixPointId < 0 or int32_cycle <= int32FixPointId then
		return actorId, pointId
	end

	local wrappedFixId1 = math.floor(int32FixPointId / id_multiplier)
	local wrappedFixId2 = int32FixPointId - wrappedFixId1 * id_multiplier
	local wrappedActorId = wrappedFixId1 - actor_id_offset
	local wrappedPointId = wrappedFixId2 - point_id_offset
	local resPoints = pg and pg.space and pg.space.aiMgr and pg.space.aiMgr.resPointModule and pg.space.aiMgr.resPointModule.resPoints

	if not resPoints then
		return actorId, pointId
	end

	for resPoint in pairs(resPoints) do
		local ownerActorId = resPoint.owner and resPoint.owner.actorId

		if ownerActorId and resPoint.pointId == wrappedPointId and ownerActorId % actor_id_cycle == wrappedActorId % actor_id_cycle then
			return ownerActorId, wrappedPointId
		end
	end

	return actorId, pointId
end

function ResPointUtils.GetTrunkData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, "scene_resource_point_chunk_data", spaceId)
end

function ResPointUtils.GetResPointData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, "scene_resource_point_data", spaceId)
end

function ResPointUtils.GetResPointsInEntity(actorId)
	local ent = pg.getEntityByActorId(actorId)

	return ent and ent.resPoints
end

function ResPointUtils.GetResPointInEntity(actorId, pointId)
	local resPoints = ResPointUtils.GetResPointsInEntity(actorId)

	return resPoints and resPoints[pointId]
end

function ResPointUtils.GetPortsInResPoint(actorId, pointId)
	local resPoint = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return resPoint and resPoint.ports
end

function ResPointUtils.GetPortInResPoint(actorId, pointId, portId)
	local ports = ResPointUtils.GetPortsInResPoint(actorId, pointId)

	return ports and ports[portId]
end

local function _checkPointHasTag(point, pointTag)
	return point:hasPointTag(pointTag)
end

local function _checkPortHasTag(port, portTag)
	return port:hasPortTag(portTag)
end

local function _hasTags(obj, tags, checkFunc)
	if obj == nil then
		return false
	end

	if not tags or #tags == 0 then
		return true
	end

	for _, tag in ipairs(tags) do
		if checkFunc(obj, tag) then
			return true
		end
	end

	return false
end

local function _checkPointValid(resPoint, entPos, range, maxDeltaHeight, pointTags)
	if not resPoint:canBeSearch() then
		return false, ResPointConst.SearchFailReason.CAN_NOT_BE_SEARCH
	end

	local rpPos = resPoint:getWorldPosition()

	if maxDeltaHeight > 0 and maxDeltaHeight < math.abs(rpPos[2] - entPos[2]) then
		return false, ResPointConst.SearchFailReason.HEIGHT_EXCEED
	end

	if range < math.abs(rpPos[1] - entPos[1]) or range < math.abs(rpPos[3] - entPos[3]) then
		return false, ResPointConst.SearchFailReason.RANGE_EXCEED
	end

	if not _hasTags(resPoint, pointTags, _checkPointHasTag) then
		return false, ResPointConst.SearchFailReason.POINT_TAG_NOT_MATCH
	end

	return true
end

local function _checkPortValid(resPointPort, portTags)
	if resPointPort:isFull() then
		return false, ResPointConst.SearchFailReason.PORT_FULL
	end

	if not _hasTags(resPointPort, portTags, _checkPortHasTag) then
		return false, ResPointConst.SearchFailReason.PORT_TAG_NOT_MATCH
	end

	return true
end

function ResPointUtils.GetResPointPortInRange(entityActorId, range, maxDeltaHeight, pointTags, portTags, resultTable)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent == nil or ent.space == nil then
		return false
	end

	local resPoints = ListPool.getList(3)
	local staticRpEnt
	local staticRpActorIds = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(ent, range, Const.SEARCH_USR_TYPE_RESPOINT, staticRpActorIds)

	for i = 1, count do
		staticRpEnt = pg.getEntityByActorId(staticRpActorIds[i])

		if staticRpEnt and staticRpEnt.resPoints then
			for _, resPoint in pairs(staticRpEnt.resPoints) do
				resPoints[#resPoints + 1] = resPoint
			end
		end
	end

	ListPool.returnList(staticRpActorIds, 3)

	local aiMgr = ent.space.aiMgr

	if aiMgr then
		local dynamicRps = aiMgr.resPointModule:getDynamicResPoints()

		for point, _ in pairs(dynamicRps) do
			resPoints[#resPoints + 1] = point
		end
	end

	local selfPos = ent:getPosition()

	for _, resPoint in ipairs(resPoints) do
		local pointValid = _checkPointValid(resPoint, selfPos, range, maxDeltaHeight, pointTags)

		if pointValid then
			local resPointPorts = resPoint.ports or EMPTY_TABLE

			for _, resPointPort in pairs(resPointPorts) do
				local portValid = _checkPortValid(resPointPort, portTags)

				if portValid then
					table.insert(resultTable, resPointPort:getPortIdTable())
				end
			end
		end
	end

	ListPool.returnList(resPoints, 3)

	if #resultTable > 0 then
		ResPointUtils.Log(entityActorId, "ResPointUtils.GetResPointPortInRange, entityActorId: %d, range: %f, maxDeltaHeight: %f, resultNum: %s", entityActorId, range, maxDeltaHeight, #resultTable)
	end

	return resultTable
end

function ResPointUtils.GetNearestInteractPosition(entityActorId, targetActorId, pointId, portId, lockDirDescId)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		local ret, pos, dirDescId = port:getNearestInteractPosition(entityActorId, lockDirDescId)

		if ret then
			return pos, dirDescId
		end
	end
end

function ResPointUtils.GetNearestInteractPositionInDist(entityActorId, targetActorId, pointId, portId, lockDirDescId, interactDist, ignoreSelfBodySize, ignorePointBodySize)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		local ret, pos, dirDescId = port:getNearestInteractPositionInDist(entityActorId, lockDirDescId, interactDist, ignoreSelfBodySize, ignorePointBodySize)

		if ret then
			return pos, dirDescId
		end
	end
end

function ResPointUtils.GetInteractDirectionYaw(entityActorId, targetActorId, pointId, portId)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		return port:getInteractDirectionYaw(entityActorId)
	end
end

function ResPointUtils.PreJoinPort(entityActorId, targetActorId, pointId, portId, lockDirDescId)
	if lockDirDescId == nil then
		local pos, dirDescId = ResPointUtils.GetNearestInteractPosition(entityActorId, targetActorId, pointId, portId, nil)

		if pos and dirDescId then
			lockDirDescId = dirDescId
		else
			ResPointUtils.Log("unknown reason cause pre join failed! maybe group behaviour...")

			return false
		end
	end

	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		return port:preJoin(entityActorId, lockDirDescId)
	end

	return false
end

function ResPointUtils.GetPreJoinPortDirDescId(entityActorId, targetActorId, pointId, portId)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		return port:getPreJoinDirDescId(entityActorId)
	end
end

function ResPointUtils.CheckCanInteract(entityActorId, targetActorId, pointId, portId)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		return port:checkCanInteract(entityActorId)
	end

	return false
end

function ResPointUtils.JoinPort(entityActorId, targetActorId, pointId, portId)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		port:join(entityActorId)
	end
end

function ResPointUtils.ExitPort(entityActorId, targetActorId, pointId, portId, delayTime, exitDistance)
	local port = ResPointUtils.GetPortInResPoint(targetActorId, pointId, portId)

	if port then
		port:exit(entityActorId, delayTime, exitDistance)
	end
end

function ResPointUtils.GetRouteIdFromResPoint(actorId, pointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return point and point:getRouteId() or 0
end

function ResPointUtils.GetRouteIdFromResPointWithIndex(actorId, pointId, index)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return point and point:getRouteIdWithIndex(index) or 0
end

function ResPointUtils.GetGroupBehaviourFromResPoint(actorId, pointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return point and point.groupBehaviour
end

function ResPointUtils.GetRouteIdFromEntity(actorId)
	local ent = pg.getEntityByActorId(actorId)

	return ent and ent.routeId or 0
end

function ResPointUtils.GetClimbDataIdFromResPoint(actorId, pointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return point and point:getClimbDataId() or 0
end

function ResPointUtils.CanPhoto(fixPointId)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	return point and point:canPhoto()
end

function ResPointUtils.EnterPhotoEcology(fixPointId, puppetActorId)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	if point then
		point:tryEnterPhotoEcology({
			puppetActorId
		})
	end
end

function ResPointUtils.ExitPhotoEcology(fixPointId)
	local actorId, pointId = ResPointUtils.FromFixPointId(fixPointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	if point then
		point:tryExitPhotoEcology()
	end
end

function ResPointUtils.RefreshPhotoMessage()
	if Utils.checkClient() and pg.space and pg.space.aiMgr then
		local points = pg.space.aiMgr.resPointModule.resPoints

		for point, _ in pairs(points) do
			point:refreshPhotoMessage()
		end
	end
end

function ResPointUtils.ActivatePointByScene(staticId, enable)
	if Utils.checkClient() and pg.space and pg.space.aiMgr then
		local rpEnt = pg.space.aiMgr.resPointModule:getResPointEntByStaticId(staticId)

		if rpEnt then
			local resPoints = rpEnt.resPoints or EMPTY_TABLE

			for _, point in pairs(resPoints) do
				point:activeByScene(enable)
			end
		end
	end
end

function ResPointUtils.JoinFormationFollow(entityActorId, targetActorId)
	local point = ResPointUtils.GetResPointInEntity(targetActorId, ResPointConst.FormationPointIndex)

	if point then
		return point:joinFormationFollow(entityActorId)
	end

	return false
end

function ResPointUtils.ExitFormationFollow(entityActorId, targetActorId)
	local point = ResPointUtils.GetResPointInEntity(targetActorId, ResPointConst.FormationPointIndex)

	if point then
		return point:exitFormationFollow(entityActorId)
	end

	return false
end

function ResPointUtils.DebugGetResPointPortInRange(entityActorId, range, maxDeltaHeight, pointTags, portTags)
	local ent = pg.getEntityByActorId(entityActorId)

	if ent == nil or ent.space == nil then
		return
	end

	local result = {}
	local resPoints = ListPool.getList(3)
	local staticRpEnt
	local staticRpActorIds = ListPool.getList(3)
	local count = AIUtils.SearchEntitiesInRangeWithCache(ent, range, Const.SEARCH_USR_TYPE_RESPOINT, staticRpActorIds)

	for i = 1, count do
		staticRpEnt = pg.getEntityByActorId(staticRpActorIds[i])

		if staticRpEnt and staticRpEnt.resPoints then
			for _, resPoint in pairs(staticRpEnt.resPoints) do
				resPoints[#resPoints + 1] = resPoint
			end
		end
	end

	ListPool.returnList(staticRpActorIds, 3)

	local aiMgr = pg.space and pg.space.aiMgr

	if aiMgr then
		local dynamicRps = aiMgr.resPointModule:getDynamicResPoints()

		for point, _ in pairs(dynamicRps) do
			resPoints[#resPoints + 1] = point
		end
	end

	local selfPos = ent:getPosition()

	for _, resPoint in ipairs(resPoints) do
		local actorId = resPoint.owner.actorId
		local pointId = resPoint.pointId
		local pointValid, failReason = _checkPointValid(resPoint, selfPos, range, maxDeltaHeight, pointTags)

		if pointValid then
			local resPointPorts = resPoint.ports or EMPTY_TABLE

			for portId, resPointPort in pairs(resPointPorts) do
				local portValid, failReason2 = _checkPortValid(resPointPort, portTags)

				if portValid then
					table.insert(result, {
						actorId = actorId,
						pointId = pointId,
						portId = portId,
						reason = ResPointConst.SearchFailReason.NONE
					})
				else
					table.insert(result, {
						actorId = actorId,
						pointId = pointId,
						portId = portId,
						reason = failReason2
					})
				end
			end
		else
			table.insert(result, {
				portId = 0,
				actorId = actorId,
				pointId = pointId,
				reason = failReason
			})
		end
	end

	ListPool.returnList(resPoints, 3)

	return result
end

function ResPointUtils.Log(entActorId, ...)
	if not ResPointConst.OpenLog then
		return
	end

	if entActorId ~= nil and ResPointConst.DebugLogEntActorId ~= nil and ResPointConst.DebugLogEntActorId ~= 0 and entActorId ~= ResPointConst.DebugLogEntActorId then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info(...)
	end
end

function ResPointUtils.LogError(...)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(...)
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(debug.traceback())
	end
end

function ResPointUtils.LogWithPoint(entActorId, point, formatStr, ...)
	if ResPointConst.OpenLog then
		formatStr = string.format("[Point][Temp:%d][%d,%d] %s", point.templateId, point.owner.actorId, point.pointId, formatStr)

		ResPointUtils.Log(entActorId, formatStr, ...)
	end
end

function ResPointUtils.LogWithPort(entActorId, port, formatStr, ...)
	if ResPointConst.OpenLog then
		formatStr = string.format("[Port][Temp:%d][%d,%d,%d] %s", port.owner.templateId, port.owner.owner.actorId, port.owner.pointId, port.portId, formatStr)

		ResPointUtils.Log(entActorId, formatStr, ...)
	end
end

function ResPointUtils.LogWithDirDesc(entActorId, dirDesc, formatStr, ...)
	if ResPointConst.OpenLog then
		formatStr = string.format("[DirDecs][Temp:%d][%d,%d,%d,%d] %s", dirDesc.owner.owner.templateId, dirDesc.owner.owner.owner.actorId, dirDesc.owner.owner.pointId, dirDesc.owner.portId, dirDesc.dirId, formatStr)

		ResPointUtils.Log(entActorId, formatStr, ...)
	end
end

return ResPointUtils
