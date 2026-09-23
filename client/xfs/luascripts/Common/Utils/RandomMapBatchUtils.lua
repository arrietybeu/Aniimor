-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\RandomMapBatchUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SceneDataConst = require("Common.Const.SceneDataConst")
local Const = require("Common.Const.Const")
local SceneData = require("Data.scene_data")
local MapMarkIdToConfigId = require("Data.map_mark_id_to_config_id")
local SandboxConst = require("Common.Const.SandboxConst")
local DigongRwardData = require("Data.digong_reward_data")
local DigongLightSourceData = require("Data.digong_light_data")
local RandomMapConst = require("Common.Const.RandomMapConst")
local RobEggConst = require("Common.Const.RobEggConst")
local routeDefaultValueData = require("Common.Data.Scene.route_default_value_data")
local WAY_POINT_DEFAULTS = routeDefaultValueData and routeDefaultValueData.wayPoints or {}
local pi = math.pi
local cos = math.cos
local sin = math.sin
local sandBoxConfigType = {
	Refresh = 8,
	Monster = 5,
	EggNest = 4,
	LightSource = 3,
	Reward = 2,
	Trap = 1,
	NoSelect = 0
}
local RoomSceneId = 10000
local _StockInitCacheData

local function applyProximityMapMarkConfig(markData)
	local activeDistance = markData and RobEggConst.PROXIMITY_MAP_MARK_ACTIVE_DISTANCE[markData.markConfigId]

	if not activeDistance then
		return
	end

	markData.initState = Const.MAP_MARK_STATUS_HIDE
	markData.openMapState = Const.MAP_MARK_STATUS_HIDE
	markData.activeState = Const.MAP_MARK_STATUS_UNLOCKED
	markData.activeDistance = activeDistance
end

local RandomMapBatchUtils = {
	_SrcData = {},
	_CacheData = {},
	_IdMap = {},
	_AreaIdMap = {}
}

RandomMapBatchUtils.scene_room_data = "scene_room_data"
RandomMapBatchUtils.batchFullData = true

function RandomMapBatchUtils.isUndergroundScene(sceneId)
	local sceneData = SceneData[sceneId] or {}

	if sceneData.type == Const.SPACE_TYPE_ROBEGG_UNDERGROUND then
		return true
	end

	return false
end

function RandomMapBatchUtils.getSceneData(dataName, sceneId, spaceId)
	sceneId = sceneId or RoomSceneId

	local spaceSrc = RandomMapBatchUtils._SrcData[spaceId]

	if spaceSrc == nil then
		spaceSrc = {}
		RandomMapBatchUtils._SrcData[spaceId] = spaceSrc
	end

	local sceneSrc = spaceSrc[sceneId]

	if sceneSrc == nil then
		sceneSrc = {}
		spaceSrc[sceneId] = sceneSrc
	end

	if sceneSrc[dataName] then
		return sceneSrc[dataName]
	end

	local partDataFlag = false

	if SceneDataConst.usePartData then
		for _, v in ipairs(SceneDataConst.part_data_names) do
			if dataName == v then
				partDataFlag = true

				break
			end
		end
	end

	local status, sceneData

	if partDataFlag then
		sceneData = {}

		local sceneDataPathLen = string.format(SceneDataConst.dataPathPrefix_part_len, sceneId, dataName, dataName)
		local statusLen, partLenTable = pcall(require, sceneDataPathLen)

		if not statusLen then
			partLenTable = {
				count = 0
			}
			package.loaded[sceneDataPathLen] = nil
		end

		for i = 1, partLenTable.count do
			local sceneDataPartPath = string.format(SceneDataConst.dataPathPrefix_part, sceneId, dataName, dataName, i)
			local statusPart, partData = pcall(require, sceneDataPartPath)

			if not statusPart then
				partData = {}
			end

			for k, v in pairs(partData) do
				sceneData[k] = v
			end

			package.loaded[sceneDataPartPath] = nil
		end
	else
		local sceneDataPath = string.format(SceneDataConst.dataPathPrefix, sceneId, dataName)

		status, sceneData = pcall(require, sceneDataPath)

		if not status then
			sceneData = {}
		end
	end

	sceneSrc[dataName] = sceneData

	return sceneData
end

function RandomMapBatchUtils.getSceneDataFromCache(sceneId, dataName, spaceId)
	local cacheScene = RandomMapBatchUtils._CacheData[spaceId]

	if not cacheScene then
		return {}
	end

	local cacheData = cacheScene[dataName] or {}

	return cacheData
end

function RandomMapBatchUtils.getMapMarkConfigData(spaceId)
	if spaceId then
		local cacheScene = RandomMapBatchUtils._CacheData[spaceId]
		local resData = cacheScene and cacheScene[SceneDataConst.map_mark_id_to_config_id]

		if resData then
			return resData
		end
	end

	return MapMarkIdToConfigId
end

function RandomMapBatchUtils.getInitCacheData(spaceId)
	if spaceId then
		local cacheScene = RandomMapBatchUtils._CacheData[spaceId]
		local resData = cacheScene and cacheScene[SceneDataConst.init_cache_data]

		if resData then
			return resData
		end
	end

	if _StockInitCacheData == nil and pg.component == "game" then
		_StockInitCacheData = require("Data.init_cache_data")
	end

	return _StockInitCacheData
end

function RandomMapBatchUtils.clearSceneCacheData(spaceId)
	RandomMapBatchUtils._CacheData[spaceId] = nil
	RandomMapBatchUtils._SrcData[spaceId] = nil
	RandomMapBatchUtils._IdMap[spaceId] = nil
	RandomMapBatchUtils._AreaIdMap[spaceId] = nil
end

function RandomMapBatchUtils.batchSceneData(sceneId, hardLv, sandboxIdsMap, spaceId)
	local cacheScene = RandomMapBatchUtils._CacheData[spaceId]

	if not cacheScene then
		cacheScene = {}
		RandomMapBatchUtils._CacheData[spaceId] = cacheScene
	else
		return
	end

	local Utils = require("Common.Utils.Utils")
	local roomDataMap = RandomMapBatchUtils.getSceneData(RandomMapBatchUtils.scene_room_data, sceneId, spaceId)

	if pg.component == "client" then
		SampleUtils.beginSample("RandomMapBatchUtils.batchSceneData")
	end

	if not RandomMapBatchUtils.batchFullData then
		local sceneSandBoxData = RandomMapBatchUtils.batchSceneSandboxData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_sandbox_data] = sceneSandBoxData

		local sceneSandboxInitData, sceneSandboxGlobalData, sceneSandboxFarawayData = RandomMapBatchUtils.batchSceneSandboxAdditionData(sceneSandBoxData)

		cacheScene[SceneDataConst.scene_sandbox_init_data] = sceneSandboxInitData
		cacheScene[SceneDataConst.scene_sandbox_global_data] = sceneSandboxGlobalData
		cacheScene[SceneDataConst.scene_sandbox_faraway_data] = sceneSandboxFarawayData

		local sceneSpawnerData = RandomMapBatchUtils.batchSceneSpawnerData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_spawner_data] = sceneSpawnerData

		local sceneAreaData = RandomMapBatchUtils.batchSceneAreaData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_area_data] = sceneAreaData

		local sceneGlobalAreaData = RandomMapBatchUtils.batchSceneGlobalAreaData(sceneAreaData)

		cacheScene[SceneDataConst.scene_global_area_data] = sceneGlobalAreaData

		local sceneGraphData = RandomMapBatchUtils.batchSceneGraphData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_graph_data] = sceneGraphData

		local sceneEntityData = RandomMapBatchUtils.batchSceneEntityData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_entity_data] = sceneEntityData

		local sceneRouteData = RandomMapBatchUtils.batchSceneRouteData(roomDataMap, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_route_data] = sceneRouteData

		local sceneMarkData, sceneMarkPointData, sceneMarkTypeData = RandomMapBatchUtils.batchSceneMarkData({
			sceneSandBoxData,
			sceneSpawnerData,
			sceneEntityData
		}, Utils.deepCopyTable, spaceId)

		cacheScene[SceneDataConst.scene_mark_data] = sceneMarkData
		cacheScene[SceneDataConst.scene_mark_point_data] = sceneMarkPointData
		cacheScene[SceneDataConst.scene_mark_type_data] = sceneMarkTypeData
	else
		RandomMapBatchUtils.batchSceneDataFull(sceneId, cacheScene, roomDataMap, Utils.deepCopyTable, hardLv, sandboxIdsMap, spaceId)
	end

	RandomMapBatchUtils.batchPostGenerateData(sceneId, Utils.deepCopyTable, spaceId)

	if pg.component == "client" then
		SampleUtils.endSample()
	end
