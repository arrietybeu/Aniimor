-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ServerErrorReporter.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Globals = require("Globals")
local GameServerRepo = require("Core.Server.GameServerRepo")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local phonestcore = require("phonestcore")
local md5 = require("md5")
local json = require("json")
local logger = LoggerManager.getLogger("ServerErrorReporter")
local SERVER_ERROR_REPORT_IP = "10.8.45.67"
local SERVER_ERROR_REPORT_PORT = 8080
local SERVER_ERROR_REPORT_URL = "http://10.8.45.67:8080/api/autotest/game-server-errors/add"
local DEDUP_WINDOW_SEC = 86400
local MAX_CACHE_SIZE = 1000
local MAX_RAW_BYTES = 4096
local MAX_MSG_BYTES = 1024
local REPORT_ALLOW_IP_TO_VERSION = {
	["10.8.45.77"] = "ver001",
	["10.8.45.64"] = "release"
}
local ServerErrorReporter = {
	dedupCacheSize = 0,
	lastReportTime = {}
}

local function normalizeForDedup(s)
	s = string.gsub(s, "0x[0-9a-fA-F]+", "")
	s = string.gsub(s, "%d%d%d%d%d%d%d%d%d%d+", "")

	return s
end

local function checkAndUpdateDedup(errorMsg, stackTrace)
	local key = md5.sumhexa(normalizeForDedup((errorMsg or "") .. (stackTrace or "")))
	local now = Time.secondCache
	local last = ServerErrorReporter.lastReportTime[key]

	if last and now - last < DEDUP_WINDOW_SEC then
		return false
	end

	if not last then
		ServerErrorReporter.dedupCacheSize = ServerErrorReporter.dedupCacheSize + 1

		if ServerErrorReporter.dedupCacheSize > MAX_CACHE_SIZE then
			ServerErrorReporter.lastReportTime = {}
			ServerErrorReporter.dedupCacheSize = 1
		end
	end

	ServerErrorReporter.lastReportTime[key] = now

	return true
end

local function truncate(s, maxBytes)
	s = tostring(s or "")

	if maxBytes >= #s then
		return s
	end

	return string.sub(s, 1, maxBytes) .. "...[truncated]"
end

local function buildRequestBody(errorMsg, stackTrace)
	return {
		errors = {
			{
				error_type = "code_error",
				batch_count = 1,
				error_from = "game_server",
				error_time = TimeUtils.timeStampToUtcString(Time.secondCache),
				error_message = truncate(errorMsg, MAX_MSG_BYTES),
				error_raw = truncate(stackTrace, MAX_RAW_BYTES)
			}
		},
		error_info = {
			game_server_error_type = "server",
			server_id = tostring(GameServerRepo.gameServerClusterId or ""),
			server_ip = GameServerRepo.gameServerIp or "",
			server_version = ServerErrorReporter.reportServerVersion or ""
		}
	}
end

local function onReportReply(reply)
	if not reply or not logger or not logger.info then
		return
	end

	local status = reply.header and reply.header.HTTP_STATUS or ""
	local statusNum = tonumber(status) or 0

	if reply.err ~= 0 or statusNum >= 400 then
		logger:info("[ServerErrorReport] http failed err=%s status=%s body=%s", tostring(reply.err), tostring(status), tostring(reply.body))
	end
end

function ServerErrorReporter.reportTraceback(errorMsg, stackTrace)
	if not checkAndUpdateDedup(errorMsg, stackTrace) then
		return
	end

	local httpClientProxy = GameServerRepo.httpClientProxy

	if not httpClientProxy then
		return
	end

	local body = json.encode(buildRequestBody(errorMsg, stackTrace))
	local headers = {
		["Content-Type"] = "application/json"
	}
	local request = HttpRequest(SERVER_ERROR_REPORT_IP, SERVER_ERROR_REPORT_PORT, HttpRequest.Method.POST, SERVER_ERROR_REPORT_URL, headers, body, false)

	httpClientProxy:httpRequest(request, 5000, onReportReply, false, "", 3)
end

local function doReport(name, extra, ...)
	local fullBody = phonestcore.logFormat(...)
	local firstLine = fullBody
	local nlPos = string.find(fullBody, "\n", 1, true)

	if nlPos then
		firstLine = string.sub(fullBody, 1, nlPos - 1)
	end

	local errorMsg = string.format("[%s] %s", name or "?", firstLine)
	local errorRaw = fullBody

	if extra and extra ~= "" then
		errorRaw = errorRaw .. "\n" .. extra
	end

	ServerErrorReporter.reportTraceback(errorMsg, errorRaw)
end

function ServerErrorReporter.onErrorLog(name, extra, ...)
	pcall(doReport, name, extra, ...)
end

local REPORT_ALLOW_CLUSTER_ID = 100

function ServerErrorReporter.init()
	local clusterId = GameServerRepo.gameServerClusterId

	if clusterId ~= REPORT_ALLOW_CLUSTER_ID then
		logger:info("[ServerErrorReport] hook NOT installed, clusterId=%s != %d", tostring(clusterId), REPORT_ALLOW_CLUSTER_ID)

		return
	end

	local debugIp = Globals.debugServerIp

	if not debugIp then
		logger:info("[ServerErrorReport] hook NOT installed, debugServerIp not set")

		return
	end

	local versionName = REPORT_ALLOW_IP_TO_VERSION[debugIp]

	if not versionName then
		logger:info("[ServerErrorReport] hook NOT installed, ip=%s not in whitelist", debugIp)

		return
	end

	ServerErrorReporter.reportServerVersion = versionName

	LoggerManager.setErrorHook(ServerErrorReporter.onErrorLog)
	logger:info("[ServerErrorReport] hook installed, ip=%s server_version=%s", debugIp, versionName)
end

function ServerErrorReporter.clearDedup()
	ServerErrorReporter.lastReportTime = {}
	ServerErrorReporter.dedupCacheSize = 0
end

return ServerErrorReporter
