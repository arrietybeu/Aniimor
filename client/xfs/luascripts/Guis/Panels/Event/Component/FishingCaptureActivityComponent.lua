-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\FishingCaptureActivityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("FishingCaptureActivityComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local GameEventData = require("Data.game_event_data")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FishingCaptureActivityComponent = Class.LightClass("FishingCaptureActivityComponent", EventContainerComponent)

FishingCaptureActivityComponent.RewardViewState = {
	Claimed = 2,
	ReadyToClaim = 1,
	Unfinished = 0
}
FishingCaptureActivityComponent.RewardSlotCount = 4
FishingCaptureActivityComponent.ExchangeState = {
	Exchanged = 3,
	NotEnough = 2,
	Normal = 1
}
FishingCaptureActivityComponent.EntranceState = {
	Completed = 3,
	Available = 2,
	Locked = 1
}
FishingCaptureActivityComponent.IrisUnlockHintDelay = 1

function FishingCaptureActivityComponent:getActivityConfig()
	return self.model:getFishingCaptureActivityConfig(self.eventPhase)
end

function FishingCaptureActivityComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.rootUComponent = self.transform:GetChild(0):GetComponent("UComponent")
	self.stageTabUList = objectReference:GetRefValue("stageTabUList")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.reward1UButton = objectReference:GetRefValue("reward1UButton")
	self.reward2UButton = objectReference:GetRefValue("reward2UButton")
	self.reward3UButton = objectReference:GetRefValue("reward3UButton")
	self.reward4UButton = objectReference:GetRefValue("reward4UButton")
	self.progressRewardButtons = {
		self.reward1UButton,
		self.reward2UButton,
		self.reward3UButton,
		self.reward4UButton
	}
	self.btnShopUButton = objectReference:GetRefValue("btnShopUButton")

	local btnShopObjectReference = self.btnShopUButton:GetComponent("ObjectReference")

	self.btnShopTextPlus = btnShopObjectReference:GetRefValue("textTextPlus")
	self.btnPetalSourceUButton = objectReference:GetRefValue("btnPetalSourceUButton")

	local btnPetalSourceObjectReference = self.btnPetalSourceUButton:GetComponent("ObjectReference")

	self.btnPetalSourceTextPlus = btnPetalSourceObjectReference:GetRefValue("textTextPlus")
	self.progressTitle = objectReference:GetRefValue("progressTitle")
	self.progressNum = objectReference:GetRefValue("progressNum")
	self.step2TipTxt = objectReference:GetRefValue("step2TipTxt")
	self.btnCreateReadyUButton = objectReference:GetRefValue("btnCreateReadyUButton")
	self.btnCreateNameTxt = objectReference:GetRefValue("btnCreateNameTxt")
	self.btnCreateCostTxt = objectReference:GetRefValue("btnCreateCostTxt")
	self.btnSeekUButton = objectReference:GetRefValue("btnSeekUButton")
	self.btnSeekTxt = objectReference:GetRefValue("btnSeekTxt")
	self.btnCreateUButton = objectReference:GetRefValue("btnCreateUButton")
	self.btnCreateTxt = objectReference:GetRefValue("btnCreateTxt")
	self.btnSeekReadyUButton = objectReference:GetRefValue("btnSeekReadyUButton")
	self.btnSeekReadyTxt = objectReference:GetRefValue("btnSeekReadyTxt")
	self.btnCreateStep3 = objectReference:GetRefValue("btnCreateStep3")
	self.btnCreateStep3Txt = objectReference:GetRefValue("btnCreateStep3Txt")
	self.createNum = objectReference:GetRefValue("createNum")
	self.stateBg1UContainer = objectReference:GetRefValue("stateBg1UContainer")
	self.stateBg2UContainer = objectReference:GetRefValue("stateBg2UContainer")
	self.stateBg3UContainer = objectReference:GetRefValue("stateBg3UContainer")
	self.stageBgUContainers = {
		self.stateBg1UContainer,
		self.stateBg2UContainer,
		self.stateBg3UContainer
	}
end

function FishingCaptureActivityComponent:addListener()
	if self.stageTabUList then
		function self.stageTabUList.luaRenderItem(button, index, data)
			self:renderStageTab(button, index, data)
		end

		function self.stageTabUList.luaCheckCanSelected(data)
			return data ~= nil and data.state == FishingCaptureConst.ActivityTabState.Unlocked
		end
	end

	for index = 1, self.RewardSlotCount do
		local button = self.progressRewardButtons and self.progressRewardButtons[index]

		if button then
			function button.luaClick()
				self:onRewardClick(self.progressTasks and self.progressTasks[index], button)
			end
		end
	end

	if self.btnShopUButton then
		function self.btnShopUButton.luaClick()
			self:openShop()
		end
	end

	if self.btnPetalSourceUButton then
		function self.btnPetalSourceUButton.luaClick()
			self:openPetalSourcePanel()
		end
	end

	if self.btnCreateReadyUButton then
		function self.btnCreateReadyUButton.luaClick()
			self:openTicketExchangePanel()
		end
	end

	if self.btnCreateUButton then
		function self.btnCreateUButton.luaClick()
			pg.global.showBubbleMessageRaw(pg.getGameString("IRISH_CUBE_DOWN_REMIND"))
		end
	end

	if self.btnSeekReadyUButton then
		function self.btnSeekReadyUButton.luaClick()
			self:onFinalEntranceClick()
		end
	end

	if self.btnSeekUButton then
		function self.btnSeekUButton.luaClick()
			self:onDisabledFinalEntranceClick()
		end
	end

	if self.btnCreateStep3 then
		function self.btnCreateStep3.luaClick()
			self:openSeasonCubeBuildPanel()
		end
	end
end

function FishingCaptureActivityComponent:onExitPage()
	self:_cancelIrisUnlockHint()

	if self._defaultRewardFocusFrameId then
		self:killFrameTimer(self._defaultRewardFocusFrameId)

		self._defaultRewardFocusFrameId = nil
	end

	self.ctrl:setCommonTitle(false)
	EventContainerComponent.onExitPage(self)
end

function FishingCaptureActivityComponent:onDestroy()
	self:_cancelIrisUnlockHint()

	if self._defaultRewardFocusFrameId then
		self:killFrameTimer(self._defaultRewardFocusFrameId)

		self._defaultRewardFocusFrameId = nil
	end

	EventContainerComponent.onDestroy(self)
end

function FishingCaptureActivityComponent:onEnterPlayEvent()
	self:scheduleDefaultRewardFocus()
	self:_scheduleIrisUnlockHint()
end

function FishingCaptureActivityComponent:onShow()
	if self.enterStage == EventContainerComponent.EnterStage.Visible then
		self:_scheduleIrisUnlockHint()
	end
end

function FishingCaptureActivityComponent:onHide()
	self:_cancelIrisUnlockHint()
end

function FishingCaptureActivityComponent:scheduleDefaultRewardFocus()
	if self.isDestroyed or not pg.game.input:isUsingGamepad() then
		return
	end

	if self._defaultRewardFocusFrameId then
		self:killFrameTimer(self._defaultRewardFocusFrameId)
	end

	self._defaultRewardFocusFrameId = self:startFrameTimer(function()
		self._defaultRewardFocusFrameId = nil

		self:focusDefaultReward()
	end, 1)
end

function FishingCaptureActivityComponent:focusDefaultReward()
	if not pg.game.input:isUsingGamepad() or not pg.global.navMgr then
		return false
	end

	local index = self:getDefaultRewardFocusIndex()
	local button = index and self.progressRewardButtons and self.progressRewardButtons[index]

	return button and pg.global.navMgr:FocusItem(button) or false
end

function FishingCaptureActivityComponent:getDefaultRewardFocusIndex()
	local unfinishedIndex

	for index, progressTask in ipairs(self.progressTasks or EMPTY_TABLE) do
		local rewardState = self:getRewardViewState(progressTask.taskState)

		if rewardState == self.RewardViewState.ReadyToClaim then
			return index
		end

		if not unfinishedIndex and rewardState == self.RewardViewState.Unfinished then
			unfinishedIndex = index
		end
	end

	if unfinishedIndex then
		return unfinishedIndex
	end

	return self.progressTasks and #self.progressTasks > 0 and 1 or nil
end

function FishingCaptureActivityComponent:focusOnReward()
	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	if not focused or IsNil(focused) then
		return false
	end

	for _, button in ipairs(self.progressRewardButtons or EMPTY_TABLE) do
		if focused == button then
			return true
		end
	end

	return false
end

function FishingCaptureActivityComponent:refreshStage()
	local displayStage, stageTwoStartTime = ClientActivityUtils.getFishingCaptureDisplayStage(self.eventId)
	local previousStage = self.currentStage
	local tabs, selectedStage = ClientActivityUtils.buildFishingCaptureStageTabs(displayStage, previousStage, self.selectedStage, stageTwoStartTime)

	self.currentStage = displayStage
	self.selectedStage = selectedStage
	self.stageTabs = tabs

	if self.stageTabUList then
		self.stageTabUList:SetList(tabs)
		self:_refreshStageTabSelection()
	end

	self:refreshSelectedStage()
end

function FishingCaptureActivityComponent:_refreshStageTabSelection()
	if not self.stageTabUList then
		return
	end

	for index, tabData in ipairs(self.stageTabs or {}) do
		if tabData.stage == self.selectedStage then
			self.stageTabUList:SelectItem(index - 1, false)

			return
		end
	end
end

function FishingCaptureActivityComponent:renderStageTab(button, index, data)
	if not button or not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rootBtn = objectReference and objectReference:GetRefValue("rootBtn")
	local titleUBaseText = objectReference and objectReference:GetRefValue("titleUBaseText")
	local lockTitleTxt = objectReference and objectReference:GetRefValue("lockTitleTxt")
	local countDownTxt = objectReference and objectReference:GetRefValue("countDownTxt")
	local timeBoxUWidget = objectReference and objectReference:GetRefValue("timeBoxUWidget")
	local btnTipUButton = objectReference and objectReference:GetRefValue("btnTipUButton")

	if rootBtn then
		local lockState = data.state == FishingCaptureConst.ActivityTabState.Unlocked and 0 or 1

		rootBtn:TryChangePage("Lock", lockState)
	end

	local contentConfig = self.model:getFishingCaptureStageContentConfig(self.eventPhase, data.stage)
	local titleTextId = contentConfig and contentConfig.title

	if titleUBaseText then
		if data.state ~= FishingCaptureConst.ActivityTabState.Unlocked then
			ClientTextUtils.setText(lockTitleTxt, pg.getGameString("FC_NEXTCHAP"))
		elseif titleTextId then
			ClientTextUtils.setText(titleUBaseText, pg.getLocalizationText(titleTextId))
		end
	end

	local showLockTitle = data.state == FishingCaptureConst.ActivityTabState.CountdownLocked and data.unlockTime ~= nil

	if countDownTxt then
		countDownTxt:SetActive(showLockTitle)

		if showLockTitle then
			ClientTextUtils.setText(countDownTxt, ClientActivityUtils.getFishingCaptureDayHourText(data.unlockTime, "BOSS_RUSH_SEASON_TIP3"))
		end
	end

	if timeBoxUWidget then
		timeBoxUWidget:SetActive(showLockTitle)
	end

	self.stageTabButtons = self.stageTabButtons or {}
	self.stageTabButtons[data.stage] = button

	self:_refreshStageTabRedDot(button, data)

	if data.state ~= FishingCaptureConst.ActivityTabState.Unlocked then
		button.luaClick = nil

		function btnTipUButton.luaClick()
			self:onStageTabTipClick(data)
		end
	else
		function button.luaClick()
			self:onStageTabClick(data)
		end

		btnTipUButton.luaClick = nil
	end
end

function FishingCaptureActivityComponent:onStageTabClick(data)
	if not data then
		return false
	end

	if data.state == FishingCaptureConst.ActivityTabState.Unlocked then
		if self.selectedStage ~= data.stage then
			self.selectedStage = data.stage

			self:refreshSelectedStage()
		end

		return true
	end

	return false
end

function FishingCaptureActivityComponent:onStageTabTipClick(data)
	if not data then
		return false
	end

	if data.state ~= FishingCaptureConst.ActivityTabState.Unlocked then
		self:_refreshStageTabSelection()

		if data.stage == FishingCaptureConst.ActivityStage.WindkissCompanion then
			pg.global.showBubbleMessageRaw(pg.getGameString("FC_IRIS_CUBE_CONDITION"))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("FC_PHASE_CLOSE_TEXT"))
		end

		return true
	end

	return false
