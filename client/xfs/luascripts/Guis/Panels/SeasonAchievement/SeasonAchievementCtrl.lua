-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonAchievement\\SeasonAchievementCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ActivityConst = require("Common.Const.ActivityConst")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SeasonAchievementCtrl = Class.LightClass("SeasonAchievementCtrl", UICtrl)
local LEVEL_UP_OBTAIN_WAIT_INTERVAL = 0.1
local LEVEL_UP_OBTAIN_WAIT_TICKS = 15
local LEVEL_UP_OBTAIN_CLOSE_DELAY_FRAMES = 2
local GAMEPAD_FOCUS_DELAY_FRAMES = 2

SeasonAchievementCtrl.messages = {
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.EVENT_REFRESH_REDDOT] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.EVENT_REFRESH_TAB_LIST] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onActivityStateChanged",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityStateChanged",
		true
	}
}

function SeasonAchievementCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnBadgeUButton.luaClick()
		self:_goToBadgeSource()
	end

	function self.view.btnIconUButton.luaClick()
		self:_showAchievementPointItemTip()
	end

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self:_renderStageReward(button, data, index + 1)
	end

	function self.view.listManualUList.luaRenderItem(button, index, data)
		self:_renderManualItem(button, data)
	end

	function self.view.listManualUList.luaClick(button, data)
		self:_showManual(data.manualIndex)
	end
end

function SeasonAchievementCtrl:_addSubManualListener()
	if self._subManualListenerAdded then
		return
	end

	self._subManualListenerAdded = true

	function self.view.btnBackUButton.luaClick()
		self:_showOverview()
	end

	function self.view.leftArrowUButton.luaClick()
		self:_changeManual(-1)
	end

	function self.view.rightArrowUButton.luaClick()
		self:_changeManual(1)
	end

	function self.view.btnGetAllUButton.luaClick()
		self:_receiveAllCurrentManualRewards()
	end

	function self.view.taskUList.luaRenderItem(button, index, data)
		self:_renderManualTask(button, data)
	end
end

function SeasonAchievementCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if not self:_checkSeasonAchievementActivityOpen() then
		return
	end

	self:_clearLevelUpAnimationWait()

	self.eventId = self.model:getActivityId()
	self._currentManualIndex = nil
	self._rewardListPositioned = false
	self._subManualDestroyed = false
	self._subManualReady = false
	self._subManualLoading = false
	self._subManualListenerAdded = false
	self._needGamepadFocus = false

	self:_refreshOverview()
	self:_showOverview()
	self:_scheduleGamepadDefaultFocus(true)
end

function SeasonAchievementCtrl:onActivityStateChanged()
	if not self.view or not self:_checkSeasonAchievementActivityOpen() then
		return
	end

	local previousLevel = self._totalMilestone and self._totalMilestone.level

	self.eventId = self.model:getActivityId()

	self:_refreshOverview()

	if self._currentManualIndex then
		self:_refreshManual()
	end

	self:_scheduleGamepadDefaultFocus(false)

	local currentLevel = self._totalMilestone and self._totalMilestone.level

	if previousLevel and currentLevel and previousLevel < currentLevel then
		self:_waitForLevelUpAnimation()
	end
end

function SeasonAchievementCtrl:_checkSeasonAchievementActivityOpen()
	if self.model:isSeasonAchievementActivityOpen() then
		return true
	end

	self:close()

	return false
end

