-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\Component\\DailyActiveComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("DailyActiveComponent")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local RedDotConst = require("Const.RedDotConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Vector3 = Vector3
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local GameEventData = require("Data.game_event_data")
local EventTaskData = require("Data.event_task_data")
local MessageName = require("Const.MessageName")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local SegmentProgressListComponent = require("Guis.Helper.SegmentProgressListComponent")
local BattlePassData = require("Data.event_battlepass_data")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local BP_PROGRESS_START_DELAY = 0.5
local BP_PROGRESS_GROW_DURATION = 0.5
local DailyActiveComponent = Class.LightClass("DailyActiveComponent", UIComponent)

DailyActiveComponent.messages = {
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onDayUpdate"
	},
	[MessageName.BATTLEPASS_LEVEL_UP] = {
		"_refreshBpProgress"
	},
	[MessageName.BATTLEPASS_CHANGE] = {
		"_refreshBpProgress"
	}
}

function DailyActiveComponent:ctor(ctrl, refUContainer, id)
	UIComponent.ctor(self, ctrl, refUContainer.transform)

	self.refUContainer = refUContainer
	self.cfgId = id
	self.refContainersLoaded = false
end

function DailyActiveComponent:findObjects()
	if self.transform.childCount == 0 then
		logger:warn("Transform has no children, UI may not be loaded yet")

		return
	end

	local root = self.transform:GetChild(0)
	local objectReference = root:GetComponent("ObjectReference")

	self.dailyActiveUWidget = objectReference:GetRefValue("dailyActiveUWidget")

	local titleObjRef = self.dailyActiveUWidget:GetComponent("ObjectReference")

	self.txtTitleUBaseText = titleObjRef:GetRefValue("txtTitleUBaseText")
	self.timeDesTxt = titleObjRef:GetRefValue("timeDesTxt")
	self.countDownUCountDown = titleObjRef:GetRefValue("countDownUCountDown")
	self.btnInfoUButton = titleObjRef:GetRefValue("btnInfoUButton")
	self.btnInfoUButtonConsole = titleObjRef:GetRefValue("btnInfoUButtonConsole")
	self.txtDetailsUBaseText = titleObjRef:GetRefValue("txtDetailsUBaseText")
	self.dailyActiveRewardUWidget = objectReference:GetRefValue("dailyActiveRewardUWidget")

	local dailyObjRef = self.dailyActiveRewardUWidget:GetComponent("ObjectReference")

	self.listUList = dailyObjRef:GetRefValue("listUList")
	self.listRewardUList = dailyObjRef:GetRefValue("listRewardUList")
	self.curProgressUBaseText = dailyObjRef:GetRefValue("curProgressUBaseText")
	self.totalRewardListUList = objectReference:GetRefValue("totalRewardListUList")

	local totalRewardTitleUSDFText = objectReference:GetRefValue("totalRewardTitleUSDFText")

	ClientTextUtils.setText(totalRewardTitleUSDFText, pg.getGameString("SCHOOL_GUIDE_DAILY_EXP_TIP"))

	self.progressLv = objectReference:GetRefValue("progressLv")
	self.txtCurLv = objectReference:GetRefValue("txtCurLv")
	self.textVXUSDFText = objectReference:GetRefValue("textVXUSDFText")
	self.levelUpUWidget = objectReference:GetRefValue("levelUpUWidget")
	self.txtLvExp = objectReference:GetRefValue("txtLvExp")
end

function DailyActiveComponent:onUILoaded()
	self.refContainersLoaded = true

	self:findObjects()
	self:_hideBpProgressWidget()
	self:addListener()
	self:refreshPage()
	self:_refreshBpProgress(false)
	self:_tryPlayDeferredBpProgressAnimation()
	self:_registerBpProgressTestInterface()
	pg.game.audio:playEvent("SFX_UI_DailyCheckIn_MoveIn")

	if self.listUList then
		self.listUList:SetEnableCustomInterval(false)
	end
end

function DailyActiveComponent:onHide()
	self:_hideBpProgressWidget()
	self:_stopBpProgressAnimation()
end

function DailyActiveComponent:onVisibleChange(visible)
	if visible then
		self:_tryPlayDeferredBpProgressAnimation()
	end
end