end

function FishingCaptureActivityComponent:_loadSelectedStageBackground()
	local container = self.stageBgUContainers and self.stageBgUContainers[self.selectedStage]

	if not container then
		return
	end

	if container:CheckURLLoaded() then
		if self.selectedStage == FishingCaptureConst.ActivityStage.IrisCompanion then
			self.bossCatchModeUWidget = container.content
		end

		return
	end

	local loadingStage = self.selectedStage

	container:LoadDefaultUrlManually(function(content)
		if self.isDestroyed or loadingStage ~= FishingCaptureConst.ActivityStage.IrisCompanion then
			return
		end

		self.bossCatchModeUWidget = content

		if self.selectedStage == loadingStage then
			self:refreshIrisCompanion()
		end
	end)
end

function FishingCaptureActivityComponent:refreshSelectedStage()
	if not self.selectedStage then
		return
	end

	if self.rootUComponent then
		self.rootUComponent:TryChangePage("State", self.selectedStage - 1)
	end

	self:_loadSelectedStageBackground()

	if self.selectedStage == FishingCaptureConst.ActivityStage.IrisCompanion then
		ClientActivityUtils.clearFishingCaptureRedDot(self.eventId, ClientActivityUtils.FishingCaptureRedDotName.IrisStage)
		self:refreshIrisCompanion()
		self:_scheduleIrisUnlockHint()
	elseif self.selectedStage == FishingCaptureConst.ActivityStage.WindkissCompanion then
		ClientActivityUtils.clearFishingCaptureRedDot(self.eventId, ClientActivityUtils.FishingCaptureRedDotName.WindkissStage)
		self:refreshWindkissCompanion()
	end

	local contentConfig = self.model:getFishingCaptureStageContentConfig(self.eventPhase, self.selectedStage)
	local eventData = GameEventData[self.eventId]
	local activityEndTime = eventData and Utils.getConfigTimeOfArea(eventData, "tabEndDayTime")
	local title = contentConfig and contentConfig.title and pg.getLocalizationText(contentConfig.title)
	local rule = contentConfig and contentConfig.rule and pg.getLocalizationText(contentConfig.rule)
	local desc = contentConfig and contentConfig.desc and pg.getLocalizationText(contentConfig.desc)

	self:setEventTitle(nil, activityEndTime, title, nil, rule, desc)

	if self.step2TipTxt then
		local key = "FC_IRIS_CUBE_REMIND"

		if self.selectedStage == FishingCaptureConst.ActivityStage.WindkissCompanion then
			key = "FC_SEASON_CUBE_REMIND"
		end

		ClientTextUtils.setText(self.step2TipTxt, pg.getGameString(key))
	end

	self:refreshRedDotState()
