-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BattlePass\\BattlePassModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BattlePassModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local EventTaskData = require("Data.event_task_data")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local BattlePassModel = Class.LightClass("BattlePassModel", UIModel)

function BattlePassModel:getBpTaskList(bpData, weeklyNum, isWeekly)
	if not Utils.isTable(bpData) then
		return {}
	end

	local groupId

	if isWeekly then
		local weekGroups = bpData.weekTaskGroupId

		groupId = Utils.isTable(weekGroups) and weekGroups[weeklyNum] or nil
	else
		groupId = bpData.seasonTaskGroupId
	end

	if groupId == nil then
		return {}
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(groupId) or {}
	local isMaxLevel = CashShopRedDotUtils.isBattlePassMaxLevel()
	local taskList = {}

	for _, taskId in ipairs(taskIds) do
		local cfg = EventTaskData[taskId]

		if self:_isTaskInTimeRange(cfg) and self:_isSpecialConditionMet(cfg.specialCondition) and self:_isPrevTaskFinished(cfg.preTaskId) then
			local taskState = ActivityUtils.getActTaskState(pg.me, taskId)

			if isMaxLevel and taskState == ActivityConst.TaskState.Finihed_CanRecv then
				taskState = ActivityConst.TaskState.UnFinished
			end

			taskList[#taskList + 1] = {
				tIndex = 0,
				taskId = taskId,
				cfg = cfg,
				actTaskData = ActivityUtils.getActTaskData(pg.me, taskId),
				taskState = taskState
			}
		end
	end

	self:_sortBpTaskList(taskList)

	return taskList
end

function BattlePassModel:_isTaskInTimeRange(cfg)
	if cfg == nil then
		return false
	end

	local startTs = Utils.getConfigTimeOfArea(cfg, "taskStartDayTime")
	local endTs = Utils.getConfigTimeOfArea(cfg, "taskEndDayTime")

	if startTs == nil and endTs == nil then
		return true
	end

	local now = Time.secondCache

	if startTs ~= nil and now < startTs then
		return false
	end

	if endTs ~= nil and endTs <= now then
		return false
	end

	return true
end

function BattlePassModel:_isSpecialConditionMet(specialCondition)
	if specialCondition == nil then
		return true
	end

	return ClientUtils.checkCondition(specialCondition)
end

function BattlePassModel:_isPrevTaskFinished(prevTaskId)
	if prevTaskId == nil then
		return true
	end

	local state = ActivityUtils.getActTaskState(pg.me, prevTaskId)

	if state == nil then
		return false
	end

	return state >= ActivityConst.TaskState.Received
end

function BattlePassModel:_sortBpTaskList(taskList)
	if not Utils.isTable(taskList) then
		return
	end

	table.sort(taskList, function(a, b)
		local aSortPri = 1

		if a.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			aSortPri = 0
		elseif a.taskState == ActivityConst.TaskState.Received or a.taskState == ActivityConst.TaskState.Received_SendMail then
			aSortPri = 2
		end

		local bSortPri = 1

		if b.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			bSortPri = 0
		elseif b.taskState == ActivityConst.TaskState.Received or b.taskState == ActivityConst.TaskState.Received_SendMail then
			bSortPri = 2
		end

		return aSortPri < bSortPri
	end)
end

return BattlePassModel
