-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\GateClient.lua

local phonestcore = require("phonestcore")
local class = require("Core.Framework.Class")
local ProtobufConst = require("Core.Common.ProtobufConst")
local GateClientRpcHandler = require("Core.Client.GateClientRpcHandler")
local ClientSession = require("Core.Net.ClientSession")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Version = require("Core.Common.Version")
local GateClient = class.Class("GateClient")
local ClientRepo = require("Core.Client.ClientRepo")
local CLIENT_INIT = 1
local CLIENT_CONNECTING = 2
local CLIENT_RECONNECTING = 3
local CLIENT_CONNECTED = 4
local CLIENT_DISCONNECTED = 5
local CLIENT_CLOSED = 6

function GateClient:ctor(owner, ip, port, deviceid, isSoul, config, useKcp)
	self.owner = owner
	self.ip = ip
	self.port = port
	self.status = CLIENT_INIT
	self.session = nil
	self.soulFlag = isSoul
	self.reconnectInfo = nil
	self.useTcpRetrying = false
	self.connectCb = nil
	self.disconnectCb = nil
	self.bindInfo = nil
	self.connectAction = nil
	self.onlineInfoWithBinding = nil
	self.bindSoulHandler = nil
	self.unbindSoulHandler = nil
	self.config = config or {}
	self.useKcp = useKcp or false
	self.handler = GateClientRpcHandler(self, deviceid)
	self.handlerType = phonestcore.HandlerTypeGateClient
	ClientRepo.choiceSoulGate = {
		ip,
		port
	}
end

function GateClient:getClientRpcSeqId(reqType)
	if self.soulFlag and reqType == ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL and self.owner and self.owner:consumeLoseConnectTestFullSync() then
		return 0, true
	end

	if self.handler and self.handler.getClientRpcSeqId then
		local seqId = self.handler:getClientRpcSeqId()

		if seqId and seqId > 0 then
			return seqId
		end
	end

	if self.owner and self.owner.getClientRpcSeqId then
		return self.owner:getClientRpcSeqId(self.soulFlag)
	end

	return 0
end

function GateClient:updateClientRpcSeqId(seqId)
	self.clientRpcSeqId = seqId or 0

	if self.owner and self.owner.updateClientRpcSeqId then
		self.owner:updateClientRpcSeqId(self.clientRpcSeqId, self.soulFlag)
	end
end

function GateClient:onClientRpcSeqGap(expectedSeqId, actualSeqId)
	if self.owner and self.owner.onClientRpcSeqGap then
		self.owner:onClientRpcSeqGap(expectedSeqId, actualSeqId, self.soulFlag)
	end
end

function GateClient:onSoulReplayResumeConnected()
	if self.soulFlag and self.owner and self.owner.onSoulReplayResumeConnected then
		self.owner:onSoulReplayResumeConnected()
	end
end

function GateClient:isSoulClient()
	return self.soulFlag
end

function GateClient:connect(action, bindInfo)
	assert(self.status == CLIENT_INIT)

	self.status = CLIENT_CONNECTING
	self.connectAction = action
	self.bindInfo = bindInfo

	self:_createSession()
	self.session:connect()
end

function GateClient:close()
	if self.status == CLIENT_CLOSED then
		return
	end

	if self.handler ~= nil then
		self.handler:destroy()

		self.handler = nil
	end

	if self.session ~= nil then
		self.session:unregAll()
		self.session:destroy()

		self.session = nil
	end

	self:unregAll()

	self.status = CLIENT_CLOSED
	self.reconnectInfo = nil
	self.connectAction = nil
	self.useTcpRetrying = false
end

function GateClient:_createSession()
	if self.session ~= nil then
		self.session:unregAll()
		self.session:destroy()
	end

	self.session = ClientSession(self.ip, self.port, self.handler, self.handlerType, self.useKcp)

	self.session:regConnectCb(CallbackHandler(self, "SessionConnectCallback"))
	self.session:regDisconnectCb(CallbackHandler(self, "SessionDisconnectCallback"))
end

