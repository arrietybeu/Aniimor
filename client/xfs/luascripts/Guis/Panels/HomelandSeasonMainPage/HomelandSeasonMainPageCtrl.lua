-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonMainPage\\HomelandSeasonMainPageCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonMainPageCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomelandSeasonData = require("Data.home_season_data")
local HomeSeasonModuleData = require("Data.home_season_module_data")
local HomeSeasonCollectionRewardData = require("Data.home_season_collection_reward_data")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeSeasonConfigData = require("Data.home_season_config_data")
local HomelandSeasonMainPageCtrl = Class.LightClass("HomelandSeasonMainPageCtrl", UICtrl)

HomelandSeasonMainPageCtrl.STAGE_REFRESH_DELAY_OFFSET = 1

local COLLECTION_REWARD_STATE_CAN_RECEIVE = 1
local COLLECTION_REWARD_STATE_RECEIVED = 2
local COLLECTION_REWARD_STATE_MAILED = 3

HomelandSeasonMainPageCtrl.messages = {
	[MessageName.HOME_SEASON_CHANGE] = {
		"onSeasonChanged",
		true
	},
	[MessageName.HOME_SEASON_PROGRESS_CHANGE] = {
		"onSeasonProgressChanged",
		true
	},
	[MessageName.HOME_SEASON_TASK_CHANGED] = {
		"onHomeSeasonTaskChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMutationCropItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onMutationCropItemCountChanged",
		true
	}
}

function HomelandSeasonMainPageCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomelandSeasonMainPageCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.shopBtn.luaClick()
		self:openSeasonShop()
	end

	function self.view.btnInfoUButton.luaClick()
		self:openSeasonIntro()
	end

	self.view.btnInfoUButton:SetHotkeyConsoleBar("CONSOLE_BAR_RULES_DESCRIPTION", 0)

	if self.view.seasonCountDown then
		function self.view.seasonCountDown.luaFinished()
			self:onSeasonCountDownFinished()
		end
	end
end

function HomelandSeasonMainPageCtrl:onDestroy()
	self:clearStageRefreshTimer()
	UICtrl.onDestroy(self)

	self.funcBtns = nil
end

function HomelandSeasonMainPageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.seasonExpired = false

	self:updateSeasonState(info)

	if not HomelandSeasonData[self.seasonId] then
		logger:error("home season config is unavailable seasonId=%s", tostring(self.seasonId))
		self:close()

		return
	end

	if not HomeSeasonUtils.isSeasonAvailable(pg.me) or pg.me.homeSeasonId ~= self.seasonId then
		self:close()

		return
	end

	self.funcBtns = {
		self.view.btn1UButton,
		self.view.btn2UButton,
		self.view.btn3UButton,
		self.view.btn4UButton
	}

	self:initSeasonProgressListener()
	self:refreshSeasonInfo()
end

function HomelandSeasonMainPageCtrl:onShow()
	return
end

function HomelandSeasonMainPageCtrl:onHide()
	return
end

function HomelandSeasonMainPageCtrl:updateSeasonState(info)
	local player = pg.me

	if player then
		self.seasonId = player.homeSeasonId or 0

		return
	end

	self.seasonId = info and info.seasonId or 0
end

function HomelandSeasonMainPageCtrl:onSeasonChanged()
	if not self.view or self.seasonExpired then
		return
	end

	local player = pg.me
	local seasonId = player and (player.homeSeasonId or 0) or 0

	if not HomeSeasonUtils.isSeasonAvailable(player) then
		self:close()

		return
	end

	local seasonChanged = self.seasonId ~= seasonId

	self.seasonId = seasonId

	if seasonChanged then
		self:initSeasonProgressListener()
	end

	self:refreshSeasonInfo()
end

function HomelandSeasonMainPageCtrl:onSeasonCountDownFinished()
	self.seasonExpired = true

	self:close()
	facade:sendMsgToUI(MessageName.HOME_SEASON_CHANGE)
end

