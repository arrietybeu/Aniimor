-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AreaActivity\\AreaActivityCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("AreaActivityCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local EventAreaActivityData = require("Data.event_area_activity_data")
local EventTaskData = require("Data.event_task_data")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local AddressDataConst = require("Const.AddressDataConst")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ItemSourceData = require("Data.item_source_data")
local AreaActivityCtrl = Class.LightClass("AreaActivityCtrl", UICtrl)

AreaActivityCtrl.messages = {
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onRefreshUI",
		true
	},
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerTeleport",
		true
	}
}

function AreaActivityCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function AreaActivityCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnInfoUButton.luaClick()
		return
	end

	function self.view.nextUButton.luaClick()
		local res, targetIndex = self.model:checkSubTaskAvailable(self.eventPhase, self.subTaskIndex + 1)

		if res then
			self.view.taskUList.luaPreInterval = 0
			self.subTaskIndex = targetIndex
			self.subTaskState = nil

			local data = EventAreaActivityData[self.eventPhase]

			if self.subTaskIndex == 0 then
				self.taskGroupId = data.islandTaskGroupId
			else
				self.taskGroupId = data.petResearchTaskGroupId[self.subTaskIndex]
			end

			self:refreshUI()
			UIUtils.PlayAnimation(self.view.rootAnimation, "VX_Ani_Pb_Event_WaterArea_TaskList_Switch", function()
				return
			end)
		end
	end

	function self.view.previousUButton.luaClick()
		local res, targetIndex = self.model:checkSubTaskAvailable(self.eventPhase, self.subTaskIndex - 1)

		if res then
			self.view.taskUList.luaPreInterval = 0
			self.subTaskIndex = targetIndex
			self.subTaskState = nil

			local data = EventAreaActivityData[self.eventPhase]

			if self.subTaskIndex == 0 then
				self.taskGroupId = data.islandTaskGroupId
			else
				self.taskGroupId = data.petResearchTaskGroupId[self.subTaskIndex]
			end

			self:refreshUI()
			UIUtils.PlayAnimation(self.view.rootAnimation, "VX_Ani_Pb_Event_WaterArea_TaskList_Switch", function()
				return
			end)
		end
	end

	function self.view.taskUList.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data)
	end

	function self.view.btnGotoUButton.luaClick()
		local areaTaskData = EventAreaActivityData[self.eventPhase]
		local eventId = areaTaskData.event

		if eventId then
			pg.global.showConfirmMsgRaw(pg.getGameString("PET_RESEARCH_TEXT1"), pg.getGameString("PET_RESEARCH_TEXT2"), function()
				pg.me:doEvent(eventId)
			end, nil)
		end
	end

	function self.view.getAllBtn.luaClick()
		pg.me:reqActReceiveGroupTaskReward(self.taskGroupId, self.eventId)
	end
end

function AreaActivityCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function AreaActivityCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.eventId = info.eventId
	self.eventPhase = info.eventPhase
	self.rootTask = info.rootTask
	self.subTaskIndex = info.subTaskIndex
	self.subTaskState = info.subTaskState

	local data = EventAreaActivityData[self.eventPhase]

	if self.rootTask then
		self.taskGroupId = data.islandTaskGroupId
		self.subTaskIndex = 0
	else
		self.taskGroupId = data.petResearchTaskGroupId[self.subTaskIndex]
	end

	self.view.rootAnimation.playAutomatically = false

	if self._hideEventTimer then
		self:killTimer(self._hideEventTimer)

		self._hideEventTimer = nil
	end

	self._hideEventTimer = self:startTimer(function()
		self._hideEventTimer = nil

		pg.global.ui.event:hide()
	end, 0.5)

	self:refreshUI()
end

function AreaActivityCtrl:onShow()
	pg.game.audio:playEvent("SFX_UI_WaterArea_TaskMoveIn")
	self:refreshUI()
end

function AreaActivityCtrl:onHide()
	if self._hideEventTimer then
		self:killTimer(self._hideEventTimer)

		self._hideEventTimer = nil
	end

	pg.global.ui.event:show()
end

function AreaActivityCtrl:onVisibleChange(visible)
	if visible then
		self:refreshUI()
	end
end

