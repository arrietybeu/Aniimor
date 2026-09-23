-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\MsProxy.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ProtoCodec = require("Core.Common.ProtoCodec")
local StringEx = require("Core.Framework.String")
local MsServiceManager = require("Core.MicroService.MsServiceManager")
local LoggerManager = require("Core.Log.LoggerManager")
local MsClient = require("Core.Client.MsClient")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TimerManager = require("Core.Timer.TimerManager")
local Switch = require("Core.Common.Switch")
local GlobalData = require("Core.Client.GlobalData")
local ClientRepo = require("Core.Client.ClientRepo")
local CommonSwitch = require("Common.CommonSwitch")
local logger = LoggerManager.getLogger("MsProxy")
local MsProxy = class.Class("MsProxy")
local MsServiceComponent = require("Core.MicroService.Components.MsServiceComponent")

class.AddComponents(MsProxy, {
	MsServiceComponent
})

function MsProxy:ctor()
	self.codec = ProtoCodec()
	self.connected = false
	self.running = false
	self.msGateAddr = ""
	self.serviceMgr = MsServiceManager(self)
	self.msclient = nil
	self.connectCb = nil
	self.disconnectCb = nil
	self._getGateInfoTimer = nil
	self._lastTTL = nil
	self._TTL = 0
	self._TTLTimer = nil
end

function MsProxy:start(msGateAddr)
	if msGateAddr ~= nil then
		self.msGateAddr = msGateAddr

		local ip, port = unpack(StringEx.split(msGateAddr, ":"))

		self:_connect(ip, port)

		self.running = true

		if not self:isExtraConnect() then
			self:_startGetGateInfoTimer()
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("start without valid msGateAddr")
	end
end

function MsProxy:isConnected()
	return self.connected
end

function MsProxy:_connect(ip, port)
	self:_createMsClient(ip, port)
	self.msclient:connect()
end

function MsProxy:getClient()
	return self.msclient
end

function MsProxy:_createMsClient(ip, port)
	if self.msclient ~= nil then
		self.msclient:close()

		self.connected = false
	end

	self.msclient = MsClient(self, ip, port, self.config)

	local function onConnect(connType)
		self.connected = true

		if self.connectCb ~= nil then
			self.connectCb(connType)
		end

		self.serviceMgr:onConnected()
	end

	local function onDisconnect(connType)
		self.connected = false

		if self.disconnectCb ~= nil then
			self.disconnectCb(connType)
		end

		self:_stopTTL()
	end

	self.msclient:regConnectCb(onConnect)
	self.msclient:regDisconnectCb(onDisconnect)
	self.msclient.handler:setHeartbeatCb(CallbackHandler(self, "_onHeartbeat"))
end

function MsProxy:sendMicroRequest(request)
	if self.msclient == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("sendMicroRequest %s-%s failed", request.serviceName, request.methodName)
		end

		return
	end

	self.msclient.handler:dispatchRpc("sendMicroRequestV2", request.rid, request.serviceName, request.methodName, request.args, request.callerId, request.options, request.msContext.context)
end

function MsProxy:close()
	if not self.running then
		return
	end

	self.running = false

	self.msclient:close()

	self.msclient = nil
	self.connected = false

	self:_stopTTL()
	self:_stopGetGateInfoTimer()
end

function MsProxy:destroy()
	self:_stopGetGateInfoTimer()
	self:close()

	self.handler = nil

	if self.serviceMgr ~= nil then
		self.serviceMgr:destroy()

		self.serviceMgr = nil
	end
end

function MsProxy:regConnectCb(cb)
	self.connectCb = cb
end

function MsProxy:regDisconnectCb(cb)
	self.disconnectCb = cb
end

function MsProxy:finishedGetGateInfo()
	self:_stopGetGateInfoTimer()
end

function MsProxy:_startGetGateInfoTimer()
	self:_stopGetGateInfoTimer()

	self._getGateInfoTimer = TimerManager.addRepeatTimer(10, CallbackHandler(self, "_getGateInfoTimeout"))
end

function MsProxy:_stopGetGateInfoTimer()
	if self._getGateInfoTimer then
		TimerManager.removeTimer(self._getGateInfoTimer)

		self._getGateInfoTimer = nil
	end
end

function MsProxy:_getGateInfoTimeout()
	self:getGateInfo(CallbackHandler(self, "_getGateInfoCb"))
end

function MsProxy:_getGateInfoCb(retStatus, response)
	if retStatus.status then
		self:_stopGetGateInfoTimer()
		logger:info("getGateInfo to micro-service gate succeed: %s", self.msGateAddr)

		if not self:isExtraConnect() then
			local oldSessionId = GlobalData.GlobalGateSessionId

			GlobalData.GlobalGateId = response.GateId
			GlobalData.GlobalGateSessionId = response.SessionId

			if oldSessionId ~= GlobalData.GlobalGateSessionId and self.msclient and self.msclient.handler.isServiceLogin and GlobalData.UserName ~= nil and GlobalData.UserName ~= "" then
				local connInfo = {
					sessionId = GlobalData.GlobalGateSessionId,
					gateId = GlobalData.GlobalGateId
				}

				self:callService("RoleService", "CS_ClientConnInfoChanged", {
					GlobalData.UserName,
					ClientRepo.netHandler.connectToken,
					connInfo
				}, nil, {
					hint = GlobalData.UserName
				})

				if GlobalData.Player then
					GlobalData.Player:updateMsGateInfo(false)
				end
			end

			GlobalData.LastBindMsUid = nil

			if GlobalData.Player then
				GlobalData.Player:bindGlobalMsGate()
			end
		end
	else
		logger:error("getGateInfo to micro-service gate failed: %s", self.msGateAddr)
	end
end

function MsProxy:startTTL()
	self:_stopTTL()

	if not Switch.EnableTTL then
		return
	end

	self._TTLTimer = TimerManager.addRepeatTimer(1, CallbackHandler(self, "_onSendHeartbeat"))
end

function MsProxy:_stopTTL()
	if self._TTLTimer ~= nil then
		TimerManager.removeTimer(self._TTLTimer)

		self._TTLTimer = nil
	end

	self._lastTTL = nil
	self._TTL = 0
end

function MsProxy:_onSendHeartbeat()
	if self.msclient ~= nil then
		self.msclient.handler:sendHeartbeat()
	end
end

function MsProxy:_onHeartbeat(delta)
	if self._lastTTL == nil then
		self._TTL = delta
	else
		self._TTL = self._lastTTL * 0.2 + delta * 0.8
	end
end

function MsProxy:getTTL()
	return self._TTL
end

return MsProxy
