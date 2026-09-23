-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\CashShopCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CashShopCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local CashShopConst = require("Const.CashShopConst")
local CashShopModel = require("Guis.Panels.CashShop.CashShopModel")
local CashShopView = require("Guis.Panels.CashShop.CashShopView")
local RecommendationComponent = require("Guis.Panels.CashShop.Component.RecommendationComponent")
local ExchangeShopsComponent = require("Guis.Panels.CashShop.Component.ExchangeShopsComponent")
local PaymentShopsComponent = require("Guis.Panels.CashShop.Component.PaymentShopsComponent")
local CashShopItemListComponent = require("Guis.Panels.CashShop.Component.CashShopItemListComponent")
local AppearanceComponent = require("Guis.Panels.CashShop.Component.AppearanceComponent")
local MonthCardShopsComponent = require("Guis.Panels.CashShop.Component.MonthCardShopsComponent")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local FriendNewComponent = require("Guis.Panels.Chat.Component.FriendNewComponent")
local AvatarPreviewComponent = require("Guis.Panels.CashShop.Component.AvatarPreviewComponent")
local CashShopGiftPackComponent = require("Guis.Panels.CashShop.Component.CashShopGiftPackComponent")
local TradeMarketComponent = require("Guis.Panels.CashShop.Component.TradeMarket.TradeMarketComponent")
local UIConst = require("Const.UIConst")
local ShopmallTabData = require("Data.shopmall_tab_data")
local CashShopRedDotUtils = require("Utils.CashShopRedDotUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local CommonSwitch = require("Common.CommonSwitch")
local HotkeyConst = require("Const.HotkeyConst")
local AudioConst = require("Const.AudioConst")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local CASH_SHOP_EX_SCENE_CLASS = "CashShopExScene"
local CashShopCtrl = Class.LightClass("CashShopCtrl", UICtrl)

CashShopCtrl.modelClz = CashShopModel
CashShopCtrl.viewClz = CashShopView
CashShopCtrl.CategoryTypeInfo = {
	[CashShopConst.CategoryType.RECOMMEND] = {
		container = "recommendationUContainer",
		cls = RecommendationComponent
	},
	[CashShopConst.CategoryType.MONTHLYCARD] = {
		container = "monthCardUContainer",
		cls = MonthCardShopsComponent
	},
	[CashShopConst.CategoryType.GIFTPACK] = {
		container = "giftPackUContainer",
		cls = CashShopGiftPackComponent
	},
	[CashShopConst.CategoryType.AVATAR] = {
		container = "appearanceUContainer",
		cls = AppearanceComponent
	},
	[CashShopConst.CategoryType.ITEM] = {
		container = "itemUContainer",
		cls = CashShopItemListComponent
	},
	[CashShopConst.CategoryType.EXCHANGE] = {
		container = "exchangeShopsUContainer",
		cls = ExchangeShopsComponent
	},
	[CashShopConst.CategoryType.RECHARGE] = {
		container = "paymentUContainer",
		cls = PaymentShopsComponent
	},
	[CashShopConst.CategoryType.TRADE_MARKET] = {
		container = "tradeMarketUContainer",
		cls = TradeMarketComponent
	}
}
CashShopCtrl.messages = {
	[MessageName.CASH_SHOP_ON_GET_CATEGORY_LIST] = {
		"onCategoryListReceived",
		true
	},
	[MessageName.CASH_SHOP_ON_GET_ITEM_LIST] = {
		"onItemListReceived",
		true
	},
	[MessageName.CASH_SHOP_ON_BUY_ITEM] = {
		"onBuyItemResult",
		true
	},
	[MessageName.CASH_SHOP_CART_CHANGED] = {
		"refreshShoppingCartCommodityCount",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onCurrencyChange",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onCurrencyChange",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onCurrencyChange",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"onCashShopRewardChanged",
		true
	},
	[MessageName.CASH_GIFT_PANEL_CLOSED] = {
		"onCashGiftPanelClosed",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"onCommonSwitchStateChanged",
		true
	},
	[MessageName.BATTLEPASS_CHANGE] = {
		"onBattlePassChange",
		true
	},
	[MessageName.NOTIFY_ACTIVITY_DAY_UPDATED] = {
		"onActivityDayUpdated",
		true
	}
}

function CashShopCtrl:checkOpenExtra(info)
	local tabId = info and info.tabId

	if tabId and not self.model:isTabOpen(tabId) then
		return false
	end

	return true
end

function CashShopCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._friendCloseHandlersWrapped = nil
	self._primeStartTime = nil
	self._tabStartTime = nil
	self._tabDwellTimes = {}
	self._curLogCategoryType = nil
	self._primeLogged = false
	self._currencyPenaltyItemIdSet = {}
	self._isVisible = false
	self._cashShopExSceneToken = 0
	self._cashShopExSceneName = CASH_SHOP_EX_SCENE_CLASS .. tostring(self.uid)
	self._cashShopExSceneTimelineSerial = 0
	self._cashShopExSceneTimelinePlayed = false
	self._cashShopExSceneTimelineContext = nil
	self._cashShopExSceneBlackScreenVisible = false
	self._cashShopExSceneKeepBlackForLotteryReturn = false
	self._lotteryReturnPreviewComponent = nil
	self._initialLotteryRecommendationPending = false
	self._restoreUIAfterInitialLotteryTimeline = false

	if SDKLoginConfig.isEnabled() then
		local products = csSDKManager:GetPayProductsTable()

		if not products or next(products) == nil then
			csSDKManager:GetPayProductsInfo()
		end
	end

	self:addComponents()
	self:addListener()
	self:addNavFocusListener(function()
		self:refreshConsoleBarState()
	end, "CashShop")
	self.model:setShowTabs(info and info.showTabs)

	local _, initialTabId = self:_getVisibleTabs(info and info.tabId or self.model:getDefaultTabId())

	self._initialLotteryRecommendationPending = initialTabId == CashShopConst.CategoryType.RECOMMEND

	if initialTabId == CashShopConst.CategoryType.RECOMMEND and self.recommendationUContainer then
		local sceneRes = self.recommendationUContainer:getInitialSpecialSceneRes()

		if self:_normalizeCashShopExSceneRes(sceneRes) then
			self:_setCashShopExSceneBlackScreenVisible(true)
		end
	end

	self:initTabs(info)
	self.view:setUIInfo()
	self:_refreshCurrencyPenalty(false)
	self:refreshShoppingCartCommodityCount()
	CashShopRedDotUtils.refreshRedDot()
end

function CashShopCtrl:onBattlePassChange()
	if self.curComponent and self.curComponent.onBattlePassChange then
		self.curComponent:onBattlePassChange()
	end
end

function CashShopCtrl:onShow()
	self._isShowing = true

	local friendListVisible = self.friendComponent and self.friendComponent.gameObject and self.friendComponent.gameObject.activeSelf

	self:_setListCurrencyVisible(not friendListVisible)

	self._bpRotateVisible = true

	self:refreshShoppingCartCommodityCount()
	self:_refreshCurrencyPenalty(false)
	self:_refreshBPRotateConsoleBar()

	local directPurchaseSwitchTarget = self:_refreshMoneyList()

	pg.game.recharge:tryShowDailyDirectPurchaseTips(directPurchaseSwitchTarget)

	if self._pendingMainPageLog then
		local log = self._pendingMainPageLog

		self._pendingMainPageLog = nil

		local groupId = self.curComponent and self.curComponent._currentGroupId or 0

		LuaUIUtils.sendCustomLog(Const.BILogName.SHOPPING_MALL_MAIN_PAGE, {
			from_page = log.fromPage,
			stay_page_prime = log.tabId,
			stay_page_sec = groupId
		})
	end

	self._primeStartTime = Time.realSecondCache
	self._tabStartTime = Time.realSecondCache
	self._tabDwellTimes = {}
	self._primeLogged = false

	function ClientCashShopUtils.onPaymentJump()
		self:_sendPrimeStayLog(1)
	end

	function ClientCashShopUtils.onExchangeConfirmOpen()
		self:_sendPrimeStayLog(2)
	end
end

function CashShopCtrl:onHide()
	if self.curComponent and self.curComponent.markCurrentTabRead then
		self.curComponent:markCurrentTabRead()
	end

	self._cashCartRequestToken = (self._cashCartRequestToken or 0) + 1

	self:_sendPrimeStayLog(0)

	self._isShowing = false

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInCurrency", false)

	self._bpRotateVisible = false

	self:_setBPRotateConsoleBar(false)

	ClientCashShopUtils.onPaymentJump = nil
	ClientCashShopUtils.onExchangeConfirmOpen = nil
end

function CashShopCtrl:_accumulateCurTabTime()
	if not self._isShowing or not self._curLogCategoryType or not self._tabStartTime then
		return
	end

	self._tabDwellTimes = self._tabDwellTimes or {}

	local elapsed = math.floor(Time.realSecondCache - self._tabStartTime)

	self._tabDwellTimes[self._curLogCategoryType] = (self._tabDwellTimes[self._curLogCategoryType] or 0) + elapsed
	self._tabStartTime = Time.realSecondCache
end

function CashShopCtrl:_sendPrimeStayLog(reason)
	if self._primeLogged or not self._primeStartTime then
		return
	end

	self._primeLogged = true

	self:_accumulateCurTabTime()

	local logData = {
		leaving_reason_prime = reason,
		stay_time_prime = math.floor(Time.realSecondCache - self._primeStartTime)
	}

	for catType, seconds in pairs(self._tabDwellTimes or EMPTY_TABLE) do
		logData["stay_time_sec_" .. tostring(catType)] = seconds
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.SHOPPING_MALL_PRIME_STAY, logData)
end

function CashShopCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local showTabsChanged = self.model:setShowTabs(info and info.showTabs)
	local tabId = info and info.tabId
	local groupId = info and info.groupId
	local commodityId = info and info.commodityId
	local isFirstOpen = not self.model:getCurrentTabId()
	local targetTabId

	if isFirstOpen then
		local _, t = self:_getVisibleTabs(tabId or self.model:getDefaultTabId())

		targetTabId = t
	elseif tabId then
		local _, t = self:_getVisibleTabs(tabId)

		targetTabId = t
	end

	if not self._isShowing then
		self._pendingMainPageLog = {
			fromPage = info and info.fromPage or "",
			tabId = targetTabId or self.model:getCurrentTabId() or self.model:getDefaultTabId()
		}
	end

	if isFirstOpen then
		if groupId or commodityId then
			self._pendingNav = {
				groupId = groupId,
				commodityId = commodityId
			}
		end

		self:onFirstTabSelected(targetTabId)

		return
	end

	if showTabsChanged then
		self:_refreshFirstTabList(tabId)
	end

	if not tabId and not groupId and not commodityId then
		return
	end

	self:navigateTo(targetTabId or tabId, groupId, commodityId)
end

function CashShopCtrl:_refreshFirstTabList(preferredTabId)
	local currentTabId = self.model:getCurrentTabId()
	local visibleTabs, targetTabId = self:_getVisibleTabs(preferredTabId or currentTabId)

	if not visibleTabs or #visibleTabs == 0 then
		return
	end

	self.view:setFirstTabList(visibleTabs, targetTabId, function(selTabId)
		self:onFirstTabSelected(selTabId)
	end)

	if not preferredTabId and currentTabId ~= targetTabId then
		self:onFirstTabSelected(targetTabId)
	end
end

function CashShopCtrl:navigateTo(tabId, groupId, commodityId)
	if tabId then
		local canOpen, tipText = self:checkOpenExtra({
			tabId = tabId
		})

		if not canOpen then
			pg.global.ui.tips:showTextTip(tipText or pg.getGameString("FUNCTION_NOT_OPEN"))

			return
		end
	end

	self:_closeSecondaryPopups()

	if tabId and tabId ~= self.model:getCurrentTabId() then
		if self.model:addShowTab(tabId) then
			self:_refreshFirstTabList(tabId)
		end

		if groupId or commodityId then
			self._pendingNav = {
				groupId = groupId,
				commodityId = commodityId
			}
		end

		self:onFirstTabSelected(tabId)
	elseif self.curComponent then
		if groupId then
			if commodityId then
				self._pendingNav = {
					commodityId = commodityId
				}
			end

			self.curComponent:selectGroup(groupId)
		elseif commodityId then
			self.curComponent:selectCommodity(commodityId)
		end
	end
end

function CashShopCtrl:_closeSecondaryPopups()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_USE_CONFIRM) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_USE_CONFIRM)
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_QUICK_PAYMENT) then
		pg.global.ui:close(UIConst.UI_ID_QUICK_PAYMENT)
	end

	if self.friendComponent and self.friendComponent.gameObject and self.friendComponent.gameObject.activeSelf then
		self.friendComponent.gameObject:SetActiveEx(false)
		self:_setListCurrencyVisible(true)
	end
end

function CashShopCtrl:onDestroy()
	self._cashCartRequestToken = (self._cashCartRequestToken or 0) + 1
	self._bpRotateVisible = false
	self._lotteryReturnPreviewComponent = nil

	self:_setBPRotateConsoleBar(false)
	self:_destroyCashShopExScene()
	self:removeComponents()
	UICtrl.onDestroy(self)
end