function SeasonAchievementCtrl:_refreshOverview()
	local headerInfo = self.model:getHeaderInfo()
	local titleText = headerInfo.titleTextId and pg.getLocalizationText(headerInfo.titleTextId) or ""
	local seasonTagText = headerInfo.seasonTagTextId or ""

	if type(seasonTagText) == "number" then
		seasonTagText = pg.getLocalizationText(seasonTagText)
	end

	ClientTextUtils.setText(self.view.titleUSDFText, titleText)
	ClientTextUtils.setText(self.view.txtTitleUSDFText, titleText)
	ClientTextUtils.setText(self.view.subTitleUSDFText, seasonTagText)

	if headerInfo.seasonTagIcon ~= "" then
		self.view.subTitleIconUImage.url = headerInfo.seasonTagIcon
	end

	local endTime = self.model:getActivityEndTime()

	if endTime then
		self.view.timeUCountDown:SetActive(true)
		LuaUIUtils.setCountDownTime(self.view.timeUCountDown, endTime, UIConst.TimeType.Short)
	else
		self.view.timeUCountDown:Stop()
		self.view.timeUCountDown:SetActive(false)
	end

	self._stageRewards = self.model:getStageRewards()
	self._listStageRewards = {}

	for index = 1, #self._stageRewards - 1 do
		self._listStageRewards[index] = self._stageRewards[index]
	end

	self._totalMilestone = self.model:getTotalMilestone(self._stageRewards)
	self._gameplayRows = self.model:getGameplayRows()

	local achievementPointItemId = self.model:getAchievementPointItemId()

	if self._achievementPointItemId ~= achievementPointItemId then
		self._achievementPointItemId = achievementPointItemId
		self._achievementPointItemTipData = achievementPointItemId and {
			hideCount = true,
			id = achievementPointItemId
		}
	end

	ClientTextUtils.setText(self.view.txtLevelUSDFText, self._totalMilestone.level)
	ClientTextUtils.setText(self.view.progressUSDFText, string.format("%s/%s", self._totalMilestone.current, self._totalMilestone.target))

	self.view.progressUProgress.normalizedValue = self._totalMilestone.normalizedProgress

	if achievementPointItemId then
		self.view.iconUImage.url = LuaUIUtils.getIconByItemId(achievementPointItemId)
	else
		self.view.iconUImage:ClearUrl()
	end

	self.view.listRewardUList:SetList(self._listStageRewards)
	self.view.listManualUList:SetList(self._gameplayRows)
	self:_bindRewardListScroll()
	self:_locateInitialRewardList()
end

function SeasonAchievementCtrl:_bindRewardListScroll()
	if self._onRewardListScroll then
		self.view.listRewardUList:UnRegisterToScrollEvent(self._onRewardListScroll)
	end

	function self._onRewardListScroll()
		self:_refreshStageRewardPreview()
	end

	self.view.listRewardUList:RegisterToScrollEvent(self._onRewardListScroll)
	self:startFrameTimer(function()
		if self.view then
			self:_refreshStageRewardPreview()
		end
	end, 1)
end

function SeasonAchievementCtrl:_locateInitialRewardList()
	if self._rewardListPositioned or not self._listStageRewards or #self._listStageRewards == 0 then
		return
	end

	self._rewardListPositioned = true

	local targetIndex = self.model:getRewardListInitialIndex(self._listStageRewards)

	self:startFrameTimer(function()
		if not self.view or not self.view.listRewardUList then
			return
		end

		self.view.listRewardUList:GoToIndex(targetIndex, true)
		self:_refreshStageRewardPreview()
	end, 1)
end

function SeasonAchievementCtrl:_scheduleGamepadDefaultFocus(needFocus)
	self._needGamepadFocus = self._needGamepadFocus or needFocus
	self._gamepadFocusToken = (self._gamepadFocusToken or 0) + 1

	local token = self._gamepadFocusToken

	self:startFrameTimer(function()
		if not self.view or token ~= self._gamepadFocusToken then
			return
		end

		local needFocusNow = self._needGamepadFocus

		self._needGamepadFocus = false

		self:_refreshGamepadDefaultFocus(needFocusNow)
	end, GAMEPAD_FOCUS_DELAY_FRAMES)
end

function SeasonAchievementCtrl:_refreshGamepadDefaultFocus(needFocus)
	local receivableRewardButton = self:_getStageRewardNavButton(self.model:getReceivableStageRewardIndex(self._stageRewards))
	local currentRewardButton = self:_getStageRewardNavButton(self.model:getCurrentStageRewardIndex(self._stageRewards))
	local manualButton = self:_getManualNavButton(self.model:getReceivableGameplayIndex(self._gameplayRows) or 1)
	local mileageDefaultButton = receivableRewardButton or currentRewardButton

	if mileageDefaultButton then
		self.view.topAchievementInfo:SetNavGroupDefaultItem(mileageDefaultButton)
	end

	if manualButton then
		self.view.listManualUList:SetNavGroupDefaultItem(manualButton)
	end

	if not needFocus or self._currentManualIndex or not pg.game.input:isUsingGamepad() then
		return
	end

	local focusButton = receivableRewardButton or manualButton

	if focusButton then
		pg.global.navMgr:FocusItem(focusButton)
	end
end

