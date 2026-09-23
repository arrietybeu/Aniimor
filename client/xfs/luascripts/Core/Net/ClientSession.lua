-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\ClientSession.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local phonestcore = require("phonestcore")
local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local ProtobufConst = require("Core.Common.ProtobufConst")
local TcpClient = require("Core.Net.TcpClient")
local KcpClient = require("Core.Net.KcpClient")
local HandlerManager = require("Core.Net.HandlerManager")
local CallbackManager = require("Core.Net.CallbackManager")
local TimerManager = require("Core.Timer.TimerManager")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientSession = class.Class("ClientSession")
local logger = LoggerManager.getLogger("ClientSession")
local STATUS_INIT = 0
local STATUS_CONNECTING = 1
local STATUS_CONNECT = 2
local STATUS_CLOSE = 3
local CONNECTING_TIMEOUT = 2

function ClientSession:ctor(ip, port, handler, handlerType, useKcp)
	self.ip = ip
	self.port = port
	self.handler = handler
	self.handlerId = IDManager.genB64ID()
	useKcp = useKcp or false

	if useKcp then
		self.client = KcpClient(handlerType, self.handlerId)
	else
		self.client = TcpClient(handlerType, self.handlerId)
	end

	self.status = STATUS_INIT
	self.sucID = IDManager.genB64ID()
	self.failID = IDManager.genB64ID()
	self.connectCb = nil
	self.disconnectCb = nil
	self.timer = nil
	self.destroyed = false
end

function ClientSession:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true

	if self.client then
		self.client:destroy()

		self.client = nil
	end

	CallbackManager.unRegisterHandler(self.sucID)
	CallbackManager.unRegisterHandler(self.failID)
	HandlerManager.unRegisterHandler(self.handlerId)
	self:_clrTimer()
end

function ClientSession:connect()
	assert(self.status == STATUS_INIT)

	self.status = STATUS_CONNECTING

	local function sucHandler()
		assert(self.status == STATUS_CONNECTING)
		self:onConnect()
		CallbackManager.unRegisterHandler(self.sucID)
	end

	local function failhandler()
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("%s failHandler ", self:toString())
		end

		assert(self.status == STATUS_CONNECTING)
		self:onConnectFail()
		CallbackManager.unRegisterHandler(self.failID)
	end

	CallbackManager.registerHandler(self.sucID, sucHandler)
	CallbackManager.registerHandler(self.failID, failhandler)

	if pg.component == "client" then
		local ClientRepo = require("Core.Client.ClientRepo")

		if ClientRepo.isLoseConnectTestNetworkBlocked then
			self:_addTimer()

			return
		end
	end

	self.client:connect(self.ip, self.port, self.sucID, self.failID)
	self:_addTimer()
end

function ClientSession:onConnect()
	assert(self.status == STATUS_CONNECTING)
	self:_clrTimer()

	self.status = STATUS_CONNECT

	local function handlerFunc(cObj, mappingObj)
		HandlerManager.bindHandler(self.handler, mappingObj)
		self.handler:setCobj(cObj)

		if self.connectCb ~= nil then
			self.connectCb()
		end
	end

	assert(HandlerManager.debugGetHandler(self.handlerId) == nil)
	HandlerManager.registerHandler(self.handlerId, handlerFunc)
end

function ClientSession:onConnectFail()
	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("%s onConnectFail", self:toString())
	end

	assert(self.status == STATUS_CONNECTING)
	self:_clrTimer()

	self.status = STATUS_CLOSE

	if self.disconnectCb ~= nil then
		self.disconnectCb(ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE)
	end

	self:destroy()
end

function ClientSession:onDisconnect(connType)
	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("%s onDisconnect", self:toString())
	end

	if self.status ~= STATUS_CONNECT then
		return
	end

	self:_clrTimer()

	self.status = STATUS_CLOSE

	if self.disconnectCb ~= nil then
		self.disconnectCb(connType)
	end

	self:destroy()
end

function ClientSession:_clrTimer()
	if self.timer ~= nil then
		TimerManager.removeTimer(self.timer)

		self.timer = nil
	end
end

function ClientSession:_addTimer()
	local function checkConnection()
		assert(self.status == STATUS_CONNECTING)
		self:onConnectFail()
	end

	self:_clrTimer()

	self.timer = TimerManager.addTimer(CONNECTING_TIMEOUT, checkConnection)
end

function ClientSession:regConnectCb(cb)
	self.connectCb = cb
end

function ClientSession:regDisconnectCb(cb)
	self.disconnectCb = cb
end

function ClientSession:unregAll()
	self.connectCb = nil
	self.disconnectCb = nil
end

return ClientSession
