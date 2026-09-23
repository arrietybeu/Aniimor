-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\ReunionTrainingComponent.lua

local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local GameEventData = require("Data.game_event_data")
local ItemSourceData = require("Data.item_source_data")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local ReunionTrainingComponent = Class.LightClass("ReunionTrainingComponent", EventContainerComponent)
local Utils = require("Common.Utils.Utils")
local WAIT_SHOW_RED_DOT = 0.6

function ReunionTrainingComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.listNormal = objectReference:GetRefValue("listNormal")
	self.listRow = objectReference:GetRefValue("listRow")
	self.totalRewardUButton = objectReference:GetRefValue("totalRewardUButton")
	self.texTaskPro = objectReference:GetRefValue("texTaskPro")
	self.texTaskTitle = objectReference:GetRefValue("texTaskTitle")
	self.textTaskDesc = objectReference:GetRefValue("textTaskDesc")
	self.goToUButton = objectReference:GetRefValue("goToUButton")
	self.txtSmallTitle = objectReference:GetRefValue("txtSmallTitle")
	self.TxtGotoName = objectReference:GetRefValue("TxtGotoName")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.txtRewardTitle = objectReference:GetRefValue("txtRewardTitle")
	self.txtRewardTips = objectReference:GetRefValue("txtRewardTips")

	local btnReadyTxtName = self.rootUComponent:Find("SafeBoxMobile/Window/Layout/Widget/Task/BtnReady/TxtName")

	self.btnReadyTxtNameUSDFText = btnReadyTxtName and btnReadyTxtName:GetComponent("USDFText") or nil
	self.vxEffUWidgetRows = {}
	self.vxEffUWidgetCols = {}

	for i = 0, 3 do
		self.vxEffUWidgetRows[i] = objectReference:GetRefValue("vxEffUWidgetRow" .. i)
		self.vxEffUWidgetCols[i] = objectReference:GetRefValue("vxEffUWidgetCol" .. i)

		self.vxEffUWidgetRows[i].gameObject:SetActiveEx(false)
		self.vxEffUWidgetCols[i].gameObject:SetActiveEx(false)
	end
end

function ReunionTrainingComponent:onContentReady()
	ClientTextUtils.setText(self.txtSmallTitle, pg.getGameString("REUNION_TASK_TITLE"))
	ClientTextUtils.setText(self.TxtGotoName, pg.getGameString("BUTTON_NAME_1"))
	ClientTextUtils.setText(self.txtRewardTitle, pg.getGameString("REUNION_AWARD_SHOW"))
	ClientTextUtils.setText(self.txtRewardTips, pg.getGameString("REUNION_LINE_AWARD_TIP"))
end

function ReunionTrainingComponent:addListener()
	function self.goToUButton.luaClick()
		local eventId = self.curTaskData and self.curTaskData.taskEvent
		local sourceId = self.curTaskData and self.curTaskData.sourceId

		if sourceId then
			local sourceData = ItemSourceData[sourceId]

			LuaUIUtils.clueSeek(sourceData)
		elseif eventId then
			pg.me:doEvent(eventId)
		end
	end

	function self.listNormal.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data, self.model.REUNION_TRAINING_TASK_TYPE.normal)
	end

	function self.listNormal.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onTaskSelectChanged(uList)
	end

	function self.listRow.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data, self.model.REUNION_TRAINING_TASK_TYPE.row)
	end

	function self.listRewardUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end
end

function ReunionTrainingComponent:refreshPage()
	local eventData = GameEventData[self.eventId]

	if not eventData then
		return
	end

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime)

	local normalTaskCfgs = ClientActivityUtils.getTaskInfoList(self.model.REUNION_TRAINING_TASK_TYPE.normal, true)
	local rowTaskCfgs = ClientActivityUtils.getTaskInfoList(self.model.REUNION_TRAINING_TASK_TYPE.row, true)
	local fanalTaskCfgs = ClientActivityUtils.getTaskInfoList(self.model.REUNION_TRAINING_TASK_TYPE.final, true)

	self.listNormal:SetList(normalTaskCfgs)
	self.listNormal:SelectItem(self.curTaskIndex or 0)
	self.listRow:SetList(rowTaskCfgs)
	self:renderTaskItem(self.totalRewardUButton, 0, fanalTaskCfgs[1], self.model.REUNION_TRAINING_TASK_TYPE.final)
	self:refreshCommonNodeRedDot()
end

function ReunionTrainingComponent:playEvent(eventName)
	if not self.eventName or self.eventName ~= eventName then
		self.eventName = eventName

		self.rootUComponent:InvokeCallback(eventName)
	end
end

function ReunionTrainingComponent:onTaskSelectChanged(uList)
	local sData = uList.selectedItem
	local index = uList.selectedIndex

	self:refreshSelectTask(sData, index)
end

function ReunionTrainingComponent:setTaskStatus(type, index, button, status)
	button:TryChangePage("status", status)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_REUNION_TRAINING_TASK, type, index), button, status == 1, type == self.model.REUNION_TRAINING_TASK_TYPE.normal and RedDotConst.RedDotStyle.POINT or RedDotConst.RedDotStyle.REWARD)
end

