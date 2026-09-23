-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonLobby\\SeasonLobbyCtrl.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SeasonLobbyCtrl")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local ActivityConst = require("Common.Const.ActivityConst")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local SHOP_SHOW_INTERVAL = 3
local ENTRY_FOCUS_REFRESH_DELAY = 0.45
local ENTRY_FOCUS_VISUALS_HIDE_DURATION = 0.5
local SeasonLobbyCtrl = Class.LightClass("SeasonLobbyCtrl", UICtrl)

SeasonLobbyCtrl.messages = {
	[MessageName.CURRENCY_CHANGE] = {
		"onSeasonCurrencyChanged",
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
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onSeasonCurrencyChanged",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onSeasonCurrencyChanged",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityStateChanged",
		true
	}
}

function SeasonLobbyCtrl:onOpen(info)
	if not self:_checkSeasonActivityOpen() then
		return
	end

	if info and info.type == "open" and info.openTab == "battlepass" then
		self:_showBattlePass()

		return
	end

	self:refresh()
	self:_playEnterSound()
	self:_scheduleEntryFocusRefresh()
	self:_startShopShowLoop()
	self:_checkFirstOpen()
end

function SeasonLobbyCtrl:onShow()
	return
end

function SeasonLobbyCtrl:onVisibleChange(visible)
	if visible then
		if self._replayEntryAnimationOnVisible then
			self._replayEntryAnimationOnVisible = nil

			self:_replayEntryAnimation()
		end

		self:_startShopShowLoop(true)

		return
	end

	self._replayEntryAnimationOnVisible = self._adapterVisibilityState == UIConst.UI_ADAPTER_VISIBILITY_STATE.PANEL_COVERED

	self:_stopShopShowLoop()
end

function SeasonLobbyCtrl:onDestroy()
	self:_stopShopShowLoop()
	self:_cancelEntryFocusRefresh()

	self._replayEntryAnimationOnVisible = nil
end

function SeasonLobbyCtrl:_replayEntryAnimation()
	if not self:checkUIVisible() then
		return
	end

	local widget = self.view and self.view.widget

	if not widget then
		return
	end

	widget:InvokeCallback(CS.XGUI.EInvokeTime.Show)

	local animation = widget.anim

	if animation then
		animation:Sample()
	end
end

function SeasonLobbyCtrl:addListener()
	self:_bindClick(self.view.btnCloseUButton, function()
		self:dismiss()
	end)
	self:_bindClick(self.view.btnBPUButton, function()
		self:_showBattlePass()
	end)
	self:_bindClick(self.view.btnWeekMedalUButton, function()
		self:_showWeekMedal()
	end)
	self:_bindClick(self.view.btnSeasonCatchUButton, function()
		self:_showSeasonCatch()
	end)
	self:_bindClick(self.view.btnSeasonAchievementUButton, function()
		self:_showSeasonAchievement()
	end)
	self:_bindClick(self.view.btnSeasonShopUButton, function()
		self:_showSeasonShop()
	end)
	self:_bindClick(self.view.btnSeasonTipsUButton, function()
		self:_showSeasonTips()
	end)
	self:_bindClick(self.view.btnSeasonCalendarUButton, function()
		self:_showSeasonCalendar()
	end)
	self:_bindEntryRedDots()
end

function SeasonLobbyCtrl:_bindClick(button, handler)
	if not button then
		return
	end

	button.luaClick = handler
end

