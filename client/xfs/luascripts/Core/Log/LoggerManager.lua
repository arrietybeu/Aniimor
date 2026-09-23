-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Log\\LoggerManager.lua

local phonestcore = require("phonestcore")
local hook, hookId, errorHook, luaUtil

if UNITY_EDITOR then
	luaUtil = CS.FunPlus.WorldX.Utils.LuaUtils
end

local LoggerConst = require("Core.Log.LoggerConst")
local Logging = require("Core.Log.Logging")
local LogManager = {
	loggerInsMap = {}
}

function LogManager.setHook(hookFunc)
	hook = hookFunc

	local function callbackHook(level, msg)
		hook(level, msg)
	end

	local IDManager = require("Core.Common.IDManager")
	local CallbackManager = require("Core.Net.CallbackManager")

	hookId = IDManager.genB64ID()

	CallbackManager.registerHandler(hookId, callbackHook)
	phonestcore.spdlogSetHook(hookId)
end

function LogManager.clearHook()
	hook = nil

	phonestcore.spdlogClearHook()

	if hookId ~= nil then
		local CallbackManager = require("Core.Net.CallbackManager")

		CallbackManager.unRegisterHandler(hookId)

		hookId = nil
	end
end

function LogManager.setErrorHook(hookFunc)
	errorHook = hookFunc
end

function LogManager.clearErrorHook()
	errorHook = nil
end

function LogManager.getLogger(name, filter, filterLevel)
	if LogManager.loggerInsMap[name] then
		return LogManager.loggerInsMap[name]
	end

	filterLevel = filterLevel or LoggerConst.INFO

	local ins = Logging.new(function(self, level, extra, ...)
		if hook then
			local msg = Logging.prepareLogMsgForHook(self, name, extra, ...)

			hook(level, msg)
		else
			phonestcore.spdlogLua(level, name, extra, ...)
		end

		if errorHook and level >= LoggerConst.ERROR then
			errorHook(name, extra, ...)
		end

		return true
	end)

	LogManager.loggerInsMap[name] = ins

	return ins
end

function LogManager.setLevel(level)
	if level < LoggerConst.DEBUG or level > LoggerConst.ERROR then
		return
	end

	LoggerConst.CURRENT_LEVEL = level

	phonestcore.spdlogSetLevel(level)
end

function LogManager.setEnable(enable)
	LoggerConst.ENABLE = enable
end

function LogManager.checkLogger(level, logTag)
	local enable = LoggerConst.ENABLE and level >= LoggerConst.CURRENT_LEVEL

	if enable and logTag then
		return luaUtil and luaUtil.AllowTag(logTag)
	else
		return enable
	end
end

return LogManager
