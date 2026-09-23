-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\SafeCallback.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local try = require("Core.Framework.Exception")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("SafeCallback")

local function SafeCallback(cb, ...)
	if jit then
		local status, ret = xpcall(cb, debug.traceback, ...)

		if not status then
			local ex = ret or "unknown error occurred"

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallback traceback occurred \n", ex)
			end
		end

		return
	end

	local args = {
		...
	}
	local paramCount = select("#", ...)
	local status, err = xpcall(function()
		cb(unpack(args, 1, paramCount))
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred \n", ex)
		end
	end
end

return SafeCallback