function SeasonAchievementCtrl:_getStageRewardNavButton(rewardIndex)
	if not rewardIndex or IsNil(self.view.listRewardUList) then
		return nil
	end

	local ok, button = self.view.listRewardUList:TryGetChildAt(rewardIndex - 1)

	return ok and button or nil
end

function SeasonAchievementCtrl:_getManualNavButton(manualIndex)
	if not manualIndex or IsNil(self.view.listManualUList) then
		return nil
	end

	local ok, button = self.view.listManualUList:TryGetChildAt(manualIndex - 1)

	return ok and button or nil
end

function SeasonAchievementCtrl:_renderRewardContent(button, data, rewardLevel)
	local objectReference = button:GetComponent("ObjectReference")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local itemUButton = objectReference:GetRefValue("itemUButton")
	local itemObjectReference = itemUButton:GetComponent("ObjectReference")
	local itemIconUImage = itemObjectReference and itemObjectReference:GetRefValue("itemIconUImage") or objectReference:GetRefValue("itemIconUImage")
	local rewards = data.award and LuaUIUtils.getRewardItemByDropId(data.award) or {}
	local reward = rewards[1]

	button:TryChangePage("State", data.displayState)
	itemUButton:ClearRedDot()

	local redDotPath = string.format(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_REWARD_ITEM, data.taskId)

	pg.global.setRedDot(redDotPath, itemUButton, data.displayState == 1, RedDotConst.RedDotStyle.REWARD)
	ClientTextUtils.setText(numUSDFText, rewardLevel)

	if reward then
		LuaUIUtils.renderRewardItem(itemUButton, reward)

		if itemIconUImage then
			itemIconUImage.url = LuaUIUtils.getIconByItemId(reward.id)
		end

		local function rewardClick()
			if data.displayState == 1 then
				self:_receiveAllStageRewards(data.taskGroupId)
			else
				LuaUIUtils.onRewardItemClick(itemUButton, reward)
			end
		end

		button.luaClick = rewardClick
		itemUButton.luaClick = rewardClick
	else
		if itemIconUImage then
			itemIconUImage:ClearUrl()
		end

		button.luaClick = nil
		itemUButton.luaClick = nil
	end

	itemUButton:TryChangePage("State", data.displayState == 2 and 1 or 0)
end

function SeasonAchievementCtrl:_renderStageReward(button, data, rewardLevel)
	local objectReference = button:GetComponent("ObjectReference")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")

	ClientTextUtils.setText(txtLevelUSDFText, data.sort)
	self:_renderRewardContent(button, data, rewardLevel)
end

function SeasonAchievementCtrl:_refreshStageRewardPreview()
	local targetReward, targetRewardLevel
	local lastVisibleSort = self._totalMilestone and self._totalMilestone.level or 0
	local ok, _, maxIndex = self.view.listRewardUList:TryGetVisualRange()

	if ok and self._stageRewards[maxIndex + 1] then
		lastVisibleSort = self._stageRewards[maxIndex + 1].sort
	end

	for rewardLevel, rewardData in ipairs(self._stageRewards or {}) do
		if rewardData.isStageReward and lastVisibleSort < rewardData.sort then
			targetReward = rewardData
			targetRewardLevel = rewardLevel

			break
		end
	end

	if targetReward then
		local objectReference = self.view.stageRewardItemUButton:GetComponent("ObjectReference")
		local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")

		ClientTextUtils.setText(txtLevelUSDFText, targetReward.sort)
		self:_renderRewardContent(self.view.stageRewardItemUButton, targetReward, targetRewardLevel)
	end
end

