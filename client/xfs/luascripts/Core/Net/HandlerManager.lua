-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\HandlerManager.lua

local class = require("Core.Framework.Class")
local globalDeclare = require("Core.Framework.Global")
local HandlerManager = class.Class("HandlerManager")
local cToLHandler = {}
local idToHandler = {}

local function RpcHandlerCallbackOnConnect(cObj, mappingObj, handlerId)
	local handler = idToHandler[handlerId]

	if handler then
		handler(cObj, mappingObj)
	end
end

local function RpcHandlerCallbackOnClose(mappingObj)
	local luaObj = cToLHandler[mappingObj]

	if luaObj == nil then
		return
	end

	luaObj:onSessionDisconnected()

	cToLHandler[mappingObj] = nil
end

local function RpcHandlerCallbackOnMethod(mappingObj, funcName, ...)
	local luaObj = cToLHandler[mappingObj]

	if luaObj == nil then
		return
	end

	if not luaObj[funcName] then
		local LoggerManager = require("Core.Log.LoggerManager")
		local logger = LoggerManager.getLogger("HandlerManager")

		logger:error("RpcHandlerCallbackOnMethod: funcName=%s not found", funcName)

		return
	end

	luaObj[funcName](luaObj, ...)
end

local function RpcHandlerCallbackProtoExceedLimit(mappingObj, size, context)
	local luaObj = cToLHandler[mappingObj]

	if luaObj == nil then
		return
	end

	luaObj:onProtoExceedLimit(size, context)
end

function HandlerManager.init()
	globalDeclare("RpcHandlerCallbackOnConnect", RpcHandlerCallbackOnConnect)
	globalDeclare("RpcHandlerCallbackOnClose", RpcHandlerCallbackOnClose)
	globalDeclare("RpcHandlerCallbackOnMethod", RpcHandlerCallbackOnMethod)
	globalDeclare("RpcHandlerCallbackProtoExceedLimit", RpcHandlerCallbackProtoExceedLimit)

	return true
end

function HandlerManager.registerHandler(handlerId, handler)
	idToHandler[handlerId] = handler
end

function HandlerManager.debugGetHandler(handlerId)
	return idToHandler[handlerId]
end

function HandlerManager.bindHandler(luaObj, mappingObj)
	cToLHandler[mappingObj] = luaObj
end

function HandlerManager.unRegisterHandler(id)
	idToHandler[id] = nil
end

return HandlerManager
