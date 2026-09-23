-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\SceneUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SceneData = require("Data.scene_data")
local Vector3 = Vector3
local MapLineConfigData = require("Data.map_line_config_data")
local RoguelikeData = require("Data.roguelike_data")
local CatchRogueLevelData = require("Data.catch_rogue_level_data")
local SceneTargetPositionData = require("Common.Data.Scene.scene_target_position_data")
local SceneTargetPositionRevertData = require("Common.Data.Scene.scene_target_position_revert_data")
local BossRushGuankaData = require("Data.bossrush_guanka_data")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local SceneUtils = {}

function SceneUtils.getSceneName(fileResId)
	fileResId = fileResId or ""

	local paths = string.split(fileResId, "/")
	local fileName = paths[#paths]

	if string.sub(fileName, -6) == ".unity" then
		fileName = string.sub(fileName, 1, #fileName - 6)
	end

	if string.sub(fileName, 1, 1) == "$" then
		fileName = string.sub(fileName, 2)
	end

	return fileName
end

SceneUtils.dataPathPrefix = "Data.Scene.%s.%s"
SceneUtils.scene_entity_data = "scene_entity_data"
SceneUtils.scene_spawner_data = "scene_spawner_data"
SceneUtils.scene_titan_spawner_data = "scene_titan_spawner_data"
SceneUtils.scene_spawner_condition_data = "scene_spawner_condition_data"
SceneUtils.scene_spawner_immediately_condition = "scene_spawner_immediately_condition"
SceneUtils.scene_chunk_data = "scene_chunk_data"
SceneUtils.scene_route_data = "scene_route_data"
SceneUtils.scene_graph_data = "scene_graph_data"
SceneUtils.scene_sandbox_data = "scene_sandbox_data"
SceneUtils.scene_sandbox_global_data = "scene_sandbox_global_data"
SceneUtils.scene_sandbox_chunk_data = "scene_sandbox_chunk_data"
SceneUtils.quest_active_sandbox_data = "quest_active_sandbox_data"
SceneUtils.scene_sandbox_quest_data = "scene_sandbox_quest_data"
SceneUtils.scene_sandbox_dungeon_data = "scene_sandbox_dungeon_data"
SceneUtils.scene_sandbox_finished_data = "scene_sandbox_finished_data"
SceneUtils.scene_sandbox_destroy_data = "scene_sandbox_destroy_data"
SceneUtils.scene_sandbox_faraway_data = "scene_sandbox_faraway_data"
SceneUtils.scene_sandbox_weather_data = "scene_sandbox_weather_data"
SceneUtils.scene_sandbox_meteorology_data = "scene_sandbox_meteorology_data"
SceneUtils.stp_group_data = "stp_group_data"
SceneUtils.scene_mark_data = "scene_mark_data"
SceneUtils.scene_mark_type_data = "scene_mark_type_data"
SceneUtils.scene_mark_point_data = "scene_mark_point_data"
SceneUtils.scene_common_basics_point_data = "scene_common_basics_point_data"
SceneUtils.scene_portal_data = "scene_portal_data"
SceneUtils.scene_portal_group_data = "scene_portal_group_data"
SceneUtils.scene_area_data = "scene_area_data"
SceneUtils.scene_global_area_data = "scene_global_area_data"
SceneUtils.scene_poi_data = "scene_poi_data"
SceneUtils.scene_base_point_group_data = "scene_base_point_group_data"
SceneUtils.scene_dialogset_data = "scene_dialogset_data"
SceneUtils.scene_envobj_chunk_data = "scene_envobj_chunk_data"
SceneUtils.scene_climb_data = "scene_climb_data"
SceneUtils.scene_entity_block_id_data = "scene_entity_block_id_data"
SceneUtils.useDataCache = true
SceneUtils.dataPathPrefix_part = "Data.Scene.%s.%s.%s_%d"
SceneUtils.dataPathPrefix_part_len = "Data.Scene.%s.%s.%s_len"
SceneUtils.usePartData = false
SceneUtils.part_data_names = {
	SceneUtils.scene_route_data,
	SceneUtils.scene_entity_data
}

function SceneUtils.getSceneData(sceneId, dataName, spaceId)
	if RandomMapBatchUtils.isUndergroundScene(sceneId) and spaceId then
		return RandomMapBatchUtils.getSceneDataFromCache(sceneId, dataName, spaceId)
	end

	if SceneUtils.useDataCache then
		return SceneUtils.getSceneDataFromCache(sceneId, dataName)
	end

	local partDataFlag = false

	if SceneUtils.usePartData then
		for _, v in ipairs(SceneUtils.part_data_names) do
			if dataName == v then
				partDataFlag = true

				break
			end
		end
	end

	if partDataFlag then
		local sceneData = {}
		local sceneDataPathLen = string.format(SceneUtils.dataPathPrefix_part_len, sceneId, dataName, dataName)
		local statusLen, partLenTable = pcall(require, sceneDataPathLen)

		if not statusLen then
			partLenTable = {
				count = 0
			}
			package.loaded[sceneDataPathLen] = nil
		end

		for i = 1, partLenTable.count do
			local sceneDataPartPath = string.format(SceneUtils.dataPathPrefix_part, sceneId, dataName, dataName, i)
			local statusPart, partData = pcall(require, sceneDataPartPath)

			if not statusPart then
				partData = {}
			end

			for k, v in pairs(partData) do
				sceneData[k] = v
			end

			package.loaded[sceneDataPartPath] = nil
		end

		return sceneData
	else
		local sceneDataPath = string.format(SceneUtils.dataPathPrefix, sceneId, dataName)
		local status, sceneData = pcall(require, sceneDataPath)

		if not status then
			sceneData = {}
			package.loaded[sceneDataPath] = sceneData
		end

		return sceneData
	end
end

function SceneUtils.getSceneDataFromCache(sceneId, dataName)
	if SceneUtils._DataCache == nil then
		SceneUtils._DataCache = {}
	end

	local cache = SceneUtils._DataCache[sceneId]

	if cache == nil then
		cache = {}
		SceneUtils._DataCache[sceneId] = cache
	end

	if cache[dataName] == nil then
		local partDataFlag = false

		if SceneUtils.usePartData then
			for _, v in ipairs(SceneUtils.part_data_names) do
				if dataName == v then
					partDataFlag = true

					break
				end
			end
		end

		if partDataFlag then
			local sceneData = {}
			local sceneDataPathLen = string.format(SceneUtils.dataPathPrefix_part_len, sceneId, dataName, dataName)
			local statusLen, partLenTable = pcall(require, sceneDataPathLen)

			if not statusLen then
				partLenTable = {
					count = 0
				}
				package.loaded[sceneDataPathLen] = nil
			end

			for i = 1, partLenTable.count do
				local sceneDataPartPath = string.format(SceneUtils.dataPathPrefix_part, sceneId, dataName, dataName, i)
				local statusPart, partData = pcall(require, sceneDataPartPath)

				if not statusPart then
					partData = {}
				end

				for k, v in pairs(partData) do
					sceneData[k] = v
				end

				package.loaded[sceneDataPartPath] = nil
			end

			cache[dataName] = sceneData

			return sceneData
		else
			local sceneDataPath = string.format(SceneUtils.dataPathPrefix, sceneId, dataName)
			local status, sceneData = pcall(require, sceneDataPath)

			if not status then
				sceneData = {}
				package.loaded[sceneDataPath] = sceneData
			end

			cache[dataName] = sceneData

			return sceneData
		end
	end

	return cache[dataName]
end

function SceneUtils.clearCache()
	SceneUtils._DataCache = {}
end

function SceneUtils.unloadSceneDataCache(sceneId)
	if not SceneUtils.useDataCache then
		return
	end

	local cache = SceneUtils._DataCache[sceneId]

	for k, v in cache do
		local sceneDataPath = string.format(SceneUtils.dataPathPrefix, sceneId, k)

		cache[k] = nil
		package.loaded[sceneDataPath] = nil
	end
end

function SceneUtils.getSceneEntityData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_entity_data, spaceId)
end

function SceneUtils.getSceneSpawnerData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_spawner_data, spaceId)
end