function SeasonAchievementCtrl:_renderManualItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local txtManualTitleUSDFText = objectReference:GetRefValue("txtManualTitleUSDFText")
	local manualIconUImage = objectReference:GetRefValue("manualIconUImage")
	local txtProgressUSDFText = objectReference:GetRefValue("txtProgressUSDFText")
	local iconBgUImage = objectReference:GetRefValue("iconBgUImage")
	local manualTipsPicUImage = objectReference:GetRefValue("manualTipsPicUImage")

	ClientTextUtils.setText(txtManualTitleUSDFText, pg.getGameString(data.manualTitleName))
	ClientTextUtils.setText(txtProgressUSDFText, string.format("%s%%", data.progressPercent))
	button:TryChangePage("State", data.totalCount > 0 and data.completedCount >= data.totalCount and 1 or 0)

	if data.manualTitlePic ~= "" then
		bgUImage.url = data.manualTitlePic
	end

	if data.manualIcon ~= "" then
		manualIconUImage.url = data.manualIcon
	end

	if data.manualIconBgPic ~= "" then
		iconBgUImage.url = data.manualIconBgPic
	end

	if data.manualTipsPic ~= "" then
		manualTipsPicUImage.url = data.manualTipsPic
	end

	button:ClearRedDot()

	local manualRedDotPath = string.format(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_MANUAL_ITEM, data.manualIndex)

	pg.global.setPreViewRedDot(manualRedDotPath, button, function()
		if #self.model:getCanReceiveTaskGroupIds(data) > 0 then
			return RedDotConst.RedDotStyle.REWARD
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function SeasonAchievementCtrl:_showOverview()
	self._currentManualIndex = nil

	self.view.rootUComponent:TryChangePage("Size", 0)
end

function SeasonAchievementCtrl:_showManual(manualIndex)
	if not self._gameplayRows or not self._gameplayRows[manualIndex] then
		return
	end

	self._currentManualIndex = manualIndex

	self.view.rootUComponent:TryChangePage("Size", 1)
	self:_loadSubManual()
end

function SeasonAchievementCtrl:_loadSubManual()
	local subManualUContainer = self.view.subManualUComponent
	local contentLoaded = subManualUContainer:CheckURLLoaded()
	local manualObjectsValid = contentLoaded and not IsNil(subManualUContainer.content) and not IsNil(self.view.manualBgUImage)

	if self._subManualReady and manualObjectsValid then
		self:_refreshManual()

		return
	end

	if self._subManualReady then
		self._subManualReady = false
		self._subManualListenerAdded = false
	end

	if self._subManualLoading then
		return
	end

	if contentLoaded then
		self:_onSubManualLoaded(subManualUContainer.content)

		return
	end

	self._subManualLoading = true

	subManualUContainer:LoadDefaultUrlManually(function(content)
		self:_onSubManualLoaded(content)
	end)
end

function SeasonAchievementCtrl:_onSubManualLoaded(content)
	self._subManualLoading = false

	if self._subManualDestroyed or not self.view or IsNil(content) then
		return
	end

	if not self.view:findSubManualObjects(content) then
		return
	end

	self._subManualReady = true

	ClientTextUtils.setText(self.view.btnGetAllNameUText, pg.getGameString("SEASON_CLAIMALL"))
	self:_addSubManualListener()

	if self._currentManualIndex then
		self:_refreshManual()
	end
end

function SeasonAchievementCtrl:_refreshManual()
	local subManualUContainer = self.view and self.view.subManualUComponent
	local contentLoaded = subManualUContainer and subManualUContainer:CheckURLLoaded()
	local manualObjectsValid = contentLoaded and not IsNil(subManualUContainer.content) and not IsNil(self.view.manualBgUImage)

	if not self._subManualReady or not manualObjectsValid then
		self._subManualReady = false
		self._subManualListenerAdded = false

		if self._currentManualIndex then
			self:_loadSubManual()
		end

		return
	end

	local manualData = self._gameplayRows and self._gameplayRows[self._currentManualIndex]

	if not manualData then
		self:_showOverview()

		return
	end

	ClientTextUtils.setText(self.view.manualTitleUSDFText, pg.getGameString(manualData.manualTitleName))
	ClientTextUtils.setText(self.view.manualProgressUSDFText, string.format("%s%%", manualData.progressPercent))
	self.view.manualCardInfo:TryChangePage("State", manualData.totalCount > 0 and manualData.completedCount >= manualData.totalCount and 1 or 0)

	if manualData.manualTitleOpenPic ~= "" then
		self.view.manualBgUImage.url = manualData.manualTitleOpenPic
	end

	if manualData.manualIcon ~= "" then
		self.view.manualIconUImage.url = manualData.manualIcon
	end

	if manualData.manualIconBgPic ~= "" then
		self.view.manualIconBgUImage.url = manualData.manualIconBgPic
	end

	if manualData.manualTipsOpenPic ~= "" then
		self.view.textBgUImage.url = manualData.manualTipsOpenPic
	end

	self._currentManualTasks = self.model:getManualTaskGroups(manualData)

	self.view.taskUList:SetList(self._currentManualTasks)
	self.view.leftArrowUButton:SetActive(self._currentManualIndex > 1)
	self.view.rightArrowUButton:SetActive(self._currentManualIndex < #self._gameplayRows)
	self:_refreshManualArrowRedDots()

	local canReceiveGroupIds = self.model:getCanReceiveTaskGroupIds(manualData)
	local canReceive = #canReceiveGroupIds > 0

	self.view.btnGetAllUButton:ClearRedDot()

	local getAllRedDotPath = string.format(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_MANUAL_GET_ALL, manualData.manualIndex)

	pg.global.setRedDot(getAllRedDotPath, self.view.btnGetAllUButton, canReceive, RedDotConst.RedDotStyle.REWARD)
	self.view.btnGetAllUButton:SetActive(canReceive)
end

function SeasonAchievementCtrl:_refreshManualArrowRedDots()
	local manualCount = #(self._gameplayRows or {})
	local currentIndex = self._currentManualIndex or 1
	local hasLeftReward = self.model:hasCanReceiveManualRewardInRange(self._gameplayRows, 1, currentIndex - 1)
	local hasRightReward = self.model:hasCanReceiveManualRewardInRange(self._gameplayRows, currentIndex + 1, manualCount)

	self.view.leftArrowUButton:ClearRedDot()
	pg.global.setRedDot(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_MANUAL_LEFT_ARROW, self.view.leftArrowUButton, hasLeftReward, RedDotConst.RedDotStyle.REWARD)
	self.view.rightArrowUButton:ClearRedDot()
	pg.global.setRedDot(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_MANUAL_RIGHT_ARROW, self.view.rightArrowUButton, hasRightReward, RedDotConst.RedDotStyle.REWARD)
end

function SeasonAchievementCtrl:_renderManualTask(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local taskDesUSDFText = objectReference:GetRefValue("taskDesUSDFText")
	local stageUSDFText = objectReference:GetRefValue("stageUSDFText")
	local btnUSDFText = objectReference:GetRefValue("btnUSDFText")
	local awardUList = objectReference:GetRefValue("awardUList")
	local bgMarkUImage = objectReference:GetRefValue("bgMarkUImage")
	local taskDescription = data.taskDescriptionTextId and pg.getLocalizationText(data.taskDescriptionTextId) or ""

	taskDescription = pg.getFormatText(taskDescription, data.progress, data.target)

	ClientTextUtils.setText(taskDesUSDFText, taskDescription)
	ClientTextUtils.setText(stageUSDFText, string.format(pg.getGameString("SEASON_TASK_ROUND"), data.stage, data.totalStage))
	button:TryChangePage("State", data.displayState)

	if data.manualBgMarkPic and data.manualBgMarkPic ~= "" then
		bgMarkUImage.url = data.manualBgMarkPic
	else
		bgMarkUImage:ClearUrl()
	end

	local buttonText = pg.getGameString("BUTTON_NAME_1")

	if data.displayState == 1 then
		buttonText = pg.getGameString("BUTTON_NAME_2")
	elseif data.displayState == 2 then
		buttonText = pg.getGameString("ECOLOGICAL_RESARCH_FINISH")
	end

	ClientTextUtils.setText(btnUSDFText, buttonText)

	function awardUList.luaRenderItem(rewardButton, index, rewardData)
		LuaUIUtils.renderRewardItem(rewardButton, rewardData)
	end

	local hasReceived = data.taskState >= ActivityConst.TaskState.Received
	local canReceive = data.taskState == ActivityConst.TaskState.Finihed_CanRecv

	awardUList:SetList(LuaUIUtils.getRewardItemByDropId(data.award, hasReceived, canReceive))
	button:ClearRedDot()

	local taskGroupRedDotPath = string.format(RedDotConst.RedDotPath.SEASON_ACHIEVEMENT_MANUAL_TASK_GROUP, data.manualIndex, data.taskGroupId)

	pg.global.setRedDot(taskGroupRedDotPath, button, canReceive, RedDotConst.RedDotStyle.REWARD)

	function button.luaClick()
		if data.displayState == 1 then
			self:_receiveTaskReward(data.taskId)
		elseif data.displayState == 0 then
			self:_goToTask(data)
		end
	end
end

function SeasonAchievementCtrl:_receiveTaskReward(taskId)
	if not taskId or not self.eventId then
		return
	end

	pg.me:reqActReceiveTaskReward(taskId, self.eventId)
end

function SeasonAchievementCtrl:_receiveAllStageRewards(taskGroupId)
	if not taskGroupId or not self.eventId then
		return
	end

	pg.me:reqActReceiveGroupTaskReward(taskGroupId, self.eventId)
end

function SeasonAchievementCtrl:_receiveAllCurrentManualRewards()
	local manualData = self._gameplayRows and self._gameplayRows[self._currentManualIndex]

	for _, taskGroupId in ipairs(self.model:getCanReceiveTaskGroupIds(manualData)) do
		pg.me:reqActReceiveGroupTaskReward(taskGroupId, self.eventId)
	end
end

function SeasonAchievementCtrl:_goToTask(taskData)
	if taskData.sourceData then
		LuaUIUtils.clueSeek(taskData.sourceData)
		self:dismiss()
	elseif taskData.taskEvent then
		pg.me:doEvent(taskData.taskEvent)
		self:dismiss()
	end
end

function SeasonAchievementCtrl:_goToBadgeSource()
	local sourceData = self.model:getBadgeSourceData()

	if not sourceData then
		return
	end

	LuaUIUtils.clueSeek(sourceData)
end

function SeasonAchievementCtrl:_showAchievementPointItemTip()
	if not self._achievementPointItemTipData then
		return
	end

	LuaUIUtils.onRewardItemClick(self.view.btnIconUButton, self._achievementPointItemTipData)
end

function SeasonAchievementCtrl:_waitForLevelUpAnimation()
	self._pendingLevelUpAnimation = true

	if self._levelUpObtainCloseListening or self._levelUpObtainWatchTimer then
		return
	end

	local waitTicks = 0

	self._levelUpObtainWatchTimer = self:startTimer(function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_OBTAIN) then
			self:_stopLevelUpObtainWatchTimer()
			self:_addLevelUpObtainCloseListener()

			return
		end

		waitTicks = waitTicks + 1

		if waitTicks >= LEVEL_UP_OBTAIN_WAIT_TICKS then
			self:_playPendingLevelUpAnimation()
		end
	end, LEVEL_UP_OBTAIN_WAIT_INTERVAL, true)
end

function SeasonAchievementCtrl:_addLevelUpObtainCloseListener()
	if self._levelUpObtainCloseListening then
		return
	end

	self._onLevelUpObtainClose = self._onLevelUpObtainClose or function()
		self:_onLevelUpObtainClosed()
	end
	self._levelUpObtainCloseListening = true

	pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onLevelUpObtainClose)
end

function SeasonAchievementCtrl:_onLevelUpObtainClosed()
	self:startFrameTimer(function()
		if not self._pendingLevelUpAnimation or not self.view then
			return
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_OBTAIN) then
			return
		end

		self:_playPendingLevelUpAnimation()
	end, LEVEL_UP_OBTAIN_CLOSE_DELAY_FRAMES)
