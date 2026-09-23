-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Lottery\\LotteryCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("LotteryCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LotteryModel = require("Guis.Panels.Lottery.LotteryModel")
local LotteryMainComponent = require("Guis.Panels.Lottery.Component.LotteryMainComponent")
local LotteryRewardShowComponent = require("Guis.Panels.Lottery.Component.LotteryRewardShowComponent")
local AvatarPreviewComponent = require("Guis.Panels.CashShop.Component.AvatarPreviewComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LotteryUtils = require("Utils.LotteryUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local CashShopConst = require("Const.CashShopConst")
local ClientUtils = require("Utils.ClientUtils")
local LotteryCtrl = Class.LightClass("LotteryCtrl", UICtrl)

LotteryCtrl.modelClz = LotteryModel
LotteryCtrl.messages = {
	[MessageName.CURRENCY_CHANGE] = {
		"onLotteryDataChanged",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onLotteryDataChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onLotteryDataChanged",
		true
	}
}

function LotteryCtrl:checkOpenExtra(info)
	return LotteryUtils.isOpen(Utils.isTable(info) and info.drawId or nil)
end

function LotteryCtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	local drawId = Utils.isTable(info) and info.drawId or nil
	local entryConfig = self.model:getEntryConfig(drawId)

	self._uiSceneRes = entryConfig and entryConfig.scene or nil
	self.uiConfig.bgm = entryConfig and entryConfig.bgm or nil

	UICtrl.open(self, info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
end

function LotteryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.mainComponent = nil
	self._mainLoadSerial = 0
	self.rewardShowComponent = nil
	self._rewardShowLoadSerial = 0
	self._rewardShowLoading = false
	self._suitModelSerial = 0
	self._drawRequestToken = 0
	self._claimTimesRewardRequestToken = 0
	self._drawResultSerial = 0
	self._skinRewardQueue = nil
	self._skinRewardIndex = 0
	self._drawRequestPending = false
	self._drawFlowActive = false
	self._drawStartedDuringEntranceTimeline = false
	self._drawReplacedSuitPreview = false
	self._drawItemPurchasePending = false
	self._drawItemPurchaseToken = 0
	self._claimTimesRewardRequestPending = false
	self._usePlayerMirror = false
	self._interactionShowingPet = false
	self._restoreUIAfterEntranceTimeline = false
	self._sceneBlackScreenVisible = false
	self.avatarComponent = AvatarPreviewComponent.new(self, self.view.transform, {
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		sceneType = UISceneConst.LOTTERY_SCENE
	})
end

function LotteryCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			self:onBackButtonClick()
		end
	end

	if self.view.btnInfoUButton then
		function self.view.btnInfoUButton.luaClick()
			self:openRuleDesc()
		end
	end
end

function LotteryCtrl:onBackButtonClick()
	if self.mainComponent and self.mainComponent:closeRewardContainer() then
		return
	end

	if self._rewardShowVisible or self._uiPreviewVisible then
		self:gotoGacha()

		return
	end

	self:dismiss()
end

function LotteryCtrl:closePanel()
	self:onBackButtonClick()
end

function LotteryCtrl:gotoGacha()
	self:openMainUI()

	if self.mainComponent then
		self.mainComponent:setUIHidden(false)
	end
end

function LotteryCtrl:setRewardShowVisible(rewardShowVisible)
	self._rewardShowVisible = rewardShowVisible == true

	self:refreshBackButtonText()
end

function LotteryCtrl:setUIPreviewVisible(visible)
	self._uiPreviewVisible = visible == true

	self:refreshBackButtonText()
end

function LotteryCtrl:refreshBackButtonText()
	local textKey = self._rewardShowVisible and "LOTTERY_BACK_GACHA" or self._uiPreviewVisible and "LOTTERY_SHOW_UI" or "LOTTERY_BACK"

	ClientTextUtils.setText(self.view.txtBack, pg.getGameString(textKey))
end

function LotteryCtrl:onDestroy()
	self:setSceneBlackScreenVisible(false)

	if self.uiScene and self.uiScene.setEntranceTimelinePlayedCallback then
		self.uiScene:setEntranceTimelinePlayedCallback(nil)
	end

	if self.uiScene and self.uiScene.setEntranceTimelineEndCallback then
		self.uiScene:setEntranceTimelineEndCallback(nil)
	end

	self._mainLoadSerial = (self._mainLoadSerial or 0) + 1
	self._rewardShowLoadSerial = (self._rewardShowLoadSerial or 0) + 1
	self._rewardShowLoading = false
	self._suitModelSerial = (self._suitModelSerial or 0) + 1
	self._drawRequestToken = (self._drawRequestToken or 0) + 1
	self._claimTimesRewardRequestToken = (self._claimTimesRewardRequestToken or 0) + 1
	self._drawResultSerial = (self._drawResultSerial or 0) + 1
	self._drawRequestPending = false
	self._drawFlowActive = false
	self._drawStartedDuringEntranceTimeline = false
	self._drawReplacedSuitPreview = false
	self._drawItemPurchasePending = false
	self._drawItemPurchaseToken = (self._drawItemPurchaseToken or 0) + 1
	self._claimTimesRewardRequestPending = false

	self:clearInteractionPreview()
	UICtrl.onDestroy(self)

	self.mainComponent = nil
	self.rewardShowComponent = nil
	self.avatarComponent = nil
	self._suitDisplayInfo = nil
	self._entryConfig = nil
	self._openInfo = nil
	self._skinRewardQueue = nil
	self._pendingDrawItems = nil
	self._pendingDrawCount = nil
end

function LotteryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local drawId = Utils.isTable(info) and info.drawId or nil
	local entryConfig = self.model:getEntryConfig(drawId)

	if not entryConfig then
		self:dismiss()

		return
	end

	self._drawId = tonumber(drawId)
	self._entryConfig = entryConfig
	self._openInfo = Utils.isTable(info) and info or {
		drawId = self._drawId
	}
	self._usePlayerMirror = false
	self._suitDisplayInfo = nil
	self._suitPreviewKey = nil
	self._suitPreviewLoaded = false
	self._mainContainerName = self.model:getMainContainerName(entryConfig)
	self._rewardContainerName = self.model:getRewardContainerName(entryConfig)
	self.uiConfig.bgm = entryConfig.bgm

	self.adapter:refreshUIBgm()

	if self.uiScene and self.uiScene.setEntranceTimeline then
		self.uiScene:setEntranceTimeline(entryConfig.sceneTimeLine)

		if self.uiScene.setEntranceTimelinePlayedCallback then
			self.uiScene:setEntranceTimelinePlayedCallback(function()
				self:onEntranceTimelinePlayed()
			end)
		end

		if self.uiScene.setEntranceTimelineEndCallback then
			self.uiScene:setEntranceTimelineEndCallback(function()
				self:onEntranceTimelineEnd()
			end)
		end

		self:playEntranceTimeline()
	end

	self:setRewardShowVisible(false)

	local hasDesc = entryConfig.desc ~= nil and entryConfig.desc ~= 0

	self.view.btnInfoUButton:SetActive(hasDesc)
	self:refreshCurrency()

	if not self:openMainUI() then
		logger:error("抽奖入口主界面容器打开失败, drawId=%s, mainUI=%s", tostring(drawId), tostring(self._mainContainerName))
		self:dismiss()

		return
	end

	self:loadMainComponent()
end

function LotteryCtrl:loadMainComponent()
	if self.mainComponent then
		self:refreshMainComponent(true)

		return
	end

	local mainContainer = self.view[self._mainContainerName]

	if not mainContainer then
		logger:error("抽奖主界面容器不存在, drawId=%s, mainUI=%s", tostring(self._drawId), tostring(self._mainContainerName))
		self:dismiss()

		return
	end

	self._mainLoadSerial = (self._mainLoadSerial or 0) + 1

	local loadSerial = self._mainLoadSerial

	mainContainer:LoadDefaultUrlManually(function(content)
		if loadSerial ~= self._mainLoadSerial or not self._entryConfig then
			return
		end

		local contentWidget = content or mainContainer.content
		local contentTransform = contentWidget and contentWidget.transform or nil
		local objectReference = contentTransform and contentTransform:GetComponent("ObjectReference") or nil

		if not contentTransform or not objectReference then
			logger:error("抽奖主界面资源缺少 ObjectReference, drawId=%s, mainUI=%s", tostring(self._drawId), tostring(self._mainContainerName))
			self:dismiss()

			return
		end

		self.mainComponent = LotteryMainComponent.new(self, contentTransform)

		if self._restoreUIAfterEntranceTimeline then
			self.mainComponent:setUIHidden(true)
		end

		self:refreshMainComponent(true)
	end)
end

function LotteryCtrl:openMainUI()
	if not self._entryConfig then
		return false
	end

	local opened = self.view:openMainContainer(self._mainContainerName, self._rewardContainerName)

	if opened then
		self:setRewardShowVisible(false)
	end

	return opened
end

function LotteryCtrl:openRewardUI()
	if not self._entryConfig then
		return false
	end

	local opened = self.view:openRewardContainer(self._mainContainerName, self._rewardContainerName)

	if opened then
		self:setRewardShowVisible(true)
		self:loadRewardShowComponent()
	end

	return opened
end

function LotteryCtrl:openLotteryShop(commodityId)
	if not self._drawId or not self._entryConfig then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_SHOP, {
		drawId = self._drawId,
		commodityId = commodityId
	})
end

function LotteryCtrl:openRewardShare()
	if not self._drawId or not self._entryConfig then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_REWARD_SHARE, {
		drawId = self._drawId,
		shareCallback = function(shareInfo)
			self:onShareSuccess(shareInfo)
		end
	})
end

function LotteryCtrl:onShareSuccess(shareInfo)
	if not self._drawId or not self._openInfo then
		return
	end

	local curCanShareCount = self.model:getCurCanShareCount(self._drawId)

	if Utils.isTable(shareInfo) then
		shareInfo.curCanShareCount = curCanShareCount
	end

	self:refreshMainComponent()

	local shareCallback = self._openInfo.shareReward

	if type(shareCallback) == "function" then
		shareCallback(shareInfo)
	end
end

function LotteryCtrl:openHistory()
	if not self._drawId then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_HISTORY, {
		drawId = self._drawId
	})
