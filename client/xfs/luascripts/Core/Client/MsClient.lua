-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\MsClient.lua

local class = require("Core.Framework.Class")
local phonestcore = require("phonestcore")
local ProtobufConst = require("Core.Common.ProtobufConst")
local ClientSession = require("Core.Net.ClientSession")
local MsGateClientRpcHandler = require("Core.Client.MsGateClientRpcHandler")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientRepo = require("Core.Client.ClientRepo")
local MsClient = class.Class("MsClient")

function MsClient:ctor(msProxy, ip, port, config)
	self.msProxy = msProxy
	self.ip = ip
	self.port = port
	self.session = nil
	self.config = config or {}
	self.handlerType = phonestcore.HandlerTypeGateClient
	self.handler = MsGateClientRpcHandler(self)
	self.connectCb = nil
	self.disconnectCb = nil
	self.isHandshaking = false
	self.handshakeTimer = nil
	ClientRepo.choiceMsGate = {
		ip,
		port
	}
end

function MsClient:connect()
	self:_createSession()
	self.session:connect()
end

function MsClient:_createSession()
	if self.session ~= nil then
		self.session:unregAll()
		self.session:destroy()
	end

	self.session = ClientSession(self.ip, self.port, self.handler, self.handlerType)

	self.session:regConnectCb(CallbackHandler(self, "SessionConnectCallback"))
	self.session:regDisconnectCb(CallbackHandler(self, "SessionDisconnectCallback"))
end

function MsClient:_onHandshakeTimeout()
	self.handshakeTimer = nil
	self.isHandshaking = false

	local disconnectCb = self.disconnectCb

	self:close()

	if disconnectCb ~= nil then
		disconnectCb(ProtobufConst.CONNECT_RESPONSE_TYPE_HANDSHAKE_FAILED)
	end
end

function MsClient:addHandshakeTimer()
	self:removeHandshakeTimer()

	self.handshakeTimer = TimerManager.addTimer(20, CallbackHandler(self, "_onHandshakeTimeout"))
end

function MsClient:removeHandshakeTimer()
	if self.handshakeTimer ~= nil then
		TimerManager.removeTimer(self.handshakeTimer)

		self.handshakeTimer = nil
	end
end

function MsClient:SessionConnectCallback()
	if self.config.enableMsEncrypt then
		self.handler:handshake(self.config.msPubKeyData)

		self.isHandshaking = true

		self:addHandshakeTimer()
	else
		self:callConnectCb()
	end
end

function MsClient:callConnectCb()
	self:removeHandshakeTimer()

	self.isHandshaking = false

	if self.connectCb ~= nil then
		self.connectCb(ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED)
	end
end

function MsClient:SessionDisconnectCallback(connType)
	if self.isHandshaking and connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN then
		connType = ProtobufConst.CONNECT_RESPONSE_TYPE_HANDSHAKE_FAILED
	end

	if self.disconnectCb ~= nil then
		self.disconnectCb(connType)
	end

	self:close()
end

function MsClient:close()
	if self.session ~= nil then
		self.session:unregAll()
		self.session:destroy()

		self.session = nil
	end

	if self.handler ~= nil then
		self.handler:destroy()

		self.handler = nil
	end

	self:unregAll()
	self:removeHandshakeTimer()

	self.isHandshaking = false
end

function MsClient:regConnectCb(cb)
	self.connectCb = cb
end

function MsClient:regDisconnectCb(cb)
	self.disconnectCb = cb
end

function MsClient:unregAll()
	self.connectCb = nil
	self.disconnectCb = nil
end

return MsClient
