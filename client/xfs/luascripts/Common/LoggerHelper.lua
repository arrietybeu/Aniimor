-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\LoggerHelper.lua

local PhonestEnv = require("Core.Net.PhonestEnv")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local Switch = require("Core.Common.Switch")
local TimeUtils = require("Common.Utils.TimeUtils")
local GameVersion = require("Common.GameVersion")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LoggerHelper")
local LoggerHelper = {
	clientBuffer = "\n>>>>>>[Start Client]<<<<<<",
	httpTimeoutCnt = 0,
	clientTraceback = {},
	serverClientLogger = LoggerManager.getLogger("Client")
}
local CLIENT_CHECK_INTERVAL = 5
local DEBUG_LOG_REPORT_IP = "10.8.43.221"
local DEBUG_LOG_REPORT_PORT = 8080
local needUploadLevelMap = {
	[PhonestEnv.logLevel.ERROR] = "CLIENTERROR"
}

function LoggerHelper._isNeedUploadLevel(level)
	return needUploadLevelMap[level] or level >= PhonestEnv.logLevel.ERROR
end

function LoggerHelper._getLogDisplayName(level)
	return needUploadLevelMap[level] or "CLIENTUNKNOWN" .. tostring(level)
end

function LoggerHelper.clientLoggerHook(level, msg, rawMsg)
	if not Switch.EnableClientLoggerReport then
		return
	end

	if level == nil or msg == nil then
		return
	end

	if LoggerHelper.httpTimeoutCnt >= 2 then
		return
	end

	if not LoggerHelper._isNeedUploadLevel(level) then
		return
	end

	LoggerHelper.clientBuffer = string.format("%s\n%s", LoggerHelper.clientBuffer, msg)

	if LoggerHelper.clientTimerId == nil then
		LoggerHelper.clientTimerId = TimerManager.addRepeatTimer(CLIENT_CHECK_INTERVAL, LoggerHelper.clientCheckBuffer)
	end

	local startpos, _ = string.find(rawMsg, "stack traceback:")

	if startpos ~= nil then
		local key = string.sub(rawMsg, 1, startpos - 2)

		LoggerHelper.clientTraceback[key] = msg
	end
end

function LoggerHelper.clientCheckBuffer(isCheckByReceive)
	if not Switch.EnableClientLoggerReport then
		return
	end

	if LoggerHelper.clientBuffer == "" then
		return
	end

	LoggerHelper.sendDebugLog(LoggerHelper.clientBuffer, LoggerHelper.clientTraceback)

	LoggerHelper.clientBuffer = ""
	LoggerHelper.clientTraceback = {}
end

function LoggerHelper.serverReceiveClientLog(mergedBuffer, clientIdentifier)
	if not Switch.EnableClientLoggerReport then
		return
	end

	local batchMsg = ""

	for _, mergedLogInfo in ipairs(mergedBuffer) do
		local count, level, msg = mergedLogInfo[1], mergedLogInfo[2], mergedLogInfo[3]

		batchMsg = batchMsg .. string.format("[x%d]\t[%s]\t%s\n", count, LoggerHelper._getLogDisplayName(level), msg)
	end

	LoggerHelper.serverClientLogger:debug("CLIENT LOG REPORT:\n%s", batchMsg, clientIdentifier)
end

function LoggerHelper.sendDebugLog(message, clientTraceback)
	if FREE_WALK then
		return
	end

	if not clientTraceback or not next(clientTraceback) then
		return
	end

	local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
	local HttpRequest = require("Core.Net.Http.HttpRequest")
	local json = require("json")

	local function cb(reply)
		if reply.err ~= 0 then
			LoggerHelper.httpTimeoutCnt = LoggerHelper.httpTimeoutCnt + 1

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("LoggerHelper.sendDebugLog but http error")
			end
		end
	end

	local proxy = HttpClientProxy()
	local headers = {
		["Content-Type"] = "application/json"
	}
	local requestBody = LoggerHelper.getRequestBody(clientTraceback)
	local body = json.encode(requestBody)
	local request = HttpRequest(DEBUG_LOG_REPORT_IP, DEBUG_LOG_REPORT_PORT, "POST", "http://10.8.43.221:3004/api/autotest/game-server-errors/add", headers, body, false)

	proxy:httpRequest(request, 5, cb, false)
end

function LoggerHelper.getRequestBody(clientTraceback)
	local GlobalData = require("Core.Client.GlobalData")
	local errors = {}

	for key, value in pairs(clientTraceback) do
		local ErrorEntry = {
			error_type = "code_error",
			batch_count = 1,
			game_server = "game_client",
			error_time = TimeUtils.timeStampToUtcString(Time.secondCache),
			error_message = key,
			error_raw = value
		}

		errors[#errors + 1] = ErrorEntry
	end

	local error_info = {
		game_server_error_type = "client",
		server_id = tostring(GlobalData.ServerId),
		client_ip = LOCAL_IP_STR,
		client_player_name = GlobalData.UserName or "",
		client_uid = pg.me and pg.me.uid or "",
		client_version = tostring(GameVersion)
	}

	return {
		errors = errors,
		error_info = error_info
	}
end

return LoggerHelper