function GateClient:SessionConnectCallback()
	assert(self.status == CLIENT_CONNECTING or self.status == CLIENT_RECONNECTING)

	self.status = CLIENT_CONNECTED

	if self.useTcpRetrying == true then
		self.useTcpRetrying = false

		self.owner.logger:warn("kcp is forbidden, switch to tcp and connected to gate %s:%s", self.ip, self.port)
	end

	if self.config.enableEncrypt then
		self.handler:handshake(self.config.pubKeyData)
	else
		self:onRpcSessionEstablished()
	end
end

function GateClient:onConfirmEncryptKeyAck()
	self:onRpcSessionEstablished()

	if self.owner then
		if not self.owner.startTTL then
			self.owner.logger:error("GateClient:onConfirmEncryptKeyAck: owner.startTTL is not found, owner=%s", self.owner.className)

			return
		end

		self.owner:startTTL()
	end
end

function GateClient:onRpcSessionEstablished()
	assert(self.connectAction ~= nil)

	local codeVersion = Version.ver .. "_" .. phonestcore.version()
	local auth, mb

	if self:isSoulClient() then
		assert(self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_BIND_SOUL or self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL)

		auth, mb = self.bindInfo.auth, self.bindInfo.mb
	else
		if self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_LATENCY_DETECT then
			if self.connectCb ~= nil then
				self.connectCb()
			end

			return
		end

		if self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_NEW_CONNECTION then
			auth, mb = "", ""
		elseif self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_RE_CONNECTION then
			local reconnectInfoDict = ClientRepo.protoCodec:decode(self.reconnectInfo)

			auth, mb = reconnectInfoDict.auth, reconnectInfoDict.mb
		else
			assert(self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_BIND_ACCOUNT or self.connectAction == ProtobufConst.CONNECT_REQUEST_TYPE_BIND_AVATAR)
			assert(self.bindInfo ~= nil)

			auth, mb = self.bindInfo.auth, self.bindInfo.mb
		end
	end

	self.handler:connectServer(self.connectAction, auth, mb, codeVersion)
end

function GateClient:SessionDisconnectCallback(connType)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE and self.useKcp and self.useTcpRetrying == false then
		self.owner.logger:warn("use kcp connect gate %s:%s no response, switch to tcp try again...", self.ip, self.port)

		self.useTcpRetrying = true
		self.useKcp = false

		self:_createSession()

		self.useKcp = true

		self.session:connect()

		return
	end

	if self.soulFlag then
		local seqId = self:getClientRpcSeqId()

		if seqId > 0 then
			self:updateClientRpcSeqId(seqId)
		end
	end

	self.status = CLIENT_DISCONNECTED

	if self.disconnectCb ~= nil then
		self.disconnectCb(connType)
	end

	self:close()
end

function GateClient:handleConnectResponse(respType, recoveryMode)
	recoveryMode = recoveryMode or ProtobufConst.CONNECT_RECOVERY_MODE_FULLSYNC

	if self.soulFlag and recoveryMode == ProtobufConst.CONNECT_RECOVERY_MODE_FULLSYNC then
		self:updateClientRpcSeqId(0)
	end

	if respType == ProtobufConst.CONNECT_RESPONSE_TYPE_BUSY or respType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED or respType == ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTREFUSED or respType == ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN or respType == ProtobufConst.CONNECT_RESPONSE_TYPE_MAX_CONNECTIONS then
		if self.disconnectCb ~= nil then
			self.disconnectCb(respType)
		end

		self:close()
	elseif (respType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED or respType == ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTED) and self.connectCb ~= nil then
		self.connectCb(respType, self.onlineInfoWithBinding)
	end
end

function GateClient:handleBindSoul(soulInfo)
	if self.bindSoulHandler then
		self.bindSoulHandler(soulInfo)
	end
end

function GateClient:handleUnbindSoul()
	if self.unbindSoulHandler then
		self.unbindSoulHandler()
	end
end

function GateClient:regConnectCb(cb)
	self.connectCb = cb
end

function GateClient:regDisconnectCb(cb)
	self.disconnectCb = cb
end

function GateClient:regBindSoulHandler(handler)
	self.bindSoulHandler = handler
end

function GateClient:regUnbindSoulHandler(handler)
	self.unbindSoulHandler = handler
end

function GateClient:unregAll()
	self.connectCb = nil
	self.disconnectCb = nil
	self.bindSoulHandler = nil
	self.unbindSoulHandler = nil
end

return GateClient