end

function RandomMapBatchUtils.batchSceneDataFull(sceneId, cacheScene, roomDataMap, copyHandler, hardLv, sandboxIdsMap, spaceId)
	cacheScene[SceneDataConst.scene_sandbox_data] = {}

	local resSandboxData = cacheScene[SceneDataConst.scene_sandbox_data]

	cacheScene[SceneDataConst.scene_sandbox_init_data] = {}

	local resSandboxInitData = cacheScene[SceneDataConst.scene_sandbox_init_data]

	cacheScene[SceneDataConst.scene_sandbox_faraway_data] = {}

	local resSandboxFarawayData = cacheScene[SceneDataConst.scene_sandbox_faraway_data]

	cacheScene[SceneDataConst.scene_sandbox_global_data] = {}

	local resSandboxGlobalData = cacheScene[SceneDataConst.scene_sandbox_global_data]

	cacheScene[SceneDataConst.scene_spawner_data] = {}

	local resSpawnerData = cacheScene[SceneDataConst.scene_spawner_data]

	cacheScene[SceneDataConst.scene_area_data] = {}

	local resAreaData = cacheScene[SceneDataConst.scene_area_data]

	cacheScene[SceneDataConst.scene_global_area_data] = {}

	local resGlobalAreaData = cacheScene[SceneDataConst.scene_global_area_data]

	cacheScene[SceneDataConst.scene_graph_data] = {}

	local resGraphData = cacheScene[SceneDataConst.scene_graph_data]

	cacheScene[SceneDataConst.scene_entity_data] = {}

	local resEntityData = cacheScene[SceneDataConst.scene_entity_data]

	cacheScene[SceneDataConst.scene_route_data] = {}

	local resRouteData = cacheScene[SceneDataConst.scene_route_data]

	cacheScene[SceneDataConst.scene_mark_data] = {}

	local resMarkData = cacheScene[SceneDataConst.scene_mark_data]

	cacheScene[SceneDataConst.scene_mark_point_data] = {}

	local resMarkPointData = cacheScene[SceneDataConst.scene_mark_point_data]

	cacheScene[SceneDataConst.scene_mark_type_data] = {}

	local resMarkTypeData = cacheScene[SceneDataConst.scene_mark_type_data]

	cacheScene.refreshSandboxesByLevel = {}

	local resRefreshByLevel = cacheScene.refreshSandboxesByLevel
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcSpawnerData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_spawner_data, nil, spaceId)
	local srcAreaData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_area_data, nil, spaceId)
	local srcGraphData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_graph_data, nil, spaceId)
	local srcEntityData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_entity_data, nil, spaceId)
	local srcRouteData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_route_data, nil, spaceId)
	local srcMarkPointData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_mark_point_data, nil, spaceId)

	local function queryFunc(roomInstId, sandboxOrSpawnerId)
		return RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxOrSpawnerId, spaceId)
	end

	local calculateFunc = RandomMapBatchUtils.calculateNewPositionV2

	sandboxIdsMap = sandboxIdsMap or RandomMapBatchUtils.filterSandbox(roomDataMap, srcSandboxData, hardLv, copyHandler)
	cacheScene.sandboxIdsMap = sandboxIdsMap

	local sandboxToOrphanMarks

	if next(srcMarkPointData) ~= nil then
		sandboxToOrphanMarks = {}

		for markId, markItem in pairs(srcMarkPointData) do
			local sId = markItem and markItem.sandboxId

			if sId and ToBool(sId) then
				sandboxToOrphanMarks[sId] = sandboxToOrphanMarks[sId] or {}
				sandboxToOrphanMarks[sId][markId] = markItem
			end
		end
	end

	local sandboxToRoutes = {}

	for routeId, routeItem in pairs(srcRouteData) do
		local sId = routeItem and routeItem.sandboxId

		if sId and ToBool(sId) then
			sandboxToRoutes[sId] = sandboxToRoutes[sId] or {}

			table.insert(sandboxToRoutes[sId], routeId)
		end
	end

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = sandboxIdsMap[roomInstId] or {}
		local offset = rData.position or {
			0,
			0,
			0
		}
		local yaw = rData.yaw or 0
		local angleRad = yaw * pi / 180
		local cosA = cos(angleRad)
		local sinA = sin(angleRad)
		local halfRad = angleRad * 0.5
		local halfCos = cos(halfRad)
		local halfSin = sin(halfRad)

		for _, sandboxId in ipairs(sandboxIds) do
			local newSandboxId = queryFunc(roomInstId, sandboxId)
			local sadData = srcSandboxData[sandboxId] or {}
			local copySandboxData = copyHandler(sadData)

			copySandboxData.id = newSandboxId
			copySandboxData.roomInstanceId = roomInstId
			copySandboxData.graphId = queryFunc(roomInstId, sadData.graphId)

			local spawnerIds = copySandboxData.spawners or {}
			local num = #spawnerIds

			if num > 0 then
				for i = num, 1, -1 do
					local spawnerId = spawnerIds[i]
					local newSpawnerId = queryFunc(roomInstId, spawnerId)
					local spaData = srcSpawnerData[spawnerId] or {}
					local copySpawnerData = copyHandler(spaData)

					copySpawnerData.id = newSpawnerId
					copySpawnerData.sandboxId = newSandboxId

					local entityGroups = copySpawnerData.spawnGroups or {}

					for _, group in ipairs(entityGroups) do
						local entityIds = group.spawnIds or {}
						local jNum = #entityIds

						for j = jNum, 1, -1 do
							local entityId = entityIds[j]
							local newEntityId = queryFunc(roomInstId, entityId)
							local srcEntity = srcEntityData[entityId] or {}
							local copyEntityData = copyHandler(srcEntity)

							copyEntityData.staticId = newEntityId
							copyEntityData.routeId = queryFunc(roomInstId, srcEntity.routeId)

							local routeRefs = copyEntityData.routeRefs or {}
							local kNum = #routeRefs

							for k = kNum, 1, -1 do
								local routeId = queryFunc(roomInstId, routeRefs[k])

								routeRefs[k] = routeId
							end

							copyEntityData.sandboxId = newSandboxId
							copyEntityData.spawnerId = newSpawnerId

							calculateFunc(copyEntityData.position, offset, cosA, sinA)
							RandomMapBatchUtils.combineYaw(copyEntityData, "yaw", yaw)
							RandomMapBatchUtils.combineQuatYaw(copyEntityData.rotation, halfCos, halfSin)

							resEntityData[newEntityId] = copyEntityData

							RandomMapBatchUtils.batchSceneDataFull_Mark(sceneId, newEntityId, newSandboxId, offset, cosA, sinA, copyEntityData, srcMarkPointData, resMarkPointData, resMarkData, resMarkTypeData, copyHandler, roomInstId)

							entityIds[j] = newEntityId
						end
					end

					calculateFunc(copySpawnerData.position, offset, cosA, sinA)

					resSpawnerData[newSpawnerId] = copySpawnerData

					RandomMapBatchUtils.batchSceneDataFull_Mark(sceneId, newSpawnerId, newSandboxId, offset, cosA, sinA, copySpawnerData, srcMarkPointData, resMarkPointData, resMarkData, resMarkTypeData, copyHandler, roomInstId)

					spawnerIds[i] = newSpawnerId
				end
			end

			local routeIds = sandboxToRoutes[sandboxId]

			if routeIds then
				for _, routeId in ipairs(routeIds) do
					local srcRoute = srcRouteData[routeId] or {}
					local rawData = copyHandler(srcRoute)
					local newRouteId = queryFunc(roomInstId, routeId)

					rawData.id = newRouteId
					rawData.sandboxId = newSandboxId

					calculateFunc(rawData.pos, offset, cosA, sinA)
					RandomMapBatchUtils.combineQuatYaw(rawData.quaternion, halfCos, halfSin)

					local wayPoints = rawData.wayPoints or {}

					for _, point in ipairs(wayPoints) do
						calculateFunc(point.position, offset, cosA, sinA)
						RandomMapBatchUtils.combineYaw(point, "yaw", yaw)
					end

					resRouteData[newRouteId] = rawData
				end
			end

			local areaIds = copySandboxData.areaIds or {}

			num = #areaIds

			if num > 0 then
				for i = num, 1, -1 do
					local areaId = areaIds[i]
					local newAreaId = RandomMapBatchUtils.queryOrRecorderNewAreaId(roomInstId, areaId, spaceId)
					local areaData = srcAreaData[areaId] or {}
					local rawData = copyHandler(areaData)

					rawData.id = newAreaId
					rawData.sandboxId = newSandboxId

					RandomMapBatchUtils.calculateNewPosition(rawData.position, offset, yaw)
					RandomMapBatchUtils.offsetAreaPoints(rawData.areaPoints, offset, cosA, sinA)

					resAreaData[newAreaId] = rawData

					if areaData.areaLoadType == Const.AREA_LOAD_TYPE.SCENE_LOAD then
						resGlobalAreaData[newAreaId] = rawData
					end

					areaIds[i] = newAreaId
				end
			end

			calculateFunc(copySandboxData.position, offset, cosA, sinA)

			local levelItems = sadData.levelItems or {}
			local cpLevelItems = copySandboxData.levelItems or {}

			for lItemId, _ in pairs(levelItems) do
				local newLItemId = queryFunc(roomInstId, lItemId)
				local cpItemData = cpLevelItems[lItemId]

				cpItemData.id = newLItemId

				calculateFunc(cpItemData.position, offset, cosA, sinA)
				RandomMapBatchUtils.combineEulerYaw(cpItemData.rotation, yaw)

				local cmpItems = cpItemData.componentsInfo or {}

				for _, cmpItem in pairs(cmpItems) do
					calculateFunc(cmpItem.initPosition, offset, cosA, sinA)
					RandomMapBatchUtils.combineQuatYaw(cmpItem.initRotation, halfCos, halfSin)
				end

				cpLevelItems[lItemId] = nil
				cpLevelItems[newLItemId] = cpItemData
			end

			resSandboxData[newSandboxId] = copySandboxData

			if copySandboxData.sandBoxConfigType == sandBoxConfigType.Refresh then
				local lv = copySandboxData.sandBoxLevel

				if lv ~= nil then
					local bucket = resRefreshByLevel[lv]

					if not bucket then
						bucket = {}
						resRefreshByLevel[lv] = bucket
					end

					table.insert(bucket, newSandboxId)
				end
			end

			RandomMapBatchUtils.batchSceneDataFull_Mark(sceneId, newSandboxId, newSandboxId, offset, cosA, sinA, copySandboxData, srcMarkPointData, resMarkPointData, resMarkData, resMarkTypeData, copyHandler, roomInstId)

			local orphanMarks = sandboxToOrphanMarks and sandboxToOrphanMarks[sandboxId]

			if orphanMarks then
				for markId, srcMark in pairs(orphanMarks) do
					local newMarkId = RandomMapBatchUtils.queryMarkId(roomInstId, markId)

					if resMarkPointData[newMarkId] == nil then
						local rawData = copyHandler(srcMark)

						RandomMapBatchUtils.calculateNewPositionV2(rawData.markPosition, offset, cosA, sinA)

						if rawData.ownerInfo then
							rawData.ownerInfo[2] = newMarkId
						end

						rawData.sandboxId = newSandboxId
						rawData.realSceneId = sceneId

						applyProximityMapMarkConfig(rawData)

						resMarkPointData[newMarkId] = rawData

						local markType = srcMark.markType

						if not ToBool(resMarkData[markType]) then
							resMarkData[markType] = {}
						end

						resMarkData[markType][newMarkId] = rawData

						if not ToBool(resMarkTypeData[markType]) then
							resMarkTypeData[markType] = {}
						end

						table.insert(resMarkTypeData[markType], newMarkId)
					end
				end
			end

			if copySandboxData.activeOnInit == SandboxConst.ACTIVE_TYPE.INIT then
				resSandboxInitData[newSandboxId] = true
			end

			if copySandboxData.sightLevel == SandboxConst.SIGHT_LEVEL.GLOBAL then
				resSandboxGlobalData[newSandboxId] = true
			end

			if copySandboxData.sightLevel == SandboxConst.SIGHT_LEVEL.FARAWAY then
				resSandboxFarawayData[newSandboxId] = true
			end

			local graphId = sadData.graphId
			local newGraphId = queryFunc(roomInstId, graphId)

			if ToBool(newGraphId) then
				local graData = srcGraphData[graphId] or {}
				local copyGraphData = copyHandler(graData)

				copyGraphData.graphId = newGraphId

				local nodes = copyGraphData.nodes or {}

				for _, node in pairs(nodes) do
					local _inputPortValues = node._inputPortValues or {}

					_inputPortValues.SpawnerId = queryFunc(roomInstId, _inputPortValues.SpawnerId)
					_inputPortValues.spawnerId = queryFunc(roomInstId, _inputPortValues.spawnerId)
					_inputPortValues.staticId = queryFunc(roomInstId, _inputPortValues.staticId)
					_inputPortValues.StaticId = queryFunc(roomInstId, _inputPortValues.StaticId)
					_inputPortValues.LevelItemId = queryFunc(roomInstId, _inputPortValues.LevelItemId)

					local eventParams = node.eventParams or {}

					eventParams.spawnerId = queryFunc(roomInstId, eventParams.spawnerId)
					eventParams.staticId = queryFunc(roomInstId, eventParams.staticId)
					eventParams.puppetStaticId = queryFunc(roomInstId, eventParams.puppetStaticId)

					local staticId = node.staticId

					node.staticId = queryFunc(roomInstId, staticId)
				end

				resGraphData[newGraphId] = copyGraphData
			end
		end
	end