end

function FishingCaptureActivityComponent:refreshWindkissCompanion()
	local data = self.model:getFishingCaptureSeasonCubeData(self.eventPhase)

	self.seasonCubeData = data

	if not data then
		return
	end

	if self.btnCreateStep3 then
		self.btnCreateStep3.interactable = true
	end

	if self.createNum then
		ClientTextUtils.setText(self.createNum, string.format(pg.getGameString("FC_SEACUBE_LEFT"), data.remainingCount))
	end
end

function FishingCaptureActivityComponent:refreshIrisCompanion()
	local activityData = self:getActivityConfig()
	local templateId = activityData and activityData.keyPetType
	local pData = templateId and PetData[templateId]

	self.irisTemplateId = pData and templateId or nil

	if pData and self.bossCatchModeUWidget then
		local bossObjectReference = self.bossCatchModeUWidget:GetComponent("ObjectReference")
		local petNameUBaseText = bossObjectReference:GetRefValue("petNameUBaseText")
		local elementUButton = bossObjectReference:GetRefValue("elementUButton")
		local labelTxt = bossObjectReference:GetRefValue("labelTxt")
		local btnLabelUButton = bossObjectReference:GetRefValue("btnLabelUButton")
		local petName = LuaUIUtils.getPetNameWithIdOrTmpId(templateId)
		local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)
		local element = elementNames and elementNames[1] and elementNames[1].element

		if petName then
			ClientTextUtils.setText(petNameUBaseText, pg.getLocalizationText(petName))
		end

		if element then
			LuaUIUtils.setElementButtonNew(elementUButton, element)
		end

		ClientTextUtils.setText(labelTxt, pg.getGameString("PET_STAGE_TXT_4"))

		function btnLabelUButton.luaClick()
			self:onIrisDetailClick()
		end
	end

	local fishingData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local petalItemId = activityData and activityData.petalItemId
	local petalCount = petalItemId and pg.me and pg.me.getItemCountById and pg.me:getItemCountById(petalItemId) or 0

	self.ticketExchangeCost = tonumber(activityData and activityData.coincube) or 0
	self.petalCount = math.max(tonumber(petalCount) or 0, 0)

	local irisCubeExchanged = ClientActivityUtils.getFishingCaptureCubeExchangeCount(FishingCaptureConst.CubeType.LEGEND) > 0

	self.exchangeState, self.entranceState = self.model:resolveFishingCaptureStageTwoActions(irisCubeExchanged, fishingData and fishingData.irisRewardReceived, self.petalCount, self.ticketExchangeCost)

	if self.rootUComponent then
		local state = self.entranceState - 1

		if self:_shouldPlayIrisUnlockHint() then
			state = 0
		end

		self.rootUComponent:TryChangePage("State2nd", state)
	end

	if self.btnCreateCostTxt then
		local petalIconPrefix = petalItemId and LuaUIUtils.getIconByItemId(petalItemId) and LuaUIUtils.getItemShowText(petalItemId) or ""

		ClientTextUtils.setText(self.btnCreateCostTxt, string.format("%s%s/%s", petalIconPrefix, self.petalCount, self.ticketExchangeCost))
	end
