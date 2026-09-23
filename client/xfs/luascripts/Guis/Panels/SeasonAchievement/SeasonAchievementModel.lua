-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonAchievement\\SeasonAchievementModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ActivityConst = require("Common.Const.ActivityConst")
local TriggerConst = require("Common.Const.TriggerConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local Utils = require("Common.Utils.Utils")
local RedDotConst = require("Const.RedDotConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local EventSeasonAchievementData = require("Data.event_season_achievement_data")
local EventTaskData = require("Data.event_task_data")
local ItemSourceData = require("Data.item_source_data")
local SeasonAchievementModel = Class.LightClass("SeasonAchievementModel", UIModel)
local MANUAL_DEFINITIONS = {
	{
		manualBgMarkPic = "$UI_Img_Event_Season_Achievement_TaskMask1.png",
		manualTitleName = "SEASON_TASKTYPE1",
		taskGroupField = "petTaskGroup",
		manualIconBgPic = "$UI_Img_Event_Season_Achievement_TaskTitle1.png",
		manualTipsOpenPic = "$UI_Img_Event_Season_Achievement_TaskText1_1.png",
		manualTipsPic = "$UI_Img_Event_Season_Achievement_TaskText1.png",
		manualTitleOpenPic = "$UI_Img_Event_Season_Achievement_TaskBtnOpen1.png",
		manualIcon = "$UI_Img_Event_Season_Achievement_TaskIcon1.png",
		manualTitlePic = "$UI_Img_Event_Season_Achievement_TaskBtn1.png",
		subTaskType = ActivityConst.ActivityTaskSubType.AchiTask_SeasonAchieve_Emo
	},
	{
		manualBgMarkPic = "$UI_Img_Event_Season_Achievement_TaskMask2.png",
		manualTitleName = "SEASON_TASKTYPE2",
		taskGroupField = "battleTaskGroup",
		manualIconBgPic = "$UI_Img_Event_Season_Achievement_TaskTitle2.png",
		manualTipsOpenPic = "$UI_Img_Event_Season_Achievement_TaskText2_1.png",
		manualTipsPic = "$UI_Img_Event_Season_Achievement_TaskText2.png",
		manualTitleOpenPic = "$UI_Img_Event_Season_Achievement_TaskBtnOpen2.png",
		manualIcon = "$UI_Img_Event_Season_Achievement_TaskIcon2.png",
		manualTitlePic = "$UI_Img_Event_Season_Achievement_TaskBtn2.png",
		subTaskType = ActivityConst.ActivityTaskSubType.AchiTask_SeasonAchieve_Battle
	},
	{
		manualBgMarkPic = "$UI_Img_Event_Season_Achievement_TaskMask3.png",
		manualTitleName = "SEASON_TASKTYPE3",
		taskGroupField = "eggTaskGroup",
		manualIconBgPic = "$UI_Img_Event_Season_Achievement_TaskTitle3.png",
		manualTipsOpenPic = "$UI_Img_Event_Season_Achievement_TaskText3_1.png",
		manualTipsPic = "$UI_Img_Event_Season_Achievement_TaskText3.png",
		manualTitleOpenPic = "$UI_Img_Event_Season_Achievement_TaskBtnOpen3.png",
		manualIcon = "$UI_Img_Event_Season_Achievement_TaskIcon3.png",
		manualTitlePic = "$UI_Img_Event_Season_Achievement_TaskBtn3.png",
		subTaskType = ActivityConst.ActivityTaskSubType.AchiTask_SeasonAchieve_Rogg
	},
	{
		manualBgMarkPic = "$UI_Img_Event_Season_Achievement_TaskMask4.png",
		manualTitleName = "SEASON_TASKTYPE4",
		taskGroupField = "homeTaskGroup",
		manualIconBgPic = "$UI_Img_Event_Season_Achievement_TaskTitle4.png",
		manualTipsOpenPic = "$UI_Img_Event_Season_Achievement_TaskText4_1.png",
		manualTipsPic = "$UI_Img_Event_Season_Achievement_TaskText4.png",
		manualTitleOpenPic = "$UI_Img_Event_Season_Achievement_TaskBtnOpen4.png",
		manualIcon = "$UI_Img_Event_Season_Achievement_TaskIcon4.png",
		manualTitlePic = "$UI_Img_Event_Season_Achievement_TaskBtn4.png",
		subTaskType = ActivityConst.ActivityTaskSubType.AchiTask_SeasonAchieve_Home
	}
}

function SeasonAchievementModel:getOpenActivityIdByType(activityType)
	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(activityType, pg.me)

	if not isOpen or not activityId or not ClientActivityUtils.isGameEventTabOpen(activityId) then
		return nil
	end

	return activityId
end

function SeasonAchievementModel:getActivityId()
	return self:getOpenActivityIdByType(ActivityConst.EventType.SeasonAchievements)
end

function SeasonAchievementModel:isSeasonAchievementActivityOpen()
	return self:getActivityId() ~= nil
end

function SeasonAchievementModel:getActivityEndTime()
	local activityId = self:getActivityId()
	local timeConfig = activityId and Utils.getEventTimeConfig(activityId)

	return timeConfig and timeConfig.tabEndDayTime
end

function SeasonAchievementModel:getHeaderInfo()
	local activityId = self:getActivityId()
	local activityConfig = activityId and EventSeasonAchievementData[activityId]
	local seasonStageInfo = Utils.getCurrentSeasonStage()

	return {
		titleTextId = activityConfig and activityConfig.title,
		seasonTagIcon = seasonStageInfo and seasonStageInfo.seasonTagIcon or "",
		seasonTagTextId = seasonStageInfo and seasonStageInfo.seasonTagTextId
	}
end

function SeasonAchievementModel:getBadgeSourceData()
	local activityId = self:getActivityId()
	local activityConfig = activityId and EventSeasonAchievementData[activityId]
	local badgeSourceId = activityConfig and activityConfig.badgeSource

	return badgeSourceId and ItemSourceData[badgeSourceId]
end

function SeasonAchievementModel:getSeasonAchievementPoints()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.SeasonAchievements)

	return activityData and activityData.seasonAchivePoints or 0
end

function SeasonAchievementModel:_getTaskState(taskId)
	return ActivityUtils.getActTaskState(pg.me, taskId) or ActivityConst.TaskState.UnFinished
end

function SeasonAchievementModel:_getDisplayState(taskState)
	if taskState == ActivityConst.TaskState.Finihed_CanRecv then
		return 1
	end

	if taskState >= ActivityConst.TaskState.Received then
		return 2
	end

	return 0
end

function SeasonAchievementModel:_getTaskProgress(taskConfig, taskState)
	if not taskConfig or not pg.me or not pg.me.triggerMap then
		return 0, 0
	end

	local conditionId = taskConfig.taskCondition
	local target = conditionId and pg.me.triggerMap:getConditionTargetCount(conditionId, 1) or 0
	local progress = conditionId and pg.me.triggerMap:getConditionFinishCount(conditionId, 1) or 0

	if taskState >= ActivityConst.TaskState.Finihed_CanRecv then
		progress = target
	end

	return progress or 0, target or 0
end

function SeasonAchievementModel:_getSortedTaskIds(taskGroupId)
	local taskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroupId) or {}
	local sortedTaskIds = {}

	for _, taskId in ipairs(taskIds) do
		if EventTaskData[taskId] then
			sortedTaskIds[#sortedTaskIds + 1] = taskId
		end
	end

	table.sort(sortedTaskIds, function(leftTaskId, rightTaskId)
		local leftConfig = EventTaskData[leftTaskId]
		local rightConfig = EventTaskData[rightTaskId]
		local leftSort = leftConfig.sort or leftTaskId
		local rightSort = rightConfig.sort or rightTaskId

		if leftSort ~= rightSort then
			return leftSort < rightSort
		end

		return leftTaskId < rightTaskId
	end)

	return sortedTaskIds
end

function SeasonAchievementModel:_getMileageTaskGroupId(activityId)
	for _, taskConfig in pairs(EventTaskData) do
		if taskConfig.activityId == activityId and taskConfig.actTaskType == ActivityConst.ActivityTaskType.Active_AchievementTask and taskConfig.actSubTaskType == ActivityConst.ActivityTaskSubType.AchiTask_SeasonAchieve_Mileage then
			return taskConfig.groupId
		end
	end

	return nil
end

function SeasonAchievementModel:getStageRewards()
	local activityId = self:getActivityId()
	local taskGroupId = activityId and self:_getMileageTaskGroupId(activityId)
	local rewards = {}

	for index, taskId in ipairs(self:_getSortedTaskIds(taskGroupId)) do
		local taskConfig = EventTaskData[taskId]
		local taskState = self:_getTaskState(taskId)
		local _, target = self:_getTaskProgress(taskConfig, taskState)

		rewards[#rewards + 1] = {
			taskId = taskId,
			taskGroupId = taskGroupId,
			sort = taskConfig.sort or index,
			target = target,
			award = taskConfig.award,
			taskState = taskState,
			displayState = self:_getDisplayState(taskState),
			isStageReward = taskConfig.specShow == 1
		}
	end

	return rewards
end

function SeasonAchievementModel:getAchievementPointItemId()
	local activityId = self:getActivityId()
	local taskGroupId = activityId and self:_getMileageTaskGroupId(activityId)

	for _, taskId in ipairs(self:_getSortedTaskIds(taskGroupId)) do
		local taskConfig = EventTaskData[taskId]
		local triggerConfig = taskConfig and CustomTriggerData[taskConfig.taskCondition]

		for _, condition in ipairs(triggerConfig and triggerConfig.condition or {}) do
			if TriggerUtils.getTriggerType(condition) == TriggerConst.TRIGGER_TARGET_GET_ITEMS then
				return condition[TriggerConst.CUSTOM_TRIGGER_TARGET_POS]
			end
		end
	end

	return nil
end

function SeasonAchievementModel:getReceivableStageRewardIndex(stageRewards)
	for index, rewardData in ipairs(stageRewards or {}) do
		if rewardData.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			return index
		end
	end

	return nil
end

function SeasonAchievementModel:getCurrentStageRewardIndex(stageRewards)
	local rewardCount = #(stageRewards or {})

	if rewardCount == 0 then
		return nil
	end

	for index, rewardData in ipairs(stageRewards) do
		if rewardData.taskState < ActivityConst.TaskState.Received then
			return index
		end
	end

	return rewardCount
end

function SeasonAchievementModel:getReceivableGameplayIndex(gameplayRows)
	for index, manualData in ipairs(gameplayRows or {}) do
		if #self:getCanReceiveTaskGroupIds(manualData) > 0 then
			return index
		end
	end

	return nil
end

function SeasonAchievementModel:getRewardListInitialIndex(stageRewards)
	local rewardCount = #(stageRewards or {})

	if rewardCount <= 1 then
		return 0
	end

	local currentRewardIndex = self:getCurrentStageRewardIndex(stageRewards) or rewardCount

	return math.max(0, currentRewardIndex - 2)
end

function SeasonAchievementModel:getTotalMilestone(stageRewards)
	stageRewards = stageRewards or self:getStageRewards()

	local points = self:getSeasonAchievementPoints()
	local level = 0
	local previousTarget = 0
	local nextTarget = 0

	for _, rewardData in ipairs(stageRewards) do
		if points >= rewardData.target then
			level = rewardData.sort
			previousTarget = rewardData.target
		else
			nextTarget = rewardData.target

			break
		end
	end

	if nextTarget == 0 then
		local lastReward = stageRewards[#stageRewards]
		local previousReward = stageRewards[#stageRewards - 1]

		nextTarget = lastReward and lastReward.target or points
		previousTarget = previousReward and previousReward.target or 0
	end

	local requiredInLevel = math.max(0, nextTarget - previousTarget)
	local currentInLevel = math.max(0, math.min(requiredInLevel, points - previousTarget))
	local hasRewards = #stageRewards > 0
	local normalizedProgress = hasRewards and (requiredInLevel > 0 and currentInLevel / requiredInLevel or 1) or 0

	return {
		level = level,
		points = points,
		current = currentInLevel,
		target = requiredInLevel,
		normalizedProgress = normalizedProgress
	}
end

function SeasonAchievementModel:_getActivityConfig()
	local activityId = self:getActivityId()

	return activityId and EventSeasonAchievementData[activityId]
end

function SeasonAchievementModel:_getManualProgress(taskGroupIds)
	local completedCount = 0
	local totalCount = 0

	for _, taskGroupId in ipairs(taskGroupIds or {}) do
		local taskIds = self:_getSortedTaskIds(taskGroupId)

		totalCount = totalCount + #taskIds

		for _, taskId in ipairs(taskIds) do
			if self:_getTaskState(taskId) >= ActivityConst.TaskState.Finihed_CanRecv then
				completedCount = completedCount + 1
			end
		end
	end

	return completedCount, totalCount
end

function SeasonAchievementModel:getGameplayRows()
	local activityConfig = self:_getActivityConfig()
	local rows = {}

	for index, definition in ipairs(MANUAL_DEFINITIONS) do
		local taskGroupIds = activityConfig and activityConfig[definition.taskGroupField] or {}
		local completedCount, totalCount = self:_getManualProgress(taskGroupIds)

		rows[#rows + 1] = {
			manualIndex = index,
			subTaskType = definition.subTaskType,
			taskGroupIds = taskGroupIds,
			manualTitleName = definition.manualTitleName,
			manualTitlePic = definition.manualTitlePic,
			manualTitleOpenPic = definition.manualTitleOpenPic,
			manualIcon = definition.manualIcon,
			manualTipsPic = definition.manualTipsPic,
			manualTipsOpenPic = definition.manualTipsOpenPic,
			manualIconBgPic = definition.manualIconBgPic,
			manualBgMarkPic = definition.manualBgMarkPic,
			completedCount = completedCount,
			totalCount = totalCount,
			progressPercent = totalCount > 0 and math.floor(completedCount * 100 / totalCount) or 0
		}
	end

	return rows
end

function SeasonAchievementModel:_isPreviousTaskFinished(taskConfig)
	if not taskConfig or not taskConfig.preTaskId then
		return true
	end

	local previousState = ActivityUtils.getActTaskState(pg.me, taskConfig.preTaskId)

	return previousState and previousState >= ActivityConst.TaskState.Received
end

function SeasonAchievementModel:_getCurrentTaskData(taskGroupId, manualIndex, manualBgMarkPic)
	local taskIds = self:_getSortedTaskIds(taskGroupId)
	local selectedTaskId, selectedIndex

	for index, taskId in ipairs(taskIds) do
		local taskConfig = EventTaskData[taskId]
		local taskState = ActivityUtils.getActTaskState(pg.me, taskId)
		local notReceived = not taskState or taskState < ActivityConst.TaskState.Received

		if notReceived and self:_isPreviousTaskFinished(taskConfig) then
			selectedTaskId = taskId
			selectedIndex = index

			break
		end
	end

	if not selectedTaskId then
		selectedTaskId = taskIds[#taskIds]
		selectedIndex = #taskIds
	end

	if not selectedTaskId then
		return nil
	end

	local taskConfig = EventTaskData[selectedTaskId]
	local taskState = self:_getTaskState(selectedTaskId)
	local progress, target = self:_getTaskProgress(taskConfig, taskState)

	return {
		taskId = selectedTaskId,
		taskGroupId = taskGroupId,
		manualIndex = manualIndex,
		config = taskConfig,
		taskState = taskState,
		displayState = self:_getDisplayState(taskState),
		progress = progress,
		target = target,
		stage = selectedIndex,
		totalStage = #taskIds,
		taskDescriptionTextId = taskConfig.taskDes,
		award = taskConfig.award,
		manualBgMarkPic = manualBgMarkPic,
		sourceData = taskConfig.sourceId and ItemSourceData[taskConfig.sourceId],
		taskEvent = taskConfig.eventId or taskConfig.event
	}
end

function SeasonAchievementModel:getManualTaskGroups(manualData)
	local taskGroups = {}

	for _, taskGroupId in ipairs(manualData and manualData.taskGroupIds or {}) do
		local taskData = self:_getCurrentTaskData(taskGroupId, manualData.manualIndex, manualData.manualBgMarkPic)

		if taskData then
			taskGroups[#taskGroups + 1] = taskData
		end
	end

	return taskGroups
end

function SeasonAchievementModel:getCanReceiveTaskGroupIds(manualData)
	local taskGroupIds = {}

	for _, taskGroupId in ipairs(manualData and manualData.taskGroupIds or {}) do
		if #ActivityUtils.getActTaskCanReceiveByGroupId(pg.me, taskGroupId) > 0 then
			taskGroupIds[#taskGroupIds + 1] = taskGroupId
		end
	end

	return taskGroupIds
end

function SeasonAchievementModel:hasCanReceiveManualRewardInRange(manualRows, startIndex, endIndex)
	if not manualRows or not startIndex or not endIndex or endIndex < startIndex then
		return false
	end

	for index = startIndex, endIndex do
		if #self:getCanReceiveTaskGroupIds(manualRows[index]) > 0 then
			return true
		end
	end

	return false
end

function SeasonAchievementModel:getStageRewardRedDotStyle()
	local activityId = self:getActivityId()
	local taskGroupId = activityId and self:_getMileageTaskGroupId(activityId)

	for _, taskId in ipairs(self:_getSortedTaskIds(taskGroupId)) do
		if self:_getTaskState(taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function SeasonAchievementModel:getManualRewardRedDotStyle()
	for _, manualData in ipairs(self:getGameplayRows()) do
		if #self:getCanReceiveTaskGroupIds(manualData) > 0 then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function SeasonAchievementModel:getEntryRedDotStyle()
	local styleList = {
		self:getStageRewardRedDotStyle(),
		self:getManualRewardRedDotStyle()
	}

	return pg.global.calculateRedDotPriority(styleList)
end

return SeasonAchievementModel
