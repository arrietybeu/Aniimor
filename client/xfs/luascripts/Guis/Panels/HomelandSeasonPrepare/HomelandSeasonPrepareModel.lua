-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonPrepare\\HomelandSeasonPrepareModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local Const = require("Common.Const.Const")
local QuestConst = require("Common.Const.QuestConst")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local HomeSeasonPrepareGoalData = require("Data.home_season_prepare_goal_data")
local HomeSeasonPrepareTaskData = require("Data.home_season_prepare_task_data")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonPrepareModel")
local HomelandSeasonPrepareModel = Class.LightClass("HomelandSeasonPrepareModel", UIModel)

HomelandSeasonPrepareModel.GOAL_STATE = {
	TIME_LOCKED = "TIME_LOCKED",
	WAIT_SYNC = "WAIT_SYNC",
	FINISHED = "FINISH",
	IN_PROGRESS = "NORMAL"
}

function HomelandSeasonPrepareModel:ctor()
	UIModel.ctor(self)

	self.seasonId = nil
	self.stageId = nil
	self.moduleId = nil
	self.moduleConfig = nil
	self.goalList = {}
	self.questIdSet = {}
	self.selectedGoalId = nil
end

function HomelandSeasonPrepareModel.isGoalInStage(goalConfig, stageId)
	local configuredStageIds = goalConfig.stageId
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

function HomelandSeasonPrepareModel.sortGoalConfig(a, b)
	local aOrder = a.config.displayOrder or 0
	local bOrder = b.config.displayOrder or 0

	if aOrder == bOrder then
		return a.goalId < b.goalId
	end

	return aOrder < bOrder
end

function HomelandSeasonPrepareModel.sortTaskConfig(a, b)
	return a.taskRowId < b.taskRowId
end

function HomelandSeasonPrepareModel.buildTaskConfigsByGoal(seasonId)
	local taskConfigsByGoal = {}

	for taskRowId, taskConfig in pairs(HomeSeasonPrepareTaskData) do
		if taskConfig.seasonId == seasonId then
			local goalTaskConfigs = taskConfigsByGoal[taskConfig.goalId]

			if not goalTaskConfigs then
				goalTaskConfigs = {}
				taskConfigsByGoal[taskConfig.goalId] = goalTaskConfigs
			end

			goalTaskConfigs[#goalTaskConfigs + 1] = {
				taskRowId = taskRowId,
				config = taskConfig
			}
		end
	end

	for _, goalTaskConfigs in pairs(taskConfigsByGoal) do
		table.sort(goalTaskConfigs, HomelandSeasonPrepareModel.sortTaskConfig)
	end

	return taskConfigsByGoal
end

function HomelandSeasonPrepareModel.calculateGoalState(allFinished, serverTime, openTime, traceQuestId)
	if allFinished then
		return HomelandSeasonPrepareModel.GOAL_STATE.FINISHED
	end

	if traceQuestId then
		return HomelandSeasonPrepareModel.GOAL_STATE.IN_PROGRESS
	end

	if serverTime < openTime then
		return HomelandSeasonPrepareModel.GOAL_STATE.TIME_LOCKED
	end

	return HomelandSeasonPrepareModel.GOAL_STATE.WAIT_SYNC
end

