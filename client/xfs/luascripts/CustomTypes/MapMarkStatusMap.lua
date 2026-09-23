-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\MapMarkStatusMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local SceneSeamlessData = require("Data.scene_seamless_data")
local SceneData = require("Data.scene_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local MapOverlapScene = require("Data.map_overlap_scene")
local ToBool = ToBool
local IS_CLIENT = pg.component == "client"

local function findStatus(statusMap, sceneId, markType, staticId)
	local sceneInfo = statusMap[sceneId]
	local markInfo = sceneInfo and sceneInfo[markType]
	local status = markInfo and markInfo[staticId]

	if status then
		return status
	end

	local mainScene = SceneUtils.getMainSceneId(sceneId)
	local mainSceneData = SceneSeamlessData[mainScene]
	local seamlessGroup = mainSceneData and mainSceneData.seamlessGroup

	if seamlessGroup then
		for seamlessId, _ in pairs(seamlessGroup) do
			local seamlessInfo = statusMap[seamlessId]
			local seamlessMarkInfo = seamlessInfo and seamlessInfo[markType]
			local seamlessStatus = seamlessMarkInfo and seamlessMarkInfo[staticId]

			if seamlessStatus then
				return seamlessStatus
			end
		end
	end

	local rootScene = MapOverlapScene[sceneId] or sceneId
	local rootSceneData = SceneData[rootScene]
	local overlayScenes = rootSceneData and rootSceneData.mapDisplayOverlayScenes

	if overlayScenes then
		for _, childScene in pairs(overlayScenes) do
			local childInfo = statusMap[childScene]
			local childMarkInfo = childInfo and childInfo[markType]
			local childStatus = childMarkInfo and childMarkInfo[staticId]

			if childStatus then
				return childStatus
			end
		end
	end

	local rootInfo = statusMap[rootScene]
	local rootMarkInfo = rootInfo and rootInfo[markType]

	return rootMarkInfo and rootMarkInfo[staticId] or Const.MAP_MARK_STATUS_HIDE
end

local MapMarkStatusMap = class.LiteClass("MapMarkStatusMap", CustomDict)

if IS_CLIENT then
	local NORMAL_CACHE_KEY = {}
	local PARENT_CACHE_KEY = {}
	local CACHE_ID_KEY = {}
	local statusCacheOwners = setmetatable({}, {
		__mode = "kv"
	})

	local function getStatusValue(markStatusCache, staticId)
		local sceneCache = markStatusCache[PARENT_CACHE_KEY]
		local filterCache = sceneCache[PARENT_CACHE_KEY]
		local statusCache = filterCache[PARENT_CACHE_KEY]
		local statusMap = statusCacheOwners[statusCache]
		local filterKey = filterCache[CACHE_ID_KEY]
		local status = Const.MAP_MARK_STATUS_HIDE

		if filterKey == NORMAL_CACHE_KEY then
			status = findStatus(statusMap, sceneCache[CACHE_ID_KEY], markStatusCache[CACHE_ID_KEY], staticId)
		else
			local markConfig = Utils.getMarkConfigByMarkId(staticId, filterKey)

			if markConfig and ToBool(markConfig.multiplayerPoiType) then
				status = findStatus(statusMap, sceneCache[CACHE_ID_KEY], markStatusCache[CACHE_ID_KEY], staticId)
			end
		end

		markStatusCache[staticId] = status

		return status
	end

	local markStatusCacheMeta = {
		__index = getStatusValue
	}

	local function getMarkStatusCache(sceneCache, markType)
		local cache = setmetatable({
			[PARENT_CACHE_KEY] = sceneCache,
			[CACHE_ID_KEY] = markType
		}, markStatusCacheMeta)

		sceneCache[markType] = cache

		return cache
	end

	local sceneCacheMeta = {
		__index = getMarkStatusCache
	}

	local function getSceneCache(filterCache, sceneId)
		local cache = setmetatable({
			[PARENT_CACHE_KEY] = filterCache,
			[CACHE_ID_KEY] = sceneId
		}, sceneCacheMeta)

		filterCache[sceneId] = cache

		return cache
	end

	local filterCacheMeta = {
		__index = getSceneCache
	}

	local function getFilterCache(statusCache, filterKey)
		local cache = setmetatable({
			[PARENT_CACHE_KEY] = statusCache,
			[CACHE_ID_KEY] = filterKey
		}, filterCacheMeta)

		statusCache[filterKey] = cache

		return cache
	end

	local statusCacheMeta = {
		__index = getFilterCache
	}

	local function getStatusCache(caches, statusMap)
		local cache = setmetatable({}, statusCacheMeta)

		caches[statusMap] = cache
		statusCacheOwners[cache] = statusMap

		return cache
	end

	local function createStatusCaches()
		return setmetatable({}, {
			__mode = "k",
			__index = getStatusCache
		})
	end

	local statusCaches = createStatusCaches()

	function MapMarkStatusMap:clearStatusCache()
		statusCaches[self] = nil
	end

	function MapMarkStatusMap.clearAllStatusCache()
		statusCaches = createStatusCaches()
	end

	function MapMarkStatusMap:getStatus(sceneId, markType, staticId)
		return statusCaches[self][NORMAL_CACHE_KEY][sceneId][markType][staticId]
	end

	function MapMarkStatusMap:getFilteredStatus(sceneId, markType, staticId, spaceId)
		if not spaceId then
			return Const.MAP_MARK_STATUS_HIDE
		end

		return statusCaches[self][spaceId][sceneId][markType][staticId]
	end
else
	function MapMarkStatusMap:clearStatusCache()
		return
	end

	function MapMarkStatusMap.clearAllStatusCache()
		return
	end

	MapMarkStatusMap.getStatus = findStatus

	function MapMarkStatusMap:getFilteredStatus(sceneId, markType, staticId, spaceId)
		if not spaceId then
			return Const.MAP_MARK_STATUS_HIDE
		end

		local markConfig = Utils.getMarkConfigByMarkId(staticId, spaceId)

		return markConfig and ToBool(markConfig.multiplayerPoiType) and findStatus(self, sceneId, markType, staticId) or Const.MAP_MARK_STATUS_HIDE
	end
end

function MapMarkStatusMap:getTotalUnlockedCount(needMarkConfigId, needSceneId, spaceId)
	needMarkConfigId = needMarkConfigId or 0
	needSceneId = needSceneId or 0

	local getMarkConfigId = Utils.getMarkConfigId
	local count = 0

	for sceneId, sceneInfo in self:items() do
		if needSceneId == 0 or needSceneId == sceneId then
			for markType, markInfo in sceneInfo:items() do
				for staticId, status in markInfo:items() do
					if (needMarkConfigId == 0 or needMarkConfigId == getMarkConfigId(staticId, spaceId)) and status >= Const.MAP_MARK_STATUS_UNLOCKED then
						count = count + 1
					end
				end
			end
		end
	end

	return count
end

function MapMarkStatusMap:isStaticIdUnlocked(checkStaticId)
	for sceneId, sceneInfo in self:items() do
		for markType, markInfo in sceneInfo:items() do
			for staticId, status in markInfo:items() do
				if staticId == checkStaticId and status >= Const.MAP_MARK_STATUS_UNLOCKED then
					return true
				end
			end
		end
	end

	return false
end

function MapMarkStatusMap:setStatus(sceneId, markType, staticId, status)
	self[sceneId] = self[sceneId] or {}
	self[sceneId][markType] = self[sceneId][markType] or {}
	self[sceneId][markType][staticId] = self[sceneId][markType][staticId] or Const.MAP_MARK_STATUS_HIDE
	self[sceneId][markType][staticId] = status
end

return MapMarkStatusMap