end

function FishingCaptureActivityComponent:_shouldPlayIrisUnlockHint()
	if self.selectedStage ~= FishingCaptureConst.ActivityStage.IrisCompanion then
		return false
	end

	if self.entranceState ~= self.EntranceState.Available then
		return false
	end

	return not pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.EventFishingCaptureIrisHintPlayed, false, ClientConst.CACHE_TYPE_FLAG.USER)
end

function FishingCaptureActivityComponent:_scheduleIrisUnlockHint()
	if self._irisUnlockHintTimerId or not self:_shouldPlayIrisUnlockHint() then
		return
	end

	if not self.rootUComponent then
		return
	end

	self.rootUComponent:TryChangePage("State2nd", 0)

	self._irisUnlockHintTimerId = self:startTimer(function()
		self._irisUnlockHintTimerId = nil

		if self.isDestroyed or not self:_shouldPlayIrisUnlockHint() then
			return
		end

		pg.global.prefsCacheUtils:setBool(ClientConst.PrefKey.EventFishingCaptureIrisHintPlayed, true, ClientConst.CACHE_TYPE_FLAG.USER)
		self.rootUComponent:TryChangePage("State2nd", 1)
	end, self.IrisUnlockHintDelay)
end

function FishingCaptureActivityComponent:_cancelIrisUnlockHint()
	if not self._irisUnlockHintTimerId then
		return
	end

	self:killTimer(self._irisUnlockHintTimerId)

	self._irisUnlockHintTimerId = nil