end

local hardLvMap = {
	Chaos = 6,
	NightMare = 5,
	Hard = 4,
	Normal = 3
}
local sandBoxTrapEnum = {
	T2 = 2,
	T1 = 1,
	T0 = 0,
	T3 = 3
}
local sandBoxRewardEnum = {
	G5 = 5,
	G6 = 6,
	G0 = 0,
	G1 = 1,
	G2 = 2,
	G3 = 3,
	G4 = 4
}
local sandBoxRewardOrder = {
	"G6",
	"G5",
	"G4",
	"G3",
	"G2",
	"G1",
	"G0"
}
local sandBoxLightSourceEnum = {
	L0 = 0,
	L2 = 2,
	L1 = 1
}
local sandBoxMonsterEnum = {
	M4 = 4,
	M3 = 3,
	M2 = 2,
	M1 = 1,
	M0 = 0
}
local specialRewardRoomSuffixMap = {
	uniquebuild = true,
	uniquebulid = true
}

local function isSpecialRewardRoom(roomData)
	local resId = roomData and roomData.resId

	if type(resId) ~= "string" then
		return false
	end

	local normalizedResId = string.lower(resId)
	local suffix = string.match(normalizedResId, "_([^_%.]+)%.prefab$")

	return suffix and specialRewardRoomSuffixMap[suffix] or false
end

local difficultyEnum = {
	K9 = 9,
	K8 = 8,
	K7 = 7,
	K6 = 6,
	K5 = 5,
	K4 = 4,
	K3 = 3,
	K2 = 2,
	K1 = 1,
	K0 = 0
}
local DifficultyToTrapAndMonster = {
	[difficultyEnum.K0] = {
		{
			sandBoxMonsterEnum.M0,
			sandBoxTrapEnum.T0
		}
	},
	[difficultyEnum.K1] = {
		{
			sandBoxMonsterEnum.M0,
			sandBoxTrapEnum.T1
		}
	},
	[difficultyEnum.K2] = {
		{
			sandBoxMonsterEnum.M1,
			sandBoxTrapEnum.T0
		},
		{
			sandBoxMonsterEnum.M0,
			sandBoxTrapEnum.T2
		}
	},
	[difficultyEnum.K3] = {
		{
			sandBoxMonsterEnum.M1,
			sandBoxTrapEnum.T1
		}
	},
	[difficultyEnum.K4] = {
		{
			sandBoxMonsterEnum.M1,
			sandBoxTrapEnum.T2
		},
		{
			sandBoxMonsterEnum.M2,
			sandBoxTrapEnum.T0
		}
	},
	[difficultyEnum.K5] = {
		{
			sandBoxMonsterEnum.M2,
			sandBoxTrapEnum.T1
		},
		{
			sandBoxMonsterEnum.M2,
			sandBoxTrapEnum.T2
		}
	},
	[difficultyEnum.K6] = {
		{
			sandBoxMonsterEnum.M2,
			sandBoxTrapEnum.T3
		},
		{
			sandBoxMonsterEnum.M3,
			sandBoxTrapEnum.T0
		},
		{
			sandBoxMonsterEnum.M3,
			sandBoxTrapEnum.T1
		}
	},
	[difficultyEnum.K7] = {
		{
			sandBoxMonsterEnum.M3,
			sandBoxTrapEnum.T2
		},
		{
			sandBoxMonsterEnum.M3,
			sandBoxTrapEnum.T3
		}
	},
	[difficultyEnum.K8] = {
		{
			sandBoxMonsterEnum.M4,
			sandBoxTrapEnum.T1
		},
		{
			sandBoxMonsterEnum.M4,
			sandBoxTrapEnum.T2
		}
	},
	[difficultyEnum.K9] = {
		{
			sandBoxMonsterEnum.M4,
			sandBoxTrapEnum.T3
		}
	}
}
local RewardToDifficulty = {
	[sandBoxRewardEnum.G0] = {
		difficultyEnum.K0
	},
	[sandBoxRewardEnum.G1] = {
		difficultyEnum.K1,
		difficultyEnum.K2
	},
	[sandBoxRewardEnum.G2] = {
		difficultyEnum.K3,
		difficultyEnum.K4
	},
	[sandBoxRewardEnum.G3] = {
		difficultyEnum.K5,
		difficultyEnum.K6
	},
	[sandBoxRewardEnum.G4] = {
		difficultyEnum.K7
	},
	[sandBoxRewardEnum.G5] = {
		difficultyEnum.K8
	},
	[sandBoxRewardEnum.G6] = {
		difficultyEnum.K9
	}
}

