-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformLogger.lua

local LoggerManager = require("Core.Log.LoggerManager")
local PlatformLogger = {}

PlatformLogger.inner = LoggerManager.getLogger("platform")
PlatformLogger.STACK_LEN = jit and 3 or 4

function PlatformLogger:debug(...)
	PlatformLogger.inner.stackLen = PlatformLogger.STACK_LEN

	PlatformLogger.inner:debug(...)
end

function PlatformLogger:info(...)
	PlatformLogger.inner.stackLen = PlatformLogger.STACK_LEN

	PlatformLogger.inner:info(...)
end

function PlatformLogger:warn(...)
	PlatformLogger.inner.stackLen = PlatformLogger.STACK_LEN

	PlatformLogger.inner:warn(...)
end

function PlatformLogger:error(...)
	PlatformLogger.inner.stackLen = PlatformLogger.STACK_LEN

	PlatformLogger.inner:error(...)
end

return PlatformLogger