function SeasonLobbyCtrl:_bindEntryRedDots()
	local achievementButton = self.view.btnSeasonAchievementUButton

	if achievementButton then
		achievementButton:ClearRedDot()
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SEASON_LOBBY_ACHIEVEMENT, achievementButton, function()
			return pg.global.ui.seasonAchievement.model:getEntryRedDotStyle()
		end)
	end

	local battlePassButton = self.view.btnBPUButton

	if battlePassButton then
		battlePassButton:ClearRedDot()
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SEASON_LOBBY_BATTLEPASS, battlePassButton, CashShopRedDotUtils.getBattlePassHudRedDotStyle)
	end

	local shopButton = self.view.btnSeasonShopUButton

	if shopButton then
		shopButton:ClearRedDot()
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.SEASON_LOBBY_SHOP, shopButton, function()
			local seasonShop = pg.global.ui.seasonShop
			local seasonShopModel = seasonShop and seasonShop.model

			return seasonShopModel and seasonShopModel:getEntryRedDotStyle() or RedDotConst.RedDotStyle.NONE
		end)
	end
end

function SeasonLobbyCtrl:_refreshEntryRedDots()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_LOBBY_ACHIEVEMENT)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_LOBBY_BATTLEPASS)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.SEASON_LOBBY_SHOP)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FUNC_MENU_SEASON_LOBBY)
end

function SeasonLobbyCtrl:refresh()
	self:_refreshBgm()

	local ruleDesc = self.model:getSeasonRuleDesc()

	self.view:setSeasonTipsVisible(ruleDesc ~= nil)
	ClientTextUtils.setText(self.view.txtBackBtnUSDFText, self.model:getSeasonLobbyTitleName() or pg.getGameString("COMMON_CANCEL"))

	local seasonTitleTextId = self.model:getSeasonTitleTextId()
	local seasonTitleText = seasonTitleTextId and pg.getLocalizationText(seasonTitleTextId) or ""

	ClientTextUtils.setText(self.view.txtTitleUText, seasonTitleText)
	ClientTextUtils.setText(self.view.txtSeasonCalendarUText, pg.getGameString("SEASON_OVERVIEW"))
	ClientTextUtils.setText(self.view.txtShopBtnNameUSDFText, pg.getGameString("SEASON_ENTRY_SHOP"))
	self:refreshSeasonCountDowns()

	local battlePassEndTime = self.model:getActivityEndTime(ActivityConst.EventType.BattlePass)
	local seasonAchievementEndTime = self.model:getActivityEndTime(ActivityConst.EventType.SeasonAchievements)

	self:_renderButtonItem(self.view.btnBPUButton, "SEASON_ENTRY_BP", battlePassEndTime)
	self:_renderButtonItem(self.view.btnWeekMedalUButton, "SEASON_ENTRY_WEEKLY")
	self:_renderSeasonCatchButtonItem(self.view.btnSeasonCatchUButton)
	self:_renderButtonItem(self.view.btnSeasonAchievementUButton, "SEASON_ENTRY_ACHIEVEMENT", seasonAchievementEndTime)
	self:_renderButtonItem(self.view.btnSeasonShopUButton, "SEASON_ENTRY_SHOP")
	self:refreshSeasonCoinIcon()
	self:refreshSeasonCoinNum()
	self:_refreshEntryRedDots()
end

function SeasonLobbyCtrl:_refreshBgm()
	local bgm = self.model:getSeasonAudioConfig()

	if self.uiConfig.bgm == bgm then
		return
	end

	self.uiConfig.bgm = bgm

	if self:checkUIVisible() then
		-- block empty
	end

	self.adapter:refreshUIBgm()
end

function SeasonLobbyCtrl:_playEnterSound()
	local _, enterSound = self.model:getSeasonAudioConfig()

	if enterSound then
		pg.game.audio:playEvent(enterSound)
	end
end

function SeasonLobbyCtrl:refreshSeasonCountDowns()
	local seasonEndTime, stageEndTime = self.model:getSeasonCountDownEndTimes()

	self:_renderCountDown(self.view.countDownUCountDown, seasonEndTime)
	self:_renderCountDown(self.view.seasonStageUCountDown, stageEndTime)
end

