-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\RpcHandler.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("RpcHandler")
local RpcHandler = class.Class("RpcHandler")

function RpcHandler:ctor()
	self.cObj = nil
end

function RpcHandler:setCobj(cObj)
	self.cObj = cObj
end

function RpcHandler:dispatchRpc(rpcName, ...)
	if self.cObj then
		self.cObj:dispatchRpc(rpcName, ...)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("dispatchRpc %s, but rpcHandler is invalid", rpcName)
	end
end

function RpcHandler:onSessionDisconnected()
	assert(self.cObj ~= nil)

	self.cObj = nil
end

function RpcHandler:onProtoExceedLimit(size, context)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("onProtoExceedLimit size: %d, context: %s", size, context)
	end
end

return RpcHandler