function CashShopCtrl:tryAutoHideInitialLotteryRecommendation(data)
	if not self._initialLotteryRecommendationPending then
		return
	end

	self._initialLotteryRecommendationPending = false

	if not data or data.showModle ~= CashShopConst.ShowModle.Lottery then
		return
	end

	self._restoreUIAfterInitialLotteryTimeline = true

	self:setUIShow(false)
end

function CashShopCtrl:restoreInitialLotteryTimelineUI()
	if not self._restoreUIAfterInitialLotteryTimeline then
		return
	end

	self._restoreUIAfterInitialLotteryTimeline = false

	self:setUIShow(true)
end

function CashShopCtrl:prepareLotteryReturnPreview()
	local component = self.curComponent
	local interaction = component and component.productInformation and component.productInformation.suitPowerInteractionComponent

	if interaction then
		interaction:clearPreviewState(true)
	end

	self._lotteryReturnPreviewComponent = component and component._showingPet and component or nil
	self._cashShopExSceneKeepBlackForLotteryReturn = self._cashShopExSceneRes ~= nil

	if self._cashShopExSceneKeepBlackForLotteryReturn then
		self:_setCashShopExSceneBlackScreenVisible(true)
	end
end

function CashShopCtrl:onVisibleChange(visible)
	self._isVisible = visible == true
	self._bpRotateVisible = visible == true

	if visible then
		self._cashShopExSceneKeepBlackForLotteryReturn = false

		self:_refreshBPRotateConsoleBar()
	else
		self:_setBPRotateConsoleBar(false)
	end

	if not self.avatarComponent then
		return
	end

	if visible then
		self.avatarComponent:registerGesture(self.view.maskRayBoxTrans)
	else
		self.avatarComponent:unRegisterGesture()
	end

	if visible then
		local restoreComponent = self._lotteryReturnPreviewComponent

		self._lotteryReturnPreviewComponent = nil

		if restoreComponent and restoreComponent == self.curComponent and restoreComponent:_switchToPlayer(function()
			if self._isVisible and self.curComponent == restoreComponent then
				self:_activateCashShopExScene()
			end
		end) then
			return
		end

		self:_activateCashShopExScene()
	else
		self:_deactivateCashShopExScene()
	end
end

function CashShopCtrl:_normalizeCashShopExSceneRes(exScene)
	if type(exScene) ~= "string" then
		return nil
	end

	exScene = exScene:match("^%s*(.-)%s*$")

	if exScene == "" or exScene == "0" then
		return nil
	end

	return exScene
end

function CashShopCtrl:_setCashShopExSceneBlackScreenVisible(visible)
	visible = visible == true

	if self._cashShopExSceneBlackScreenVisible == visible then
		return
	end

	self._cashShopExSceneBlackScreenVisible = visible

	if self.view and self.view.setSpecialSceneBlackScreenVisible then
		self.view:setSpecialSceneBlackScreenVisible(visible)
	end
end

function CashShopCtrl:_isCashShopExSceneTimelineFemale()
	local avatarScene = self.avatarComponent and self.avatarComponent.avatarScene
	local presetData = avatarScene and avatarScene.getPresetData and avatarScene:getPresetData()
	local body = presetData and tonumber(presetData.body)

	return body == nil or math.floor(body / 10) == 1
end

function CashShopCtrl:_applyCashShopExSceneTimelineGenderTrack(cutscene)
	local cutsceneItem = cutscene and cutscene.cutscene

	if not cutsceneItem then
		return false
	end

	local isFemale = self:_isCashShopExSceneTimelineFemale()

	cutsceneItem:SetGroupActiveWithName("BOY", not isFemale)
	cutsceneItem:SetGroupActiveWithName("GIRL", isFemale)

	self._cashShopExSceneTimelineIsFemale = isFemale

	return true
end

function CashShopCtrl:_resetCashShopExSceneEntity(timelineContext, restoreSource)
	local avatarScene = self.avatarComponent and self.avatarComponent.avatarScene

	if avatarScene and avatarScene.resetCashShopExSceneEntity then
		avatarScene:resetCashShopExSceneEntity(timelineContext, restoreSource)
	end
end

function CashShopCtrl:_applyCashShopExSceneTimelineCameraState()
	local exScene = self._cashShopExScene

	if exScene and exScene.endTimelineCamera then
		exScene:endTimelineCamera()
	end
end

function CashShopCtrl:_clearCashShopExSceneTimelineCameraState()
	self._cashShopExSceneTimelineCameraSerial = nil
	self._cashShopExSceneTimelineCameraReady = nil
end

function CashShopCtrl:_completeCashShopExSceneTimelineCamera(requestToken, timelineSerial, timelineContext)
	local exScene = self._cashShopExScene

	if exScene and exScene.finishTimelineCamera then
		exScene:finishTimelineCamera()
	end

	TimerManager.addNextFrameCb(function()
		if requestToken ~= self._cashShopExSceneToken or timelineSerial ~= self._cashShopExSceneTimelineCameraSerial or not self._isVisible or self._cashShopExScene ~= exScene then
			return
		end

		exScene:blendTimelineCameraToDefault()
		self:_resetCashShopExSceneEntity(timelineContext, self._cashShopExSceneTimelineContext == nil)
		self:_clearCashShopExSceneTimelineCameraState()
	end)
end

function CashShopCtrl:_restoreCashShopExSceneTimelineCamera()
	self:_applyCashShopExSceneTimelineCameraState()
	self:_clearCashShopExSceneTimelineCameraState()
end

function CashShopCtrl:_onCashShopExSceneTimelineCreated(cutscene, requestToken, timelineSerial, timelineContext)
	if requestToken ~= self._cashShopExSceneToken or timelineSerial ~= self._cashShopExSceneActiveTimelineSerial or not self._isVisible or not self._cashShopExScene then
		return
	end

	self._cashShopExSceneTimeline = cutscene
	self._cashShopExSceneTimelineCameraSerial = timelineSerial

	local avatarScene = self.avatarComponent and self.avatarComponent.avatarScene

	if not avatarScene or not avatarScene.activateCashShopExSceneTimelineEntity or not avatarScene:activateCashShopExSceneTimelineEntity(timelineContext) then
		logger:error("商城特殊推荐 Timeline 临时模型激活失败, timeline=%s", tostring(self._cashShopExSceneTimelineRes))

		return
	end

	if not self:_applyCashShopExSceneTimelineGenderTrack(cutscene) then
		logger:error("商城特殊推荐 Timeline 男女轨道切换失败, timeline=%s", tostring(self._cashShopExSceneTimelineRes))

		return
	end

	local exScene = self._cashShopExScene

	if not exScene or not exScene.beginTimelineCamera or not exScene:beginTimelineCamera() then
		logger:error("商城特殊推荐 Timeline 无法接管特殊场景 Camera, timeline=%s", tostring(self._cashShopExSceneTimelineRes))

		return
	end

	self._cashShopExSceneTimelineCameraReady = true
