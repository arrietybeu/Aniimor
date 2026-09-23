-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\SafeCallbackWithReturn.lua

local try = require("Core.Framework.Exception")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("SafeCallbackWithReturn")
local lume = require("Core.Common.lume")
local getListLenWithNil = lume.getListLenWithNil

local function tryFunc(cb, ...)
	return {
		cb(...)
	}
end

local function SafeCallbackWithReturn(cb, ...)
	if jit then
		local status, ret = xpcall(tryFunc, debug.traceback, cb, ...)

		if not status then
			local ex = ret or "unknown error occurred"

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("SafeCallbackWithReturn traceback occurred \n", ex)
			end

			return nil
		end

		if next(ret) ~= nil then
			return unpack(ret, 1, getListLenWithNil(ret))
		else
			return nil
		end
	end

	local args = {
		...
	}
	local ret
	local paramCount = select("#", ...)
	local status, err = xpcall(function()
		ret = {
			cb(unpack(args, 1, paramCount))
		}
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallbackWithReturn traceback occurred \n", ex)
		end

		return nil
	end

	if next(ret) ~= nil then
		return unpack(ret, 1, getListLenWithNil(ret))
	else
		return nil
	end
end

return SafeCallbackWithReturn
