-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsServiceManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MsRequest = require("Core.MicroService.MsRequest")
local MsIdGenerator = require("Core.MicroService.MsIdGenerator")
local LoggerManager = require("Core.Log.LoggerManager")
local MsServiceManager = class.Class("MsServiceManager")
local Queue = require("Core.Framework.Queue")
local Time = require("Core.Common.Time")
local CallbackHandler = require("Core.Common.CallbackHandler")
local SafeCallback = require("Core.Framework.SafeCallback")
local TimerWheel = require("Core.Timer.TimerWheel")
local Const = require("Core.Common.Const")
local CommonRepo = require("Core.Common.CommonRepo")
local GameVersion = require("Common.GameVersion")
local Utils = require("Common.Utils.Utils")
local RpcMethod = require("Core.Common.RpcMethod")
local logger = LoggerManager.getLogger("MsServiceManager")
local MsCallRateLimiter

local function getClientRateLimiter()
	if pg == nil or pg.component ~= "client" then
		return nil
	end

	if MsCallRateLimiter == nil then
		MsCallRateLimiter = require("Core.MicroService.MsCallRateLimiter")
	end

	return MsCallRateLimiter
end

function MsServiceManager:ctor(msProxy)
	self.msProxy = msProxy
	self.rid2request = {}
	self.idGenerator = MsIdGenerator()
	self.pushEndpoints = {}
	self.pendingMax = 1
	self.pendingRequestQueue = Queue(self.pendingMax)
	self.timerWheel = TimerWheel(0.1, CallbackHandler(self, "onCheckTimeout"), 100)
end

function MsServiceManager:toRequest(serviceName, methodName, args, callback, options)
	if type(args) ~= "table" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("callService %s failed: args must be table list", serviceName)
		end

		return
	end

	local rid = 0

	if callback ~= nil then
		rid = self.idGenerator:next()
	elseif options ~= nil and options.callbackInfo ~= nil and options.timeout ~= nil then
		rid = self.idGenerator:next()
		options.callbackInfo.rid = rid
	end

	local request = MsRequest(rid, serviceName, methodName, args, callback, options, CommonRepo.msContext)

	return request
end

function MsServiceManager:sendRequest(request, curTime)
	if request == nil then
		return
	end

	if curTime == nil or request.expireAt == 0 or curTime <= request.expireAt then
		self.msProxy:sendMicroRequest(request)
	end
end

function MsServiceManager:pendingMsg(request)
	if request == nil then
		return
	end

	local overflowRequest

	if self.pendingRequestQueue:size() >= self.pendingMax then
		overflowRequest = self.pendingRequestQueue:deQueue()
	end

	self.pendingRequestQueue:enQueue(request)

	if overflowRequest ~= nil and overflowRequest.rid ~= 0 then
		self.timerWheel:remove(overflowRequest.rid)
		self:onRequestTimeout(overflowRequest.rid)
	end
end

function MsServiceManager:callService(serviceName, methodName, args, callback, options)
	local request = self:toRequest(serviceName, methodName, args, callback, options)

	if not request then
		return
	end

	local rateLimiter = getClientRateLimiter()

	if rateLimiter ~= nil then
		local allowed, retStatus = rateLimiter.tryAcquire(serviceName, methodName, options)

		if not allowed then
			request:onResponse(retStatus)

			return
		end
	end

	self:addRequestCallback(request)

	if not self.msProxy.connected then
		self:pendingMsg(request)
	else
		self:sendRequest(request)
	end

	return request.rid
end

function MsServiceManager:pushTimeWheel(request)
	self.timerWheel:push(request.timeout, request.rid, request.rid)
end

function MsServiceManager:onResponse(rid, retStatus, response)
	local request = self:getRequestCallback(rid)

	if request ~= nil then
		CommonRepo.msContext = request.msContext

		self:delRequestCallback(rid)
		self.timerWheel:remove(rid)
		request:onResponse(retStatus, response)
	end
end

function MsServiceManager:onRequestTimeout(rid)
	local request = self:getRequestCallback(rid)

	if request ~= nil then
		self:delRequestCallback(rid)
		request:onTimeout(rid)
	end
end

function MsServiceManager:addRequestCallback(request)
	if not request then
		return
	end

	if request.rid ~= 0 then
		self.rid2request[request.rid] = request

		if request.expireAt ~= 0 then
			self:pushTimeWheel(request)
		end
	end
end

function MsServiceManager:onPlayerResponse(rid)
	self:delRequestCallback(rid)
	self.timerWheel:remove(rid)
end

function MsServiceManager:getRequestCallback(rid)
	return self.rid2request[rid]
end

function MsServiceManager:delRequestCallback(rid)
	self.rid2request[rid] = nil
end

function MsServiceManager:addPushEndpoint(id, entity)
	assert(type(id) == "string")

	self.pushEndpoints[id] = entity
end

function MsServiceManager:delPushEndpoint(id)
	assert(type(id) == "string")

	self.pushEndpoints[id] = nil
end

function MsServiceManager:getPushEndpoint(id)
	assert(type(id) == "string")

	return self.pushEndpoints[id]
end

local function callCommonMethod(target, methodName, parameters)
	local func = target[methodName]

	if func ~= nil then
		if class.isInstanceOf(func, RpcMethod) then
			SafeCallback(func, func.accessor, target, unpack(parameters or {}))
		else
			SafeCallback(func, target, unpack(parameters or {}))
		end
	elseif pg.logError() then
		logger:error("onPush callCommonMethod %s not found", methodName)
	end
