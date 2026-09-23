-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\SafeCallbackWithStatusAndReturn.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SafeCallbackWithReturn")

local function errorHandler(err)
	local traceback = debug.traceback(tostring(err), 2)

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("SafeCallback failed\n%s", traceback)
	end

	return traceback
end

local function SafeCallbackWithStatusAndReturn(cb, ...)
	if jit then
		return xpcall(cb, errorHandler, ...)
	end

	local args = {
		...
	}
	local argCount = select("#", ...)

	return xpcall(function()
		return cb(unpack(args, 1, argCount))
	end, errorHandler)
end

return SafeCallbackWithStatusAndReturn