function HomelandSeasonMainPageCtrl:openSeasonShop()
	local exchangeShopId = self:getHomeSeasonShopId()

	if not exchangeShopId then
		logger:error("home season exchange shop is unavailable seasonId=%s", tostring(self.seasonId))
		pg.global.showBubbleMessage(NoticeDef.ERROR_CONFIG_HAS_ERROR)

		return
	end

	if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
		shopTags = {
			exchangeShopId
		},
		shopTag = HomeSeasonConfigData.SeasonShopType or 51
	})
end

function HomelandSeasonMainPageCtrl:getHomeSeasonShopId()
	local seasonInfo = HomelandSeasonData[self.seasonId]
	local exchangeShopId = seasonInfo and seasonInfo.exchangeShopId or HomelandConfigData.homelandShopId or 26

	return exchangeShopId
end

function HomelandSeasonMainPageCtrl:getHomeSeasonPlantShopId()
	local seasonInfo = HomelandSeasonData[self.seasonId]
	local homePlantShopId = seasonInfo and seasonInfo.homePlantShopId or HomeSeasonConfigData.SeasonShopType or 51

	return homePlantShopId
end

function HomelandSeasonMainPageCtrl:refreshSeasonInfo()
	self:refreshSeasonBaseInfo()
	self:refreshRemainTime()
	self:refreshSeasonProgress()
	self:refreshSeasonFunctions()
	self:refreshShopInfo()
	self:scheduleStageRefresh()
end

function HomelandSeasonMainPageCtrl:clearStageRefreshTimer()
	if self.stageRefreshTimer then
		TimerManager.removeTimer(self.stageRefreshTimer)

		self.stageRefreshTimer = nil
	end
end

function HomelandSeasonMainPageCtrl:scheduleStageRefresh()
	self:clearStageRefreshTimer()

	local now = Time.secondCache or Time.getSecond()
	local nextChangeTime = HomeSeasonUtils.getNextStageChangeTime(self.seasonId, now)

	if not nextChangeTime then
		return
	end

	local delay = math.max(nextChangeTime - now + HomelandSeasonMainPageCtrl.STAGE_REFRESH_DELAY_OFFSET, HomelandSeasonMainPageCtrl.STAGE_REFRESH_DELAY_OFFSET)

	self.stageRefreshTimer = TimerManager.addTimer(delay, function()
		self.stageRefreshTimer = nil

		if not self.view or self.seasonExpired then
			return
		end

		self:refreshSeasonFunctions()
		self:refreshShopInfo()
		self:scheduleStageRefresh()
	end)
end

function HomelandSeasonMainPageCtrl:onSeasonProgressChanged()
	if not self.view then
		return
	end

	self:refreshSeasonProgress()
end

function HomelandSeasonMainPageCtrl:refreshSeasonBaseInfo()
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}

	ClientTextUtils.setText(self.view.txtTitle, pg.getLocalizationText(seasonInfo.name))
	ClientTextUtils.setText(self.view.bigTxtTitle, pg.getLocalizationText(seasonInfo.name))
end

function HomelandSeasonMainPageCtrl:refreshRemainTime()
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}

	ClientTextUtils.setText(self.view.remainTextTitle, pg.getGameString("ACTIVITY_REMAIN_TIME"))
	ClientTextUtils.setText(self.view.ruleTitle, pg.getGameString("EVENT_RULE_TITLE"))

	local seasonDesc = self.view.descScroll.content:GetComponent("USDFText")

	ClientTextUtils.setText(seasonDesc, pg.getLocalizationText(seasonInfo.desc))

	if self.view.seasonCountDown then
		local endTime = Utils.getConfigTimeOfAreaByData(seasonInfo.endDayTime, seasonInfo.endDayTimeRefId)
		local remainTime = endTime and endTime - Time.getSecond() + 1 or 0

		if remainTime > 0 then
			local d = ClientTextUtils.getGameString("DAY")
			local h = ClientTextUtils.getGameString("HOUR")
			local m = ClientTextUtils.getGameString("MINUTE")

			if remainTime > Const.SECONDS_ONE_DAY then
				self.view.seasonCountDown.formatText = string.format("{0}%s{1}%s", d, h)
			else
				self.view.seasonCountDown.formatText = string.format("{1}%s{2}%s", h, m)
			end

			self.view.seasonCountDown:Play(remainTime)
		else
			self.view.seasonCountDown:Stop()
		end
	end
end