function SeasonLobbyCtrl:refreshSeasonCoinIcon()
	local seasonCoinInfo = self.model:getSeasonCoinInfo()
	local seasonCoinId = seasonCoinInfo and seasonCoinInfo.itemId

	self.view.iconSeasonCoinUImage.url = seasonCoinId and LuaUIUtils.getIconByItemId(seasonCoinId) or ""
end

function SeasonLobbyCtrl:refreshSeasonCoinNum()
	local seasonCoinInfo = self.model:getSeasonCoinInfo()

	ClientTextUtils.setText(self.view.txtSeasonCoinNumUFText, seasonCoinInfo and seasonCoinInfo.count or 0)
end

function SeasonLobbyCtrl:onSeasonCurrencyChanged()
	self:refreshSeasonCoinNum()
	self:_refreshEntryRedDots()
end

function SeasonLobbyCtrl:_startShopShowLoop(keepIndex)
	self:_stopShopShowLoop()

	local urls = self.model:getShopImageUrls()

	if not urls or #urls == 0 then
		return
	end

	if not keepIndex or not self._shopShowIndex or self._shopShowIndex > #urls then
		self._shopShowIndex = 1
	end

	if not self.view:setShopImageUrl(urls[self._shopShowIndex]) then
		return
	end

	if #urls <= 1 then
		return
	end

	self._shopShowTimerId = self:startTimer(function()
		self:_showNextShopImage()
	end, SHOP_SHOW_INTERVAL, true)
end

function SeasonLobbyCtrl:_showNextShopImage()
	local urls = self.model:getShopImageUrls()

	if not urls or #urls == 0 then
		self:_stopShopShowLoop()

		return
	end

	self._shopShowIndex = (self._shopShowIndex or 1) % #urls + 1

	if not self.view:setShopImageUrl(urls[self._shopShowIndex]) then
		self:_stopShopShowLoop()
	end
end

function SeasonLobbyCtrl:_stopShopShowLoop()
	if self._shopShowTimerId then
		self:killTimer(self._shopShowTimerId)

		self._shopShowTimerId = nil
	end
end

function SeasonLobbyCtrl:_scheduleEntryFocusRefresh()
	self:_cancelEntryFocusRefresh()

	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	navMgr:HideFocusVisualsForSeconds(ENTRY_FOCUS_VISUALS_HIDE_DURATION)

	self._entryFocusTimerId = self:startTimer(function()
		self._entryFocusTimerId = nil

		if not self:checkUIVisible() then
			return
		end

		local mgr = pg.global.navMgr

		if not mgr then
			return
		end

		mgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Default)
	end, ENTRY_FOCUS_REFRESH_DELAY)
end

function SeasonLobbyCtrl:_cancelEntryFocusRefresh()
	if self._entryFocusTimerId then
		self:killTimer(self._entryFocusTimerId)

		self._entryFocusTimerId = nil
	end
end

function SeasonLobbyCtrl:_showWeekMedal()
	pg.global.ui:open(UIConst.UI_ID_EVENT_SCHOOL_GUIDE, {
		SchoolGuideConst.EventType.BadgeCollection
	})
end

function SeasonLobbyCtrl:_showSeasonCatch()
	local buttonData = self.model:getSeasonCatchButtonData()

	if not buttonData or not buttonData.sourceData then
		return
	end

	LuaUIUtils.clueSeek(buttonData.sourceData)
end

function SeasonLobbyCtrl:_showSeasonAchievement()
	pg.global.ui:open(UIConst.UI_ID_SEASON_ACHIEVEMENT)
end

function SeasonLobbyCtrl:_showSeasonShop()
	local openInfo = self.model:getSeasonShopOpenInfo()

	if not openInfo then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_SEASON_SHOP, openInfo)
end

function SeasonLobbyCtrl:_showSeasonTips()
	local ruleDesc = self.model:getSeasonRuleDesc()

	if not ruleDesc then
		return
	end

	pg.global.ui.tips:openEventRuleDesc(ruleDesc)
end

