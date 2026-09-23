-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonDailyTask\\HomelandSeasonDailyTaskCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local ActivityConst = require("Common.Const.ActivityConst")
local EventConst = require("Common.Const.EventConst")
local RedDotConst = require("Const.RedDotConst")
local ItemSourceData = require("Data.item_source_data")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonDailyTaskCtrl")
local HomelandSeasonDailyTaskCtrl = Class.LightClass("HomelandSeasonDailyTaskCtrl", UICtrl)

HomelandSeasonDailyTaskCtrl.ITEM_STATE = {
	CAN_RECEIVE = 2,
	RECEIVED = 1,
	NORMAL = 0
}
HomelandSeasonDailyTaskCtrl.messages = {
	[MessageName.HOME_SEASON_CHANGE] = {
		"onSeasonContextChanged",
		true
	},
	[MessageName.HOME_SEASON_STAGE_CHANGE] = {
		"onSeasonContextChanged",
		true
	},
	[MessageName.HOME_SEASON_TASK_CHANGED] = {
		"onTaskDataChanged",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onDayUpdated",
		true
	}
}

function HomelandSeasonDailyTaskCtrl:onCreate(info)
	self.lifecycleId = (self.lifecycleId or 0) + 1
	self.pendingTaskIds = {}
	self.dataRefreshToken = 0
	self.pendingDayUpdateNotice = false
	self.moduleId = info and info.moduleId or nil

	UICtrl.onCreate(self, info)

	self.languageChangedCallback = CallbackHandler(self, "onLanguageChanged")

	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.languageChangedCallback)
end

function HomelandSeasonDailyTaskCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	self:bindCloseButton(self.view.btnBackUButton)

	function self.view.listTaskUList.luaRenderItem(button, index, data)
		self:renderTaskItem(button, index, data)
	end
end

function HomelandSeasonDailyTaskCtrl:onDestroy()
	self.lifecycleId = self.lifecycleId + 1
	self.dataRefreshToken = self.dataRefreshToken + 1
	self.pendingTaskIds = {}
	self.pendingDayUpdateNotice = false

	pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.languageChangedCallback)

	self.languageChangedCallback = nil
	self.view.btnBackUButton.luaClick = nil
	self.view.listTaskUList.luaRenderItem = nil

	UICtrl.onDestroy(self)
end

function HomelandSeasonDailyTaskCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.lifecycleId = self.lifecycleId + 1
	self.dataRefreshToken = self.dataRefreshToken + 1
	self.pendingTaskIds = {}
	self.pendingDayUpdateNotice = false
	self.moduleId = info and info.moduleId or nil

	self:refreshUI()
end

function HomelandSeasonDailyTaskCtrl:onShow()
	self:refreshUI()
end

function HomelandSeasonDailyTaskCtrl:onSeasonContextChanged()
	self.lifecycleId = self.lifecycleId + 1
	self.pendingTaskIds = {}

	self:scheduleDataRefresh(false)
end

function HomelandSeasonDailyTaskCtrl:onTaskDataChanged(taskId)
	if taskId then
		self.pendingTaskIds[taskId] = nil
	else
		self.pendingTaskIds = {}
	end

	self:scheduleDataRefresh(false)
end

function HomelandSeasonDailyTaskCtrl:onDayUpdated()
	self.pendingTaskIds = {}

	self:scheduleDataRefresh(true)
end

function HomelandSeasonDailyTaskCtrl:scheduleDataRefresh(showDayUpdateNotice)
	self.pendingDayUpdateNotice = self.pendingDayUpdateNotice or showDayUpdateNotice
	self.dataRefreshToken = self.dataRefreshToken + 1

	local token = self.dataRefreshToken

	self:startFrameTimer(function()
		if token ~= self.dataRefreshToken or not self._isOpen or not self.view then
			return
		end

		local needShowNotice = self.pendingDayUpdateNotice

		self.pendingDayUpdateNotice = false

		self:refreshUI()

		if needShowNotice then
			pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_DAILY_TASK_REFRESH_NOTICE)
		end
	end, 1)
end

function HomelandSeasonDailyTaskCtrl:onLanguageChanged()
	if self._isOpen and self.view then
		self:refreshUI()
	end
end

function HomelandSeasonDailyTaskCtrl:refreshUI()
	local taskList = self.model:refreshTaskData(self.moduleId)

	self.moduleId = self.model.moduleId

	if not self.moduleId then
		self:dismiss()

		return
	end

	ClientTextUtils.setText(self.view.txtSeasonNameUSDFText, self.model:getModuleName())
	self.view.listTaskUList:SetList(taskList)