end

function SeasonAchievementCtrl:_playPendingLevelUpAnimation()
	if not self._pendingLevelUpAnimation then
		return
	end

	self:_clearLevelUpAnimationWait()

	if self.view and self.view.rootUComponent then
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function SeasonAchievementCtrl:_stopLevelUpObtainWatchTimer()
	if not self._levelUpObtainWatchTimer then
		return
	end

	self:killTimer(self._levelUpObtainWatchTimer)

	self._levelUpObtainWatchTimer = nil
end

function SeasonAchievementCtrl:_clearLevelUpAnimationWait()
	self:_stopLevelUpObtainWatchTimer()

	if self._levelUpObtainCloseListening and self._onLevelUpObtainClose then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onLevelUpObtainClose)
	end

	self._levelUpObtainCloseListening = false
	self._onLevelUpObtainClose = nil
	self._pendingLevelUpAnimation = false
end

function SeasonAchievementCtrl:_changeManual(offset)
	local targetIndex = (self._currentManualIndex or 1) + offset

	if targetIndex < 1 or targetIndex > #(self._gameplayRows or {}) then
		return
	end

	self._currentManualIndex = targetIndex

	self:_refreshManual()
end

function SeasonAchievementCtrl:onDestroy()
	self:_clearLevelUpAnimationWait()

	self._subManualDestroyed = true
	self._subManualReady = false
	self._subManualLoading = false
	self._subManualListenerAdded = false

	if self.view and self.view.listRewardUList and self._onRewardListScroll then
		self.view.listRewardUList:UnRegisterToScrollEvent(self._onRewardListScroll)
	end

	self._onRewardListScroll = nil

	UICtrl.onDestroy(self)
end

return SeasonAchievementCtrl
