-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BattlePass\\BattlePassCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BattlePassCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local CashShopConst = require("Const.CashShopConst")
local UIConst = require("Const.UIConst")
local BattlePassData = require("Data.event_battlepass_data")
local EventTaskData = require("Data.event_task_data")
local GameEventData = require("Data.game_event_data")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local FriendNewComponent = require("Guis.Panels.Chat.Component.FriendNewComponent")
local RedDotConst = require("Const.RedDotConst")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local AvatarPreviewComponent = require("Guis.Panels.CashShop.Component.AvatarPreviewComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local CommonSwitch = require("Common.CommonSwitch")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PROGRESS_GROW_DURATION = 0.5
local BattlePassCtrl = Class.LightClass("BattlePassCtrl", UICtrl)

BattlePassCtrl.messages = {
	[MessageName.BATTLEPASS_LEVEL_UP] = {
		"onBpChange",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onTaskStateChange",
		true
	},
	[MessageName.BATTLEPASS_CHANGE] = {
		"onBpChange",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"onBpChange",
		true
	},
	[MessageName.BATTLEPASS_SHOW_GIFT_FRIEND_LIST] = {
		"onShowGiftFriendList",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onCommonSwitchStateChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"_refreshLoopRewardCurrency",
		true
	},
	[MessageName.MONTH_CARD_ACTIVATE] = {
		"setMonthEventState",
		true
	}
}

function BattlePassCtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	local skipBlack = info and info.fromPreorderGuide == true

	UICtrl.open(self, info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack or skipBlack)
end

function BattlePassCtrl:checkOpenExtra(info)
	return ClientCashShopUtils.canOpenBattlePass()
end

function BattlePassCtrl:checkCanOpen(showNotice, info)
	if not UICtrl.checkCanOpen(self, showNotice, info) then
		return false
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase

	if not phase then
		return false
	end

	local firstOpenKey = ClientConst.PrefKey.BPFirstOpenPhase

	if pg.global.prefsCacheUtils:getInt(firstOpenKey, 0) ~= phase then
		pg.global.prefsCacheUtils:setInt(firstOpenKey, phase)
		pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE, nil, nil, function()
			pg.global.ui:open(UIConst.UI_ID_BP_PERMIT)
		end)

		return false
	end

	return true
end

function BattlePassCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._hasEnteredOnce = false

	if self.view.levelUpUWidget then
		self.view.levelUpUWidget.gameObject:SetActiveEx(false)
	end

	if self.view.friendUIUComponent then
		self.friendComponent = FriendNewComponent.new(self, self.view.friendUIUComponent)
	end

	self.avatarComponent = AvatarPreviewComponent.new(self, self.view.transform, {
		disableCameraZoom = false,
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		sceneType = UISceneConst.BP_SCENE
	})

	function self._onMonthCardActivate(...)
		self:monthCardActivate(...)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onMonthCardActivate)
end

function BattlePassCtrl:addListener()
	local view = self.view

	if view.btnBack then
		function view.btnBack.luaClick()
			self:dismiss()
		end
	end

	if view.btnBP then
		function view.btnBP.luaClick()
			self:_switchToBattlePassTab()
			self:HideStoreIcon()
		end
	end

	if view.btnMonthCard then
		function view.btnMonthCard.luaClick()
			self:_switchToMonthCardTab()
		end
	end

	if view.btnExchange then
		function view.btnExchange.luaClick()
			logger:info("BattlePassCtrl:btnExchange.luaClick()")
			pg.global.ui:open(UIConst.UI_ID_SEASON_SHOP, {
				shopTags = {
					46
				}
			})
		end
	end

	if view.buttonSkipUButton then
		function view.buttonSkipUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_SEASON_SHOP, {
				shopTags = {
					46
				}
			})
		end
	end

	if view.listBPType then
		function view.listBPType.luaClick(btn, data)
			if data then
				self._currentBPKind = data.kind or 0

				self:_selectBPTypeByKind(self._currentBPKind)
				view.rootUComponent:TryChangePage("Kind", self._currentBPKind)
				self:_tryPlayDeferredBpProgressAnimation()

				if self._currentBPKind == 1 and self._refreshCurrentTaskTab then
					self._refreshCurrentTaskTab()
				end

				self:_scheduleFocusCurrentTabList()
			end
		end
	end

	if view.btnInfo then
		function view.btnInfo.luaClick()
			local ruleDesc = self._bpData and self._bpData.passRule

			if ruleDesc then
				pg.global.ui.tips:openEventRuleDesc(ruleDesc)
			end
		end
	end

	if view.btnBuyBP then
		function view.btnBuyBP.luaClick()
			logger:info("BattlePassCtrl:btnBuyBP.luaClick()")
			pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE, nil, nil, function()
				self:_showBattlePassPet(CashShopConst.PetActionType.BattlePass)
			end)
		end
	end

	if view.btnBuy then
		function view.btnBuy.luaClick()
			pg.global.ui:open(UIConst.UI_ID_BUY_LV)
		end
	end

	if view.btnAllGet then
		function view.btnAllGet.luaClick()
			self:_receiveAllTaskReward()
		end
	end

	if view.btnGift then
		function view.btnGift.luaClick()
			logger:info("BattlePassCtrl:btnGift.luaClick()")
			pg.global.ui:open(UIConst.UI_ID_BP_GIFT)
		end
	end

	if view.listUList then
		function view.listUList.luaRenderItem(button, index, data)
			self:renderItem(button, index, data)
		end
	end

	if view.listTask then
		function view.listTask.luaRenderItem(button, index, data)
			if data.tIndex == 1 then
				self:renderGoToItem(button, index, data)
			else
				self:renderTaskItem(button, index, data)
			end
		end
	end

	if view.btnLeftUButton then
		function view.btnLeftUButton.luaClick()
			if view.listUList and self._bpLevel then
				self:_scrollToLeft(view.listUList, self:_getAwardListIndex(self._bpLevel), false)
			end
		end
	end

	if view.buttonLeftUButton then
		function view.buttonLeftUButton.luaClick()
			self:_changeCycleRewardGroup(-1)
		end
	end

	if view.buttonRightUButton then
		function view.buttonRightUButton.luaClick()
			self:_changeCycleRewardGroup(1)
		end
	end

	if view.changeListBtn then
		function view.changeListBtn.luaClick()
			if not self._isCycleRewardUnlocked then
				return
			end

			if not self._showCycleRewardList and not self:_canShowCycleRewardList() then
				pg.global.showBubbleMessageRaw(pg.getGameString("BATTLEPASS_LOOP_LOCK"))

				return
			end

			self._showCycleRewardList = not self._showCycleRewardList

			if self._showCycleRewardList then
				self._cycleRewardGroupIndex = nil
			end

			self:_refreshAwardListByCurrentMode()

			if view.rootUComponent then
				view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
			end
		end
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener("BattlePassFocusChange", function()
			self:refreshConsoleBarState()
		end)
	end
end

function BattlePassCtrl:showEnterAnim()
	if self._currentBPKind == 1 then
		self.view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	end
end

function BattlePassCtrl:onDestroy()
	if self._fromPreorderGuide then
		pg.game.monthCard:reportPreorderWindow("close", self.uid, true)
	end

	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener("BattlePassFocusChange")
	end

	local view = self.view

	self:_stopBpProgressAnimation()
	self:_stopTaskEndTimeTimer()

	self._bpProgressDeferred = nil

	self:_setBPRotateConsoleBar(false)

	if self._focusTabTimer then
		TimerManager.delFrameCb(self._focusTabTimer)

		self._focusTabTimer = nil
	end

	if view and view.listUList and self._onListScroll then
		view.listUList:UnRegisterToScrollEvent(self._onListScroll)

		self._onListScroll = nil
	end

	if self.avatarComponent then
		self.avatarComponent:onDestroy()

		self.avatarComponent = nil
	end

	UICtrl.onDestroy(self)
	self:HideStoreIcon()

	if self._onMonthCardActivate then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, self._onMonthCardActivate)

		self._onMonthCardActivate = nil
	end

	self.monthEventState = false