end

function LotteryCtrl:openLotteryReward(drawItems, skipAnimation, drawCount)
	if not drawItems then
		logger:error("抽奖成功但未返回奖励数据, drawId=%s", tostring(self._drawId))
		self:finishDrawPreview()

		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_REWARD, {
		drawId = self._drawId,
		drawItems = drawItems,
		drawCount = tonumber(drawCount) or 1,
		costInfo = self.model:getDrawCostInfo(self._entryConfig, drawCount, self._drawId),
		skipAnimation = skipAnimation == true,
		shareCallback = self._openInfo and self._openInfo.shareReward or nil,
		drawAgainCallback = function(nextDrawCount, nextSkipAnimation)
			self:requestDraw(nextDrawCount, nextSkipAnimation)
		end
	}, nil, function()
		self:finishDrawPreview()
	end)
end

function LotteryCtrl:finishDrawPreview()
	local shouldReloadSuitPreview = self._drawReplacedSuitPreview == true
	local shouldRestoreAnimation = self._drawStartedDuringEntranceTimeline == true

	self._drawReplacedSuitPreview = false
	self._drawStartedDuringEntranceTimeline = false
	self._drawFlowActive = false

	if shouldReloadSuitPreview then
		self._suitPreviewKey = nil
		self._usePlayerMirror = false

		self:showSuitPreview()

		return
	end

	if shouldRestoreAnimation then
		self:restoreSuitPreviewAnimation()
	end