end

function CashShopCtrl:_onCashShopExSceneTimelinePlayed(cutscene, requestToken, timelineSerial)
	if requestToken ~= self._cashShopExSceneToken or timelineSerial ~= self._cashShopExSceneActiveTimelineSerial or self._cashShopExSceneTimeline and self._cashShopExSceneTimeline ~= cutscene or not self._cashShopExSceneTimelineCameraReady then
		pg.game.cutscene:stopCutscene(cutscene.id)

		if requestToken == self._cashShopExSceneToken and timelineSerial == self._cashShopExSceneActiveTimelineSerial then
			self:_setCashShopExSceneBlackScreenVisible(false)
		end

		return
	end

	self:_setCashShopExSceneBlackScreenVisible(false)
end

function CashShopCtrl:_onCashShopExSceneTimelineEnd(requestToken, timelineSerial, timelineContext)
	if requestToken ~= self._cashShopExSceneToken or timelineSerial ~= self._cashShopExSceneActiveTimelineSerial then
		TimerManager.addNextFrameCb(function()
			self:_resetCashShopExSceneEntity(timelineContext, self._cashShopExSceneTimelineContext == nil)
		end)

		return
	end

	self:_setCashShopExSceneBlackScreenVisible(false)

	self._cashShopExSceneTimeline = nil
	self._cashShopExSceneActiveTimelineSerial = nil

	if self._cashShopExSceneTimelineContext == timelineContext then
		self._cashShopExSceneTimelineContext = nil
	end

	self:restoreInitialLotteryTimelineUI()
	self:_completeCashShopExSceneTimelineCamera(requestToken, timelineSerial, timelineContext)
end

function CashShopCtrl:_stopCashShopExSceneTimeline()
	local cutscene = self._cashShopExSceneTimeline
	local timelineContext = self._cashShopExSceneTimelineContext
	local hadActiveTimeline = self._cashShopExSceneActiveTimelineSerial ~= nil

	self._cashShopExSceneTimeline = nil
	self._cashShopExSceneTimelineContext = nil
	self._cashShopExSceneActiveTimelineSerial = nil

	if not cutscene then
		self:_restoreCashShopExSceneTimelineCamera()
		self:_resetCashShopExSceneEntity(timelineContext, true)

		if hadActiveTimeline then
			self:restoreInitialLotteryTimelineUI()
		end

		return
	end

	pg.game.cutscene:stopCutscene(cutscene.id)
	self:_restoreCashShopExSceneTimelineCamera()

	if hadActiveTimeline then
		self:restoreInitialLotteryTimelineUI()
	end
end

function CashShopCtrl:_playCashShopExSceneTimeline()
	local exScene = self._cashShopExScene
	local avatarScene = self.avatarComponent and self.avatarComponent.avatarScene
	local isFemale = self:_isCashShopExSceneTimelineFemale()

	if self._cashShopExSceneTimelineIsFemale ~= nil and self._cashShopExSceneTimelineIsFemale ~= isFemale then
		if self._cashShopExSceneTimeline then
			self:_stopCashShopExSceneTimeline()
		end

		self._cashShopExSceneTimelinePlayed = false
	elseif self._cashShopExSceneTimeline then
		return true
	elseif self._cashShopExSceneTimelinePlayed then
		return false
	end

	self._cashShopExSceneTimelineIsFemale = isFemale

	local timelineRes = self:_normalizeCashShopExSceneRes(self._cashShopExSceneTimelineRes)
	local sourceEntity = avatarScene and avatarScene:getCurEntity()
	local entityRootTransform = exScene and exScene.getEntityRootTransform and exScene:getEntityRootTransform()

	if not timelineRes or not sourceEntity or IsNil(sourceEntity.eModel) or IsNil(entityRootTransform) then
		logger:error("商城特殊推荐 Timeline 播放条件不足, timeline=%s, entity=%s, root=%s", tostring(timelineRes), tostring(sourceEntity ~= nil), tostring(NotNil(entityRootTransform)))

		return false
	end

	local timelineContext = avatarScene.createCashShopExSceneTimelineEntity and avatarScene:createCashShopExSceneTimelineEntity() or nil
	local entity = timelineContext and timelineContext.timelineEntity or nil

	if not entity or IsNil(entity.eModel) then
		logger:error("商城特殊推荐 Timeline 临时模型创建失败, timeline=%s", tostring(timelineRes))

		return false
	end

	self._cashShopExSceneTimelinePlayed = true
	self._cashShopExSceneTimelineSerial = self._cashShopExSceneTimelineSerial + 1

	local timelineSerial = self._cashShopExSceneTimelineSerial
	local timelineName = self._cashShopExSceneName .. "Timeline" .. tostring(timelineSerial)
	local requestToken = self._cashShopExSceneToken

	self._cashShopExSceneActiveTimelineSerial = timelineSerial
	self._cashShopExSceneTimelineContext = timelineContext

	local cutscene = pg.game.cutscene:playCutscene(timelineName, timelineRes, entityRootTransform.position, entityRootTransform.rotation, nil, true, {
		applySoundListener = false,
		bindEntity = entity,
		createCallback = function(createdCutscene)
			self:_onCashShopExSceneTimelineCreated(createdCutscene, requestToken, timelineSerial, timelineContext)
			pgUtils.SetAllEffLodCamera(createdCutscene.cutscene.rootObject.transform, self._cashShopExScene.camera)
		end,
		endCallback = function()
			self:_onCashShopExSceneTimelineEnd(requestToken, timelineSerial, timelineContext)
		end
	}, nil, function(playingCutscene)
		self:_onCashShopExSceneTimelinePlayed(playingCutscene, requestToken, timelineSerial)
	end)

	if not cutscene then
		self._cashShopExSceneTimelinePlayed = false
		self._cashShopExSceneActiveTimelineSerial = nil

		if self._cashShopExSceneTimelineContext == timelineContext then
			self._cashShopExSceneTimelineContext = nil
		end

		self:_resetCashShopExSceneEntity(timelineContext, true)
		logger:error("商城特殊推荐 Timeline 创建失败, timeline=%s", tostring(timelineRes))

		return false
	end

	if self._cashShopExSceneActiveTimelineSerial == timelineSerial then
		self._cashShopExSceneTimeline = cutscene
	end

	return true
end

function CashShopCtrl:_setCashShopExSceneActive(active)
	local avatarScene = self.avatarComponent and self.avatarComponent.avatarScene
	local exScene = self._cashShopExScene

	if avatarScene and avatarScene.setCashShopExSceneActive then
		local entityRootTransform

		if active and exScene and exScene.getEntityRootTransform then
			entityRootTransform = exScene:getEntityRootTransform()
		end

		return avatarScene:setCashShopExSceneActive(active, entityRootTransform, exScene)
	end

	return false