function HomelandSeasonPrepareModel.buildGoalTaskViewData(goalTaskConfigs, player)
	local allFinished = true
	local finishedTaskCount = 0
	local firstQuestId, firstTaskConfig, firstUnfinishedQuestId, firstUnfinishedTaskConfig, traceQuestId, traceTaskConfig

	for _, taskItem in ipairs(goalTaskConfigs) do
		local taskConfig = taskItem.config
		local questId = taskConfig.questId
		local questState = QuestCommonUtils.getQuestState(player, questId)
		local isFinished = questState == QuestConst.QUEST_STATE.COMPLETED or questState == QuestConst.QUEST_STATE.SUBMITED

		firstQuestId = firstQuestId or questId
		firstTaskConfig = firstTaskConfig or taskConfig

		if isFinished then
			finishedTaskCount = finishedTaskCount + 1
		else
			allFinished = false
			firstUnfinishedQuestId = firstUnfinishedQuestId or questId
			firstUnfinishedTaskConfig = firstUnfinishedTaskConfig or taskConfig

			if not traceQuestId and questState == QuestConst.QUEST_STATE.RECEIVED then
				traceQuestId = questId
				traceTaskConfig = taskConfig
			end
		end
	end

	local displayQuestId = traceQuestId or firstUnfinishedQuestId or firstQuestId
	local displayTaskConfig = traceTaskConfig or firstUnfinishedTaskConfig or firstTaskConfig or {}
	local title = displayTaskConfig.goalDes or ""
	local description = displayTaskConfig.des or ""

	return {
		allFinished = allFinished,
		displayQuestId = displayQuestId,
		traceQuestId = traceQuestId,
		finishedTaskCount = finishedTaskCount,
		taskCount = #goalTaskConfigs,
		title = title,
		description = description,
		imageAddress = displayTaskConfig.image or ""
	}
end

function HomelandSeasonPrepareModel.buildGoalViewData(seasonId, stageId, player, serverTime)
	local goalConfigs = {}

	for goalId, goalConfig in pairs(HomeSeasonPrepareGoalData) do
		if goalConfig.seasonId == seasonId and HomelandSeasonPrepareModel.isGoalInStage(goalConfig, stageId) then
			goalConfigs[#goalConfigs + 1] = {
				goalId = goalId,
				config = goalConfig
			}
		end
	end

	table.sort(goalConfigs, HomelandSeasonPrepareModel.sortGoalConfig)

	if #goalConfigs == 0 then
		logger:error("home season prepare has no goals seasonId=%s stageId=%s", tostring(seasonId), tostring(stageId))

		return nil
	end

	local taskConfigsByGoal = HomelandSeasonPrepareModel.buildTaskConfigsByGoal(seasonId)
	local goalList = {}
	local questIdSet = {}

	for _, goalItem in ipairs(goalConfigs) do
		local goalId = goalItem.goalId
		local goalConfig = goalItem.config
		local goalTaskConfigs = taskConfigsByGoal[goalId]

		if not goalTaskConfigs or #goalTaskConfigs == 0 then
			logger:error("home season prepare goal has no task seasonId=%s stageId=%s goalId=%s", tostring(seasonId), tostring(stageId), tostring(goalId))

			return nil
		end

		local openTime = Utils.getConfigTimeOfAreaByData(goalConfig.openDayTime, goalConfig.openDayTimeRefId)

		if not openTime then
			logger:error("home season prepare goal open time invalid seasonId=%s stageId=%s goalId=%s", tostring(seasonId), tostring(stageId), tostring(goalId))

			return nil
		end

		for _, taskItem in ipairs(goalTaskConfigs) do
			questIdSet[taskItem.config.questId] = true
		end

		local taskViewData = HomelandSeasonPrepareModel.buildGoalTaskViewData(goalTaskConfigs, player)
		local state = HomelandSeasonPrepareModel.calculateGoalState(taskViewData.allFinished, serverTime, openTime, taskViewData.traceQuestId)

		goalList[#goalList + 1] = {
			goalId = goalId,
			questId = taskViewData.displayQuestId,
			traceQuestId = taskViewData.traceQuestId,
			displayOrder = goalConfig.displayOrder or 0,
			orderImageAddress = goalConfig.orderImage or "",
			title = taskViewData.title,
			description = taskViewData.description,
			imageAddress = taskViewData.imageAddress,
			openTime = openTime,
			finishedTaskCount = taskViewData.finishedTaskCount,
			taskCount = taskViewData.taskCount,
			state = state,
			canGo = state == HomelandSeasonPrepareModel.GOAL_STATE.IN_PROGRESS,
			isFinished = taskViewData.allFinished
		}
	end

	return goalList, questIdSet
end

function HomelandSeasonPrepareModel.countFinishedGoals(goalList)
	local count = 0

	for _, goalData in ipairs(goalList) do
		if goalData.isFinished then
			count = count + 1
		end
	end

	return count
end