end

function LotteryCtrl:openSkinResult(drawResultSerial, skinReward)
	if drawResultSerial ~= self._drawResultSerial or not skinReward then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_RESULT, {
		drawId = self._drawId,
		itemId = skinReward.itemId,
		drawItem = skinReward.drawItem,
		poolConfig = skinReward.poolConfig
	}, nil, function()
		self:onSkinResultClosed(drawResultSerial)
	end)
end

function LotteryCtrl:showSkinResult(drawResultSerial, skinReward)
	if drawResultSerial ~= self._drawResultSerial or not skinReward then
		return
	end

	if self.uiScene and self.uiScene.stopEntranceTimeline then
		self.uiScene:stopEntranceTimeline(true)
	end

	self._suitPreviewLoaded = false
	self._suitModelSerial = (self._suitModelSerial or 0) + 1

	local modelSerial = self._suitModelSerial

	if not self.avatarComponent then
		self:openSkinResult(drawResultSerial, skinReward)

		return
	end

	self._drawReplacedSuitPreview = true

	self.avatarComponent:showPlayerWithPreview(skinReward.itemId, nil, function()
		if drawResultSerial ~= self._drawResultSerial or modelSerial ~= self._suitModelSerial then
			return
		end

		if self.uiScene and self.uiScene.setResultPreviewTransform then
			self.uiScene:setResultPreviewTransform(skinReward.transform)
		end

		self:openSkinResult(drawResultSerial, skinReward)
	end)
