-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RpcMethod.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Core.Common.Const")
local CallbackContext = require("Core.Common.CallbackContext")
local logger = LoggerManager.getLogger("RpcMethod")
local Switch = require("Core.Common.Switch")
local NoticeDef = require("Common.NoticeDef")
local RpcMethod = class.Class("RpcMethod")
local RPC_LOG_COLORS = {
	RPC_SC_ = "#4FC3F7",
	RPC_CS_ = "#FFB74D"
}

local function colorRpcLog(funcName, logStr)
	for prefix, color in pairs(RPC_LOG_COLORS) do
		if string.sub(funcName, 1, #prefix) == prefix then
			return string.format("<color=%s>%s</color>", color, logStr)
		end
	end

	return logStr
end

function RpcMethod:ctor(accessor, argValidators, name, entity, originFuncName, funcSwitch)
	self.accessor = accessor
	self.argValidators = argValidators
	self.argNum = #argValidators
	self.name = name
	self.entity = entity
	self.originFuncName = originFuncName
	self.funcSwitch = funcSwitch

	local meta = getmetatable(self)

	meta.__call = RpcMethod.call

	setmetatable(self, meta)
end

function RpcMethod:call(callerAccessor, obj, ...)
	if self.funcSwitch and not obj:isFunctionAndSwitchEnable(self.funcSwitch, true) then
		return
	end

	if _G_IsDebugMode and rawget(getfenv(2), "isInTelnetConsole") then
		return self.entity[self.originFuncName](callerAccessor, obj, ...)
	end

	if obj.isObMode and obj:isObMode() and obj.space and obj.space.checkObMsg and not obj.space:checkObMsg(obj, self.name) then
		return
	end

	if self.accessor ~= callerAccessor and self.accessor ~= Const.ACCESSOR_ENGINE then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("RpcMethod %s need accessor %d, but got %d", self.name, self.accessor, callerAccessor)
		end

		return
	end

	if self.accessor == Const.ACCESSOR_CLIENT and not obj:checkCanCallCsRpc(self.name) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("RpcMethod %s too frequent calls, for %s", self.name, obj:repr())
		end

		obj:sendNotice(NoticeDef.ERROR_CS_RPC_CALL_FREQUENT)

		return
	end

	local num = select("#", ...)

	if num == 0 then
		if self.argNum ~= 0 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("RpcMethod %s need args num %d, but got %d", self.name, self.argNum, num)
			end

			return
		end

		if Switch.RpcLog then
			self:traceRpcLog(false, callerAccessor, obj, ...)
		end

		return self.entity[self.originFuncName](obj)
	end

	local arg1 = select(1, ...)

	if class.isInstanceOf(arg1, CallbackContext) then
		num = num - 1

		local chanCtx = arg1

		if num ~= self.argNum then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("RpcMethod %s need args num %d, but got %d", self.name, self.argNum, num)
			end

			return
		end

		for i = 1, num do
			local arg = select(i + 1, ...)
			local ret, errMsg = self.argValidators[i](arg)

			if not ret then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("RpcMethod %s args %d error: %s", self.name, i, errMsg)
				end

				return
			end
		end

		if Switch.RpcLog then
			self:traceRpcLog(true, callerAccessor, obj, ...)
		end

		local ret = self.entity[self.originFuncName](obj, select(2, ...))

		if ret ~= nil then
			if type(ret) ~= "table" then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("Channel callback return must table for: %s", self.name)
				end

				return
			end

			chanCtx:sendResponse(ret)
		end
	else
		if num ~= self.argNum then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				if self.name == "RPC_CS_OtherEntityMethod" and num >= 2 then
					local methodName = select(2, ...)

					logger:error("RpcMethod RPC_CS_OtherEntityMethod(%s) need args num %d, but got %d", methodName, self.argNum, num)
				else
					logger:error("RpcMethod %s need args num %d, but got %d", self.name, self.argNum, num)
				end
			end

			return
		end

		for i = 1, num do
			local arg = select(i, ...)
			local ret, errMsg = self.argValidators[i](arg)

			if not ret then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("RpcMethod %s args %d error: %s", self.name, i, errMsg)
				end

				return
			end
		end

		if Switch.RpcLog then
			self:traceRpcLog(false, callerAccessor, obj, ...)
		end

		return self.entity[self.originFuncName](obj, ...)
	end
end

function RpcMethod:traceRpcLog(hasCallback, callerAccessor, obj, ...)
	local excludeMap = require("Common.Const.GmConst").getName("RpcLogExclulde") or {}
	local funcParams = hasCallback and {
		select(2, ...)
	} or {
		...
	}
	local funcComp = self.entity.typeName
	local funcName = self.name
	local funcStr = string.format("%s:%s", funcComp, funcName)
	local funcObj = obj

	if excludeMap and excludeMap[funcName] then
		return
	end

	if funcStr == "DispatcherComponent:RPC_CS_SpaceMethod" or funcStr == "ClientDispatcherComponent:RPC_SC_SpaceMethod" then
		return
	end

	local params = inspect(funcParams, {
		indent = " ",
		newline = " ",
		depth = 5
	})
	local logStr = string.format("RpcLog: cb=%-5s accessor=%d entityType=%-12s\tentityId=%-20s\tfuncStr=%-50s\tfuncParams=%s", tostring(hasCallback), callerAccessor, funcObj.className, funcObj.id, funcStr, #params <= 200 and params or string.format("len(%d)", #params))

	logStr = colorRpcLog(funcName, logStr)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(logStr)
	end
end

return RpcMethod