function SeasonLobbyCtrl:_showSeasonCalendar()
	pg.global.ui:open(UIConst.UI_ID_SEASON_CALENDAR)
end

function SeasonLobbyCtrl:_renderCountDown(countDown, endTime)
	if not countDown then
		return
	end

	if endTime then
		countDown:SetActive(true)
		LuaUIUtils.setCountDownTime(countDown, endTime, UIConst.TimeType.Short)
	else
		countDown:Stop()
		countDown:SetActive(false)
	end
end

function SeasonLobbyCtrl:_renderButtonItem(button, btnName, countDownTime)
	if not button then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local timeUCountDown = objectReference:GetRefValue("timeUCountDown")

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(btnName))
	self:_renderCountDown(timeUCountDown, countDownTime)
end

function SeasonLobbyCtrl:_renderSeasonCatchButtonItem(button)
	if not button then
		return
	end

	local buttonData = self.model:getSeasonCatchButtonData()

	self.view:setSeasonCatchVisible(buttonData ~= nil)

	if not buttonData then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local buttonText = buttonData.textId and pg.getLocalizationText(buttonData.textId) or ""

	ClientTextUtils.setText(txtNameUSDFText, buttonText)

	if iconUImage then
		iconUImage.url = buttonData.iconUrl
	end
end

function SeasonLobbyCtrl:onActivityStateChanged()
	if not self:_checkSeasonActivityOpen() then
		return
	end

	self:refresh()
end

function SeasonLobbyCtrl:_checkSeasonActivityOpen()
	if self.model:isSeasonActivityOpen() then
		return true
	end

	self:close()

	return false
end

function SeasonLobbyCtrl:_checkFirstOpen()
	local seasonId = self.model:getSeasonId()

	if not seasonId then
		return
	end

	if self.model:hasOpenedSeasonLobbySeason(seasonId) then
		return
	end

	self.model:recordSeasonLobbySeasonOpened(seasonId)
	pg.global.ui:open(UIConst.UI_ID_SEASON_HEAD_TIPS, nil, nil, function()
		self:_replayEntryAnimation()
	end)
end

function SeasonLobbyCtrl:_showBattlePass()
	if not ClientCashShopUtils.canOpenBattlePass() then
		return
	end

	if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

		return
	end

	local battlePassContext = self.model:getBattlePassContext()

	if not battlePassContext then
		return
	end

	if self:_tryShowBattlePassLevelPopup(battlePassContext) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_BP_PERMIT)
end

function SeasonLobbyCtrl:_tryShowBattlePassLevelPopup(battlePassContext)
	local bpGear = battlePassContext.gear
	local popupLimitLevels = battlePassContext.popupLimitLevels

	if bpGear >= battlePassContext.payGear or not popupLimitLevels or #popupLimitLevels == 0 then
		return false
	end

	local phase = battlePassContext.phase
	local recordPhase, shownLevels, isLegacyRecord = self.model:getBattlePassPopupRecord()
	local sameSeason = recordPhase == phase

	if isLegacyRecord and sameSeason then
		shownLevels = self.model:markReachedBattlePassPopupLevels(popupLimitLevels, math.huge, shownLevels)

		self.model:saveBattlePassPopupRecord(phase, shownLevels)
	end

	if not self.model:isBattlePassPopupScopeAllowed(battlePassContext.config) then
		return false
	end

	local bpLevel = battlePassContext.level
	local targetLevel = self.model:getBattlePassPopupTargetLevel(popupLimitLevels, bpLevel, sameSeason, shownLevels)

	if not targetLevel then
		return false
	end

	shownLevels = sameSeason and shownLevels or {}
	shownLevels = self.model:markReachedBattlePassPopupLevels(popupLimitLevels, bpLevel, shownLevels)

	self.model:saveBattlePassPopupRecord(phase, shownLevels)
	pg.global.ui:open(UIConst.UI_ID_BP_CORE_REWARD)

	return true
end

return SeasonLobbyCtrl
