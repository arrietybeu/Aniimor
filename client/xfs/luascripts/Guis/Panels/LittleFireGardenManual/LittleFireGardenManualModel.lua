-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LittleFireGardenManual\\LittleFireGardenManualModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local LittleFireGardenManualModel = Class.LightClass("LittleFireGardenManualModel", UIModel)

LittleFireGardenManualModel.TASK_TYPE_SORT_PRI = {
	[ActivityConst.ActivityTaskType.Active_DailyTask] = 1,
	[ActivityConst.ActivityTaskType.Active_WeeklyTask] = 2,
	[ActivityConst.ActivityTaskType.Active_AchievementTask] = 3
}

function LittleFireGardenManualModel._getTaskStateSortPri(taskState)
	if taskState == ActivityConst.TaskState.Finihed_CanRecv then
		return 1
	end

	if taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail then
		return 3
	end

	return 2
end

function LittleFireGardenManualModel._compareTask(a, b)
	if a.stateSortPri ~= b.stateSortPri then
		return a.stateSortPri < b.stateSortPri
	end

	if a.typeSortPri ~= b.typeSortPri then
		return a.typeSortPri < b.typeSortPri
	end

	return a.taskId < b.taskId
end

function LittleFireGardenManualModel:_collectSortedTasks()
	local tasks = {}
	local actType = ActivityConst.EventType.LittleFirePerson

	for taskType, typeSortPri in pairs(LittleFireGardenManualModel.TASK_TYPE_SORT_PRI) do
		local taskInfoList = ClientActivityUtils.getTaskInfoByTaskType(actType, taskType)

		for _, taskInfo in ipairs(taskInfoList) do
			tasks[#tasks + 1] = {
				taskId = taskInfo.taskId or 0,
				taskInfo = taskInfo,
				stateSortPri = LittleFireGardenManualModel._getTaskStateSortPri(taskInfo.taskState),
				typeSortPri = typeSortPri
			}
		end
	end

	table.sort(tasks, LittleFireGardenManualModel._compareTask)

	return tasks
end

function LittleFireGardenManualModel:getTaskList()
	return self:_collectSortedTasks()
end

function LittleFireGardenManualModel:getRankList(eventId)
	return ClientActivityUtils.getLittleFirePersonRankList(eventId)
end

return LittleFireGardenManualModel
