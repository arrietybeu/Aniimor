-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\SyncStrategy\\CombineSync.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("CombineSync")
local SafeCallback = require("Core.Framework.SafeCallback")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CombineSync = {}

function CombineSync.init()
	SyncStrategyMgr.registerSyncMode(PropertyTypes.SYNC_MODE_COMBINE, CombineSync._syncProperty, CombineSync._onSyncProperty)
end

function CombineSync.runProcess(runner, processName, processFunc, ...)
	SyncStrategyMgr.run(runner, PropertyTypes.SYNC_MODE_COMBINE, processName)

	local processArgs = {
		...
	}
	local status, err = xpcall(function()
		processFunc(unpack(processArgs))
		SyncStrategyMgr.syncProperty2Client(runner)
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

function CombineSync._syncProperty(owner, syncdata)
	if owner.syncMsgToClient == nil then
		local owndata = syncdata.own
		local alldata = syncdata.all

		if next(owndata) ~= nil then
			local ownClientProxy = owner:getOwnClient()

			if ownClientProxy ~= nil then
				local ownerid = ""

				if ownClientProxy.owner ~= owner then
					ownerid = owner.id
				end

				ownClientProxy:sendPropertyStrategySync2Client(PropertyTypes.SYNC_MODE_COMBINE, ownerid, owndata)
			end
		end

		if next(alldata) ~= nil then
			local clientProxies = owner:getAoiClients()

			if clientProxies ~= nil then
				for _, clientProxy in pairs(clientProxies) do
					clientProxy:sendPropertyStrategySync2Client(PropertyTypes.SYNC_MODE_COMBINE, owner.id, alldata)
				end
			end
		end
	elseif owner.syncMsgToClient then
		owner:sendPropertyStrategySync2Client(PropertyTypes.SYNC_MODE_COMBINE, owner.id, syncdata.all)
	end
end

function CombineSync._onSyncProperty(owner, syncdata)
	local changedRoots = {}
	local rootChangedCallbacks = {}

	for propertyId, ops in pairs(syncdata) do
		local size = #ops
		local i = 1
		local name, value

		while i <= size do
			local opType = ops[i]

			if opType == PropertyTypes.OP_DEL or opType == PropertyTypes.OP_REMOVE then
				name, value = ops[i + 1], ""
				i = i + 2
			else
				name, value = ops[i + 1], ops[i + 2]
				i = i + 3
			end

			local rootname

			if propertyId == -1 then
				rootname = name
			else
				local property = owner:_getCachedProperty(propertyId)

				rootname = property._root._name
			end

			if changedRoots[rootname] == nil and rootChangedCallbacks[rootname] ~= false then
				local cb, _, _ = owner:_getPropertyCallback(PropertyTypes.OP_CHANGE, rootname)

				if cb ~= nil then
					rootChangedCallbacks[rootname] = cb

					local root = owner[rootname]

					if type(root) == "table" then
						changedRoots[rootname] = root:deepCopy()
					else
						changedRoots[rootname] = root
					end
				else
					rootChangedCallbacks[rootname] = false
				end
			end

			owner:__syncProperty__(propertyId, opType, name, value, false)
		end
	end

	for rootname, oldval in pairs(changedRoots) do
		local cb = rootChangedCallbacks[rootname]

		SafeCallback(cb, owner, oldval, owner[rootname])
	end
end

return CombineSync
