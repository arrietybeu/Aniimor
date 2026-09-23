-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\GateClientRpcHandler.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local EntityFactory = require("Core.Common.EntityFactory")
local RpcMethod = require("Core.Common.RpcMethod")
local Const = require("Core.Common.Const")
local ClientRepo = require("Core.Client.ClientRepo")
local ServerProxy = require("Core.Client.ServerProxy")
local ProtobufConst = require("Core.Common.ProtobufConst")
local logger = LoggerManager.getLogger("GateClientRpcHandler")
local EntityManager = require("Core.Common.EntityManager")
local RpcHandler = require("Core.Net.RpcHandler")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local Time = require("Core.Common.Time")
local ProtoCodec = require("Core.Common.ProtoCodec")
local RpcIndex = require("Core.Common.RpcIndex")
local BotIgnoreRpc = require("Core.Common.BotIgnoreRpc")
local ClientUtils = require("Utils.ClientUtils")
local CoreConst = require("Core.Common.Const")
local ActorManager = require("Core.Common.ActorManager")
local CommonSwitch = require("Common.CommonSwitch")
local RpcDataCodec = require("Core.PropertySync.RpcDataCodec")
local CompactPropertySchema = require("Core.PropertySync.CompactPropertySchema")
local GlobalData = require("Core.Client.GlobalData")

local function decodeEntityInitForLogic(entityType, initDict)
	if CommonSwitch.CompactClientInitDataVerify then
		local VerifyCodec = require("Core.PropertySync.RpcDataVerifyCodec")

		return VerifyCodec.decodeEntityInitOrNormal(RpcDataCodec, entityType, initDict)
	end

	return RpcDataCodec.decodeEntityInit(entityType, initDict)
end

local GateClientRpcHandler = class.Class("GateClientRpcHandler", RpcHandler)

function GateClientRpcHandler:ctor(client, deviceid)
	GateClientRpcHandler.super.ctor(self)

	self.codec = ProtoCodec()
	self.deviceid = deviceid
	self.serverProxy = nil
	ClientRepo.clusterMsProxy = nil
	self.client = client
	self.destroyed = false
end

function GateClientRpcHandler:onSessionDisconnected()
	if self.client then
		self.client:updateClientRpcSeqId(self:getClientRpcSeqId())
	end

	GateClientRpcHandler.super.onSessionDisconnected(self)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onSessionDisconnected")
	end

	if self.serverProxy ~= nil then
		self.serverProxy:onSessionDisconnected()
		self.serverProxy:destroy()

		self.serverProxy = nil
		ClientRepo.clusterMsProxy = nil
	end

	if self.client and self.client.session then
		self.client.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
	end

	self:destroy()
end

function GateClientRpcHandler:handshake(pubKeyData)
	assert(self.client ~= nil)
	self:requestEncryptToken(pubKeyData)
end

function GateClientRpcHandler:requestEncryptToken(pubKeyData)
	self:dispatchRpc("sendRequestEncryptToken", pubKeyData)
end

function GateClientRpcHandler:confirmEncryptKeyAck()
	if self.client then
		self.client:onConfirmEncryptKeyAck()
	end
end

function GateClientRpcHandler:connectServer(reqType, auth, entMbBin, version)
	local auth = auth or ""
	local entMbBin = entMbBin or ""

	if CommonSwitch.ClientRpcReplayReconnect then
		local lastClientRpcSeqId = 0
		local forceFullSync = false

		if self.client then
			lastClientRpcSeqId, forceFullSync = self.client:getClientRpcSeqId(reqType)
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("clientRpcReplay connectServer reqType=%s lastClientRpcSeqId=%s forceFullSync=%s", reqType, lastClientRpcSeqId, forceFullSync)
		end

		self:dispatchRpc("sendConnectServer", reqType, self.deviceid, auth, entMbBin, version, lastClientRpcSeqId)

		return
	end

	self:dispatchRpc("sendConnectServer", reqType, self.deviceid, auth, entMbBin, version)
end

function GateClientRpcHandler:dispatchRpc(rpcName, ...)
	if self.cObj then
		self.cObj:dispatchRpc(rpcName, ...)
	end
end

function GateClientRpcHandler:getClientRpcSeqId()
	if self.cObj and self.cObj.getClientRpcSeqId then
		return self.cObj:getClientRpcSeqId()
	end

	return 0
end

