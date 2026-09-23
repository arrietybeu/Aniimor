-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\ActionTimelineNotify.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local ActionTimelineNotify = {}
local ActionTimelineNotifyEvent = Class.LiteClass("ActionTimelineNotifyEvent")

ActionTimelineNotify.ActionTimelineNotifyEvent = ActionTimelineNotifyEvent

function ActionTimelineNotifyEvent:ctor(timelineEvent)
	self.timelineEvent = timelineEvent
	self.eventStr = timelineEvent.eventType
end

function ActionTimelineNotifyEvent:executeEvent(entity, combatContext)
	if not combatContext then
		return false
	end

	combatContext:pushNodeIdToStack(self.timelineEvent.NodeID)

	combatContext.timelineEventStr = self.eventStr

	local result = entity.combatAction:doActions(self.timelineEvent.action, combatContext)

	combatContext.timelineEventStr = nil

	combatContext:popNodeIdFromStack()

	return result
end

local ActionTimelineNotifyAction = Class.LiteClass("ActionTimelineNotifyAction")

ActionTimelineNotify.ActionTimelineNotifyAction = ActionTimelineNotifyAction

function ActionTimelineNotifyAction:ctor(timelineEvent, index)
	self.timelineEvent = timelineEvent
	self.time = timelineEvent.time or 0
	self.index = index or 0
	self.eventStr = tostring(self.time)
end

function ActionTimelineNotifyAction:isNotifyActivate(prevTime, curTime)
	return prevTime <= self.time and curTime > self.time
end

function ActionTimelineNotifyAction:executeNotify(entity, combatContext)
	if not combatContext then
		return false
	end

	combatContext:pushNodeIdToStack(self.timelineEvent.NodeID)

	combatContext.timelineEventStr = self.eventStr

	local result = entity.combatAction:doActions(self.timelineEvent.action, combatContext)

	combatContext.timelineEventStr = nil

	combatContext:popNodeIdFromStack()

	return result
end

local ActionTimelineNotifyStateAction = Class.LiteClass("ActionTimelineNotifyStateAction")

ActionTimelineNotify.ActionTimelineNotifyStateAction = ActionTimelineNotifyStateAction

function ActionTimelineNotifyStateAction:ctor(timelineEvent, idx)
	self.tickInterval = math.max(timelineEvent.tickInterval or 0.1, 0.03)
	self.startTime = timelineEvent.startTime
	self.endTime = timelineEvent.endTime
	self.timelineEvent = timelineEvent
	self.stateIdx = idx
	self.enterTimelineEventStr = "NotifyStateEnter" .. tostring(self.startTime)
	self.exitTimelineEventStr = "NotifyStateExit" .. tostring(self.endTime)
end

function ActionTimelineNotifyStateAction:executeNotifyStateEnter(entity, combatContext, startGameTime)
	local onEnterAction = self.timelineEvent.onEnter

	if not onEnterAction then
		return false
	end

	if not combatContext then
		return false
	end

	combatContext:pushNodeIdToStack(self.timelineEvent.NodeID)

	combatContext.overrideGameTime = startGameTime + self.startTime
	combatContext.timelineEventStr = self.enterTimelineEventStr

	local result = entity.combatAction:doActions(onEnterAction, combatContext)

	combatContext.timelineEventStr = nil
	combatContext.overrideGameTime = nil

	combatContext:popNodeIdFromStack()

	return result
end

function ActionTimelineNotifyStateAction:executeNotifyStateUpdate(entity, combatContext, curTimeStep, lastTickTime, startGameTime, tickCnt)
	local updateAction = self.timelineEvent.onUpdate

	if not updateAction then
		return false
	end

	if not combatContext then
		return false
	end

	local deltaSeconds = math.fixedFloat(curTimeStep - lastTickTime)
	local result = deltaSeconds >= self.tickInterval

	while deltaSeconds >= self.tickInterval do
		lastTickTime = lastTickTime + self.tickInterval

		combatContext:pushNodeIdToStack(self.timelineEvent.NodeID)

		combatContext.overrideGameTime = startGameTime + lastTickTime
		tickCnt = tickCnt + 1
		combatContext.timelineEventStr = tostring(tickCnt)

		entity.combatAction:doActions(updateAction, combatContext)

		combatContext.timelineEventStr = nil
		combatContext.overrideGameTime = nil

		combatContext:popNodeIdFromStack()

		deltaSeconds = deltaSeconds - self.tickInterval
	end

	return result, lastTickTime, tickCnt
end

function ActionTimelineNotifyStateAction:executeNotifyStateExit(entity, combatContext)
	local exitAction = self.timelineEvent.onExit

	if not exitAction then
		return false
	end

	if not combatContext then
		return false
	end

	combatContext:pushNodeIdToStack(self.timelineEvent.NodeID)

	combatContext.timelineEventStr = self.exitTimelineEventStr

	local result = entity.combatAction:doActions(exitAction, combatContext)

	combatContext.timelineEventStr = nil

	combatContext:popNodeIdFromStack()

	return result
end

local ActionTimelineNotifyStateTimeNode = Class.LiteClass("ActionTimelineNotifyNode")

ActionTimelineNotify.ActionTimelineNotifyStateTimeNode = ActionTimelineNotifyStateTimeNode

function ActionTimelineNotifyStateTimeNode:ctor(time, nodeType, notifyState)
	self.time = time
	self.nodeType = nodeType
	self.notifyState = notifyState
end

return ActionTimelineNotify