end

function BattlePassCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._fromPreorderGuide = info and info.fromPreorderGuide == true

	if self._fromPreorderGuide then
		pg.game.monthCard:reportPreorderWindow("open", self.uid, true)
	end
end

function BattlePassCtrl:DisplayStoreIcon()
	pg.setPSIconUIVisiable("BattlePassCtrl", true)

	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(1)
	end
end

function BattlePassCtrl:HideStoreIcon()
	if pg.setPSIconUIVisiable("BattlePassCtrl", false) == false and PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function BattlePassCtrl:_showBattlePassPet(actionType)
	if not self.avatarComponent or not self._bpData or not self._bpData.passPetModelingId then
		return
	end

	local movementIds = self._bpData.passPetMovementId
	local animKey = movementIds and movementIds[actionType]
	local posXYZ = self._bpData.postionIndex and self._bpData.postionIndex[actionType]
	local rotXYZ = self._bpData.rotationIndex and self._bpData.rotationIndex[actionType]
	local scaleXYZ = self._bpData.scaleIndex and self._bpData.scaleIndex[actionType]

	self.avatarComponent:showPetByModelingId(self._bpData.passPetModelingId, animKey, posXYZ, rotXYZ, scaleXYZ)
end

function BattlePassCtrl:_getBattlePassLevelLimit()
	local normalLevelLimit = math.floor(tonumber(SysConfigData.BATTLE_PASS_LEVEL_UP_MAX) or 0)
	local loopLevelLimit = math.floor(tonumber(SysConfigData.LOOP_LEVEL_LIMITS) or normalLevelLimit)

	return math.max(normalLevelLimit, loopLevelLimit)
end

function BattlePassCtrl:_refreshLevelState(view, bpLevel)
	if not view or not view.rootUComponent then
		return
	end

	local levelLimit = self:_getBattlePassLevelLimit()
	local isMaxLevel = levelLimit > 0 and levelLimit <= bpLevel

	view.rootUComponent:TryChangePage("State", isMaxLevel and 1 or 0)
end

function BattlePassCtrl:onBattlePassLevelUp(data)
	local view = self.view
	local newLevel = data and data.bpLevel or 0

	if view.txtNewLv then
		ClientTextUtils.setText(view.txtNewLv, tostring(newLevel))
	end

	pg.game.audio:triggerEvent("SFX_BP_PURCHASE_LevelUp")
	CashShopRedDotUtils.refreshBattlePassRedDots()

	if view.levelUpUWidget then
		view.levelUpUWidget.gameObject:SetActiveEx(true)
		self:killTimer(self._levelUpTimer)

		self._levelUpTimer = self:startTimer(function()
			if view.levelUpUWidget then
				view.levelUpUWidget.gameObject:SetActiveEx(false)
			end

			self._levelUpTimer = nil
		end, 3)
	end
end

function BattlePassCtrl:onTaskStateChange(data)
	if data and data.isTaskRewardResult then
		self._taskRewardRequestPending = false
	end

	if not self.view then
		return
	end

	if self:_isBpAwardStateChange(data) then
		self:_refreshDynamicContent()
	end

	CashShopRedDotUtils.refreshBattlePassRedDots()

	if self._refreshCurrentTaskTab then
		self._refreshCurrentTaskTab()
	end
end

function BattlePassCtrl:_isBpAwardStateChange(data)
	if not data then
		return false
	end

	if data.taskGroupId and self._bpData and data.taskGroupId == self._bpData.awardTaskGroupId then
		return true
	end

	local cfg = data.taskId and EventTaskData[data.taskId]
	local actTaskType = cfg and cfg.actTaskType

	return actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardFree or actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardPay
end

function BattlePassCtrl:_requestTaskReward(taskId)
	if not taskId or self._taskRewardRequestPending then
		return false
	end

	self._taskRewardRequestPending = true

	if not pg.me:reqActReceiveTaskReward(taskId, self.eventId) then
		self._taskRewardRequestPending = false

		return false
	end

	return true
end

function BattlePassCtrl:_requestGroupTaskReward(taskGroupId)
	if not taskGroupId or self._taskRewardRequestPending then
		return false
	end

	self._taskRewardRequestPending = true

	if not pg.me:reqActReceiveGroupTaskReward(taskGroupId, self.eventId) then
		self._taskRewardRequestPending = false

		return false
	end

	return true
end

function BattlePassCtrl:_switchToBattlePassTab()
	local view = self.view

	self._currentTopTab = CashShopConst.CardShopType.BattlePass

	if view.btnBP then
		view.btnBP:SetSelected(true)
	end

	if view.btnMonthCard then
		view.btnMonthCard:SetSelected(false)
	end

	if view.rootUComponent then
		view.rootUComponent:TryChangePage("Type", CashShopConst.CardShopType.BattlePass)
	end

	self:_tryPlayDeferredBpProgressAnimation()

	if view.bgUWidget then
		view.bgUWidget.gameObject:SetActiveEx(false)
	end

	self:_refreshBPRotateConsoleBar()

	local kind = self._currentBPKind or 0

	if view.rootUComponent then
		if kind == 1 then
			view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
		else
			view.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end
end

function BattlePassCtrl:_switchToMonthCardTab()
	local view = self.view

	self._currentTopTab = CashShopConst.CardShopType.MonthCard

	if view.btnMonthCard then
		view.btnMonthCard:SetSelected(true)
	end

	if view.btnBP then
		view.btnBP:SetSelected(false)
	end

	if view.rootUComponent then
		view.rootUComponent:TryChangePage("Type", CashShopConst.CardShopType.MonthCard)
	end

	if view.bgUWidget then
		view.bgUWidget.gameObject:SetActiveEx(true)
	end

	self:_refreshBPRotateConsoleBar()
	self:refreshmonthCard()
	self:DisplayStoreIcon()
end

function BattlePassCtrl:_setBPRotateConsoleBar(isShow)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_BP_Rotate", isShow == true)
end

function BattlePassCtrl:_isFocusOnClaimableReward()
	if self._currentTopTab ~= CashShopConst.CardShopType.BattlePass or self._currentBPKind ~= 0 then
		return false
	end

	local navMgr = pg.global.navMgr
	local focused = navMgr and navMgr.CurrentFocusedUContent

	if not focused or IsNil(focused) then
		return false
	end

	local components = focused.gameObject:GetComponentsInChildren(typeof(CS.XGUI.UComponent), false)

	for i = 0, components.Length - 1 do
		if components[i].name == "UI_Com_RedTag_Reward" then
			return true
		end
	end

	return false
end

function BattlePassCtrl:refreshConsoleBarState()
	local focusRewards = self:_isFocusOnClaimableReward()

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_BP_Choose", focusRewards == false)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_BP_Claim", focusRewards == true)
end

function BattlePassCtrl:_refreshBPRotateConsoleBar()
	local isBP = self._currentTopTab == CashShopConst.CardShopType.BattlePass

	self:_setBPRotateConsoleBar(isBP)
end

function BattlePassCtrl:onCommonSwitchStateChanged()
	local view = self.view

	RechargeUtils.setupMoneyList(view.moneyListUButton)

	local monthCardOn = CommonSwitch.ShopMall_MonthlyCard == true

	if view.btnMonthCard then
		view.btnMonthCard.gameObject:SetActiveEx(monthCardOn)
	end

	if view.btnBP then
		view.btnBP.gameObject:SetActiveEx(monthCardOn)
	end

	if not monthCardOn and self._currentTopTab == CashShopConst.CardShopType.MonthCard then
		self:_switchToBattlePassTab()
	end
end