end

function FishingCaptureActivityComponent:onIrisDetailClick()
	if not self.irisTemplateId then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
		templateId = self.irisTemplateId
	})
end

function FishingCaptureActivityComponent:onDisabledFinalEntranceClick()
	self:refreshIrisCompanion()

	if self.entranceState == self.EntranceState.Completed then
		pg.global.showBubbleMessageRaw(pg.getGameString("FC_IRIS_LIMIT_TEXT"))

		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("FC_IRIS_CUBE_CONDITION"))
end

function FishingCaptureActivityComponent:onFinalEntranceClick()
	self:refreshIrisCompanion()

	local activityData = self:getActivityConfig()

	if not self.irisTemplateId then
		logger:warn("FishingCapture final entrance keyPetType invalid, eventId=%s eventPhase=%s keyPetType=%s", tostring(self.eventId), tostring(self.eventPhase), tostring(activityData and activityData.keyPetType))

		return
	end

	if self.entranceState == self.EntranceState.Locked then
		pg.global.showBubbleMessageRaw(pg.getGameString("FISHING_CAPTURE_TICKET_REQUIRED"))

		return
	end

	if self.entranceState == self.EntranceState.Completed then
		pg.global.showBubbleMessageRaw(pg.getGameString("FC_IRIS_LIMIT_TEXT"))

		return
	end

	local eventId = activityData and activityData.event1

	if not eventId then
		logger:warn("FishingCapture final entrance event invalid, eventId=%s eventPhase=%s", tostring(self.eventId), tostring(self.eventPhase))

		return
	end

	pg.me:doEvent(eventId)
