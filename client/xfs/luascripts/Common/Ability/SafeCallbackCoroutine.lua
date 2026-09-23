-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SafeCallbackCoroutine.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local try = require("Core.Framework.Exception")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("SafeCallback")

local function SafeCallbackCoroutine(cb, ...)
	local args = {
		...
	}
	local ret, coFunc
	local status, err = xpcall(function()
		local co = coroutine.create(function()
			return {
				cb(unpack(args))
			}
		end)

		local function ResumeCoroutine()
			return coroutine.resume(co)
		end

		local status, result = coroutine.resume(co)

		if status then
			if coroutine.status(co) ~= "dead" then
				ret = ResumeCoroutine
				coFunc = co
			else
				ret = result
			end
		else
			error(result)
		end
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SafeCallback traceback occurred")
		end

		CommonRepo.exceptionFunc(ex)

		return nil, nil
	end

	if type(ret) == "function" then
		return ret, coFunc
	elseif next(ret) ~= nil then
		return unpack(ret), nil
	else
		return nil, nil
	end
end

return SafeCallbackCoroutine