function BattlePassCtrl:onBpChange(data)
	local view = self.view
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local isCycleRewardUnlocked = actData.unlockCycleReward == 1

	if view.changeListBtn then
		view.changeListBtn.gameObject:SetActiveEx(isCycleRewardUnlocked)
	end

	local isNewCycleRewardUnlock = data and data.oldUnlockCycleReward ~= 1 and data.newUnlockCycleReward == 1
	local canShowCycleRewardList = isCycleRewardUnlocked and self:_canShowCycleRewardList(actData)

	if isNewCycleRewardUnlock and canShowCycleRewardList then
		self._showCycleRewardList = true
		self._cycleRewardGroupIndex = nil
	elseif not canShowCycleRewardList then
		self._showCycleRewardList = false
		self._cycleRewardGroupIndex = nil
	end

	if view.rootUComponent and isNewCycleRewardUnlock and canShowCycleRewardList then
		self:_setAwardItemPage(1)
	end

	local bpGear = actData.bpGear or 0

	if view.txtNameBuy then
		local buyKey

		buyKey = bpGear == ActivityConst.BattlePassGear.Free and "BATTLEPASS_BOTTOM_FREE" or bpGear == ActivityConst.BattlePassGear.Pay1 and "BATTLEPASS_BOTTOM_UNLOCKED1" or "BATTLEPASS_BOTTOM_UNLOCKED2"

		ClientTextUtils.setText(view.txtNameBuy, pg.getGameString(buyKey))
	end

	if view.lockUWidget then
		view.lockUWidget.gameObject:SetActiveEx(bpGear == ActivityConst.BattlePassGear.Free)
	end

	self:_refreshDynamicContent()
	CashShopRedDotUtils.refreshBattlePassRedDots()
	self:refreshmonthCard()
end

function BattlePassCtrl:_refreshDynamicContent()
	local view = self.view
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData or not self._bpData then
		return
	end

	local bpLevel = actData.bpLevel or 0
	local oldLevel = self._bpLevel or 0
	local isLevelUp = oldLevel < bpLevel

	self._bpLevel = bpLevel

	if not isLevelUp and self._bpProgressAnimPhase ~= "levelUp" then
		if view.txtCurLv then
			ClientTextUtils.setText(view.txtCurLv, tostring(bpLevel))
			ClientTextUtils.setText(view.textVXUSDFText, tostring(bpLevel))
		end

		if view.txtNewLv then
			ClientTextUtils.setText(view.txtNewLv, tostring(bpLevel))
		end
	end

	self:_refreshAwardList(view, self._bpData, actData, bpLevel, true, isLevelUp)
	self:_refreshLevelState(view, bpLevel)
end

function BattlePassCtrl:onShow()
	local view = self.view

	RechargeUtils.setupMoneyList(view.moneyListUButton)

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	if view.changeListBtn then
		view.changeListBtn.gameObject:SetActiveEx(actData.unlockCycleReward == 1)
	end

	view.rootUComponent:TryChangePage("Type", CashShopConst.CardShopType.BattlePass)

	if view.bgUWidget then
		view.bgUWidget.gameObject:SetActiveEx(false)
	end

	self._currentTopTab = CashShopConst.CardShopType.BattlePass

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]
	local bpLevel = actData.bpLevel or 0

	self._bpData = bpData
	self._bpLevel = bpLevel
	self._showCycleRewardList = actData.unlockCycleReward == 1 and self:_canShowCycleRewardList(actData, bpData)
	self._cycleRewardGroupIndex = nil

	local bpGear = actData.bpGear or 0
	local weeklyNum = actData.weeklyNum or 0

	for id, data in pairs(GameEventData) do
		if data.eventType == ActivityConst.EventType.BattlePass and phase == data.phase then
			self.eventId = id
		end
	end

	if view.btnBP then
		view.btnBP:SetSelected(true)
		self:_renderTabItem(view.btnBP, "BATTLEPASS_TOPTAB1")
		view.btnBP.gameObject:SetActiveEx(CommonSwitch.ShopMall_MonthlyCard == true)
	end

	if view.btnMonthCard then
		view.btnMonthCard:SetSelected(false)
		self:_renderTabItem(view.btnMonthCard, "BATTLEPASS_TOPTAB2")
		view.btnMonthCard.gameObject:SetActiveEx(CommonSwitch.ShopMall_MonthlyCard == true)
	end

	if view.txtBPName then
		ClientTextUtils.setText(view.txtBPName, pg.getGameString("BATTLEPASS_MAIN_TITLE"))
	end

	if view.txtLvUp then
		ClientTextUtils.setText(view.txtLvUp, pg.getGameString("BATTLEPASS_LEVELUP_TIPS"))
	end

	if view.txtTimeTitle then
		ClientTextUtils.setText(view.txtTimeTitle, pg.getGameString("BATTLEPASS_TIPS_DURATION"))
	end

	if view.txtRule then
		ClientTextUtils.setText(view.txtRule, pg.getGameString("BATTLEPASS_RULE_TITLE"))
	end

	if view.txtBPNormalName then
		ClientTextUtils.setText(view.txtBPNormalName, pg.getGameString("BATTLEPASS_SELLPAGE_LEFTTITLE"))
	end

	if view.txtBPAdvancedName then
		ClientTextUtils.setText(view.txtBPAdvancedName, pg.getGameString("BATTLEPASS_SELLPAGE_RIGHTTITLE"))
	end

	if view.txtLvMax then
		ClientTextUtils.setText(view.txtLvMax, pg.getGameString("BATTLEPASS_EXPMAX"))
	end

	if view.txtTaskWeek then
		ClientTextUtils.setText(view.txtTaskWeek, pg.getGameString("BATTLEPASS_MISSION_WEEKLY"))
	end

	if view.txtTaskSeason then
		ClientTextUtils.setText(view.txtTaskSeason, pg.getGameString("BATTLEPASS_MISSION_ONETIME"))
	end

	if view.txtBtnLvMax then
		ClientTextUtils.setText(view.txtBtnLvMax, pg.getGameString("BATTLEPASS_BUTTOM_LEVELMAX"))
	end

	if view.titleName then
		ClientTextUtils.setText(view.titleName, pg.getGameString("BATTLEPASS_MAIN_TITLE"))
	end

	if view.txtGetAllTask then
		ClientTextUtils.setText(view.txtGetAllTask, pg.getGameString("BATTLEPASS_MISSION_CLAIMALL"))
	end

	if view.txtExchange then
		ClientTextUtils.setText(view.txtExchange, pg.getGameString("BATTLEPASS_BOTTOM_GOSTORE"))
	end

	if view.txtExchangeGo then
		ClientTextUtils.setText(view.txtExchangeGo, pg.getGameString("BATTLEPASS_EXCHANGE_GO"))
	end

	if view.loopRewardTitleTxt then
		ClientTextUtils.setText(view.loopRewardTitleTxt, pg.getGameString("BATTLEPASS_LOOP_TITLE"))
	end

	if view.loopRewardDescTxt then
		ClientTextUtils.setText(view.loopRewardDescTxt, pg.getGameString("BATTLEPASS_LOOP_DESC"))
	end

	if view.txtNewLv then
		ClientTextUtils.setText(view.txtNewLv, tostring(bpLevel))
	end

	if view.txtCurLv then
		ClientTextUtils.setText(view.txtCurLv, tostring(bpLevel))
		ClientTextUtils.setText(view.textVXUSDFText, tostring(bpLevel))
	end

	if view.txtBtnBuy then
		ClientTextUtils.setText(view.txtBtnBuy, pg.getGameString("BATTLEPASS_BUYLEVEL"))
	end

	if view.txtNameBuy then
		local buyKey

		buyKey = bpGear == ActivityConst.BattlePassGear.Free and "BATTLEPASS_BOTTOM_FREE" or bpGear == ActivityConst.BattlePassGear.Pay1 and "BATTLEPASS_BOTTOM_UNLOCKED1" or "BATTLEPASS_BOTTOM_UNLOCKED2"

		ClientTextUtils.setText(view.txtNameBuy, pg.getGameString(buyKey))
	end

	if view.lockUWidget then
		view.lockUWidget.gameObject:SetActiveEx(bpGear == ActivityConst.BattlePassGear.Free)
	end

	if self.eventId and view.countDown then
		local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)

		if eventTimeCfg.tabEndDayTime then
			LuaUIUtils.setCountDownTime(view.countDown, eventTimeCfg.tabEndDayTime)
		end
	end

	view.rootUComponent:TryChangePage("testPayState", self._fromPreorderGuide and 1 or 0)

	if self._fromPreorderGuide then
		self:_switchToMonthCardTab()
	end

	if not bpData then
		return
	end

	self:_refreshLoopRewardCurrency()

	if view.btnUp then
		local weekRate = bpData.expWeekRaiseRates and bpData.expWeekRaiseRates[weeklyNum] or 0

		view.btnUp.gameObject:SetActiveEx(weekRate ~= 0)
	end

	self:_showBattlePassPet(CashShopConst.PetActionType.BattlePass)
	self:_refreshAwardList(view, bpData, actData, bpLevel)
	self:_refreshLevelState(view, bpLevel)
	self:_setupBPTypeTabs(view, bpData)
	self:_setupTaskTabs(view, bpData, weeklyNum)
	self:_selectInitialTab()

	if view.btnDailyUButton then
		view.btnDailyUButton.gameObject:SetActiveEx(false)
	end

	self._hasEnteredOnce = true

	self:_scheduleFocusCurrentTabList()
	self:_refreshBPRotateConsoleBar()