end

function CashShopCtrl:_activateCashShopExScene()
	local exScene = self._cashShopExScene

	if not self._isVisible or not exScene or not exScene:checkLoadSucceed() then
		return
	end

	if not exScene:checkSceneValid() or not self:_setCashShopExSceneActive(true) then
		logger:error("商城特殊推荐 UI 场景初始化失败, res=%s", tostring(self._cashShopExSceneRes))
		self:_destroyCashShopExScene()

		return
	end

	pg.game.uiScene:switchToScene(self._cashShopExSceneName, false, false, false, self.module)

	if not self:_playCashShopExSceneTimeline() then
		self:_setCashShopExSceneBlackScreenVisible(false)
		self:restoreInitialLotteryTimelineUI()
	end
end

function CashShopCtrl:_deactivateCashShopExScene()
	if not self._cashShopExSceneKeepBlackForLotteryReturn then
		self:_setCashShopExSceneBlackScreenVisible(false)
	end

	local exScene = self._cashShopExScene

	self:_stopCashShopExSceneTimeline()

	self._cashShopExSceneTimelinePlayed = false

	self:_restoreCashShopExSceneTimelineCamera()
	self:_setCashShopExSceneActive(false)

	if exScene and exScene:checkLoaded() then
		pg.game.uiScene:switchOutScene(self._cashShopExSceneName, true, false, self.module)
	end
end

function CashShopCtrl:_destroyCashShopExScene(keepBlackScreen)
	if not keepBlackScreen then
		self:_setCashShopExSceneBlackScreenVisible(false)
	end

	self._cashShopExSceneToken = (self._cashShopExSceneToken or 0) + 1

	self:_stopCashShopExSceneTimeline()

	self._cashShopExSceneTimelinePlayed = false

	self:_restoreCashShopExSceneTimelineCamera()
	self:_setCashShopExSceneActive(false)

	local exScene = self._cashShopExScene

	if exScene then
		exScene:removeUICtrlKey(self.module)
		pg.game.uiScene:switchOutScene(self._cashShopExSceneName, false, false, self.module)
	end

	self._cashShopExScene = nil
	self._cashShopExSceneRes = nil
	self._cashShopExSceneTimelineRes = nil
	self._cashShopExSceneTimelineIsFemale = nil
end

function CashShopCtrl:switchCashShopExScene(exScene, sceneTimeLine)
	local exSceneRes = self:_normalizeCashShopExSceneRes(exScene)
	local timelineRes = self:_normalizeCashShopExSceneRes(sceneTimeLine)

	if self._cashShopExScene and self._cashShopExSceneRes == exSceneRes then
		if self._cashShopExSceneTimelineRes ~= timelineRes then
			self:_stopCashShopExSceneTimeline()

			self._cashShopExSceneTimelineRes = timelineRes
			self._cashShopExSceneTimelinePlayed = false
		end

		self:_activateCashShopExScene()

		return
	end

	self:_destroyCashShopExScene(exSceneRes ~= nil)

	if not exSceneRes then
		return
	end

	self:_setCashShopExSceneBlackScreenVisible(true)

	self._cashShopExSceneRes = exSceneRes
	self._cashShopExSceneTimelineRes = timelineRes
	self._cashShopExSceneToken = self._cashShopExSceneToken + 1

	local requestToken = self._cashShopExSceneToken
	local loadingScene = pg.game.uiScene:getUISceneInst(self._cashShopExSceneName, exSceneRes, nil, nil, CASH_SHOP_EX_SCENE_CLASS)

	self._cashShopExScene = loadingScene

	loadingScene:bindUICtrlKey(self.module)
	loadingScene:startLoad(function(succeed)
		if requestToken ~= self._cashShopExSceneToken or self._cashShopExScene ~= loadingScene then
			return
		end

		if not succeed then
			logger:error("商城特殊推荐 UI 场景加载失败, res=%s", tostring(exSceneRes))
			self:restoreInitialLotteryTimelineUI()
			self:_destroyCashShopExScene()

			return
		end

		self:_activateCashShopExScene()
	end)
end

function CashShopCtrl:_setBPRotateConsoleBar(isShow)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_BP_Rotate", isShow == true)
end

function CashShopCtrl:_refreshBPRotateConsoleBar()
	if not self._bpRotateVisible then
		self:_setBPRotateConsoleBar(false)

		return
	end

	local isShowingBP = self.curComponent and self.curComponent.isShowingBP and self.curComponent:isShowingBP()

	self:_setBPRotateConsoleBar(isShowingBP == true)
end

function CashShopCtrl:addComponents()
	self.avatarComponent = AvatarPreviewComponent.new(self, self.view.transform, {
		presetKey = pg.game.avatar:getPresetKey(pg.me)
	})

	if self.view.friendNewUComponent then
		self.friendComponent = FriendNewComponent.new(self, self.view.friendNewUComponent)
	end

	for categoryType, info in pairs(CashShopCtrl.CategoryTypeInfo) do
		local container = self.view[info.container]

		if container then
			self[info.container] = info.cls.new(self, container, categoryType)
		else
			logger:error("addComponents: View 中找不到容器节点 '%s'，请检查 findObjects", info.container)
		end
	end
end

function CashShopCtrl:removeComponents()
	for _, info in pairs(CashShopCtrl.CategoryTypeInfo) do
		self[info.container] = nil
	end

	if self.curComponent and self.curComponent.onDestroy then
		self.curComponent:onDestroy()
	end

	if self.avatarComponent then
		self.avatarComponent:onDestroy()

		self.avatarComponent = nil
	end

	self.curComponent = nil

	self.model:setCurrentTabId(nil)
end

function CashShopCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:dismiss()
	end

	if self.view.btnShoppingCart then
		function self.view.btnShoppingCart.luaClick()
			self:openCashCart()
		end
	end

	if self.view.btnSearch then
		function self.view.btnSearch.luaClick()
			local tabId = self.model:getCurrentTabId()

			if tabId then
				local gender = self.curComponent and self.curComponent._currentGender or ClientCashShopUtils.getPlayerGender()

				pg.global.ui:open(UIConst.UI_ID_CASH_SEARCH, {
					tabId = tabId,
					gender = gender
				})
			end
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			if self.view.rootUComponent then
				self:setUIShow(true)
			end
		end
	end

	if self.view.minusBtn then
		self.view.minusBtn.enabledTooltip = false
		self.view.minusBtn.luaRenderTooltip = nil

		function self.view.minusBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_CASH_SHOP_PENALTY_TIP)
		end
	end
end