end

function LotteryCtrl:showNextSkinResult(drawResultSerial)
	if drawResultSerial ~= self._drawResultSerial then
		return
	end

	self._skinRewardIndex = (self._skinRewardIndex or 0) + 1

	local skinReward = self._skinRewardQueue and self._skinRewardQueue[self._skinRewardIndex] or nil

	if skinReward then
		self:showSkinResult(drawResultSerial, skinReward)

		return
	end

	local drawItems = self._pendingDrawItems
	local skipAnimation = self._pendingDrawSkipAnimation == true
	local drawCount = self._pendingDrawCount

	self._skinRewardQueue = nil
	self._skinRewardIndex = 0
	self._pendingDrawItems = nil
	self._pendingDrawSkipAnimation = nil
	self._pendingDrawCount = nil

	self:openLotteryReward(drawItems, skipAnimation, drawCount)
end

function LotteryCtrl:onSkinResultClosed(drawResultSerial)
	if drawResultSerial ~= self._drawResultSerial then
		return
	end

	self:showNextSkinResult(drawResultSerial)
end

function LotteryCtrl:loadRewardShowComponent()
	if self.rewardShowComponent then
		self:refreshRewardShowComponent()

		return
	end

	if self._rewardShowLoading then
		return
	end

	local rewardContainer = self.view[self._rewardContainerName]

	if not rewardContainer then
		logger:error("抽奖奖励预览容器不存在, drawId=%s, rewardUI=%s", tostring(self._drawId), tostring(self._rewardContainerName))

		return
	end

	self._rewardShowLoadSerial = (self._rewardShowLoadSerial or 0) + 1

	local loadSerial = self._rewardShowLoadSerial

	self._rewardShowLoading = true

	rewardContainer:LoadDefaultUrlManually(function(content)
		if loadSerial ~= self._rewardShowLoadSerial or not self._entryConfig then
			return
		end

		self._rewardShowLoading = false

		local contentWidget = content or rewardContainer.content
		local contentTransform = contentWidget and contentWidget.transform or nil

		if not contentTransform then
			logger:error("抽奖奖励预览资源加载失败, drawId=%s, rewardUI=%s", tostring(self._drawId), tostring(self._rewardContainerName))

			return
		end

		self.rewardShowComponent = LotteryRewardShowComponent.new(self, contentTransform)

		self:refreshRewardShowComponent()
	end)
end

function LotteryCtrl:refreshRewardShowComponent()
	if not self.rewardShowComponent or not self._entryConfig or not self._drawId then
		return
	end

	self.rewardShowComponent:setInfo(self.model:buildRewardShowViewData(self._drawId, self._entryConfig))
end

function LotteryCtrl:refreshMainComponent(refreshPreview)
	if not self.mainComponent or not self._entryConfig or not self._drawId then
		return
	end

	local viewData = self.model:buildMainViewData(self._drawId, self._entryConfig, self._openInfo)

	self.mainComponent:setInfo(viewData)

	if refreshPreview == true then
		self:refreshSuitPreview(viewData.suitDisplayInfo)
	end