function DailyActiveComponent:addListener()
	function self.btnInfoUButton.luaClick()
		pg.global.ui.tips:openEventRuleDesc(ClientActivityUtils.getEventRule(self.eventId))
	end

	self.btnInfoUButtonConsole:SetGamepadAction("Raw/GamepadStart", nil, function()
		pg.global.ui.tips:openEventRuleDesc(ClientActivityUtils.getEventRule(self.eventId))
	end)

	function self.listUList.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data)
	end

	function self.totalRewardListUList.luaRenderItem(button, index, data)
		self:renderTotalRewardListItem(button, index, data)
	end

	function self.totalRewardListUList.luaClick(button, data)
		if not data or not data.item then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = data.item,
			targetRect = button
		})
	end

	if not self.dailyActiveProgressComponent then
		self._rewardItemComs = {}
		self.dailyActiveProgressComponent = SegmentProgressListComponent.new(self, nil, {
			waitFinishEvent = false,
			list = self.listRewardUList,
			getProgress = function(button)
				local itemComs = self._rewardItemComs[button]

				return itemComs and itemComs.progress, itemComs and itemComs.progress
			end,
			getTarget = function(data)
				return data.targetNum
			end,
			renderOther = function(button, index, data, visualTotal)
				self:renderRewardItem(button, index, data, visualTotal)
			end,
			onProgressChanged = function(currentTotal)
				self.dailyActiveProgressVisualTotal = currentTotal

				local displayValue = math.max(0, math.floor(currentTotal + 0.0001))

				if self.dailyActiveProgressDisplayValue == displayValue then
					return
				end

				self.dailyActiveProgressDisplayValue = displayValue

				ClientTextUtils.setText(self.curProgressUBaseText, displayValue)
			end,
			onSegmentComplete = function(button, index, data, currentTotal, isReached)
				if not isReached then
					return
				end

				if button and NotNil(button) then
					self:renderRewardItem(button, index, data, currentTotal)
				end

				self:refreshGamepadDefaultFocus()
			end
		})
	end

	function self.listRewardUList.luaFinishRender()
		self:refreshGamepadDefaultFocus()
	end
end

function DailyActiveComponent:refreshGamepadDefaultFocus()
	local rewardList = self.model:getDailyActiveRewardDataList()
	local defaultItem

	for i, data in ipairs(rewardList) do
		local isVisuallyReached = self.dailyActiveProgressVisualTotal == nil or self.dailyActiveProgressVisualTotal + 0.0001 >= data.targetNum

		if data.state == ClientConst.RewardState.ReadyToClaim and isVisuallyReached then
			local res, btn = self.listRewardUList:TryGetChildAt(i - 1)

			if res then
				local objRef = btn:GetComponent("ObjectReference")

				defaultItem = objRef:GetRefValue("rewardItem")
			end

			break
		end
	end

	self.listRewardUList:SetNavGroupDefaultItem(defaultItem)
end

function DailyActiveComponent:onDestroy()
	self:_clearBpProgressTestInterface()
	self:_hideBpProgressWidget()
	self:_stopBpProgressAnimation()

	self._bpProgressDeferred = nil

	UIComponent.onDestroy(self)
end

function DailyActiveComponent:_registerBpProgressTestInterface()
	self:_clearBpProgressTestInterface()

	function self._bpProgressTestFunc(addExp)
		addExp = tonumber(addExp)

		if not addExp or addExp ~= addExp or addExp == math.huge or addExp <= 0 then
			return false, "addExp 必须是正数"
		end

		addExp = math.floor(addExp)

		if addExp <= 0 then
			return false, "addExp 必须是正整数"
		end

		if not self.progressLv then
			return false, "每日活跃 BP 进度节点未加载"
		end

		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
		local phase = actData and actData.activityBase and actData.activityBase.activityPhase
		local bpData = phase and BattlePassData[phase]
		local expPerLv = bpData and bpData.passExperienceLimit or 0

		if not actData or expPerLv <= 0 then
			return false, "当前战令数据不可用"
		end

		local startLevel = actData.bpLevel or 0
		local startExp = actData.bpExp or 0
		local totalExp = startExp + addExp
		local targetLevel = startLevel + math.floor(totalExp / expPerLv)
		local targetExp = totalExp % expPerLv

		self._bpProgressDeferred = nil

		self:_refreshBpProgress(false, {
			bpLevel = startLevel,
			bpExp = startExp,
			expPerLv = expPerLv
		})
		self:_refreshBpProgress(true, {
			bpLevel = targetLevel,
			bpExp = targetExp,
			expPerLv = expPerLv
		})

		return true
	end

	pg.testDailyActiveBpProgress = self._bpProgressTestFunc