end

function FishingCaptureActivityComponent:getCurrencyItems()
	return self.model:getFishingCaptureCurrencyItems(self.eventPhase)
end

function FishingCaptureActivityComponent:refreshProgressRewards()
	local activityData = self:getActivityConfig()
	local petalItemId = activityData and activityData.petalItemId
	local progressTasks = petalItemId and self.model:buildFishingCaptureProgressTasks(self.eventId) or {}
	local petalCount = ClientActivityUtils.getFishingCapturePetalTotalCnt()
	local current, maximum, renderedProgressTasks = ClientActivityUtils.resolveFishingCaptureProgress(petalCount, progressTasks)

	self.progressTasks = renderedProgressTasks

	if self.progressUProgress then
		self.progressUProgress.maxValue = maximum > 0 and maximum or 1
		self.progressUProgress.value = current
	end

	if self.progressTitle then
		ClientTextUtils.setText(self.progressTitle, pg.getGameString("FC_SEASONCOIN"))
	end

	if self.progressNum then
		ClientTextUtils.setText(self.progressNum, string.format("%s", petalCount))
	end

	if #renderedProgressTasks > self.RewardSlotCount then
		logger:error("FishingCapture progress reward count exceeds slots, eventId=%s count=%s slots=%s", tostring(self.eventId), #renderedProgressTasks, self.RewardSlotCount)
	end

	for index = 1, self.RewardSlotCount do
		local button = self.progressRewardButtons and self.progressRewardButtons[index]
		local progressTask = renderedProgressTasks[index]

		if button then
			button:SetActive(progressTask ~= nil)

			if progressTask then
				self:renderProgressReward(button, index, progressTask)
			end
		end
	end
end

function FishingCaptureActivityComponent:getRewardViewState(taskState)
	if taskState == ActivityConst.TaskState.Finihed_CanRecv then
		return self.RewardViewState.ReadyToClaim
	end

	if taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail then
		return self.RewardViewState.Claimed
	end

	return self.RewardViewState.Unfinished
end

function FishingCaptureActivityComponent:renderProgressReward(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootBtn = objectReference:GetRefValue("rootBtn")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numUBaseText = objectReference:GetRefValue("numUBaseText")
	local rewardNumTxt = objectReference:GetRefValue("textNumUSDFText")

	rootBtn:TryChangePage("State", self:getRewardViewState(data.taskState))

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward)
	local reward = rewards and rewards[1]

	if not reward then
		return
	end

	local itemConfig = ItemData[reward.id]

	iconUImage.url = LuaUIUtils.getIconByItemId(reward.id)

	ClientTextUtils.setText(numUBaseText, data.target)

	if rewardNumTxt then
		ClientTextUtils.setText(rewardNumTxt, reward.num)
	end
end

function FishingCaptureActivityComponent:onRewardClick(data, button)
	if not data then
		return
	end

	if data.taskState == ActivityConst.TaskState.Finihed_CanRecv then
		if self.rewardClaimPending then
			return
		end

		local taskGroupId = self.model:getFishingCaptureProgressTaskGroupId(self.eventId)

		if not taskGroupId then
			return
		end

		self.rewardClaimPending = true

		if not pg.me:reqActReceiveGroupTaskReward(taskGroupId, self.eventId) then
			self.rewardClaimPending = false
		end

		return
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(data.taskAward)
	local reward = rewards and rewards[1]

	if reward and reward.id then
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = reward.id,
			num = reward.num,
			targetRect = button
		})
	end