function AreaActivityCtrl:refreshUI()
	local areaTaskData = EventAreaActivityData[self.eventPhase]

	if not areaTaskData then
		return
	end

	self.view.bigBubbleUWidget:TryChangePage("Type", self.subTaskIndex == 0 and "Island" or "Emo")

	local getAllBtnTxt = self.view.getAllBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(getAllBtnTxt, pg.getGameString("PET_RESEARCH_GET_REWARD_ALL"))
	ClientTextUtils.setText(self.view.titleTxt, pg.getLocalizationText(self.subTaskIndex == 0 and areaTaskData.islandTitle or areaTaskData.petResearchTitle[self.subTaskIndex]))
	ClientTextUtils.setText(self.view.bigBubbleDownTxt, pg.getLocalizationText(self.subTaskIndex == 0 and areaTaskData.islandName or areaTaskData.petResearchName[self.subTaskIndex]))

	if self.subTaskIndex == 0 then
		self.view.lslandsUImage.url = areaTaskData.islandImage
	else
		self.view.emoUImage.url = string.format(AddressDataConst.AREA_ACTIVITY_ENTRANCE_OPEN, areaTaskData.petResearchImage[self.subTaskIndex])
	end

	local tempTaskList = ClientActivityUtils.getTaskInfoList(self.taskGroupId)
	local taskList = {}
	local curIdx, taskIdx = 1, 1

	while taskIdx <= #tempTaskList do
		taskList[curIdx] = tempTaskList[curIdx] or {}
		taskList[curIdx].taskData = tempTaskList[curIdx].taskData or {}

		local innerData = taskList[curIdx].taskData

		if #innerData == 2 then
			curIdx = curIdx + 1
		else
			innerData[#innerData + 1] = tempTaskList[taskIdx]
			taskIdx = taskIdx + 1
		end
	end

	self.view.taskUList:SetList(taskList)
	self:_refreshGetAllBtnVisible()
	self:_refreshSideBtnVisible()

	local hasLockedTask = false
	local now = Time.secondCache

	for _, t in ipairs(tempTaskList) do
		local cfg = EventTaskData[t.taskId]
		local taskStartTime = Utils.getConfigTimeOfArea(cfg, "taskStartDayTime")

		if taskStartTime and now < taskStartTime then
			hasLockedTask = true

			break
		end
	end

	if hasLockedTask then
		self:_scheduleUnlockTick()
	end
end

function AreaActivityCtrl:renderTaskItem(button, index, outerData)
	local innerData = outerData.taskData

	button:TryChangePage("Quantity", #innerData == 2 and "Two" or "One")

	local outerObjectReference = button:GetComponent("ObjectReference")

	for i = 1, #innerData do
		local taskBtn = outerObjectReference:GetRefValue("task" .. i .. "UButton")

		if taskBtn then
			local data = innerData[i]
			local objectReference = taskBtn:GetComponent("ObjectReference")
			local goUButton = objectReference:GetRefValue("goUButton")
			local receiveUButton = objectReference:GetRefValue("receiveUButton")
			local describeUBaseText = objectReference:GetRefValue("describeUBaseText")
			local progressUBaseText = objectReference:GetRefValue("progressUBaseText")
			local listRewardUList = objectReference:GetRefValue("listRewardUList")
			local aniWidget = objectReference:GetRefValue("aniWidget")

			function listRewardUList.luaRenderItem(rewardBtn, rewardIndex, rewardData)
				LuaUIUtils.renderRewardItem(rewardBtn, rewardData)
			end

			aniWidget:SetActiveQuickly(false)

			local taskId = data.taskId
			local taskState = data.taskState
			local cfg = EventTaskData[taskId]
			local nowSec = Time.secondCache
			local taskStartTime = Utils.getConfigTimeOfArea(cfg, "taskStartDayTime")
			local locked = taskStartTime and nowSec < taskStartTime

			if locked then
				taskBtn:TryChangePage("TaskState", 3)

				local remainTime = taskStartTime - nowSec
				local unlockTimeUBaseText = objectReference:GetRefValue("lockUBaseText")
				local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")

				ClientTextUtils.setText(unlockTimeUBaseText, pg.getGameString("ACCESSORY_UNLOCK"))
				LuaUIUtils.setCountDownTime(countDownUCountDown, remainTime, UIConst.TimeType.Short)
			elseif not taskState or taskState == ActivityConst.TaskState.UnFinished then
				taskBtn:TryChangePage("TaskState", 0)
			elseif taskState == ActivityConst.TaskState.Finihed_CanRecv then
				taskBtn:TryChangePage("TaskState", 1)
			elseif taskState == ActivityConst.TaskState.Received then
				taskBtn:TryChangePage("TaskState", 2)
			end

			local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward, taskState == ActivityConst.TaskState.Received, taskState == ActivityConst.TaskState.Finihed_CanRecv)

			listRewardUList:SetList(rewards)
			ClientTextUtils.setText(describeUBaseText, pg.getLocalizationText(data.taskDes))

			local curCnt = pg.me.triggerMap:getConditionFinishCount(data.taskCondition, 1)
			local finishCnt = pg.me.triggerMap:getConditionTargetCount(data.taskCondition, 1)

			if cfg.taskFinishCnt then
				finishCnt = cfg.taskFinishCnt
			end

			if taskState ~= ActivityConst.TaskState.UnFinished then
				curCnt = finishCnt
			end

			ClientTextUtils.setText(progressUBaseText, string.format("%s/%s", curCnt, finishCnt))

			local goBtnTxt = goUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

			ClientTextUtils.setText(goBtnTxt, pg.getGameString("PET_RESEARCH_HELP_TIP"))

			local receBtnTxt = receiveUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

			ClientTextUtils.setText(receBtnTxt, pg.getGameString("PET_RESEARCH_GET_REWARD"))
			goUButton:SetActive(data.taskEvent ~= nil or cfg.sourceId ~= nil)

			function goUButton.luaClick()
				local eventId = data.taskEvent
				local sourceId = cfg.sourceId

				if sourceId then
					local sourceData = ItemSourceData[sourceId]

					LuaUIUtils.clueSeek(sourceData)
				elseif eventId then
					pg.me:doEvent(eventId)
				end
			end

			local treePath = string.format(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_TASK_REWARD, taskId)

			pg.global.setRedDot(treePath, receiveUButton, taskState == ActivityConst.TaskState.Finihed_CanRecv, RedDotConst.RedDotStyle.REWARD)

			if locked then
				pg.global.setRedDot(treePath, receiveUButton, false)
			end

			function receiveUButton.luaClick()
				pg.me:reqActReceiveTaskReward(taskId, self.eventId)
			end
		end
	end
end

function AreaActivityCtrl:_refreshGetAllBtnVisible()
	local getAllVisible = ClientActivityUtils.getCanGetRewardByTaskGroupId(self.taskGroupId)

	self.view.getAllBtn:SetActive(getAllVisible)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_GET_ALL_REWARD, self.view.getAllBtn, getAllVisible, RedDotConst.RedDotStyle.REWARD)
