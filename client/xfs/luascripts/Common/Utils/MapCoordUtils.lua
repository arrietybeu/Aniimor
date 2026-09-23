-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\MapCoordUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("MapCoordUtils")
local SceneData = require("Data.scene_data")
local MapCoordUtils = {}
local _cache = {}

local function buildCache(sceneId)
	local sceneData = SceneData[sceneId]

	if not sceneData then
		logger:error("buildCache: no scene_data for sceneId=%d", sceneId)

		return false
	end

	local pA = sceneData.PointAPositon
	local pB = sceneData.PointBPosition
	local mA = sceneData.MapAPosition
	local mB = sceneData.MapBPosition

	if not pA or not pB or not mA or not mB then
		logger:error("buildCache: missing calibration fields for sceneId=%d " .. "(need PointAPositon/PointBPosition/MapAPosition/MapBPosition)", sceneId)

		return false
	end

	local dx = pA[1] - pB[1]
	local dz = pA[2] - pB[2]

	if dx == 0 or dz == 0 then
		logger:error("buildCache: degenerate calibration (A==B on axis) sceneId=%d", sceneId)

		return false
	end

	return {
		pointAPosX = pA[1],
		pointAPosY = pA[2],
		mapAPosX = mA[1],
		mapAPosY = mA[2],
		coefX = (mA[1] - mB[1]) / dx,
		coefZ = (mA[2] - mB[2]) / dz
	}
end

local function getCache(sceneId)
	local cached = _cache[sceneId]

	if cached ~= nil then
		return cached or nil
	end

	local built = buildCache(sceneId)

	_cache[sceneId] = built or false

	return built or nil
end

function MapCoordUtils.worldToMap(sceneId, worldX, worldZ)
	local c = getCache(sceneId)

	if not c then
		return nil, nil
	end

	local mapX = (worldX - c.pointAPosX) * c.coefX + c.mapAPosX
	local mapY = (worldZ - c.pointAPosY) * c.coefZ + c.mapAPosY

	return mapX, mapY
end

function MapCoordUtils.mapToWorld(sceneId, mapX, mapY)
	local c = getCache(sceneId)

	if not c then
		return nil, nil
	end

	local worldX = (mapX - c.mapAPosX) / c.coefX + c.pointAPosX
	local worldZ = (mapY - c.mapAPosY) / c.coefZ + c.pointAPosY

	return worldX, worldZ
end

function MapCoordUtils.clearCache(sceneId)
	if sceneId then
		_cache[sceneId] = nil
	else
		_cache = {}
	end
end

return MapCoordUtils