end

function FishingCaptureActivityComponent:onTaskStageChanged(info)
	local taskGroupId = self.model:getFishingCaptureProgressTaskGroupId(self.eventId)

	if info and info.taskGroupId == taskGroupId then
		self.rewardClaimPending = false
	end

	self:refreshPage()
end

function FishingCaptureActivityComponent:_refreshStageTabRedDot(button, data)
	if not button or not data or not self.redDotState then
		return
	end

	local visible = false
	local style = RedDotConst.RedDotStyle.NEW

	if data.stage == FishingCaptureConst.ActivityStage.FlowerGathering and #self.redDotState.rewardTaskIds > 0 then
		visible = true
		style = RedDotConst.RedDotStyle.REWARD
	elseif data.stage == FishingCaptureConst.ActivityStage.IrisCompanion and (self.redDotState.canExchange or self.redDotState.canSeek) then
		visible = true
		style = RedDotConst.RedDotStyle.POINT
	elseif data.stage == FishingCaptureConst.ActivityStage.IrisCompanion and self.redDotState.irisStageNew or data.stage == FishingCaptureConst.ActivityStage.WindkissCompanion and self.redDotState.windkissStageNew then
		visible = true
	end

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_STAGE, data.stage), button, visible, style)
end

function FishingCaptureActivityComponent:refreshRedDotState()
	self.redDotState = ClientActivityUtils.getFishingCaptureRedDotState(self.eventId)

	local rewardTaskMap = {}

	for _, taskId in ipairs(self.redDotState.rewardTaskIds) do
		rewardTaskMap[taskId] = true
	end

	for index, progressTask in ipairs(self.progressTasks or {}) do
		local button = self.progressRewardButtons and self.progressRewardButtons[index]

		if button then
			local visible = rewardTaskMap[progressTask.taskId] == true

			pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_PROGRESS_REWARD, progressTask.taskId), button, visible, RedDotConst.RedDotStyle.REWARD)
		end
	end

	for _, stageTab in ipairs(self.stageTabs or {}) do
		local button = self.stageTabButtons and self.stageTabButtons[stageTab.stage]

		self:_refreshStageTabRedDot(button, stageTab)
	end

	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_EXCHANGE, self.btnCreateReadyUButton, self.redDotState.canExchange, RedDotConst.RedDotStyle.POINT)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_SEEK, self.btnSeekReadyUButton, self.redDotState.canSeek, RedDotConst.RedDotStyle.POINT)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_SHOP, self.btnShopUButton, self.redDotState.shopUnlockNew, RedDotConst.RedDotStyle.NEW)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_FISHING_CAPTURE_PETAL_SOURCE, self.btnPetalSourceUButton, self.redDotState.weeklyNew, RedDotConst.RedDotStyle.NEW)
end

function FishingCaptureActivityComponent:openShop()
	local activityData = self:getActivityConfig()
	local shopId = activityData and activityData.shopId

	if not shopId then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
		shopTags = {
			shopId
		},
		onFishingCaptureShopOpened = function()
			ClientActivityUtils.clearFishingCaptureRedDot(self.eventId, ClientActivityUtils.FishingCaptureRedDotName.ShopUnlock)
			self:refreshRedDotState()
		end
	})
