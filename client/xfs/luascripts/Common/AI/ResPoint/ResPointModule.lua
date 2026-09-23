-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ResPoint\\ResPointModule.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ResPointConst = require("Common.Const.ResPointConst")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local ResPointModule = Class.LightClass("ResPointModule")

function ResPointModule:ctor()
	self.chunkStaticIds = {}
	self.staticRpEnts = {}
	self.resPoints = {}
	self.dynamicPoints = {}
	self.formationPoints = {}
	self.tickPoints = {}
	self.tickTimer = 0

	if Utils.checkClient() and UNITY_EDITOR then
		self.debugDrawTimer = TimerManager.addRepeatTimer(ResPointConst.DebugDrawRate, CallbackHandler(self, "_debugDraw"))
	end
end

function ResPointModule:init(space, sceneId)
	self.space = space
	self.sceneId = sceneId
end

function ResPointModule:onTick(deltaTime)
	self.tickTimer = self.tickTimer + deltaTime

	if self.tickTimer > 1 then
		self.tickTimer = 0
	else
		return
	end

	for point, _ in pairs(self.resPoints) do
		self.tickPoints[#self.tickPoints + 1] = point
	end

	for _, point in ipairs(self.tickPoints) do
		point:update()
	end

	table.clearArray(self.tickPoints)
end

function ResPointModule:onDestroy()
	if Utils.checkClient() and UNITY_EDITOR and self.debugDrawTimer ~= nil then
		TimerManager.removeTimer(self.debugDrawTimer)

		self.debugDrawTimer = nil
	end
end

function ResPointModule:onChunkLoad(chunkKey)
	if Utils.checkClient() then
		return
	end

	ResPointUtils.Log(nil, "onChunkLoad sceneId: %d, chunkKey: %s", self.sceneId, chunkKey)

	local chunkData = ResPointUtils.GetTrunkData(self.sceneId, self.space and self.space.id)[chunkKey]

	if chunkData == nil then
		return
	end

	local staticIds = chunkData.sceneResourcePoints

	if staticIds == nil then
		return
	end

	if self.chunkStaticIds[chunkKey] == nil then
		self.chunkStaticIds[chunkKey] = {}
	end

	local resPointData = ResPointUtils.GetResPointData(self.sceneId, self.space and self.space.id)

	for _, staticId in ipairs(staticIds) do
		local pointData = resPointData[staticId]

		if pointData ~= nil then
			self:__loadResPointEntity(staticId, Vector3.New(unpack(pointData.position)), pointData.yaw, pointData)
			table.insert(self.chunkStaticIds[chunkKey], staticId)
		else
			ResPointUtils.LogError("资源点的配置不存在, staticId: %d", staticId)
		end
	end
end

function ResPointModule:onChunkUnload(chunkKey)
	if Utils.checkClient() then
		return
	end

	ResPointUtils.Log(nil, "onChunkUnload sceneId: %d, chunkKey: %s", self.sceneId, chunkKey)

	local staticIds = self.chunkStaticIds[chunkKey]

	if staticIds == nil then
		return
	end

	for _, staticId in ipairs(staticIds) do
		self:__unloadResPointEntity(staticId)
	end

	self.chunkStaticIds[chunkKey] = nil
end

function ResPointModule:__loadResPointEntity(staticId, pos, yaw, rawData)
	ResPointUtils.Log(nil, "ResPointModule.__loadResPointEntity  staticId: %s", staticId)

	local content = {
		position = pos,
		rotation = Quaternion.Euler(0, yaw, 0),
		sceneId = self.sceneId,
		staticId = staticId,
		staticResPointRawData = rawData
	}
	local ent = self.space:createEntity("ResPointEntity", content, pos, Quaternion.Euler(0, yaw, 0))

	self.staticRpEnts[staticId] = ent

	return ent
end

function ResPointModule:__unloadResPointEntity(staticId)
	ResPointUtils.Log(nil, "ResPointModule.__unloadResPointEntity  staticId: %s", staticId)

	if staticId == nil or self.staticRpEnts[staticId] == nil then
		return
	end

	local entity = self.staticRpEnts[staticId]

	if Utils.checkClient() then
		local ClientUtils = require("Utils.ClientUtils")

		ClientUtils.safeDestroy(entity)
	elseif not entity.destroyed then
		entity:destroy()
	end

	self.staticRpEnts[staticId] = nil
end

function ResPointModule:__unloadAllResPointEntity()
	local curStaticIds = self:__getCurrentAllResPointStaticIds()

	for _, staticId in ipairs(curStaticIds) do
		self:__unloadResPointEntity(staticId)
	end

	self.chunkStaticIds = {}
	self.staticRpEnts = {}
	self.resPoints = {}
end

function ResPointModule:__getCurrentAllResPointStaticIds()
	local tab = {}

	for staticId, _ in pairs(self.staticRpEnts) do
		table.insert(tab, staticId)
	end

	return tab
end

function ResPointModule:getResPointEntByStaticId(staticId)
	return self.staticRpEnts[staticId]
end

function ResPointModule:getDynamicResPoints()
	return self.dynamicPoints
end

function ResPointModule:getFormationResPoints()
	return self.formationPoints
end

function ResPointModule:onResPointInit(resPoint)
	if Utils.checkClient() and resPoint.isStatic then
		self.staticRpEnts[resPoint.owner.staticId] = resPoint.owner
	end

	if not resPoint.isStatic then
		if resPoint.pointType == ResPointConst.PointType.Dynamic then
			self.dynamicPoints[resPoint] = true
		elseif resPoint.pointType == ResPointConst.PointType.Formation then
			self.formationPoints[resPoint] = true
		end
	end

	self.resPoints[resPoint] = true

	if Utils.checkClient() and UNITY_EDITOR then
		self:_setDebugInfo(resPoint, true)
	end
end

function ResPointModule:onResPointDestroy(resPoint)
	if Utils.checkClient() and resPoint.isStatic then
		self.staticRpEnts[resPoint.owner.staticId] = nil
	end

	if not resPoint.isStatic then
		if resPoint.pointType == ResPointConst.PointType.Dynamic then
			self.dynamicPoints[resPoint] = nil
		elseif resPoint.pointType == ResPointConst.PointType.Formation then
			self.formationPoints[resPoint] = nil
		end
	end

	self.resPoints[resPoint] = nil

	if Utils.checkClient() and UNITY_EDITOR then
		self:_setDebugInfo(resPoint, nil)
	end
end

local pointSize = {
	1
}
local portSize = {
	0.8
}
local pointColor = {
	a = 0.4196078431372549,
	r = 1,
	g = 0,
	b = 0
}
local portColor = {
	a = 0.4196078431372549,
	r = 0,
	g = 1,
	b = 0
}
local dirColor = {
	a = 0.6274509803921569,
	r = 0,
	g = 0,
	b = 1
}
local formationColor = {
	a = 0.4196078431372549,
	r = 1,
	g = 0.92,
	b = 0.016
}

function ResPointModule:_checkNeedDraw(point)
	if ResPointConst.DebugDrawEntActorId ~= nil and ResPointConst.DebugDrawEntActorId ~= 0 and ResPointConst.DebugDrawEntActorId ~= point.owner.actorId then
		return false
	end

	return true
end

function ResPointModule:_debugDraw()
	if not ResPointConst.OpenDebugDraw then
		return
	end

	for point, _ in pairs(self.resPoints) do
		if self:_checkNeedDraw(point) then
			self:_debugDrawPoint(point)

			if point.pointType == ResPointConst.PointType.Formation then
				self:_debugDrawFormationPos(point)
			else
				for _, port in pairs(point.ports) do
					self:_debugDrawPort(port)

					for _, dirDesc in pairs(port.dirDescs) do
						self:_debugDrawDirDesc(dirDesc)
					end
				end
			end
		end
	end
end

function ResPointModule:_debugDrawPoint(point)
	local shape_kind = 9
	local pos = point:getWorldPosition()
	local size = 1
	local duration = ResPointConst.DebugDrawRate
	local rgb = 1

	shape_kind = 1

	local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

	LxGeometryMesh.DrawMesh(pos, Quaternion.identity, shape_kind, pointSize, duration, pointColor)
end

function ResPointModule:_debugDrawPort(port)
	local shape_kind = 9
	local pos = port:getWorldPosition()
	local size = 1
	local duration = ResPointConst.DebugDrawRate
	local rgb = 1

	shape_kind = 1

	local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

	LxGeometryMesh.DrawMesh(pos, Quaternion.identity, shape_kind, portSize, duration, portColor)
end

function ResPointModule:_debugDrawDirDesc(dirDesc)
	local pos = dirDesc.owner:getWorldPosition()
	local radius = dirDesc.owner.bodySize + dirDesc.owner.interactDist
	local height = math.max(dirDesc.owner.interactMaxHeight, 0.2)
	local duration = ResPointConst.DebugDrawRate
	local rgb = 1

	if radius <= 0 then
		radius = 0.2
		rgb = 255 * math.pow(2, -8)
	end

	if dirDesc.dirLimitRefType == ResPointConst.DirRefType.NoLimit then
		local shape_kind = 1

		shape_kind = 4

		local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

		LxGeometryMesh.DrawMesh(pos, Quaternion.identity, shape_kind, {
			radius,
			height,
			height
		}, duration, dirColor)
	else
		local shape_kind = 2
		local yawDegree, halfDegree

		if dirDesc.dirLimitDescType == ResPointConst.DirDescType.FixAngle then
			halfDegree = 5
		elseif dirDesc.dirLimitDescType == ResPointConst.DirDescType.Range then
			halfDegree = (dirDesc.dirLimitParams[2] - dirDesc.dirLimitParams[1]) * 0.5
		end

		shape_kind = 5

		local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

		LxGeometryMesh.DrawMesh(pos, Quaternion.identity, shape_kind, {
			radius,
			halfDegree,
			height,
			height
		}, duration, dirColor)
	end
end

function ResPointModule:_debugDrawFormationPos(point)
	local shape_kind = 1
	local duration = ResPointConst.DebugDrawRate

	if not point.formationActorIds then
		return
	end

	local num = #point.formationActorIds
	local LxGeometryMesh = CS.FunPlus.WorldX.Physx.LxGeometryMesh

	for i = 1, num do
		local pos = Vector3.zero

		point:getFormationFollowPointWorldPosition(i, pos)
		LxGeometryMesh.DrawMesh(pos, Quaternion.identity, shape_kind, pointSize, duration, formationColor)
	end
end

function ResPointModule:_setDebugInfo(resPoint, valid)
	if self.debugBaseInfo == nil then
		self.debugBaseInfo = {}
	end

	if valid then
		local ResPointTemplateData = require("Common.Data.ResPoint.resource_point_temp_data")
		local name

		if resPoint.pointType ~= ResPointConst.PointType.Formation then
			name = (ResPointTemplateData[resPoint.templateId] or EMPTY_TABLE).name
		else
			name = "阵型资源点"
		end

		self.debugBaseInfo[resPoint] = {
			actorId = resPoint.owner.actorId,
			pointId = resPoint.pointId,
			pos = resPoint:getWorldPosition(),
			templateId = resPoint.templateId,
			name = name
		}
	else
		self.debugBaseInfo[resPoint] = nil
	end
end

function ResPointModule.debugGetCenterActorPos(actorId)
	local ent = pg.getEntityByActorId(actorId)

	if ent == nil then
		actorId = pg.me.actorId
		ent = pg.me
	end

	local ret = {
		actorId = actorId,
		pos = ent:getPosition()
	}

	return ret
end

function ResPointModule.debugGetResPointDetailInfo(actorId, pointId)
	local point = ResPointUtils.GetResPointInEntity(actorId, pointId)

	if not point then
		return
	end

	local ret = {}

	if point.isActive then
		ret.activeStatus = "已激活"
	else
		ret.activeStatus = "未激活"
	end

	ret.playerDistance = Vector3.Distance(point:getWorldPosition(), pg.me:getPosition())
	ret.activeRange = point.activeRange
	ret.inactiveRange = point.inactiveRange
	ret.photoId = point:getPhotoId()
	ret.joinInfo = {}

	for portId, port in pairs(point.ports) do
		for actorId, joinData in pairs(port.joinData) do
			local ent = pg.getEntityByActorId(actorId)
			local entPortDist = ent and Vector3.Distance(ent:getPosition(), port:getWorldPosition()) or 0

			table.insert(ret.joinInfo, {
				portId = portId,
				dirId = joinData.dirDesc.dirId,
				actorId = actorId,
				exitTime = joinData.exitTime or 0,
				exitSqrDistance = joinData.exitSqrDistance or 0,
				curDistance = entPortDist
			})
		end
	end

	local groupBehav = point.groupBehaviour

	if groupBehav == nil then
		return ret
	end

	ret.groupBehavInfo = {}
	ret.groupBehavInfo.behavName = groupBehav.behaviourName or ""
	ret.groupBehavInfo.behavCurTacheKey = groupBehav.fsm._curState._stateEnum
	ret.groupBehavInfo.behavTargetParmonBehavID = groupBehav.parmonBehavId or ""
	ret.groupBehavInfo.behavCdTime = groupBehav.cdTime
	ret.groupBehavInfo.memberInfo = {}

	for i = 1, groupBehav.maxMemberCount do
		ret.groupBehavInfo.memberInfo[i] = {
			roleType = ((groupBehav.memberData or EMPTY_TABLE)[i] or EMPTY_TABLE).roleType or "",
			actorId = (groupBehav.members[i] or EMPTY_TABLE).actorId or 0
		}
	end

	ret.groupBehavInfo.tacheInfo = {}

	for tacheKey, tache in pairs(groupBehav.taches) do
		ret.groupBehavInfo.tacheInfo[#ret.groupBehavInfo.tacheInfo + 1] = {
			tacheKey = tacheKey,
			tacheTimeout = tache.timeoutTime,
			tacheRunningTime = tache.startTime and Time.realSecondCache - tache.startTime or 0
		}
	end

	return ret
end

function ResPointModule.debugGetResPointPortInRange(entityActorId, range, maxDeltaHeight, pointTag, portTag)
	local pointTags = string.isNilOrEmpty(pointTag) and {} or {
		pointTag
	}
	local portTags = string.isNilOrEmpty(portTag) and {} or {
		portTag
	}

	return ResPointUtils.DebugGetResPointPortInRange(entityActorId, range, maxDeltaHeight, pointTags, portTags)
end

return ResPointModule
