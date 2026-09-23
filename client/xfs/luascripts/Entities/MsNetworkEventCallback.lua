-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\MsNetworkEventCallback.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ProtobufConst = require("Core.Common.ProtobufConst")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local MsNetworkEventCallback = class.Class("MsNetworkEventCallback")
local RECONNECT_RETRY = 10
local RECONNECT_INTERVAL = 2

local function showLoginMsGateFailedTip()
	ClientUtils.showBubbleMessageRaw(pg.getGameString("LOGIN_MSGATE_CONNECT_FAILED"))

	return true
end

function MsNetworkEventCallback:ctor()
	self.logger = LoggerManager.getLogger(self:getClassType())
	self.msGateList = {}
	self.msGateAddr = nil
	self.msGateIndex = 0
	self.reconnectTimes = 0
	self.readyCb = nil
	self.needShowDisconnectUI = false
end

function MsNetworkEventCallback:regCallbacksTo(msProxy)
	self.msProxy = msProxy

	self.msProxy:regConnectCb(CallbackHandler(self, "onConnectCallback"))
	self.msProxy:regDisconnectCb(CallbackHandler(self, "onDisconnectCallback"))
end

function MsNetworkEventCallback:start(msGateList, readyCb)
	self.msGateList = msGateList
	self.msGateIndex = 0

	self:selectNextMsGate()

	self.readyCb = readyCb

	self.msProxy:start(self.msGateAddr)
end

function MsNetworkEventCallback:destroy()
	self.msGateList = {}
	self.msGateAddr = nil
	self.msGateIndex = 0
	self.reconnectTimes = 0

	self.msProxy:destroy()

	if self.timer ~= nil then
		TimerManager.removeTimer(self.timer)

		self.timer = nil
	end
end

function MsNetworkEventCallback:onTraceback(ex)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("MsNetworkEventCallback:onTraceback " .. ex)
	end
end

function MsNetworkEventCallback:onConnectCallback(connType)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED then
		-- block empty
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTED then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("MsNetworkEventCallback:onConnect: " .. "Reconnected")
		end
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("MsNetworkEventCallback:onConnect: " .. "Unknown")
	end

	if self.readyCb ~= nil then
		self.readyCb()
	end

	self.reconnectTimes = 0
	self.needShowDisconnectUI = true
end

function MsNetworkEventCallback:onDisconnectCallback(connType)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("MsNetworkEventCallback:onDisconnect: " .. "NormalBroken")
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("MsNetworkEventCallback:onDisconnect: " .. "NoResponse")
		end

		ClientUtils.checkNetwork()
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORECONNECT then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("MsNetworkEventCallback:onDisconnect: " .. "NoReconnect")
		end

		ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.MsNoReconnect)

		return
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("MsNetworkEventCallback:onDisconnect: " .. "Unknown")
	end

	self.reconnectTimes = self.reconnectTimes + 1

	if self.reconnectTimes >= RECONNECT_RETRY and not self.msProxy:isExtraConnect() then
		if self.needShowDisconnectUI then
			self:onReconnectFailed()

			self.needShowDisconnectUI = false
			self.reconnectTimes = 0

			return
		else
			ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.MsGateConnectExtra)

			self.reconnectTimes = 0

			return
		end
	end

	if self.timer ~= nil then
		TimerManager.removeTimer(self.timer)

		self.timer = nil
	end

	self.timer = TimerManager.addTimer(RECONNECT_INTERVAL, CallbackHandler(self, "reconnect"))
end

function MsNetworkEventCallback:reconnect()
	self:selectNextMsGate()
	self.msProxy:start(self.msGateAddr)
end

function MsNetworkEventCallback:onReconnectFailed()
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("reconnect to msGate %s failed, reconnectTimes = %s", self.msGateAddr, self.reconnectTimes)
	end

	ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.MsGateDisconnect)
end

function MsNetworkEventCallback:selectNextMsGate()
	if self.msGateList == nil or #self.msGateList == 0 then
		self.msGateAddr = nil

		return
	end

	self.msGateIndex = self.msGateIndex + 1

	if self.msGateIndex > #self.msGateList then
		self.msGateIndex = 1
	end

	self.msGateAddr = self.msGateList[self.msGateIndex]
end

function MsNetworkEventCallback:isConnected()
	if self.msProxy and self.msProxy:isConnected() then
		return true
	end

	return false
end

function MsNetworkEventCallback:getTTL()
	if self.msProxy == nil then
		return nil
	end

	return self.msProxy:getTTL()
end

return MsNetworkEventCallback
