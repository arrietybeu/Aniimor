-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PetDispatchHomeComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetDispatchHomeComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local EventTaskData = require("Data.event_task_data")
local Time = require("Core.Common.Time")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local PetDispatchHomeComponent = Class.LightClass("PetDispatchHomeComponent", EventContainerComponent)
local CLUE_STATE = {
	LOCKED_UNFINISHED = 5,
	LOCKED_NO_PREREQ = 4,
	AVAILABLE = 3,
	DISPATCHING = 2,
	REWARDABLE = 1,
	COMPLETED = 0
}
local REWARD_STATE = {
	RECEIVED = 1,
	REWARDABLE = 2
}
local CLUE_SLOT_COUNT = 5
local ITEM_COUNT = 3

function PetDispatchHomeComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.txtNumNow = self.objectReference:GetRefValue("txtNumNow")
	self.txtNumTotal = self.objectReference:GetRefValue("txtNumTotal")
	self.txtPreview = self.objectReference:GetRefValue("txtPreview")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.rewardItems = {}

	for i = 1, ITEM_COUNT do
		self.rewardItems[i] = self.objectReference:GetRefValue("rewardItem" .. i)
	end

	self.clueSlots = {}

	for i = 1, CLUE_SLOT_COUNT do
		self.clueSlots[i] = self.objectReference:GetRefValue("clueItem" .. i)
	end

	ClientTextUtils.setText(self.txtTitle, pg.getGameString("DISPATCH_INVESTIGATION_PROGRESS"))
	ClientTextUtils.setText(self.txtPreview, pg.getGameString("DISPATCH_TASK_ADVENTURE_PREVIEW_TITLE"))
end

function PetDispatchHomeComponent:addListener()
	if self.listRewardUList then
		function self.listRewardUList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end

	if self.btnInfoUButton then
		self.btnInfoUButton.tooltipId = pg.getGameString("DISPATCH_TASK_ADVENTURE_DESC")
	end

	for i = 1, CLUE_SLOT_COUNT do
		local slot = self.clueSlots[i]

		if slot then
			function slot.luaClick()
				self:onClickClue(i)
			end
		end
	end

	for i = 1, ITEM_COUNT do
		local btn = self.rewardItems[i]

		if btn then
			function btn.luaClick()
				self:onClickReward(i)
			end
		end
	end
end

function PetDispatchHomeComponent:refreshPage()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.PetDispatch)

	if not activityData then
		return
	end

	self.eventPhase = activityData.eventPhase

	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime)

	self.clues = self:buildClues()

	for i = 1, CLUE_SLOT_COUNT do
		self:refreshClueSlot(i)
	end

	local complete, allCnt = PetDispatchUtils.getDispatchProgress()

	self:refreshProgress(complete, allCnt)
	self:refreshPossiblyReward()

	self.stageScoreTaskInfos = PetDispatchUtils.getStageScoreTaskInfos()
	self.rewardEntries = self:buildRewardItems(self.stageScoreTaskInfos)

	for i = 1, ITEM_COUNT do
		self:refreshRewardItem(i)
	end

	self:refreshCommonNodeRedDot()
	self:refreshNavDefaultFocus()
end

function PetDispatchHomeComponent:refreshNavDefaultFocus()
	self:setNavGroupDefaultFocus(self.clueSlots, self.clues, CLUE_STATE.REWARDABLE, CLUE_STATE.COMPLETED)
	self:setNavGroupDefaultFocus(self.rewardItems, self.rewardEntries, REWARD_STATE.REWARDABLE, REWARD_STATE.RECEIVED)
end

function PetDispatchHomeComponent:setNavGroupDefaultFocus(items, entries, rewardableState, completedState)
	local focusIndex = self:getPreferredFocusIndex(entries, rewardableState, completedState)

	for i, item in ipairs(items or EMPTY_TABLE) do
		if item then
			item:SetNavItemPriorityOverride(i == focusIndex and 1 or 0)
		end
	end
end

function PetDispatchHomeComponent:getPreferredFocusIndex(entries, rewardableState, completedState)
	local firstUnfinishedIndex

	for i, entry in ipairs(entries or EMPTY_TABLE) do
		if entry.state == rewardableState then
			return i
		end

		if not firstUnfinishedIndex and entry.state ~= completedState then
			firstUnfinishedIndex = i
		end
	end

	return firstUnfinishedIndex or 1
end

function PetDispatchHomeComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	if self.rootUComponent then
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function PetDispatchHomeComponent:buildClues()
	local taskById = {}

	for _, taskInfo in ipairs(ClientActivityUtils.getTaskInfoByActType(ActivityConst.EventType.PetDispatch)) do
		if taskInfo.taskType == ActivityConst.ActivityTaskType.PetDispatch_Dispatch then
			taskById[taskInfo.taskId] = taskInfo
		end
	end

	local configs = PetDispatchUtils.getCurrentStageClues(self.eventPhase)
	local clues = {}

	for i = 1, CLUE_SLOT_COUNT do
		local cfg = configs[i] or {}
		local taskInfo = cfg.taskId and taskById[cfg.taskId]
		local prevTaskInfo = i > 1 and clues[i - 1] and clues[i - 1].taskInfo or nil

		clues[i] = {
			index = i,
			taskId = cfg.taskId,
			mapBlockId = cfg.mapBlockId,
			clueImage = cfg.clueImage,
			state = self:getClueState(taskInfo, prevTaskInfo),
			taskInfo = taskInfo
		}
	end

	return clues