function HomelandSeasonMainPageCtrl:refreshSeasonFunctions()
	if not self.funcBtns then
		return
	end

	local seasonInfo = HomelandSeasonData[self.seasonId] or {}
	local funcRefIds = seasonInfo.funcRefIds or {}

	for index, funcBtn in ipairs(self.funcBtns) do
		funcBtn:ClearRedDot()

		local refId = funcRefIds[index]

		funcBtn:SetActive(refId ~= nil)

		if refId then
			self:rendererFuncBtn(funcBtn, refId)
		end
	end
end

function HomelandSeasonMainPageCtrl:rendererFuncBtn(button, refId)
	local moduleInfo = HomeSeasonModuleData[refId]

	if not moduleInfo or moduleInfo.seasonId ~= self.seasonId then
		logger:error("home season module config is invalid seasonId=%s moduleId=%s", tostring(self.seasonId), tostring(refId))
		button:SetActive(false)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtEndedUSDFText = objectReference:GetRefValue("txtEndedUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local endTimeUSDFText = objectReference:GetRefValue("endTimeUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(moduleInfo.name))
	ClientTextUtils.setText(txtEndedUSDFText, pg.getGameString("FINISHED"))

	if moduleInfo.icon then
		iconUImage.url = moduleInfo.icon or ""
	end

	local curTime = Time.secondCache or Time.getSecond()
	local eventStartTime = Utils.getConfigTimeOfAreaByData(moduleInfo.startDayTime, moduleInfo.startDayTimeRefId)
	local eventEndTime = Utils.getConfigTimeOfAreaByData(moduleInfo.endDayTime, moduleInfo.endDayTimeRefId)

	if eventStartTime and curTime < eventStartTime then
		function button.luaClick()
			pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_EVENT_NOT_OPEN)
		end

		button:TryChangePage("State", 2)

		local remainTimeText = TimeUtils.getRemainTimeShort(eventStartTime - curTime)

		ClientTextUtils.setText(endTimeUSDFText, pg.getFormatText(pg.getGameString("START_TIME_DESC"), remainTimeText))
	else
		function button.luaClick()
			self:onFuncBtnClick(refId)
		end

		if eventEndTime and eventEndTime < curTime then
			button:TryChangePage("State", 0)
			ClientTextUtils.setText(endTimeUSDFText, "")
		else
			button:TryChangePage("State", 1)

			local endTimeText = ""

			if eventEndTime then
				local remainTimeText = TimeUtils.getRemainTimeShort(eventEndTime - curTime + 1)

				endTimeText = pg.getFormatText(pg.getGameString("FINISH_TIME_DESC"), remainTimeText)
			end

			ClientTextUtils.setText(endTimeUSDFText, endTimeText)
		end
	end

	self:initSeasonModuleRedDot(button, refId, moduleInfo.type)
end

function HomelandSeasonMainPageCtrl:getSeasonModuleRedDotPath(moduleType)
	return HomeSeasonUtils.getHomeSeasonModuleRedDotPath(self.seasonId, moduleType)
end

function HomelandSeasonMainPageCtrl:initSeasonModuleRedDot(button, moduleId, moduleType)
	local redDotPath = self:getSeasonModuleRedDotPath(moduleType)

	if not redDotPath then
		return
	end

	pg.global.setPreViewRedDot(redDotPath, button, function()
		return self:getSeasonModuleRedDotStyle(moduleId, moduleType, redDotPath)
	end)
end

function HomelandSeasonMainPageCtrl:getSeasonModuleRedDotStyle(moduleId, moduleType, redDotPath)
	return HomeSeasonUtils.getHomeSeasonModuleRedDotStyle(pg.me, self.seasonId, moduleId, moduleType, redDotPath)
end

function HomelandSeasonMainPageCtrl:onHomeSeasonTaskChanged()
	if not self.view then
		return
	end

	local redDotPath = self:getSeasonModuleRedDotPath(Const.HOMELAND_SEASON_MODULE_TYPE.DAILY_QUEST)

	pg.global.refreshRedDotState(redDotPath)
end

