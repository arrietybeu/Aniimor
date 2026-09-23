-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonPrepare\\HomelandSeasonPrepareCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local EventConst = require("Common.Const.EventConst")
local RedDotConst = require("Const.RedDotConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local HomelandSeasonPrepareCtrl = Class.LightClass("HomelandSeasonPrepareCtrl", UICtrl)

HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER = "State"
HomelandSeasonPrepareCtrl.OPEN_TIME_REFRESH_DELAY = 0.1
HomelandSeasonPrepareCtrl.FINISH_VX_RECORD_KEY_FORMAT = "finish_vx.season_%d.goal_%d"
HomelandSeasonPrepareCtrl.ITEM_STATE = {
	LOCKED = 2,
	FINISHED = 1,
	NORMAL = 0
}
HomelandSeasonPrepareCtrl.messages = {
	[MessageName.HOME_SEASON_CHANGE] = {
		"onSeasonContextChanged",
		true
	},
	[MessageName.HOME_SEASON_STAGE_CHANGE] = {
		"onSeasonContextChanged",
		true
	},
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestChanged",
		true
	},
	[MessageName.QUEST_ON_OBJECTIVE_CHANGED] = {
		"onQuestChanged",
		true
	}
}

function HomelandSeasonPrepareCtrl:onCreate(info)
	self.moduleId = info and info.moduleId or nil
	self.openTimeTimerId = nil
	self.selectedNewGoalRedDotPaths = {}

	UICtrl.onCreate(self, info)

	self.languageChangedCallback = CallbackHandler(self, "onLanguageChanged")

	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.languageChangedCallback)
end

function HomelandSeasonPrepareCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	self:bindCloseButton(self.view.btnCloseUButton)

	function self.view.listGoalUList.luaRenderItem(button, index, data)
		self:renderGoalItem(button, index, data)
	end

	function self.view.btnGoUButton.luaClick()
		self:onGoButtonClick()
	end
end

function HomelandSeasonPrepareCtrl:onDestroy()
	if pg.me then
		for redDotPath in pairs(self.selectedNewGoalRedDotPaths or EMPTY_TABLE) do
			pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, redDotPath, false)
		end
	end

	self.selectedNewGoalRedDotPaths = nil

	self:clearOpenTimeTimer()
	pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.languageChangedCallback)

	self.languageChangedCallback = nil
	self.view.btnCloseUButton.luaClick = nil
	self.view.listGoalUList.luaRenderItem = nil
	self.view.btnGoUButton.luaClick = nil

	UICtrl.onDestroy(self)
end

function HomelandSeasonPrepareCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.moduleId = info and info.moduleId or nil
	self.requestedGoalImageAddress = nil
	self.requestedGoalOrderImageAddress = nil

	self:refreshUI(true)
end

function HomelandSeasonPrepareCtrl:onShow()
	self:refreshUI()
end

function HomelandSeasonPrepareCtrl:onPostOpen(info, isReOpen)
	UICtrl.onPostOpen(self, info, isReOpen)

	if self.pendingFinishVxGoalId then
		self:refreshGoalDetail(true)
	end
end

function HomelandSeasonPrepareCtrl:onSeasonContextChanged()
	self:refreshUI()
end

function HomelandSeasonPrepareCtrl:onQuestChanged(eventData)
	if self.model:isQuestEventRelevant(eventData) then
		self:refreshUI()
	end
end

function HomelandSeasonPrepareCtrl:onLanguageChanged()
	if self._isOpen and self.view then
		self:refreshUI()
	end
end

function HomelandSeasonPrepareCtrl:clearOpenTimeTimer()
	if self.openTimeTimerId then
		self:killTimer(self.openTimeTimerId)

		self.openTimeTimerId = nil
	end
end