function GateClientRpcHandler:resumeEntityServer()
	local entity = GlobalData.Player or pg.me

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("clientRpcReplay resumeEntityServer failed: main player missing")
		end

		return false
	end

	if entity.aoi == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("clientRpcReplay resumeEntityServer failed: main player aoi missing entityId=%s", tostring(entity.id))
		end

		return false
	end

	if self.cObj == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("clientRpcReplay resumeEntityServer failed: rpc handler cObj missing entityId=%s", tostring(entity.id))
		end

		return false
	end

	if entity.server ~= nil and entity.server ~= self.serverProxy then
		if entity.server.channel ~= nil then
			entity.server:detachChannel()
		end

		entity.server:destroy()

		entity.server = nil
	end

	if self.serverProxy ~= nil then
		local owner = self.serverProxy.owner

		if owner ~= nil then
			if self.serverProxy.channel ~= nil and owner.server == self.serverProxy then
				owner.server:detachChannel()
			end

			if owner.server == self.serverProxy then
				owner.server = nil
			end

			self.serverProxy.owner = nil
		end

		self.serverProxy:destroy()

		self.serverProxy = nil
	end

	self.serverProxy = ServerProxy(self)

	entity:setServer(self.serverProxy)
	entity.aoi:setServer(self.cObj)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("clientRpcReplay resumeEntityServer success entityId=%s actorId=%s", tostring(entity.id), tostring(entity.actorId))
	end

	return true
end

function GateClientRpcHandler:connectResponse(respType, recoveryMode)
	assert(self.client ~= nil)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("clientRpcReplay connectResponse respType=%s recoveryMode=%s", tostring(respType), tostring(recoveryMode))
	end

	if recoveryMode == ProtobufConst.CONNECT_RECOVERY_MODE_RESUME then
		if not self:resumeEntityServer() then
			if self.client and self.client.session then
				self.client.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN)
			end

			return
		end

		if self.client.onSoulReplayResumeConnected then
			self.client:onSoulReplayResumeConnected()
		end
	end

	if self.client then
		self.client:handleConnectResponse(respType, recoveryMode)
	end
end

function GateClientRpcHandler:clientRpcSeqGap(expectedSeqId, actualSeqId)
	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("Client RPC seq gap expected=%s actual=%s", tostring(expectedSeqId), tostring(actualSeqId))
	end

	if self.client then
		self.client:onClientRpcSeqGap(expectedSeqId, actualSeqId)
	end
end