end

function DailyActiveComponent:_clearBpProgressTestInterface()
	if pg.testDailyActiveBpProgress == self._bpProgressTestFunc then
		pg.testDailyActiveBpProgress = nil
	end

	self._bpProgressTestFunc = nil
end

function DailyActiveComponent:_stopBpProgressAnimation()
	self._bpProgressAnimVersion = (self._bpProgressAnimVersion or 0) + 1
	self._bpProgressAnimPhase = nil

	if self._bpProgressDelayTimer then
		self:killTimer(self._bpProgressDelayTimer)

		self._bpProgressDelayTimer = nil
	end

	if self.progressLv then
		self.progressLv:KillProcessAnim()
	end
end

function DailyActiveComponent:_isBpProgressVisible()
	if not self.progressLv then
		return false
	end

	if self.ctrl then
		return self:checkUIShow() and true or false
	end

	return self._visible ~= false
end

function DailyActiveComponent:_tryPlayDeferredBpProgressAnimation()
	local deferred = self._bpProgressDeferred

	if not deferred or not self:_isBpProgressVisible() then
		return
	end

	self._bpProgressDeferred = nil

	self:_refreshBpProgress(true, deferred.testData, deferred)
end

function DailyActiveComponent:_showBpProgressWidget()
	if not self.levelUpUWidget then
		return
	end

	if self._bpProgressHideTimer then
		self:killTimer(self._bpProgressHideTimer)

		self._bpProgressHideTimer = nil
	end

	self.levelUpUWidget.gameObject:SetActiveEx(true)

	self._bpProgressHideTimer = self:startTimer(function()
		self._bpProgressHideTimer = nil

		if self.levelUpUWidget then
			self.levelUpUWidget.gameObject:SetActiveEx(false)
		end
	end, 3)
end

function DailyActiveComponent:_hideBpProgressWidget()
	if self._bpProgressHideTimer then
		self:killTimer(self._bpProgressHideTimer)

		self._bpProgressHideTimer = nil
	end

	if self.levelUpUWidget then
		self.levelUpUWidget.gameObject:SetActiveEx(false)
	end
end

