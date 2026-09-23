-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\TimelineTemplate.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ActionTimelineNotify = require("Common.Ability.Timeline.ActionTimelineNotify")
local LoggerManager = require("Core.Log.LoggerManager")
local CombatLogger = require("Common.Ability.CombatLogger")
local TimelineTemplate = Class.LiteClass("TimelineTemplate")

function TimelineTemplate:ctor(id, timelineData)
	self.nodeMap = timelineData.nodeMap
	self.id = id
	self.layer = timelineData.layer
	self.length = timelineData.length

	if pg.component == "game" and self.length ~= -1 then
		self.length = timelineData.length + AbilityConst.MAX_DELAY_TIME
	end

	self.loop = timelineData.loop
	self.maxLoopCnt = timelineData.maxLoopCnt or 0
	self.BPName = timelineData.BPName

	if timelineData.isSkillTimeline == false then
		self.isSkillTimeline = false
	else
		self.isSkillTimeline = true
	end

	self.timelineEnterEvents = {}
	self.timelineExitEvents = {}
	self.timelineNotifyEvents = {}

	local timelineNotifyStateEvents = {}

	for index, eventId in ipairs(timelineData.eventIds) do
		local event = timelineData.nodeMap[eventId]
		local eventType = event.eventType

		if eventType == AbilityConst.TIMELINE_EVENT_ENTER then
			self.timelineEnterEvents[#self.timelineEnterEvents + 1] = ActionTimelineNotify.ActionTimelineNotifyEvent(event)
		elseif eventType == AbilityConst.TIMELINE_EVENT_EXIT then
			self.timelineExitEvents[#self.timelineExitEvents + 1] = ActionTimelineNotify.ActionTimelineNotifyEvent(event)
		elseif eventType == AbilityConst.TIMELINE_EVENT_NOTIFY then
			self.timelineNotifyEvents[#self.timelineNotifyEvents + 1] = ActionTimelineNotify.ActionTimelineNotifyAction(event, index)
		elseif eventType == AbilityConst.TIMELINE_EVENT_NOTIFY_STATE then
			local idx = #timelineNotifyStateEvents + 1

			timelineNotifyStateEvents[idx] = ActionTimelineNotify.ActionTimelineNotifyStateAction(event, idx)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("Unknown event type: " .. eventType)
		end
	end

	table.sort(self.timelineNotifyEvents, TimelineTemplate.sortNotifyEvent)

	self.timelineNotifyStateNodes = {}

	for _, notifyStateA in ipairs(timelineNotifyStateEvents) do
		table.insert(self.timelineNotifyStateNodes, ActionTimelineNotify.ActionTimelineNotifyStateTimeNode(notifyStateA.startTime, AbilityConst.NOTIFY_STATE_TIME_NODE_ENTER, notifyStateA))
		table.insert(self.timelineNotifyStateNodes, ActionTimelineNotify.ActionTimelineNotifyStateTimeNode(notifyStateA.endTime, AbilityConst.NOTIFY_STATE_TIME_NODE_EXIT, notifyStateA))
	end

	table.sort(self.timelineNotifyStateNodes, TimelineTemplate.sortTimeNode)
end

function TimelineTemplate.sortNotifyEvent(a, b)
	local timeA = a.time or 0
	local timeB = b.time or 0

	if timeA == timeB then
		return a.index < b.index
	end

	return timeA < timeB
end

function TimelineTemplate.sortTimeNode(a, b)
	return (a.time or 0) < (b.time or 0)
end

return TimelineTemplate
