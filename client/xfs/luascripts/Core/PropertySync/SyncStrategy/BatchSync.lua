-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\SyncStrategy\\BatchSync.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("BatchSync")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local BatchSync = {}

function BatchSync.init()
	SyncStrategyMgr.registerSyncMode(PropertyTypes.SYNC_MODE_BATCH, BatchSync._syncProperty, BatchSync._onSyncProperty)
end

function BatchSync.runProcess(runner, processName, processFunc, ...)
	SyncStrategyMgr.run(runner, PropertyTypes.SYNC_MODE_BATCH, processName)

	local processArgs = {
		...
	}
	local status, err = xpcall(function()
		local syncArgs = {
			processFunc(unpack(processArgs))
		}

		SyncStrategyMgr.syncProperty2Client(runner)

		local clientProxy = runner:getOwnClient()

		if clientProxy then
			if clientProxy.owner == runner then
				clientProxy:clientMsg(processName, unpack(syncArgs))
			else
				clientProxy:clientOtherMsg(runner.id, processName, unpack(syncArgs))
			end
		end
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("runProcess traceback occurred")
		end

		CommonRepo.exceptionFunc(ex)
	end

	SyncStrategyMgr.exit()
end

function BatchSync._syncProperty(owner, syncdata)
	local owndata = syncdata.own
	local alldata = syncdata.all

	if next(owndata) ~= nil then
		local ownClientProxy = owner:getOwnClient()

		if ownClientProxy ~= nil then
			local ownerid = ""

			if ownClientProxy.owner ~= owner then
				ownerid = owner.id
			end

			ownClientProxy:sendPropertyStrategySync2Client(PropertyTypes.SYNC_MODE_BATCH, ownerid, owndata)
		end
	end

	if next(alldata) ~= nil then
		local clientProxies = owner:getAoiClients()

		if clientProxies ~= nil then
			for _, clientProxy in pairs(clientProxies) do
				clientProxy:sendPropertyStrategySync2Client(PropertyTypes.SYNC_MODE_BATCH, owner.id, alldata)
			end
		end
	end
end

function BatchSync._onSyncProperty(owner, syncdata)
	for propertyId, ops in pairs(syncdata) do
		local size = #ops
		local i = 1

		while i <= size do
			local opType = ops[i]
			local name, value

			if opType == PropertyTypes.OP_DEL or opType == PropertyTypes.OP_REMOVE then
				name, value = ops[i + 1], ""
				i = i + 2
			else
				name, value = ops[i + 1], ops[i + 2]
				i = i + 3
			end

			owner:__syncProperty__(propertyId, opType, name, value, false)
		end
	end
end

return BatchSync