function CashShopCtrl:getShoppingCartCommodityCount()
	local commodityCount = 0
	local shopMallCart = pg.me and pg.me.shopMallCart

	if not shopMallCart then
		return commodityCount
	end

	for _ in pairs(shopMallCart) do
		commodityCount = commodityCount + 1
	end

	return commodityCount
end

function CashShopCtrl:refreshShoppingCartCommodityCount()
	self.view:setShoppingCartCommodityCount(self:getShoppingCartCommodityCount())
end

function CashShopCtrl:openCashCart(commodityId)
	self._cashCartRequestToken = (self._cashCartRequestToken or 0) + 1

	local requestToken = self._cashCartRequestToken

	if commodityId then
		local cartItem = pg.me and pg.me.shopMallCart and pg.me.shopMallCart[commodityId]

		if cartItem then
			self:_openCashCart(requestToken)

			return
		end

		self:_requestAddCashCartCommodity(commodityId, function(success, noticeId)
			if not self:_isCashCartRequestValid(requestToken) then
				return
			end

			if not success then
				if noticeId then
					pg.global.showBubbleMessageById(noticeId)
				end

				return
			end

			self:_openCashCart(requestToken)
		end)
	else
		self:_openCashCart(requestToken)
	end
end

function CashShopCtrl:addCashCartCommodity(commodityId)
	if not commodityId then
		return
	end

	self._cashCartRequestToken = (self._cashCartRequestToken or 0) + 1

	local requestToken = self._cashCartRequestToken
	local cartItem = pg.me and pg.me.shopMallCart and pg.me.shopMallCart[commodityId]
	local currentNum = cartItem and math.max(1, tonumber(cartItem.num) or 1) or 0

	self:_requestModifyCashCartCommodityNum(commodityId, currentNum + 1, function(success, noticeId)
		if not self:_isCashCartRequestValid(requestToken) then
			return
		end

		if not success then
			if noticeId then
				pg.global.showBubbleMessageById(noticeId)
			end

			return
		end

		self:refreshShoppingCartCommodityCount()
		pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_CART_ADD"))
	end)
end

function CashShopCtrl:_requestAddCashCartCommodity(commodityId, callback)
	self:_requestModifyCashCartCommodityNum(commodityId, 1, callback)
end

function CashShopCtrl:_requestModifyCashCartCommodityNum(commodityId, buyCount, callback)
	if not pg.me then
		if callback then
			callback(false)
		end

		return
	end

	pg.me:serverMsg("RPC_CS_ShopMallCartModifyCommodityNum", commodityId, buyCount, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.CASH_SHOP_CART_CHANGED)
		end

		if callback then
			callback(noticeId == NoticeDef.SUCCESS, noticeId)
		end
	end)
end

function CashShopCtrl:_isCashCartRequestValid(requestToken)
	return requestToken == self._cashCartRequestToken and self:checkUIOpen() and not self:checkUIClosing()
end

function CashShopCtrl:_openCashCart(requestToken)
	if not self:_isCashCartRequestValid(requestToken) then
		return
	end

	self:refreshShoppingCartCommodityCount()
	pg.global.ui:open(UIConst.UI_ID_CASH_CART)
end

function CashShopCtrl:_bindHideModeCancel()
	local widgetGo = self.view and self.view.widget and self.view.widget.gameObject

	if not widgetGo then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(widgetGo, "cashShopHideCancelBind")

	bind.isVirtual = true
	bind.priority = 99999
	bind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.ClosePanelCommon

	function bind.luaTrigger(inputInfo)
		if not pg.game.input:isUsingGamepad() then
			return true
		end

		if inputInfo.phase == "Performed" and self._uiHidden then
			self:setUIShow(true)

			return false
		end

		return true
	end
end

function CashShopCtrl:_unbindHideModeCancel()
	local widgetGo = self.view and self.view.widget and self.view.widget.gameObject

	if not widgetGo then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(widgetGo, "cashShopHideCancelBind")

	bind.luaTrigger = nil
	bind.actionPath = ""
end

function CashShopCtrl:checkCommonQuit()
	if self._uiHidden then
		return false
	end

	local navMgr = pg.global.navMgr

	if self._isShowing == true and pg.game.input:isUsingGamepad() and navMgr and navMgr.CurrentFocusedGroupName == "ListCurrency" then
		self:startFrameTimer(function()
			if not self.view or not self.view.rootUComponent then
				return
			end

			if pg.global.ui:getTopFirstPanel() ~= self.uid then
				return
			end

			local currentNavMgr = pg.global.navMgr

			if currentNavMgr and currentNavMgr.CurrentFocusedGroupName == "ListCurrency" then
				currentNavMgr:ClearFocus()
				currentNavMgr:TryFocusFirstAvailable()
			end
		end, 1)

		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function CashShopCtrl:_restoreNavFocusAfterShow()
	if not pg.game.input:isUsingGamepad() or not pg.global.navMgr then
		return
	end

	self:startFrameTimer(function()
		if not self.view or not self.view.rootUComponent then
			return
		end

		if pg.global.navMgr then
			pg.global.navMgr:TryFocusFirstAvailable()
		end
	end, 1)
end

function CashShopCtrl:setUIShow(isShow)
	if not self.view.rootUComponent then
		return
	end

	if isShow then
		self._restoreUIAfterInitialLotteryTimeline = false
	end

	local targetHidden = not isShow

	if self._uiHidden == targetHidden then
		self.view.rootUComponent:TryChangePage("type", isShow and 0 or 1)
		self:refreshConsoleBarState()

		return
	end

	self._uiHidden = targetHidden

	self.view.rootUComponent:TryChangePage("type", isShow and 0 or 1)

	if targetHidden then
		self:_bindHideModeCancel()
	else
		self:_unbindHideModeCancel()
		self:_restoreNavFocusAfterShow()
	end

	self:refreshConsoleBarState()
end