end

function PetDispatchHomeComponent:getClueState(taskInfo, prevTaskInfo)
	if not taskInfo then
		return CLUE_STATE.LOCKED_NO_PREREQ
	end

	if taskInfo.taskState == ActivityConst.TaskState.Received or taskInfo.taskState == ActivityConst.TaskState.Received_SendMail then
		return CLUE_STATE.COMPLETED
	end

	if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv then
		return CLUE_STATE.REWARDABLE
	end

	if taskInfo.taskState == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching then
		return CLUE_STATE.DISPATCHING
	end

	if prevTaskInfo and prevTaskInfo.taskState and (prevTaskInfo.taskState == ActivityConst.TaskState.UnFinished or prevTaskInfo.taskState == ActivityConst.PetDispatchTaskSubState.UnFinished_Disptaching) then
		return CLUE_STATE.LOCKED_UNFINISHED
	end

	return CLUE_STATE.AVAILABLE
end

function PetDispatchHomeComponent:refreshClueSlot(i)
	local slot = self.clueSlots[i]

	if not slot then
		return
	end

	local data = self.clues[i]

	if not data then
		return
	end

	slot:TryChangePage("State", data.state)

	local slotRef = slot:GetComponent("ObjectReference")
	local imgPic = slotRef:GetRefValue("imgPic")
	local txtClue = slotRef:GetRefValue("txtClue")
	local countDownUCountDown = slotRef:GetRefValue("countDownUCountDown")
	local txtUnlock = slotRef:GetRefValue("txtUnlock")
	local txtState = slotRef:GetRefValue("txtState")

	if imgPic and data.clueImage then
		imgPic.url = data.clueImage
	end

	local taskCfg = data.taskId and EventTaskData[data.taskId]

	if txtClue then
		if data.state == CLUE_STATE.LOCKED_NO_PREREQ or data.state == CLUE_STATE.LOCKED_UNFINISHED then
			ClientTextUtils.setText(txtClue, pg.getFormatText(pg.getGameString("DISPATCH_AERAE_CLUE_TITLE"), i))
		elseif taskCfg and taskCfg.eventTitle then
			ClientTextUtils.setText(txtClue, pg.getLocalizationText(taskCfg.eventTitle))
		end
	end

	if data.state == CLUE_STATE.LOCKED_NO_PREREQ and countDownUCountDown then
		local unlockTs = pg.me.activityPetDispatch.clueUnlockTms[i]

		if unlockTs and unlockTs > Time.getSecond() then
			LuaUIUtils.setCountDownTime(countDownUCountDown, unlockTs, UIConst.TimeType.Short)
		end
	elseif countDownUCountDown and countDownUCountDown.Stop then
		countDownUCountDown:Stop()
	end

	if data.state == CLUE_STATE.LOCKED_UNFINISHED and txtUnlock then
		ClientTextUtils.setText(txtUnlock, pg.getLocalizationText(pg.getGameString("DISPATCH_PRE_TASK_UNDONE")))
	elseif data.state == CLUE_STATE.DISPATCHING and txtState then
		ClientTextUtils.setText(txtState, pg.getLocalizationText(pg.getGameString("DISPATCH_INVESTIGATING")))
	elseif data.state == CLUE_STATE.REWARDABLE and txtState then
		ClientTextUtils.setText(txtState, pg.getLocalizationText(pg.getGameString("DISPATCH_INVESTIGATION_DONE")))
	end

	if data.taskId then
		local treePath = string.format(RedDotConst.RedDotPath.EVENT_PET_DISPATCH_TASK_ITEM, data.taskId)
		local isNewPet = data.mapBlockId and pg.me and data.state == CLUE_STATE.AVAILABLE and pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_DISPATCH_MAPBLOCK, data.mapBlockId, true)

		if data.state == CLUE_STATE.REWARDABLE then
			pg.global.setRedDot(treePath, slot, true, RedDotConst.RedDotStyle.REWARD)
		elseif isNewPet then
			pg.global.setRedDot(treePath, slot, true, RedDotConst.RedDotStyle.NEW)
		else
			pg.global.setRedDot(treePath, slot, false, RedDotConst.RedDotStyle.NONE)
		end
	end
end