end

function HomelandSeasonDailyTaskCtrl:renderTaskItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
	local btnReceiveUButton = objectReference:GetRefValue("btnReceiveUButton")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local numUWidget = objectReference:GetRefValue("numUWidget")
	local btnGoObjectReference = btnGoUButton:GetComponent("ObjectReference")
	local btnGoTextUText = btnGoObjectReference and btnGoObjectReference:GetRefValue("txtNameUText")
	local description = pg.getLocalizationText(data.description)
	local detailsText = description

	if data.isReady then
		numUWidget:SetActive(true)
		ClientTextUtils.setText(txtNumUSDFText, string.format("%s/%s", data.progress, data.target))
	else
		numUWidget:SetActive(false)
	end

	ClientTextUtils.setText(txtDetailsUSDFText, detailsText)

	if btnGoTextUText then
		ClientTextUtils.setText(btnGoTextUText, pg.getGameString("BUTTON_NAME_1"))
	end

	function listRewardUList.luaRenderItem(rewardButton, rewardIndex, rewardData)
		LuaUIUtils.renderRewardItem(rewardButton, rewardData)
	end

	listRewardUList:SetList(LuaUIUtils.getRewardItemByDropId(data.rewardId, data.hasReceived, data.canReceive))

	local pending = self.pendingTaskIds[data.taskId] == true
	local canReceive = data.isReady and data.canReceive
	local itemState = HomelandSeasonDailyTaskCtrl.ITEM_STATE.NORMAL

	if data.isReady and data.hasReceived then
		itemState = HomelandSeasonDailyTaskCtrl.ITEM_STATE.RECEIVED
	elseif canReceive then
		itemState = HomelandSeasonDailyTaskCtrl.ITEM_STATE.CAN_RECEIVE
	end

	button:TryChangePage("State", itemState)

	local sourceId = data.sourceId
	local showGo = data.isReady and data.taskState == ActivityConst.TaskState.UnFinished
	local hasGoSource = type(sourceId) == "number" and sourceId > 0

	btnGoUButton:SetActive(showGo)

	btnGoUButton.interactable = showGo
	btnReceiveUButton.interactable = canReceive and not pending

	local rewardRedDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_DAILY_QUEST_REWARD_ITEM, self.model.seasonId, data.taskId)

	pg.global.setRedDot(rewardRedDotPath, btnReceiveUButton, canReceive, RedDotConst.RedDotStyle.REWARD)

	btnGoUButton.luaClick = nil
	btnReceiveUButton.luaClick = nil

	if showGo and hasGoSource then
		function btnGoUButton.luaClick()
			local sourceData = ItemSourceData[sourceId]

			if not sourceData then
				return
			end

			pg.global.ui:closeAllNormalPanel()
			LuaUIUtils.clueSeek(sourceData, nil, nil, sourceId)
		end
	end

	if canReceive and not pending then
		function btnReceiveUButton.luaClick()
			self:onReceiveTaskClick(data)
		end
	end
end

function HomelandSeasonDailyTaskCtrl:onReceiveTaskClick(data)
	local taskId = data.taskId

	if not data.isReady or not data.canReceive or not taskId or self.pendingTaskIds[taskId] then
		return
	end

	self.pendingTaskIds[taskId] = true

	self.view.listTaskUList:RefreshList()
	pg.me:reqReceiveHomeSeasonTaskReward(taskId, CallbackHandler(self, "onReceiveTaskRewardCallback", self.lifecycleId, taskId))
end

function HomelandSeasonDailyTaskCtrl:onReceiveTaskRewardCallback(lifecycleId, taskId, code, receivedTaskId)
	if lifecycleId ~= self.lifecycleId or not self._isOpen or not self.view then
		return
	end

	if code ~= NoticeDef.SUCCESS then
		self.pendingTaskIds[taskId] = nil

		pg.global.showBubbleMessage(code)

		if code == NoticeDef.ERROR_ACTIVITY_NOT_OPEN then
			self:dismiss()

			return
		end

		self:refreshUI()

		return
	end

	if receivedTaskId ~= taskId then
		logger:error("home season task reward response mismatch requestTaskId=%s responseTaskId=%s", tostring(taskId), tostring(receivedTaskId))

		self.pendingTaskIds[taskId] = nil

		self:refreshUI()
	end
end

return HomelandSeasonDailyTaskCtrl
