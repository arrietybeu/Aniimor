-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Buff\\EventBus.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SafeCallback = require("Core.Framework.SafeCallback")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local Utils = require("Common.Utils.Utils")
local ListPool = require("Common.Container.ListPool")
local lume = require("Core.Common.lume")
local EventBus = {}
local ToBool = ToBool
local EventContainer = Class.LiteClass("EventContainer")

EventBus.EventContainer = EventContainer

function EventContainer:ctor()
	self.container = {}
end

function EventContainer:add(token, callback, removeCallback)
	if EventBus.enableRegisterRepeatEvent then
		for _, info in ipairs(self.container) do
			if info[1] == token then
				if type(info[2]) == "function" then
					info[2] = {
						info[2],
						callback
					}
					info[3] = {
						info[3] or false,
						removeCallback or false
					}

					return
				else
					table.insert(info[2], callback)
					table.insert(info[3], removeCallback or false)

					return
				end
			end
		end
	end

	self.container[#self.container + 1] = {
		token,
		callback,
		removeCallback,
		EventBus.isReceiveAdditionalEvent,
		EventBus.isUnSummonAdditionEventValid,
		EventBus.isReceiveCreationEvent
	}
end

function EventContainer:remove(token)
	for idx, info in ipairs(self.container) do
		if info[1] == token then
			table.remove(self.container, idx)

			local rm = info[3]

			if type(rm) == "function" then
				rm()
			elseif type(rm) == "table" then
				for i = 1, #rm do
					local cb = rm[i]

					if cb then
						local result, info = xpcall(cb, debug.traceback)

						if not result then
							CombatLogger.logException(info)
						end
					end
				end
			end

			return
		end
	end
end

local EventSubject = Class.LiteClass("EventSubject")

EventBus.EventSubject = EventSubject
EventBus.isReceiveAdditionalEvent = false
EventBus.isUnSummonAdditionEventValid = false
EventBus.isReceiveCreationEvent = false
EventBus.enableRegisterRepeatEvent = false

function EventSubject:ctor(actorId)
	self.notifyRecord = {}
	self.actorId = actorId
	self.owner = pg.getEntityByActorId(actorId)
	self.eventContainerMap = {}
	self.releaseCallbackMap = {}
	self.blockEventName = nil
end

function EventSubject:clear()
	for k, v in pairs(self.releaseCallbackMap) do
		local isOk, result = xpcall(v, debug.traceback, self)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error(result)
		end
	end

	lume.clear(self.releaseCallbackMap)
	lume.clear(self.eventContainerMap)
	lume.clear(self.notifyRecord)

	self.additionalReceiver = nil
end

function EventSubject:registerObserver(token, observer)
	self.releaseCallbackMap[token] = function(eventSubject)
		observer:deleteSubject(eventSubject)
	end
end

function EventSubject:unregisterObserver(token)
	if self.releaseCallbackMap[token] then
		local isOk, result = xpcall(self.releaseCallbackMap[token], debug.traceback, self)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error(result)
		end

		self.releaseCallbackMap[token] = nil
	end
end

function EventSubject:add(token, eventId, callback, removeCallback)
	if self.eventContainerMap[eventId] == nil then
		self.eventContainerMap[eventId] = EventContainer.new()
	end

	self.eventContainerMap[eventId]:add(token, callback, removeCallback)
end

function EventSubject:isEventListening(eventId)
	return self.eventContainerMap[eventId] and ToBool(self.eventContainerMap[eventId].container)
end

function EventSubject:remove(token, eventId)
	local container = self.eventContainerMap[eventId]

	if container ~= nil then
		container:remove(token)

		if not next(container.container) then
			self.eventContainerMap[eventId] = nil
		end
	end
end

function EventSubject:removeAll(token)
	for eventName, container in pairs(self.eventContainerMap) do
		container:remove(token)

		if not next(container.container) then
			self.eventContainerMap[eventName] = nil
		end
	end
end

function EventSubject:notifySelf(eventId, info1, ...)
	if eventId == self.blockEventName then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("blockEvent", eventId)
		end

		return false
	end

	local container = self.eventContainerMap[eventId]

	if container then
		if eventId == self.blockEventName then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("blockEvent", eventId)
			end

			return false
		end

		local recordEventId = eventId

		if eventId == AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE then
			recordEventId = eventId .. AttributeConst.ID2NAME[info1.attributeId]
		end

		if self.notifyRecord[recordEventId] then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("inifinity loop detected, eventId", recordEventId)
			end

			return false
		end

		self.notifyRecord[recordEventId] = true

		local tempList = ListPool.getList(3)
		local containerList = container.container
		local containerSize = #containerList

		for i = 1, containerSize do
			tempList[i] = containerList[i]
		end

		for i = 1, containerSize do
			local fun = tempList[i]

			if type(fun[2]) == "function" then
				local isOk, result = xpcall(fun[2], debug.traceback, info1, ...)

				if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
					CombatLogger.logException(result)
				end
			else
				local funList = fun[2]

				for j = 1, #funList do
					local isOk, result = xpcall(funList[j], debug.traceback, info1, ...)

					if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
						CombatLogger.logException(result)
					end
				end
			end
		end

		ListPool.returnList(tempList, 3)

		self.notifyRecord[recordEventId] = nil
	end

	return true