function CashShopCtrl:refreshConsoleBarState()
	local consoleBar = CS.XGUI.Navigation.ConsoleBar

	if not consoleBar or not consoleBar.SetStateForAll then
		return
	end

	local categoryType = self.model and self.model:getCurrentTabId()
	local isExchange = categoryType == CashShopConst.CategoryType.EXCHANGE
	local isGiftPack = categoryType == CashShopConst.CategoryType.GIFTPACK
	local isMonthlyCard = categoryType == CashShopConst.CategoryType.MONTHLYCARD
	local isItem = categoryType == CashShopConst.CategoryType.ITEM
	local showingModel = self.curComponent and self.curComponent._showingModel == true
	local uiHidden = self._uiHidden == true
	local currentGroupName = CS.XGUI.Navigation.NavManager.Instance and CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
	local isInCurrency = not uiHidden and self._isShowing ~= false and currentGroupName == "ListCurrency"
	local firstTopReward = false
	local randomShopSelect = false
	local randomShopChangeSelect = false
	local isRuleVisible = false

	if categoryType == CashShopConst.CategoryType.RECOMMEND then
		if self.curComponent then
			firstTopReward = self.curComponent.focusOnReward and self.curComponent:focusOnReward()

			local currentData = self.curComponent._currentData

			isRuleVisible = currentData ~= nil and currentData.showModle == CashShopConst.ShowModle.FirstTopup
		end
	elseif categoryType == CashShopConst.CategoryType.EXCHANGE and self.curComponent then
		randomShopSelect = self.curComponent.focusOnUnopenCard and self.curComponent:focusOnUnopenCard()
		showingModel = false
		isRuleVisible = self.curComponent.isRandomShopPageActive and self.curComponent:isRandomShopPageActive() or false
	end

	consoleBar.SetStateForAll("CashShop_UIHidden", uiHidden)
	consoleBar.SetStateForAll("isInCurrency", isInCurrency)
	consoleBar.SetStateForAll("canSelect", not not categoryType and not isExchange and not isGiftPack and not isMonthlyCard and not isItem and not uiHidden and not not not firstTopReward)
	consoleBar.SetStateForAll("canSelect2", not not isGiftPack and not not not uiHidden)
	consoleBar.SetStateForAll("canMoveCamera", not not showingModel)
	consoleBar.SetStateForAll("randomshop_select", randomShopSelect)
	consoleBar.SetStateForAll("randomshop_changeselect", randomShopChangeSelect)
	consoleBar.SetStateForAll("CashShop_Rule", isRuleVisible, true)
end

function CashShopCtrl:openAvatarAdjust()
	pg.global.ui:open(UIConst.UI_ID_CASH_ACCESSORY_ADJUST, {
		cashShopCtrl = self,
		context = self._adjustContext
	})
end

function CashShopCtrl:hideAvatarAdjust()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_CASH_ACCESSORY_ADJUST) then
		pg.global.ui:close(UIConst.UI_ID_CASH_ACCESSORY_ADJUST)
	end
end

function CashShopCtrl:saveAvatarAdjust(callBack)
	local panel = pg.global.ui.cashShopAccessoryAdjust

	if panel and panel.saveAvatarAdjust then
		panel:saveAvatarAdjust(callBack)
	elseif callBack then
		callBack(false)
	end
end

function CashShopCtrl:updateAdjustContext(selectedAccessoryId, selectedSlotId, selectedPetAccessoryId, selectedPetGenId, selectedPetSlotIdx)
	self._adjustContext = {
		selectedAccessoryId = selectedAccessoryId,
		selectedSlotId = selectedSlotId,
		selectedPetAccessoryId = selectedPetAccessoryId,
		selectedPetGenId = selectedPetGenId,
		selectedPetSlotIdx = selectedPetSlotIdx or 1
	}

	local panel = pg.global.ui.cashShopAccessoryAdjust

	if panel and panel.updateAdjustContext then
		panel:updateAdjustContext(self._adjustContext)
	end
end

function CashShopCtrl:_getVisibleTabs(targetTabId)
	local tabList = self.model:getTabList()
	local visibleTabs = {}

	for _, tab in ipairs(tabList or EMPTY_TABLE) do
		if tab.unlock and self.model:isTabInShowTabs(tab.id) then
			visibleTabs[#visibleTabs + 1] = tab
		end
	end

	local finalTabId = targetTabId
	local targetVisible = false

	for _, tab in ipairs(visibleTabs) do
		if tab.id == finalTabId then
			targetVisible = true

			break
		end
	end

	if not targetVisible then
		finalTabId = visibleTabs[1] and visibleTabs[1].id or nil
	end

	return visibleTabs, finalTabId
end

function CashShopCtrl:initTabs(info)
	local initialTabId = info and info.tabId or self.model:getDefaultTabId()
	local visibleTabs, targetTabId = self:_getVisibleTabs(initialTabId)

	if not visibleTabs or #visibleTabs == 0 then
		logger:warning("initTabs: 页签配置表为空")

		return
	end

	self.view:setFirstTabList(visibleTabs, targetTabId, function(tabId)
		self:onFirstTabSelected(tabId)
	end)
end

function CashShopCtrl:onFirstTabSelected(tabId)
	if self.model:getCurrentTabId() == tabId then
		local typeInfo = CashShopCtrl.CategoryTypeInfo[tabId]
		local targetComponent = typeInfo and self[typeInfo.container]
		local pageReady = true

		if targetComponent and targetComponent.checkPageReady then
			pageReady = targetComponent:checkPageReady()
		end

		if targetComponent and (self.curComponent ~= targetComponent or not pageReady) then
			logger:warning("onFirstTabSelected retry unfinished tab, tabId=%s, contentLoaded=%s", tostring(tabId), tostring(targetComponent.checkContentLoaded and targetComponent:checkContentLoaded()))

			if self.curComponent ~= targetComponent then
				self:_enterTab(tabId)
			else
				targetComponent:retryPage()
			end
		end

		return
	end

	if tabId ~= CashShopConst.CategoryType.RECOMMEND then
		self._initialLotteryRecommendationPending = false

		self:restoreInitialLotteryTimelineUI()
	end

	self:_accumulateCurTabTime()

	self._curLogCategoryType = tabId
	self._tabStartTime = Time.realSecondCache

	self.model:setCurrentTabId(tabId)
	self.view:refreshFirstTabSelected(tabId)
	self:_refreshCurrencyList()
	self:_refreshCurrencyPenalty(false)

	if self.view.btnSearch then
		local tabCfg = ShopmallTabData[tabId]
		local showSearch = tabCfg and tabCfg.showSearch == 1

		self.view.btnSearch.gameObject:SetActiveEx(showSearch)
	end

	self:_enterTab(tabId)
end

function CashShopCtrl:_refreshMoneyList()
	return RechargeUtils.setupMoneyList(self.view.moneyListUButton)
end

function CashShopCtrl:_refreshCurrencyList()
	self.view:refreshCurrencyList(self.model:getCurrentTabCurrencyList(), function(itemId)
		if self.curComponent and self.curComponent.onTopCurrencyClick then
			return self.curComponent:onTopCurrencyClick(itemId) == true
		end

		return false
	end)
end

function CashShopCtrl:refreshDirectPurchaseState()
	self:_refreshMoneyList()
end

function CashShopCtrl:_enterTab(tabId)
	local typeInfo = CashShopCtrl.CategoryTypeInfo[tabId]

	if not typeInfo then
		logger:warning("_enterTab: tabId=%s 在 CategoryTypeInfo 中未注册，跳过内容切换", tostring(tabId))

		return
	end

	if self.curComponent then
		self.curComponent:onExitPage()
	end

	self:_setBPRotateConsoleBar(false)

	self.curComponent = self[typeInfo.container]

	if self.curComponent then
		self.curComponent:onEnterPage(tabId)
	end

	self:refreshConsoleBarState()
end

function CashShopCtrl:onCategoryListReceived(categoryList)
	self.model:setCategoryList(categoryList)
end

function CashShopCtrl:onCurrencyChange()
	self:_refreshCurrencyList()
	self:_refreshCurrencyPenalty(true)
end

function CashShopCtrl:_refreshCurrencyPenalty(showRecoveredToast)
	local negativeMoneyList = ItemUtils.getNegativeMoneyList(pg.me)
	local currencyList = self.model:getCurrentTabCurrencyList()
	local currentItemIdSet = {}

	for _, item in ipairs(negativeMoneyList) do
		currentItemIdSet[item.itemId] = true
	end

	local hasNegativeCurrencyInBar = false

	for _, currency in ipairs(currencyList) do
		if currentItemIdSet[currency.itemId] then
			hasNegativeCurrencyInBar = true

			break
		end
	end

	local shouldShowMinusBtn = self.view.listCurrency and self.view.listCurrency.gameObject.activeInHierarchy and hasNegativeCurrencyInBar

	if showRecoveredToast and self._isShowing then
		for itemId in pairs(self._currencyPenaltyItemIdSet) do
			if not currentItemIdSet[itemId] then
				local itemName = pg.getLocalizationText(ItemData[itemId].itemName)

				pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("CASH_SHOP_PENALTY_RECOVER_TOAST"), itemName))
			end
		end
	end

	self._currencyPenaltyItemIdSet = currentItemIdSet

	self.view:setCurrencyPenaltyVisible(shouldShowMinusBtn)