function SceneUtils.getSceneChunkSpawnerData(sceneId, size, spaceId)
	local dataName = SceneUtils.scene_chunk_data

	if size then
		dataName = dataName .. "_" .. tostring(size)
	end

	return SceneUtils.getSceneData(sceneId, dataName, spaceId)
end

function SceneUtils.getSceneTitanSpawnerData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_titan_spawner_data, spaceId)
end

function SceneUtils.getSceneSpawnerConditionData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_spawner_condition_data, spaceId)
end

function SceneUtils.getSceneSpawnerImmediatelyConditionData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_spawner_immediately_condition, spaceId)
end

function SceneUtils.getSceneRouteData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_route_data, spaceId)
end

function SceneUtils.getSceneGraphData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_graph_data, spaceId)
end

function SceneUtils.getSceneSandboxData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_data, spaceId)
end

function SceneUtils.getSceneSandboxGlobalData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_global_data, spaceId)
end

function SceneUtils.getSceneSandboxIdData(sceneId, sandboxId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_data, spaceId)[sandboxId]
end

function SceneUtils.getSceneSandboxChunkData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_chunk_data, spaceId)
end

function SceneUtils.getSceneSandboxQuestData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_quest_data, spaceId)
end

function SceneUtils.getSceneSandboxQuestActiveData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.quest_active_sandbox_data, spaceId)
end