function ReunionTrainingComponent:tryShowReceiveEff(button, type, index, status)
	if type == self.model.REUNION_TRAINING_TASK_TYPE.row or type == self.model.REUNION_TRAINING_TASK_TYPE.col then
		if not self.taskInfo then
			self.taskInfo = {}
		end

		if not self.taskInfo[type] then
			self.taskInfo[type] = {}
		end

		if status == 1 and self.taskInfo[type][index] and self.taskInfo[type][index] ~= status then
			self.taskInfo[type][index] = status

			if not self.waitShowTimer then
				for i = 0, 3 do
					self.vxEffUWidgetRows[i].gameObject:SetActiveEx(type == self.model.REUNION_TRAINING_TASK_TYPE.row and i == index)
				end

				self.waitShowTimer = self:startTimer(function()
					self:setTaskStatus(type, index, button, status)

					self.waitShowTimer = nil
				end, WAIT_SHOW_RED_DOT)
			end
		else
			self.taskInfo[type][index] = status

			self:setTaskStatus(type, index, button, status)
		end
	else
		self:setTaskStatus(type, index, button, status)
	end
end

function ReunionTrainingComponent:renderTaskItem(button, index, data, type)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local taskCondition = data.taskCondition
	local taskState = data.taskState
	local isComplete = taskState ~= ActivityConst.TaskState.UnFinished
	local rewards

	if type == self.model.REUNION_TRAINING_TASK_TYPE.normal then
		local bgColorType = index % 4

		button:TryChangePage("color", bgColorType)

		local taskType = math.floor(index / 4)

		button:TryChangePage("task", taskType)

		local arrow = index < 4 and 1 or 0
		local triangle = index % 4 == 3 and 1 or 0

		button:TryChangePage("Arrow", arrow)
		button:TryChangePage("triangle", triangle)

		local finishCnt = pg.me.triggerMap:getConditionTargetCount(taskCondition, 1)
		local curCnt = isComplete and finishCnt or pg.me.triggerMap:getConditionFinishCount(taskCondition, 1)

		ClientTextUtils.setText(textUBaseText, string.format("%s/%s", curCnt, finishCnt))

		iconUImage.url = data.eventIcon
	else
		rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState == ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

		if type == self.model.REUNION_TRAINING_TASK_TYPE.row or type == self.model.REUNION_TRAINING_TASK_TYPE.col then
			ClientTextUtils.setText(textUBaseText, rewards and rewards[1] and rewards[1].num or 1)
		else
			local finishCnt = pg.me.triggerMap:getConditionTargetCount(taskCondition, 1)
			local curCnt = isComplete and finishCnt or pg.me.triggerMap:getConditionFinishCount(taskCondition, 1)

			ClientTextUtils.setText(textUBaseText, string.format("%s/%s", curCnt, finishCnt))
		end

		iconUImage.url = LuaUIUtils.getIconByItemId(rewards[1].id)
	end

	local status

	status = (taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail) and 2 or taskState == ActivityConst.TaskState.Finihed_CanRecv and 1 or 0

	self:setTaskStatus(type, index, button, status)

	function button.luaClick()
		if taskState == ActivityConst.TaskState.Finihed_CanRecv then
			pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
		end

		if type ~= self.model.REUNION_TRAINING_TASK_TYPE.normal then
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = rewards[1].id,
				targetRect = button,
				originData = {
					hideCount = true
				}
			})
		end
	end
end

function ReunionTrainingComponent:refreshSelectTask(data, index)
	self.curTaskData = data
	self.curTaskIndex = index

	ClientTextUtils.setText(self.texTaskTitle, pg.getLocalizationText(data.taskTitle))
	ClientTextUtils.setText(self.textTaskDesc, pg.getLocalizationText(data.taskDes))

	local bgColorType = index % 4

	self.rootUComponent:TryChangePage("color", bgColorType)

	local taskType = math.floor(index / 4)

	self.rootUComponent:TryChangePage("task", taskType)

	local taskCondition = data.taskCondition
	local taskState = data.taskState
	local isComplete = taskState ~= ActivityConst.TaskState.UnFinished
	local finishCnt = pg.me.triggerMap:getConditionTargetCount(taskCondition, 1)
	local curCnt = isComplete and finishCnt or pg.me.triggerMap:getConditionFinishCount(taskCondition, 1)

	ClientTextUtils.setText(self.texTaskPro, string.format("%s/%s", curCnt, finishCnt))

	local btnType, btnTxt

	if taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail then
		btnType = 1
		btnTxt = "ECOLOGICAL_RESARCH_FINISH"
	elseif not isComplete and (data.taskEvent or data.sourceId) then
		btnType = 0
	else
		btnType = 2
		btnTxt = "ECOLOGICAL_CHAPTER_AWARD_CLAIMABLE"
	end

	self.rootUComponent:TryChangePage("btnstatus", btnType)

	if self.btnReadyTxtNameUSDFText and btnTxt then
		ClientTextUtils.setText(self.btnReadyTxtNameUSDFText, pg.getGameString(btnTxt))
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState == ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

	self.listRewardUList:SetList(rewards)
end

function ReunionTrainingComponent:onExitPage()
	self.taskInfo = nil
	self.curTaskData = nil
	self.curTaskIndex = nil

	if self.waitShowTimer then
		self:killTimer(self.waitShowTimer)

		self.waitShowTimer = nil
	end

	EventContainerComponent.onExitPage(self)
end

return ReunionTrainingComponent