end

function CashShopCtrl:onItemListReceived(categoryId, itemList)
	self.model:setItemList(categoryId, itemList)

	if self.curComponent and self.curComponent.categoryId == categoryId then
		self.curComponent:onItemListReceived(itemList)
	end
end

function CashShopCtrl:onBuyBtnClick(itemId, count)
	if self.model:isItemSoldOut(itemId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_SOLD_OUT"))

		return
	end

	if self.model:isItemReachLimit(itemId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_REACH_LIMIT"))

		return
	end

	ClientCashShopUtils.requestBuyItem(itemId, count)
end

function CashShopCtrl:onBuyItemResult(result)
	if not result.success then
		logger:warning("onBuyItemResult: 购买失败, errCode=%s", tostring(result.errCode))
		pg.global.ui.tips:showTextTip(pg.getGameString("CASH_SHOP_BUY_FAIL"))

		return
	end

	pg.game.audio:playEvent(AudioConst.SFX_UI_SHOP_BUY)

	if self.curComponent then
		self.curComponent:onBuyItemResult(result)
	end
end

function CashShopCtrl:onCashShopRewardChanged()
	if self.curComponent and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end

	CashShopRedDotUtils.refreshGiftPackTabRedDots()
	CashShopRedDotUtils.refreshRedDot()
end

function CashShopCtrl:onActivityDayUpdated()
	local isGiftPackPage = self.model:getCurrentTabId() == CashShopConst.CategoryType.GIFTPACK

	if isGiftPackPage and self.curComponent and self.curComponent.refreshPage then
		self.curComponent:refreshPage()
	end

	CashShopRedDotUtils.refreshGiftPackTabRedDots()
	CashShopRedDotUtils.refreshRedDot(CashShopConst.CategoryType.GIFTPACK)
end

function CashShopCtrl:onCommonSwitchStateChanged()
	if CommonSwitch.ShopMall_All ~= true then
		self:dismiss()

		return
	end

	self:_refreshMoneyList()

	local currentTabId = self.model:getCurrentTabId()
	local visibleTabs, targetTabId = self:_getVisibleTabs(currentTabId)

	if not visibleTabs or #visibleTabs == 0 then
		return
	end

	self.view:setFirstTabList(visibleTabs, targetTabId, function(tabId)
		self:onFirstTabSelected(tabId)
	end)

	if not targetTabId then
		return
	end

	if currentTabId ~= targetTabId then
		self:onFirstTabSelected(targetTabId)
	else
		self.view:refreshFirstTabSelected(targetTabId)
		self:_refreshCurrencyList()
		self:_refreshCurrencyPenalty(false)

		if self.view.btnSearch then
			local tabCfg = ShopmallTabData[targetTabId]
			local showSearch = tabCfg and tabCfg.showSearch == 1

			self.view.btnSearch.gameObject:SetActiveEx(showSearch)
		end

		if self.curComponent and self.curComponent.refreshPage then
			self.curComponent:refreshPage()
		end
	end

	CashShopRedDotUtils.refreshGiftPackTabRedDots()
	CashShopRedDotUtils.refreshRedDot()
end

function CashShopCtrl:showFriendList(commodityId, productInfo)
	if not self.friendComponent then
		return
	end

	self._giftCommodityId = commodityId

	self:_setListCurrencyVisible(false)
	self.friendComponent.gameObject:SetActiveEx(true)
	self.friendComponent:refreshFriendList(self.friendComponent.OpenType.CashShop, {
		giftCommodityId = self._giftCommodityId,
		productInfo = productInfo,
		categoryType = self.model:getCurrentTabId()
	})
	self:_wrapFriendCloseHandlers()

	local friendList = pg.game.chat:getFriendList() or {}
	local friendIds = {}

	for _, friend in ipairs(friendList) do
		friendIds[#friendIds + 1] = friend.playerId
	end

	self.model:requestFriendShopStatus(friendIds, commodityId, function(hasGiftMap)
		if not self.friendComponent or self._giftCommodityId ~= commodityId then
			return
		end

		self.friendComponent:setHasGiftMap(hasGiftMap)
	end)
end

function CashShopCtrl:_setListCurrencyVisible(visible)
	if self.view and self.view.listCurrency then
		self.view.listCurrency.gameObject:SetActiveEx(visible)

		if visible and self.model then
			self:_refreshCurrencyList()
		end

		self:_refreshCurrencyPenalty(false)
	end
end

function CashShopCtrl:onCashGiftPanelClosed()
	self:_setListCurrencyVisible(true)
end

function CashShopCtrl:_wrapFriendCloseHandlers()
	if self._friendCloseHandlersWrapped or not self.friendComponent then
		return
	end

	self._friendCloseHandlersWrapped = true

	self:_wrapFriendCloseButton(self.friendComponent.btnCloseUButton)
	self:_wrapFriendCloseButton(self.friendComponent.bgCloseUButton)
end

function CashShopCtrl:_wrapFriendCloseButton(button)
	if not button then
		return
	end

	local original = button.luaClick

	function button.luaClick()
		if original then
			original()
		end

		self:_setListCurrencyVisible(true)
	end
end

return CashShopCtrl