end

function FishingCaptureActivityComponent:openPetalSourcePanel()
	pg.global.ui:open(UIConst.UI_ID_FISHING_CAPTURE_PETAL_SOURCE, {
		eventId = self.eventId
	})
end

function FishingCaptureActivityComponent:openTicketExchangePanel()
	self:refreshIrisCompanion()

	local activityData = self:getActivityConfig()
	local totalCount = math.max(tonumber(activityData and activityData.coincubenum) or 0, 0)
	local exchangedCount = ClientActivityUtils.getFishingCaptureCubeExchangeCount(FishingCaptureConst.CubeType.LEGEND)

	if totalCount > 0 and totalCount <= exchangedCount then
		pg.global.showBubbleMessageRaw(pg.getGameString("FC_CUBE_LIMIT_TEXT"))

		return
	end

	self:openCubeBuildPanel(FishingCaptureConst.CubeType.LEGEND)
end

function FishingCaptureActivityComponent:openCubeBuildPanel(cubeType)
	if not UIConst.UI_ID_FISHING_CAPTURE_TICKET_EXCHANGE then
		logger:warn("FishingCapture cube build panel is not registered, eventId=%s cubeType=%s", tostring(self.eventId), tostring(cubeType))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_FISHING_CAPTURE_TICKET_EXCHANGE, {
		eventId = self.eventId,
		cubeType = cubeType
	})
end

function FishingCaptureActivityComponent:openSeasonCubeBuildPanel()
	self:refreshWindkissCompanion()

	if not self.seasonCubeData then
		return
	end

	self:openCubeBuildPanel(FishingCaptureConst.CubeType.SEASON)
end

function FishingCaptureActivityComponent:onMoneyChanged()
	if self:checkContentLoaded() then
		self:refreshProgressRewards()

		if self.selectedStage == FishingCaptureConst.ActivityStage.IrisCompanion then
			self:refreshIrisCompanion()
		elseif self.selectedStage == FishingCaptureConst.ActivityStage.WindkissCompanion then
			self:refreshWindkissCompanion()
		end

		self:refreshRedDotState()
	end
end

function FishingCaptureActivityComponent:refreshPage()
	if not self:checkContentLoaded() then
		return
	end

	self:refreshStage()
	self:refreshProgressRewards()

	local activityData = self:getActivityConfig()

	if self.btnShopUButton then
		self.btnShopUButton.interactable = activityData and activityData.shopId ~= nil
	end

	if self.btnShopTextPlus then
		ClientTextUtils.setText(self.btnShopTextPlus, pg.getGameString("FC_PAGE_SHOP"))
	end

	if self.btnPetalSourceTextPlus then
		ClientTextUtils.setText(self.btnPetalSourceTextPlus, pg.getLocalizationText(activityData.getcoin))
	end

	if self.btnCreateNameTxt then
		ClientTextUtils.setText(self.btnCreateNameTxt, pg.getGameString("FC_IRIS_CUBE_BUILD"))
	end

	if self.btnCreateTxt then
		ClientTextUtils.setText(self.btnCreateTxt, pg.getGameString("FC_IRIS_CUBE_BUILD"))
	end

	if self.btnSeekReadyTxt then
		ClientTextUtils.setText(self.btnSeekReadyTxt, pg.getGameString("FC_IRIS_SEEK"))
	end

	if self.btnSeekTxt then
		ClientTextUtils.setText(self.btnSeekTxt, pg.getGameString("FC_IRIS_SEEK"))
	end

	if self.btnCreateStep3Txt then
		ClientTextUtils.setText(self.btnCreateStep3Txt, pg.getGameString("FC_IRIS_CUBE_BUILD"))
	end

	self:refreshRedDotState()
end

function FishingCaptureActivityComponent:onActivityDayUpdated()
	if self:checkContentLoaded() then
		self:refreshStage()
		self:refreshRedDotState()
	end
end

return FishingCaptureActivityComponent