function DailyActiveComponent:_refreshBpProgress(animateProgress, testData, deferredInfo)
	local progress = self.progressLv

	if not progress then
		return
	end

	local actData = testData or ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = not testData and actData and actData.activityBase and actData.activityBase.activityPhase
	local bpData = testData and {
		passExperienceLimit = testData.expPerLv
	} or phase and BattlePassData[phase]

	if not actData or not bpData then
		return
	end

	local bpLevel = actData.bpLevel or 0
	local bpExp = actData.bpExp or 0
	local expPerLv = bpData.passExperienceLimit or 0
	local isMaxLevel = not testData and CashShopRedDotUtils.isBattlePassMaxLevel()
	local targetProgress = isMaxLevel and 1 or expPerLv > 0 and math.min(1, bpExp / expPerLv) or 0
	local displayBpExp = isMaxLevel and expPerLv or bpExp

	if self.txtLvExp then
		ClientTextUtils.setText(self.txtLvExp, pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_BP_EXP"), displayBpExp))
	end

	animateProgress = animateProgress ~= false

	local pendingDeferred = self._bpProgressDeferred
	local oldLevel = self._bpLevel
	local isLevelUp = deferredInfo and deferredInfo.isLevelUp or pendingDeferred and pendingDeferred.isLevelUp or oldLevel ~= nil and oldLevel < bpLevel or false

	self._bpLevel = bpLevel

	local previousTarget = self._bpProgressTarget
	local previousPhase = self._bpProgressAnimPhase
	local playLevelUpProgress = isLevelUp or previousPhase == "levelUp"

	local function setLevelText()
		if self.txtCurLv then
			ClientTextUtils.setText(self.txtCurLv, tostring(bpLevel))
		end

		if self.textVXUSDFText then
			ClientTextUtils.setText(self.textVXUSDFText, tostring(bpLevel))
		end
	end

	local function invokeProgressCallback(invokeTime)
		if self.levelUpUWidget then
			self.levelUpUWidget:InvokeCallback(invokeTime)
		end
	end

	local function showFinalLevel()
		setLevelText()

		if playLevelUpProgress then
			invokeProgressCallback(CS.XGUI.EInvokeTime.Custom3)
		end
	end

	if not playLevelUpProgress then
		setLevelText()
	end

	if animateProgress and not isLevelUp and previousTarget == targetProgress then
		return
	end

	if pendingDeferred and not animateProgress then
		return
	end

	if animateProgress and previousTarget ~= nil and not self:_isBpProgressVisible() then
		self._bpProgressDeferred = {
			isLevelUp = playLevelUpProgress,
			testData = testData
		}

		return
	end

	self._bpProgressDeferred = nil

	if self._bpProgressDelayTimer then
		self:killTimer(self._bpProgressDelayTimer)

		self._bpProgressDelayTimer = nil
	end

	self._bpProgressTarget = targetProgress
	self._bpProgressAnimVersion = (self._bpProgressAnimVersion or 0) + 1

	local version = self._bpProgressAnimVersion

	local function isValid()
		return version == self._bpProgressAnimVersion and self.progressLv == progress
	end

	local function setImmediately()
		self._bpProgressAnimPhase = nil

		progress:ProgressToValue(targetProgress, nil, 0)
		showFinalLevel()
	end

	if not animateProgress or previousTarget == nil then
		setImmediately()

		return
	end

	if not playLevelUpProgress and targetProgress <= previousTarget then
		setImmediately()

		return
	end

	local shouldInvokeStart = previousPhase == nil

	local function onProgressFinished()
		if not isValid() then
			return
		end

		self._bpProgressAnimPhase = nil

		if progress.gameObject.activeInHierarchy then
			invokeProgressCallback(CS.XGUI.EInvokeTime.Custom2)
		end
	end

	local function growToFinalProgress()
		if not isValid() then
			return
		end

		self._bpProgressAnimPhase = "final"

		if targetProgress > progress.value and progress.gameObject.activeInHierarchy then
			progress:ProgressToValue(targetProgress, onProgressFinished, BP_PROGRESS_GROW_DURATION)
		else
			progress:ProgressToValue(targetProgress, nil, 0)
			onProgressFinished()
		end
	end

	local function playProgressAnimation()
		if not isValid() then
			return
		end

		if not progress.gameObject.activeInHierarchy then
			setImmediately()

			return
		end

		if shouldInvokeStart then
			invokeProgressCallback(CS.XGUI.EInvokeTime.Custom1)
		end

		if playLevelUpProgress then
			self._bpProgressAnimPhase = "levelUp"

			local function onProgressFull()
				if not isValid() then
					return
				end

				showFinalLevel()

				if targetProgress >= 1 then
					onProgressFinished()

					return
				end

				progress:ProgressToValue(0, nil, 0)
				growToFinalProgress()
			end

			if progress.value < 1 then
				progress:ProgressToValue(1, onProgressFull, BP_PROGRESS_GROW_DURATION)
			else
				onProgressFull()
			end
		else
			self._bpProgressAnimPhase = "normal"

			progress:ProgressToValue(targetProgress, onProgressFinished, BP_PROGRESS_GROW_DURATION)
		end
	end

	self._bpProgressAnimPhase = playLevelUpProgress and "levelUp" or "normal"

	self:_showBpProgressWidget()

	self._bpProgressDelayTimer = self:startTimer(function()
		if not isValid() then
			return
		end

		self._bpProgressDelayTimer = nil

		playProgressAnimation()
	end, BP_PROGRESS_START_DELAY)
end

function DailyActiveComponent:refreshPage()
	pg.game.audio:playEvent("SFX_UI_ActivePage_MoveInCommon")

	local gameEventData = GameEventData[self.eventId]
	local activityTitle = gameEventData.name
	local activityDesc = gameEventData.eventDesc
	local nextRefreshTs = TimeUtils.getServerDayBegin() + 86400

	ClientTextUtils.setText(self.txtTitleUBaseText, pg.getLocalizationText(activityTitle))
	ClientTextUtils.setText(self.txtDetailsUBaseText, pg.getLocalizationText(activityDesc))

	if nextRefreshTs then
		LuaUIUtils.setCountDownTime(self.countDownUCountDown, nextRefreshTs, UIConst.TimeType.Short, nil, nil, nil, "SCHOOL_GUIDE_TIME_TIP")
	end

	self._isScoreFull = LuaUIUtils.isDailyActiveScoreFull()

	local taskList = self.model:getDailyActiveTaskDataList()

	self.listUList:SetList(taskList)
	self:refreshRewardProgress()
end

function DailyActiveComponent:refreshRewardProgress()
	local rewardList = self.model:getDailyActiveRewardDataList()
	local playerActivityDailyActive = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.DailyActive)
	local curProgress = playerActivityDailyActive and playerActivityDailyActive.dailyActiveScore or 0

	self.dailyActiveProgressComponent:refresh(rewardList, curProgress)
	self:refreshTotalReward()