function HomelandSeasonPrepareCtrl:scheduleOpenTimeRefresh(nextRefreshTime)
	self:clearOpenTimeTimer()

	if not nextRefreshTime then
		return
	end

	local serverTime = Time.secondCache or Time.getSecond()
	local delay = math.max(nextRefreshTime - serverTime, 0) + HomelandSeasonPrepareCtrl.OPEN_TIME_REFRESH_DELAY

	self.openTimeTimerId = self:startTimer(CallbackHandler(self, "onOpenTimeReached"), delay)
end

function HomelandSeasonPrepareCtrl:onOpenTimeReached()
	self.openTimeTimerId = nil

	if self._isOpen and self.view then
		self:refreshUI()
	end
end

function HomelandSeasonPrepareCtrl:getGoalPageState(goalState)
	if goalState == self.model.GOAL_STATE.FINISHED then
		return HomelandSeasonPrepareCtrl.ITEM_STATE.FINISHED
	end

	if goalState == self.model.GOAL_STATE.IN_PROGRESS then
		return HomelandSeasonPrepareCtrl.ITEM_STATE.NORMAL
	end

	return HomelandSeasonPrepareCtrl.ITEM_STATE.LOCKED
end

function HomelandSeasonPrepareCtrl:getLockedText(goalData)
	local serverTime = Time.secondCache or Time.getSecond()

	if goalData.openTime and serverTime < goalData.openTime then
		local openTimeText = LuaUIUtils.timeStampToUtcString(goalData.openTime, nil, false)

		return pg.getFormatText(pg.getGameString("HOME_SEASON_PREPARE_TIME_NOTICE"), openTimeText)
	end

	if goalData.state ~= self.model.GOAL_STATE.IN_PROGRESS and goalData.state ~= self.model.GOAL_STATE.FINISHED then
		return pg.getGameString("LOCKED")
	end

	return ""
end

function HomelandSeasonPrepareCtrl:refreshUI(checkFinishVx)
	self:clearOpenTimeTimer()

	local pageData = self.model:refreshPrepareData(self.moduleId)

	if not pageData then
		self:dismiss()

		return false
	end

	self.moduleId = pageData.moduleId

	if checkFinishVx then
		self.pendingFinishVxGoalId = nil

		local finishVxGoalId = self:getPendingFinishVxGoalId(pageData.goalList, pageData.seasonId)

		if finishVxGoalId then
			self.model.selectedGoalId = finishVxGoalId
			self.pendingFinishVxGoalId = finishVxGoalId
		else
			self.model.selectedGoalId = self.model.selectDefaultGoal(pageData.goalList)
		end
	end

	local selectedGoalData = self.model:getSelectedGoalData()

	if selectedGoalData and selectedGoalData.state == self.model.GOAL_STATE.IN_PROGRESS and pg.me then
		local selectedGoalRedDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_PREPARE_GOAL_ITEM, self.model.seasonId, selectedGoalData.goalId)

		if pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, selectedGoalRedDotPath, true) then
			self.selectedNewGoalRedDotPaths[selectedGoalRedDotPath] = true
		end
	end

	local moduleName = self.model:getModuleName()

	ClientTextUtils.setText(self.view.txtSeasonNameUSDFText, moduleName)
	ClientTextUtils.setText(self.view.txtProgressUSDFText, string.format("%d/%d", pageData.finishedCount, pageData.totalCount))
	ClientTextUtils.setText(self.view.txtProgressTitleUSDFText, pg.getGameString("HOMELAND_SEASON_PREPARE_PROGRESS"))

	if self.view.txtComfortTitleUSDFText then
		ClientTextUtils.setText(self.view.txtComfortTitleUSDFText, pg.getGameString("HOMELAND_SEASON_PREPARE_COMFORT_VALUE"))
	end

	if self.view.txtComfortUSDFText then
		local homeAreaStats = pg.space and pg.space.homeAreaStats
		local seasonAreaStats = homeAreaStats and homeAreaStats[Const.HOMELAND_AREA_TYPE.SEASON]

		ClientTextUtils.setText(self.view.txtComfortUSDFText, seasonAreaStats and seasonAreaStats.comfortValue or 0)
	end

	self.view.listGoalUList:SetList(pageData.goalList)
	self:refreshGoalDetail()
	self:scheduleOpenTimeRefresh(pageData.nextRefreshTime)

	return true
