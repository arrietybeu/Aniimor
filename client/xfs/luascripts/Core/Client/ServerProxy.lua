-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\ServerProxy.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local ClientRepo = require("Core.Client.ClientRepo")
local Const = require("Core.Common.Const")
local RpcMethod = require("Core.Common.RpcMethod")
local SafeCallback = require("Core.Framework.SafeCallback")
local MsServiceManager = require("Core.MicroService.MsServiceManager")
local RpcIndex = require("Core.Common.RpcIndex")
local CommonSwitch = require("Common.CommonSwitch")
local RpcSendValidator = require("Core.Common.RpcSendValidator")
local ServerProxy = class.Class("ServerProxy")
local MsServiceComponent = require("Core.MicroService.Components.MsServiceComponent")

class.AddComponents(ServerProxy, {
	MsServiceComponent
})

function ServerProxy:ctor(stub)
	self.stub = stub
	self.owner = nil
	self.channel = nil
	self.connected = true
	self.serviceMgr = MsServiceManager(self)
	self.logger = LoggerManager.getLogger(self:getClassType())
end

function ServerProxy:setOwner(owner)
	self.owner = owner
end

function ServerProxy:attachChannel(channel)
	assert(self.channel == nil)
	channel:updateRpcHandler(self.stub.cObj, self.stub.client.session.handlerId)

	self.channel = channel
end

function ServerProxy:detachChannel()
	assert(self.channel ~= nil)
	self.channel:clearRpcHandler()

	self.channel = nil
end

function ServerProxy:sendGateHeartbeat()
	self.stub:sendHeartbeat()
end

function ServerProxy:setGateHeartbeatCb(cb)
	self.stub:setHeartbeatCb(cb)
end

function ServerProxy:serverMsg(name, ...)
	if self.owner == nil then
		return
	end

	if not RpcSendValidator.validate(name, ...) then
		return
	end

	local index = RpcIndex.sendRpcIndex(name)
	local context = ""

	self.stub:dispatchRpc("sendEntityMessageV2", "", "", index, 0, context, ...)
end

function ServerProxy:serverMsgWithCallback(callbackId, name, ...)
	if self.owner == nil then
		return
	end

	if not RpcSendValidator.validate(name, ...) then
		return
	end

	local context = ""
	local index = RpcIndex.sendRpcIndex(name)

	self.stub:dispatchRpc("sendEntityMessageV2", "", "", index, callbackId, context, ...)
end

function ServerProxy:sendChannelMsg(dummyLocation, chanMsg, context)
	if context == nil then
		context = {}
	end

	self.stub:dispatchRpc("sendChannelMessage", ClientRepo.protoCodec:encode(chanMsg), ClientRepo.protoCodec:encode(context))
end

function ServerProxy:onChannelRequest(chanCtx, name, parameters)
	local method = self.owner[name]

	if method == nil or not class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s onChannelRequest but has no rpc method %s", self.owner:repr(), name)
		end

		return
	end

	method(Const.ACCESSOR_CHANNEL, self.owner, chanCtx, unpack(parameters))
end

function ServerProxy:onChannelResponse(callback, name, parameters)
	SafeCallback(callback, unpack(parameters))
end

function ServerProxy:onChannelBroken(channel)
	return
end

function ServerProxy:onSessionDisconnected()
	if self.owner then
		assert(self.owner.server == self)

		if self.owner.server == self then
			self.owner:onLoseServer()
		end
	end
end

function ServerProxy:sendMicroRequest(request)
	self.stub:sendMicroRequest(request)
end

function ServerProxy:destroy()
	if self.owner ~= nil then
		if self.owner.server == self then
			self.owner.server = nil
		end

		self.owner = nil
	end

	self.stub = nil
	self.channel = nil

	self.serviceMgr:destroy()

	self.serviceMgr = nil
end

return ServerProxy
