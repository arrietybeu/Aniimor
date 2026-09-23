-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventEcoTraceTask\\EventEcoTraceTaskCtrl.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local EventEcoTraceTaskCtrl = Class.LightClass("EventEcoTraceTaskCtrl", UICtrl)

EventEcoTraceTaskCtrl.messages = {
	[MessageName.EVENT_GET_VITALITY_REWARD] = {
		"refreshView",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"refreshView",
		true
	}
}

function EventEcoTraceTaskCtrl:onCreate(eventId)
	UICtrl.onCreate(self, eventId)

	self.eventId = eventId
end

function EventEcoTraceTaskCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	local cData = ClientActivityUtils.getEcoTraceActivityCfg()

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openEventRuleDesc(pg.getLocalizationText(cData.investigateRule))
	end

	function self.view.tabList.luaRenderItem(button, index, data)
		self:renderTabItem(button, index, data)
	end

	function self.view.taskList.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data)
	end

	function self.view.topRewardList.luaRenderItem(button, index, data)
		if data.canGet and not data.hasGet then
			function data.extraFunc()
				pg.me:reqActReceiveTaskReward(data.chapterTaskId, self.eventId)
			end
		end

		LuaUIUtils.renderRewardItem(button, data)
	end

	function self.view.btnGetUButton.luaClick()
		if self.canGetReward then
			local tabCfg = self.tabCfgs[self.curPage]

			pg.me:reqActReceiveTaskReward(tabCfg.chapterTaskId, self.eventId)
		end
	end
end

function EventEcoTraceTaskCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initUI()
end

function EventEcoTraceTaskCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function EventEcoTraceTaskCtrl:initUI()
	ClientTextUtils.setText(self.view.txtTitle, pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_TITLE"))
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_ONGOING"))
	ClientTextUtils.setText(self.view.txtBtnGet, pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_CLAIMABLE"))
	ClientTextUtils.setText(self.view.txtBtnGot, pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_CLAIMED"))

	local chapterCfg = self.model:getChapterCfg()

	if not chapterCfg or not next(chapterCfg) then
		return
	end

	self.tabCfgs = {}

	for i, questCfgs in pairs(chapterCfg) do
		local chapterTaskInfo = self.model:getChapterTaskInfo(questCfgs)

		if chapterTaskInfo then
			self.tabCfgs[#self.tabCfgs + 1] = {
				type = questCfgs.taskType,
				tabName = questCfgs.tabName,
				tabIcon = questCfgs.iconResId,
				chapterIcon = questCfgs.chapterIcon,
				maxCount = chapterTaskInfo.maxCount,
				chapterAward = chapterTaskInfo.taskAward,
				chapterTaskId = chapterTaskInfo.taskId,
				chapterId = i
			}
		end
	end

	table.sort(self.tabCfgs, function(a, b)
		return a.chapterId < b.chapterId
	end)

	for page, tabCfg in ipairs(self.tabCfgs) do
		tabCfg.page = page
	end

	self.view.tabList:SetList(self.tabCfgs)

	local res, button = self.view.tabList:TryGetChildAt(0)

	if res then
		self.curPage = 1

		button:OnClickSimulate()
	end

	self:refreshQuestList()
end

function EventEcoTraceTaskCtrl:refreshView()
	self.view.tabList:RefreshList()
	self:refreshQuestList()
end

function EventEcoTraceTaskCtrl:renderTabItem(button, index, data)
	if data == nil then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local nameUBaseText = objectReference:GetRefValue("nameUBaseText")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")

	iconUImage.url = data.tabIcon

	ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(data.tabName))

	local completeNum, canGetChild = self.model:getTaskCompleteNum(data.type)

	completeNum = math.min(completeNum, data.maxCount)

	local chapterTaskState = self.model:getTaskState(data.chapterTaskId)
	local canGetChapter = chapterTaskState == ActivityConst.TaskState.Finihed_CanRecv

	ClientTextUtils.setText(numUBaseText, pg.getFormatText(" {0}/{1}", completeNum, data.maxCount))

	function button.luaClick()
		if self.curPage ~= data.page then
			self.curPage = data.page

			self:refreshQuestList()
			self.view.tabList:RefreshList()
		end
	end

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_ECO_TRACE_QUEST_TAB, data.type)

	pg.global.setRedDot(treePath, button, canGetChild or canGetChapter, RedDotConst.RedDotStyle.REWARD)
end

function EventEcoTraceTaskCtrl:refreshQuestList()
	local tabCfg = self.tabCfgs[self.curPage]

	if not tabCfg then
		return
	end

	self.view.imgTabIcon.url = tabCfg.chapterIcon

	local questInfos = self.model:getTaskCfgDic(tabCfg.type)
	local completeNum = self.model:getTaskCompleteNum(tabCfg.type)

	completeNum = math.min(completeNum, tabCfg.maxCount)

	local chapterTaskState = self.model:getTaskState(tabCfg.chapterTaskId)
	local hasGet = self.model:isTaskRewardReceived(tabCfg.chapterTaskId)
	local canGetChapter = chapterTaskState == ActivityConst.TaskState.Finihed_CanRecv
	local rewards = LuaUIUtils.getRewardItemByDropId(tabCfg.chapterAward)

	if rewards and next(rewards) then
		for _, data in ipairs(rewards) do
			data.hasGet = hasGet
			data.canGet = canGetChapter
			data.chapterTaskId = tabCfg.chapterTaskId
		end

		self.view.topRewardList:SetList(rewards)
	else
		self.view.topRewardList:SetList({})
	end

	if questInfos and next(questInfos) then
		self.view.taskList:SetList(questInfos)
	else
		self.view.taskList:SetList({})
	end

	ClientTextUtils.setText(self.view.txtQuestPro, pg.getFormatText(" {0}/{1}", completeNum, tabCfg.maxCount))

	local allComplete = hasGet
	local state = 0

	if allComplete then
		state = 2
	elseif canGetChapter then
		state = 1
	end

	self.canGetReward = canGetChapter

	self.view.btnDarkUComponent:TryChangePage("State", state)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_ECO_TRACE_QUEST_REWARD, tabCfg.type)

	pg.global.setRedDot(treePath, self.view.btnGetUButton, self.canGetReward, RedDotConst.RedDotStyle.REWARD)
	self:tryRefreshFirstConsoleKeyTrack()