function SceneUtils.getSceneSandboxWeatherData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_weather_data, spaceId)
end

function SceneUtils.getSceneSandboxMeteorologyData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_meteorology_data, spaceId)
end

function SceneUtils.getSceneSandboxDungeonData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_dungeon_data, spaceId)
end

function SceneUtils.getSceneSandboxFinishedData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_finished_data, spaceId)
end

function SceneUtils.getSceneSandboxDestroyData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_destroy_data, spaceId)
end

function SceneUtils.getSceneSandboxFarawayData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_sandbox_faraway_data, spaceId)
end

function SceneUtils.getSceneStpGroupData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.stp_group_data, spaceId)
end

function SceneUtils.getSceneMarkData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_mark_data, spaceId)
end

function SceneUtils.getSceneMarkTypeData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_mark_type_data, spaceId)
end

function SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_mark_point_data, spaceId)
end

function SceneUtils.getMarkPosition(sceneId, pointId, spaceId)
	local smpdd = SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	local point = smpdd and smpdd[pointId]

	if point == nil then
		return nil, nil
	end

	return point.markPosition and Vector3.Clone(point.markPosition), point.yaw and Quaternion.Euler(0, point.yaw, 0)
end

function SceneUtils.getCommonBasicsPosition(sceneId, pointId, spaceId)
	local scbpdd = SceneUtils.getSceneCommonBasicsPointData(sceneId, spaceId)
	local point = scbpdd and scbpdd[pointId]

	if point == nil then
		return nil, nil
	end

	return point.position and Vector3.Clone(point.position), point.rotation and Quaternion.Euler(unpack(point.rotation))
end

function SceneUtils.getSceneCommonBasicsPointData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_common_basics_point_data, spaceId)
end

function SceneUtils.getScenePortalData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_portal_data, spaceId)
end

function SceneUtils.getScenePortalGroupData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_portal_group_data, spaceId)
end

function SceneUtils.getSceneAreaData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_area_data, spaceId)
end

function SceneUtils.getSceneGlobalAreaData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_global_area_data, spaceId)
end

function SceneUtils.getScenePOIData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_poi_data, spaceId)
end

function SceneUtils.getSceneBasePointGroupData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_base_point_group_data, spaceId)
end

