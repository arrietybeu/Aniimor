-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventTaskPanel\\EventTaskPanelModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ActivityConst = require("Common.Const.ActivityConst")
local GameEventData = require("Data.game_event_data")
local EventTaskData = require("Data.event_task_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local EventTaskPanelModel = Class.LightClass("EventTaskPanelModel", UIModel)

function EventTaskPanelModel:ctor()
	self.eventIds = {}
end

function EventTaskPanelModel:setEventIds(eventIds)
	self.eventIds = eventIds or {}
end

function EventTaskPanelModel:_getActDataByEventId(eventId)
	local eventCfg = GameEventData[eventId]

	if not eventCfg then
		return nil
	end

	local attrName = ActivityConst.NewFrameEventAttriName[eventCfg.eventType]

	if not attrName then
		return nil
	end

	return pg.me and pg.me[attrName]
end

function EventTaskPanelModel:getTaskList()
	local list = {}

	if not pg.me or not pg.me.triggerMap then
		return list
	end

	local triggerMap = pg.me.triggerMap

	for _, eventId in ipairs(self.eventIds) do
		local eventData = GameEventData[eventId]
		local eventType = eventData and eventData.eventType

		if eventData and eventType then
			local taskMap = ActivityUtils.getActTaskMap(pg.me, eventType)

			if taskMap then
				for taskId, taskInfo in pairs(taskMap) do
					local config = EventTaskData[taskId]

					if config then
						local progress = triggerMap:getConditionFinishCount(config.taskCondition, 1) or 0
						local target = triggerMap:getConditionTargetCount(config.taskCondition, 1) or 0

						table.insert(list, {
							eventId = eventId,
							taskId = taskId,
							cfg = config,
							state = taskInfo.state,
							progress = taskInfo.state ~= ActivityConst.TaskState.UnFinished and target or progress,
							target = target
						})
					end
				end
			end
		end
	end

	local sortPri = ActivityConst.TaskSortPri or {}

	table.sort(list, function(a, b)
		local pa = sortPri[a.state] or 0
		local pb = sortPri[b.state] or 0

		if pa ~= pb then
			return pb < pa
		end

		if a.eventId ~= b.eventId then
			return a.eventId < b.eventId
		end

		return a.taskId < b.taskId
	end)

	return list
end

return EventTaskPanelModel
