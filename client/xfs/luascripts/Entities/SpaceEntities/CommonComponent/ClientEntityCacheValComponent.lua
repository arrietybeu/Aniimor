-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientEntityCacheValComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local EntityCacheValueUtils = require("Common.Utils.EntityCacheValueUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientEntityCacheValComponent = Class.Component("ClientEntityCacheValComponent")

function ClientEntityCacheValComponent:init(dict)
	self.serverEntityCacheVal = dict.serverEntityCacheVal
end

function ClientEntityCacheValComponent:EVENT_EnterScene()
	if self.subject then
		for k, v in pairs(self.serverEntityCacheVal) do
			self.subject:notify(AbilityConst.COMBAT_EVENT_ON_SERVER_CACHE_VAL_CHANGE, k)
		end
	end
end

function ClientEntityCacheValComponent:RPC_SC_SyncEntityCacheValNumber(key, val)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SyncEntityCacheValNumber", key, val)
	end

	local oldVal = EntityCacheValueUtils.getCacheValue(self, key)

	EntityCacheValueUtils.innerSetCacheValue(self, key, val)
	self:postComponentMethod("EVENT_OnEntityCacheValChanged", key, val, oldVal)
end

function ClientEntityCacheValComponent:RPC_SC_SyncRemoveEntityCacheVal(key)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_SyncRemoveEntityCacheVal", key)
	end

	local oldVal = EntityCacheValueUtils.getCacheValue(self, key)

	EntityCacheValueUtils.innerRemoveCacheValue(self, key)
	self:postComponentMethod("EVENT_OnEntityCacheValChanged", key, nil, oldVal)
end

return ClientEntityCacheValComponent
