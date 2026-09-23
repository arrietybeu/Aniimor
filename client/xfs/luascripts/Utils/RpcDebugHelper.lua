-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RpcDebugHelper.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local logger = LoggerManager.getLogger("RpcDebugHelper")
local RpcDebugHelper = {
	Reset = false,
	RpcDebug = false,
	TmpClosed = false,
	RpcMsg = ""
}
local CLIENT_CHECK_INTERVAL = 5
local DEBUG_LOG_REPORT_IP = "10.8.45.66"
local DEBUG_LOG_REPORT_PORT = 8080

function RpcDebugHelper.setRpcDebug()
	if not RpcDebugHelper.RpcDebug then
		RpcDebugHelper.Reset = true
		RpcDebugHelper.RpcDebug = true
	else
		RpcDebugHelper.RpcDebug = false

		if RpcDebugHelper.SendTimerId ~= nil then
			TimerManager.removeTimer(RpcDebugHelper.SendTimerId)

			RpcDebugHelper.SendTimerId = nil
		end
	end

	RpcDebugHelper.TmpClosed = false
end

function RpcDebugHelper.checkRpcMsg()
	if RpcDebugHelper.RpcMsg == "" then
		return
	end

	RpcDebugHelper.sendRpcMsg(RpcDebugHelper.RpcMsg)

	RpcDebugHelper.RpcMsg = ""
end

function RpcDebugHelper.sendRpcMsg(message)
	local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
	local HttpRequest = require("Core.Net.Http.HttpRequest")
	local GlobalData = require("Core.Client.GlobalData")
	local json = require("json")

	local function cb(reply)
		if reply.err ~= 0 and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("LoggerHelper.sendDebugLog but http error")
		end
	end

	local proxy = HttpClientProxy()
	local request = {
		ip = LOCAL_IP_STR,
		name = GlobalData.UserName or "",
		msg = message,
		reset = RpcDebugHelper.Reset
	}

	RpcDebugHelper.Reset = false

	local body = json.encode(request)
	local request = HttpRequest(DEBUG_LOG_REPORT_IP, DEBUG_LOG_REPORT_PORT, "POST", "/log", nil, body, false)

	proxy:httpRequest(request, 5, cb, false)
end

function RpcDebugHelper.sendMsg(className, entId, methodName, ...)
	if not RpcDebugHelper.RpcDebug or RpcDebugHelper.TmpClosed then
		return
	end

	if methodName == "RPC_CS_Heartbeat" then
		return
	end

	local msg = string.format("%s %s %s %s %s\n", TimeUtils.timeStampToUtcString(Time.secondCache), className, entId, methodName, inspect({
		...
	}))

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("[RPCLOG]: ", msg)
	end

	RpcDebugHelper.RpcMsg = RpcDebugHelper.RpcMsg .. msg

	if RpcDebugHelper.SendTimerId == nil then
		RpcDebugHelper.SendTimerId = TimerManager.addRepeatTimer(CLIENT_CHECK_INTERVAL, RpcDebugHelper.checkRpcMsg)
	end
end

return RpcDebugHelper