function HomelandSeasonMainPageCtrl:onMutationCropItemCountChanged(data)
	if not self.view or not data then
		return
	end

	local itemId = data.itemId or data.genId

	if not HomeSeasonUtils.isHomeSeasonMutationCropItem(self.seasonId, itemId) then
		return
	end

	local redDotPath = self:getSeasonModuleRedDotPath(Const.HOMELAND_SEASON_MODULE_TYPE.ITEM_COLLECT)

	pg.global.refreshRedDotState(redDotPath)
end

function HomelandSeasonMainPageCtrl:initSeasonProgressListener()
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}
	local progressModuleInfo = HomeSeasonModuleData[seasonInfo.progressRefId]

	if not progressModuleInfo or progressModuleInfo.seasonId ~= self.seasonId then
		logger:error("home season progress module is invalid seasonId=%s moduleId=%s", tostring(self.seasonId), tostring(seasonInfo.progressRefId))
		self.view.progressUWidget:SetActive(false)

		return
	end

	self.view.progressUWidget:SetActive(true)

	local objectReference = self.view.progressObjectRef
	local rewardList = objectReference:GetRefValue("rewardList")
	local btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")

	function btnInfoUButton.luaRenderTooltip(btn, tipPanel)
		local objectReference = tipPanel:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(progressModuleInfo.des))
	end

	function rewardList.luaRenderItem(button, idx, data)
		self:rendererProgressRewardItem(button, data)
	end

	local btnArrowUButton = objectReference:GetRefValue("btnArrowUButton")

	function btnArrowUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_SEASON, {
			seasonId = self.seasonId
		})
	end

	local progressNameText = objectReference:GetRefValue("progressNameText")

	ClientTextUtils.setText(progressNameText, pg.getLocalizationText(progressModuleInfo.name))
end

function HomelandSeasonMainPageCtrl:refreshSeasonProgress()
	if not self.view then
		return
	end

	local objectReference = self.view.progressObjectRef
	local progressText = objectReference:GetRefValue("progressText")
	local rewardList = objectReference:GetRefValue("rewardList")

	self.curProgress = pg.me and (pg.me.homeSeasonCollectionScore or 0) or 0

	ClientTextUtils.setText(progressText, tostring(self.curProgress))

	local rewardStateMap = pg.me and pg.me.homeSeasonCollectionRewardStateMap or {}
	local rewardListData = {}

	for rewardRowId, rewardInfo in pairs(HomeSeasonCollectionRewardData or EMPTY_TABLE) do
		if rewardInfo.seasonId == self.seasonId then
			rewardListData[#rewardListData + 1] = {
				id = rewardRowId,
				numMax = rewardInfo.needPoint or 0,
				rewardId = rewardInfo.reward,
				rewardState = rewardStateMap and rewardStateMap[rewardRowId] or 0
			}
		end
	end

	table.sort(rewardListData, function(a, b)
		if a.numMax == b.numMax then
			return a.id < b.id
		end

		return a.numMax < b.numMax
	end)

	local preNum = 0

	for _, rewardData in ipairs(rewardListData) do
		rewardData.numMin = preNum
		preNum = rewardData.numMax
	end

	rewardList:SetList(rewardListData)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.HOME_SEASON_PROGRESS_REWARD)
end

function HomelandSeasonMainPageCtrl:rendererProgressRewardItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local progress2UProgress = objectReference:GetRefValue("progress2UProgress")

	progress2UProgress.maxValue = 1
	progress2UProgress.minValue = 0

	if self.curProgress >= data.numMax then
		progress2UProgress.value = 1
	elseif self.curProgress < data.numMin or data.numMax <= data.numMin then
		progress2UProgress.value = 0
	else
		progress2UProgress.value = (self.curProgress - data.numMin) / (data.numMax - data.numMin)
	end

	ClientTextUtils.setText(numUSDFText, data.numMax)

	local rewardList = LuaUIUtils.getRewardItemByDropId(data.rewardId)
	local renderData = rewardList[1]

	if not renderData then
		rewardItemUButton:ClearRedDot()
		rewardItemUButton:SetActive(false)

		return
	end

	rewardItemUButton:SetActive(true)

	local canReceive = data.rewardState == COLLECTION_REWARD_STATE_CAN_RECEIVE
	local hasReceived = data.rewardState == COLLECTION_REWARD_STATE_RECEIVED or data.rewardState == COLLECTION_REWARD_STATE_MAILED

	if canReceive then
		function renderData.extraFunc()
			self:onSeasonRewardBtnClick(data.id)
		end
	else
		renderData.extraFunc = nil
	end

	if hasReceived then
		renderData.state = 1
	elseif canReceive then
		renderData.state = 2
	else
		renderData.state = 0
	end

	LuaUIUtils.renderRewardItem(rewardItemUButton, renderData)

	local rewardRedDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_PROGRESS_REWARD_ITEM, self.seasonId, data.id)

	pg.global.setRedDot(rewardRedDotPath, rewardItemUButton, canReceive, RedDotConst.RedDotStyle.REWARD)
