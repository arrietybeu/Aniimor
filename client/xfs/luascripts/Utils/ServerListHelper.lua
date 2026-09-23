-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ServerListHelper.lua

local HttpClientProxy = require("Core.Net.Http.HttpClientProxy")
local HttpRequest = require("Core.Net.Http.HttpRequest")
local ClientRepo = require("Core.Client.ClientRepo")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local json = require("json")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local logger = LoggerManager.getLogger("ServerListHelper")
local ServerListPullDelayNormal = 120
local ServerListPullDelayFast = 10
local ServerListRoundTimeout = 12
local ServerListPullUseCSImp = false
local ServerListHelper = {
	_pullSeq = 0
}

function ServerListHelper.startPullServerList(needNotify, onFailure)
	if not ClientRepo.confJson.enableOnlineServerList then
		ServerListHelper.reqServerList(false, onFailure)

		return
	end

	local prefetchedResult = ServerListHelper._prefetchedResult

	ServerListHelper._prefetchedResult = nil

	local prefetchedApplied = false

	if prefetchedResult ~= nil then
		prefetchedApplied = ServerListHelper._finishPullSuccess(prefetchedResult)

		if not prefetchedApplied then
			local dirConf = ClientUtils.getDirConf()

			if dirConf == nil or dirConf.localDirData == nil or #dirConf.localDirData == 0 then
				ServerListHelper._tryApplyLocalFallback()
			end
		end
	elseif ClientRepo.ServerGroupDataOnline ~= nil then
		if not ServerListHelper._finishPullSuccess(ClientRepo.ServerGroupDataOnline) then
			ServerListHelper._tryApplyLocalFallback()
		end
	else
		ServerListHelper._tryApplyLocalFallback()
	end

	local serverInfo = ClientUtils.getServerInfo()

	if serverInfo ~= nil and serverInfo.Status ~= nil and serverInfo.Status ~= 1 then
		ServerListHelper.pullServerListFast()

		if needNotify then
			ClientUtils.showConfirmRaw(serverInfo.Title, serverInfo.Msg, function()
				return
			end, true)
		end
	else
		ServerListHelper.pullServerListNormal()
	end

	local pending = ServerListHelper._pendingPull

	if pending ~= nil then
		if onFailure ~= nil then
			pending.onFailure = onFailure
		end

		return
	end

	if prefetchedApplied then
		return
	end

	ServerListHelper.reqServerList(false, onFailure)
end

function ServerListHelper.prefetchServerList()
	if not ClientRepo.confJson.enableOnlineServerList then
		return
	end

	ServerListHelper._requestServerList(false, nil, true)
end

function ServerListHelper.stopPullServerList()
	ServerListHelper._stopPullServerListTimer()

	local pending = ServerListHelper._pendingPull

	if pending ~= nil then
		ServerListHelper._cancelPullDeadline(pending)

		ServerListHelper._pendingPull = nil
	end
end

function ServerListHelper._stopPullServerListTimer()
	if ServerListHelper.pullServerListTimer then
		TimerManager.removeTimer(ServerListHelper.pullServerListTimer)

		ServerListHelper.pullServerListTimer = nil
	end
end

function ServerListHelper.pullServerListNormal()
	ServerListHelper._stopPullServerListTimer()

	ServerListHelper.pullServerListTimer = TimerManager.addRepeatTimer(ServerListPullDelayNormal, ServerListHelper.reqServerList)
end

function ServerListHelper.pullServerListFast()
	ServerListHelper._stopPullServerListTimer()

	ServerListHelper.pullServerListTimer = TimerManager.addRepeatTimer(ServerListPullDelayFast, ServerListHelper.reqServerList)
end

function ServerListHelper._buildPullError(source, category, detail)
	return {
		source = source,
		category = category,
		detail = detail,
		ts = Time and Time.secondCache or 0
	}
end

function ServerListHelper._isCurrentPull(seq)
	local pending = ServerListHelper._pendingPull

	return pending ~= nil and pending.seq == seq