function PetDispatchHomeComponent:refreshPossiblyReward()
	if not self.listRewardUList then
		return
	end

	local dropIds = PetDispatchUtils.getAdventureRewardDropIds(self.eventPhase or 1)
	local rewards = {}

	for _, dropId in ipairs(dropIds) do
		for _, item in ipairs(LuaUIUtils.getRewardItemByDropId(dropId) or EMPTY_TABLE) do
			rewards[#rewards + 1] = item
		end
	end

	self.listRewardUList:SetList(rewards)
end

function PetDispatchHomeComponent:refreshProgress(complete, allCnt)
	complete = complete or 0
	allCnt = allCnt or 0

	if self.txtNumNow then
		ClientTextUtils.setText(self.txtNumNow, tostring(complete) .. "/")
	end

	if self.txtNumTotal then
		ClientTextUtils.setText(self.txtNumTotal, tostring(allCnt))
	end

	if self.progressUProgress then
		self.progressUProgress.maxValue = allCnt > 0 and allCnt or 1
		self.progressUProgress.value = complete
	end
end

function PetDispatchHomeComponent:buildRewardItems(stageScoreTaskInfos)
	local complete = PetDispatchUtils.getDispatchProgress()
	local entries = {}

	for i = 1, ITEM_COUNT do
		local taskInfo = stageScoreTaskInfos and stageScoreTaskInfos[i]
		local taskCfg = taskInfo and EventTaskData[taskInfo.taskId]
		local rewards = taskCfg and taskCfg.award and LuaUIUtils.getRewardItemByDropId(taskCfg.award) or {}
		local item = rewards[1]
		local target = PetDispatchUtils.getStageScoreTarget(taskInfo)

		entries[i] = {
			index = i,
			id = item and item.id,
			num = item and item.num,
			iconUrl = item and (item.iconUrl or item.id and LuaUIUtils.getIconByItemId(item.id)),
			state = self:getRewardState(i, taskInfo),
			taskId = taskInfo and taskInfo.taskId,
			progressCurrent = math.min(complete, target),
			progressTarget = target
		}
	end

	return entries
end

function PetDispatchHomeComponent:getRewardState(index, stageScoreTaskInfo)
	if not stageScoreTaskInfo then
		return 0
	end

	local state = stageScoreTaskInfo.taskState

	if state == ActivityConst.TaskState.Received or state == ActivityConst.TaskState.Received_SendMail then
		return 1
	end

	if state == ActivityConst.TaskState.Finihed_CanRecv then
		return 2
	end

	return 0
end

function PetDispatchHomeComponent:refreshRewardItem(i)
	local btn = self.rewardItems[i]

	if not btn then
		return
	end

	local entry = self.rewardEntries and self.rewardEntries[i]

	if not entry then
		return
	end

	btn:TryChangePage("State", entry.state)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_PET_DISPATCH_REWARD_ITEM, i)

	pg.global.setRedDot(treePath, btn, entry.state == 2, RedDotConst.RedDotStyle.REWARD)

	local btnRef = btn:GetComponent("ObjectReference")
	local iconUImage = btnRef:GetRefValue("iconUImage")
	local txtNum = btnRef:GetRefValue("txtNum")
	local txtItemNum = btnRef:GetRefValue("txtItemNum")

	if iconUImage and entry.iconUrl then
		iconUImage.url = entry.iconUrl
	end

	if txtItemNum and entry.num then
		ClientTextUtils.setText(txtItemNum, tostring(entry.num))
	end

	if txtNum then
		local text = ""

		if entry.progressTarget and entry.progressTarget > 0 then
			text = entry.progressTarget
		end

		ClientTextUtils.setText(txtNum, text)
	end
end

function PetDispatchHomeComponent:onClickClue(i)
	local data = self.clues[i]

	if not data then
		return
	end

	if data.state == CLUE_STATE.LOCKED_NO_PREREQ or data.state == CLUE_STATE.LOCKED_UNFINISHED then
		local tipKey = data.state == CLUE_STATE.LOCKED_NO_PREREQ and "DISPATCH_TASK_TIME_NOT_REACHED" or "DISPATCH_PRE_TASK_UNDONE"

		pg.global.ui.tips:showTextTip(pg.getGameString(tipKey))

		return
	end

	if data.state == CLUE_STATE.COMPLETED then
		pg.global.ui:open(UIConst.UI_ID_PET_DISPATCH_SURVEY_COMPLETED, {
			defaultState = 0,
			eventId = self.eventId,
			clueId = data.taskId
		})

		return
	end

	if not data.taskId then
		return
	end

	if data.mapBlockId and pg.me and pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_DISPATCH_MAPBLOCK, data.mapBlockId, true) then
		local treePath = string.format(RedDotConst.RedDotPath.EVENT_PET_DISPATCH_TASK_ITEM, data.taskId)

		pg.global.setRedDot(treePath, self.clueSlots[i], false, RedDotConst.RedDotStyle.NONE)
		pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_DISPATCH_MAPBLOCK, data.mapBlockId, false)
	end

	pg.global.ui:open(UIConst.UI_ID_PET_DISPATCH_TASK, {
		eventId = self.eventId,
		clueId = data.taskId
	})
end

function PetDispatchHomeComponent:onClickReward(i)
	local entry = self.rewardEntries and self.rewardEntries[i]

	if not entry then
		return
	end

	if entry.state == 2 then
		if entry.taskId then
			pg.me:reqActReceiveTaskReward(entry.taskId, self.eventId)
		end

		return
	end

	if entry.id then
		pg.global.ui.commonItemTip:open({
			id = entry.id,
			targetRect = self.rewardItems[i]
		})
	end
end

return PetDispatchHomeComponent
