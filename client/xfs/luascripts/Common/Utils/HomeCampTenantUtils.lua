-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeCampTenantUtils.lua

local HomeCampConst = require("Common.Const.HomeCampConst")
local LoggerManager = require("Core.Log.LoggerManager")
local HomeCampTenantUtils = {}
local math_random = math.random
local logger = LoggerManager.getLogger("HomeCampTenantUtils")

HomeCampTenantUtils._staticId2AreaId = {}
HomeCampTenantUtils._areaId2StaticId = {}
HomeCampTenantUtils._areaId2Prefix = {}
HomeCampTenantUtils._areaBucketCount = {}
HomeCampTenantUtils._initialized = false

function HomeCampTenantUtils.init()
	HomeCampTenantUtils._staticId2AreaId = {}
	HomeCampTenantUtils._areaId2StaticId = {}
	HomeCampTenantUtils._areaId2Prefix = {}
	HomeCampTenantUtils._areaBucketCount = {}

	local bridgeConfig = {
		[83980508] = {
			areaPrefix = "A1",
			areaId = 1,
			bucketCount = 4
		},
		[84748009] = {
			areaPrefix = "A2",
			areaId = 2,
			bucketCount = 4
		},
		[84750948] = {
			areaPrefix = "A3",
			areaId = 3,
			bucketCount = 4
		},
		[84750989] = {
			areaPrefix = "A4",
			areaId = 4,
			bucketCount = 4
		}
	}
	local ok, HomeCampData = pcall(require, "Data.home_camp_data")

	if ok and HomeCampData then
		for staticId, campCfg in pairs(HomeCampData) do
			local areaId = tonumber(campCfg and campCfg.areaId)
			local areaPrefix = campCfg and campCfg.areaPrefix
			local bucketCount = HomeCampConst.DEFAULT_BUCKET_COUNT

			if areaId and areaPrefix and bucketCount then
				HomeCampTenantUtils._staticId2AreaId[staticId] = areaId
				HomeCampTenantUtils._areaId2StaticId[areaId] = staticId
				HomeCampTenantUtils._areaId2Prefix[areaId] = areaPrefix
				HomeCampTenantUtils._areaBucketCount[areaId] = bucketCount

				logger:info("HomeCampTenantUtils.init area loaded, staticId=%s areaId=%s areaPrefix=%s bucketCount=%s", tostring(staticId), tostring(areaId), tostring(areaPrefix), tostring(bucketCount))
			else
				logger:warn("HomeCampTenantUtils.init invalid camp cfg, staticId=%s areaId=%s areaPrefix=%s bucketCount=%s", tostring(staticId), tostring(campCfg and campCfg.areaId), tostring(campCfg and campCfg.areaPrefix), tostring(campCfg and campCfg.bucketCount))
			end
		end
	else
		for staticId, cfg in pairs(bridgeConfig) do
			HomeCampTenantUtils._staticId2AreaId[staticId] = cfg.areaId
			HomeCampTenantUtils._areaId2StaticId[cfg.areaId] = staticId
			HomeCampTenantUtils._areaId2Prefix[cfg.areaId] = cfg.areaPrefix
			HomeCampTenantUtils._areaBucketCount[cfg.areaId] = cfg.bucketCount
		end
	end

	HomeCampTenantUtils._initialized = true
end

function HomeCampTenantUtils.getTenantKey(clusterId)
	local ServerSwitch = require("ServerSwitch")

	if _G_IsDebugMode and ServerSwitch.OneClusterOneHomeCampService and clusterId and clusterId ~= 0 then
		return tostring(clusterId)
	end

	return HomeCampConst.DEFAULT_TENANT_KEY
end

function HomeCampTenantUtils.getForceClusterId(clusterId)
	local ServerSwitch = require("ServerSwitch")

	if _G_IsDebugMode and ServerSwitch.OneClusterOneHomeCampService and ServerSwitch.ForceNewCampLine and clusterId and clusterId ~= 0 then
		return clusterId
	end

	return 0
end

function HomeCampTenantUtils.getBucketKey(tenantKey, areaId, bucketId)
	return string.format("%s:%d:%d", tenantKey, areaId, bucketId)
end

function HomeCampTenantUtils.parseBucketKey(bucketKey)
	local tenantKey, areaId, bucketId = string.match(bucketKey, "^(.+):(%d+):(%d+)$")

	if not tenantKey then
		return nil
	end

	return tenantKey, tonumber(areaId), tonumber(bucketId)
end

function HomeCampTenantUtils.getAreaIdFromStaticId(staticId)
	return HomeCampTenantUtils._staticId2AreaId[staticId]
end

function HomeCampTenantUtils.getStaticIdFromAreaId(areaId)
	return HomeCampTenantUtils._areaId2StaticId[areaId]
end

function HomeCampTenantUtils.isConfiguredAreaId(areaId)
	return HomeCampTenantUtils._areaId2StaticId[areaId] ~= nil
end

function HomeCampTenantUtils.isConfiguredAreaStaticPair(areaId, staticId)
	return HomeCampTenantUtils._areaId2StaticId[areaId] == staticId
end

function HomeCampTenantUtils.getAreaPrefix(areaId)
	return HomeCampTenantUtils._areaId2Prefix[areaId] or "XX"
end

function HomeCampTenantUtils.getBucketCount(areaId)
	return HomeCampTenantUtils._areaBucketCount[areaId] or HomeCampConst.DEFAULT_BUCKET_COUNT
end

function HomeCampTenantUtils.selectBucketForLogin(areaId)
	local count = HomeCampTenantUtils.getBucketCount(areaId)

	return math_random(0, count - 1)
end

function HomeCampTenantUtils.getAllAreaIds()
	local ids = {}

	for areaId, _ in pairs(HomeCampTenantUtils._areaId2StaticId) do
		ids[#ids + 1] = areaId
	end

	table.sort(ids)

	return ids
end

function HomeCampTenantUtils.getAllBucketIds(areaId)
	local count = HomeCampTenantUtils.getBucketCount(areaId)
	local ids = {}

	for i = 0, count - 1 do
		ids[#ids + 1] = i
	end

	return ids
end

return HomeCampTenantUtils
