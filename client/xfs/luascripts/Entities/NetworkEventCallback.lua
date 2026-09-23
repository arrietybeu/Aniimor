-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\NetworkEventCallback.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ProtobufConst = require("Core.Common.ProtobufConst")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientRepo = require("Core.Client.ClientRepo")
local GlobalData = require("Core.Client.GlobalData")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientUtils = require("Utils.ClientUtils")
local StringEx = require("Core.Framework.String")
local lume = require("Core.Common.lume")
local ClientConst = require("Const.ClientConst")
local NetworkEventCallback = class.Class("NetworkEventCallback")

local function showLoginConnectFailedTip(textKey)
	local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

	if loginCtrl and loginCtrl.isInLogin and loginCtrl.showLoginFailedTip then
		loginCtrl:showLoginFailedTip(textKey)

		return true
	end

	return false
end

function NetworkEventCallback:ctor()
	self.logger = LoggerManager.getLogger(self:getClassType())
	self.netHandler = nil
	self.gateList = {}
	self.gateAddr = nil
	self.connectCb = nil
	self.reconnectCb = nil
end

function NetworkEventCallback:destroy()
	self.logger = nil

	self.netHandler:close()

	self.gateList = {}
	self.gateAddr = nil
	self.connectCb = nil
	self.reconnectCb = nil
end

function NetworkEventCallback:randomGate()
	self.gateAddr = lume.randomchoice(self.gateList)
end

function NetworkEventCallback:onTraceback(ex)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("NetworkEventCallback:onTraceback " .. debug.traceback(ex))
	end
end

function NetworkEventCallback:onConnectCallback(connType, onlineInfo)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED then
		if self.connectCb ~= nil then
			self.connectCb(onlineInfo)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTED then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onConnect: " .. "Reconnected")
		end

		if self.reconnectCb ~= nil then
			self.reconnectCb()
		end
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("NetworkEventCallback:onConnect: " .. "Unknown")
	end
end

function NetworkEventCallback:onDisconnectCallback(connType)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "NormalBroken")
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "ConnectRefused")
		end

		if not showLoginConnectFailedTip("LOGIN_SERVER_CONNECT_REFUSED") then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("ACCOUNT_ERROR"), 3)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTREFUSED then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "ReconnectRefused")
		end

		ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.ReconnectRefused)
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "Forbidden")
		end

		if not showLoginConnectFailedTip("LOGIN_SERVER_FORBIDDEN") then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("ACCOUNT_ERROR"), 3)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_MAX_CONNECTIONS then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "MaxConnections")
		end

		if not showLoginConnectFailedTip("LOGIN_SERVER_BUSY") then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_UNRESPONSIVE"), 3)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_BUSY then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "Busy")
		end

		if not showLoginConnectFailedTip("LOGIN_SERVER_BUSY") then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_UNRESPONSIVE"), 3)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "NoResponse")
		end

		if not showLoginConnectFailedTip("LOGIN_SERVER_CONNECT_FAILED") then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_UNRESPONSIVE"), 3)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORECONNECT then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:onDisconnect: " .. "NoReconnect")
		end

		ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.NoReconnect)
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("NetworkEventCallback:onDisconnect: " .. "Unknown")
	end
end

function NetworkEventCallback:onBindSoulSucceed()
	if GlobalData.Player then
		GlobalData.Player:onBindSoulSucceed()
	end
end

function NetworkEventCallback:onBindSoulFailed(connType)
	if connType == ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:bindSoulFailed: ConnectRefused, connType=%s", connType)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:bindSoulFailed: NoResponse, connType=%s", connType)
		end
	elseif connType == ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("NetworkEventCallback:bindSoulFailed: forbid, connType=%s", connType)
		end

		ClientUtils.showNetworkForbid()

		return
	elseif LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("NetworkEventCallback:bindSoulFailed: Unknown, connType=%s", connType)
	end

	ClientUtils.showNetworkDisconnect(ClientConst.NETWORK_DISCONNECT_CODE.BindSoulFail)
end

function NetworkEventCallback:checkSoulConnected()
	if self.netHandler then
		return self.netHandler:isSoulConnected()
	else
		return false
	end
end

function NetworkEventCallback:regCallbacksTo(netHandler)
	self.netHandler = netHandler

	netHandler:regConnectCb(CallbackHandler(self, "onConnectCallback"))
	netHandler:regDisconnectCb(CallbackHandler(self, "onDisconnectCallback"))
	netHandler:regBindSoulSucceedCb(CallbackHandler(self, "onBindSoulSucceed"))
	netHandler:regBindSoulFailedCb(CallbackHandler(self, "onBindSoulFailed"))
end

function NetworkEventCallback:getTTL()
	if self.netHandler == nil then
		return nil
	end

	return self.netHandler:getTTL()
end

return NetworkEventCallback