end

function ServerListHelper._cancelPullDeadline(pending)
	if pending ~= nil and pending.deadlineTimer ~= nil then
		TimerManager.removeTimer(pending.deadlineTimer)

		pending.deadlineTimer = nil
	end
end

function ServerListHelper._completePull(seq)
	if not ServerListHelper._isCurrentPull(seq) then
		return
	end

	local pending = ServerListHelper._pendingPull

	ServerListHelper._cancelPullDeadline(pending)

	ServerListHelper._pendingPull = nil
end

function ServerListHelper._finishPullSuccessForSeq(seq, source, result)
	if not ServerListHelper._isCurrentPull(seq) then
		return false
	end

	local pending = ServerListHelper._pendingPull
	local doneKey = source .. "Done"

	if pending[doneKey] then
		return true
	end

	local finished, errInfo = ServerListHelper._acceptPullResult(result, pending.isPrefetch)

	if not finished then
		return false, errInfo
	end

	pending[doneKey] = true

	if source == "backup" and not pending.mainDone then
		pending.hasSuccess = true

		return true
	end

	ServerListHelper._completePull(seq)

	return true
end

function ServerListHelper._finishPullFailure(seq, errInfo)
	if not ServerListHelper._isCurrentPull(seq) then
		return
	end

	local pending = ServerListHelper._pendingPull
	local onFailure = pending.onFailure

	ServerListHelper._completePull(seq)
	logger:error("ServerListHelper pull failed")

	if ServerListHelper.pullServerListTimer == nil then
		return
	end

	local dirConf = ClientUtils.getDirConf()

	if dirConf ~= nil and dirConf.localDirData ~= nil and #dirConf.localDirData > 0 then
		return
	end

	if ServerListHelper._tryApplyLocalFallback() then
		return
	end

	if onFailure ~= nil then
		onFailure(errInfo.category or "network", errInfo)
	end
end

function ServerListHelper._onPullDeadline(seq)
	if not ServerListHelper._isCurrentPull(seq) then
		return
	end

	local pending = ServerListHelper._pendingPull

	pending.deadlineTimer = nil

	logger:warn("server-list deadline seq=%s mainDone=%s backupDone=%s", tostring(seq), tostring(pending.mainDone), tostring(pending.backupDone))

	if pending.hasSuccess then
		ServerListHelper._completePull(seq)

		return
	end

	ServerListHelper._finishPullFailure(seq, ServerListHelper._buildPullError("round", "network", "server-list round timeout"))
end

function ServerListHelper._parseServerListReply(reply, source)
	if reply == nil then
		logger:error("ServerListHelper.%s empty reply", tostring(source))

		return false, ServerListHelper._buildPullError(source, "network", "empty reply")
	end

	if reply.err == 0 then
		local status, result = pcall(json.decode, reply.body)

		if status and type(result) == "table" and result.serverGroupData then
			return true, result
		else
			logger:error("ServerListHelper.%s json decode error: %s", tostring(source), tostring(reply.body))

			return false, ServerListHelper._buildPullError(source, "data", "json decode error")
		end
	else
		logger:error("ServerListHelper.%s error: %s", tostring(source), tostring(reply.err))

		return false, ServerListHelper._buildPullError(source, "network", tostring(reply.err))
	end
end

function ServerListHelper._tryApplyLocalFallback()
	local serverGroupData = ClientRepo.confJson.serverGroupData

	if serverGroupData == nil then
		return false
	end

	return ServerListHelper._finishPullSuccess({
		serverGroupData = serverGroupData
	})
end

function ServerListHelper._acceptPullResult(result, isPrefetch)
	if isPrefetch and ServerListHelper.pullServerListTimer == nil then
		ServerListHelper._prefetchedResult = result

		return true
	end

	return ServerListHelper._finishPullSuccess(result)
end

