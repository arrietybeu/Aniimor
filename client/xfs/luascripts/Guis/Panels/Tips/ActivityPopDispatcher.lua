-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\ActivityPopDispatcher.lua

local Class = require("Core.Framework.Class")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityPopConst = require("Const.ActivityPopConst")
local MessageName = require("Const.MessageName")
local ActivityPopUtils = require("Utils.ActivityPopUtils")
local GameEventData = require("Data.game_event_data")
local GameEventTypeData = require("Data.game_event_type_data")
local UIConst = require("Const.UIConst")
local LoggerManager = require("Core.Log.LoggerManager")
local Time = require("Core.Common.Time")
local WATCHDOG_EMPTY_TIMEOUT = 3
local logger = LoggerManager.getLogger("ActivityPopDispatcher")
local ActivityPopDispatcher = Class.LightClass("ActivityPopDispatcher")

function ActivityPopDispatcher:ctor()
	self.popQueue = {}
	self.currentIndex = 0
	self.serialNumber = 0
	self.currentSerial = nil
	self.currentEventId = nil
	self.currentTarget = nil
	self.currentFinished = true
	self.currentMarked = false
	self.waitingEventPanel = false
	self.watchdogTimer = nil
	self.watchdogEmptyDeadline = nil
	self.watchdogSeenActive = false
	self.sessionStarted = false
	self.seasonActivityPopPending = nil
end

function ActivityPopDispatcher:start()
	if self.sessionStarted then
		self:_notifySeasonActivityPopPendingChanged(true)

		return
	end

	self.sessionStarted = true
	self.popQueue = ActivityPopUtils.collectPops() or {}
	self.currentIndex = 0

	self:_dispatchNext()
end

function ActivityPopDispatcher:_beginCurrent(eventId, target)
	self.serialNumber = self.serialNumber + 1
	self.currentSerial = self.serialNumber
	self.currentEventId = eventId
	self.currentTarget = target
	self.currentFinished = false
	self.currentMarked = false
	self.waitingEventPanel = false

	return self.currentSerial
end

function ActivityPopDispatcher:_isCurrent(serial)
	return not self.currentFinished and self.currentEventId ~= nil and self.currentSerial == serial
end

function ActivityPopDispatcher:_markCurrentPopped(serial)
	if not self:_isCurrent(serial) or self.currentMarked then
		return
	end

	self.currentMarked = true

	local cooldown = self.currentTarget.cooldown or ActivityPopConst.CooldownType.None

	ActivityPopUtils.markPopped(self.currentEventId, cooldown)
end

function ActivityPopDispatcher:_finishCurrent(serial, shouldMark)
	if not self:_isCurrent(serial) then
		return
	end

	if shouldMark then
		self:_markCurrentPopped(serial)
	end

	self.currentFinished = true

	self:_stopWatchdog()
	self:_resetCurrent()
	self:_dispatchNext()
end

function ActivityPopDispatcher:_resetCurrent()
	self.currentSerial = nil
	self.currentEventId = nil
	self.currentTarget = nil
	self.currentMarked = false
	self.waitingEventPanel = false
end

function ActivityPopDispatcher:_dispatchNext()
	while self.currentIndex < #self.popQueue do
		self.currentIndex = self.currentIndex + 1

		local eventId = self.popQueue[self.currentIndex]
		local accepted = self:_dispatchOne(eventId)

		if accepted then
			self:_notifySeasonActivityPopPendingChanged()

			return
		end

		self.currentFinished = true

		self:_resetCurrent()
	end

	self.currentFinished = true

	self:_resetCurrent()
	self:_notifySeasonActivityPopPendingChanged()
end

function ActivityPopDispatcher:hasActivityPopPending(eventType)
	if self.currentEventId then
		local currentEventData = GameEventData[self.currentEventId]

		if currentEventData and currentEventData.eventType == eventType then
			return true
		end
	end

	for index = self.currentIndex + 1, #self.popQueue do
		local eventData = GameEventData[self.popQueue[index]]

		if eventData and eventData.eventType == eventType then
			return true
		end
	end

	return false
end

function ActivityPopDispatcher:_notifySeasonActivityPopPendingChanged(force)
	local pending = self:hasActivityPopPending(ActivityConst.EventType.SeasonActivity)

	if not force and self.seasonActivityPopPending == pending then
		return
	end

	self.seasonActivityPopPending = pending

	facade:SendMessageCommand(MessageName.SEASON_ACTIVITY_POP_PENDING_CHANGED, {
		pending = pending
	})
end

function ActivityPopDispatcher:_dispatchOne(eventId)
	local eventData = GameEventData[eventId]

	if not eventData then
		logger:error("@ActivityPop activity popup event data missing eventId=%s", eventId)

		return false
	end

	local target = ActivityPopConst.PopTarget[eventData.eventType]

	if not target then
		logger:error("@ActivityPop activity popup target missing eventId=%s eventType=%s", eventId, eventData.eventType)

		return false
	end

	local isLegacy = target.legacy == true
	local isItem = not string.isNilOrEmpty(target.areaType) and not string.isNilOrEmpty(target.itemKey)

	if isLegacy == isItem then
		logger:error("@ActivityPop activity popup target shape invalid eventId=%s eventType=%s", eventId, eventData.eventType)

		return false
	end

	if isLegacy then
		return self:_dispatchLegacy(eventId, eventData, target)
	end

	return self:_dispatchItem(eventId, eventData, target)
end

