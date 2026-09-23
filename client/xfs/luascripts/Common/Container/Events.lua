-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\Events.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Events")
local EventEmitter = Class.LightClass("EventEmitter")
local SafeCallback = require("Core.Framework.SafeCallback")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local lume = require("Core.Common.lume")
local ListPool = require("Common.Container.ListPool")
local pairs = pairs
local next = raw_next
local unpack = unpack
local table_remove = table.remove
local debug_traceback = debug.traceback
local listpool_getList = ListPool.getList
local listpool_returnList = ListPool.returnList
local lume_push = lume.push
local lume_disposeItem = lume.disposeItem
local lume_removeAllListItemWithDispose = lume.removeAllListItemWithDispose
local lume_removeListItemWithDispose = lume.removeListItemWithDispose

function EventEmitter:ctor()
	self.listeners = {}
	self.onceListeners = {}
	self.notifyRecord = {}
	self.notifyQueue = {}
	self._emitting = false
end

function EventEmitter.copy(listeners, refTable)
	for i = 1, #listeners do
		refTable[i] = listeners[i]
	end

	return refTable
end

function EventEmitter:emit(event, ...)
	if not self.listeners[event] and not self.onceListeners[event] then
		return
	end

	if self.notifyRecord[event] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("inifinity loop detected, event", event, debug_traceback())
		end

		return
	end

	if self._emitting then
		local params = listpool_getList(3)

		params[1] = event

		lume_push(params, ...)

		local queue = self.notifyQueue

		queue[#queue + 1] = params

		return
	end

	self._emitting = true

	self:_do_emit(event, ...)

	local queue = self.notifyQueue

	while queue[1] do
		local params = table_remove(queue, 1)
		local n = #params
		local ev = params[1]

		self:_do_emit(ev, unpack(params, 2, n))
		listpool_returnList(params, 3)
	end

	self._emitting = false
end

function EventEmitter:emitNextFrame(event, ...)
	TimerManager.addNextFrameCb(CallbackHandlerNoGC.new(self, self.emit, event, ...))
end

function EventEmitter:_do_emit(event, ...)
	self.notifyRecord[event] = true

	local listeners = self.listeners[event]

	if listeners then
		local snapshot = listpool_getList(3)
		local n = #listeners

		for i = 1, n do
			snapshot[i] = listeners[i]
		end

		for i = 1, n do
			SafeCallback(snapshot[i], ...)
		end

		listpool_returnList(snapshot, 3)
	end

	local onceEvent = self.onceListeners[event]

	if onceEvent then
		local snapshot = listpool_getList(3)
		local n = #onceEvent

		for i = 1, n do
			snapshot[i] = onceEvent[i]
		end

		for i = 1, n do
			SafeCallback(snapshot[i], ...)
		end

		listpool_returnList(snapshot, 3)

		if self.onceListeners[event] == onceEvent then
			lume_disposeItem(onceEvent)

			self.onceListeners[event] = nil

			listpool_returnList(onceEvent, 3)
		end
	end

	self.notifyRecord[event] = nil
end

function EventEmitter:addEventListener(event, listener)
	local list = self.listeners[event]

	if not list then
		list = listpool_getList(3)
		self.listeners[event] = list
	end

	list[#list + 1] = listener
end

function EventEmitter:onceEventListener(event, listener)
	local list = self.onceListeners[event]

	if not list then
		list = listpool_getList(3)
		self.onceListeners[event] = list
	end

	list[#list + 1] = listener
end

function EventEmitter:removeAllListeners(event)
	if event ~= nil then
		local listeners = self.listeners[event]

		if listeners then
			lume_removeAllListItemWithDispose(listeners)

			self.listeners[event] = nil

			listpool_returnList(listeners, 3)
		end

		local onceListeners = self.onceListeners[event]

		if onceListeners then
			lume_removeAllListItemWithDispose(onceListeners)

			self.onceListeners[event] = nil

			listpool_returnList(onceListeners, 3)
		end
	else
		local k, listener = next(self.listeners)

		while k do
			lume_removeAllListItemWithDispose(listener)

			self.listeners[k] = nil

			listpool_returnList(listener, 3)

			k, listener = next(self.listeners)
		end

		k, listener = next(self.onceListeners)

		while k do
			lume_removeAllListItemWithDispose(listener)

			self.onceListeners[k] = nil

			listpool_returnList(listener, 3)

			k, listener = next(self.onceListeners)
		end
	end
end

function EventEmitter:removeEventListener(event, listener)
	local listeners = self.listeners[event]

	if listeners then
		lume_removeListItemWithDispose(listeners, listener, true)

		if #listeners == 0 then
			self.listeners[event] = nil

			listpool_returnList(listeners, 3)
		end
	end

	local onceListeners = self.onceListeners[event]

	if onceListeners then
		lume_removeListItemWithDispose(onceListeners, listener, true)

		if #onceListeners == 0 then
			self.onceListeners[event] = nil

			listpool_returnList(onceListeners, 3)
		end
	end
end

return EventEmitter