function RandomMapBatchUtils.filterRoomsWithReward(roomList, roomInstToSandboxMap, rewardLevel)
	local result = {}

	for _, roomInsId in ipairs(roomList) do
		local rewardByLevel = roomInstToSandboxMap[roomInsId] and roomInstToSandboxMap[roomInsId][sandBoxConfigType.Reward]
		local rewards = rewardByLevel and rewardByLevel[rewardLevel]

		if rewards and #rewards > 0 then
			table.insert(result, roomInsId)
		end
	end

	return result
end

local function weightedRandomSampleRewardRooms(roomList, priorityRoomMap, weightMap, count)
	count = math.floor(tonumber(count) or 0)

	if count <= 0 then
		return {}
	end

	local priorityRooms = {}
	local normalRooms = {}

	for _, roomInsId in ipairs(roomList or EMPTY_TABLE) do
		if priorityRoomMap and priorityRoomMap[roomInsId] then
			table.insert(priorityRooms, roomInsId)
		else
			table.insert(normalRooms, roomInsId)
		end
	end

	local result = RandomMapBatchUtils.weightedRandomSample(priorityRooms, weightMap, count)
	local remainCount = count - #result

	if remainCount > 0 then
		local normalResult = RandomMapBatchUtils.weightedRandomSample(normalRooms, weightMap, remainCount)

		for _, roomInsId in ipairs(normalResult) do
			table.insert(result, roomInsId)
		end
	end

	return result
end