function ServerListHelper._finishPullSuccess(result)
	local oldServerGroupDataOnline = ClientRepo.ServerGroupDataOnline

	ClientRepo.ServerGroupDataOnline = result

	local dirConf, dirKey = ClientUtils.getDirConf()

	if dirConf == nil then
		logger:error("ServerListHelper serverGroup data error: dirConf is nil, %s, %s, %s, %s", ClientConfigServerGroup, ClientConfigLuaReview, ClientConst.OPEN_MIRROR_SERVER, inspect(ClientRepo.ServerGroupDataOnline))

		ClientRepo.ServerGroupDataOnline = oldServerGroupDataOnline

		return false, ServerListHelper._buildPullError("serverGroup", "data", tostring(dirKey))
	end

	if dirConf.localDirData == nil or #dirConf.localDirData == 0 then
		logger:error("ServerListHelper serverGroup data error: localDirData is empty, %s, %s, %s, %s", ClientConfigServerGroup, ClientConfigLuaReview, ClientConst.OPEN_MIRROR_SERVER, inspect(dirConf))

		ClientRepo.ServerGroupDataOnline = oldServerGroupDataOnline

		return false, ServerListHelper._buildPullError("serverGroup", "empty", tostring(dirKey))
	end

	ClientUtils.updateServerList()
	GlobalData.DefaultServerManager:latencyDetect()

	return true
end