end

function AreaActivityCtrl:_refreshSideBtnVisible()
	local areaTaskData = EventAreaActivityData[self.eventPhase]

	if not areaTaskData or #areaTaskData.petResearchTaskGroupId <= 0 then
		self.view.nextUButton:SetActive(false)
		self.view.previousUButton:SetActive(false)

		return false
	end

	self.view.nextUButton:SetActive(true)
	self.view.previousUButton:SetActive(true)

	local _, targetIndex = self.model:checkSubTaskAvailable(self.eventPhase, self.subTaskIndex - 1)
	local taskGroupId = targetIndex == 0 and areaTaskData.islandTaskGroupId or areaTaskData.petResearchTaskGroupId[targetIndex]
	local leftBtnRewardShow = ClientActivityUtils.getCanGetRewardByTaskGroupId(taskGroupId)

	_, targetIndex = self.model:checkSubTaskAvailable(self.eventPhase, self.subTaskIndex + 1)
	taskGroupId = targetIndex == 0 and areaTaskData.islandTaskGroupId or areaTaskData.petResearchTaskGroupId[targetIndex]

	local rightBtnRewardShow = ClientActivityUtils.getCanGetRewardByTaskGroupId(taskGroupId)

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_LEFT_BTN_REWARD, self.view.previousUButton, leftBtnRewardShow, RedDotConst.RedDotStyle.REWARD)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_AREA_ACTIVITY_RIGHT_BTN_REWARD, self.view.nextUButton, rightBtnRewardShow, RedDotConst.RedDotStyle.REWARD)
end

function AreaActivityCtrl:onRefreshUI()
	self:refreshUI()
end

function AreaActivityCtrl:onPlayerTeleport()
	self:dismiss()
end

function AreaActivityCtrl:_scheduleUnlockTick()
	self:startTimer(function()
		if self.view and self.view.taskUList then
			self:refreshUI()
		end
	end, 60)
end

return AreaActivityCtrl