local function deployRandomPriorityRewards(roomList, priorityRoomMap, roomInstToSandboxMap, rewardRemainNums, weightMap, resRoomSandBoxMap)
	if not priorityRoomMap then
		return {}
	end

	local highestRewardIndex

	for index, rewardType in ipairs(sandBoxRewardOrder) do
		if (rewardRemainNums[rewardType] or 0) > 0 then
			highestRewardIndex = index

			break
		end
	end

	if not highestRewardIndex then
		return {}
	end

	local randomRewardTypes = {}
	local lastRewardIndex = math.min(highestRewardIndex + 2, #sandBoxRewardOrder)

	for index = highestRewardIndex, lastRewardIndex do
		table.insert(randomRewardTypes, sandBoxRewardOrder[index])
	end

	local priorityRooms = {}

	for _, roomInsId in ipairs(roomList or EMPTY_TABLE) do
		if priorityRoomMap[roomInsId] then
			table.insert(priorityRooms, roomInsId)
		end
	end

	local randomPriorityRooms = RandomMapBatchUtils.weightedRandomSample(priorityRooms, weightMap, #priorityRooms)
	local deployedRooms = {}

	for _, roomInsId in ipairs(randomPriorityRooms) do
		local rewardByLevel = roomInstToSandboxMap[roomInsId] and roomInstToSandboxMap[roomInsId][sandBoxConfigType.Reward]
		local placeableRewardTypes = {}

		for _, rewardType in ipairs(randomRewardTypes) do
			local rewardLevel = sandBoxRewardEnum[rewardType]
			local rewards = rewardByLevel and rewardByLevel[rewardLevel]

			if (rewardRemainNums[rewardType] or 0) > 0 and rewards and #rewards > 0 then
				table.insert(placeableRewardTypes, rewardType)
			end
		end

		local rewardType = RandomMapBatchUtils.randomOne(placeableRewardTypes)

		if rewardType then
			local rewardLevel = sandBoxRewardEnum[rewardType]

			RandomMapBatchUtils.deploy(resRoomSandBoxMap, roomInsId, roomInstToSandboxMap, rewardLevel)

			rewardRemainNums[rewardType] = rewardRemainNums[rewardType] - 1

			table.insert(deployedRooms, roomInsId)
		end
	end

	return deployedRooms
end

function RandomMapBatchUtils.filterSandbox(roomDataMap, srcSandboxData, hardLv, copyHandler)
	local roomTypeInstMap = {}
	local roomInstToSandboxMap = {}
	local resRoomSandBoxMap = {}
	local priorityRewardRoomMap = {}

	for roomInstId, rData in pairs(roomDataMap) do
		local roomType = rData.roomType

		if not roomTypeInstMap[roomType] then
			roomTypeInstMap[roomType] = {}
		end

		table.insert(roomTypeInstMap[roomType], roomInstId)

		if roomType == RandomMapConst.ROOM_TYPE.Normal and isSpecialRewardRoom(rData) then
			priorityRewardRoomMap[roomInstId] = true
		end

		if not roomInstToSandboxMap[roomInstId] then
			roomInstToSandboxMap[roomInstId] = {}
		end

		local sandboxIds = rData.sandboxIds or {}

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local boxConfigType = sadData.sandBoxConfigType

			if boxConfigType == 0 or boxConfigType == sandBoxConfigType.Refresh or boxConfigType == nil then
				if not roomInstToSandboxMap[roomInstId].other then
					roomInstToSandboxMap[roomInstId].other = {}
				end

				table.insert(roomInstToSandboxMap[roomInstId].other, sandboxId)
			else
				if not roomInstToSandboxMap[roomInstId][boxConfigType] then
					roomInstToSandboxMap[roomInstId][boxConfigType] = {}
				end

				local sandBoxLevel = sadData.sandBoxLevel

				if not roomInstToSandboxMap[roomInstId][boxConfigType][sandBoxLevel] then
					roomInstToSandboxMap[roomInstId][boxConfigType][sandBoxLevel] = {}
				end

				table.insert(roomInstToSandboxMap[roomInstId][boxConfigType][sandBoxLevel], sandboxId)
			end
		end
	end

	local eggNestRoomlist = roomTypeInstMap[RandomMapConst.ROOM_TYPE.EggNest]

	if eggNestRoomlist and #eggNestRoomlist > 0 then
		if not roomTypeInstMap[RandomMapConst.ROOM_TYPE.Normal] then
			roomTypeInstMap[RandomMapConst.ROOM_TYPE.Normal] = {}
		end

		for _, roomId in ipairs(eggNestRoomlist) do
			table.insert(roomTypeInstMap[RandomMapConst.ROOM_TYPE.Normal], roomId)
		end

		roomTypeInstMap[RandomMapConst.ROOM_TYPE.EggNest] = nil
	end

	local rewardNumsInfo = RandomMapBatchUtils.getRewardBoxInfoByHardLv(hardLv, copyHandler)
	local weightMap = {}

	for roomType, _ in pairs(rewardNumsInfo) do
		local roomlist = roomTypeInstMap[roomType]

		if roomlist and #roomlist > 0 then
			for _, roomId in pairs(roomlist) do
				weightMap[roomId] = roomDataMap[roomId].depth or 0
			end
		end
	end

	local normalRoomInfo = rewardNumsInfo[RandomMapConst.ROOM_TYPE.Normal] or {}
	local normalRoomlist = roomTypeInstMap[RandomMapConst.ROOM_TYPE.Normal] or {}
	local eggCandidateRooms = {}

	for _, roomInsId in ipairs(normalRoomlist) do
		local eggNestByLevel = roomInstToSandboxMap[roomInsId] and roomInstToSandboxMap[roomInsId][sandBoxConfigType.EggNest]
		local eggNest = eggNestByLevel and eggNestByLevel[hardLv]

		if eggNest and #eggNest > 0 then
			table.insert(eggCandidateRooms, roomInsId)
		end
	end

	local eggCount = normalRoomInfo.EggCount or 0
	local minEggNest = math.min(eggCount, #eggCandidateRooms)
	local eggPlacedRooms = RandomMapBatchUtils.weightedRandomSample(eggCandidateRooms, weightMap, minEggNest)
	local eggProbability = normalRoomInfo.EggProbability or 0

	if eggProbability > 0 then
		local remainNestRoomList = RandomMapBatchUtils.listDifference(eggCandidateRooms, eggPlacedRooms)

		for _, roomInsId in ipairs(remainNestRoomList) do
			if eggProbability > math.random() then
				table.insert(eggPlacedRooms, roomInsId)
			end
		end
	end

	for _, roomInsId in ipairs(eggPlacedRooms) do
		local eggNestByLevel = roomInstToSandboxMap[roomInsId][sandBoxConfigType.EggNest]
		local eggNest = eggNestByLevel and eggNestByLevel[hardLv]

		if eggNest and #eggNest > 0 then
			if not resRoomSandBoxMap[roomInsId] then
				resRoomSandBoxMap[roomInsId] = {}
			end

			table.insert(resRoomSandBoxMap[roomInsId], eggNest[1])
		end
	end

	for roomType, rewardDetails in pairs(rewardNumsInfo) do
		local roomlist = roomTypeInstMap[roomType]

		if roomlist and #roomlist > 0 then
			local minNum = rewardDetails["G-All"] or 0
			local baoReward = rewardDetails["G-sup"] or {}
			local curRewardNum = 0
			local copyRoomList = copyHandler(roomlist)
			local rewardWeightMap = roomType == RandomMapConst.ROOM_TYPE.Aisle and {} or weightMap
			local rewardPriorityMap = roomType == RandomMapConst.ROOM_TYPE.Normal and priorityRewardRoomMap or nil
			local rewardRemainNums = {}

			for _, rewardType in ipairs(sandBoxRewardOrder) do
				rewardRemainNums[rewardType] = math.max(math.floor(tonumber(rewardDetails[rewardType]) or 0), 0)
			end

			local priorityDeployedRooms = deployRandomPriorityRewards(copyRoomList, rewardPriorityMap, roomInstToSandboxMap, rewardRemainNums, rewardWeightMap, resRoomSandBoxMap)

			copyRoomList = RandomMapBatchUtils.listDifference(copyRoomList, priorityDeployedRooms)
			curRewardNum = curRewardNum + #priorityDeployedRooms

			for _, rewardType in ipairs(sandBoxRewardOrder) do
				local rewardLevel = sandBoxRewardEnum[rewardType]
				local rewardtempNums = rewardRemainNums[rewardType]
				local eligibleRooms = RandomMapBatchUtils.filterRoomsWithReward(copyRoomList, roomInstToSandboxMap, rewardLevel)
				local tempRoomList = weightedRandomSampleRewardRooms(eligibleRooms, rewardPriorityMap, rewardWeightMap, rewardtempNums)

				copyRoomList = RandomMapBatchUtils.listDifference(copyRoomList, tempRoomList)

				if #tempRoomList > 0 then
					curRewardNum = curRewardNum + #tempRoomList

					for _, roomInsId in pairs(tempRoomList) do
						RandomMapBatchUtils.deploy(resRoomSandBoxMap, roomInsId, roomInstToSandboxMap, rewardLevel)
					end
				end
			end

			if curRewardNum < minNum and #baoReward > 0 then
				local needfill = minNum - curRewardNum
				local fillCandidates = {}

				for _, roomInsId in ipairs(copyRoomList) do
					local rewardByLevel = roomInstToSandboxMap[roomInsId] and roomInstToSandboxMap[roomInsId][sandBoxConfigType.Reward]
					local placeable = {}

					for _, rewardType in ipairs(baoReward) do
						local rewardLevel = sandBoxRewardEnum[rewardType]

						if rewardLevel then
							local rewards = rewardByLevel and rewardByLevel[rewardLevel]

							if rewards and #rewards > 0 then
								table.insert(placeable, rewardLevel)
							end
						end
					end

					if #placeable > 0 then
						fillCandidates[roomInsId] = placeable
					end
				end

				local eligibleRooms = {}

				for roomInsId, _ in pairs(fillCandidates) do
					table.insert(eligibleRooms, roomInsId)
				end

				local needfillRoomList = weightedRandomSampleRewardRooms(eligibleRooms, rewardPriorityMap, rewardWeightMap, needfill)

				for _, roomInsId in pairs(needfillRoomList) do
					local rewardLevel = RandomMapBatchUtils.randomOne(fillCandidates[roomInsId])

					RandomMapBatchUtils.deploy(resRoomSandBoxMap, roomInsId, roomInstToSandboxMap, rewardLevel)
				end
			end
		end
	end

	local lightMap = RandomMapBatchUtils.getLightSourceInfoByHardLv(hardLv, copyHandler)

	for roomInstId, _ in pairs(roomDataMap) do
		if roomInstToSandboxMap[roomInstId] then
			local weight = math.min(roomDataMap[roomInstId].depth or 0, 1)
			local lightList = {
				sandBoxLightSourceEnum.L0,
				sandBoxLightSourceEnum.L1,
				sandBoxLightSourceEnum.L2
			}
			local weightTemp = {
				lightMap.L0,
				lightMap.L1,
				lightMap.L2
			}
			local weightList = RandomMapBatchUtils.adjustAndNormalize(weightTemp, weight)
			local weightfinal = {}

			for l_index, l_id in pairs(lightList) do
				weightfinal[l_id] = weightList[l_index] or 0
			end

			local lightLevel = RandomMapBatchUtils.weightedRandomSample(lightList, weightfinal, 1)

			if roomInstToSandboxMap[roomInstId][sandBoxConfigType.LightSource] then
				local light = roomInstToSandboxMap[roomInstId][sandBoxConfigType.LightSource][lightLevel[1]]

				if light and #light > 0 then
					if not resRoomSandBoxMap[roomInstId] then
						resRoomSandBoxMap[roomInstId] = {}
					end

					table.insert(resRoomSandBoxMap[roomInstId], light[1])
				end
			end
		end
	end

	for roomInstId, sandboxData in pairs(roomInstToSandboxMap) do
		if sandboxData.other then
			if not resRoomSandBoxMap[roomInstId] then
				resRoomSandBoxMap[roomInstId] = {}
			end

			for _, sandboxId in ipairs(sandboxData.other) do
				table.insert(resRoomSandBoxMap[roomInstId], sandboxId)
			end
		end
	end

	return resRoomSandBoxMap
end

function RandomMapBatchUtils.getRefreshSandboxesByMonsterLevels(spaceId, monsterLevels, sourceSandboxId)
	local result = {}
	local cacheScene = RandomMapBatchUtils._CacheData[spaceId]

	if not cacheScene then
		return result
	end

	local sandboxData = cacheScene[SceneDataConst.scene_sandbox_data] or {}
	local sourceRoomInstanceId

	if sourceSandboxId then
		local sourceSandboxData = sandboxData[sourceSandboxId]

		if not sourceSandboxData then
			return result
		end

		sourceRoomInstanceId = sourceSandboxData.roomInstanceId

		if sourceRoomInstanceId == nil then
			return result
		end
	end

	local refreshByLevel = cacheScene.refreshSandboxesByLevel

	if not refreshByLevel then
		return result
	end

	for _, level in ipairs(monsterLevels or EMPTY_TABLE) do
		local bucket = refreshByLevel[level]

		if bucket then
			for _, sandboxId in ipairs(bucket) do
				local data = sandboxData[sandboxId]

				if not sourceRoomInstanceId or data and data.roomInstanceId == sourceRoomInstanceId then
					table.insert(result, sandboxId)
				end
			end
		end
	end

	return result
end

function RandomMapBatchUtils.getRewardBoxInfoByHardLv(hardLv, copyHandler)
	local res = {}

	if hardLv <= hardLvMap.Normal then
		res = {
			[RandomMapConst.ROOM_TYPE.Aisle] = copyHandler(DigongRwardData["Normal-hallway"]),
			[RandomMapConst.ROOM_TYPE.Normal] = copyHandler(DigongRwardData["Normal-room"])
		}
	elseif hardLv == hardLvMap.Hard then
		res = {
			[RandomMapConst.ROOM_TYPE.Aisle] = copyHandler(DigongRwardData["Hard-hallway"]),
			[RandomMapConst.ROOM_TYPE.Normal] = copyHandler(DigongRwardData["Hard-room"])
		}
	elseif hardLv == hardLvMap.Chaos then
		res = {
			[RandomMapConst.ROOM_TYPE.Aisle] = copyHandler(DigongRwardData["Chaos-hallway"]),
			[RandomMapConst.ROOM_TYPE.Normal] = copyHandler(DigongRwardData["Chaos-room"])
		}
	else
		res = {
			[RandomMapConst.ROOM_TYPE.Aisle] = copyHandler(DigongRwardData["Nightmare-hallway"]),
			[RandomMapConst.ROOM_TYPE.Normal] = copyHandler(DigongRwardData["Nightmare-room"])
		}
	end

	local rewardKeys = {
		"G0",
		"G1",
		"G2",
		"G3",
		"G4",
		"G5",
		"G6"
	}

	for _, roomData in pairs(res) do
		if type(roomData) == "table" then
			for _, key in ipairs(rewardKeys) do
				local val = roomData[key]

				if type(val) == "table" then
					roomData[key] = #val > 0 and val[math.random(#val)] or 0
				end

				roomData[key] = tonumber(roomData[key]) or 0
			end
		end
	end

	return res
end

function RandomMapBatchUtils.getLightSourceInfoByHardLv(hardLv, copyHandler)
	local res = {}

	if hardLv <= hardLvMap.Normal then
		res = copyHandler(DigongLightSourceData.Normal)
	elseif hardLv == hardLvMap.Hard then
		res = copyHandler(DigongLightSourceData.Hard)
	elseif hardLv == hardLvMap.Chaos then
		res = copyHandler(DigongLightSourceData.Chaos)
	else
		res = copyHandler(DigongLightSourceData.Nightmare)
	end

	return res
end

function RandomMapBatchUtils.adjustAndNormalize(weights, a)
	local temp = {}
	local len = #weights
	local sum = 0

	for i = 1, len do
		temp[i] = weights[i]^(a * (i / len))
		sum = sum + temp[i]
	end

	local normalized = {}

	for i = 1, len do
		normalized[i] = temp[i] / sum
	end

	return normalized
end

function RandomMapBatchUtils.deploy(resRoomSandBoxMap, roomInsId, roomInstToSandboxMap, rewardLevel)
	if not resRoomSandBoxMap[roomInsId] then
		resRoomSandBoxMap[roomInsId] = {}
	end

	if roomInstToSandboxMap[roomInsId][sandBoxConfigType.Reward] then
		local tmpReward = roomInstToSandboxMap[roomInsId][sandBoxConfigType.Reward][rewardLevel]

		if tmpReward and #tmpReward > 0 then
			table.insert(resRoomSandBoxMap[roomInsId], tmpReward[1])
		end
	end

	local difficulty = RandomMapBatchUtils.randomOne(RewardToDifficulty[rewardLevel])
	local TrapAndMonster = difficulty and RandomMapBatchUtils.randomOne(DifficultyToTrapAndMonster[difficulty])

	if not TrapAndMonster then
		return difficulty
	end

	local monsterType = TrapAndMonster[1]

	if roomInstToSandboxMap[roomInsId][sandBoxConfigType.Monster] then
		local tempMonster = roomInstToSandboxMap[roomInsId][sandBoxConfigType.Monster][monsterType]

		if tempMonster and #tempMonster > 0 then
			table.insert(resRoomSandBoxMap[roomInsId], tempMonster[1])
		end
	end

	local trapType = TrapAndMonster[2]

	if roomInstToSandboxMap[roomInsId][sandBoxConfigType.Trap] then
		local tempTrap = roomInstToSandboxMap[roomInsId][sandBoxConfigType.Trap][trapType]

		if tempTrap and #tempTrap > 0 then
			table.insert(resRoomSandBoxMap[roomInsId], tempTrap[1])
		end
	end

	return difficulty
end

function RandomMapBatchUtils.randomOne(list)
	if not list or type(list) ~= "table" or #list == 0 then
		return nil
	end

	local index = math.random(#list)

	return list[index]
end

function RandomMapBatchUtils.listDifference(list1, list2)
	if type(list1) ~= "table" or #list1 == 0 then
		return {}
	end

	if type(list2) ~= "table" or #list2 == 0 then
		local copy = {}

		for _, v in ipairs(list1) do
			table.insert(copy, v)
		end

		return copy
	end

	local excludeSet = {}

	for _, v in ipairs(list2) do
		excludeSet[v] = true
	end

	local result = {}

	for _, item in ipairs(list1) do
		if not excludeSet[item] then
			table.insert(result, item)
		end
	end

	return result
end

function RandomMapBatchUtils.weightedRandomSample(list, weightMap, count)
	if type(list) ~= "table" or #list == 0 then
		return {}
	end

	if type(weightMap) ~= "table" then
		return {}
	end

	count = math.floor(tonumber(count) or 0)

	local maxCount = math.min(count, #list)

	if maxCount <= 0 then
		return {}
	end

	local candidates = {}

	for i, v in ipairs(list) do
		table.insert(candidates, v)
	end

	local result = {}

	for _ = 1, maxCount do
		local totalWeight = 0
		local validItems = {}

		for _, item in ipairs(candidates) do
			local w = weightMap[item] or 1

			w = tonumber(w) or 1
			w = math.max(w, 0.0001)
			totalWeight = totalWeight + w

			table.insert(validItems, {
				item = item,
				weight = w
			})
		end

		local randomVal = math.random() * totalWeight
		local selectedItem, selectedIndex
		local cumulativeWeight = 0

		for idx, data in ipairs(validItems) do
			cumulativeWeight = cumulativeWeight + data.weight

			if randomVal <= cumulativeWeight then
				selectedItem = data.item
				selectedIndex = idx

				break
			end
		end

		table.insert(result, selectedItem)
		table.remove(candidates, selectedIndex)
	end

	return result
end

function RandomMapBatchUtils.batchSceneDataFull_Mark(sceneId, newId, newSandboxId, offset, cosA, sinA, copyData, srcMarkPointData, resMarkPointData, resMarkData, resMarkTypeData, copyHandler, roomInstId)
	local markCfg = copyData.markConfig
	local markId = markCfg and markCfg.markContent1

	if ToBool(markId) then
		local newMarkId = RandomMapBatchUtils.queryMarkId(roomInstId, markId)

		markCfg.markContent1 = newMarkId

		local srcMark = srcMarkPointData[markId]

		if srcMark then
			local rawData = copyHandler(srcMark)

			RandomMapBatchUtils.calculateNewPositionV2(rawData.markPosition, offset, cosA, sinA)

			if rawData.ownerInfo then
				rawData.ownerInfo[2] = newMarkId
			end

			rawData.sandboxId = newSandboxId
			rawData.realSceneId = sceneId

			if markCfg.openMapState ~= nil then
				rawData.openMapState = markCfg.openMapState
			end

			if markCfg.initState ~= nil then
				rawData.initState = markCfg.initState
			end

			if markCfg.nearState ~= nil then
				rawData.activeState = markCfg.nearState
			end

			applyProximityMapMarkConfig(rawData)

			resMarkPointData[newMarkId] = rawData

			local markType = srcMark.markType

			if not ToBool(resMarkData[markType]) then
				resMarkData[markType] = {}
			end

			resMarkData[markType][newMarkId] = rawData

			if not ToBool(resMarkTypeData[markType]) then
				resMarkTypeData[markType] = {}
			end

			table.insert(resMarkTypeData[markType], newMarkId)
		end
	end
end

function RandomMapBatchUtils.batchSceneSandboxData(roomDataMap, copyHandler, spaceId)
	local resSandboxData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}
		local offset = rData.position or {
			0,
			0,
			0
		}
		local yaw = rData.yaw or WAY_POINT_DEFAULTS.yaw or 0

		for _, sandboxId in ipairs(sandboxIds) do
			local newSandboxId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxId, spaceId)
			local sadData = srcSandboxData[sandboxId] or {}
			local copySandboxData = copyHandler(sadData)

			copySandboxData.id = newSandboxId
			copySandboxData.roomInstanceId = roomInstId
			copySandboxData._offset = offset
			copySandboxData._yaw = yaw

			local spawnerIds = sadData.spawners or {}

			table.clear(copySandboxData.spawners)

			for _, spawnerId in ipairs(spawnerIds) do
				local newSpawnerId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, spawnerId, spaceId)

				table.insert(copySandboxData.spawners, newSpawnerId)
			end

			copySandboxData.graphId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sadData.graphId, spaceId)

			local routeIds = sadData.routes or {}
			local cpRouteIds = copySandboxData.routes or {}

			table.clear(cpRouteIds)

			for _, routeId in ipairs(routeIds) do
				cpRouteIds[#cpRouteIds + 1] = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, routeId, spaceId)
			end

			RandomMapBatchUtils.calculateNewPosition(copySandboxData.position, offset, yaw)

			local levelItems = sadData.levelItems or {}
			local cpLevelItems = copySandboxData.levelItems or {}

			table.clear(cpLevelItems)

			for lItemId, levelItem in pairs(levelItems) do
				local newLItemId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, lItemId, spaceId)
				local cpItemData = copyHandler(levelItem)

				cpItemData.id = newLItemId

				RandomMapBatchUtils.calculateNewPosition(cpItemData.position, offset, yaw)

				local cmpItems = cpItemData.componentsInfo or {}

				for _, cmpItem in pairs(cmpItems) do
					RandomMapBatchUtils.calculateNewPosition(cmpItem.initPosition, offset, yaw)
				end

				cpLevelItems[newLItemId] = cpItemData
			end

			resSandboxData[newSandboxId] = copySandboxData
		end
	end

	return resSandboxData
end

function RandomMapBatchUtils.batchSceneSandboxAdditionData(sceneSandboxData)
	local resSandboxInitData = {}
	local resSandboxFarawayData = {}
	local resSandboxGlobalData = {}

	for sandboxId, sandboxData in pairs(sceneSandboxData) do
		if sandboxData.activeOnInit == SandboxConst.ACTIVE_TYPE.INIT then
			resSandboxInitData[sandboxId] = true
		end

		if sandboxData.sightLevel == SandboxConst.SIGHT_LEVEL.GLOBAL then
			resSandboxGlobalData[sandboxId] = true
		end

		if sandboxData.sightLevel == SandboxConst.SIGHT_LEVEL.FARAWAY then
			resSandboxFarawayData[sandboxId] = true
		end
	end

	return resSandboxInitData, resSandboxGlobalData, resSandboxFarawayData
end

function RandomMapBatchUtils.batchSceneSpawnerData(roomDataMap, copyHandler, spaceId)
	local resSpawnerData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcSpawnerData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_spawner_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}
		local offset = rData.position or {
			0,
			0,
			0
		}
		local yaw = rData.yaw or 0

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local spawnerIds = sadData.spawners or {}

			for _, spawnerId in ipairs(spawnerIds) do
				local newSpawnerId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, spawnerId, spaceId)
				local spaData = srcSpawnerData[spawnerId] or {}
				local rawData = copyHandler(spaData)

				rawData.id = newSpawnerId
				rawData.sandboxId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxId, spaceId)
				rawData._offset = offset
				rawData._yaw = yaw

				local entityGroups = rawData.spawnGroups or {}

				for _, group in ipairs(entityGroups) do
					local entityIds = group.spawnIds or {}
					local num = #entityIds

					for i = num, 1, -1 do
						local newEntityId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, entityIds[i], spaceId)

						table.remove(entityIds, i)
						table.insert(entityIds, i, newEntityId)
					end
				end

				RandomMapBatchUtils.calculateNewPosition(rawData.position, offset, yaw)

				resSpawnerData[newSpawnerId] = rawData
			end
		end
	end

	return resSpawnerData
