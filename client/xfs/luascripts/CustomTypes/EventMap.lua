-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\EventMap.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local logger = LoggerManager.getLogger("event")
local bit = bit
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ObjHelper = require("Common.ObjHelper")
local NoticeDef = require("Common.NoticeDef")
local EventEnumData = require("Data.event_enum_data")
local SysEventData = require("Data.sys_event_data")
local EventMap = class.LiteClass("EventMap", CustomDict)
local pairs = pairs
local ipairs = ipairs
local math_floor = math.floor
local eventCheckInterVal = 0.1

function EventMap:ctor()
	EventMap.super.ctor(self)
	rawset(self, "delayWithEvents", {})
	rawset(self, "eventTimerId", 0)
end

local function getDelayClockNow()
	if pg.component == "client" then
		return Time.realSecondCache
	end

	return Time.secondCache
end

if UNITY_EDITOR then
	local types = {
		ObjHelper.TYPE_PLAYER,
		ObjHelper.TYPE_PET_INFO
	}

	function EventMap:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		assert(ObjHelper.matchOneOf(obj, types))

		return obj
	end
else
	function EventMap:getObj()
		local obj = Utils.isPetInfoType(self._parent) and self._parent or self:getRootOwner()

		return obj
	end
end

function EventMap:checkSysEvent(eventId, context)
	local nedd = SysEventData[eventId]

	if not nedd then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	context = context or {}
	context.eventId = eventId

	return self:_checkEvent(nedd.eventType, nedd.eventParam, context)
end

function EventMap:checkSysEventByData(eventData, context)
	local eventName, param, delay = unpack(eventData)

	context = context or {}

	return self:_checkEvent(eventName, param, context)
end

function EventMap:onSysEvent(eventId, context)
	local nedd = SysEventData[eventId]

	if not nedd then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("SysEventData config nil: eventId = %d", eventId)
		end

		return
	end

	context = context or {}
	context.eventId = eventId

	local delay = nedd.eventDelay or 0

	self:dispatchSysEvent(nedd.eventType, nedd.eventParam, delay, context)
end

function EventMap:onSysEventByData(eventData, context)
	local eventName, param, delay = Utils.safeUnpack(eventData)

	context = context or {}

	self:dispatchSysEvent(eventName, param, delay, context)
end

function EventMap:dispatchSysEvent(eventName, param, delay, context)
	local obj = self:getObj()
	local endd = EventEnumData[eventName]

	if endd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("dispatchSysEvent invalid eventConfig, eventName=%s, param=%s, context=%s", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
		end

		return
	end

	param = param or {}
	delay = delay or 0
	context.eventDelay = delay

	local eventFlag = endd and endd.eventFlag
	local ok = false

	if eventFlag == "c" then
		if pg.component == "client" then
			ok = self:registerSysEvent(eventName, param, delay, context)
		else
			ok = ObjHelper.callObjFunc(obj, "_doClientEvent", eventName, Utils.deepCopyTable(param), context)
		end
	elseif eventFlag == "s" then
		if pg.component == "game" then
			ok = self:registerSysEvent(eventName, param, delay, context)
		else
			ok = ObjHelper.callObjFunc(obj, "_doServerEvent", eventName, Utils.deepCopyTable(param), context)
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("dispatchSysEvent eventFlag error", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
		end

		return
	end

	if ok == false and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("dispatchSysEvent register or callFunction error", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
	end
end

function EventMap:registerSysEvent(eventName, param, delay, context)
	local obj = self:getObj()
	local endd = EventEnumData[eventName]

	if endd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("dispatchSysEvent invalid eventConfig, eventName=%s, param=%s, context=%s", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
		end

		return false
	end

	param = param or {}
	delay = delay or context.eventDelay or 0

	if delay > 0 and Utils.isPlayer(obj) then
		local triggerTime = tostring(math.floor((getDelayClockNow() + delay) * 10))

		self.delayWithEvents[triggerTime] = self.delayWithEvents[triggerTime] or {}

		local eventList = self.delayWithEvents[triggerTime]

		eventList[#eventList + 1] = {
			eventName,
			Utils.deepCopyTable(param),
			Utils.deepCopyTable(context)
		}

		self:startEventTimer()
	else
		self:_checkAndDoEvent(eventName, param, context)
	end

	return true
end

function EventMap:_checkAndDoEvent(eventName, param, context)
	local ok, err = self:_checkEvent(eventName, param, context)

	if not ok then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_checkEvent failed, eventName=%s, param=%s, context=%s, err=%s", eventName, inspect(param), inspect(context), NoticeDef.getRepr(err), ObjHelper.getObjRepr(self:getObj()))
		end

		return false, err
	end

	return self:_doEvent(eventName, param, context)
end

function EventMap:_checkEvent(eventName, param, context)
	local endd = EventEnumData[eventName]

	if not endd then
		return false, NoticeDef.ERROR_CONFIG_HAS_ERROR
	end

	local source = context.source or 0

	if endd.useMask and endd.useMask ~= Const.ESM_ANY and bit.band(source, endd.useMask) == 0 and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("event useMask check failed, source=%d, need=%d", source, endd.useMask, eventName)
	end

	if endd.eventFlag == "c" then
		if pg.component == "client" then
			return self:getObj():_checkClientEvent(eventName, param, context)
		else
			return true, NoticeDef.SUCCESS
		end
	elseif endd.eventFlag == "s" then
		if pg.component == "game" then
			return self:getObj():_checkServerEvent(eventName, param, context)
		else
			return true, NoticeDef.SUCCESS
		end
	else
		return false, NoticeDef.ERROR_CONFIG_HAS_ERROR
	end
end

function EventMap:_doEvent(eventName, param, context)
	local endd = EventEnumData[eventName]

	if not endd then
		return false
	end

	local obj = self:getObj()

	if endd.eventFlag == "c" then
		if pg.component == "client" then
			return ObjHelper.callObjFunc(obj, "_doClientEvent", eventName, Utils.deepCopyTable(param), context)
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("_doEvent client error, dispatch first", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
			end

			return false
		end
	elseif endd.eventFlag == "s" then
		if pg.component == "game" then
			return ObjHelper.callObjFunc(obj, "_doServerEvent", eventName, Utils.deepCopyTable(param), context)
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("_doEvent server error, dispatch first", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
			end

			return false
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_doEvent eventFlag error", eventName, inspect(param), inspect(context), ObjHelper.getObjRepr(obj))
		end

		return false
	end
end

function EventMap:startEventTimer()
	if self.eventTimerId == 0 and next(self.delayWithEvents) then
		self.eventTimerId = TimerManager.addRepeatTimer(eventCheckInterVal, CallbackHandler(self, "timerCheckExecuteDelayWithEvent"))
	end
end

function EventMap:timerCheckExecuteDelayWithEvent()
	local now = math_floor(getDelayClockNow() * 10)

	for triggerTime, eventList in pairs(self.delayWithEvents) do
		if now >= tonumber(triggerTime) then
			self.delayWithEvents[triggerTime] = nil

			for _, args in ipairs(eventList) do
				if next(args) then
					self:_checkAndDoEvent(Utils.safeUnpack(args))
				end
			end
		end
	end

	if not next(self.delayWithEvents) then
		self:removeEventTimer()
	end
end

function EventMap:removeEventTimer()
	if self.eventTimerId ~= nil and self.eventTimerId ~= 0 then
		TimerManager.removeTimer(self.eventTimerId)

		self.eventTimerId = 0
	end
end

return EventMap
