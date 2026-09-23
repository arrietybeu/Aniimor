-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Seamless\\SeamlessSystem.lua

local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("SeamlessSystem")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local SeamlessSystem = Class.LightClass("SeamlessSystem", SystemBase)
local SceneUtils = require("Common.Utils.SceneUtils")
local SceneSeamlessData = require("Data.scene_seamless_data")
local RegionSyncData = require("Data.region_sync_config_data")
local SceneData = require("Data.scene_data")
local MapLineData = require("Data.map_line_config_data")
local MapLevelConfigLoadData = require("Data.map_level_config_load_data")
local Const = require("Common.Const.Const")
local InteractionConst = require("Common.Const.InteractionConst")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local CoreConst = require("Core.Common.Const")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local CommonSwitch = require("Common.CommonSwitch")
local EModelUtils = require("Entities.Utils.EModelUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local areaManager = appFacade.areaManager
local Vector3 = Vector3
local Vector2 = Vector2
local Quaternion = Quaternion
local entityManager = appFacade.entityManager
local AREA_OFFSET_Y = 1

function SeamlessSystem:onCtor()
	self.airWallRoot = CS.UnityEngine.GameObject("AirWallRoot").transform

	CS.UnityEngine.Object.DontDestroyOnLoad(self.airWallRoot)

	self.__seamlessAreas = {}
	self._currentTrigger = nil
	self.__isInSwitching = false
	self.__LastTipArea = nil
	self.tempPlayer = nil
	self.tempNpcEModel = {}
	self.tempNpcRecreate = {}
end

function SeamlessSystem:getMessageBindMap()
	return {
		[MessageName.RELOAD_CURRENT_SCENE] = "onStartReloadCurScene"
	}
end

function SeamlessSystem:onSceneLoaded(sceneId, sceneName)
	self:seam_sys_clearRuntimeAreas()

	if pg.me == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@zqd pg.me is nil! can't start check seamless area.")
		end
	else
		pg.me:seamless_startSeamlessCheck()
	end

	self.__seamlessMainSceneId = SceneUtils.getMainSceneId(sceneId)
	self.__isDynamicSeamless = pg.me and pg.me.isDynamicPhase or false
	self.__isEventSeamless = false

	self:seam_sys_updateSeamlessType(sceneId)
	self:seam_sys_onInitBranchAreas(sceneId)
	self:seam_sys_onInitSeamlessAreas(sceneId)
	self:seam_sys_onInitRegionAreas()
	self:seam_sys_onInitDynamicArea(sceneId)
	self:seam_sys_onInitMapLayerAreas(sceneId)

	self.__recorderSeamlessSceneId = sceneId

	self:seam_sys_initDefaultCacheArea()
	self:seam_sys_checkEnterMappingRegion()
end

function SeamlessSystem:onSceneUnloaded(sceneId, sceneName)
	if pg.me then
		pg.me:seamless_endSeamlessCheck()
	end

	self:seam_sys_clearRuntimeAreas()
	pg.game.interaction:onLeaveTriggerWithType(InteractionConst.INTERACTION_TYPE_BRANCH_LINE_AREA)
end

function SeamlessSystem:onStartReloadCurScene()
	if pg.me == nil then
		return
	end

	pg.me:seamless_endSeamlessCheck()
end

function SeamlessSystem:onSceneReset(sceneId)
	if pg.me == nil then
		return
	end

	pg.me:seamless_startSeamlessCheck()
end

function SeamlessSystem:seam_sys_initDefaultCacheArea()
	local sceneId = pg.space.sceneId

	if not Utils.isSpacePhase(sceneId) then
		return
	end

	local cData = SceneData[sceneId]

	if cData == nil then
		return
	end

	local areaId = cData.seamlessRange and cData.seamlessRange[1]
	local oldTrigger = self._currentTrigger or {}

	if areaId == oldTrigger.areaId then
		return
	end

	self._currentTrigger = {
		isEnter = false,
		areaId = areaId
	}
end

function SeamlessSystem:seam_sys_removeSingleArea(areaId)
	local areaData = self.__seamlessAreas[areaId]

	if areaData == nil then
		return
	end

	self:seam_sys_removeArea(areaId)

	if areaData.airInstances == nil then
		return
	end

	for _, subV in ipairs(areaData.airInstances) do
		pg.global.resMgr:RemoveInstanceToCache(subV, true)
	end
end

function SeamlessSystem:seam_sys_updateSeamlessType(sceneId)
	local sData = SceneData[sceneId]

	if sData == nil then
		self.__isEventSeamless = true

		return
	end

	self.__isEventSeamless = sData.autoCutSeamless ~= 1
end

function SeamlessSystem:seam_sys_onInitBranchAreas(sceneId)
	local cData = MapLineData[sceneId]

	if cData == nil or cData.switchInstance == nil then
		return
	end

	for _, areaId in ipairs(cData.switchInstance) do
		self:seam_sys_addAreaById(areaId)
	end
end

function SeamlessSystem:seam_sys_onInitMapLayerAreas(sceneId)
	local cData = MapLevelConfigLoadData[sceneId]

	if cData == nil then
		return
	end

	for staticId, _ in pairs(cData) do
		self:seam_sys_addAreaById(staticId)
	end
end

function SeamlessSystem:seam_sys_onInitRegionAreas()
	local mainSceneId = self.__seamlessMainSceneId
	local areaTb = SceneUtils.getSceneAreaData(mainSceneId)

	if areaTb == nil then
		return
	end

	for _, areaData in pairs(areaTb) do
		if self:seam_sys_isMappingRegionType(areaData.areaLoadType) then
			self:seam_sys_addSceneAreaCom(areaData, mainSceneId, false)
		end
	end
end

function SeamlessSystem:seam_sys_onInitSeamlessAreas(sceneId)
	local cData = SceneSeamlessData[self.__seamlessMainSceneId]

	if cData == nil then
		return
	end

	local group = cData.seamlessGroup

	if group == nil then
		return
	end

	for _, v in pairs(group) do
		if v.autoCutSeamless == 1 then
			self:seam_sys_addSceneAreaInternal(v, false)
		end
	end
end

function SeamlessSystem:seam_sys_onInitDynamicArea(sceneId)
	if not self:seam_sys_isSwitchSeamless() then
		return
	end

	self:seam_sys_addDynamicArea(sceneId, self.__isDynamicSeamless)
end

function SeamlessSystem:seam_sys_addDynamicArea(sceneId, dynamic)
	self.__isDynamicSeamless = dynamic

	self:seam_sys_updateSeamlessType(sceneId)

	local mainSceneId = SceneUtils.getMainSceneId(sceneId)
	local cData = SceneSeamlessData[mainSceneId]

	if cData == nil then
		return
	end

	local group = cData.seamlessGroup

	if group == nil then
		return
	end

	local seamlessData = group[sceneId]

	if seamlessData then
		self:seam_sys_addSceneAreaInternal(seamlessData, dynamic)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("@zqd 位面区域配置数据错误: ", tostring(sceneId))
	end
end

function SeamlessSystem:seam_sys_removeDynamicArea(sceneId)
	local cData = SceneData[sceneId]

	if cData == nil then
		return
	end

	local group = cData.seamlessRange

	if group == nil then
		return
	end

	self:seam_sys_removeSingleArea(group[1])
end

function SeamlessSystem:seam_sys_checkAreaOverlap(areaData)
	self:seam_sys_parseOverlapPos(areaData)

	local res_flag = false

	for _, v in pairs(self.__seamlessAreas) do
		self:seam_sys_parseOverlapPos(v)

		if v.areaShapeType == areaData.areaShapeType then
			if v.areaShapeType == 0 then
				res_flag = self:seam_sys_checkCylinder_Cylinder(areaData, v)
			else
				res_flag = self:seam_sys_checkPolygon_Polygon(areaData, v)
			end
		elseif v.areaShapeType > areaData.areaShapeType then
			res_flag = self:seam_sys_checkCylinder_Polygon(areaData, v)
		else
			res_flag = self:seam_sys_checkCylinder_Polygon(v, areaData)
		end

		if res_flag then
			break
		end
	end

	return res_flag
end

function SeamlessSystem:seam_sys_checkCylinder_Cylinder(areaData1, areaData2)
	local radius_dis = areaData1.radius + areaData2.radius
	local pos1 = areaData1.position
	local pos2 = areaData2.position

	return radius_dis >= Vector3.Distance(pos1, pos2)
end

function SeamlessSystem:seam_sys_checkCylinder_Polygon(areaData1, areaData2)
	local pos_orin = areaData1.position

	pos_orin = Vector2.New(pos_orin[1], pos_orin[3])

	local radius = areaData1.radius
	local pos_data = areaData2.overlapPos

	return self:seam_sys_polygonIntersectsCircle(pos_data, pos_orin, radius)
end

function SeamlessSystem:seam_sys_checkPolygon_Polygon(areaData1, areaData2)
	local pos_orin = areaData1.overlapPos
	local pos_data = areaData2.overlapPos

	return self:seam_sys_polygonsIntersect(pos_orin, pos_data)
end

function SeamlessSystem:seam_sys_orientation(p, q, r)
	local val = (q[2] - p[2]) * (r[1] - q[1]) - (q[1] - p[1]) * (r[2] - q[2])

	if val == 0 then
		return 0
	end

	return val > 0 and 1 or 2
end

function SeamlessSystem:seam_sys_onSegment(p, q, r)
	if q[1] <= math.max(p[1], r[1]) and q[1] >= math.min(p[1], r[1]) and q[2] <= math.max(p[2], r[2]) and q[2] >= math.min(p[2], r[2]) then
		return true
	end

	return false
end

function SeamlessSystem:seam_sys_doIntersect(p1, q1, p2, q2)
	local o1 = self:seam_sys_orientation(p1, q1, p2)
	local o2 = self:seam_sys_orientation(p1, q1, q2)
	local o3 = self:seam_sys_orientation(p2, q2, p1)
	local o4 = self:seam_sys_orientation(p2, q2, q1)

	if o1 ~= o2 and o3 ~= o4 then
		return true
	end

	if o1 == 0 and self:seam_sys_onSegment(p1, p2, q1) then
		return true
	end

	if o2 == 0 and self:seam_sys_onSegment(p1, q2, q1) then
		return true
	end

	if o3 == 0 and self:seam_sys_onSegment(p2, p1, q2) then
		return true
	end

	if o4 == 0 and self:seam_sys_onSegment(p2, q1, q2) then
		return true
	end

	return false
end

function SeamlessSystem:seam_sys_isInsidePolygon(polygon, point)
	local n = #polygon

	if n < 3 then
		return false
	end

	local extreme = {
		1000000000,
		point[2]
	}
	local count = 0
	local i = 1

	repeat
		local next = i % n + 1

		if self:seam_sys_doIntersect(polygon[i], polygon[next], point, extreme) then
			if self:seam_sys_orientation(polygon[i], point, polygon[next]) == 0 then
				return self:seam_sys_onSegment(polygon[i], point, polygon[next])
			end

			count = count + 1
		end

		i = next
	until i == 1

	return count % 2 == 1
end

function SeamlessSystem:seam_sys_polygonsIntersect(convex_polygon, concave_polygon)
	for i = 1, #convex_polygon do
		local next = i % #convex_polygon + 1

		for j = 1, #concave_polygon do
			local next2 = j % #concave_polygon + 1

			if self:seam_sys_doIntersect(convex_polygon[i], convex_polygon[next], concave_polygon[j], concave_polygon[next2]) then
				return true
			end
		end
	end

	for i = 1, #convex_polygon do
		if self:seam_sys_isInsidePolygon(concave_polygon, convex_polygon[i]) then
			return true
		end
	end

	for i = 1, #concave_polygon do
		if self:seam_sys_isInsidePolygon(convex_polygon, concave_polygon[i]) then
			return true
		end
	end

	return false
end

function SeamlessSystem:seam_sys_closestPointOnSegment(p, q, c)
	local pqx, pqy = q[1] - p[1], q[2] - p[2]
	local pcx, pcy = c[1] - p[1], c[2] - p[2]
	local pq_dist_sq = pqx * pqx + pqy * pqy
	local t = (pcx * pqx + pcy * pqy) / pq_dist_sq

	t = math.max(0, math.min(1, t))

	return p[1] + t * pqx, p[2] + t * pqy
end

function SeamlessSystem:seam_sys_lineIntersectsCircle(p1, p2, center, radius)
	local x_1, y_1 = self:seam_sys_closestPointOnSegment(p1, p2, center)

	return radius >= Vector2.Distance(x_1, y_1, center[1], center[2])
end

function SeamlessSystem:seam_sys_polygonIntersectsCircle(polygon, center, radius)
	for i = 1, #polygon do
		local next = i % #polygon + 1

		if self:seam_sys_lineIntersectsCircle(polygon[i], polygon[next], center, radius) then
			return true
		end
	end

	if self:seam_sys_isInsidePolygon(polygon, center) then
		return true
	end

	return false
end

function SeamlessSystem:seam_sys_parseOverlapPos(rawData)
	if rawData.overlapPos ~= nil then
		return
	end

	local areaShapeType = rawData.areaShapeType

	if areaShapeType == 0 then
		return
	end

	local overlapPos = {}
	local area_pos = rawData.areaPoints
	local p_num = #area_pos
	local c_idx = 1

	while c_idx < p_num do
		local x = area_pos[c_idx]
		local z = area_pos[c_idx + 1]

		overlapPos[#overlapPos + 1] = Vector2.New(x, z)
		c_idx = c_idx + 2
	end

	rawData.overlapPos = overlapPos
end

function SeamlessSystem:seam_sys_addAreaById(areaId)
	local areaData = self:seam_sys_getAreaData(areaId)

	if areaData == nil then
		return
	end

	areaData = self:seam_sys_getRawAreaData(areaData)

	self:seam_sys_addAreaByData(areaData)
end

function SeamlessSystem:seam_sys_addAreaByData(areaData)
	local areaId = areaData.id
	local areaShapeType = areaData.areaShapeType
	local entityTypeList = areaData.entityTypeList

	if not entityTypeList then
		return
	end

	local areaLayers = self:seam_sys_getAreaLayers(entityTypeList)

	for i = 1, #areaLayers do
		local layer = areaLayers[i]
		local enable = true

		if areaShapeType == 0 then
			areaManager:AddCylinder(layer, areaId, areaData.position, areaData.height, areaData.radius, enable)
		elseif areaShapeType == 1 then
			areaManager:AddSphere(layer, areaId, areaData.position, areaData.radius, enable)
		elseif areaShapeType == 2 then
			areaManager:AddPolygon(layer, areaId, areaData.position, areaData.height, areaData.areaPoints, enable)
		end
	end

	self.__seamlessAreas[areaId] = areaData

	self:seam_sys_parseAreaBoxInfo(areaData)
end

function SeamlessSystem:seam_sys_removeArea(areaId)
	for i = Const.AREA_LAYER.DEFAULT, Const.AREA_LAYER.MAX - 1 do
		areaManager:RemoveArea(i, areaId)
	end
end

function SeamlessSystem:seam_sys_clearRuntimeAreas()
	for areaId, _ in pairs(self.__seamlessAreas) do
		self:seam_sys_removeSingleArea(areaId)
	end

	table.clear(self.__seamlessAreas)
end

function SeamlessSystem:seam_sys_getSceneAreaData(areaId)
	if self.__seamlessMainSceneId == nil then
		return nil, true
	end

	local sceneAreas = SceneUtils.getSceneAreaData(self.__seamlessMainSceneId)

	if sceneAreas == nil then
		return nil, false
	end

	return sceneAreas[areaId], false
end

function SeamlessSystem:seam_sys_getAreaData(areaId)
	if self.__seamlessAreas[areaId] then
		return self.__seamlessAreas[areaId], true
	end

	return self:seam_sys_getSceneAreaData(areaId)
end

function SeamlessSystem:seam_sys_getRawAreaData(areaData)
	return areaData.getRawTable and areaData:getRawTable() or Utils.deepCopyTable(areaData)
end

function SeamlessSystem:seam_sys_getAllAreas()
	return self.__seamlessAreas
end

function SeamlessSystem:seam_sys_isMappingRegionType(areaType)
	return areaType == Const.AREA_LOAD_TYPE.MAPPING_REGION
end

function SeamlessSystem:seam_sys_getMappingRegionConfig(areaId)
	local regionData = RegionSyncData[areaId]

	if regionData == nil or regionData.mainScene ~= self.__seamlessMainSceneId then
		return
	end

	local areaData = self:seam_sys_getAreaData(areaId)

	if areaData == nil or not self:seam_sys_isMappingRegionType(areaData.areaLoadType) then
		return
	end

	return regionData, areaData
end

function SeamlessSystem:seam_sys_checkEnterMappingRegion()
	if pg.me == nil then
		return
	end

	local position = pg.me:getPosition()

	for areaId, _ in pairs(RegionSyncData) do
		local regionData, areaData = self:seam_sys_getMappingRegionConfig(areaId)

		if regionData and self:seam_sys_inSeamlessArea(position, areaData) then
			pg.me:seamless_mappingRegionEnter(areaId, regionData)

			return
		end
	end
end

function SeamlessSystem:seam_sys_getAreaLayers(entityTypeList)
	local layers = {}

	for i = 1, #entityTypeList do
		local entityType = entityTypeList[i]
		local layer = Const.ENTITY_TYPE_2_AREA_LAYER[entityType]

		if layer and not table.contains(layers, layer) then
			table.insert(layers, layer)
		end
	end

	return layers
end

function SeamlessSystem:seam_sys_addSceneAreaInternal(seamlessData, dynamic)
	local seamless = seamlessData.seamlessRange
	local areaId = seamless[1]
	local areaData = self:seam_sys_getSceneAreaData(areaId)

	if areaData == nil then
		return
	end

	local rawData = self:seam_sys_addSceneAreaCom(areaData, seamlessData.sceneId, dynamic)

	if rawData == nil then
		return
	end

	local edgeType = seamless[2]

	rawData.edgeType = edgeType

	if edgeType == 2 and not string.isNilOrEmpty(rawData.airWallAssetUrl) then
		rawData.airInstances = rawData.airInstances or {}

		self:seam_sys_initAirWallForShape(rawData)
	end
end

function SeamlessSystem:seam_sys_addSceneAreaCom(areaData, mainSceneId, dynamic)
	if areaData == nil then
		return nil
	end

	local areaId = areaData.id

	if self.__seamlessAreas[areaId] then
		self:seam_sys_removeSingleArea(areaId)

		self.__seamlessAreas[areaId] = nil
	end

	local rawData = self:seam_sys_getRawAreaData(areaData)

	rawData.sceneId = mainSceneId

	if dynamic then
		local p_pos = pg.me:getPosition()
		local areaPoints = Utils.getDynamicSeamlessArea(p_pos, self.__seamlessMainSceneId, areaId)

		rawData.areaPoints = areaPoints
		rawData.position = Vector3.New(p_pos.x, p_pos.y - AREA_OFFSET_Y, p_pos.z)
	else
		local pos = rawData.position

		rawData.position = Vector3.New(pos[1], pos[2] - AREA_OFFSET_Y, pos[3])
	end

	if dynamic and self:seam_sys_checkAreaOverlap(rawData) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("位面:%d 与其它位面重合!", rawData.sceneId)
		end

		return nil
	end

	self:seam_sys_addAreaByData(rawData)

	return rawData
end

function SeamlessSystem:seam_sys_parseAreaBoxInfo(rawData)
	local areaShapeType = rawData.areaShapeType
	local min_x = math.maxInt
	local max_x = -math.maxInt
	local min_z = math.maxInt
	local max_z = -math.maxInt
	local center = rawData.position

	if areaShapeType == 0 then
		local radius = rawData.radius
		local x = center[1]
		local z = center[3]

		min_x = x - radius
		max_x = x + radius
		min_z = z - radius
		max_z = z + radius
	else
		local area_pos = rawData.areaPoints
		local p_num = #area_pos
		local c_idx = 1

		while c_idx < p_num do
			local x = area_pos[c_idx]
			local z = area_pos[c_idx + 1]

			if max_x < x then
				max_x = x
			end

			if x < min_x then
				min_x = x
			end

			if max_z < z then
				max_z = z
			end

			if z < min_z then
				min_z = z
			end

			c_idx = c_idx + 2
		end
	end

	rawData.min_y = center[2] - AREA_OFFSET_Y
	rawData.max_y = center[2] + rawData.height
	rawData.min_x = min_x
	rawData.max_x = max_x
	rawData.min_z = min_z
	rawData.max_z = max_z
end

function SeamlessSystem:seam_sys_initAirWallForShape(rawData)
	local areaShapeType = rawData.areaShapeType

	if areaShapeType == 2 or areaShapeType == 1 then
		self:seam_sys_initCustomAir(rawData)
	elseif areaShapeType == 0 then
		self:seam_sys_initCylinderAir(rawData)
	end
end

function SeamlessSystem:seam_sys_initCylinderAir(rawData)
	self:seam_sys_LoadAirWallInternal(rawData.airWallAssetUrl, function(obj)
		local p = rawData.position
		local radius = rawData.radius

		obj.transform.localScale = Vector3.one * radius
		obj.transform.position = Vector3.New(p.x, p.y, p.z)

		pg.global.uiMgr:ReCalculateAirWallUV(obj)
		table.insert(rawData.airInstances, obj)
	end)
end

function SeamlessSystem:seam_sys_initCustomAir(rawData)
	local points = {}
	local ps = rawData.areaPoints
	local y = rawData.position[2]
	local p_num = #ps
	local c_idx = 1

	while c_idx < p_num do
		local x = ps[c_idx]
		local z = ps[c_idx + 1]

		points[#points + 1] = Vector3(x, y, z)
		c_idx = c_idx + 2
	end

	local pointNum = #points

	for i = 1, pointNum do
		local id1 = i
		local id2 = i == pointNum and 1 or i + 1

		self:seam_sys_LoadAirWallInternal(rawData.airWallAssetUrl, function(obj)
			local p1 = points[id1]
			local p2 = points[id2]
			local width = Vector3.Distance(Vector3.New(p1.x, 0, p1.z), Vector3.New(p2.x, 0, p2.z))

			obj.transform.localScale = Vector3.New(width, 10, 1)

			local center = Vector3.New((p1.x + p2.x) / 2, (p1.y + p2.y) / 2 + 2, (p1.z + p2.z) / 2)

			obj.transform.position = center

			local dir1 = p2 - p1
			local dir2 = Vector3.constRight
			local rotation = Quaternion.FromToRotation(dir2, dir1)

			obj.transform.rotation = rotation

			pg.global.uiMgr:ReCalculateAirWallUV(obj)
			table.insert(rawData.airInstances, obj)
		end)
	end
end

function SeamlessSystem:seam_sys_LoadAirWallInternal(assetURL, callback)
	pg.global.resMgr:GetInstanceFromCacheByLua(assetURL, function(gameObj, userData)
		if IsNil(gameObj) then
			return
		end

		callback(gameObj)
	end, 1, nil, self.airWallRoot)
end

function SeamlessSystem:seam_sys_createChannelEntity(createMode)
	if createMode == CoreConst.CreateClientEntityMode.Seamless then
		self:seam_sys_setSwitchState(true)
	end
end

function SeamlessSystem:seam_sys_setSwitchState(inSwitch)
	self.__isInSwitching = inSwitch

	if inSwitch then
		self.lastSeamlessSwitchTime = Time.realSecondCache
	end
end

function SeamlessSystem:seam_sys_isSeamlessType(areaType)
	return areaType == Const.AREA_LOAD_TYPE.PHASE_LOAD
end

function SeamlessSystem:seam_sys_enterArea(areaId)
	local areaData = self:seam_sys_getAreaData(areaId)

	if areaData == nil then
		return
	end

	local regionData = self:seam_sys_getMappingRegionConfig(areaId)

	if regionData then
		pg.me:seamless_mappingRegionEnter(areaId, regionData)

		return
	end

	if not self:seam_sys_isSeamlessType(areaData.areaLoadType) then
		return
	end

	self._currentTrigger = {
		isEnter = true,
		areaId = areaId
	}

	facade:sendMsgToUI(MessageName.ENTER_SEAMLESS)
end

function SeamlessSystem:seam_sys_exitArea(areaId)
	local areaData = self:seam_sys_getAreaData(areaId)

	if areaData == nil then
		return
	end

	local regionData = self:seam_sys_getMappingRegionConfig(areaId)

	if regionData then
		pg.me:seamless_mappingRegionExit(areaId, regionData)

		return
	end

	if not self:seam_sys_isSeamlessType(areaData.areaLoadType) then
		return
	end

	self._currentTrigger = {
		isEnter = false,
		areaId = areaId
	}

	pg.me:seamless_event_TriggerAutoExitSeamless()
	facade:sendMsgToUI(MessageName.EXIT_SEAMLESS)
end

function SeamlessSystem:seam_sys_setLastTipArea(areaId)
	self.__LastTipArea = areaId
end

function SeamlessSystem:seam_sys_getLastTipArea()
	return self.__LastTipArea
end

function SeamlessSystem:seam_sys_checkIsDynamic()
	return self.__isDynamicSeamless
end

function SeamlessSystem:seam_sys_checkIsEventArea()
	return self.__isEventSeamless
end

function SeamlessSystem:seam_sys_onSwitchFinished(sceneId)
	self:seam_sys_setSwitchState(false)
	pg.game:notifyServerSceneLoaded(sceneId)
end

function SeamlessSystem:seam_sys_isSwitchSeamless()
	return self.__isInSwitching
end

function SeamlessSystem:seam_sys_destroySpace(space)
	self._lastSceneId = space.sceneId
end

function SeamlessSystem:seam_sys_isForbidAutoEnter(player, areaId)
	if player == nil then
		return true
	end

	local areaData = self:seam_sys_getAreaData(areaId)

	if areaData == nil then
		return true
	end

	local phaseSceneId = areaData.sceneId

	if phaseSceneId == nil then
		return true
	end

	if areaData.areaLoadType == Const.AREA_LOAD_TYPE.PHASE_LOAD then
		local currentSceneId = player.space and player.space.sceneId

		if not currentSceneId or currentSceneId ~= phaseSceneId and currentSceneId ~= Utils.getPhaseMainSceneId(phaseSceneId) then
			return true
		end

		if player.banAutoDetectPhase == nil or player.banAutoDetectPhase[phaseSceneId] then
			return true
		end
	end

	return false
end

function SeamlessSystem:seam_sys_enterSeamless(player)
	self.__isDynamicSeamless = player.isDynamicPhase
	self.__recorderSeamlessSceneId = player.space.sceneId

	self:seam_sys_updateSeamlessType(player.space.sceneId)
	pg.game.weather:refreshWeather(player.space.sceneId)
end

function SeamlessSystem:seam_sys_exitSeamless()
	if self:seam_sys_checkIsEventArea() then
		self:seam_sys_removeDynamicArea(self.__recorderSeamlessSceneId)
	end

	self.__isEventSeamless = false
	self.__isDynamicSeamless = false
	self.__recorderSeamlessSceneId = nil
end

function SeamlessSystem:seam_sys_getLastAreaInfo()
	if self._currentTrigger == nil then
		return nil
	end

	local trigger = self._currentTrigger

	return self:seam_sys_getAreaData(trigger.areaId)
end

function SeamlessSystem:seam_sys_getLastSeamlessId()
	return self.__recorderSeamlessSceneId
end

function SeamlessSystem:seam_sys_inLastSeamlessArea(pos)
	local rawData = self:seam_sys_getLastAreaInfo()

	return self:seam_sys_inSeamlessArea(pos, rawData)
end

function SeamlessSystem:seam_sys_inSeamlessArea(pos, rawData)
	if rawData == nil then
		return false
	end

	local sceneId = rawData.sceneId or self.__seamlessMainSceneId

	if sceneId == nil then
		return false
	end

	local min_x = rawData.min_x or 0
	local max_x = rawData.max_x or 0
	local min_y = rawData.min_y or 0
	local max_y = rawData.max_y or 0
	local min_z = rawData.min_z or 0
	local max_z = rawData.max_z or 0
	local x = pos[1]
	local y = pos[2]
	local z = pos[3]

	if rawData.sceneId and (x < min_x or max_x < x or z < min_z or max_z < z) then
		return false
	end

	local areaId = rawData.id

	return Utils.inSeamlessRange(sceneId, areaId, pos, true)
end

function SeamlessSystem:recordEntity(ent)
	if not CommonSwitch.SEAM_LESS then
		return
	end

	if pg.global.ui.loadProgress:checkUIVisible() then
		return
	end

	if ent == nil or not ent.isModelLoaded or not ent.visible or not ent.active or ent.onVehicleActorId and ent.onVehicleActorId > 0 then
		return
	end

	self:createTempPlayer(ent)
	self:replaceTempPlayer()
end

function SeamlessSystem:useRecordTempNpcEModel(staticId)
	local eModel

	if staticId ~= nil and staticId ~= 0 then
		eModel = self.tempNpcEModel[staticId]

		if eModel ~= nil then
			self.tempNpcEModel[staticId] = nil
		end
	end

	return eModel
end

function SeamlessSystem:isReuseType(ent)
	if (Utils.isNpc(ent) or Utils.isVehicle(ent)) and ent.isModelLoaded and ent.visible and ent.active and ent.eModel then
		return true
	end

	return false
end

function SeamlessSystem:needRecordTempNpcEModel(ent)
	if not ent.staticId or ent.staticId == 0 then
		return false
	end

	return self.tempPlayer ~= nil and self:isReuseType(ent)
end

function SeamlessSystem:recordTempNpcEModel(ent)
	local oldEModel = self.tempNpcEModel[ent.staticId]

	if oldEModel ~= nil and oldEModel ~= ent.eModel then
		entityManager:DestroyEModel(oldEModel)

		self.tempNpcEModel[ent.staticId] = nil
	end

	if ent.eModel ~= nil then
		self.tempNpcEModel[ent.staticId] = ent.eModel

		entityManager:ClearEModelBind(ent.eModel)
	end
end

function SeamlessSystem:removeTempNpcEModel()
	for staticId, eModel in pairs(self.tempNpcEModel) do
		entityManager:DestroyEModel(eModel)
	end

	table.clear(self.tempNpcEModel)
end

function SeamlessSystem:isModelViewLoadDisable(ent)
	if self:isLastPawn(ent) then
		return true
	end

	if self.tempNpcRecreate[ent.staticId] then
		return true
	end

	return false
end

function SeamlessSystem:markTempNpc(ent)
	self.tempNpcRecreate[ent.staticId] = ent
end

function SeamlessSystem:resetTempNpc()
	for _, ent in pairs(self.tempNpcRecreate) do
		if not ent.destroyed and ent.eModel then
			ent.eModel:EnableModelViewLoad(Const.COMPONENT_INDEX_MODEL, true)
		end
	end

	table.clear(self.tempNpcRecreate)
end

function SeamlessSystem:createTempPlayer(ent)
	local EntityFactory = require("Core.Common.EntityFactory")
	local SafeCallback = require("Core.Framework.SafeCallback")
	local player = EntityFactory.createEntity("ClientTempPlayer", "10000")
	local position = pg.playerPos
	local rotation = pg.playerRot
	local id = ent.templateId
	local templateData = ent:getTemplateData()

	player.templateData = templateData
	player.spaceId = 1
	player.lastPawnId = ent.id
	player.isMainPlayer = ent.isMainPlayer
	player.deformContext = ent.deformContext
	player.deformData = ent.deformData

	local function initFun()
		player:init({
			teleportPortalId = 0,
			buffTag = 0,
			yaw = 0,
			__Properties__ = {
				actorId = VirtualEntUtils.getNewVirtualEntActorId(),
				templateId = id
			},
			position = position
		})
		player:postInit({})
		player:start()
		player:setInScene(true)
	end

	SafeCallback(initFun)
	EModelUtils.setAgentPositionAndRotation(player, position, rotation, true, Const.AgentTransformReasonConst.TeleportFromLua)

	self.tempPlayer = player
end

function SeamlessSystem:replaceTempPlayer()
	if self.tempPlayer ~= nil then
		pg.game.controller:controlTempPlayer(self.tempPlayer)
	end

	local player = pg.me

	if player ~= nil then
		player:setVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, false, false)
		player:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, false, false)
	end
end

function SeamlessSystem:destroyTempPlayer()
	if self.tempPlayer ~= nil then
		ClientUtils.safeDestroy(self.tempPlayer)

		self.tempPlayer = nil
	end
end

function SeamlessSystem:isLastPawn(ent)
	return self.tempPlayer ~= nil and self.tempPlayer.lastPawnId == ent.id
end

function SeamlessSystem:seizeTempPlayerModel(pawn)
	if self.tempPlayer ~= nil and self.tempPlayer:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		local modelComponent = self.tempPlayer:getEModelComponent(Const.COMPONENT_INDEX_MODEL)

		if NotNil(modelComponent) then
			pawn.eModel:SeizeModel(Const.COMPONENT_INDEX_MODEL, modelComponent)
		end

		pawn.eModel:EnableModelViewLoad(Const.COMPONENT_INDEX_MODEL, true)
	else
		pawn.eModel:EnableModelViewLoad(Const.COMPONENT_INDEX_MODEL, true)
	end
end

function SeamlessSystem:startCheckClientReady()
	if not CommonSwitch.SEAM_LESS then
		return
	end

	local player = pg.me

	if player ~= nil then
		player:setVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, false, false)
		player:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, false, false)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("bgf SeamlessSystem:startCheckClientReady")
	end

	self.clientReadyTimerId = TimerManager.addNextFrameCb(function()
		self:afterClientReady()
	end)

	if self.clearTempNpcTimerId ~= nil then
		TimerManager.removeTimer(self.clearTempNpcTimerId)

		self.clearTempNpcTimerId = nil
	end

	self.clearTempNpcTimerId = TimerManager.addTimer(5, function()
		self:removeTempNpcEModel()
		self:resetTempNpc()
	end)