end

function LotteryCtrl:refreshSuitPreview(suitDisplayInfo)
	if not self.avatarComponent or not self.uiScene then
		return
	end

	self._suitDisplayInfo = suitDisplayInfo

	if self.uiScene.setPreviewAnimationKey then
		self.uiScene:setPreviewAnimationKey(Utils.isTable(suitDisplayInfo) and suitDisplayInfo.shopAction or nil)
	end

	local suitItemId = Utils.isTable(suitDisplayInfo) and suitDisplayInfo.suitItemId or nil
	local templatePresetKey = Utils.isTable(suitDisplayInfo) and suitDisplayInfo.templatePresetKey or nil
	local previewKey = tostring(suitItemId) .. ":" .. tostring(templatePresetKey)

	if self._suitPreviewKey == previewKey then
		return
	end

	self._suitPreviewKey = previewKey
	self._usePlayerMirror = false

	self:showSuitPreview()
end

function LotteryCtrl:showSuitPreview(onLoaded)
	local suitDisplayInfo = self._suitDisplayInfo
	local avatarComponent = self.avatarComponent

	if not Utils.isTable(suitDisplayInfo) or not avatarComponent or not self.uiScene then
		return false
	end

	self._suitModelSerial = (self._suitModelSerial or 0) + 1

	local modelSerial = self._suitModelSerial

	self._interactionShowingPet = false

	local suitItemId = suitDisplayInfo.suitItemId

	if not suitItemId then
		avatarComponent:hideAllEntities()

		self._suitPreviewLoaded = true

		self.uiScene:setAvatarReady(true)

		if onLoaded then
			onLoaded()
		end

		return true
	end

	if self._suitPreviewLoaded then
		self.uiScene:stopEntranceTimeline()
	end

	self._suitPreviewLoaded = false

	self.uiScene:setAvatarReady(false)

	if self._usePlayerMirror or not suitDisplayInfo.templatePresetKey then
		avatarComponent:showPlayerWithPreview(suitItemId, suitDisplayInfo.shopAction, function()
			self:onSuitPreviewLoaded(modelSerial, onLoaded)
		end)

		return true
	end

	avatarComponent:showTemplateAvatar(suitDisplayInfo.templatePresetKey, suitDisplayInfo.shopAction, function()
		if modelSerial ~= self._suitModelSerial or not self.avatarComponent then
			return
		end

		self.avatarComponent:templateEquip(suitItemId)
		self:onSuitPreviewLoaded(modelSerial, onLoaded)
	end)

	return true
end

function LotteryCtrl:onSuitPreviewLoaded(modelSerial, onLoaded)
	if modelSerial ~= self._suitModelSerial or not self.uiScene then
		return
	end

	self._suitPreviewLoaded = true

	self.uiScene:setAvatarReady(true)

	if onLoaded then
		onLoaded()
	end
end

function LotteryCtrl:restoreSuitPreviewAnimation()
	if not self._suitPreviewLoaded or self._interactionShowingPet or not self.uiScene or not self.uiScene.restorePreviewAnimation then
		return
	end

	self.uiScene:restorePreviewAnimation()
end

function LotteryCtrl:switchMakeup()
	if not Utils.isTable(self._suitDisplayInfo) or self._suitDisplayInfo.canSwitchMakeup ~= true then
		return
	end

	self._usePlayerMirror = not self._usePlayerMirror

	self:showSuitPreview()
end

function LotteryCtrl:onLotteryDataChanged()
	self:refreshCurrency()
	self:refreshMainComponent()
end

function LotteryCtrl:refreshCurrency()
	if not self.view or not self.view.listCurrencyUList or not self._entryConfig then
		return
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, self.model:getCurrencyList(self._entryConfig))
end

function LotteryCtrl:setSkipAnimation(skipAnimation)
	if not self._openInfo then
		return
	end

	self._openInfo.skipAnimation = skipAnimation == true

	if self.mainComponent then
		self.mainComponent:setSkipAnimation(self._openInfo.skipAnimation)
	end
end