end

function EventSubject:notify(eventId, info1, ...)
	if not self:notifySelf(eventId, info1, ...) then
		return
	end

	if self.additionalReceiver then
		self.additionalReceiver:notifyFromAdditive(self, eventId, info1, ...)
	end
end

function EventSubject:notifyFromAdditive(dispatchSubject, eventId, info1, ...)
	if eventId == self.blockEventName then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("blockEvent", eventId)
		end

		return
	end

	local container = self.eventContainerMap[eventId]

	if container then
		local recordEventId = eventId

		if eventId == AbilityConst.COMBAT_EVENT_ATTRIBUTE_CHANGE then
			recordEventId = eventId .. AttributeConst.ID2NAME[info1.attributeId]
		end

		if self.notifyRecord[recordEventId] then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("infinity loop detected, eventId", recordEventId)
			end

			return
		end

		self.notifyRecord[recordEventId] = true

		local tempList = ListPool.getList(3)
		local containerList = container.container
		local containerSize = #containerList

		for i = 1, containerSize do
			tempList[i] = containerList[i]
		end

		for i = 1, containerSize do
			local fun = tempList[i]
			local isGroupEvent = fun[4]
			local isSummonValid = fun[5]
			local isReceiveCreationEvent = fun[6]

			if isGroupEvent and (isSummonValid or self.owner.isSummon == nil or self.owner.isSummon == true) and (isReceiveCreationEvent or not Utils.isPuppet(dispatchSubject.owner) and not Utils.isCreation(dispatchSubject.owner)) then
				if type(fun[2]) == "table" then
					local funList = fun[2]

					for j = 1, #funList do
						local isOk, result = xpcall(funList[j], debug.traceback, info1, ...)

						if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
							CombatLogger.logException(result)
						end
					end
				else
					local isOk, result = xpcall(fun[2], debug.traceback, info1, ...)

					if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
						CombatLogger.logException(result)
					end
				end
			end
		end

		ListPool.returnList(tempList, 3)

		self.notifyRecord[recordEventId] = nil
	end

	if self.additionalReceiver and (self.owner.isSummon == nil or self.owner.isSummon == true) then
		self.additionalReceiver:notifyFromAdditive(dispatchSubject, eventId, info1, ...)
	end
end

local EventObserver = Class.LiteClass("EventObserver")

EventBus.EventObserver = EventObserver

function EventObserver:ctor()
	self.token = pg.global.abilityMgr:genTokenId()
	self.subjectEventRecord = {}
end

function EventObserver:listen(eventSubject, eventId, callback, removeCallback)
	local findSubject = self.subjectEventRecord[eventSubject]

	if findSubject == nil then
		eventSubject:registerObserver(self.token, self)

		self.subjectEventRecord[eventSubject] = {}
		self.subjectEventRecord[eventSubject][eventId] = true

		eventSubject:add(self.token, eventId, callback, removeCallback)
	else
		if not EventBus.enableRegisterRepeatEvent and self.subjectEventRecord[eventSubject][eventId] ~= nil then
			eventSubject:remove(self.token, eventId)
		end

		self.subjectEventRecord[eventSubject][eventId] = true

		eventSubject:add(self.token, eventId, callback, removeCallback)
	end
end

function EventObserver:isListening(eventSubject, eventId)
	return self.subjectEventRecord[eventSubject] and self.subjectEventRecord[eventSubject][eventId]
end

function EventObserver:unlisten(eventSubject, eventId)
	local findSubject = self.subjectEventRecord[eventSubject]

	if findSubject ~= nil then
		eventSubject:remove(self.token, eventId)

		findSubject[eventId] = nil

		if next(findSubject) == nil then
			eventSubject:unregisterObserver(self.token)

			self.subjectEventRecord[eventSubject] = nil
		end
	end
end

function EventObserver:unlistenAll()
	for evnetSubject, _ in pairs(self.subjectEventRecord) do
		evnetSubject:removeAll(self.token)
		evnetSubject:unregisterObserver(self.token)
	end

	self.subjectEventRecord = {}
end

function EventObserver:deleteSubject(eventSubject)
	self.subjectEventRecord[eventSubject] = nil
end

return EventBus
