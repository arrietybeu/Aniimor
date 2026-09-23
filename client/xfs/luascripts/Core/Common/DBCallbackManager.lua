-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\DBCallbackManager.lua

local RotatedIdGenerator = require("Core.Common.RotatedIdGenerator")
local DBCallbackManager = {}

DBCallbackManager.dbCallbacks = {}

local dbCallbackIdGenerator = RotatedIdGenerator()

function DBCallbackManager.regDBCallback(callback)
	local callbackId = dbCallbackIdGenerator:genID()

	DBCallbackManager.dbCallbacks[callbackId] = callback

	return callbackId
end

function DBCallbackManager.unregDBCallback(callbackId)
	DBCallbackManager.dbCallbacks[callbackId] = nil
end

function DBCallbackManager.getDBCallback(callbackId)
	local callback = DBCallbackManager.dbCallbacks[callbackId]

	DBCallbackManager.dbCallbacks[callbackId] = nil

	return callback
end

return DBCallbackManager