end

function SeamlessSystem:afterClientReady()
	if self.clientReadyTimerId ~= nil then
		TimerManager.delFrameCb(self.clientReadyTimerId)

		self.clientReadyTimerId = nil
	end

	local tempPlayer = self.tempPlayer
	local tempPlayerPosition, tempPlayerRotation, lastPawnId

	if tempPlayer ~= nil then
		lastPawnId = tempPlayer.lastPawnId

		local x, y, z = tempPlayer.eModel:GetPositionAgentPosEx()

		tempPlayerPosition = Vector3(x, y, z)

		local rx, ry, rz, rw = tempPlayer.eModel:GetPositionAgentRotationEx()

		tempPlayerRotation = Quaternion(rx, ry, rz, rw)
	end

	local player = pg.me

	pg.game.controller:setSwitchControllerEnable(true)

	if player ~= nil then
		player:setVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, true, true)
		player:setVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
		player:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.SEAMLESS_STATE, true, true)
		player:setCurPetVisible(ClientConst.MODEL_VISIBLE_KEY.TELEPORT, true)
	end

	if tempPlayer == nil then
		return
	end

	local entity = pg.getEntity(lastPawnId)

	if entity ~= nil then
		if tempPlayerPosition ~= nil then
			EModelUtils.setAgentPositionAndRotation(entity, tempPlayerPosition, tempPlayerRotation, true, Const.AgentTransformReasonConst.TeleportFromLua)
			self:seizeTempPlayerModel(entity)
		end

		if player:isControllingPet() then
			if player.curCombatPetId == lastPawnId then
				player:onPetReady(entity)
			else
				local curPetEnt = player:getCurPetEntity()

				if curPetEnt then
					player:switchToPet(Const.EVENT_ENTER_SCENE)
				else
					player:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.ManualSwitch)
				end
			end
		else
			pg.game.controller:setPlayer(player, true)
			player:switchToPlayer(Const.EVENT_ENTER_SCENE)
		end
	end

	self:destroyTempPlayer()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("bgf SeamlessSystem:startCheckClientReady end")
	end
end

return SeamlessSystem