end

function RandomMapBatchUtils.batchSceneAreaData(roomDataMap, copyHandler, spaceId)
	local resAreaData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcAreaData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_area_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}
		local offset = rData.position
		local yaw = rData.yaw or 0
		local angleRad = yaw * pi / 180
		local cosA = cos(angleRad)
		local sinA = sin(angleRad)

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local areaIds = sadData.areaIds or {}

			for _, spawnerId in ipairs(areaIds) do
				local newAreaId = RandomMapBatchUtils.queryOrRecorderNewAreaId(roomInstId, spawnerId, spaceId)
				local areaData = srcAreaData[spawnerId] or {}
				local rawData = copyHandler(areaData)

				rawData.id = newAreaId
				rawData.sandboxId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxId, spaceId)

				RandomMapBatchUtils.calculateNewPosition(rawData.position, offset, yaw)
				RandomMapBatchUtils.offsetAreaPoints(rawData.areaPoints, offset, cosA, sinA)

				resAreaData[newAreaId] = rawData
			end
		end
	end

	return resAreaData
end

function RandomMapBatchUtils.batchSceneGlobalAreaData(sceneAreaData)
	local resGlobalAreaData = {}

	for areaId, areaData in pairs(sceneAreaData) do
		if areaData.areaLoadType == Const.AREA_LOAD_TYPE.SCENE_LOAD then
			resGlobalAreaData[areaId] = areaData
		end
	end

	return resGlobalAreaData
