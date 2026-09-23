-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\RedBookGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventCommonGuideData = require("Data.event_common_guide_data")
local ActivateTasksData = require("Data.activate_tasks_data")
local EventTaskData = require("Data.event_task_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local UIConst = require("Const.UIConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EventCommonGuideComponent")
local RedBookGuideHandler = Class.LightClass("RedBookGuideHandler", GuideHandlerBase)

function RedBookGuideHandler:getOwnedRefKeys()
	return {
		"redBookUContainer"
	}
end

function RedBookGuideHandler:getOwnedContainers()
	return {
		"redBookUContainer"
	}
end

function RedBookGuideHandler:onFindObjects(objectReference)
	self.redBookUContainer = objectReference:GetRefValue("redBookUContainer")
end

function RedBookGuideHandler:onRefresh()
	self.comp.rewardPreviewUWidget:SetActive(false)

	if self.redBookUContainer then
		if self.redBookUContainer:CheckURLLoaded() then
			self:_refreshRedBook()
		else
			self.redBookUContainer:LoadDefaultUrlManually(function()
				self:_refreshRedBook()
			end)
		end

		self.redBookUContainer:SetActive(true)
	end
end

function RedBookGuideHandler:onExit()
	if self.redBookUContainer then
		self.redBookUContainer:SetActive(false)
	end
end

function RedBookGuideHandler:getRightTaskStatus(taskState)
	if taskState and taskState >= ActivityConst.TaskState.Received then
		return 2
	elseif taskState == ActivityConst.TaskState.Finihed_CanRecv then
		return 1
	end

	return 0
end

function RedBookGuideHandler:bindGetButton(button, taskId)
	if not button then
		return
	end

	local taskState = taskId and ActivityUtils.getActTaskState(pg.me, taskId)
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local redDotPath = taskId and string.format(RedDotConst.RedDotPath.EVENT_RED_BOOK_TASK, taskId)

	if redDotPath then
		pg.global.setRedDot(redDotPath, button, canReceive, RedDotConst.RedDotStyle.REWARD)
	end

	local buttonRef = button:GetComponent("ObjectReference")
	local buttonText = buttonRef and buttonRef:GetRefValue("txtNameUText")

	if buttonText then
		ClientTextUtils.setText(buttonText, pg.getGameString("REDNOTE_GET"))
	end

	function button.luaClick()
		if taskId and ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			pg.me:reqActReceiveTaskReward(taskId, self.comp.eventId)
		end
	end
end

function RedBookGuideHandler:_refreshRedBook()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]

	if not commonGuideData then
		if pg.logError() then
			logger:error("@EventCommonGuideComponent _refreshRedBook commonGuideData is nil, eventId: %d, commonGuideId: %d", self.comp.eventId, self.comp.commonGuideId)
		end

		return
	end

	if not self.redBookUContainer or not self.redBookUContainer.content then
		return
	end

	local objectReference = self.redBookUContainer.content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local activateTaskCfg = ActivateTasksData[self.comp.eventId]
	local taskGroups = activateTaskCfg and activateTaskCfg.foreverTaskGroup

	if not taskGroups then
		if pg.logError() then
			logger:error("@EventCommonGuideComponent _refreshRedBook activateTasksData is nil, eventId: %d", self.comp.eventId)
		end

		return
	end

	local function bindRewardItem(button, taskId, taskCfg)
		if not button then
			return
		end

		local rewards = taskCfg.award and LuaUIUtils.getRewardItemByDropId(taskCfg.award)
		local firstItem = rewards and rewards[1]
		local itemId = firstItem and firstItem.id

		button.gameObject:SetActiveEx(itemId ~= nil)

		function button.luaClick()
			if ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
				pg.me:reqActReceiveTaskReward(taskId, self.comp.eventId)
			elseif itemId then
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = itemId,
					num = firstItem.num,
					targetRect = button
				})
			end
		end
	end

	local rightTaskIds = {}

	for _, taskId in ipairs(ActivityUtils.getActTaskIdsByGroupId(taskGroups[1])) do
		rightTaskIds[#rightTaskIds + 1] = taskId
	end

	table.sort(rightTaskIds, function(taskIdA, taskIdB)
		local taskCfgA = EventTaskData[taskIdA]
		local taskCfgB = EventTaskData[taskIdB]
		local sortA = taskCfgA and taskCfgA.sort or math.huge
		local sortB = taskCfgB and taskCfgB.sort or math.huge

		if sortA == sortB then
			return taskIdA < taskIdB
		end

		return sortA < sortB
	end)

	local rightRefs = {
		{
			get = "getUButton1",
			txt = "txtTask1",
			root = "rightBtn1UButton",
			goto_ = "btnTask1",
			reward = "rewardTask1"
		},
		{
			get = "getUButton2",
			txt = "txtTask2",
			root = "rightBtn2UButton",
			goto_ = "btnTask2",
			reward = "rewardTask2"
		}
	}

	for i, ref in ipairs(rightRefs) do
		local txtTask = objectReference:GetRefValue(ref.txt)
		local rewardTask = objectReference:GetRefValue(ref.reward)
		local btnTask = objectReference:GetRefValue(ref.goto_)
		local rightBtn = objectReference:GetRefValue(ref.root)
		local getButton = objectReference:GetRefValue(ref.get)
		local rewardRef = rewardTask and rewardTask:GetComponent("ObjectReference")
		local rewardTaskIcon = rewardRef and rewardRef:GetRefValue("itemIconUImage")
		local rewardTaskNum = rewardRef and rewardRef:GetRefValue("txtNumUText")
		local btnRef = btnTask and btnTask:GetComponent("ObjectReference")
		local btnTxt = btnRef and btnRef:GetRefValue("txtNameUText")
		local taskId = rightTaskIds[i]
		local taskCfg = taskId and EventTaskData[taskId]
		local taskState = taskId and ActivityUtils.getActTaskState(pg.me, taskId)

		if rightBtn then
			rightBtn:TryChangePage("Status", self:getRightTaskStatus(taskState))
		end

		self:bindGetButton(getButton, taskId)

		if taskCfg then
			ClientTextUtils.setText(txtTask, pg.getLocalizationText(taskCfg.taskDes))
			bindRewardItem(rewardTask, taskId, taskCfg)

			local rewards = taskCfg.award and LuaUIUtils.getRewardItemByDropId(taskCfg.award)
			local firstItem = rewards and rewards[1]

			if rewardTaskIcon then
				local itemCfg = firstItem and firstItem.id and ItemData[firstItem.id]

				rewardTaskIcon.url = itemCfg and itemCfg.icon or ""
			end

			if rewardTaskNum then
				ClientTextUtils.setText(rewardTaskNum, firstItem and firstItem.num or "")
			end

			if btnTxt then
				ClientTextUtils.setText(btnTxt, pg.getGameString("REDNOTE_GO"))
			end

			if btnTask then
				function btnTask.luaClick()
					local sourceId = taskCfg.sourceId

					if sourceId then
						local sourceData = ItemSourceData[sourceId]

						LuaUIUtils.clueSeek(sourceData)
					end
				end
			end
		else
			if txtTask then
				ClientTextUtils.setText(txtTask, "")
			end

			if rewardTask then
				rewardTask.gameObject:SetActiveEx(false)
			end

			if btnTask then
				btnTask.gameObject:SetActiveEx(false)
			end
		end
	end

	local btnReward = objectReference:GetRefValue("btnReward")
	local txtRewardPro = objectReference:GetRefValue("txtRewardPro")
	local imgReward = objectReference:GetRefValue("imgReward")
	local txtReward = objectReference:GetRefValue("txtReward")

	ClientTextUtils.setText(txtReward, pg.getGameString("REDNOTE_PRIZE"))

	local rewardTaskIds = ActivityUtils.getActTaskIdsByGroupId(taskGroups[2])
	local rewardTaskId = rewardTaskIds[1]
	local rewardTaskCfg = rewardTaskId and EventTaskData[rewardTaskId]

	if rewardTaskCfg then
		local triggerMap = pg.me and pg.me.triggerMap
		local target = triggerMap and triggerMap:getConditionTargetCount(rewardTaskCfg.taskCondition, 1) or 0
		local finished = triggerMap and triggerMap:getConditionFinishCount(rewardTaskCfg.taskCondition, 1) or 0
		local rewardTaskState = ActivityUtils.getActTaskState(pg.me, rewardTaskId)
		local progress = rewardTaskState and rewardTaskState >= ActivityConst.TaskState.Finihed_CanRecv and target or finished

		ClientTextUtils.setText(txtRewardPro, string.format("%s/%s", progress, target))

		local rewards = rewardTaskCfg.award and LuaUIUtils.getRewardItemByDropId(rewardTaskCfg.award)
		local firstItem = rewards and rewards[1]

		if imgReward then
			local itemCfg = firstItem and ItemData[firstItem.id]

			imgReward.url = itemCfg and itemCfg.icon or ""
		end

		bindRewardItem(btnReward, rewardTaskId, rewardTaskCfg)
	elseif btnReward then
		btnReward.gameObject:SetActiveEx(false)
	end
end

return RedBookGuideHandler