end

function DailyActiveComponent:enter(tabType)
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.DailyActive)

	self.mainTabType = tabType
	self.eventId = activityId

	self:show()

	if self.refUContainer:CheckURLLoaded() then
		self:onUILoaded()
	else
		self.refUContainer:LoadDefaultUrlManually(function()
			self:onUILoaded()
		end)
	end
end

function DailyActiveComponent:exit()
	self._rewardReq = nil

	self:_clearBpProgressTestInterface()
	self:_hideBpProgressWidget()
	self:_stopBpProgressAnimation()

	if self.listUList then
		self.listUList:SetEnableCustomInterval(true)
	end

	self:hide()
end

function DailyActiveComponent:onDayUpdate()
	local isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.DailyActive)

	self.eventId = activityId

	if self._rewardReq then
		self:refreshRewardProgress()
	else
		self:refreshPage()
	end

	self:refreshGamepadDefaultFocus()

	self._rewardReq = nil
end

function DailyActiveComponent:setFirstTabRed(button, index, data)
	local redPath = string.format(RedDotConst.RedDotPath.SCHOOL_GUIDE_TAB_LIST_ITEM .. "Consist", data.tabType)

	pg.global.setPreViewRedDot(redPath, button, function()
		return LuaUIUtils.SchoolGuide_getDailyActiveRedDotStyle()
	end)
end

function DailyActiveComponent:renderTaskItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNumberUBaseText = objectReference:GetRefValue("textNumberUBaseText")
	local textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	local textDescribeUBaseText = objectReference:GetRefValue("textDescribeUBaseText")
	local textDoingUBaseText = objectReference:GetRefValue("textDoingUBaseText")
	local btnGet = objectReference:GetRefValue("btnGet")
	local btnGo = objectReference:GetRefValue("btnGo")
	local textReceivedUBaseText = objectReference:GetRefValue("textReceivedUBaseText")
	local txtGoUBaseText = objectReference:GetRefValue("txtGoUBaseText")
	local textScoreUBaseText = objectReference:GetRefValue("textScoreUBaseText")
	local txtCanReceivedTxt = objectReference:GetRefValue("txtCanReceivedTxt")
	local scrollRectContentUScrollRect = objectReference:GetRefValue("scrollRectContentUScrollRect")
	local state
	local isScoreFull = self._isScoreFull

	state = data.taskState == ActivityConst.TaskState.Received and 3 or isScoreFull and 1 or data.taskState == ActivityConst.TaskState.Finihed_CanRecv and 2 or data.taskEvent ~= nil and 0 or 1

	button:TryChangePage("Type", state)

	local finishCnt = pg.me.triggerMap:getConditionTargetCount(data.taskCondition, 1)
	local isTaskFinished = data.taskState == ActivityConst.TaskState.Finihed_CanRecv or data.taskState == ActivityConst.TaskState.Received
	local curCnt = isTaskFinished and finishCnt or pg.me.triggerMap:getConditionFinishCount(data.taskCondition, 1)

	ClientTextUtils.setText(textNumberUBaseText, string.format("%d/%d", curCnt, finishCnt))
	ClientTextUtils.setText(textNameUBaseText, pg.getLocalizationText(data.taskTitle))

	if scrollRectContentUScrollRect then
		ClientTextUtils.setText(scrollRectContentUScrollRect.content, pg.getLocalizationText(data.taskDes))
	end

	local doingText = isScoreFull and pg.getGameString("SCHOOL_GUIDE_DAILY_SCORE_FULL") or pg.getGameString("BUTTON_NAME_3")

	ClientTextUtils.setText(textDoingUBaseText, doingText)
	ClientTextUtils.setText(txtGoUBaseText, pg.getGameString("CHARACTER_SKILL_GO"))
	ClientTextUtils.setText(txtCanReceivedTxt, pg.getGameString("BUTTON_NAME_2"))
	ClientTextUtils.setText(textReceivedUBaseText, pg.getGameString("SCHOOL_GUIDE_DAILY_RECEIVED"))
	ClientTextUtils.setText(textScoreUBaseText, string.format("+%d", data.taskAward))

	btnGet.clickSoundUrl = AudioConst.EVENT_DAILY_ACTIVE_CLAIM_REWARD

	function btnGet.luaClick()
		pg.me:reqActReceiveTaskReward(data.taskId, self.eventId)
	end

	function btnGo.luaClick()
		local eventId = data.taskEvent

		if eventId then
			pg.me:doEvent(eventId)
		end
	end

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_DAILY_ACTIVE_TASK_ITEM, index)
	local showRedDot = not isScoreFull and data.taskState == ActivityConst.TaskState.Finihed_CanRecv

	pg.global.setRedDot(treePath, btnGet, showRedDot, RedDotConst.RedDotStyle.POINT)