end

function RandomMapBatchUtils.batchSceneGraphData(roomDataMap, copyHandler, spaceId)
	local resGraphData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcGraphData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_graph_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local graphId = sadData.graphId
			local newGraphId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, graphId, spaceId)

			if ToBool(newGraphId) then
				local graData = srcGraphData[graphId] or {}
				local rawData = copyHandler(graData)

				rawData.graphId = newGraphId

				local nodes = rawData.nodes or {}

				for _, node in pairs(nodes) do
					local _inputPortValues = node._inputPortValues or {}

					_inputPortValues.SpawnerId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, _inputPortValues.SpawnerId, spaceId)
					_inputPortValues.staticId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, _inputPortValues.staticId, spaceId)
					_inputPortValues.StaticId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, _inputPortValues.StaticId, spaceId)
					_inputPortValues.LevelItemId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, _inputPortValues.LevelItemId, spaceId)

					local staticId = node.staticId

					node.staticId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, staticId, spaceId)
				end

				resGraphData[newGraphId] = rawData
			end
		end
	end

	return resGraphData
end

function RandomMapBatchUtils.batchSceneEntityData(roomDataMap, copyHandler, spaceId)
	local resEntityData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcSpawnerData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_spawner_data, nil, spaceId)
	local srcEntityData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_entity_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}
		local offset = rData.position
		local yaw = rData.yaw or 0

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local spawnerIds = sadData.spawners or {}

			for _, spawnerId in ipairs(spawnerIds) do
				local spaData = srcSpawnerData[spawnerId] or {}
				local entityGroups = spaData.spawnGroups or {}

				for _, entityData in ipairs(entityGroups) do
					local entityIds = entityData.spawnIds

					for _, entityId in ipairs(entityIds) do
						local srcEntity = srcEntityData[entityId] or {}
						local newEntityId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, entityId, spaceId)
						local rawData = copyHandler(srcEntity)

						rawData.staticId = newEntityId
						rawData._offset = offset
						rawData._yaw = yaw
						rawData.routeId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, srcEntity.routeId, spaceId)

						local routeRefs = rawData.routeRefs or {}
						local num = #routeRefs

						for i = num, 1, -1 do
							local routeId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, routeRefs[i], spaceId)

							table.remove(routeRefs, i)
							table.insert(routeRefs, i, routeId)
						end

						rawData.sandboxId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxId, spaceId)
						rawData.spawnerId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, spawnerId, spaceId)

						RandomMapBatchUtils.calculateNewPosition(rawData.position, offset, yaw)

						resEntityData[newEntityId] = rawData
					end
				end
			end
		end
	end

	return resEntityData
end

function RandomMapBatchUtils.batchSceneRouteData(roomDataMap, copyHandler, spaceId)
	local resRouteData = {}
	local srcSandboxData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_sandbox_data, nil, spaceId)
	local srcRouteData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_route_data, nil, spaceId)

	for roomInstId, rData in pairs(roomDataMap) do
		local sandboxIds = rData.sandboxIds or {}
		local offset = rData.position
		local yaw = rData.yaw or WAY_POINT_DEFAULTS.yaw or 0

		for _, sandboxId in ipairs(sandboxIds) do
			local sadData = srcSandboxData[sandboxId] or {}
			local routeIds = sadData.routes or {}

			for _, rId in ipairs(routeIds) do
				local srcRoute = srcRouteData[rId] or {}
				local rawData = copyHandler(srcRoute)
				local newRouteId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, rId, spaceId)

				rawData.id = newRouteId
				rawData.sandboxId = RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxId, spaceId)

				RandomMapBatchUtils.calculateNewPosition(rawData.pos, offset, yaw)

				local wayPoints = rawData.wayPoints or {}

				for _, point in ipairs(wayPoints) do
					RandomMapBatchUtils.calculateNewPosition(point.position, offset, yaw)
				end

				resRouteData[newRouteId] = rawData
			end
		end
	end

	return resRouteData