function ServerListHelper._recordPullFailure(seq, source, errInfo)
	if not ServerListHelper._isCurrentPull(seq) then
		return
	end

	local pending = ServerListHelper._pendingPull
	local doneKey = source .. "Done"

	if pending[doneKey] then
		return
	end

	pending[doneKey] = true
	pending.errors[#pending.errors + 1] = errInfo

	if pending.hasSuccess then
		ServerListHelper._completePull(seq)

		return
	end

	local allDone = pending.mainDone and pending.backupDone

	if not allDone then
		return
	end

	local bestError = pending.errors[1]

	for _, err in ipairs(pending.errors) do
		if err.category == "data" then
			bestError = err

			break
		elseif err.category == "empty" and bestError.category == "network" then
			bestError = err
		end
	end

	ServerListHelper._finishPullFailure(seq, bestError)
end

function ServerListHelper._OnResponse(reply, seq)
	if not ServerListHelper._isCurrentPull(seq) then
		logger:warn("ignore stale server-list callback source=main seq=%s", tostring(seq))

		return
	end

	local ok, resultOrErr = ServerListHelper._parseServerListReply(reply, "_OnResponse")

	if ok then
		logger:info("ServerListHelper._OnResponse success")

		local finished, errInfo = ServerListHelper._finishPullSuccessForSeq(seq, "main", resultOrErr)

		if finished then
			return
		end

		ServerListHelper._recordPullFailure(seq, "main", errInfo)

		return
	end

	ServerListHelper._recordPullFailure(seq, "main", resultOrErr)
end

function ServerListHelper._OnResponseVolc(reply, seq)
	if not ServerListHelper._isCurrentPull(seq) then
		logger:warn("ignore stale server-list callback source=backup seq=%s", tostring(seq))

		return
	end

	local ok, resultOrErr = ServerListHelper._parseServerListReply(reply, "_OnResponseVolc")

	if ok then
		logger:info("ServerListHelper._OnResponseVolc success")

		local finished, errInfo = ServerListHelper._finishPullSuccessForSeq(seq, "backup", resultOrErr)

		if finished then
			return
		end

		ServerListHelper._recordPullFailure(seq, "backup", errInfo)

		return
	end

	ServerListHelper._recordPullFailure(seq, "backup", resultOrErr)
end

function ServerListHelper._requestServerList(force, onFailure, isPrefetch)
	if not ClientRepo.confJson.enableOnlineServerList then
		if _G_IsDebugMode then
			local dirConf = ClientUtils.getDirConf()

			if dirConf ~= nil then
				ClientRepo.loginAgent:getServerInfosByConfig(dirConf)
			end
		end

		return
	end

	if ServerListHelper._pendingPull ~= nil then
		if not force then
			if onFailure ~= nil then
				ServerListHelper._pendingPull.onFailure = onFailure
			end

			return
		end

		local stalePending = ServerListHelper._pendingPull

		ServerListHelper._cancelPullDeadline(stalePending)

		ServerListHelper._pendingPull = nil

		logger:warn("force restart server-list pull staleSeq=%s", tostring(stalePending.seq))
	end

	local proxy = HttpClientProxy()
	local serverlistUrl = ClientConst.SERVER_LIST.URL_TEST

	if ClientConfigEnvType > 0 then
		serverlistUrl = ClientConst.SERVER_LIST.URL_PUBLISH
	end

	local serverlistHost = ClientConst.SERVER_LIST.CN_HOST

	if ClientConfigAppCountry ~= "cn" then
		serverlistHost = ClientConst.SERVER_LIST.GLOBAL_HOST
	end

	ServerListHelper._pullSeq = (ServerListHelper._pullSeq or 0) + 1

	local seq = ServerListHelper._pullSeq

	ServerListHelper._pendingPull = {
		backupDone = false,
		mainDone = false,
		seq = seq,
		errors = {},
		onFailure = onFailure,
		isPrefetch = isPrefetch == true
	}
	ServerListHelper._pendingPull.deadlineTimer = TimerManager.addTimer(ServerListRoundTimeout, function()
		ServerListHelper._onPullDeadline(seq)
	end)

	logger:info("server-list begin seq=%s timeout=%s", tostring(seq), tostring(ServerListRoundTimeout))

	if ServerListPullUseCSImp == true then
		ServerListHelper.csReqServerList(true, serverlistHost, serverlistUrl, 5000, function(reply)
			ServerListHelper._OnResponse(reply, seq)
		end)
	else
		local request = HttpRequest(serverlistHost, nil, HttpRequest.Method.GET, serverlistUrl, nil, nil, true)

		proxy:httpRequest(request, 5000, function(reply)
			ServerListHelper._OnResponse(reply, seq)
		end, false)
	end

	if ServerListHelper._isCurrentPull(seq) then
		local proxyVolc = HttpClientProxy()
		local serverlistHost = ClientConst.SERVER_LIST.CN_HOST_BACKUP

		if ClientConfigAppCountry ~= "cn" then
			serverlistHost = ClientConst.SERVER_LIST.GLOBAL_HOST_BACKUP
		end

		if ServerListPullUseCSImp == true then
			ServerListHelper.csReqServerList(true, serverlistHost, serverlistUrl, 5000, function(reply)
				ServerListHelper._OnResponseVolc(reply, seq)
			end)
		else
			local request = HttpRequest(serverlistHost, nil, HttpRequest.Method.GET, serverlistUrl, nil, nil, true)

			proxyVolc:httpRequest(request, 5000, function(reply)
				ServerListHelper._OnResponseVolc(reply, seq)
			end, false)
		end
	end
end

function ServerListHelper.reqServerList(force, onFailure)
	ServerListHelper._requestServerList(force, onFailure, false)
end

function ServerListHelper.csReqServerList(isSSL, host, url, timeoutMS, callback)
	local schema = "http"

	if isSSL == true then
		schema = "https"
	end

	local fullUrl = schema .. "://" .. host .. url
	local retry = 0
	local timeoutSec = timeoutMS / 1000
	local addTSFlag = 1

	appFacade.httpManager:LuaHttpGet(fullUrl, retry, timeoutSec, addTSFlag, function(err, msg, body)
		local reply = {}

		reply.err = err
		reply.head = {}
		reply.body = body

		if err ~= 0 then
			print("LuaHttpGetCB: fail, err=[", err, "], msg=[", msg, "], body=[", body, "]")
		end

		callback(reply)
	end)
end

return ServerListHelper