end

function HomelandSeasonPrepareCtrl:getPendingFinishVxGoalId(goalList, seasonId)
	if not pg.me then
		return nil
	end

	local pendingGoalId

	for _, goalData in ipairs(goalList) do
		if goalData.isFinished then
			local recordKey = string.format(HomelandSeasonPrepareCtrl.FINISH_VX_RECORD_KEY_FORMAT, seasonId, goalData.goalId)

			if pg.me:getRedDotRecord(Const.CLIENT_KEY.HOME_SEASON_PREPARE_ANIM_RECORD, recordKey, true) then
				pendingGoalId = goalData.goalId
			end
		end
	end

	return pendingGoalId
end

function HomelandSeasonPrepareCtrl:markGoalViewed(goalData, button, redDotPath)
	if not pg.me or not goalData or goalData.state ~= self.model.GOAL_STATE.IN_PROGRESS then
		return
	end

	local goalRedDotPath = redDotPath or string.format(RedDotConst.RedDotPath.HOME_SEASON_PREPARE_GOAL_ITEM, self.model.seasonId, goalData.goalId)

	if button then
		pg.global.setRedDot(goalRedDotPath, button, false, RedDotConst.RedDotStyle.NEW)
	end

	if not pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, goalRedDotPath, true) then
		return
	end

	pg.me:setRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, goalRedDotPath, false)

	self.selectedNewGoalRedDotPaths[goalRedDotPath] = nil
end

function HomelandSeasonPrepareCtrl:renderGoalItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtOrderUSDFText = objectReference:GetRefValue("txtOrderUSDFText")

	ClientTextUtils.setText(txtOrderUSDFText, tostring(data.displayOrder or index))

	local itemState = self:getGoalPageState(data.state)

	button:TryChangePage(HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER, itemState, true, true, false)
	button:SetSelected(data.goalId == self.model.selectedGoalId)

	local redDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_PREPARE_GOAL_ITEM, self.model.seasonId, data.goalId)
	local showNew = data.state == self.model.GOAL_STATE.IN_PROGRESS and pg.me and pg.me:getRedDotRecord(Const.CLIENT_KEY.EVENT_RED_DOT, redDotPath, true)

	pg.global.setRedDot(redDotPath, button, showNew == true, RedDotConst.RedDotStyle.NEW)

	function button.luaClick()
		self:onGoalItemClick(data, button, redDotPath)
	end
end

function HomelandSeasonPrepareCtrl:onGoalItemClick(data, button, redDotPath)
	if data.state ~= self.model.GOAL_STATE.IN_PROGRESS and data.state ~= self.model.GOAL_STATE.FINISHED then
		local noticeId = NoticeDef.HOME_SEASON_EVENT_NOT_OPEN

		for _, goalData in ipairs(self.model.goalList) do
			if goalData.goalId == data.goalId then
				break
			end

			if not goalData.isFinished then
				noticeId = NoticeDef.HOME_SEASON_PREPARE_PREVIOUS_GOAL_NOT_FINISHED

				break
			end
		end

		pg.global.showBubbleMessage(noticeId)
	end

	self:markGoalViewed(data, button, redDotPath)

	if self.model.selectedGoalId == data.goalId then
		return
	end

	self.model.selectedGoalId = data.goalId

	self.view.listGoalUList:RefreshList()
	self:refreshGoalDetail()
end