end

function HomelandSeasonMainPageCtrl:openSeasonIntro()
	pg.global.ui.homelandSeasonIntro:open({
		seasonId = self.seasonId
	})
end

function HomelandSeasonMainPageCtrl:refreshShopInfo()
	local seasonInfo = HomelandSeasonData[self.seasonId] or {}
	local shopModuleInfo = HomeSeasonModuleData[seasonInfo.shopRefId]
	local exchangeShopId = self:getHomeSeasonShopId()
	local canOpenShop = exchangeShopId ~= nil and HomeSeasonUtils.isModuleOpen(self.seasonId, seasonInfo.shopRefId)

	self.view.shopBtn:SetActive(canOpenShop)

	if not canOpenShop then
		return
	end

	local txtNameUText = self.view.shopBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(shopModuleInfo.name))
end

function HomelandSeasonMainPageCtrl:onFuncBtnClick(moduleId)
	local moduleInfo = HomeSeasonModuleData[moduleId]

	if not moduleInfo or moduleInfo.seasonId ~= self.seasonId then
		logger:error("home season module is unavailable seasonId=%s moduleId=%s", tostring(self.seasonId), tostring(moduleId))
		pg.global.showBubbleMessage(NoticeDef.ERROR_CONFIG_HAS_ERROR)

		return
	end

	if not HomeSeasonUtils.isModuleOpen(self.seasonId, moduleId) then
		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_EVENT_NOT_OPEN)

		return
	end

	local moduleQuestId = moduleInfo.moduleQuestId

	if moduleQuestId and moduleQuestId ~= 0 and not QuestCommonUtils.questCompleted(pg.me, moduleQuestId) then
		if not HomeSeasonUtils.acceptAndTraceHomeSeasonQuest(pg.me, moduleQuestId) then
			logger:warn("home season quest chain has no traceable quest, moduleQuestId=%s", moduleQuestId)
		end

		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_NOT_FINISH_QUEST)

		return
	end

	local moduleType = moduleInfo.type

	if moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.ITEM_COLLECT then
		local exchangeShopId = self:getHomeSeasonPlantShopId()

		pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP, {
			seasonId = self.seasonId,
			exchangeShopId = exchangeShopId
		})
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.PROGRESS then
		pg.global.ui:open(UIConst.UI_ID_HOME_BOOK_SEASON, {
			seasonId = self.seasonId
		})
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.SHOP then
		self:openSeasonShop()
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.DAILY_QUEST then
		pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_DAILY_TASK, {
			moduleId = moduleId
		})
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.PREPARE_QUEST then
		pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_PREPARE, {
			moduleId = moduleId
		})
	elseif moduleType == Const.HOMELAND_SEASON_MODULE_TYPE.PARTY then
		pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_PARTY, {
			moduleId = moduleId
		})
	else
		pg.global.showBubbleMessage(NoticeDef.HOME_SEASON_EVENT_NOT_OPEN)

		return
	end

	local redDotPath = self:getSeasonModuleRedDotPath(moduleType)

	if redDotPath then
		HomeSeasonUtils.markHomeSeasonModuleEntryViewed(pg.me, redDotPath)
		pg.global.refreshRedDotState(redDotPath)
	end
end

function HomelandSeasonMainPageCtrl:onSeasonRewardBtnClick(rewardRowId)
	pg.me:serverMsg("RPC_CS_ReceiveHomeSeasonCollectionReward", rewardRowId)
end

return HomelandSeasonMainPageCtrl
