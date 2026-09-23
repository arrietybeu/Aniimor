-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ServiceUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonRepo = require("Core.Common.CommonRepo")
local logger = LoggerManager.getLogger("ServiceUtils")
local Repo, GameAPI

if pg.component == "client" then
	Repo = require("Core.Client.ClientRepo")
else
	Repo = require("Core.Server.GameServerRepo")
	GameAPI = require("Core.Server.GameAPI")
end

local ServiceUtils = {}

function ServiceUtils.callService(serviceName, methodName, args, callback, options)
	if not _G_IsDebugMode then
		if GameAPI == nil or not GameAPI.inGlobalCluster() then
			return ServiceUtils._localClusterCallService(serviceName, methodName, args, callback, options)
		else
			return ServiceUtils._globalClusterCallService(serviceName, methodName, args, callback, options)
		end
	elseif CommonRepo.serviceType[serviceName] == "CLUSTER" then
		if Repo.clusterMsProxy == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("callService clusterMsProxy is nil, for ", serviceName, methodName)
			end

			return
		end

		Repo.clusterMsProxy:callService(serviceName, methodName, args, callback, options)

		return
	elseif GameAPI == nil or not GameAPI.inGlobalCluster() then
		return ServiceUtils._localClusterCallService(serviceName, methodName, args, callback, options)
	else
		return ServiceUtils._globalClusterCallService(serviceName, methodName, args, callback, options)
	end
end

function ServiceUtils._localClusterCallService(serviceName, methodName, args, callback, options)
	if Repo.extraGlobalMsProxy == nil or Repo.extraServiceMap[serviceName] == nil then
		if Repo.globalMsProxy == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("callService globalMsProxy is nil, for ", serviceName, methodName)
			end

			return
		end

		return Repo.globalMsProxy:callService(serviceName, methodName, args, callback, options)
	else
		return Repo.extraGlobalMsProxy:callService(serviceName, methodName, args, callback, options)
	end
end

function ServiceUtils._globalClusterCallService(serviceName, methodName, args, callback, options)
	if Repo.extraGlobalMsProxy == nil or Repo.extraServiceMap[serviceName] == nil then
		if Repo.clusterMsProxy == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("callService clusterMsProxy is nil, for ", serviceName, methodName)
			end

			return
		end

		return Repo.clusterMsProxy:callService(serviceName, methodName, args, callback, options)
	else
		return Repo.extraGlobalMsProxy:callService(serviceName, methodName, args, callback, options)
	end
end

function ServiceUtils.delRequestCallback(rid, serviceName)
	local msProxy = Repo.globalMsProxy

	if Repo.extraGlobalMsProxy ~= nil and Repo.extraServiceMap[serviceName] ~= nil then
		msProxy = Repo.extraGlobalMsProxy

		if msProxy == nil then
			return
		end
	end

	if msProxy == nil then
		return
	end

	msProxy:delRequestCallback(rid)
end

function ServiceUtils.msProxyConected(serviceName)
	if Repo.extraGlobalMsProxy == nil or Repo.extraServiceMap[serviceName] == nil then
		return Repo.globalMsProxy ~= nil and Repo.globalMsProxy:isConnected()
	else
		return Repo.extraGlobalMsProxy:isConnected()
	end
end

function ServiceUtils.userDataGetAttribute(uid, attributesList, callback, callerId)
	ServiceUtils.callService("UserDataService", "getAttribute", {
		uid,
		attributesList
	}, callback, {
		callerId = callerId
	})
end

function ServiceUtils.userDataBatchGetAttribute(uids, attributesList, callback, callerId)
	ServiceUtils.callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList
	}, callback, {
		callerId = callerId
	})
end

function ServiceUtils.kvServiceEcoTracePro(phase, petId, callback)
	ServiceUtils.callService("KvService", "getEcoTraceProgress", {
		phase,
		petId
	}, callback)
end

function ServiceUtils.kvServiceFind(key, callback)
	ServiceUtils.callService("KvService", "find", {
		key
	}, callback, {
		hint = key
	})
end

return ServiceUtils
