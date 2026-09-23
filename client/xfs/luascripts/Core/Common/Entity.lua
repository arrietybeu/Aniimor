-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\Entity.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local EntityManager = require("Core.Common.EntityManager")
local CallbackGuard = require("Core.Common.CallbackGuard")
local MethodOrIndex = require("Core.Common.MethodOrIndex")
local LoggerManager = require("Core.Log.LoggerManager")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local TickManager = require("Core.Common.TickManager")
local CommonRepo = require("Core.Common.CommonRepo")
local Entity = class.Class("Entity")
local _hasClientLODCache = setmetatable({}, {
	__mode = "k"
})

local function _classHasClientLODComponent(cls)
	local cached = _hasClientLODCache[cls]

	if cached ~= nil then
		return cached
	end

	local has = false
	local cur = cls

	while cur do
		local names = rawget(cur, "componentNames")

		if names and names.ClientLODComponent then
			has = true

			break
		end

		cur = cur.superType
	end

	_hasClientLODCache[cls] = has

	return has
end

function Entity:ctor(entityId)
	if entityId == nil then
		entityId = IDManager.genB64ID()
	end

	self.id = entityId
	self.destroyed = false
	self.started = false
	self.__startfinish = false
	self.logger = LoggerManager.getLogger(self:getClassType())
	self.methodOrIndex = MethodOrIndex()
	self.remoteMethodOrIndex = MethodOrIndex()
	self.callbackGuard = CallbackGuard(self)

	EntityManager.addEntity(entityId, self)
end

function Entity:getGlobalId()
	return self.id
end

function Entity:getPersistentId()
	return self.id
end

function Entity:preInit(dict)
	return
end

function Entity:init(dict)
	return true
end

function Entity:postInit(dict)
	return
end

function Entity:start()
	self.started = true

	self:startTick()
end

function Entity:startTick()
	local entityCls = self:getClass()
	local tickInterval = entityCls.__TickInterval__

	if tickInterval ~= nil then
		if pg and pg.component == "game" then
			local frameCount = math.floor(tickInterval * 1000 / 33)

			if frameCount < 1 then
				frameCount = 1
			end

			self._tickLastTime = Time.getTickSecond()
			self._tickHandlerId = TimerManager.addSpecificFrameCb(frameCount, true, function()
				local curTime = Time.getTickSecond()
				local deltaTime = curTime - self._tickLastTime

				xpcall(self.tick, CommonRepo.exceptionFunc, self, deltaTime)

				self._tickLastTime = curTime
			end)
		elseif _classHasClientLODComponent(entityCls) then
			require("Core.Common.ClientLODTickManager").register(self, tickInterval)

			self.__lodRegistered = true
		else
			TickManager.addTick(self, tickInterval)
		end
	end
end

function Entity:stopTick()
	local entityCls = self:getClass()
	local tickInterval = entityCls.__TickInterval__

	if tickInterval ~= nil then
		if pg and pg.component == "game" then
			if self._tickHandlerId ~= nil then
				TimerManager.delFrameCb(self._tickHandlerId)

				self._tickHandlerId = nil
				self._tickLastTime = nil
			end
		elseif self.__lodRegistered then
			require("Core.Common.ClientLODTickManager").unregister(self)

			self.__lodRegistered = nil
		else
			TickManager.removeTick(self, tickInterval)
		end
	end
end

function Entity:repr()
	return string.format("Entity (%s, %s)", self:getClassType(), self.id)
end

function Entity:tick()
	return
end

function Entity:destroy()
	assert(self.destroyed == false)

	self.destroyed = true

	self:stopTick()
	self.methodOrIndex:clear()
	self.remoteMethodOrIndex:clear()
	self.callbackGuard:clear()
	EntityManager.removeEntity(self.id)
end

function Entity:clearMethodOrIndex()
	self.methodOrIndex:clear()
	self.remoteMethodOrIndex:clear()
end

function Entity:encodeMethodOrIndex(method)
	return self.methodOrIndex:encode(method)
end

function Entity:decodeMethodOrIndex(method, index)
	local retMethod = self.remoteMethodOrIndex:decode(index)

	if retMethod == nil then
		return method
	end

	return retMethod
end

function Entity:addTimer(delay, handler)
	return self.callbackGuard:addTimerCallback(delay, handler)
end

function Entity:addRepeatTimer(delay, handler)
	return self.callbackGuard:addRepeatTimerCallback(delay, handler)
end

function Entity:removeTimer(timerid)
	self.callbackGuard:removeTimerCallbackByTimerId(timerid)
end

function Entity:callService(serviceName, methodName, args, callback, options)
	if not _G_IsDebugMode or CommonRepo.serviceType[serviceName] == "GLOBAL" then
		self:_callGlobalService(serviceName, methodName, args, callback, options)
	elseif CommonRepo.serviceType[serviceName] == "CLUSTER" then
		self:_callClusterService(serviceName, methodName, args, callback, options)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s callService %s with method %s failed, err: serviceType not configed", self:repr(), serviceName, methodName)
	end
end

function Entity:_callGlobalService(serviceName, methodName, args, callback, options)
	local ServiceUtils = require("Common.Utils.ServiceUtils")

	if ServiceUtils.msProxyConected(serviceName) then
		if callback ~= nil then
			local cid = self.callbackGuard:genNextCallbackId()

			local function callbackWrapper(...)
				self.callbackGuard:removeMicroServiceCallback(cid)
				callback(...)
			end

			local requestid = ServiceUtils.callService(serviceName, methodName, args, callbackWrapper, options)

			if requestid ~= nil then
				self.callbackGuard:addMicroServiceCallback(cid, {
					requestid,
					serviceName
				})
			end
		else
			ServiceUtils.callService(serviceName, methodName, args, callback, options)
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s callService %s with method %s failed: MsProxy not connected", self:repr(), serviceName, methodName)
		end

		if callback ~= nil then
			callback({
				errmsg = "MsProxy not connected",
				status = false
			})
		end
	end
end

function Entity:getClusterMsProxy()
	return nil
end

function Entity:_callClusterService(serviceName, methodName, args, callback, options)
	local clusterMsProxy = self:getClusterMsProxy()

	if clusterMsProxy ~= nil then
		if callback ~= nil then
			local cid = self.callbackGuard:genNextCallbackId()

			local function callbackWrapper(...)
				self.callbackGuard:removeMicroServiceCallback(cid)
				callback(...)
			end

			local requestid = clusterMsProxy:callService(serviceName, methodName, args, callbackWrapper, options)

			if requestid ~= nil then
				self.callbackGuard:addClusterMsCallback(cid, requestid)
			end
		else
			clusterMsProxy:callService(serviceName, methodName, args, callback, options)
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s _callClusterService %s with method %s failed: globalMsProxy is nil", self:repr(), serviceName, methodName)
		end

		if callback ~= nil then
			callback({
				errmsg = "globalMsProxy is nil",
				status = false
			})
		end
	end
end

function Entity:_Engine_ExRelation_(method, index)
	self.remoteMethodOrIndex:addRelation(method, index)
end

function Entity:getGameTime()
	if self.space == nil then
		return 0
	end

	return self.space:getGameTime()
end

function Entity:getGameTimeScale()
	return self.space and self.space.gameTimeScale or 1
end

return Entity
