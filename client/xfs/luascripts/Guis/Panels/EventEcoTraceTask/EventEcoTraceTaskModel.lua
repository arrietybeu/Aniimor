-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceTask\\EventEcoTraceTaskModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local EcotraceChapterData = require("Data.ecotrace_chapter_data")
local EventTaskData = require("Data.event_task_data")
local EventEcoTraceTaskModel = Class.LightClass("EventEcoTraceTaskModel", UIModel)
local _ecoTraceActTaskTypeMap = {
	81,
	82,
	83
}

function EventEcoTraceTaskModel:getActTaskType(taskType)
	return _ecoTraceActTaskTypeMap[taskType] or taskType
end

function EventEcoTraceTaskModel:isTaskComplete(taskState)
	return taskState and taskState >= ActivityConst.TaskState.Finihed_CanRecv or false
end

function EventEcoTraceTaskModel:isTaskRewardReceivedByState(taskState)
	return taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail
end

function EventEcoTraceTaskModel:getTaskGroupId()
	local activityCfg = ClientActivityUtils.getEcoTraceActivityCfg()

	return activityCfg and activityCfg.questGroupId
end

function EventEcoTraceTaskModel:getTaskCfgDic(type)
	local questDic = {}
	local taskGroupId = self:getTaskGroupId()
	local taskInfos = ClientActivityUtils.getTaskInfoList(taskGroupId, true)

	for _, taskInfo in ipairs(taskInfos) do
		local taskType = taskInfo.taskType

		if taskType then
			questDic[taskType] = questDic[taskType] or {}
			taskInfo.isComplete = self:isTaskComplete(taskInfo.taskState)
			taskInfo.hasGet = self:isTaskRewardReceivedByState(taskInfo.taskState)

			table.insert(questDic[taskType], taskInfo)
		end
	end

	for _, taskCfgs in pairs(questDic) do
		table.sort(taskCfgs, function(a, b)
			if a.hasGet ~= b.hasGet then
				return not a.hasGet
			end

			if not a.hasGet and a.isComplete ~= b.isComplete then
				return a.isComplete
			end

			return a.showIndex < b.showIndex
		end)
	end

	return type and questDic[self:getActTaskType(type)] or questDic
end

function EventEcoTraceTaskModel:getTaskCompleteNum(type)
	local questInfos = self:getTaskCfgDic(type)
	local completeNum = 0
	local canGet = false

	if questInfos and next(questInfos) then
		for _, questInfo in pairs(questInfos) do
			if questInfo.isComplete then
				if not questInfo.hasGet then
					canGet = true
				end

				completeNum = completeNum + 1
			end
		end
	end

	return completeNum, canGet
end

function EventEcoTraceTaskModel:getTaskState(taskId)
	return ActivityUtils.getActTaskState(pg.me, taskId)
end

function EventEcoTraceTaskModel:isTaskRewardReceived(taskId)
	return self:isTaskRewardReceivedByState(self:getTaskState(taskId))
end

function EventEcoTraceTaskModel:isGetQuestReward(taskId)
	return self:isTaskRewardReceived(taskId)
end

function EventEcoTraceTaskModel:getChapterCfg()
	local cfgs = {}
	local chosedPetId = ClientActivityUtils.getEcoTracePetId()
	local phaseCfg = EcotraceChapterData[ClientActivityUtils.getEcoTraceActivityPhase()] or {}

	for i, v in pairs(phaseCfg) do
		if v.petId == chosedPetId then
			cfgs[i] = v
		end
	end

	return cfgs
end

function EventEcoTraceTaskModel:getChapterTaskInfo(chapterCfg)
	local chapterTaskId = chapterCfg and chapterCfg.taskId
	local taskCfg = chapterTaskId and EventTaskData[chapterTaskId]

	if not taskCfg then
		return nil
	end

	local taskState = self:getTaskState(chapterTaskId)
	local triggerMap = pg.me and pg.me.triggerMap
	local maxCount = taskCfg.taskFinishCnt or triggerMap and triggerMap:getConditionTargetCount(taskCfg.taskCondition, 1) or 0
	local completeNum = self:getTaskCompleteNum(chapterCfg.taskType)

	return {
		taskId = chapterTaskId,
		taskAward = taskCfg.award,
		taskState = taskState,
		completeNum = completeNum,
		maxCount = maxCount,
		canGet = taskState == ActivityConst.TaskState.Finihed_CanRecv,
		hasGet = self:isTaskRewardReceivedByState(taskState)
	}
end

function EventEcoTraceTaskModel:getTaskCompleteInfo()
	local maxCount = 0
	local completeNumCount = 0
	local chapterCfg = self:getChapterCfg()

	if chapterCfg and next(chapterCfg) then
		for _, cfg in pairs(chapterCfg) do
			local chapterTaskInfo = self:getChapterTaskInfo(cfg)

			if chapterTaskInfo then
				maxCount = maxCount + chapterTaskInfo.maxCount
				completeNumCount = completeNumCount + math.min(chapterTaskInfo.completeNum, chapterTaskInfo.maxCount)
			end
		end
	end

	return completeNumCount, maxCount
end

function EventEcoTraceTaskModel:getResearchCompleteInfo()
	local taskCompleteNum = self:getTaskCompleteInfo()
	local activityCfg = ClientActivityUtils.getEcoTraceActivityCfg()
	local projectBoost = activityCfg and activityCfg.projectBoost or {}
	local maxCount = #projectBoost
	local completeNumCount = 0
	local remainTaskNum = math.max(tonumber(taskCompleteNum) or 0, 0)

	for _, stageCfg in ipairs(projectBoost) do
		local stageTaskNum = math.max(tonumber(stageCfg and stageCfg[1]) or 0, 0)

		if stageTaskNum <= 0 or remainTaskNum < stageTaskNum then
			break
		end

		remainTaskNum = remainTaskNum - stageTaskNum
		completeNumCount = completeNumCount + 1
	end

	return completeNumCount, maxCount
end

function EventEcoTraceTaskModel:hasRewardCanGet()
	local chapterCfg = self:getChapterCfg()

	for _, cfg in pairs(chapterCfg) do
		local chapterTaskInfo = self:getChapterTaskInfo(cfg)

		if chapterTaskInfo and chapterTaskInfo.canGet then
			return true
		end

		local _, canGetChild = self:getTaskCompleteNum(cfg.taskType)

		if canGetChild then
			return true
		end
	end

	return false
end

return EventEcoTraceTaskModel