function HomelandSeasonPrepareCtrl:refreshGoalDetail(playFinishVx)
	if self.view.txtGoUText then
		ClientTextUtils.setText(self.view.txtGoUText, pg.getGameString("BUTTON_NAME_1"))
	end

	local goalData = self.model:getSelectedGoalData()

	if not goalData then
		self.view.rootUComponent:TryChangePage(HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER, HomelandSeasonPrepareCtrl.ITEM_STATE.LOCKED, true, true, false)

		if self.requestedGoalImageAddress ~= "" then
			self.requestedGoalImageAddress = ""
			self.view.imgGoalImageUImage.url = ""
		end

		if self.view.imgGoalOrderUImage and self.requestedGoalOrderImageAddress ~= "" then
			self.requestedGoalOrderImageAddress = ""
			self.view.imgGoalOrderUImage.url = ""
		end

		ClientTextUtils.setText(self.view.txtGoalTitleUSDFText, "")
		ClientTextUtils.setText(self.view.txtGoalDescUSDFText, "")

		if self.view.txtLockedUSDFText then
			ClientTextUtils.setText(self.view.txtLockedUSDFText, "")
		end

		self.view.btnGoUButton:SetActive(false)

		self.view.btnGoUButton.interactable = false

		return
	end

	local goalPageState = self:getGoalPageState(goalData.state)

	if goalPageState == HomelandSeasonPrepareCtrl.ITEM_STATE.FINISHED then
		local goalImageAddress = goalData.imageAddress or ""

		if self.requestedGoalImageAddress ~= goalImageAddress then
			self.requestedGoalImageAddress = goalImageAddress
			self.view.imgGoalImageUImage.url = goalImageAddress
		end
	end

	local goalOrderImageAddress = goalData.orderImageAddress or ""

	if self.view.imgGoalOrderUImage and self.requestedGoalOrderImageAddress ~= goalOrderImageAddress then
		self.requestedGoalOrderImageAddress = goalOrderImageAddress
		self.view.imgGoalOrderUImage.url = goalOrderImageAddress
	end

	ClientTextUtils.setText(self.view.txtGoalTitleUSDFText, pg.getLocalizationText(goalData.title))
	ClientTextUtils.setText(self.view.txtGoalDescUSDFText, pg.getLocalizationText(goalData.description))

	if self.view.txtLockedUSDFText then
		ClientTextUtils.setText(self.view.txtLockedUSDFText, self:getLockedText(goalData))
	end

	self.view.btnGoUButton:SetActive(goalData.canGo)

	self.view.btnGoUButton.interactable = goalData.canGo

	if playFinishVx and self.pendingFinishVxGoalId == goalData.goalId then
		for _, finishedGoalData in ipairs(self.model.goalList) do
			if finishedGoalData.isFinished then
				local recordKey = string.format(HomelandSeasonPrepareCtrl.FINISH_VX_RECORD_KEY_FORMAT, self.model.seasonId, finishedGoalData.goalId)

				pg.me:setRedDotRecord(Const.CLIENT_KEY.HOME_SEASON_PREPARE_ANIM_RECORD, recordKey, false)
			end
		end

		self.pendingFinishVxGoalId = nil

		self.view.rootUComponent:TryChangePage(HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER, HomelandSeasonPrepareCtrl.ITEM_STATE.LOCKED, true, true, false)
		self.view.rootUComponent:TryChangePage(HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER, HomelandSeasonPrepareCtrl.ITEM_STATE.FINISHED)
	else
		local isFinishedPage = goalPageState == HomelandSeasonPrepareCtrl.ITEM_STATE.FINISHED

		if isFinishedPage then
			self.view.imgGoalLockedUImage:SetActive(false)
		end

		self.view.rootUComponent:TryChangePage(HomelandSeasonPrepareCtrl.ITEM_STATE_CONTROLLER, goalPageState, true, true, not isFinishedPage)
	end
end

function HomelandSeasonPrepareCtrl:onGoButtonClick()
	if not self:refreshUI() then
		return
	end

	local goalData = self.model:getSelectedGoalData()

	if not goalData or not goalData.canGo or not goalData.traceQuestId then
		return
	end

	local traceQuestId = goalData.traceQuestId

	pg.global.ui:closeAllNormalPanel()
	QuestUtils.questManualForce(traceQuestId, 1)
end

return HomelandSeasonPrepareCtrl