end

function BattlePassCtrl:_refreshLoopRewardCurrency()
	local view = self.view

	if not view or not view.currencyItemUButton then
		return
	end

	local seasonStage = Utils.getCurrentSeasonStage()
	local currencyId = seasonStage and seasonStage.seasonCoinId

	if currencyId then
		LuaUIUtils.setTopCurrencyItem(view.currencyItemUButton, currencyId)
	end
end

function BattlePassCtrl:_canShowCycleRewardList(actData, bpData)
	actData = actData or ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData or actData.unlockCycleReward ~= 1 then
		return false
	end

	if not bpData then
		local phase = actData.activityBase and actData.activityBase.activityPhase

		bpData = phase and BattlePassData[phase] or self._bpData
	end

	if not bpData or not bpData.awardTaskGroupId then
		return false
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(bpData.awardTaskGroupId) or {}

	for _, taskId in ipairs(taskIds) do
		if ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			return false
		end
	end

	return true
end

function BattlePassCtrl:_renderTabItem(btn, txt)
	local objectReference = btn.transform:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("name1")
	local nameSelectText = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(nameText, pg.getGameString(txt))
	ClientTextUtils.setText(nameSelectText, pg.getGameString(txt))
end

function BattlePassCtrl:_stopBpProgressAnimation()
	self._bpProgressAnimVersion = (self._bpProgressAnimVersion or 0) + 1
	self._bpProgressAnimPhase = nil

	if self.view and self.view.progressLv then
		self.view.progressLv:KillProcessAnim()
	end
end

function BattlePassCtrl:_tryPlayDeferredBpProgressAnimation()
	local deferred = self._bpProgressDeferred
	local view = self.view
	local progress = view and view.progressLv

	if not deferred or not progress or not progress.gameObject.activeInHierarchy then
		return
	end

	self._bpProgressDeferred = nil

	self:_refreshBpProgress(view, deferred.targetProgress, deferred.targetLevel, true, deferred.isLevelUp)
end

function BattlePassCtrl:_refreshBpProgress(view, targetProgress, targetLevel, animateProgress, isLevelUp)
	local progress = view.progressLv

	if not progress then
		return
	end

	local previousTarget = self._bpProgressTarget
	local previousPhase = self._bpProgressAnimPhase

	if animateProgress and not isLevelUp and previousTarget == targetProgress then
		return
	end

	if animateProgress and previousTarget ~= nil and not progress.gameObject.activeInHierarchy then
		self._bpProgressDeferred = {
			targetProgress = targetProgress,
			targetLevel = targetLevel,
			isLevelUp = isLevelUp or previousPhase == "levelUp"
		}

		return
	end

	self._bpProgressDeferred = nil
	self._bpProgressTarget = targetProgress
	self._bpProgressAnimVersion = (self._bpProgressAnimVersion or 0) + 1

	local version = self._bpProgressAnimVersion

	local function isValid()
		return version == self._bpProgressAnimVersion and self.view == view and view.progressLv == progress
	end

	local playLevelUpProgress = isLevelUp or previousPhase == "levelUp"

	local function showFinalLevel()
		if view.txtCurLv then
			ClientTextUtils.setText(view.txtCurLv, tostring(targetLevel))
			ClientTextUtils.setText(view.textVXUSDFText, tostring(targetLevel))
		end

		if view.txtNewLv then
			ClientTextUtils.setText(view.txtNewLv, tostring(targetLevel))
		end

		if playLevelUpProgress then
			if view.eXPUWidget then
				view.eXPUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom6)
			end

			self:onBattlePassLevelUp({
				bpLevel = targetLevel
			})
		end
	end

	local function setImmediately()
		self._bpProgressAnimPhase = nil

		progress:ProgressToValue(targetProgress, nil, 0)

		if playLevelUpProgress then
			showFinalLevel()
		end
	end

	if not animateProgress or previousTarget == nil then
		setImmediately()

		return
	end

	if not playLevelUpProgress and targetProgress <= previousTarget then
		setImmediately()

		return
	end

	if previousPhase == nil then
		progress:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	local function onProgressFinished()
		if not isValid() then
			return
		end

		self._bpProgressAnimPhase = nil

		if progress.gameObject.activeInHierarchy then
			progress:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end
	end

	local function growToFinalProgress()
		if not isValid() then
			return
		end

		self._bpProgressAnimPhase = "final"

		if targetProgress > progress.value and progress.gameObject.activeInHierarchy then
			progress:ProgressToValue(targetProgress, onProgressFinished, PROGRESS_GROW_DURATION)
		else
			progress:ProgressToValue(targetProgress, nil, 0)
			onProgressFinished()
		end
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
			progress:ProgressToValue(1, onProgressFull, PROGRESS_GROW_DURATION)
		else
			onProgressFull()
		end
	else
		self._bpProgressAnimPhase = "normal"

		progress:ProgressToValue(targetProgress, onProgressFinished, PROGRESS_GROW_DURATION)
	end
end