end

function MsServiceManager:onPush(orgType, epIds, msgId, serviceName, methodName, parameters)
	if Utils.checkClient() then
		local target = pg.me

		if Const.MicroServiceName[serviceName] then
			methodName = serviceName .. "_" .. methodName
		end

		callCommonMethod(target, methodName, parameters)

		return
	end

	if serviceName == "ForwardPlayerMessageByUid" then
		if #epIds < 1 then
			logger:error("ForwardPlayerMessageByUid method %s, no target", methodName)

			return
		end

		local uid = epIds[1]
		local EntityManager = require("Core.Common.EntityManager")
		local player = EntityManager.getPlayerByUid(uid)

		if player == nil then
			logger:info("ForwardPlayerMessageByUid Not Found player[%s], rpc method is %s", uid, methodName)

			return
		end

		callCommonMethod(player, methodName, parameters)

		return
	end

	if serviceName == "GMService" and (orgType == "CLUSTER" or orgType == "WORLD") and methodName == "ExecProcessGM" then
		local Globals = require("Globals")

		Globals.specificEntity:onExecProcessGM(unpack(parameters or {}))

		return
	end

	if serviceName == "GMService_ClusterCommand" and (orgType == "CLUSTER" or orgType == "WORLD") then
		local Globals = require("Globals")

		Globals.specificEntity:onClusterCommand(methodName, parameters)

		return
	end

	local function handler(epId)
		local target = self:getPushEndpoint(epId)

		if target ~= nil then
			if Const.MicroServiceName[serviceName] then
				methodName = serviceName .. "_" .. methodName
			end

			local func = target[methodName]

			if func ~= nil then
				if msgId ~= nil and msgId ~= "" then
					if LoggerManager.checkLogger(LoggerConst.INFO) then
						logger:info("onPush %s received reliable msg: %s, %s", epId, methodName, inspect(parameters))
					end

					if not Const.MicroServiceName[serviceName] then
						if #parameters < 2 or parameters[1] ~= "TAG_SERVER_VERSION" or parameters[2] > GameVersion then
							if LoggerManager.checkLogger(LoggerConst.ERROR) then
								logger:error("onPush %s received reliable msg parameters error: %s, %s", epId, methodName, inspect(parameters))
							end

							return
						end

						if #parameters == 2 then
							parameters = {}
						else
							parameters = parameters[3]
						end
					end

					target:ackReliableMsg(epId, msgId)

					if target:getReliableMsgAck(msgId) ~= nil then
						if LoggerManager.checkLogger(LoggerConst.WARN) then
							logger:warn("onPush to target %s method %s msgId %s duplicated", epId, methodName, msgId)
						end
					else
						target:addReliableMsgAck(epId, msgId)
						callCommonMethod(target, methodName, parameters)
					end
				else
					callCommonMethod(target, methodName, parameters)
				end
			elseif target.onPushServiceForward then
				target:onPushServiceForward(epId, msgId, serviceName, methodName, parameters)
			elseif LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("onPush to %s for method %s not defined", epId, methodName)
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("onPush to %s for method %s, target not found", epId, methodName)
		end
	end

	if orgType == "ENTITY" then
		for _, epId in ipairs(epIds) do
			handler(epId)
		end
	elseif orgType == "CLUSTER" or orgType == "WORLD" then
		if orgType == "CLUSTER" and serviceName == "ActivityService" then
			methodName = serviceName .. "_" .. methodName

			local Globals = require("Globals")

			if Globals.activitySyncAgent == nil then
				logger:info("onPush to ActivitySyncAgent is nil for method %s not defined", methodName)

				return
			end

			local func = Globals.activitySyncAgent[methodName]

			if func ~= nil then
				SafeCallback(func, Globals.activitySyncAgent, unpack(parameters or {}))
			elseif LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("onPush to ActivitySyncAgent for method %s not defined", methodName)
			end

			return
		end

		for epId, _ in pairs(self.pushEndpoints) do
			handler(epId)
		end
	end
end

function MsServiceManager:onCheckTimeout(rid)
	self:onRequestTimeout(rid)
end

function MsServiceManager:sendPendingMsgs()
	local curTime = Time.realSecondCache * 1000

	while not self.pendingRequestQueue:isEmpty() do
		local r = self.pendingRequestQueue:deQueue()

		if r ~= nil then
			if r.rid == 0 then
				self:sendRequest(r)
			else
				local request = self:getRequestCallback(r.rid)

				if request ~= nil then
					self:sendRequest(request, curTime)
				end
			end
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("sendPendingMsgs but msg is nil")
		end
	end
end

function MsServiceManager:getRequestInfo(rid)
	local request = self:getRequestCallback(rid)

	if request ~= nil then
		return request.serviceName .. "-" .. request.methodName .. "-cb"
	else
		return "null"
	end
end

function MsServiceManager:onConnected()
	self:sendPendingMsgs()
end

function MsServiceManager:destroy()
	self.msProxy = nil
	self.rid2request = {}

	self.pendingRequestQueue:clear()

	self.idGenerator = nil
	self.pushEndpoints = {}

	self.timerWheel:destroy()

	self.timerWheel = nil
end

return MsServiceManager