end

function RandomMapBatchUtils.batchSceneMarkData(collectMap, copyHandler, spaceId)
	local resMarkData = {}
	local resMarkPointData = {}
	local resMarkTypeData = {}
	local srcMarkPointData = RandomMapBatchUtils.getSceneData(SceneDataConst.scene_mark_point_data, nil, spaceId)

	for _, map in ipairs(collectMap) do
		for id, item in pairs(map) do
			local markCfg = item.markConfig
			local markId = markCfg and markCfg.markContent1 or 0

			if ToBool(markId) then
				markCfg.markContent1 = id

				local srcMark = srcMarkPointData[markId]

				if srcMark then
					local rawData = copyHandler(srcMark)

					RandomMapBatchUtils.calculateNewPosition(rawData.markPosition, item._offset, item._yaw)

					if rawData.ownerInfo then
						rawData.ownerInfo[2] = id
					end

					applyProximityMapMarkConfig(rawData)

					resMarkPointData[id] = rawData

					local markType = srcMark.markType or 0

					if not ToBool(resMarkData[markType]) then
						resMarkData[markType] = {}
					end

					resMarkData[markType][id] = rawData

					if not ToBool(resMarkTypeData[markType]) then
						resMarkTypeData[markType] = {}
					end

					table.insert(resMarkTypeData[markType], id)
				end
			end
		end
	end

	return resMarkData, resMarkPointData, resMarkTypeData
end

function RandomMapBatchUtils.batchPostGenerateData(sceneId, copyHandler, spaceId)
	local cacheScene = RandomMapBatchUtils._CacheData[spaceId]

	if not cacheScene then
		return
	end

	local markPointData = cacheScene[SceneDataConst.scene_mark_point_data]
	local map_mark_id_to_config_id = copyHandler(MapMarkIdToConfigId)
	local InitCacheData

	if pg.component == "game" then
		InitCacheData = require("Data.init_cache_data")
	else
		InitCacheData = {}
	end

	local init_cache_data = copyHandler(InitCacheData)
	local mapMark = init_cache_data.mapMark or {}

	init_cache_data.mapMark = mapMark

	for staticId, v in pairs(markPointData) do
		map_mark_id_to_config_id[staticId] = v.markConfigId

		local markType = v.markType or 0
		local status = v.openMapState or Const.MAP_MARK_STATUS_HIDE

		mapMark[sceneId] = mapMark[sceneId] or {}
		mapMark[sceneId][markType] = mapMark[sceneId][markType] or {}
		mapMark[sceneId][markType][staticId] = mapMark[sceneId][markType][staticId] or Const.MAP_MARK_STATUS_HIDE
		mapMark[sceneId][markType][staticId] = status
	end

	cacheScene[SceneDataConst.map_mark_id_to_config_id] = map_mark_id_to_config_id
	cacheScene[SceneDataConst.init_cache_data] = init_cache_data
end

function RandomMapBatchUtils.calculateNewPosition(position, offset, angle)
	if not ToBool(position) or not ToBool(offset) then
		return
	end

	if #position < 3 or #offset < 3 then
		return
	end

	angle = angle or 0

	local angleRad = angle * pi / 180
	local cosA = cos(angleRad)
	local sinA = sin(angleRad)
	local x, z = position[1], position[3]

	position[1] = x * cosA + z * sinA + offset[1]
	position[2] = position[2] + offset[2]
	position[3] = -x * sinA + z * cosA + offset[3]
end

function RandomMapBatchUtils.calculateNewPositionV2(position, offset, cosA, sinA)
	if not ToBool(position) or not ToBool(offset) then
		return
	end

	if #position < 3 or #offset < 3 then
		return
	end

	local x, z = position[1], position[3]

	position[1] = x * cosA + z * sinA + offset[1]
	position[2] = position[2] + offset[2]
	position[3] = -x * sinA + z * cosA + offset[3]
end

function RandomMapBatchUtils.offsetAreaPoints(areaPoints, offset, cosA, sinA)
	if not ToBool(areaPoints) or not ToBool(offset) then
		return
	end

	if #offset < 3 then
		return
	end

	local n = #areaPoints

	for i = 1, n - 1, 2 do
		local x, z = areaPoints[i], areaPoints[i + 1]

		areaPoints[i] = x * cosA + z * sinA + offset[1]
		areaPoints[i + 1] = -x * sinA + z * cosA + offset[3]
	end
end

function RandomMapBatchUtils.combineYaw(data, key, deltaYaw)
	if not data or not deltaYaw or deltaYaw == 0 then
		return
	end

	data[key] = ((data[key] or 0) + deltaYaw) % 360
end

function RandomMapBatchUtils.combineEulerYaw(rotation, deltaYaw)
	if not rotation or #rotation < 3 or not deltaYaw or deltaYaw == 0 then
		return
	end

	rotation[2] = ((rotation[2] or 0) + deltaYaw) % 360
end

function RandomMapBatchUtils.combineQuatYaw(quat, halfCos, halfSin)
	if not quat or #quat < 4 then
		return
	end

	if halfSin == 0 then
		return
	end

	local lx, ly, lz, lw = quat[1], quat[2], quat[3], quat[4]

	quat[1] = halfCos * lx + halfSin * lz
	quat[2] = halfCos * ly + halfSin * lw
	quat[3] = -halfSin * lx + halfCos * lz
	quat[4] = -halfSin * ly + halfCos * lw
end

function RandomMapBatchUtils.queryOrRecorderNewId(roomInstId, sandboxOrSpawnerId, spaceId)
	if not ToBool(sandboxOrSpawnerId) then
		return sandboxOrSpawnerId
	end

	local spaceMap = RandomMapBatchUtils._IdMap[spaceId]

	if spaceMap == nil then
		spaceMap = {}
		RandomMapBatchUtils._IdMap[spaceId] = spaceMap
	end

	local roomMap = spaceMap[roomInstId]

	if roomMap == nil then
		roomMap = {}
		spaceMap[roomInstId] = roomMap
	end

	local cacheId = roomMap[sandboxOrSpawnerId]

	if cacheId then
		return cacheId
	end

	local newId = RandomMapBatchUtils.queryId(roomInstId, sandboxOrSpawnerId)

	roomMap[sandboxOrSpawnerId] = newId

	return newId
end

function RandomMapBatchUtils.queryId(roomInstId, sandboxOrSpawnerId)
	return sandboxOrSpawnerId % 2147483647 * 100 + roomInstId
end

function RandomMapBatchUtils.queryNewIdsByOrigin(spaceId, originId)
	local spaceMap = RandomMapBatchUtils._IdMap[spaceId]

	if spaceMap == nil or not ToBool(originId) then
		return nil
	end

	local result

	for _roomInstId, roomMap in pairs(spaceMap) do
		local newId = roomMap[originId]

		if newId ~= nil then
			result = result or {}
			result[#result + 1] = newId
		end
	end

	return result
end

function RandomMapBatchUtils.queryAreaId(roomInstId, areaId)
	return areaId % 21474835 * 100 + roomInstId
end

function RandomMapBatchUtils.queryMarkId(roomInstId, srcMarkId)
	return srcMarkId % 21474835 * 100 + roomInstId
end

function RandomMapBatchUtils.queryOrRecorderNewAreaId(roomInstId, areaId, spaceId)
	if not ToBool(areaId) then
		return areaId
	end

	local spaceMap = RandomMapBatchUtils._AreaIdMap[spaceId]

	if spaceMap == nil then
		spaceMap = {}
		RandomMapBatchUtils._AreaIdMap[spaceId] = spaceMap
	end

	local roomMap = spaceMap[roomInstId]

	if roomMap == nil then
		roomMap = {}
		spaceMap[roomInstId] = roomMap
	end

	local cacheId = roomMap[areaId]

	if cacheId then
		return cacheId
	end

	local newId = RandomMapBatchUtils.queryAreaId(roomInstId, areaId)

	roomMap[areaId] = newId

	return newId
end

return RandomMapBatchUtils