function SceneUtils.getSceneDialogsetData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_dialogset_data, spaceId)
end

function SceneUtils.getMapMarkPositionById(sceneId, pointId, spaceId)
	local smdd = SceneUtils.getSceneMarkPointData(sceneId, spaceId)
	local mmdd = smdd and smdd[pointId]

	if mmdd and mmdd.markPosition then
		return Vector3(unpack(mmdd.markPosition))
	end

	return nil
end

function SceneUtils.getMapMarkPosition(mmdd)
	if mmdd and mmdd.markPosition then
		return Vector3(unpack(mmdd.markPosition))
	end

	return nil
end

function SceneUtils.getMainSceneId(sceneId)
	local sceneData = SceneData[sceneId]

	if sceneData and sceneData.mainScene then
		return sceneData.mainScene
	end

	return sceneId
end

function SceneUtils.isSeamlessScene(sceneId)
	local sceneData = SceneData[sceneId]

	if sceneData and sceneData.mainScene then
		return true
	end

	return false
end

function SceneUtils.haveSceneData(sceneId)
	local sceneData = SceneData[sceneId]

	if sceneData then
		return true
	end

	return false
end

function SceneUtils.getEnvIdByStaticId(staticId)
	return tostring(staticId)
end

function SceneUtils.getSceneEnvObjChunkData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_envobj_chunk_data, spaceId)
end

function SceneUtils.getKeepInstanceNum(sceneId)
	return MapLineConfigData[sceneId] and MapLineConfigData[sceneId].initInstanceNum
end

function SceneUtils.getMaxInstanceCapacity(sceneId)
	return MapLineConfigData[sceneId] and MapLineConfigData[sceneId].maxInstanceCapacity
end

function SceneUtils.getSceneTargetPositionData(sceneId)
	return SceneTargetPositionData[sceneId] and SceneTargetPositionData[sceneId]
end

function SceneUtils.getSceneTargetPositionRevertData(sceneId)
	return SceneTargetPositionRevertData[sceneId] and SceneTargetPositionRevertData[sceneId]
end

function SceneUtils.getVoxelPath(sceneConfig, space)
	local Utils = require("Common.Utils.Utils")
	local voxelPath = sceneConfig.voxelPath

	if not voxelPath then
		voxelPath = sceneConfig.file

		if string.sub(voxelPath, -7) == "_XBatch" then
			voxelPath = string.sub(voxelPath, 1, #voxelPath - 7)
		end

		if string.sub(voxelPath, 1, 7) == "Runtime" then
			voxelPath = string.sub(voxelPath, 8)
		end
	end

	if Utils.isSpaceRogueDungeon(space.spaceType) then
		local voxelLevel = (RoguelikeData[space.dungeonId] or EMPTY_TABLE).sceneLevelId or 0

		voxelPath = string.format("%s_Level%d", voxelPath, voxelLevel)
	elseif Utils.isSpaceBossRushDungeon(space.spaceType) then
		local voxelLevel = (BossRushGuankaData[space.dungeonId] or EMPTY_TABLE).levelId or "Level_Prepare"

		voxelPath = string.format("%s_%s", voxelPath, voxelLevel)
	end

	return voxelPath
end

function SceneUtils.getSceneClimbData(sceneId, spaceId)
	return SceneUtils.getSceneData(sceneId, SceneUtils.scene_climb_data, spaceId)
end

function SceneUtils.getBlockIdByEntity(entity)
	local entityStaticId = entity and entity.staticId
	local sceneId = entity.space and entity.space.sceneId

	if not entityStaticId or not sceneId then
		return 0
	end

	local spaceId = entity.space and entity.space.id
	local sceneEntityBlockIdData = SceneUtils.getSceneData(sceneId, SceneUtils.scene_entity_block_id_data, spaceId)

	return sceneEntityBlockIdData and sceneEntityBlockIdData[entityStaticId] or 0
end

return SceneUtils