function GateClientRpcHandler:createChannelEntity(entityType, initData, entityId, lazyload, createMode)
	pg.game.seamless:seam_sys_createChannelEntity(createMode)

	local entity = EntityManager.getEntity(entityId)

	if entity then
		if entity.space then
			xpcall(entity.leaveSpace, debug.traceback, entity)
		end

		ClientUtils.safeDestroy(entity)
	end

	entity = EntityFactory.createEntity(entityType, entityId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("createChannelEntity (%s, %s) failed: unknown entityType", entityType, entityId)
		end

		return
	end

	if self.serverProxy ~= nil then
		local owner = self.serverProxy.owner

		if owner ~= nil then
			if owner.csChannel ~= nil then
				owner.server:detachChannel()
			end

			owner.server = nil
			self.serverProxy.owner = nil
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("serverProxy has no owner")
		end
	else
		self.serverProxy = ServerProxy(self)
		ClientRepo.clusterMsProxy = self.serverProxy
	end

	entity:setServer(self.serverProxy)

	local initDict

	if lazyload then
		initDict = {
			__bin_data = initData,
			__decode_type = phonestcore.LazyDecodeClient
		}
	else
		initDict = ClientRepo.protoCodec:decode(initData)
		initDict = decodeEntityInitForLogic(entityType, initDict)
	end

	entity:preInit(initDict)
	entity:init(initDict)
	entity:postInit(initDict)
	entity:onFirstCreated()
	entity:start()
	entity:onBecomePlayer()
end

function GateClientRpcHandler:recoverChannelEntity(entityId, channelId)
	local entity = EntityManager.getEntity(entityId)

	if entity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("recoverChannelEntity (%s, %s) failed: entity is not exist", entityId, channelId)
		end

		return
	end

	assert(entity.csChannel ~= nil and not entity.csChannel:isBroken())

	if entity.csChannel.id ~= channelId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("recoverChannelEntity (%s, %s) failed: channelId not match, client channelId is %s", entityId, channelId, entity.csChannel.id)
		end

		return
	end

	assert(self.serverProxy == nil)

	self.serverProxy = ServerProxy(self)
	ClientRepo.clusterMsProxy = self.serverProxy

	entity:setServer(self.serverProxy)
	entity:onBecomePlayer()
end

function GateClientRpcHandler:entityMessage(entityId, raw, index, parameters, context)
	local ownEntity = self.serverProxy.owner

	if ownEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GateClientRpcHandler has no owner in entityMessage")
		end

		return
	end

	local methodName = RpcIndex.INDEX2RPC[index]

	if methodName == nil then
		methodName = RpcIndex.RPC_INDEX2NAME[index]

		if pg.isBot and BotIgnoreRpc[methodName] then
			return
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("entityMessage entity (%s, %s) got invalid raw index (%s, %d)", ownEntity:getClassType(), ownEntity.id, raw, index, methodName)
		end

		return
	end

	local targetEntity = ownEntity

	if entityId ~= "" then
		targetEntity = ownEntity:getRealOwner(entityId)

		if targetEntity == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("entityMessage %s with targetId %s can not find targetEntity", methodName, entityId)
			end

			return
		end
	end

	local method = targetEntity[methodName]

	if method == nil or not class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("entityMessage entity(%s, %s) has no rpc method %s", targetEntity:getClassType(), targetEntity.id, methodName)
		end

		return
	end

	method(Const.ACCESSOR_SERVER, targetEntity, unpack(ClientRepo.protoCodec:decode(parameters)))
end

function GateClientRpcHandler:entityMessageV2(entityId, raw, index, context, ...)
	local ownEntity = self.serverProxy.owner

	if ownEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GateClientRpcHandler has no owner in entityMessage")
		end

		return
	end

	local methodName = RpcIndex.INDEX2RPC[index]

	if methodName == nil then
		methodName = RpcIndex.RPC_INDEX2NAME[index]

		if pg.isBot and BotIgnoreRpc[methodName] then
			return
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("entityMessage entity (%s, %s) got invalid raw index (%s, %d)", ownEntity:getClassType(), ownEntity.id, raw, index, methodName)
		end

		return
	end

	local targetEntity = ownEntity

	if entityId ~= "" then
		targetEntity = ownEntity:getRealOwner(entityId)

		if targetEntity == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("entityMessage %s with targetId %s can not find targetEntity", methodName, entityId)
			end

			return
		end
	end

	local method = targetEntity[methodName]

	if method == nil or not class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("entityMessage entity(%s, %s) has no rpc method %s", targetEntity:getClassType(), targetEntity.id, methodName)
		end

		return
	end

	method(Const.ACCESSOR_SERVER, targetEntity, ...)
end

function GateClientRpcHandler:ecsMessage(entityId, parameters, context)
	return
end

function GateClientRpcHandler:disconnectClient()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("client notified disconnect server")
	end

	if self.client and self.client.session then
		self.client.session:onDisconnect(ProtobufConst.CONNECT_RESPONSE_TYPE_NORECONNECT)
	end
end

function GateClientRpcHandler:bindSoul(gates, auth, soulMbBin)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("client notified bindSoul")
	end

	assert(self.client ~= nil)

	if self.client then
		local gatesList = ClientRepo.protoCodec:decode(gates)
		local soulInfo = {
			gates = gatesList,
			auth = auth,
			soulMbBin = soulMbBin
		}

		self.client:handleBindSoul(soulInfo)
	end
end

function GateClientRpcHandler:unbindSoul()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("client notified unbindSoul")
	end

	assert(self.client ~= nil)

	if self.client then
		self.client:handleUnbindSoul()
	end
end

function GateClientRpcHandler:sendHeartbeat()
	self:dispatchRpc("sendHeartbeat", Time.getNanosecond())
end

function GateClientRpcHandler:recvHeartbeat(time)
	local delta = Time.getNanosecond() - time

	if self.heartbeatCb ~= nil then
		self.heartbeatCb(delta)
	end
end

function GateClientRpcHandler:setHeartbeatCb(cb)
	self.heartbeatCb = cb
end

function GateClientRpcHandler:onSyncProperty(ownerid, propertyid, optype, name, value)
	local clientOwner = self.serverProxy.owner

	if clientOwner == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GateClientRpcHandler has no owner when onSyncProperty")
		end

		return
	end

	local owner = clientOwner

	if ownerid ~= "" then
		owner = clientOwner:getRealOwner(ownerid)

		if owner == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("onSyncProperty with ownerid %s can not find target", ownerid)
			end

			return
		end
	end

	if value ~= "" then
		value = ClientRepo.protoCodec:decode(value)
	end

	owner:__syncProperty__(propertyid, optype, name, value, true)
end

function GateClientRpcHandler:onSyncPropertyId(ownerid, propertyid, name, value)
	local clientOwner = self.serverProxy.owner

	if clientOwner == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GateClientRpcHandler has no owner when onSyncPropertyId")
		end

		return
	end

	local owner = clientOwner

	if ownerid ~= "" then
		owner = clientOwner:getRealOwner(ownerid)

		if owner == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("onSyncPropertyId with ownerid %s can not find target", ownerid)
			end

			return
		end
	end

	value = ClientRepo.protoCodec:decode(value)

	owner:__syncPropertyId__(propertyid, name, value)
end

function GateClientRpcHandler:onStrategySyncProperty(syncMode, ownerid, syncdata)
	local clientOwner = self.serverProxy.owner

	if clientOwner == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("GateClientRpcHandler has no owner when onStrategySyncProperty")
		end

		return
	end

	local owner = clientOwner

	if ownerid ~= "" then
		owner = clientOwner:getRealOwner(ownerid)

		if owner == nil then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("onStrategySyncProperty with ownerid %s can not find target", ownerid)
			end

			return
		end
	end

	syncdata = ClientRepo.protoCodec:decode(syncdata)

	SyncStrategyMgr.onClientSyncProperty(syncMode, owner, syncdata)
end

function GateClientRpcHandler:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true

	if self.serverProxy ~= nil then
		self.serverProxy:onSessionDisconnected()
		self.serverProxy:destroy()

		self.serverProxy = nil
		ClientRepo.clusterMsProxy = nil
	end

	self.client = nil

	GateClientRpcHandler.super.destroy(self)
end

function GateClientRpcHandler:sendMicroRequest(request)
	self.msclient.handler:dispatchRpc("sendMicroRequestV2", request.rid, request.serviceName, request.methodName, request.args, request.callerId, request.options, request.msContext.context)
end

function GateClientRpcHandler:onMicroResponse(rid, parameters, contextData, serviceId)
	local response = parameters
	local ret = response.Ret

	assert(ret ~= nil)

	if ret == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("onMicroResponse error, response invalid")
		end

		return
	end

	local retStatus = {
		status = ret[1],
		errmsg = ret[2],
		serviceId = serviceId
	}

	response.context = contextData
	response.Ret = nil

	self.serverProxy:onResponse(rid, retStatus, response)
end

function GateClientRpcHandler:onMicroPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
	self.serverProxy:onPush(orgType, targetIds, msgUUId, serviceName, methodName, parameters)
end

function GateClientRpcHandler:onHotfix(content)
	content = decompress(content)
	pg.isRuningScript = true

	local bddDataMgr = require("Core.Framework.BddDataMgr").GetInstance()

	bddDataMgr:beginPatch()
	ClientUtils.tryWithLogError(function()
		loadstring(content)()
	end)
	bddDataMgr:endPatch()

	pg.isRuningScript = false
end

function GateClientRpcHandler:onPropertyDeclare(bundleConfig, customTypeConfig)
	if CommonSwitch.CppProperty or CommonSwitch.CompactClientInitData then
		phonestcore.setPropertyConfig(bundleConfig, customTypeConfig)
	end

	if CommonSwitch.CompactClientInitData then
		local ok, bundleConfigTable, customTypeConfigTable = pcall(function()
			return ClientRepo.protoCodec:decode(bundleConfig), ClientRepo.protoCodec:decode(customTypeConfig)
		end)

		if ok then
			CompactPropertySchema.setPropertyConfig(bundleConfigTable, customTypeConfigTable)
		else
			logger:error("decode compact property declare failed: %s", tostring(bundleConfigTable))
		end
	end
end

function GateClientRpcHandler:beforeHandleBotMessage()
	local client = self.client
	local owner = client and client.owner
	local bot = owner and owner.__Bot__

	self.botMessageOwner = bot
	self.botMessageOwnershipAcquired = bot ~= nil and bot:takeOverClient() == true
end

function GateClientRpcHandler:afterHandleBotMessage()
	local bot = self.botMessageOwner
	local acquired = self.botMessageOwnershipAcquired

	self.botMessageOwner = nil
	self.botMessageOwnershipAcquired = nil

	if acquired and bot ~= nil then
		bot:freeClient()
	end
end

return GateClientRpcHandler