function HomelandSeasonPrepareModel.getNextRefreshTime(goalList, serverTime)
	local nextRefreshTime

	for _, goalData in ipairs(goalList) do
		if goalData.state == HomelandSeasonPrepareModel.GOAL_STATE.TIME_LOCKED and serverTime < goalData.openTime and (not nextRefreshTime or nextRefreshTime > goalData.openTime) then
			nextRefreshTime = goalData.openTime
		end
	end

	return nextRefreshTime
end

function HomelandSeasonPrepareModel.selectDefaultGoal(goalList)
	for _, goalData in ipairs(goalList) do
		if goalData.state == HomelandSeasonPrepareModel.GOAL_STATE.IN_PROGRESS then
			return goalData.goalId
		end
	end

	for _, goalData in ipairs(goalList) do
		if not goalData.isFinished then
			return goalData.goalId
		end
	end

	return goalList[#goalList] and goalList[#goalList].goalId or nil
end

function HomelandSeasonPrepareModel.containsGoal(goalList, goalId)
	for _, goalData in ipairs(goalList) do
		if goalData.goalId == goalId then
			return true
		end
	end

	return false
end

function HomelandSeasonPrepareModel:refreshPrepareData(moduleId)
	local previousSeasonId = self.seasonId
	local previousStageId = self.stageId
	local previousModuleId = self.moduleId
	local previousSelectedGoalId = self.selectedGoalId
	local player = pg.me

	self.seasonId = player and player.homeSeasonId or nil
	self.stageId = player and player.homeSeasonStageId or nil
	self.moduleId = nil
	self.moduleConfig = nil
	self.goalList = {}
	self.questIdSet = {}
	self.selectedGoalId = nil

	if not HomeSeasonUtils.isSeasonAvailable(player) then
		return nil
	end

	local moduleConfig = HomeSeasonModuleData[moduleId]

	if not moduleConfig or moduleConfig.type ~= Const.HOMELAND_SEASON_MODULE_TYPE.PREPARE_QUEST or not HomeSeasonUtils.isModuleOpen(self.seasonId, moduleId) then
		return nil
	end

	local serverTime = Time.secondCache or Time.getSecond()
	local goalList, questIdSet = HomelandSeasonPrepareModel.buildGoalViewData(self.seasonId, self.stageId, player, serverTime)

	if not goalList then
		return nil
	end

	self.moduleId = moduleId
	self.moduleConfig = moduleConfig
	self.goalList = goalList
	self.questIdSet = questIdSet

	local isSameContext = previousSeasonId == self.seasonId and previousStageId == self.stageId and previousModuleId == self.moduleId

	if isSameContext and HomelandSeasonPrepareModel.containsGoal(goalList, previousSelectedGoalId) then
		self.selectedGoalId = previousSelectedGoalId
	else
		self.selectedGoalId = HomelandSeasonPrepareModel.selectDefaultGoal(goalList)
	end

	return {
		seasonId = self.seasonId,
		stageId = self.stageId,
		moduleId = self.moduleId,
		goalList = self.goalList,
		selectedGoalId = self.selectedGoalId,
		finishedCount = HomelandSeasonPrepareModel.countFinishedGoals(self.goalList),
		totalCount = #self.goalList,
		nextRefreshTime = HomelandSeasonPrepareModel.getNextRefreshTime(self.goalList, serverTime)
	}
end

function HomelandSeasonPrepareModel:getModuleName()
	return self.moduleConfig and pg.getLocalizationText(self.moduleConfig.name) or ""
end

function HomelandSeasonPrepareModel:isQuestEventRelevant(eventData)
	local questId = eventData and eventData.questId

	if not questId then
		return false
	end

	if self.questIdSet[questId] then
		return true
	end

	local rootQuestId = QuestUtils.getRootQuestId(questId)

	return rootQuestId and self.questIdSet[rootQuestId] == true or false
end

function HomelandSeasonPrepareModel:getSelectedGoalData()
	if not self.selectedGoalId then
		return nil
	end

	for _, goalData in ipairs(self.goalList) do
		if goalData.goalId == self.selectedGoalId then
			return goalData
		end
	end

	return nil
end

return HomelandSeasonPrepareModel