function LotteryCtrl:requestDraw(drawCount, skipAnimation)
	drawCount = tonumber(drawCount)

	if not pg.me or not self._drawId or not drawCount or self._drawRequestPending or self._drawItemPurchasePending then
		return
	end

	drawCount = math.max(1, math.floor(drawCount))

	local costInfo = self.model:getDrawCostInfo(self._entryConfig, drawCount, self._drawId)
	local costItemId = tonumber(costInfo.itemId)
	local consumeNum = math.max(1, math.floor(tonumber(costInfo.consumeNum) or 1))

	if costItemId and costItemId > 0 then
		local ownNum = ClientUtils.getItemCountById(costItemId) or 0

		if ownNum < consumeNum then
			self:openMissingDrawItemBuyConfirm(drawCount, skipAnimation, costItemId, consumeNum - ownNum)

			return
		end
	end

	self:sendDrawRequest(drawCount, skipAnimation)
end

function LotteryCtrl:openMissingDrawItemBuyConfirm(drawCount, skipAnimation, costItemId, missingCount)
	local commodityId = self.model:getDrawItemCommodityId()
	local commodityConfig = commodityId and ClientCashShopUtils.getCommodityData(commodityId) or nil

	missingCount = math.max(1, math.floor(tonumber(missingCount) or 1))

	if not commodityConfig then
		logger:error("抽奖道具快捷购买商品配置不存在, drawId=%s, commodityId=%s", tostring(self._drawId), tostring(commodityId))
		ClientUtils.showBubbleMessage(NoticeDef.SHOP_CONFIG_PARAM_ERROR)

		return
	end

	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, missingCount)

	if not costs then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	local primaryCost = costs[1]
	local summaryCost = primaryCost and {
		primaryCost.itemId,
		primaryCost.totalPrice
	} or nil
	local costIcon = summaryCost and LuaUIUtils.getItemShowText(summaryCost[1]) or ""
	local desc = pg.getFormatText(pg.getGameString("SHOP_BUY_SELF"), costIcon, summaryCost and (summaryCost[2] or 0) or 0)

	ClientCashShopUtils.openBuyCommonUseConfirm(commodityId, missingCount, desc, function()
		self:confirmMissingDrawItemPurchase(commodityId, missingCount, drawCount, skipAnimation, costItemId)
	end, summaryCost)
end

function LotteryCtrl:confirmMissingDrawItemPurchase(commodityId, buyCount, drawCount, skipAnimation, costItemId)
	if not pg.me or not self._drawId or self._drawItemPurchasePending or not self:checkUIOpen() or self:checkUIClosing() then
		return
	end

	local commodityConfig = ClientCashShopUtils.getCommodityData(commodityId)
	local costs, errorCode = ClientCashShopUtils.getCommodityCostList(commodityId, buyCount)

	if not commodityConfig or not costs then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	local notEnoughCost

	for _, cost in ipairs(costs) do
		local currencyId = tonumber(cost.itemId)
		local needCount = tonumber(cost.totalPrice) or 0
		local ownNum = currencyId and (ClientUtils.getItemCountById(currencyId) or 0) or 0

		if ownNum < needCount then
			notEnoughCost = cost

			break
		end
	end

	if not notEnoughCost then
		self:purchaseMissingDrawItems(commodityId, buyCount)

		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_QUICK_PAYMENT) then
		return
	end

	RechargeUtils.openQuickPay({
		itemId = tonumber(commodityConfig.itemId) or costItemId,
		itemNum = (tonumber(commodityConfig.num) or 1) * buyCount,
		needCount = tonumber(notEnoughCost.totalPrice) or 0,
		currencyID = tonumber(notEnoughCost.itemId),
		categoryType = CashShopConst.CategoryType.ITEM,
		buyCallBack = function()
			self:openMissingDrawItemBuyConfirm(drawCount, skipAnimation, costItemId, buyCount)
		end
	})
end

