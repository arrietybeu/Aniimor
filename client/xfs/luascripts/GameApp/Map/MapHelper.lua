-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Map\\MapHelper.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SceneUtils = require("Common.Utils.SceneUtils")
local PuppetData = require("Data.puppet_data")
local LeylineTreePuppetData = require("Data.leylinetree_puppet_data")
local LevelInfoData = require("Data.level_reward_linked_data")
local RealElementAgainst = require("Data.real_element_against")
local ElementPropData = require("Data.element_prop_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local Lume = require("Core.Common.lume")
local const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local MapAreaConfigData = require("Data.map_area_config_data")
local SceneSeamlessData = require("Data.scene_seamless_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local CountryAreaData = require("Data.country_area_data")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local scene_block_info = require("Data.scene_block_info")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local MapOverlapScene = require("Data.map_overlap_scene")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LeylineFlowerConst = require("Common.Const.LeylineFlowerConst")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientUtils")
local SceneData = require("Data.scene_data")
local MapBlockData = MapBlockConfigData
local testDataFromCofnig = true
local testDataCompare = false
local _emptyTable = {}
local MapHelper = {}
local CHUNK_GAP = 100

MapHelper.CHUNK_GAP = CHUNK_GAP
MapHelper.CHUNK_DIRECTION = {
	{
		0,
		0
	},
	{
		-1,
		1
	},
	{
		0,
		1
	},
	{
		1,
		1
	},
	{
		-1,
		0
	},
	{
		1,
		0
	},
	{
		-1,
		-1
	},
	{
		0,
		-1
	},
	{
		1,
		-1
	}
}

local LAYER_ICON_LOC0 = Vector3(42, -52, 0)
local LAYER_ICON_LOC1 = Vector3(30, -30, 0)

MapHelper.LAYER_ICON_LOC2 = Vector3(40, 45, 0)
MapHelper.LAYER_ICON_TARCKLOC = Vector3(-30, -30, 0)
MapHelper.MARK_SHARE_COUNTDOWN_LOC = Vector3(-45, -45, 0)

local metaTableLAYER_ICON_LOC = {
	__index = function(t, level)
		if level >= 3 then
			return LAYER_ICON_LOC1
		else
			return LAYER_ICON_LOC0
		end
	end
}

MapHelper.LAYER_ICON_LOC = {}

setmetatable(MapHelper.LAYER_ICON_LOC, metaTableLAYER_ICON_LOC)

local _sceneDataCachesNew = {}

local function initSystemDataCache(sceneId)
	local sceneData = SceneData[sceneId]
	local valid

	if sceneData.PointAPositon and sceneData.PointBPosition and sceneData.MapAPosition and sceneData.MapBPosition then
		valid = true
	end

	local cacheData

	if valid then
		cacheData = {
			valid,
			sceneData,
			sceneData.PointAPositon[1],
			sceneData.PointAPositon[2],
			sceneData.PointBPosition[1],
			sceneData.PointBPosition[2],
			sceneData.MapAPosition[1],
			sceneData.MapAPosition[2],
			sceneData.MapBPosition[1],
			sceneData.MapBPosition[2]
		}

		local pointAPosX = cacheData[3]
		local pointAPosY = cacheData[4]
		local mapAPosX = cacheData[7]
		local mapAPosY = cacheData[8]
		local coefficientX = (mapAPosX - cacheData[9]) / (pointAPosX - cacheData[5])
		local coefficientZ = (mapAPosY - cacheData[10]) / (pointAPosY - cacheData[6])

		cacheData[5] = coefficientX
		cacheData[6] = coefficientZ
	else
		cacheData = {
			valid,
			nil,
			0,
			0,
			1,
			1,
			0,
			0,
			0,
			0
		}
	end

	if sceneData.mapUISize then
		cacheData[11] = sceneData.mapUISize[1] / 2
		cacheData[12] = -sceneData.mapUISize[2] / 2
	else
		cacheData[11] = 0
		cacheData[12] = 0
	end

	_sceneDataCachesNew[sceneId] = cacheData

	return cacheData, valid
end

function MapHelper.convertPos(x, yOrz, mainSceneId, toMap, muteOffset)
	local mapX, mapY = 0, 0
	local cacheData = _sceneDataCachesNew[mainSceneId]
	local valid

	if not cacheData then
		cacheData, valid = initSystemDataCache(mainSceneId)
	else
		valid = cacheData[1]
	end

	if not valid then
		return mapX, mapY
	end

	local pointAPosX = cacheData[3]
	local pointAPosY = cacheData[4]
	local mapAPosX = cacheData[7]
	local mapAPosY = cacheData[8]
	local coefficientX = cacheData[5]
	local coefficientZ = cacheData[6]
	local offset

	if MapOverlapScene[mainSceneId] and SceneData[mainSceneId] then
		local wholemapOffset = SceneData[mainSceneId].wholemapOffset

		if wholemapOffset and #wholemapOffset == 3 then
			offset = wholemapOffset
		end
	end

	if muteOffset then
		offset = nil
	end

	if toMap then
		if offset then
			x = x + offset[1]
			yOrz = yOrz + offset[3]
		end

		mapX, mapY = (x - pointAPosX) * coefficientX + mapAPosX, (yOrz - pointAPosY) * coefficientZ + mapAPosY
	else
		mapX, mapY = (x - mapAPosX) / coefficientX + pointAPosX, (yOrz - mapAPosY) / coefficientZ + pointAPosY

		if offset then
			mapX = mapX - offset[1]
			mapY = mapY - offset[3]
		end
	end

	return mapX, mapY
end

local _sceneCacheData

function MapHelper.InitSceneCache()
	local mainSceneId = pg.game.map.mainSceneId

	if not mainSceneId then
		return
	end

	_sceneCacheData = _sceneDataCachesNew[mainSceneId]

	if not _sceneCacheData then
		_sceneCacheData = initSystemDataCache(mainSceneId)
	end
end

function MapHelper.convertPosEx(x, yOrz, offsetX, offsetZ, mainSceneId, toMap)
	local mapX, mapY = 0, 0
	local cacheData = _sceneDataCachesNew[mainSceneId]
	local valid

	if not cacheData then
		cacheData, valid = initSystemDataCache(mainSceneId)
	else
		valid = cacheData[1]
	end

	if not valid then
		return mapX, mapY
	end

	local pointAPosX = cacheData[3]
	local pointAPosY = cacheData[4]
	local mapAPosX = cacheData[7]
	local mapAPosY = cacheData[8]
	local coefficientX = cacheData[5]
	local coefficientZ = cacheData[6]

	if toMap then
		x = x + offsetX
		yOrz = yOrz + offsetZ
		mapX, mapY = (x - pointAPosX) * coefficientX + mapAPosX, (yOrz - pointAPosY) * coefficientZ + mapAPosY
	else
		mapX, mapY = (x - mapAPosX) / coefficientX + pointAPosX, (yOrz - mapAPosY) / coefficientZ + pointAPosY
		mapX = mapX - offsetX
		mapY = mapY - offsetZ
	end

	return mapX, mapY
end

function MapHelper.convertPosExCached(x, yOrz, offsetX, offsetZ, toMap)
	local mapX, mapY
	local cacheData = _sceneCacheData
	local pointAPosX = cacheData[3]
	local pointAPosY = cacheData[4]
	local mapAPosX = cacheData[7]
	local mapAPosY = cacheData[8]
	local coefficientX = cacheData[5]
	local coefficientZ = cacheData[6]

	if toMap then
		x = x + offsetX
		yOrz = yOrz + offsetZ
		mapX, mapY = (x - pointAPosX) * coefficientX + mapAPosX, (yOrz - pointAPosY) * coefficientZ + mapAPosY
	else
		mapX, mapY = (x - mapAPosX) / coefficientX + pointAPosX, (yOrz - mapAPosY) / coefficientZ + pointAPosY
		mapX = mapX - offsetX
		mapY = mapY - offsetZ
	end

	return mapX, mapY
end

function MapHelper.posSceneToMapCached(x, yOrz, offsetX, offsetZ)
	local pointAPosX = _sceneCacheData[3]
	local pointAPosY = _sceneCacheData[4]
	local mapAPosX = _sceneCacheData[7]
	local mapAPosY = _sceneCacheData[8]
	local coefficientX = _sceneCacheData[5]
	local coefficientZ = _sceneCacheData[6]

	x = x + offsetX
	yOrz = yOrz + offsetZ

	local mapX, mapY = (x - pointAPosX) * coefficientX + mapAPosX, (yOrz - pointAPosY) * coefficientZ + mapAPosY

	return mapX, mapY
end

function MapHelper.posViewToSceneCached(x, yOrz, offsetX, offsetZ)
	local pointAPosX = _sceneCacheData[3]
	local pointAPosY = _sceneCacheData[4]
	local mapAPosX = _sceneCacheData[7]
	local mapAPosY = _sceneCacheData[8]
	local coefficientX = _sceneCacheData[5]
	local coefficientZ = _sceneCacheData[6]
	local mapX, mapY = (x - mapAPosX) / coefficientX + pointAPosX, (yOrz - mapAPosY) / coefficientZ + pointAPosY

	mapX = mapX - offsetX
	mapY = mapY - offsetZ

	return mapX, mapY
end

function MapHelper.posViewToSceneXCached(x, offsetX)
	local mapX = (x - _sceneCacheData[7]) / _sceneCacheData[5] + _sceneCacheData[3]

	mapX = mapX - offsetX

	return mapX
end

function MapHelper.calMapUISize(mainSceneId, x, y)
	local cacheData = _sceneDataCachesNew[mainSceneId]

	cacheData = cacheData or initSystemDataCache(mainSceneId)

	local x1 = cacheData[11] - x
	local y1 = cacheData[12] - y

	return x1, y1
end

function MapHelper.calMapUISizeCached(x, y)
	local x1 = _sceneCacheData[11] - x
	local y1 = _sceneCacheData[12] - y

	return x1, y1
end

function MapHelper.calRadius(sceneId, radius)
	local sceneData = SceneData[sceneId]

	if not sceneData then
		return radius
	end

	local pointAPosX = sceneData.PointAPositon[1]
	local pointBPosX = sceneData.PointBPosition[1]
	local mapAPosX = sceneData.MapAPosition[1]
	local mapBPosX = sceneData.MapBPosition[1]

	return radius * math.abs((mapBPosX - mapAPosX) / (pointBPosX - pointAPosX))
end

function MapHelper.getRootScene(sceneId)
	return MapOverlapScene[sceneId] or sceneId
end

function MapHelper.getAllChildrenScene(sceneId)
	local rootScene = MapHelper.getRootScene(sceneId)
	local allChildrenScene = {
		rootScene
	}

	if SceneData[rootScene] and SceneData[rootScene].mapDisplayOverlayScenes then
		for _, childScene in pairs(SceneData[rootScene].mapDisplayOverlayScenes) do
			table.insert(allChildrenScene, childScene)
		end
	end

	return allChildrenScene
end

function MapHelper.getSceneName(sceneId)
	if not SceneData[sceneId] then
		return ""
	end

	if not SceneData[sceneId].sceneName then
		return ""
	end

	return pg.getLocalizationText(SceneData[sceneId].sceneName)
end

function MapHelper.getDefaultMapPos(sceneId)
	local sceneData = SceneData[sceneId]

	if not sceneData or not sceneData.mapSwitchDefaultPos then
		return 0, 0
	end

	return sceneData.mapSwitchDefaultPos[1], sceneData.mapSwitchDefaultPos[2]
end

function MapHelper.getDefaultMapScaleRatio(sceneId)
	local sceneData = SceneData[sceneId]

	if not sceneData or not sceneData.mapSwitchDefaultScaleRatio then
		return 1
	end

	return sceneData.mapSwitchDefaultScaleRatio
end

local function checkPointInAreaAABB(markPos, areaData)
	local areaAABB = areaData.areaAABB

	if not areaAABB then
		return true
	end

	local x = markPos[1]
	local z = markPos[3]
	local minX = areaAABB[1]
	local minZ = areaAABB[2]
	local maxX = areaAABB[3]
	local maxZ = areaAABB[4]

	if not minX or not maxX or not minZ or not maxZ then
		return true
	end

	return minX <= x and x <= maxX and minZ <= z and z <= maxZ
end

function MapHelper.pointInWhichArea(sceneId, markPos, spaceId)
	if not markPos then
		return nil
	end

	local sceneAreaData = SceneUtils.getSceneAreaData(sceneId, spaceId)

	if not sceneAreaData then
		return nil
	end

	for areaId, v in pairs(sceneAreaData) do
		local logic = v.logics and v.logics[1]

		if logic and logic.enterEvents then
			local mapLayerEvent

			for _, eventData in ipairs(logic.enterEvents) do
				if eventData[1] == "changeMapLayerData" then
					mapLayerEvent = eventData

					break
				end
			end

			if mapLayerEvent and checkPointInAreaAABB(markPos, v) and Utils.checkInAreaRange(sceneId, areaId, markPos, spaceId) then
				return areaId, mapLayerEvent
			end
		end
	end

	return nil
end

function MapHelper.inWhichBlock(inputSceneId, isMapPosition, positionTable, blockList, muteOffset)
	local mapXNeed, mapYNeed

	if not inputSceneId or isMapPosition == nil or not positionTable then
		return nil
	end

	if isMapPosition and (not positionTable.x or not positionTable.y) then
		return nil
	elseif not isMapPosition and (not positionTable.x or not positionTable.z) then
		return nil
	elseif not isMapPosition then
		mapXNeed, mapYNeed = MapHelper.convertPos(positionTable.x, positionTable.z, inputSceneId, true, muteOffset)
	else
		mapXNeed, mapYNeed = positionTable.x, positionTable.y
	end

	local last = #blockList
	local i = 1

	while i <= last do
		local blockInfo = blockList[i]
		local blockId = blockInfo.blockId

		if MapSmallAreaIdToIndex[blockId] and LuaUIUtils.isPointInPoly2(mapXNeed, mapYNeed, blockInfo) then
			return blockId
		end

		i = i + 1
	end

	return nil
end

function MapHelper.queryMinPriorityBlock(mainSceneId, positionTable, blockList)
	local mapXNeed, mapYNeed = MapHelper.convertPos(positionTable.x, positionTable.z, mainSceneId, true, true)
	local minBlockId
	local last = #blockList
	local i = 1

	while i <= last do
		local blockInfo = blockList[i]

		if LuaUIUtils.isPointInPoly2(mapXNeed, mapYNeed, blockInfo) then
			minBlockId = blockInfo.blockId

			break
		end

		i = i + 1
	end

	if minBlockId then
		if MapSmallAreaIdToIndex[minBlockId] then
			return minBlockId, minBlockId
		end

		i = i + 1

		while i <= last do
			local blockInfo = blockList[i]
			local blockId = blockInfo.blockId

			if MapSmallAreaIdToIndex[blockId] and LuaUIUtils.isPointInPoly2(mapXNeed, mapYNeed, blockInfo) then
				return blockId, minBlockId
			end

			i = i + 1
		end
	end

	return nil, minBlockId
end

function MapHelper.inWhichBlocks(inputSceneId, isMapPosition, positionTable, blockList, blockInfo)
	local mapXNeed, mapYNeed

	if not inputSceneId or isMapPosition == nil or not positionTable then
		return
	end

	if isMapPosition and (not positionTable.x or not positionTable.y) then
		return
	elseif not isMapPosition and (not positionTable.x or not positionTable.z) then
		return
	elseif not isMapPosition then
		mapXNeed, mapYNeed = MapHelper.convertPos(positionTable.x, positionTable.z, inputSceneId, true, true)
	else
		mapXNeed, mapYNeed = positionTable.x, positionTable.y
	end

	for _, arr in ipairs(blockInfo) do
		if LuaUIUtils.isPointInPoly2(mapXNeed, mapYNeed, arr) then
			table.insert(blockList, arr.blockId)
		end
	end
end

function MapHelper.getMaxPriorityMainAreaId(blockList, blockInfo, mapSmallAreaIdToIndex)
	local maxPriorityBlockId
	local curPriority = 10000

	for _, blockId in ipairs(blockList) do
		local v = blockInfo[blockId]

		if v and mapSmallAreaIdToIndex[blockId] and curPriority > v.priority then
			curPriority = v.priority
			maxPriorityBlockId = blockId

			if curPriority == 1 then
				return blockId
			end
		end
	end

	return maxPriorityBlockId
end

local _specialMarkMap = {
	[Const.MAP_MARK_ALLY] = true,
	[Const.MAP_MARK_QUEST] = true,
	[Const.MAP_MARK_CUSTOM] = true,
	[Const.MAP_MARK_SHARE] = true,
	[Const.MAP_MARK_ZONE] = true,
	[Const.MAP_MARK_TRACE] = true,
	[Const.MAP_MARK_GOLD_MONSTER] = true
}

function MapHelper.isSpecialMark(markType)
	return _specialMarkMap[markType]
end

function MapHelper.getAreaSceneId(blockId)
	local block = MapBlockConfigData[blockId]
	local area = block and MapAreaConfigData[block.mapAreaId]

	return area and area.Mapid
end

function MapHelper.getOwnRainbowPetMapData(sceneId)
	if not sceneId or not pg.me or pg.space and pg.space.sceneId == sceneId then
		return nil
	end

	local pointPets, groupPets = {}, {}
	local cachedPets = pg.me.rbPetsCahce and pg.me.rbPetsCahce[sceneId]

	if cachedPets then
		local points = SceneUtils.getSceneMarkPointData(sceneId)

		for i = 1, #cachedPets - 1, 2 do
			local templateId, pointId = cachedPets[i], cachedPets[i + 1]
			local point = points and points[pointId]

			if templateId > 0 and point and point.markConfigId == LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID then
				pointPets[pointId] = templateId

				local groupId = LeylineFlowerUtils.getMeteorologyGroupBlockId(point.largeAreaId)

				if groupId then
					groupPets[groupId] = groupPets[groupId] or {}
					groupPets[groupId][templateId] = true
				end
			end
		end
	end

	for _, treeInfo in pairs(pg.me.leylineTreeInfoMap or EMPTY_TABLE) do
		for blockId, pending in pairs(treeInfo.pendMeteo or EMPTY_TABLE) do
			if MapHelper.getAreaSceneId(blockId) == sceneId and pending.templateId > 0 and pending.pointId > 0 then
				pointPets[pending.pointId] = pending.templateId

				local groupId = LeylineFlowerUtils.getMeteorologyGroupBlockId(blockId)

				groupPets[groupId] = groupPets[groupId] or {}
				groupPets[groupId][pending.templateId] = true
			end
		end
	end

	return pointPets, groupPets
end

function MapHelper.getRainbowPetTemplateIdByPointId(markId, sceneId)
	local pointPets = MapHelper.getOwnRainbowPetMapData(sceneId)

	if pointPets then
		return pointPets[markId]
	end

	return pg.space and pg.space.getRainbowPetTemplateIdByPointId and pg.space:getRainbowPetTemplateIdByPointId(markId)
end

function MapHelper.getRainbowPetMarkStatus(markId, sceneId)
	local pointPets = MapHelper.getOwnRainbowPetMapData(sceneId)

	if pointPets then
		return pointPets[markId] and Const.MAP_MARK_STATUS_UNLOCKED or Const.MAP_MARK_STATUS_HIDE
	end

	local rainbowPetPosFlags = pg.space and pg.space.rainbowPetPosFlags

	for _, pointCountMap in pairs(rainbowPetPosFlags or EMPTY_TABLE) do
		if (pointCountMap[markId] or 0) > 0 then
			return Const.MAP_MARK_STATUS_UNLOCKED
		end
	end

	return Const.MAP_MARK_STATUS_HIDE
end

function MapHelper.getAreaRainbowPetTemplates(blockId)
	local _, groupPets = MapHelper.getOwnRainbowPetMapData(MapHelper.getAreaSceneId(blockId))

	return groupPets and (groupPets[LeylineFlowerUtils.getMeteorologyGroupBlockId(blockId)] or EMPTY_TABLE)
end

function MapHelper.getAreaMeteorology(blockId)
	local pets = MapHelper.getAreaRainbowPetTemplates(blockId)

	if not pets then
		return pg.me:getAreaMeteorology(blockId)
	end

	if next(pets) then
		return SysConfigData.LEYLINEFLOWER_CHANGEMETEOROLOGY_ID or LeylineFlowerConst.DEFAULT_RAINBOW_METEOROLOGY_ID
	end

	local groupId = LeylineFlowerUtils.getMeteorologyGroupBlockId(blockId)
	local info = pg.me.meteorologyInfoMap and pg.me.meteorologyInfoMap[groupId]

	return info and info.endTime >= Time.secondCache and info.meteorologyId or 0
end

function MapHelper.getAreaWeatherForecast(blockId)
	local sceneId = MapHelper.getAreaSceneId(blockId)

	if sceneId and (not pg.space or pg.space.sceneId ~= sceneId) then
		blockId = LeylineFlowerUtils.getMeteorologyGroupBlockId(blockId)
	end

	return pg.me.weatherInfoForecast[blockId]
end

function MapHelper.getWeatherByAreaId(blockId)
	local sceneId = MapHelper.getAreaSceneId(blockId)

	if sceneId and (not pg.space or pg.space.sceneId ~= sceneId) then
		local forecast = MapHelper.getAreaWeatherForecast(blockId)

		return forecast and forecast[1] and forecast[1].weatherId or 0
	end

	return pg.me:getWeatherByAreaId(blockId)
end

function MapHelper.getSpawnerIdByMarkPointId(sceneId, markPointId, spaceId)
	local spawnerData = SceneUtils.getSceneSpawnerData(sceneId, spaceId)

	for k, v in pairs(spawnerData) do
		if v.markConfig and v.markConfig.markContent1 == markPointId then
			return k
		end
	end

	return nil
end

function MapHelper.getSandBoxIdBySpawnerId(sceneId, spawnerId, spaceId)
	local sandBoxData = SceneUtils.getSceneSandboxData(sceneId, spaceId)

	for k, v in pairs(sandBoxData) do
		if v.spawners and v.spawners[1] == spawnerId then
			return k
		end
	end

	return nil
end

local function multiplyPetElementAgainstFactor(petElementType, testElementId, petAttacksTest)
	local factor = 1

	for petElementId, _ in pairs(petElementType) do
		local value = 1

		if petAttacksTest then
			if RealElementAgainst[petElementId] and RealElementAgainst[petElementId][testElementId] then
				value = RealElementAgainst[petElementId][testElementId]
			end
		elseif RealElementAgainst[testElementId] and RealElementAgainst[testElementId][petElementId] then
			value = RealElementAgainst[testElementId][petElementId]
		end

		factor = factor * value
	end

	return factor
end

local function collectPetElementRelations(petElementType, petAttacksTest, matchFn, maxCount)
	local temp = {}

	for elementId, propData in pairs(ElementPropData) do
		if propData.isShow == 1 then
			local factor = multiplyPetElementAgainstFactor(petElementType, elementId, petAttacksTest)

			if matchFn(factor) then
				temp[#temp + 1] = {
					factor = factor,
					elementId = elementId
				}
			end
		end
	end

	table.sort(temp, function(a, b)
		return a.factor > b.factor
	end)

	if maxCount then
		local result = {}

		for i = 1, math.min(maxCount, #temp) do
			result[i] = temp[i]
		end

		return result
	end

	return temp
end

function MapHelper.isPOIPopupBelongsToFightType(sceneId, markPointId, puppetStaticIdInitRecord, spaceId)
	local markPointData = SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	local entityData = SceneUtils.getSceneEntityData(sceneId, spaceId)

	if not markPointData[markPointId] then
		return {
			false
		}
	end

	local entityId = markPointData[markPointId].entityId

	if not entityId then
		return {
			false
		}
	end

	local idInType = entityData[entityId].idInType

	if not idInType then
		return {
			false
		}
	end

	local elementType = PuppetData[idInType] and PuppetData[idInType].elementType

	if not elementType or Lume.count(elementType) <= 0 then
		return {
			false
		}
	end

	local levelInfoData = LevelInfoData[markPointId]

	if not levelInfoData then
		return {
			false
		}
	end

	if PuppetData[idInType].lvType ~= 7 then
		return {
			false
		}
	end

	local maxLevelRequire

	if puppetStaticIdInitRecord and puppetStaticIdInitRecord[entityId] then
		maxLevelRequire = puppetStaticIdInitRecord[entityId]
	else
		maxLevelRequire = PuppetData[idInType].lv or 0
	end

	local isFight = false
	local levelPrefer, propertyPrefer

	if levelInfoData.LevelOrNot == 1 or levelInfoData.PropertyOrNot == 1 then
		isFight = true

		if levelInfoData.LevelOrNot == 1 then
			levelPrefer = LuaUIUtils.getThreatLevelState(maxLevelRequire)
		end

		if levelInfoData.PropertyOrNot == 1 then
			propertyPrefer = collectPetElementRelations(elementType, false, function(factor)
				return factor >= 1.6
			end, 3)
		end
	end

	local originalProperties = {}

	for elementId, _ in pairs(elementType) do
		originalProperties[#originalProperties + 1] = {
			elementId = elementId
		}
	end

	table.sort(originalProperties, function(a, b)
		return a.elementId < b.elementId
	end)

	local restrainedProperties = collectPetElementRelations(elementType, false, function(factor)
		return factor > 0 and factor < 1
	end)

	table.sort(restrainedProperties, function(a, b)
		return a.factor < b.factor
	end)

	local extraProperties = {
		originalProperties = originalProperties,
		restrainedProperties = restrainedProperties
	}

	return {
		isFight,
		maxLevelRequire,
		propertyPrefer,
		entityId,
		idInType,
		extraProperties
	}
end

function MapHelper.getRewardTableByMarkPointId(sceneId, markPointId)
	local spawnerId = MapHelper.getSpawnerIdByMarkPointId(sceneId, markPointId)
	local sandBoxId

	if spawnerId then
		sandBoxId = MapHelper.getSandBoxIdBySpawnerId(sceneId, spawnerId)
	end

	local rewardData

	if sandBoxId then
		rewardData = LevelInfoData[sandBoxId]
	end

	local rewardTable

	if rewardData ~= nil and rewardData.showRewardId ~= nil then
		rewardData = LuaUIUtils.getRewardItemByDropId(rewardData.showRewardId)
	end

	return rewardTable
end

function MapHelper.getLeylineTreePlentyInfo(sceneId, markPointId, createId, spaceId)
	if not createId then
		return
	end

	local sceneMarkPointData = SceneUtils.getSceneMarkPointData(sceneId, spaceId)

	if not sceneMarkPointData[markPointId] then
		return nil
	end

	local data = LeylineTreePuppetData[createId]

	if not data then
		return nil
	end

	local smallAreaId = sceneMarkPointData[markPointId].favorableCollectId
	local areaName = MapBlockConfigData[smallAreaId].areaName

	return {
		quality = data.quality,
		radius = data.radius,
		familyName = pg.getLocalizationText(data.familyName),
		puppetId1 = data.puppetIds[1],
		areaName = pg.getLocalizationText(areaName),
		smallAreaId = smallAreaId
	}
end

function MapHelper.getLeylineFlowerPlentyInfo(flowerId, createId)
	if not createId or not flowerId then
		return
	end

	local data = LeylineTreePuppetData[createId]

	if not data then
		return
	end

	local smallAreaId = LeylineFlowerUtils.getBlockIdByStaticId(nil, flowerId)

	if not smallAreaId then
		return
	end

	local areaName = MapBlockConfigData[smallAreaId].areaName

	return {
		quality = data.quality,
		radius = data.radius,
		familyName = pg.getLocalizationText(data.familyName),
		puppetId1 = data.puppetIds[1],
		areaName = pg.getLocalizationText(areaName),
		smallAreaId = smallAreaId
	}
end

function MapHelper.getMarkPriorityByConfigId(markConfigId)
	local markData = DefaultMapMarkData[markConfigId]

	if not markData then
		return 0
	end

	return markData.markPriority or 0
end

function MapHelper.getMarkTraceTypeByConfigId(markConfigId)
	local markData = DefaultMapMarkData[markConfigId]

	if not markData then
		return 1
	end

	return markData.traceType or 1
end

function MapHelper.getNPCSpecialState(staticId, specialContentDict)
	if specialContentDict then
		local spId = specialContentDict[staticId]

		if spId then
			local NpcSpecialStateData = require("Data.npc_special_state_data")

			return NpcSpecialStateData[spId]
		end
	end

	return nil
end

function MapHelper.getMarkStatusMap()
	return pg.me:getSpaceOwnerMapMarkStatusMap() or pg.me.mapMarkStatusMap
end

function MapHelper.getMarkStatus(spawnerId, markType, sceneId)
	local markStatus = (markType == const.MAP_MARK_ZONE or markType == const.MAP_MARK_CUSTOM or markType == const.MAP_MARK_QUEST or markType == const.MAP_MARK_SHARE or markType == const.MAP_MARK_TRACE or markType == const.MAP_MARK_CLUE or markType == const.MAP_MARK_ALLY) and const.MAP_MARK_STATUS_UNLOCKED or MapHelper.getMarkStatusMap():getStatus(sceneId, markType, spawnerId)

	return markStatus
end

function MapHelper.modifyVector2(tempVec2, x, y)
	tempVec2[1] = x
	tempVec2[2] = y
end

function MapHelper.modifyVector3(tempVec3, x, y, z)
	tempVec3[1] = x
	tempVec3[2] = y
	tempVec3[3] = z
end

function MapHelper.calPathDistance(path)
	local totalDistance = math.maxInt

	if not path then
		return totalDistance
	end

	if #path <= 1 then
		return totalDistance
	end

	totalDistance = 0

	for i = 1, #path - 1 do
		totalDistance = totalDistance + Vector3.Distance(path[i], path[i + 1])
	end

	return totalDistance
end

function MapHelper.popFirstElement(tbl)
	if #tbl == 0 then
		return nil
	end

	local firstElement = tbl[1]

	for i = 1, #tbl - 1 do
		tbl[i] = tbl[i + 1]
	end

	tbl[#tbl] = nil

	return firstElement
end

function MapHelper.getAreaRecommandLevel(levelAreaConfigId, countryId)
	countryId = countryId or 300001

	local SysConfigData = require("Data.sys_config_data")
	local mapData = MapBlockData[levelAreaConfigId]

	if not mapData then
		return nil
	end

	local starTitle = pg.me and pg.me.starTitle or 1
	local minLevel, maxLevel = Utils.formulaSafeCall(1, SysConfigData.DYNAMIC_LV_CALC_FUNC6, starTitle, mapData.minLevel, mapData.maxLevel, 1)

	return minLevel, maxLevel
end

function MapHelper.calXAndZKey(x, z, sceneId)
	if MapOverlapScene[sceneId] and SceneData[sceneId] then
		local wholemapOffset = SceneData[sceneId].wholemapOffset

		if wholemapOffset and #wholemapOffset == 3 then
			x = x + wholemapOffset[1]
			z = z + wholemapOffset[3]
		end
	end

	return math.floor(x / CHUNK_GAP), math.floor(z / CHUNK_GAP)
end

function MapHelper.calXAndZKeyEx(x, z)
	return math.floor(x / CHUNK_GAP), math.floor(z / CHUNK_GAP)
end

function MapHelper.GetSceneOffset(sceneId)
	if MapOverlapScene[sceneId] and SceneData[sceneId] then
		local wholemapOffset = SceneData[sceneId].wholemapOffset

		if wholemapOffset and #wholemapOffset == 3 then
			return wholemapOffset[1], wholemapOffset[3]
		end
	end

	return 0, 0
end

local combinedAllSeamlessSceneData = {}

function MapHelper.combineAllSeamlessSceneData(sceneId, spaceId)
	if combinedAllSeamlessSceneData and combinedAllSeamlessSceneData[sceneId] then
		return combinedAllSeamlessSceneData[sceneId]
	end

	local function mergeMarkPointData(result, sourceSceneId)
		local t = SceneUtils.getSceneMarkPointData(sourceSceneId, spaceId)

		if not t or next(t) == nil then
			return
		end

		for k, v in pairs(t) do
			result[k] = v
		end
	end

	local result = {}
	local mainT = SceneUtils.getSceneMarkPointData(sceneId, spaceId)

	for k, v in pairs(mainT) do
		result[k] = v
	end

	if SceneSeamlessData[sceneId] and SceneSeamlessData[sceneId].seamlessGroup then
		for seamlessId, _ in pairs(SceneSeamlessData[sceneId].seamlessGroup) do
			mergeMarkPointData(result, seamlessId)
		end
	end

	local rootSceneId = MapOverlapScene[sceneId]

	if rootSceneId then
		mergeMarkPointData(result, rootSceneId)

		if SceneSeamlessData[rootSceneId] and SceneSeamlessData[rootSceneId].seamlessGroup then
			for seamlessId, _ in pairs(SceneSeamlessData[rootSceneId].seamlessGroup) do
				mergeMarkPointData(result, seamlessId)
			end
		end
	else
		for overlapSceneId, overlapRootId in pairs(MapOverlapScene) do
			if overlapRootId == sceneId then
				mergeMarkPointData(result, overlapSceneId)
			end
		end
	end

	if combinedAllSeamlessSceneData then
		combinedAllSeamlessSceneData[sceneId] = result
	end

	return result
end

function MapHelper.getLeylineTreeIdByMarkId(markId)
	for _, v in pairs(MapAreaConfigData) do
		if v.Campid == markId then
			return v.treeId
		end
	end

	return nil
end

function MapHelper.checkBlockLeylineTreeUnlocked(areaId, leylineTreeInfoMap)
	local unlocked = false

	if not MapAreaConfigData[areaId] or not MapAreaConfigData[areaId].treeId then
		return unlocked
	end

	local treeId = MapAreaConfigData[areaId].treeId

	if not leylineTreeInfoMap or not leylineTreeInfoMap[treeId] then
		return unlocked
	end

	if not leylineTreeInfoMap[treeId].leylineTreeLevel then
		return unlocked
	end

	unlocked = leylineTreeInfoMap[treeId].leylineTreeLevel >= 0

	return unlocked
end

function MapHelper.serializeMapAreaSetting(setting)
	local result = {}

	for countryId, mapAreas in pairs(setting) do
		local mapAreaResult = {}

		if next(mapAreas) then
			for mapAreaId, smallAreas in pairs(mapAreas) do
				local smallMapAreaResult = {}

				if next(smallAreas) then
					for smallAreaId, value in pairs(smallAreas) do
						table.insert(smallMapAreaResult, tostring(smallAreaId))
					end
				end

				table.insert(mapAreaResult, string.format("%d:%s", mapAreaId, table.concat(smallMapAreaResult, "|")))
			end
		end

		if next(mapAreaResult) then
			table.insert(result, string.format("%d-%s", countryId, table.concat(mapAreaResult, "|")))
		end
	end

	return table.concat(result, ",")
end

function MapHelper.deserializeMapAreaSetting(str)
	local result = {}

	if str == nil or str == "" then
		return result
	end

	for countryEntry in string.gmatch(str, "[^,]+") do
		local countryIdStr, mapAreaInfoStr = string.match(countryEntry, "^(%d+)(-.*)$")

		if countryIdStr then
			local countryId = tonumber(countryIdStr)

			result[countryId] = {}

			if mapAreaInfoStr and mapAreaInfoStr ~= "" then
				local mapAreaStr, smallMapAreaStr = string.match(mapAreaInfoStr, "^-(%d+):(.*)$")
				local mapAreaId = tonumber(mapAreaStr)

				if mapAreaId then
					result[countryId][mapAreaId] = {}

					if smallMapAreaStr then
						for smallAreaIdStr in string.gmatch(smallMapAreaStr, "[^|]+") do
							local smallAreaId = tonumber(smallAreaIdStr)

							if smallAreaId then
								result[countryId][mapAreaId][smallAreaId] = true
							end
						end
					end
				end
			end
		end
	end

	return result
end

local _mapMarkPosCache = {}
local _MAP_MARK_SMOOTH_ALPHA = 0.3
local _MAP_MARK_SNAP_DIST_SQR = 9

function MapHelper.HasEntityPosSource(entityId)
	return entityId ~= nil and (pg.getEntity(entityId) ~= nil or pg.me:hasMovingEntityPosData(entityId)) or false
end

function MapHelper.GetEntityPos(entityId)
	if entityId then
		local ent = pg.getEntity(entityId)
		local entPos

		if ent then
			if ent.getMapMarkPosition then
				local fresh = ent:getMapMarkPosition()

				if fresh then
					local cached = _mapMarkPosCache[entityId]

					if not cached then
						cached = Vector3.New(fresh[1], fresh[2], fresh[3])
						_mapMarkPosCache[entityId] = cached
					else
						local dx = fresh[1] - cached[1]
						local dz = fresh[3] - cached[3]

						if dx * dx + dz * dz > _MAP_MARK_SNAP_DIST_SQR then
							cached:Copy(fresh)
						else
							local a = _MAP_MARK_SMOOTH_ALPHA

							cached:Set(cached[1] + (fresh[1] - cached[1]) * a, cached[2] + (fresh[2] - cached[2]) * a, cached[3] + (fresh[3] - cached[3]) * a)
						end
					end

					entPos = cached
				end
			else
				entPos = ent:getPosition()
			end
		elseif pg.me:hasMovingEntityPosData(entityId) then
			local cached = _mapMarkPosCache[entityId]

			if not cached then
				cached = Vector3.ForceNew(0, 0, 0)
				_mapMarkPosCache[entityId] = cached
			end

			entPos = pg.me:getMovingEntityPosData(entityId, cached)
		end

		return entPos
	end
end

function MapHelper.ClearEntityPosCache(entityId)
	if entityId then
		_mapMarkPosCache[entityId] = nil
	else
		_mapMarkPosCache = {}
	end
end

function MapHelper.getSceneIdByCountryId(countryId)
	return CountryAreaData[countryId].sceneId or 0
end

function MapHelper.GetMapBlockConfigData()
	return MapBlockConfigData
end

local _cacheSceneBlockList = {}

function MapHelper.GetBlockListBySceneId(mainSceneId)
	local blockIdList = _cacheSceneBlockList[mainSceneId]

	if blockIdList then
		return blockIdList
	end

	blockIdList = {}

	local configs = MapHelper.GetMapBlockConfigData()

	for blockId, config in pairs(configs) do
		local sceneId = LuaUIUtils.getSceneIdByCountryId(config.countryId)

		if sceneId == mainSceneId then
			blockIdList[#blockIdList + 1] = blockId
		end
	end

	return blockIdList
end

local _cacheBlocks = {}
local _cacheBlockList = {}
local _cacheBlockIdList = {}

function MapHelper.GetMainSceneBlockInfo(mainSceneId, spaceId)
	if testDataFromCofnig then
		return scene_block_info.data[mainSceneId] or _emptyTable
	end

	local blocks, blockIdList, blockList

	blocks = _cacheBlocks[mainSceneId]

	if not blocks then
		blocks, blockList, blockIdList = MapHelper.GetMainSceneBlockInfoEx(mainSceneId, spaceId)
		_cacheBlocks[mainSceneId] = blocks
		_cacheBlockList[mainSceneId] = blockList
		_cacheBlockIdList[mainSceneId] = blockIdList
	end

	if testDataCompare then
		local newBlocks = scene_block_info.data[mainSceneId] or _emptyTable

		if not table.isTableEqual(newBlocks, blocks) then
			logger:error(string.format("GetMainSceneBlockInfo error %d %s %s", mainSceneId, table.tostring(newBlocks), table.tostring(blocks)))
		end
	end

	return blocks
end

function MapHelper.GetMainSceneBlockList(mainSceneId, spaceId)
	if testDataFromCofnig then
		return scene_block_info.blockList[mainSceneId] or _emptyTable
	end

	local blocks, blockIdList, blockList

	blockList = _cacheBlockList[mainSceneId]

	if not blockList then
		blocks, blockList, blockIdList = MapHelper.GetMainSceneBlockInfoEx(mainSceneId, spaceId)
		_cacheBlocks[mainSceneId] = blocks
		_cacheBlockList[mainSceneId] = blockList
		_cacheBlockIdList[mainSceneId] = blockIdList
	end

	if testDataCompare then
		local newBlockList = scene_block_info.blockList[mainSceneId] or _emptyTable
		local result, reason = table.findDifferences2(newBlockList, blockList)

		if not result then
			logger:error(string.format("GetMainSceneBlockList error %d reason:%s", mainSceneId, reason))
			logger:error(table.tostring(newBlockList))
			logger:error(table.tostring(blockList))
			logger:error(MapHelper.array_hash_to_string(newBlockList))
			logger:error(MapHelper.array_hash_to_string(blockList))
		end
	end

	return blockList
end

function MapHelper.hash_to_string(tbl)
	local result, done = {}, {}

	for k, v in ipairs(tbl) do
		done[k] = true
	end

	for k, v in pairs(tbl) do
		if not done[k] then
			table.insert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
		end
	end

	return "{" .. table.concat(result, ",") .. "}"
end

function MapHelper.array_hash_to_string(tbl)
	local result, done = {}, {}

	for k, v in ipairs(tbl) do
		table.insert(result, MapHelper.hash_to_string(v))

		done[k] = true
	end

	for k, v in pairs(tbl) do
		if not done[k] then
			table.insert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
		end
	end

	return "{" .. table.concat(result, ",") .. "}"
end

function MapHelper.GetMainSceneBlockIdList(mainSceneId, spaceId)
	if testDataFromCofnig then
		return scene_block_info.blockIdList[mainSceneId] or _emptyTable
	end

	local blocks, blockIdList, blockList

	blockIdList = _cacheBlockIdList[mainSceneId]

	if not blockIdList then
		blocks, blockList, blockIdList = MapHelper.GetMainSceneBlockInfoEx(mainSceneId, spaceId)
		_cacheBlocks[mainSceneId] = blocks
		_cacheBlockList[mainSceneId] = blockList
		_cacheBlockIdList[mainSceneId] = blockIdList
	end

	if testDataCompare then
		local newBlockIdList = scene_block_info.blockIdList[mainSceneId] or _emptyTable

		if not table.isTableEqual(newBlockIdList, blockIdList) then
			logger:error(string.format("GetMainSceneBlockIdList error %d %s %s", mainSceneId, table.tostring(newBlockIdList), table.tostring(blockIdList)))
		end
	end

	return blockIdList
end

function MapHelper.GetMainSceneBlockInfoEx(mainSceneId, spaceId)
	local blockInfos = {}
	local blockList = {}
	local sceneMarkPointData = MapHelper.combineAllSeamlessSceneData(mainSceneId, spaceId)
	local relatedBlockId = MapHelper.GetBlockListBySceneId(mainSceneId)
	local blockIndex = {}

	for index, blockId in ipairs(relatedBlockId) do
		local block = MapBlockConfigData[blockId]
		local blockEntityIds = block.dividingLine
		local posSameAreaGroup = {}
		local minX = 99999999
		local maxX = -99999999
		local minY = 99999999
		local maxY = -99999999

		if blockEntityIds then
			for _, id in ipairs(blockEntityIds) do
				local specificMarkData = sceneMarkPointData[id]

				if specificMarkData then
					local mapX, mapY = MapHelper.convertPos(specificMarkData.markPosition[1], specificMarkData.markPosition[3], mainSceneId, true)

					posSameAreaGroup[#posSameAreaGroup + 1] = mapX
					posSameAreaGroup[#posSameAreaGroup + 1] = mapY
					minX = math.min(mapX, minX)
					maxX = math.max(mapX, maxX)
					minY = math.min(mapY, minY)
					maxY = math.max(mapY, maxY)
				end
			end
		end

		posSameAreaGroup.aabb = {
			minX,
			maxX,
			minY,
			maxY
		}

		local priority = block.priority

		posSameAreaGroup.priority = priority

		local func = block["function"]

		posSameAreaGroup.functionTypeValue = func and func[1] or nil
		posSameAreaGroup.blockId = blockId

		local blockInfo = {}

		blockInfo.priority = posSameAreaGroup.priority
		blockInfo.functionTypeValue = posSameAreaGroup.functionTypeValue
		blockInfos[blockId] = blockInfo
		blockList[#blockList + 1] = posSameAreaGroup
		blockIndex[blockId] = index
	end

	local function funcx(a, b)
		if a.priority ~= b.priority then
			return a.priority < b.priority
		end

		if MapSmallAreaIdToIndex[a.blockId] ~= nil ~= (MapSmallAreaIdToIndex[b.blockId] ~= nil) then
			if MapSmallAreaIdToIndex[a.blockId] then
				return true
			else
				return false
			end
		end

		return a.blockId < b.blockId
	end

	table.sort(blockList, funcx)

	local blockIdList = {}

	for i, arr in ipairs(blockList) do
		blockIdList[#blockIdList + 1] = arr.blockId
	end

	return blockInfos, blockList, blockIdList
end

function MapHelper.GetMapBlockDebugInfoString(mainSceneId)
	local json = require("json")
	local blocks = MapHelper.GetMapBlockDebugInfo(mainSceneId)

	return json.encode(blocks)
end

function MapHelper.GetMapBlockDebugInfo(mainSceneId, spaceId)
	local blockInfo = {}
	local sceneMarkPointData = MapHelper.combineAllSeamlessSceneData(mainSceneId, spaceId)
	local relatedBlockId = MapHelper.GetBlockListBySceneId(mainSceneId)

	for _, blockId in pairs(relatedBlockId) do
		local block = MapBlockConfigData[blockId]
		local blockEntityIds = block.dividingLine
		local posSameAreaGroup = {}

		if blockEntityIds then
			for _, id in pairs(blockEntityIds) do
				local specificMarkData = sceneMarkPointData[id]

				if specificMarkData then
					local mapX, mapY = MapHelper.convertPos(specificMarkData.markPosition[1], specificMarkData.markPosition[3], mainSceneId, true)

					posSameAreaGroup[#posSameAreaGroup + 1] = mapX
					posSameAreaGroup[#posSameAreaGroup + 1] = mapY
				end
			end
		end

		blockInfo[blockId] = posSameAreaGroup
	end

	return blockInfo
end

function MapHelper.loadCustomAreaConfigData(sceneId)
	local CustomAreaConfigData = require("Data.map_custom_area_config_data")
	local t = {}

	for _, data in pairs(CustomAreaConfigData) do
		if data.Mapid == sceneId then
			local area = {}

			for _, points in pairs(data.ZoneArea[1]) do
				local point = {}

				point[1] = points[1]
				point[2] = points[2]
				area[#area + 1] = point
			end

			t[#t + 1] = area
		end
	end

	return t
end

local _markPriorityList = {
	0,
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	99,
	100
}

MapHelper.trackPriority = 101
MapHelper.topPriority = 99

function MapHelper.GetMarkPriorityList()
	return _markPriorityList
end

function MapHelper.IsShowTeam(sceneId)
	return SceneData[sceneId].showTeamNot == 1
end

function MapHelper.findMemberInfoEntityId(memberInfo, entityId)
	for _, v in pairs(memberInfo) do
		if v.entityId == entityId then
			return true
		end
	end

	return false
end

function MapHelper.getCountryAreaUnlockDict()
	if pg.me == nil then
		return
	end

	local allCountyDict = {}
	local areaFirstInDic = pg.me:getAreaFirstInDataDict()

	for smallAreaId, v in pairs(areaFirstInDic) do
		local smallAreaConfig = MapBlockData[smallAreaId]

		if smallAreaConfig then
			local countryId = smallAreaConfig.countryId
			local mapAreaId = smallAreaConfig.mapAreaId

			if allCountyDict[countryId] == nil then
				allCountyDict[countryId] = {}
			end

			if allCountyDict[countryId][mapAreaId] == nil then
				allCountyDict[countryId][mapAreaId] = {}
			end

			table.insert(allCountyDict[countryId][mapAreaId], smallAreaId)
		end
	end

	return allCountyDict
end

function MapHelper.getNationAreaUnlockList(nationId)
	if pg.me == nil then
		return
	end

	local allCountyList = {}
	local areaFirstInDic = pg.me:getAreaFirstInDataDict()
	local canShow

	for smallAreaId, v in pairs(areaFirstInDic) do
		local smallAreaConfig = MapBlockData[smallAreaId]

		if smallAreaConfig and smallAreaConfig.desc ~= nil then
			local mapAreaId = smallAreaConfig.mapAreaId
			local mapAreaConfigData = MapAreaConfigData[mapAreaId]
			local belongNationId

			if mapAreaConfigData ~= nil then
				belongNationId = mapAreaConfigData.belongNation
			end

			canShow = true

			if nationId and belongNationId ~= nationId then
				canShow = false
			end

			if canShow then
				local countryInfo

				for i = 1, #allCountyList do
					local country = allCountyList[i] or {}

					if country.countryId == belongNationId then
						countryInfo = country

						break
					end
				end

				if countryInfo == nil then
					countryInfo = {
						countryId = belongNationId,
						mapAreaIdList = {}
					}

					table.insert(allCountyList, countryInfo)
				end

				local mapAreaCount = #countryInfo.mapAreaIdList
				local mapAreaInfo

				for i = 1, mapAreaCount do
					if countryInfo.mapAreaIdList[i].mapAreaId == mapAreaId then
						mapAreaInfo = countryInfo.mapAreaIdList[i]

						break
					end
				end

				if mapAreaInfo == nil then
					mapAreaInfo = {
						countryId = belongNationId,
						mapAreaId = mapAreaId,
						smallAreaIdList = {}
					}

					table.insert(countryInfo.mapAreaIdList, mapAreaInfo)
				end

				table.insert(mapAreaInfo.smallAreaIdList, {
					countryId = belongNationId,
					mapAreaId = mapAreaId,
					smallAreaId = smallAreaId
				})
			end
		end
	end

	return allCountyList
end

function MapHelper.clearSceneDataCache()
	_sceneDataCachesNew = {}
	_cacheSceneBlockList = {}
	_cacheBlocks = {}
	_cacheBlockList = {}

	if testDataCompare then
		local scene_data = require("Data.scene_data")

		for sceneId in pairs(scene_data) do
			local blocks, blockList, blockIdList = MapHelper.GetMainSceneBlockInfoEx(sceneId)
			local newBlockList = scene_block_info.blockList[sceneId] or _emptyTable
			local result, reason = table.findDifferences2(newBlockList, blockList)

			if not result then
				logger:error(string.format("MapHelper.blockList error %d %s", sceneId, reason))
			end

			local newBlocks = scene_block_info.data[sceneId] or _emptyTable

			if not table.isTableEqual(newBlocks, blocks) then
				logger:error(string.format("MapHelper.data error %d %s %s", sceneId, table.tostring(newBlocks), table.tostring(blocks)))
			end

			local newBlockIdList = scene_block_info.blockIdList[sceneId] or _emptyTable

			if not table.isTableEqual(newBlockIdList, blockIdList) then
				logger:error(string.format("MapHelper.blockIdList error %d %s %s", sceneId, table.tostring(newBlockIdList), table.tostring(blockIdList)))
			end
		end
	end
end

function MapHelper.checkMapForceOpen(sceneId)
	local sceneData = SceneData[sceneId]

	if sceneData and sceneData.forceOpen == 1 then
		return true
	end

	return false
end

function MapHelper.getMapOffsetUI(sceneId)
	local sceneData = SceneData[sceneId]

	if sceneData and sceneData.mapOffsetUI then
		return sceneData.mapOffsetUI
	end

	return nil
end

function MapHelper.getCustomMarkGenId(id, sceneId)
	local preFix = sceneId .. Const.MAP_MARK_CUSTOM .. Const.MAP_MARK_CUSTOM
	local customMarkGenId = tonumber(string.sub(tostring(id), #preFix + 1))

	return customMarkGenId
end

function MapHelper.getPetCollectBadgeIconResId(smallAreaId)
	local serverData = pg.me.badgeUnlockInfoMap

	if not serverData then
		return AddressDataConst.UI_ICON_BADGE_1
	end

	local configData = MapBlockConfigData[smallAreaId] or {}
	local bronzeRequire = configData.badge1 or 0
	local silverRequire = configData.badge2 or 0
	local goldRequire = configData.badge3 or 0
	local rainbowRequire = configData.badge4 or 0

	local function checkBadgeExists(badgeId)
		local serverUnlockinfo = serverData[badgeId]

		if not serverUnlockinfo then
			return false
		end

		return true
	end

	if checkBadgeExists(rainbowRequire) then
		return AddressDataConst.UI_ICON_BADGE_5
	end

	if checkBadgeExists(goldRequire) then
		return AddressDataConst.UI_ICON_BADGE_4
	end

	if checkBadgeExists(silverRequire) then
		return AddressDataConst.UI_ICON_BADGE_3
	end

	if checkBadgeExists(bronzeRequire) then
		return AddressDataConst.UI_ICON_BADGE_2
	end

	return AddressDataConst.UI_ICON_BADGE_1
end

return MapHelper
