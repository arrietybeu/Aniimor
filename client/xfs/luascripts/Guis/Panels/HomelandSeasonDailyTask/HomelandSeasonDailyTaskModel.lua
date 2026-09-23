-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonDailyTask\\HomelandSeasonDailyTaskModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local Const = require("Common.Const.Const")
local ActivityConst = require("Common.Const.ActivityConst")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local HomeSeasonDailyTaskData = require("Data.home_season_daily_task_data")
local HomelandSeasonDailyTaskModel = Class.LightClass("HomelandSeasonDailyTaskModel", UIModel)

HomelandSeasonDailyTaskModel.TASK_CONDITION_INDEX = 1
HomelandSeasonDailyTaskModel.UNREADY_SORT_PRIORITY = -1

function HomelandSeasonDailyTaskModel:ctor()
	UIModel.ctor(self)

	self.seasonId = nil
	self.stageId = nil
	self.moduleId = nil
	self.moduleConfig = nil
	self.taskList = {}
end

function HomelandSeasonDailyTaskModel.isTaskInStage(taskConfig, stageId)
	local configuredStageIds = taskConfig.stageId
	local configuredStageIdsType = type(configuredStageIds)

	if configuredStageIdsType == "number" then
		return configuredStageIds == stageId
	end

	if configuredStageIdsType ~= "table" and configuredStageIdsType ~= "userdata" then
		return false
	end

	for _, configuredStageId in pairs(configuredStageIds) do
		if configuredStageId == stageId then
			return true
		end
	end

	return false
end

function HomelandSeasonDailyTaskModel.getTaskProgress(taskConfig, taskState, player)
	if taskState ~= ActivityConst.TaskState.UnFinished then
		return taskConfig.targetValue
	end

	local progress = player.triggerMap:getConditionFinishCount(taskConfig.targetId, HomelandSeasonDailyTaskModel.TASK_CONDITION_INDEX)

	return math.min(progress, taskConfig.targetValue)
end

function HomelandSeasonDailyTaskModel.getTaskSortPriority(taskData)
	if taskData.canReceive then
		return ActivityConst.TaskSortPri[ActivityConst.TaskState.Finihed_CanRecv]
	end

	if not taskData.isReady then
		return HomelandSeasonDailyTaskModel.UNREADY_SORT_PRIORITY
	end

	return ActivityConst.TaskSortPri[taskData.taskState]
end

function HomelandSeasonDailyTaskModel.sortTaskViewData(a, b)
	local aPriority = HomelandSeasonDailyTaskModel.getTaskSortPriority(a)
	local bPriority = HomelandSeasonDailyTaskModel.getTaskSortPriority(b)

	if aPriority ~= bPriority then
		return bPriority < aPriority
	end

	return a.taskId < b.taskId
end

function HomelandSeasonDailyTaskModel:buildTaskViewData(player)
	local viewData = {}
	local taskStateMap = player.homeSeasonTaskStateMap
	local pendingRewardMap = player.homeSeasonTaskPendingRewardMap

	for taskId, taskConfig in pairs(HomeSeasonDailyTaskData) do
		local pendingRewardCount = pendingRewardMap and pendingRewardMap[taskId] or 0

		if taskConfig.seasonId == self.seasonId and (pendingRewardCount > 0 or HomelandSeasonDailyTaskModel.isTaskInStage(taskConfig, self.stageId)) then
			local taskState = taskStateMap and taskStateMap[taskId] or nil
			local isReady = taskState ~= nil or pendingRewardCount > 0
			local canReceive = pendingRewardCount > 0 or taskState == ActivityConst.TaskState.Finihed_CanRecv
			local hasReceived = pendingRewardCount == 0 and (taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail)
			local progress

			if pendingRewardCount > 0 then
				progress = taskConfig.targetValue
			elseif taskState ~= nil then
				progress = HomelandSeasonDailyTaskModel.getTaskProgress(taskConfig, taskState, player)
			end

			viewData[#viewData + 1] = {
				taskId = taskId,
				description = taskConfig.des,
				progress = progress,
				target = taskConfig.targetValue,
				rewardId = taskConfig.reward,
				taskState = taskState,
				canReceive = canReceive,
				hasReceived = hasReceived,
				isReady = isReady,
				sourceId = taskConfig.sourceId
			}
		end
	end

	table.sort(viewData, HomelandSeasonDailyTaskModel.sortTaskViewData)

	return viewData
end

function HomelandSeasonDailyTaskModel:refreshTaskData(moduleId)
	local player = pg.me

	self.seasonId = player and player.homeSeasonId or nil
	self.stageId = player and player.homeSeasonStageId or nil
	self.moduleId = nil
	self.moduleConfig = nil
	self.taskList = {}

	if not HomeSeasonUtils.isSeasonAvailable(player) then
		return self.taskList
	end

	local moduleConfig = HomeSeasonModuleData[moduleId]

	if not moduleConfig or moduleConfig.type ~= Const.HOMELAND_SEASON_MODULE_TYPE.DAILY_QUEST or not HomeSeasonUtils.isModuleOpen(self.seasonId, moduleId) then
		return self.taskList
	end

	self.moduleId = moduleId
	self.moduleConfig = moduleConfig
	self.taskList = self:buildTaskViewData(player)

	return self.taskList
end

function HomelandSeasonDailyTaskModel:getModuleName()
	if not self.moduleConfig then
		return ""
	end

	return pg.getLocalizationText(self.moduleConfig.name)
end

return HomelandSeasonDailyTaskModel