end

function EventEcoTraceTaskCtrl:renderTaskItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")
	local txtDetailsUBaseText = objectReference:GetRefValue("txtDetailsUBaseText")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local btnTrackUButton = objectReference:GetRefValue("btnTrackUButton")

	btnTrackUButton.luaClick = nil

	if data.taskEvent and data.taskEvent ~= 0 then
		function btnTrackUButton.luaClick()
			pg.me:doEvent(data.taskEvent)
		end
	end

	function listRewardUList.luaRenderItem(button, rIndex, rData)
		local canReceive = data.taskState == ActivityConst.TaskState.Finihed_CanRecv

		if canReceive then
			function rData.extraFunc()
				pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
			end
		end

		LuaUIUtils.renderRewardItem(button, rData)

		local treePath = string.format(RedDotConst.RedDotPath.EVENT_ECO_TRACE_QUEST_REWARD_ITEM, self.curPage, index, rIndex)

		pg.global.setRedDot(treePath, button, canReceive, RedDotConst.RedDotStyle.REWARD)
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward)

	if rewards and next(rewards) then
		for _, rewardData in ipairs(rewards) do
			rewardData.hasGet = data.hasGet
			rewardData.canGet = data.taskState == ActivityConst.TaskState.Finihed_CanRecv
		end

		listRewardUList:SetList(rewards)
	else
		listRewardUList:SetList({})
	end

	function item.luaClick()
		if data.taskState == ActivityConst.TaskState.Finihed_CanRecv then
			pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
		end
	end

	local curProNum = data.isComplete and pg.me.triggerMap:getConditionTargetCount(data.taskCondition, 1) or pg.me.triggerMap:getConditionFinishCount(data.taskCondition, 1)
	local showType = 0

	if data.isComplete then
		showType = data.hasGet and 1 or 2
	end

	item:TryChangePage("State", showType)
	btnTrackUButton.gameObject:SetActiveEx(data.taskEvent and data.taskEvent ~= 0)
	ClientTextUtils.setText(txtDetailsUBaseText, pg.getFormatText(pg.getLocalizationText(data.taskDes), curProNum))

	local hasTaskEvent = data.taskEvent and data.taskEvent ~= 0

	item:TryChangePage("HasTaskEvent", hasTaskEvent and 1 or 0)
end

function EventEcoTraceTaskCtrl:tryRefreshFirstConsoleKeyTrack()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if not self.view or not self.view.taskList then
		return
	end

	TimerManager.addNextFrameCb(function()
		local res, item = self.view.taskList:TryGetChildAt(0)

		if not res then
			return
		end

		if item.isNavFocused then
			local objectReference = item:GetComponent("ObjectReference")
			local keyTrackUWidget = objectReference and objectReference:GetRefValue("keyTrackUWidget")

			if keyTrackUWidget then
				keyTrackUWidget:RefreshActiveCtrl()
			end
		end
	end)
end

return EventEcoTraceTaskCtrl