function BattlePassCtrl:_refreshAwardList(view, bpData, actData, bpLevel, animateProgress, isLevelUp)
	local taskIds = ActivityUtils.getActTaskIdsByGroupId(bpData.awardTaskGroupId)
	local freeTasks = {}
	local payTasks = {}

	for _, taskId in ipairs(taskIds) do
		local cfg = EventTaskData[taskId]

		if cfg then
			local entry = {
				taskId = taskId,
				cfg = cfg,
				actData = ActivityUtils.getActTaskData(pg.me, taskId)
			}

			if cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardFree then
				freeTasks[#freeTasks + 1] = entry
			elseif cfg.actTaskType == ActivityConst.ActivityTaskType.BattlePass_AwardPay then
				payTasks[#payTasks + 1] = entry
			end
		end
	end

	table.sort(freeTasks, function(a, b)
		return (a.cfg.sort or 1) < (b.cfg.sort or 1)
	end)
	table.sort(payTasks, function(a, b)
		return (a.cfg.sort or 1) < (b.cfg.sort or 1)
	end)

	local fixedRewardMaxLevel = math.max(#freeTasks, #payTasks)
	local isCycleRewardUnlocked = actData.unlockCycleReward == 1
	local levelLimit = self:_getBattlePassLevelLimit()
	local isMaxLevel = levelLimit > 0 and levelLimit <= bpLevel

	self._fixedRewardMaxLevel = fixedRewardMaxLevel
	self._isCycleRewardUnlocked = isCycleRewardUnlocked

	local bpExp = actData.bpExp or 0
	local expPerLv = bpData.passExperienceLimit or 0

	if view.progressLv then
		local targetProgress = isMaxLevel and 1 or expPerLv > 0 and math.min(1, bpExp / expPerLv) or 0

		self:_refreshBpProgress(view, targetProgress, bpLevel, animateProgress, isLevelUp)
	end

	if view.txtLvExp then
		local displayBpExp = isMaxLevel and expPerLv or bpExp

		ClientTextUtils.setText(view.txtLvExp, pg.getFormatText(pg.getGameString("BATTLEPASS_EXP_LEVELUP"), displayBpExp))
	end

	if view.txtExpLimit then
		local weekExpCur = actData.addBpExpTotalWeekly or 0
		local weekExpTex = pg.getFormatText(pg.getGameString("BATTLEPASS_EXP_CURRENT"), weekExpCur)

		ClientTextUtils.setText(view.txtExpLimit, pg.getGameString("BATTLEPASS_EXP_LIMITS"), weekExpTex)
	end

	if view.listUList then
		local listData = {}

		if isCycleRewardUnlocked and self._showCycleRewardList then
			listData = self:_buildCycleRewardListData(bpData, actData, bpLevel, fixedRewardMaxLevel)
		else
			for i = 1, fixedRewardMaxLevel do
				listData[i] = {
					level = i,
					freeTask = freeTasks[i],
					payTask = payTasks[i],
					bpLevel = bpLevel
				}
			end

			self._listStartLevel = 1
		end

		self._specialNodes = {}

		for _, item in ipairs(listData) do
			local hasSpec = item.freeTask and item.freeTask.cfg and item.freeTask.cfg.specShow or item.payTask and item.payTask.cfg and item.payTask.cfg.specShow

			if hasSpec then
				self._specialNodes[#self._specialNodes + 1] = item
			end
		end

		self._listTotalCount = #listData

		view.listUList:SetList(listData)
		self:_refreshAwardItemPage()
		self:_refreshCycleRewardChangeButtons()

		if self._onListScroll then
			view.listUList:UnRegisterToScrollEvent(self._onListScroll)
		end

		function self._onListScroll(pos)
			self:_updateSpecialNodeDisplay(pos.x)
			self:_refreshLeftBtnVisibility()
		end

		view.listUList:RegisterToScrollEvent(self._onListScroll)
		self:startFrameTimer(function()
			if self._showCycleRewardList then
				self:_scrollToLeft(view.listUList, 0, true)
			else
				self:_scrollToLeft(view.listUList, self:_getAwardListIndex(bpLevel), true)
				self:_updateSpecialNodeDisplay(nil, bpLevel)
			end

			self:_refreshLeftBtnVisibility()
			self:refreshConsoleBarState()
		end, 1)
	end
end

function BattlePassCtrl:_buildCycleRewardListData(bpData, actData, bpLevel, fixedRewardMaxLevel)
	local freeLoopRewards = bpData.freeLoopReward or {}
	local advancedLoopRewards = bpData.advancedLoopReward or {}
	local rewardCount = #freeLoopRewards

	if rewardCount <= 0 then
		self._cycleRewardGroupIndex = 1
		self._cycleRewardGroupCount = 1
		self._listStartLevel = 1

		return {}
	end

	local bpMaxLevel = SysConfigData.BATTLE_PASS_LEVEL_UP_MAX or fixedRewardMaxLevel
	local cycleRewardTotalCount = math.max(rewardCount, (actData.cycleRewardShowMaxlv or 0) - bpMaxLevel)
	local groupCount = math.max(1, math.ceil(cycleRewardTotalCount / rewardCount))

	self._cycleRewardTotalCount = cycleRewardTotalCount

	if not self._cycleRewardGroupIndex then
		self._cycleRewardGroupIndex = groupCount
	end

	self._cycleRewardGroupIndex = math.max(1, math.min(groupCount, self._cycleRewardGroupIndex))
	self._cycleRewardGroupCount = groupCount

	local groupStartLevel = (self._cycleRewardGroupIndex - 1) * rewardCount + 1
	local listData = {}

	for rewardIndex = 1, rewardCount do
		local cycleLevel = groupStartLevel + rewardIndex - 1
		local rewardLevel = bpMaxLevel + cycleLevel
		local freeState, payState = actData:getCycleRewardState(rewardLevel)

		listData[#listData + 1] = {
			isCycleReward = true,
			level = rewardLevel,
			rewardLevel = rewardLevel,
			bpLevel = bpLevel or 0,
			freeRewardId = freeLoopRewards[rewardIndex],
			payRewardId = advancedLoopRewards[rewardIndex],
			freeState = self:_getRewardDisplayState(freeState),
			payState = self:_getRewardDisplayState(payState)
		}
	end

	self._listStartLevel = bpMaxLevel + groupStartLevel

	return listData
end

function BattlePassCtrl:_refreshAwardListByCurrentMode()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData or not self._bpData then
		return
	end

	self:_refreshAwardList(self.view, self._bpData, actData, actData.bpLevel or 0)
end

function BattlePassCtrl:_changeCycleRewardGroup(offset)
	if not self._showCycleRewardList then
		return
	end

	local targetGroup = (self._cycleRewardGroupIndex or 1) + offset

	if targetGroup < 1 or targetGroup > (self._cycleRewardGroupCount or 1) then
		return
	end

	self._cycleRewardGroupIndex = targetGroup

	self:_refreshAwardListByCurrentMode()
end

function BattlePassCtrl:_refreshAwardItemPage()
	if self._showCycleRewardList then
		self:_setAwardItemPage(1)
	else
		self:_setAwardItemPage(0)
	end
end

function BattlePassCtrl:_getAwardListIndex(level)
	local total = self._listTotalCount or 0

	if total <= 0 then
		return 0
	end

	local index = (level or 0) - (self._listStartLevel or 1)

	return math.max(0, math.min(total - 1, index))
end

function BattlePassCtrl:_refreshCycleRewardChangeButtons()
	local view = self.view
	local isCycleList = self._showCycleRewardList == true
	local groupIndex = self._cycleRewardGroupIndex or 1
	local groupCount = self._cycleRewardGroupCount or 1
	local canTurnLeft = isCycleList and groupIndex > 1
	local canTurnRight = isCycleList and groupIndex < groupCount

	if view.buttonLeftUButton then
		view.buttonLeftUButton:TryChangePage("Type", canTurnLeft and 0 or 1)

		view.buttonLeftUButton.interactable = canTurnLeft
	end

	if view.buttonRightUButton then
		view.buttonRightUButton:TryChangePage("Type", canTurnRight and 0 or 1)

		view.buttonRightUButton.interactable = canTurnRight
	end
end

function BattlePassCtrl:_setAwardItemPage(itemPage)
	self._awardItemPage = itemPage

	local view = self.view

	if view.rootUComponent then
		view.rootUComponent:TryChangePage("Item", itemPage)
	end

	if self._isCycleRewardUnlocked and view.changeListBtn then
		view.changeListBtn:TryChangePage("Type", itemPage == 1 and 0 or 1)
	end

	if view.changeListBtnHotKeyContent then
		if itemPage == 1 then
			view.changeListBtn:SetGamepadAction("Raw/GamepadDPadLeft", view.changeListBtnHotKeyContent.gameObject)
		else
			view.changeListBtn:SetGamepadAction("Raw/GamepadDPadRight", view.changeListBtnHotKeyContent.gameObject)
		end
	end
end

function BattlePassCtrl:_scrollToLeft(list, targetIdx, instant)
	list:GoToIndex(targetIdx, instant)
end

function BattlePassCtrl:_refreshLeftBtnVisibility()
	local view = self.view

	if not view or not view.btnLeftUButton then
		return
	end

	if self._showCycleRewardList then
		view.btnLeftUButton.gameObject:SetActiveEx(false)

		return
	end

	local bpLevel = self._bpLevel or 0
	local total = self._listTotalCount or 0

	if bpLevel <= 0 or total <= 0 or not view.listUList then
		view.btnLeftUButton.gameObject:SetActiveEx(false)

		return
	end

	local targetIdx = self:_getAwardListIndex(bpLevel)
	local ok, minIdx, maxIdx = view.listUList:TryGetVisualRange()
	local inView = ok and minIdx <= targetIdx and targetIdx <= maxIdx

	view.btnLeftUButton.gameObject:SetActiveEx(not inView)
end

function BattlePassCtrl:_scheduleFocusCurrentTabList()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self._focusTabTimer then
		TimerManager.delFrameCb(self._focusTabTimer)

		self._focusTabTimer = nil
	end

	self._focusTabTimer = self:startFrameTimer(function()
		self._focusTabTimer = nil

		if not self.view then
			return
		end

		self:_focusCurrentTabList()
	end, 2)
end

function BattlePassCtrl:_focusCurrentTabList()
	local view = self.view
	local navMgr = pg.global.navMgr

	if not view or not navMgr or not pg.game.input:isUsingGamepad() then
		return
	end

	if self._currentBPKind == 1 then
		if view.listTask then
			navMgr:FocusItemInThis(view.listTask)
		end

		return
	end

	if not view.listUList then
		return
	end

	local ok, minIdx = view.listUList:TryGetVisualRange()
	local leftIdx = ok and minIdx or 0
	local okChild, leftBtn = view.listUList:TryGetChildAt(leftIdx)

	if okChild and leftBtn then
		navMgr:FocusItemInThis(leftBtn)
	else
		navMgr:FocusItemInThis(view.listUList)
	end
end

function BattlePassCtrl:_updateSpecialNodeDisplay(normalizedX, refLevel)
	local view = self.view

	if self._showCycleRewardList then
		self:_setAwardItemPage(1)

		return
	end

	if not view.itemObjectReference then
		return
	end

	local specNodes = self._specialNodes

	if not specNodes or #specNodes == 0 then
		self:_setAwardItemPage(2)

		return
	end

	local totalCount = self._listTotalCount or 0

	if totalCount == 0 then
		return
	end

	local firstVisibleLevel, lastVisibleLevel

	if view.listUList then
		local ok, minIdx, maxIdx = view.listUList:TryGetVisualRange()

		if ok then
			firstVisibleLevel = (self._listStartLevel or 1) + minIdx
			lastVisibleLevel = (self._listStartLevel or 1) + maxIdx
		end
	end

	if not lastVisibleLevel and refLevel then
		firstVisibleLevel = refLevel
		lastVisibleLevel = refLevel
	end

	if not lastVisibleLevel then
		local scrollRatio = math.max(0, math.min(1, normalizedX or 0))

		lastVisibleLevel = (self._listStartLevel or 1) + math.floor(scrollRatio * totalCount)
		firstVisibleLevel = lastVisibleLevel
	end

	local lastSpecialNode = specNodes[#specNodes]

	if firstVisibleLevel <= lastSpecialNode.level and lastVisibleLevel >= lastSpecialNode.level then
		self:_setAwardItemPage(2)

		return
	end

	self:_setAwardItemPage(0)

	local targetNode

	for _, node in ipairs(specNodes) do
		if lastVisibleLevel < node.level then
			targetNode = node

			break
		end
	end

	targetNode = targetNode or specNodes[#specNodes]

	if targetNode then
		self:renderItem(view.itemObjectReference, 0, targetNode)
	end
end

function BattlePassCtrl:_setupBPTypeTabs(view, bpData)
	if not view.listBPType then
		return
	end

	local icons = bpData and bpData.passRewardMissionIcon
	local tabDefs = {
		{
			kind = 0,
			textKey = "BATTLEPASS_LEFTTAB_REWARDS",
			icon = icons and icons[1]
		},
		{
			kind = 1,
			textKey = "BATTLEPASS_LEFTTAB_MISSIONS",
			icon = icons and icons[2]
		}
	}

	self._bpTypeButtons = {}
	self._bpTypeTabDefs = tabDefs

	function view.listBPType.luaRenderItem(btn, idx, data)
		self._bpTypeButtons[idx + 1] = btn

		local objectReference = btn:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		local textName = objectReference:GetRefValue("textUBaseText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local text = pg.getGameString(data.textKey)

		if textName then
			ClientTextUtils.setText(textName, text)
		end

		if iconUImage and data.icon then
			iconUImage.url = data.icon
		end
	end

	view.listBPType:SetList(tabDefs)
	self:_selectBPTypeByKind(0)

	if self._bpTypeButtons[1] then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.BATTLEPASS_AWARD_TAB, self._bpTypeButtons[1], function()
			return CashShopRedDotUtils.hasClaimableAwardTask() and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
		end)
	end

	if self._bpTypeButtons[2] then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.BATTLEPASS_TASK_TAB, self._bpTypeButtons[2], function()
			return CashShopRedDotUtils.getTaskTabRedDotStyle()
		end)
	end
end

function BattlePassCtrl:_selectBPTypeByKind(kind)
	local view = self.view

	if not view or not view.listBPType then
		return
	end

	local tabDefs = self._bpTypeTabDefs

	if not tabDefs then
		return
	end

	for i, def in ipairs(tabDefs) do
		if def.kind == kind then
			view.listBPType:SelectItem(i - 1, false)
			view.listBPType:SetUListSwitchCurrentIndex(i - 1)

			return
		end
	end
end

function BattlePassCtrl:_switchBPKind(kind)
	self._currentBPKind = kind

	self.view.rootUComponent:TryChangePage("Kind", kind)
	self:_tryPlayDeferredBpProgressAnimation()
	self:_selectBPTypeByKind(kind)

	if kind == 1 and self._refreshCurrentTaskTab then
		self._refreshCurrentTaskTab()
	end
end

function BattlePassCtrl:_setupTaskTabs(view, bpData, weeklyNum)
	self._isWeeklyTaskTab = true

	local function selectAndRefresh(isWeekly)
		self._isWeeklyTaskTab = isWeekly

		local isTaskKind = self._currentBPKind == 1

		if view.btnDailyUButton then
			view.btnDailyUButton.gameObject:SetActiveEx(isWeekly and isTaskKind)
		end

		if view.tabTaskWeek then
			view.tabTaskWeek:SetSelected(isWeekly)
		end

		if view.tabTaskSeason then
			view.tabTaskSeason:SetSelected(not isWeekly)
		end

		if not view.listTask then
			return
		end

		self._taskEndTimeTexts = {}

		local taskList = self.model:getBpTaskList(bpData, weeklyNum, isWeekly)

		if isWeekly then
			table.insert(taskList, {
				tIndex = 1
			})
		end

		view.listTask:SetList(taskList)

		if view.btnAllGet then
			local isMaxLevel = CashShopRedDotUtils.isBattlePassMaxLevel()
			local hasReceivable = false

			if not isMaxLevel then
				for _, item in ipairs(taskList) do
					if item.taskState == ActivityConst.TaskState.Finihed_CanRecv then
						hasReceivable = true

						break
					end
				end
			end

			view.btnAllGet.gameObject:SetActiveEx(hasReceivable)
		end
	end

	function self._refreshCurrentTaskTab()
		selectAndRefresh(self._isWeeklyTaskTab)
	end

	self._switchTaskTab = selectAndRefresh

	selectAndRefresh(true)

	if view.tabTaskWeek then
		function view.tabTaskWeek.luaClick()
			selectAndRefresh(true)
		end

		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.BATTLEPASS_TASK_WEEK_TAB, view.tabTaskWeek, function()
			return CashShopRedDotUtils.getWeeklyTaskTabRedDotStyle()
		end)
	end

	if view.tabTaskSeason then
		function view.tabTaskSeason.luaClick()
			selectAndRefresh(false)
		end

		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.BATTLEPASS_TASK_SEASON_TAB, view.tabTaskSeason, function()
			return CashShopRedDotUtils.getSeasonTaskTabRedDotStyle()
		end)
	end
end

function BattlePassCtrl:_selectInitialTab()
	if CashShopRedDotUtils.hasClaimableSeasonTask() then
		if self._switchBPKind then
			self:_switchBPKind(1)
		end

		if self._switchTaskTab then
			self._switchTaskTab(false)
		end
	elseif CashShopRedDotUtils.hasClaimableWeeklyTask() then
		if self._switchBPKind then
			self:_switchBPKind(1)
		end

		if self._switchTaskTab then
			self._switchTaskTab(true)
		end
	elseif self._switchBPKind then
		self:_switchBPKind(0)
	end
end

function BattlePassCtrl:receiveReward(data)
	if not data then
		return
	end

	if data.isCycleReward then
		self:receiveCycleReward()
	else
		self:receiveAwardByLevel()
	end
end

function BattlePassCtrl:_hideRewardItemTag(button)
	if not button then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local tagUWidget = objectReference and objectReference:GetRefValue("tagUWidget")

	if tagUWidget then
		tagUWidget.gameObject:SetActiveEx(false)
	end
end

function BattlePassCtrl:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local listUList = objectReference:GetRefValue("listUList")
	local lockUWidget = objectReference:GetRefValue("lockUWidget")
	local itemGetUComponent = objectReference:GetRefValue("itemGetUComponent")
	local canReceiveReward = false

	if textUBaseText then
		ClientTextUtils.setText(textUBaseText, tostring(data.level))
	end

	if itemGetUComponent and (data.freeTask or data.freeRewardId) then
		local dropId = data.isCycleReward and data.freeRewardId or data.freeTask.cfg and data.freeTask.cfg.award
		local rewardList = dropId and LuaUIUtils.getRewardItemByDropId(dropId) or {}
		local firstReward = rewardList[1]
		local freeState = data.isCycleReward and data.freeState or self:_getTaskDisplayState(data.freeTask.taskId)

		canReceiveReward = canReceiveReward or freeState == 2

		if firstReward then
			LuaUIUtils.renderRewardItem(itemGetUComponent, firstReward)
			self:_hideRewardItemTag(itemGetUComponent)

			if freeState == 2 then
				function itemGetUComponent.luaClick()
					self:receiveReward(data)
				end
			end
		end

		itemGetUComponent:TryChangePage("State", freeState)

		local rewardLevel = data.rewardLevel or data.level
		local freePath = string.format(RedDotConst.RedDotPath.BATTLEPASS_AWARD_FREE_ITEM, rewardLevel)

		pg.global.setRedDot(freePath, itemGetUComponent, freeState == 2, RedDotConst.RedDotStyle.REWARD)
	end

	if listUList and (data.payTask or data.payRewardId) then
		local dropId = data.isCycleReward and data.payRewardId or data.payTask.cfg and data.payTask.cfg.award
		local rewardList = dropId and LuaUIUtils.getRewardItemByDropId(dropId) or {}
		local payState = data.isCycleReward and data.payState or self:_getTaskDisplayState(data.payTask.taskId)

		canReceiveReward = canReceiveReward or payState == 2

		local rewardLevel = data.rewardLevel or data.level
		local payPath = string.format(RedDotConst.RedDotPath.BATTLEPASS_AWARD_PAY_ITEM, rewardLevel)

		function listUList.luaRenderItem(btn, _, d)
			LuaUIUtils.renderRewardItem(btn, d)
			self:_hideRewardItemTag(btn)

			if payState == 2 then
				function btn.luaClick()
					self:receiveReward(data)
				end
			end

			btn:TryChangePage("State", payState)
			pg.global.setRedDot(payPath, btn, payState == 2, RedDotConst.RedDotStyle.REWARD)
		end

		listUList:SetList(rewardList)
	end

	if lockUWidget then
		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
		local bpGear = actData and actData.bpGear or 0

		lockUWidget.gameObject:SetActiveEx(bpGear < ActivityConst.BattlePassGear.Pay1)
	end

	if data.isCycleReward or not canReceiveReward then
		button.luaClick = nil
	else
		function button.luaClick()
			self:receiveReward(data)
		end
	end

	button:TryChangePage("Status", data.level == data.bpLevel and 1 or 0)
end

function BattlePassCtrl:_getRewardDisplayState(state)
	if state == ActivityConst.TaskState.Finihed_CanRecv then
		return 2
	elseif state == ActivityConst.TaskState.Received or state == ActivityConst.TaskState.Received_SendMail then
		return 1
	end

	return 0
end

function BattlePassCtrl:_getTaskDisplayState(taskId)
	return self:_getRewardDisplayState(ActivityUtils.getActTaskState(pg.me, taskId))
end

function BattlePassCtrl:_receiveAllTaskReward()
	local bpData = self._bpData

	if not bpData then
		return
	end

	local groupId

	if self._isWeeklyTaskTab then
		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
		local weeklyNum = actData and actData.weeklyNum or 0

		groupId = bpData.weekTaskGroupId and bpData.weekTaskGroupId[weeklyNum]
	else
		groupId = bpData.seasonTaskGroupId
	end

	if groupId then
		self:_requestGroupTaskReward(groupId)
	end
end

function BattlePassCtrl:receiveCycleReward()
	if self._cycleRewardRequestPending then
		return
	end

	self._cycleRewardRequestPending = true

	pg.me:serverMsg("RPC_CS_ReceiveBpCycleReward", function(resCode)
		self._cycleRewardRequestPending = false

		if resCode == 0 then
			self:_refreshAwardListByCurrentMode()
			CashShopRedDotUtils.refreshBattlePassRedDots()
		end
	end)
end

function BattlePassCtrl:receiveAwardByLevel()
	if not self.eventId or not self._bpData then
		return
	end

	local taskIds = ActivityUtils.getActTaskIdsByGroupId(self._bpData.awardTaskGroupId)
	local itemList = {}
	local idIndex = {}
	local hasSpecialNode = false
	local hasClaimableReward = false

	for _, taskId in ipairs(taskIds) do
		if ActivityUtils.getActTaskState(pg.me, taskId) == ActivityConst.TaskState.Finihed_CanRecv then
			hasClaimableReward = true

			local cfg = EventTaskData[taskId]

			if cfg and cfg.award then
				hasSpecialNode = hasSpecialNode or cfg.specShow == 1

				local rewards = LuaUIUtils.getRewardItemByDropId(cfg.award)

				if rewards then
					for _, item in ipairs(rewards) do
						if item.id then
							local existIdx = idIndex[item.id]

							if existIdx then
								itemList[existIdx].num = (itemList[existIdx].num or 0) + (item.num or 0)
							else
								itemList[#itemList + 1] = {
									id = item.id,
									num = item.num
								}
								idIndex[item.id] = #itemList
							end
						else
							itemList[#itemList + 1] = {
								id = item.id,
								num = item.num
							}
						end
					end
				end
			end
		end
	end

	if not hasClaimableReward then
		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local bpGear = actData and actData.bpGear or 0

	if bpGear <= ActivityConst.BattlePassGear.Free and hasSpecialNode and #itemList > 0 then
		pg.global.ui:open(UIConst.UI_ID_BP_OBTAIN, {
			itemList = itemList
		})
	end

	self:_requestGroupTaskReward(self._bpData.awardTaskGroupId)
end

function BattlePassCtrl:_stopTaskEndTimeTimer()
	if self._taskEndTimeTimer then
		self:killTimer(self._taskEndTimeTimer)

		self._taskEndTimeTimer = nil
	end

	self._taskEndTimeTexts = nil
end

function BattlePassCtrl:_refreshTaskEndTimeTexts()
	local endTimeTexts = self._taskEndTimeTexts

	if not endTimeTexts then
		return
	end

	local now = Time.secondCache
	local hasActiveCountdown = false
	local hasExpiredTask = false

	for text, endTime in pairs(endTimeTexts) do
		local remainTime = endTime - now

		if remainTime > 0 then
			hasActiveCountdown = true

			ClientTextUtils.setText(text, LuaUIUtils.getCountDownString(remainTime, UIConst.TimeType.Short, true))
		else
			hasExpiredTask = true
		end
	end

	if hasExpiredTask then
		self._taskEndTimeTexts = {}

		if self._refreshCurrentTaskTab then
			self._refreshCurrentTaskTab()
		end

		CashShopRedDotUtils.refreshBattlePassRedDots()
	elseif not hasActiveCountdown then
		self:_stopTaskEndTimeTimer()
	end
end

function BattlePassCtrl:_registerTaskEndTimeText(text, endTime)
	if not text or not endTime then
		return
	end

	self._taskEndTimeTexts = self._taskEndTimeTexts or {}
	self._taskEndTimeTexts[text] = endTime

	local remainTime = math.max(0, endTime - Time.secondCache)

	ClientTextUtils.setText(text, LuaUIUtils.getCountDownString(remainTime, UIConst.TimeType.Short, true))

	if not self._taskEndTimeTimer then
		self._taskEndTimeTimer = self:startTimer(function()
			self:_refreshTaskEndTimeTexts()
		end, 1, true)
	end
end

function BattlePassCtrl:renderTaskItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local icon = objectReference:GetRefValue("icon")
	local txtNum = objectReference:GetRefValue("txtNum")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local txtPro = objectReference:GetRefValue("txtPro")
	local btnArrow = objectReference:GetRefValue("btnArrow")
	local btnGift = objectReference:GetRefValue("btnGift")
	local txtGoingText = objectReference:GetRefValue("txtGoingText")
	local txtBtnArrow = objectReference:GetRefValue("txtBtnArrow")
	local txtBtnGift = objectReference:GetRefValue("txtBtnGift")
	local endTimeTxt = objectReference:GetRefValue("endTimeTxt")
	local cfg = data.cfg
	local state = data.taskState or ActivityUtils.getActTaskState(pg.me, data.taskId)
	local endTime = cfg and Utils.getConfigTimeOfArea(cfg, "taskEndDayTime")

	if rootUComponent then
		rootUComponent:TryChangePage("Time", 0)
	end

	if endTimeTxt then
		if endTime then
			self:_registerTaskEndTimeText(endTimeTxt, endTime)
		else
			if self._taskEndTimeTexts then
				self._taskEndTimeTexts[endTimeTxt] = nil
			end

			ClientTextUtils.setText(endTimeTxt, "")
		end
	end

	local statusPage

	if state == ActivityConst.TaskState.Finihed_CanRecv then
		statusPage = 1

		if txtBtnGift then
			ClientTextUtils.setText(txtBtnGift, pg.getGameString("BP_MISSION_GET_REWARD"))
		end
	elseif state == ActivityConst.TaskState.Received or state == ActivityConst.TaskState.Received_SendMail then
		statusPage = 2
	elseif not cfg.event then
		statusPage = 3
	else
		statusPage = 0

		ClientTextUtils.setText(txtBtnArrow, pg.getGameString("BP_GOPOS_MISSION"))
	end

	if rootUComponent then
		rootUComponent:TryChangePage("status", statusPage)
	end

	if icon and cfg then
		icon.url = cfg.eventIcon
	end

	if txtNum and cfg and cfg.award then
		local rewardList = LuaUIUtils.getRewardItemByDropId(cfg.award)
		local firstReward = rewardList and rewardList[1]

		if firstReward then
			ClientTextUtils.setText(txtNum, pg.getFormatText(pg.getGameString("BATTLEPASS_MISSION_ADDEXP"), firstReward.num or 1))
		end
	end

	if txtDesc and cfg and cfg.taskDes then
		ClientTextUtils.setText(txtDesc, pg.getLocalizationText(cfg.taskDes))
	end

	if txtPro and cfg and cfg.taskCondition then
		local isComplete = state and state >= ActivityConst.TaskState.Finihed_CanRecv
		local finishCnt = pg.me.triggerMap:getConditionTargetCount(cfg.taskCondition, 1)
		local curCnt = isComplete and finishCnt or pg.me.triggerMap:getConditionFinishCount(cfg.taskCondition, 1)

		ClientTextUtils.setText(txtPro, pg.getFormatText(pg.getGameString("BP_ONGOING_MISSION"), curCnt, finishCnt))

		if txtGoingText then
			ClientTextUtils.setText(txtGoingText, pg.getFormatText(pg.getGameString("BP_ONGOING_MISSION"), curCnt, finishCnt))
		end
	end

	local canReceive = state == ActivityConst.TaskState.Finihed_CanRecv
	local taskId = data.taskId
	local isReceived = state == ActivityConst.TaskState.Received or state == ActivityConst.TaskState.Received_SendMail

	if btnArrow then
		btnArrow.luaClick = function()
			if canReceive and taskId then
				self:_requestTaskReward(taskId)
			elseif cfg.event and not isReceived then
				pg.me:doEvent(cfg.event)
			end
		end or nil
	end

	if btnGift then
		btnGift.luaClick = canReceive and taskId and function()
			self:_requestTaskReward(taskId)
		end or nil

		if taskId then
			local taskPath = string.format(RedDotConst.RedDotPath.BATTLEPASS_TASK_ITEM, taskId)

			pg.global.setRedDot(taskPath, btnGift, canReceive, RedDotConst.RedDotStyle.POINT)
		end
	end
end

function BattlePassCtrl:renderGoToItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDailyUBaseText = objectReference:GetRefValue("txtDailyUBaseText")
	local txtDailyGoToTitleText = objectReference:GetRefValue("txtDailyGoToTitleText")
	local btnDailyUButton = objectReference:GetRefValue("btnDailyUButton")

	if txtDailyUBaseText then
		ClientTextUtils.setText(txtDailyUBaseText, pg.getGameString("BATTLEPASS_DAILYNOTES"))
	end

	if txtDailyGoToTitleText then
		ClientTextUtils.setText(txtDailyGoToTitleText, pg.getGameString("BP_GOPOS_MISSION"))
	end

	if btnDailyUButton then
		function btnDailyUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_EVENT_SCHOOL_GUIDE, {
				1
			})
		end
	end
end

function BattlePassCtrl:onHide()
	self:_stopBpProgressAnimation()
	self:_stopTaskEndTimeTimer()
end

function BattlePassCtrl:onVisibleChange(visible)
	if self.avatarComponent then
		if visible then
			self.avatarComponent:registerGesture(self.view and self.view.maskRayBoxTrans)
		else
			self.avatarComponent:unRegisterGesture()
		end
	end

	if visible then
		if self._hasEnteredOnce then
			self:showEnterAnim()
		end

		self:_refreshBPRotateConsoleBar()
		self:_tryPlayDeferredBpProgressAnimation()
	else
		self:_setBPRotateConsoleBar(false)
	end
end

function BattlePassCtrl:onShowGiftFriendList(data)
	if not self.friendComponent then
		return
	end

	self.friendComponent.gameObject:SetActiveEx(true)
	self.friendComponent:refreshFriendList(FriendNewComponent.OpenType.CashShop, {
		giftCommodityId = data and data.commodityId,
		productInfo = data and data.productInfo,
		hasGiftMap = data and data.hasGiftMap
	})

	local navMgr = pg.global.navMgr

	if navMgr and pg.game.input:isUsingGamepad() then
		navMgr:FocusItemInThis(self.friendComponent.uWidget, CS.XGUI.Navigation.FocusEntryMode.Default)
	end
end

function BattlePassCtrl:setMonthEventState()
	self.monthEventState = true
end

function BattlePassCtrl:monthCardActivate()
	if not self.monthEventState then
		return
	end

	self.monthEventState = false

	if self.view.monthlyCardObj then
		self.view.monthlyCardObj:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function BattlePassCtrl:refreshmonthCard()
	if self.view.monthlyCardObj then
		LuaUIUtils.renderMonthCard(self.view.monthlyCardObj, function()
			local productInfo = RechargeUtils.getProductsInfo()
			local data = {}

			data.giftCommodityId = 30023
			data.productInfo = productInfo

			self:onShowGiftFriendList(data)
		end)
	end
end

return BattlePassCtrl