function ActivityPopDispatcher:_dispatchLegacy(eventId, eventData, target)
	local tipsCtrl = pg.global.ui.tips
	local eventTypeData = GameEventTypeData[eventData.eventType]

	if not eventTypeData then
		logger:error("@ActivityPop activity popup event type data missing eventId=%s eventType=%s", eventId, eventData.eventType)

		return false
	end

	if not tipsCtrl.event or not tipsCtrl.event.showEvent then
		logger:error("@ActivityPop activity popup legacy component missing eventId=%s", eventId)

		return false
	end

	local cooldown = target.cooldown or ActivityPopConst.CooldownType.None
	local serial = self:_beginCurrent(eventId, target)

	tipsCtrl.event:showEvent(eventTypeData.name, eventData.popDesc, function()
		if not self:_isCurrent(serial) or self.waitingEventPanel then
			return
		end

		self.waitingEventPanel = true

		pg.global.ui:open(UIConst.UI_ID_EVENT, {
			tabType = eventTypeData.tabType,
			id = eventId
		}, nil, function()
			if not self:_isCurrent(serial) or not self.waitingEventPanel then
				return
			end

			self:_finishCurrent(serial, false)
		end)
	end, function()
		if self.waitingEventPanel then
			return
		end

		self:_finishCurrent(serial, false)
	end, {
		hint = true,
		image = eventData.popID,
		hintCb = function(isSelected)
			if isSelected then
				ActivityPopUtils.markPopped(eventId, cooldown)
			end
		end
	})

	return true
end

function ActivityPopDispatcher:_dispatchItem(eventId, eventData, target)
	local tipsCtrl = pg.global.ui.tips

	if not tipsCtrl.areaManager or not tipsCtrl.areaManager.getAreaItem then
		logger:error("@ActivityPop activity popup item target invalid eventId=%s", eventId)

		return false
	end

	local item = tipsCtrl.areaManager:getAreaItem(target.areaType, target.itemKey)

	if not item then
		logger:error("@ActivityPop activity popup target item missing eventId=%s area=%s item=%s", eventId, target.areaType, target.itemKey)

		return false
	end

	local serial = self:_beginCurrent(eventId, target)

	self:_startWatchdog(serial, target)

	local popDesc = pg.getLocalizationText(eventData.popDesc)

	tipsCtrl:pushAreaManagerData({
		areaType = target.areaType,
		itemKey = target.itemKey,
		eventId = eventId,
		popImage = eventData.popID,
		popDesc = popDesc,
		desc = popDesc,
		popFinishCb = function()
			self:_finishCurrent(serial, true)
		end
	})

	return true
end

function ActivityPopDispatcher:tryNext()
	if not self.currentEventId then
		self:_dispatchNext()

		return
	end

	if self.currentTarget and self.currentTarget.legacy == true and self.waitingEventPanel then
		self:_finishCurrent(self.currentSerial, false)
	end
end

function ActivityPopDispatcher:_stopWatchdog()
	if self.watchdogTimer then
		local tipsCtrl = pg.global.ui.tips

		tipsCtrl:killTimer(self.watchdogTimer)

		self.watchdogTimer = nil
	end

	self.watchdogEmptyDeadline = nil
	self.watchdogSeenActive = false
end

function ActivityPopDispatcher:_startWatchdog(serial, target)
	local tipsCtrl = pg.global.ui.tips

	self:_stopWatchdog()

	self.watchdogEmptyDeadline = Time.realSecondCache + WATCHDOG_EMPTY_TIMEOUT
	self.watchdogSeenActive = false
	self.watchdogTimer = tipsCtrl:startTimer(function()
		self:_watchdogTick(serial, target)
	end, 1, true)
end

function ActivityPopDispatcher:_watchdogTick(serial, target)
	if not self:_isCurrent(serial) then
		self:_stopWatchdog()

		return
	end

	local tipsCtrl = pg.global.ui.tips
	local item = tipsCtrl.areaManager:getAreaItem(target.areaType, target.itemKey)

	if item and item:isRunning() then
		self.watchdogSeenActive = true
		self.watchdogEmptyDeadline = Time.realSecondCache + WATCHDOG_EMPTY_TIMEOUT

		return
	end

	if item and item:isWaitingOrRunning() then
		self.watchdogEmptyDeadline = Time.realSecondCache + WATCHDOG_EMPTY_TIMEOUT

		return
	end

	if Time.realSecondCache >= self.watchdogEmptyDeadline then
		logger:error("@ActivityPop activity popup item finished without callback eventId=%s", self.currentEventId)
		self:_finishCurrent(serial, self.watchdogSeenActive)
	end
end

function ActivityPopDispatcher:clear()
	local tipsCtrl = pg.global.ui.tips
	local target = self.currentTarget

	self:_stopWatchdog()

	self.serialNumber = self.serialNumber + 1
	self.popQueue = {}
	self.currentIndex = 0
	self.currentFinished = true

	self:_resetCurrent()
	self:_notifySeasonActivityPopPendingChanged()

	if target and target.legacy == true and tipsCtrl.event then
		if tipsCtrl.event.hide then
			tipsCtrl.event:hide()
		end

		if tipsCtrl.event.unloadContainer then
			tipsCtrl.event:unloadContainer()
		end

		return
	end

	if target and tipsCtrl.areaManager then
		local item = tipsCtrl.areaManager:getAreaItem(target.areaType, target.itemKey)

		if item and item.clearAllData then
			item:clearAllData(true)
		end
	end
end

function ActivityPopDispatcher:resetSession()
	self:clear()

	self.sessionStarted = false
end

return ActivityPopDispatcher