function LotteryCtrl:purchaseMissingDrawItems(commodityId, buyCount)
	if not pg.me or not self._drawId or self._drawItemPurchasePending or not self:checkUIOpen() or self:checkUIClosing() then
		return
	end

	self._drawItemPurchaseToken = (self._drawItemPurchaseToken or 0) + 1

	local purchaseToken = self._drawItemPurchaseToken
	local requestDrawId = self._drawId

	self._drawItemPurchasePending = true

	ClientCashShopUtils.requestBuyItem(commodityId, buyCount, nil, function(noticeId)
		if purchaseToken == self._drawItemPurchaseToken then
			self._drawItemPurchasePending = false
		end

		if purchaseToken ~= self._drawItemPurchaseToken or requestDrawId ~= self._drawId or not self:checkUIOpen() or self:checkUIClosing() then
			return
		end

		if noticeId ~= NoticeDef.SUCCESS then
			if noticeId then
				ClientUtils.showBubbleMessage(noticeId)
			end

			return
		end

		self:refreshCurrency()
		self:refreshMainComponent()
	end)
end

function LotteryCtrl:sendDrawRequest(drawCount, skipAnimation)
	self._drawRequestToken = self._drawRequestToken + 1

	local requestToken = self._drawRequestToken
	local requestDrawId = self._drawId

	self._drawStartedDuringEntranceTimeline = self.uiScene and self.uiScene.isEntranceTimelinePlaying and self.uiScene:isEntranceTimelinePlaying() == true or false
	self._drawReplacedSuitPreview = false
	self._drawRequestPending = true

	pg.me:serverMsg("RPC_CS_GachaDraw", requestDrawId, drawCount, function(noticeId, drawItems)
		if requestToken == self._drawRequestToken then
			self._drawRequestPending = false
		end

		if requestToken ~= self._drawRequestToken or requestDrawId ~= self._drawId or not self:checkUIOpen() or self:checkUIClosing() then
			return
		end

		if noticeId ~= NoticeDef.SUCCESS then
			self._drawStartedDuringEntranceTimeline = false

			if noticeId then
				pg.global.showBubbleMessageById(noticeId)
			end

			return
		end

		self:onDrawResult(drawItems, skipAnimation, drawCount)
	end)
end

function LotteryCtrl:onDrawResult(drawItems, skipAnimation, drawCount)
	self._drawFlowActive = true
	self._lastDrawItems = drawItems
	self._lastDrawSkipAnimation = skipAnimation == true

	self:refreshCurrency()
	self:refreshMainComponent()

	self._drawResultSerial = (self._drawResultSerial or 0) + 1
	self._skinRewardQueue = nil
	self._skinRewardIndex = 0
	self._pendingDrawItems = nil
	self._pendingDrawSkipAnimation = nil
	self._pendingDrawCount = nil

	self:openLotteryReward(drawItems, self._lastDrawSkipAnimation, drawCount)
end

function LotteryCtrl:claimTimesReward(rewardIndex)
	rewardIndex = tonumber(rewardIndex)

	if not pg.me or not self._drawId or not rewardIndex or self._claimTimesRewardRequestPending then
		return
	end

	self._claimTimesRewardRequestToken = self._claimTimesRewardRequestToken + 1

	local requestToken = self._claimTimesRewardRequestToken
	local requestDrawId = self._drawId

	self._claimTimesRewardRequestPending = true

	pg.me:serverMsg("RPC_CS_GachaClaimTimesReward", requestDrawId, rewardIndex, function(noticeId)
		if requestToken == self._claimTimesRewardRequestToken then
			self._claimTimesRewardRequestPending = false
		end

		if requestToken ~= self._claimTimesRewardRequestToken or requestDrawId ~= self._drawId or not self:checkUIOpen() or self:checkUIClosing() then
			return
		end

		if noticeId ~= NoticeDef.SUCCESS then
			if noticeId then
				pg.global.showBubbleMessageById(noticeId)
			end

			return
		end

		self:refreshMainComponent()
	end)
end

function LotteryCtrl:playEntranceTimeline()
	if self.uiScene and self.uiScene.stopEntranceTimeline then
		self.uiScene:stopEntranceTimeline()
	end

	self:setSceneBlackScreenVisible(true)

	local played = self.uiScene and self.uiScene.playEntranceTimeline and self.uiScene:playEntranceTimeline() == true

	self._restoreUIAfterEntranceTimeline = played == true

	if not played then
		self:setSceneBlackScreenVisible(false)
		self:onEntranceTimelineEnd()

		return
	end

	if self.mainComponent then
		self.mainComponent:setUIHidden(true)
	end
