-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\SyncStrategy\\FrameSync.lua

local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local FrameSync = {}

function FrameSync.init()
	SyncStrategyMgr.registerSyncMode(PropertyTypes.SYNC_MODE_FRAME, FrameSync._syncProperty, FrameSync._onSyncProperty)
end

function FrameSync._syncProperty(owner, syncdata)
	local owndata = syncdata.own
	local alldata = syncdata.all

	if next(owndata) ~= nil then
		local ownClientProxy = owner:getOwnClient()

		if ownClientProxy ~= nil then
			local ownerid = ""

			if ownClientProxy.owner ~= owner then
				ownerid = owner.id
			end

			ownClientProxy:clientMsg("_Engine_onPropertyFrameSync", ownerid, owndata)
		end
	end

	if next(alldata) ~= nil then
		local clientProxies = owner:getAoiClients()

		if clientProxies ~= nil then
			for _, clientProxy in pairs(clientProxies) do
				clientProxy:clientMsg("_Engine_onPropertyFrameSync", owner.id, alldata)
			end
		end
	end
end

function FrameSync._onSyncProperty(owner, syncdata)
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

return FrameSync