end

function DailyActiveComponent:renderRewardItem(button, index, data, visualTotal)
	if visualTotal ~= nil then
		self.dailyActiveProgressVisualTotal = visualTotal
	end

	local renderData = {}

	for key, value in pairs(data) do
		renderData[key] = value
	end

	if renderData.state == ClientConst.RewardState.ReadyToClaim and visualTotal ~= nil and visualTotal + 0.0001 < renderData.targetNum then
		renderData.state = ClientConst.RewardState.NotAchieved
	end

	if renderData.state == ClientConst.RewardState.ReadyToClaim then
		function renderData.extraFunc()
			self._rewardReq = true

			local groupId = EventTaskData[renderData.taskId] and EventTaskData[renderData.taskId].groupId

			pg.me:reqActReceiveGroupTaskReward(groupId, self.eventId)
		end
	end

	self._rewardItemComs[button] = ClientActivityUtils.onRenderRewardProgressItem(button, index, renderData, true)

	local treePath = string.format(RedDotConst.RedDotPath.EVENT_DAILY_ACTIVE_REWARD_ITEM, index + 1)
	local showRedDot = renderData.state == ClientConst.RewardState.ReadyToClaim and ClientActivityUtils.redDotPoint_CheckDailyActiveRewardItem(renderData.taskId)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function DailyActiveComponent:refreshTotalReward()
	local data = {}
	local cur, max = self:getReceivedAndTotalRewardCount(ItemConst.ITEM_SPECIAL_EXP_PLAYER)

	table.insert(data, {
		item = ItemConst.ITEM_SPECIAL_EXP_PLAYER,
		cur = cur,
		max = max
	})

	cur, max = self:getReceivedAndTotalRewardCount(ItemConst.ITEM_SPECIAL_EXP_BP)

	table.insert(data, {
		item = ItemConst.ITEM_SPECIAL_EXP_BP,
		cur = cur,
		max = max
	})
	self.totalRewardListUList:SetList(data)
end

function DailyActiveComponent:renderTotalRewardListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local iconUrl = LuaUIUtils.getIconByItemId(data.item)

	bgUImage.url = iconUrl

	ClientTextUtils.setText(txtNameUSDFText, string.format("%s/%s", data.cur, data.max))
end

function DailyActiveComponent:getAllBP()
	return self:getReceivedAndTotalRewardCount(ItemConst.ITEM_SPECIAL_EXP_BP)
end

function DailyActiveComponent:getAllExp()
	return self:getReceivedAndTotalRewardCount(ItemConst.ITEM_SPECIAL_EXP_PLAYER)
end

function DailyActiveComponent:getReceivedAndTotalRewardCount(itemId)
	local receivedCount = 0
	local totalCount = 0
	local rewardList = self.model:getDailyActiveRewardDataList()

	for _, rewardData in ipairs(rewardList) do
		local rewardItems = LuaUIUtils.getRewardFixedItemsByDropId(rewardData.dropId)

		for _, rewardItem in ipairs(rewardItems) do
			if rewardItem.id == itemId then
				local count = rewardItem.num or 0

				totalCount = totalCount + count

				if rewardData.state == ClientConst.RewardState.Claimed then
					receivedCount = receivedCount + count
				end
			end
		end
	end

	return receivedCount, totalCount
end

return DailyActiveComponent