end

function LotteryCtrl:onEntranceTimelinePlayed()
	self:setSceneBlackScreenVisible(false)
end

function LotteryCtrl:onEntranceTimelineEnd()
	self:setSceneBlackScreenVisible(false)

	if not self._restoreUIAfterEntranceTimeline then
		return
	end

	self._restoreUIAfterEntranceTimeline = false

	if self.mainComponent then
		self.mainComponent:setUIHidden(false)
	end
end

function LotteryCtrl:setSceneBlackScreenVisible(visible)
	visible = visible == true

	if self._sceneBlackScreenVisible == visible then
		return
	end

	self._sceneBlackScreenVisible = visible

	if self.view and self.view.setSceneBlackScreenVisible then
		self.view:setSceneBlackScreenVisible(visible)
	end
end

function LotteryCtrl:clearInteractionPreview()
	if self.mainComponent and self.mainComponent.clearInteractionPreview then
		self.mainComponent:clearInteractionPreview(false)
	elseif self.avatarComponent and self.avatarComponent.clearSuitPowerPreviewState then
		self.avatarComponent:clearSuitPowerPreviewState()
	end
end

function LotteryCtrl:isInteractionShowingPet()
	return self._interactionShowingPet == true
end

function LotteryCtrl:stopInteractionEntranceTimeline()
	if self.uiScene and self.uiScene.stopEntranceTimeline then
		self.uiScene:stopEntranceTimeline()
	end
end

function LotteryCtrl:showInteractionPlayer(onLoaded)
	return self:showSuitPreview(onLoaded)
end

function LotteryCtrl:showInteractionPet(petTemplateId, onLoaded)
	if not self.avatarComponent or not self.uiScene or not petTemplateId then
		return false
	end

	if self.uiScene.stopEntranceTimeline then
		self.uiScene:stopEntranceTimeline()
	end

	self._suitModelSerial = (self._suitModelSerial or 0) + 1

	local modelSerial = self._suitModelSerial

	self._suitPreviewLoaded = false

	self.uiScene:setAvatarReady(false)

	local entity = self.avatarComponent:showPetByModelingId(petTemplateId, nil, nil, nil, nil, function()
		if modelSerial ~= self._suitModelSerial or not self.avatarComponent or not self.uiScene then
			return
		end

		self._suitPreviewLoaded = true

		self.uiScene:setAvatarReady(true)

		if onLoaded then
			onLoaded()
		end
	end)

	self._interactionShowingPet = entity ~= nil

	return self._interactionShowingPet
end

function LotteryCtrl:openRuleDesc()
	if not self._entryConfig or not self._entryConfig.desc then
		return
	end

	pg.global.ui.tips:openEventRuleDesc(pg.getLocalizationText(self._entryConfig.desc))
end

function LotteryCtrl:onShow()
	self:refreshMainComponent(false)
end

function LotteryCtrl:onHide()
	self._drawRequestToken = self._drawRequestToken + 1
	self._claimTimesRewardRequestToken = self._claimTimesRewardRequestToken + 1
	self._drawRequestPending = false
	self._claimTimesRewardRequestPending = false

	self:clearInteractionPreview()

	self._interactionShowingPet = false
	self._suitPreviewKey = nil

	if self.uiScene and self.uiScene.stopEntranceTimeline then
		self.uiScene:stopEntranceTimeline()
	end
end

function LotteryCtrl:onVisibleChange(visible)
	UICtrl.onVisibleChange(self, visible)

	if not self.uiScene or not self.avatarComponent then
		return
	end

	if visible then
		self.avatarComponent:registerGesture()

		if not self._drawFlowActive then
			self:restoreSuitPreviewAnimation()
		end
	elseif self.avatarComponent then
		self.avatarComponent:unRegisterGesture()
	end
end

return LotteryCtrl
