-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\EntityCacheValueUtils.lua

local Utils = require("Common.Utils.Utils")
local ListPool = require("Common.Container.ListPool")
local CommonSwitch = require("Common.CommonSwitch")
local EntityCacheValueUtils = {}

function EntityCacheValueUtils.init(entity)
	if entity then
		entity.serverEntityCacheVal = {}
	end
end

function EntityCacheValueUtils.getCacheValue(entity, key)
	if entity and entity.serverEntityCacheVal then
		return entity.serverEntityCacheVal[key]
	end
end

function EntityCacheValueUtils.setCacheValue(entity, key, value)
	if not entity then
		return false
	end

	if not value then
		EntityCacheValueUtils.removeCacheValue(entity, key)

		return true
	elseif Utils.checkClient() then
		entity:serverMsg("RPC_CS_SetEntityCacheValue", key, value)

		return true
	elseif type(value) == "number" then
		if EntityCacheValueUtils.innerSetCacheValue(entity, key, value) then
			entity:allClientsMsg("RPC_SC_SyncEntityCacheValNumber", key, value)
		end

		return true
	end

	return false
end

function EntityCacheValueUtils.innerSetCacheValue(entity, key, value)
	if entity and entity.serverEntityCacheVal and entity.serverEntityCacheVal[key] ~= value then
		entity.serverEntityCacheVal[key] = value

		return true
	end

	return false
end

function EntityCacheValueUtils.innerRemoveCacheValue(entity, key)
	if entity and entity.serverEntityCacheVal and entity.serverEntityCacheVal[key] then
		entity.serverEntityCacheVal[key] = nil

		return true
	end

	return false
end

function EntityCacheValueUtils.removeCacheValue(entity, key)
	if not entity then
		return false
	end

	if Utils.checkClient() then
		entity:serverMsg("RPC_CS_RemoveEntityCacheValue", key)

		return true
	elseif EntityCacheValueUtils.innerRemoveCacheValue(entity, key) then
		entity:clientMsg("RPC_SC_SyncRemoveEntityCacheVal", key)

		return true
	end

	return false
end

return EntityCacheValueUtils
