-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\CallbackGuard.lua

local class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local DBCallbackManager = require("Core.Common.DBCallbackManager")
local CallbackGuard = class.Class("CallbackGuard")

function CallbackGuard:ctor(owner)
	self.owner = owner
	self.id = 0
	self.timerCallbacks = {}
	self.serializableTimerCallbacks = {}
	self.timerId2Cid = {}
	self.microServiceCallbacks = {}
	self.dbCallbacks = {}
	self.clusterMsCallbacks = {}
end

function CallbackGuard:destroy()
	self:clear()

	self.owner = nil
end

function CallbackGuard:genNextCallbackId()
	self.id = self.id + 1

	if self.id > 4294967295 then
		self.id = 1
	end

	return self.id
end

function CallbackGuard:addTimerCallback(delay, handler, canSerializable)
	local cid = self:genNextCallbackId()

	local function handlerWrapper()
		self:removeTimerCallback(cid)

		if handler then
			handler()
		end
	end

	local timerid = TimerManager.addTimer(delay, handlerWrapper)

	if canSerializable then
		self.serializableTimerCallbacks[cid] = timerid
	else
		self.timerCallbacks[cid] = timerid
	end

	self.timerId2Cid[timerid] = cid

	return timerid
end

function CallbackGuard:addRepeatTimerCallback(delay, handler, canSerializable)
	local cid = self:genNextCallbackId()
	local timerid = TimerManager.addRepeatTimer(delay, handler)

	if canSerializable then
		self.serializableTimerCallbacks[cid] = timerid
	else
		self.timerCallbacks[cid] = timerid
	end

	self.timerId2Cid[timerid] = cid

	return timerid
end

function CallbackGuard:removeTimerCallback(cid)
	local timerid = self.timerCallbacks[cid]

	if timerid == nil then
		timerid = self.serializableTimerCallbacks[cid]
	end

	if timerid ~= nil then
		self.timerCallbacks[cid] = nil
		self.serializableTimerCallbacks[cid] = nil
		self.timerId2Cid[timerid] = nil

		TimerManager.removeTimer(timerid)
	end
end

function CallbackGuard:removeTimerCallbackByTimerId(timerid)
	local cid = self.timerId2Cid[timerid]

	TimerManager.removeTimer(timerid)

	if cid ~= nil then
		self.timerId2Cid[timerid] = nil
		self.timerCallbacks[cid] = nil
		self.serializableTimerCallbacks[cid] = nil
	end
end

function CallbackGuard:addMicroServiceCallback(cid, ridAndSrvName)
	self.microServiceCallbacks[cid] = ridAndSrvName
end

function CallbackGuard:removeMicroServiceCallback(cid)
	self.microServiceCallbacks[cid] = nil
end

function CallbackGuard:addClusterMsCallback(cid, requestid)
	self.clusterMsCallbacks[cid] = requestid
end

function CallbackGuard:removeClusterMsCallback(cid)
	self.clusterMsCallbacks[cid] = nil
end

function CallbackGuard:addDBCallback(cid, callbackid)
	self.dbCallbacks[cid] = callbackid
end

function CallbackGuard:removeDBCallback(cid)
	local callbackid = self.dbCallbacks[cid]

	if callbackid ~= nil then
		DBCallbackManager.unregDBCallback(callbackid)
	end

	self.dbCallbacks[cid] = nil
end

function CallbackGuard:clear()
	for _, timerid in pairs(self.timerCallbacks) do
		TimerManager.removeTimer(timerid)
	end

	self.timerCallbacks = {}

	for _, timerid in pairs(self.serializableTimerCallbacks) do
		TimerManager.removeTimer(timerid)
	end

	self.serializableTimerCallbacks = {}

	local ServiceUtils = require("Common.Utils.ServiceUtils")

	for _, ridAndSrvName in pairs(self.microServiceCallbacks) do
		ServiceUtils.delRequestCallback(ridAndSrvName[1], ridAndSrvName[2])
	end

	self.microServiceCallbacks = {}

	for _, callbackid in pairs(self.dbCallbacks) do
		DBCallbackManager.unregDBCallback(callbackid)
	end

	self.dbCallbacks = {}

	if self.owner.getClusterMsProxy ~= nil then
		local clusterMsproxy = self.owner:getClusterMsProxy()

		if clusterMsproxy ~= nil then
			for _, requestid in pairs(self.clusterMsCallbacks) do
				clusterMsproxy:delRequestCallback(requestid)
			end
		end

		self.clusterMsCallbacks = {}
	end
end

function CallbackGuard:checkHaveCallback()
	if next(self.microServiceCallbacks) ~= nil then
		return true
	end

	if next(self.dbCallbacks) ~= nil then
		return true
	end

	if next(self.clusterMsCallbacks) ~= nil then
		return true
	end

	return false
end

function CallbackGuard:recoverTimerCallback(leftMs, delay, isRepeat, handler)
	local cid = self:genNextCallbackId()
	local handlerWrapper = handler

	if not isRepeat then
		function handlerWrapper()
			self:removeTimerCallback(cid)

			if handler then
				handler()
			end
		end
	end

	local timerid = TimerManager.recoverTimer(delay, leftMs, isRepeat, handlerWrapper)

	self.serializableTimerCallbacks[cid] = timerid
	self.timerId2Cid[timerid] = cid

	return timerid
end

function CallbackGuard:getSerializableTimerLeftMs(timerid)
	return TimerManager.getSerializableTimerLeftMs(timerid)
end

return CallbackGuard
