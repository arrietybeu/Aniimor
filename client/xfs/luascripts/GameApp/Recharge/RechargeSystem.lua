-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Recharge\\RechargeSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local RechargeData = require("Data.shopmall_recharge_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local CommonSwitch = require("Common.CommonSwitch")
local GlobalData = require("Core.Client.GlobalData")
local ItemData = require("Data.item_data")
local logger = LoggerManager.getLogger("RechargeSystem")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local DIRECT_PURCHASE_TIPS_COOLDOWN = 2592000
local RECHARGE_PENALTY_TIP_COOLDOWN = 86400
local FORCED_DIRECT_BUY_CHANNELS = {
	["google.official.Aof9mf"] = true,
	["google.official.Auktpq"] = true,
	["apple.official.Iwdfss"] = true
}
local FUN_STORE_CONFIG = {
	test = {
		gameProject = "worldx_global",
		baseUrl = ShopConstantData.direct_purchase_web1.number,
		storeUrl = ShopConstantData.direct_purchase_web2.number,
		backupStoreUrl = ShopConstantData.direct_purchase_web3.number
	},
	prod = {
		gameProject = "worldx_global",
		baseUrl = ShopConstantData.direct_purchase_web4.number,
		backupDomains = {
			ShopConstantData.direct_purchase_web5.number
		},
		storeUrl = ShopConstantData.direct_purchase_web6.number,
		backupStoreUrl = ShopConstantData.direct_purchase_web7.number
	}
}
local RechargeSystem = Class.LightClass("RechargeSystem", SystemBase)

function RechargeSystem:onCtor()
	self.rechargeState = RechargeConst.STATE.IDLE
	self.pendingOrder = nil
	self.orderTimerId = nil
	self.paymentTimerId = nil
	self.funStoreInitializing = false
	self.funStoreInitialized = false
	self.funStoreUrl = nil
	self.useFunStore = false
	self.forcedDirectBuyChannel = false
end

function RechargeSystem:onInit()
	return
end

function RechargeSystem:onPlayerInit(player)
	if pg.global.sdkManager:isDouyinCloudChannel() then
		self.useFunStore = false
		self.forcedDirectBuyChannel = false

		return
	end

	self.forcedDirectBuyChannel = self:_checkForcedDirectBuyChannel()

	if self.forcedDirectBuyChannel then
		self.useFunStore = self:isForcedDirectBuyEnabled()
	else
		self.useFunStore = player.PcDirectBuySwitchChecked == true
	end

	if not IS_MOBILE then
		return
	end

	if self.funStoreInitialized or self.funStoreInitializing then
		return
	end

	self:_initFunStore(player)
end

function RechargeSystem:onClear()
	self:resetState()

	self.funStoreInitializing = false
	self.funStoreInitialized = false
	self.funStoreUrl = nil
	self.useFunStore = false
	self.forcedDirectBuyChannel = false
end

function RechargeSystem:onDisconnected()
	if self.pendingOrder and self.pendingOrder.funStoreOpened then
		self:resetState(true)
	end
end

function RechargeSystem:_checkForcedDirectBuyChannel()
	local sdkManager = pg.global and pg.global.sdkManager

	if not sdkManager then
		return false
	end

	return sdkManager:isPkgChannel(FORCED_DIRECT_BUY_CHANNELS)
end

function RechargeSystem:_initFunStore(player)
	local accountId = pg.global.sdkManager:getAccountId()

	if not player or not accountId or accountId == "" then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("initFunStore skipped, player or accountId is not ready")
		end

		return
	end

	self.funStoreInitializing = true

	local config = ClientUtils.isPublicClient() and FUN_STORE_CONFIG.prod or FUN_STORE_CONFIG.test
	local params = {
		base_url = config.baseUrl,
		game_project = config.gameProject,
		uid = player.uid,
		account_id = accountId,
		city_level = player.level,
		server = pg.me.serverArea,
		extend = {
			register_country = player.createIpInfoData and player.createIpInfoData.country or ""
		}
	}

	self:_probeFunStoreUrl(config.storeUrl, function(mainAvailable)
		if not self.funStoreInitializing then
			return
		end

		if mainAvailable then
			self:_finishInitFunStore(config, params, config.storeUrl)

			return
		end

		self:_probeFunStoreUrl(config.backupStoreUrl, function(backupAvailable)
			if not self.funStoreInitializing then
				return
			end

			self:_finishInitFunStore(config, params, backupAvailable and config.backupStoreUrl or config.storeUrl)
		end)
	end)
end

function RechargeSystem:_probeFunStoreUrl(url, callback)
	appFacade.httpManager:LuaHttpGet(url, 0, 3, 0, function(err)
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("probeFunStoreUrl url=%s err=%s", tostring(url), tostring(err))
		end

		callback(err == 0)
	end)
end

function RechargeSystem:_finishInitFunStore(config, params, storeUrl)
	if not pg.me or tostring(pg.me.uid) ~= tostring(params.uid) then
		self.funStoreInitializing = false

		return
	end

	self.funStoreUrl = storeUrl

	pg.global.sdkManager:initFunStore(params, config.backupDomains)

	self.funStoreInitialized = true
	self.funStoreInitializing = false

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("initFunStore baseUrl=%s storeUrl=%s", tostring(config.baseUrl), tostring(storeUrl))
	end
end

function RechargeSystem:setUseFunStore(enabled)
	if self.forcedDirectBuyChannel then
		self.useFunStore = self:isForcedDirectBuyEnabled()

		return self.useFunStore
	end

	if enabled and not self:isDirectBuyAvailable() then
		return false
	end

	local wasUseFunStore = self.useFunStore == true

	self.useFunStore = enabled == true

	pg.me:setDirectBuySwitchChecked(self.useFunStore)

	if self.useFunStore and not wasUseFunStore then
		pg.global.ui.tips:showTextTip(pg.getGameString("Office_pay_tips4"))
	end

	return self.useFunStore
end

function RechargeSystem:isUseFunStore()
	return self.useFunStore
end

function RechargeSystem:isForcedDirectBuyChannel()
	return self.forcedDirectBuyChannel
end

function RechargeSystem:isForcedDirectBuyEnabled()
	return self.forcedDirectBuyChannel and CommonSwitch.CHANNEL_FORCED_DIRECTBUY_SWITCH == true
end

function RechargeSystem:isDirectBuyAvailable()
	if pg.global.sdkManager:isDouyinCloudChannel() then
		return false
	end

	return self:isForcedDirectBuyEnabled() or not self.forcedDirectBuyChannel and CommonSwitch.CHANNEL_DIRECTBUY_SWITCH == true and (IS_MOBILE or UNITY_EDITOR)
end

function RechargeSystem:isDirectBuySwitchAvailable()
	return not self.forcedDirectBuyChannel and self:isDirectBuyAvailable()
end

function RechargeSystem:shouldUseFunStore()
	if self.forcedDirectBuyChannel then
		return self:isForcedDirectBuyEnabled()
	end

	return self:isDirectBuyAvailable() and self.useFunStore
end

function RechargeSystem:_recordDirectPurchaseTipsTime()
	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.DirectPurchaseTipsTs, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
	pg.global.prefsCacheUtils:save()
end

function RechargeSystem:onRechargeRebateRewardGuide(rewardNum)
	if not self:isDirectBuySwitchAvailable() then
		return
	end

	local suppressTime = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.DirectPurchaseRebateGuideSuppressTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if suppressTime > Time.secondCache then
		return
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_DIRECT_PURCHASE) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_DIRECT_PURCHASE, {
		rebateGuide = true,
		rewardNum = rewardNum
	})
end

function RechargeSystem:tryShowFirstDirectPurchaseGuide(target)
	if not self:isDirectBuySwitchAvailable() or self.useFunStore then
		return false
	end

	if pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.DirectPurchaseFirstGuideShown, false, ClientConst.CACHE_TYPE_FLAG.USER) then
		return false
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_DIRECT_PURCHASE) then
		return true
	end

	pg.global.prefsCacheUtils:setBool(ClientConst.PrefKey.DirectPurchaseFirstGuideShown, true, ClientConst.CACHE_TYPE_FLAG.USER)
	pg.global.prefsCacheUtils:save()
	self:openFirstDirectPurchaseGuide(target)

	return true
end

function RechargeSystem:openFirstDirectPurchaseGuide(target)
	if not self:isDirectBuySwitchAvailable() or self.useFunStore then
		return
	end

	if pg.global.ui:checkUIShow(UIConst.UI_ID_DIRECT_PURCHASE) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_DIRECT_PURCHASE, {
		firstGuide = true,
		target = target
	})
end

function RechargeSystem:tryShowDailyDirectPurchaseTips(target)
	if not self:isDirectBuySwitchAvailable() or self.useFunStore or not target then
		return
	end

	if self:tryShowFirstDirectPurchaseGuide(target) then
		return
	end

	local lastShowTime = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.DirectPurchaseTipsTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

	if lastShowTime + DIRECT_PURCHASE_TIPS_COOLDOWN > Time.secondCache then
		return
	end

	self:showDirectPurchaseTips(target)
end

function RechargeSystem:showDirectPurchaseTips(target)
	if not self:isDirectBuySwitchAvailable() or self.useFunStore or not target then
		return
	end

	if not pg.global.ui:checkUIShow(UIConst.UI_ID_DIRECT_PURCHASE_TIPS) then
		self:_recordDirectPurchaseTipsTime()
		pg.global.ui:open(UIConst.UI_ID_DIRECT_PURCHASE_TIPS, {
			target = target
		})
	end
end

function RechargeSystem:confirmDirectPurchaseRebateGuide()
	if not self:isDirectBuySwitchAvailable() then
		return false
	end

	pg.me:claimRechargeRebateReward()

	return self:setUseFunStore(true)
end

function RechargeSystem:confirmFirstDirectPurchaseGuide()
	local enabled = self:setUseFunStore(true)

	if enabled then
		self:_recordDirectPurchaseTipsTime()
	end

	return enabled
end

function RechargeSystem:suppressDirectPurchaseRebateGuide()
	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.DirectPurchaseRebateGuideSuppressTs, Time.secondCache + 2592000, ClientConst.CACHE_TYPE_FLAG.USER)
	pg.global.prefsCacheUtils:save()
end

function RechargeSystem:requestBuy(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
	logger:info("RechargeSystem.requestBuy packageId = %s productId = %s productDes = %s giftUid = %s giftDesc = %s", packageId, productId, productDes, giftUid, giftDesc)

	if not Utils.isRechargeProductSwitchOn(packageId) then
		return
	end

	if self.rechargeState ~= RechargeConst.STATE.IDLE then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("requestBuy ignored, state=%s", tostring(self.rechargeState))
		end

		return
	end

	local rechargeConfig = RechargeData[tostring(packageId)] or RechargeData[packageId]
	local isNormalRecharge = rechargeConfig and rechargeConfig.type == RechargeConst.RECHARGE_TYPE.RECHARGE

	if isNormalRecharge and pg.me:getMoneyNum(RechargeConst.PENALTY_CURRENCY_ID) < 0 then
		local hideTs = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.RechargePenaltyTipTs, 0, ClientConst.CACHE_TYPE_FLAG.USER)

		if hideTs + RECHARGE_PENALTY_TIP_COOLDOWN <= Time.secondCache then
			local itemName = pg.getLocalizationText(ItemData[RechargeConst.PENALTY_CURRENCY_ID].itemName)
			local hideToday = false
			local confirmTitle = pg.getGameString("RECHARGE_PENALTY_CONFIRM_TITLE")
			local confirmDesc = pg.getFormatText(pg.getGameString("RECHARGE_PENALTY_CONFIRM_DESC"), itemName)

			pg.global.showConfirmMsgRaw(confirmTitle, confirmDesc, function()
				if hideToday then
					pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.RechargePenaltyTipTs, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
					pg.global.prefsCacheUtils:save()
				end

				self:_continueRequestBuy(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
			end, nil, nil, nil, nil, {
				textLocalized = true,
				hint = true,
				hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
				hintCb = function(isSelected)
					hideToday = isSelected
				end
			})

			return
		end
	end

	self:_continueRequestBuy(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
end

function RechargeSystem:_continueRequestBuy(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
	if pg.global.platform and pg.global.platform:isPS() then
		logger:warn("requestBuy: open cash confirmation screen, productId=%s, packageId=%s, productDes=%s, categoryType=%s", tostring(productId), tostring(packageId), tostring(productDes), tostring(categoryType))

		local productPayInfo = RechargeUtils.getProductPayInfo(productId)

		if productPayInfo.sdkInfo == nil or not productPayInfo.sdkInfo.displayName or productPayInfo.sdkInfo.displayName == "" or not productPayInfo.sdkInfo.description or productPayInfo.sdkInfo.description == "" then
			PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

			return
		end

		pg.global.ui:open(UIConst.UI_ID_CASH_CONFIRMATION_SCREEN, {
			productId = productId,
			packageId = packageId,
			productDes = productDes,
			categoryType = categoryType,
			callback = callback,
			giftUid = giftUid,
			giftDesc = giftDesc,
			productPayInfo = productPayInfo
		})

		return
	end

	self:ConfirmPurchase(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
end

function RechargeSystem:ConfirmPurchase(packageId, productId, productDes, categoryType, callback, giftUid, giftDesc)
	logger:info("RechargeSystem requestBuy: ConfirmPurchase packageId = %s productId = %s productDes = %s giftUid = %s giftDesc = %s", packageId, productId, productDes, giftUid, giftDesc)

	self.buyCallback = callback

	if giftUid and giftDesc then
		self.giftInfo = {
			uid = giftUid,
			desc = giftDesc
		}
	else
		self.giftInfo = nil
	end

	self.rechargeState = RechargeConst.STATE.REQUESTING
	self.curPayCategoryType = categoryType

	self:startOrderTimer(productId)
	pg.me:createPayOrder(packageId, productId, pg.getLocalizationText(productDes), giftUid or "")
end

function RechargeSystem:tryBuyProduct()
	if self.rechargeState ~= RechargeConst.STATE.PAYING then
		logger:error("confirmBuy: wrong state=%s", tostring(self.rechargeState))

		return
	end

	local order = self.pendingOrder

	if not order then
		logger:error("confirmBuy: no pendingOrder")
		self:resetState()

		return
	end

	self.rechargeState = RechargeConst.STATE.PAYING

	local payLog = {
		order_id = order.orderId,
		base_price = order.price,
		iap_product_id = order.packageId,
		iap_product_name = order.productName,
		from_page = self.curPayCategoryType or "",
		is_sandbox = _G_IsDebugMode and 1 or 0
	}

	LuaUIUtils.sendCustomLog(Const.BILogName.SHOPPING_MALL_START_PAY, payLog)
	pg.global.sdkManager:reportAfFunnel(Const.AFLogName.PAYMENT_START)

	local giftUid = self.giftInfo and self.giftInfo.uid
	local giftDesc = self.giftInfo and self.giftInfo.desc
	local callbackUrl = order.callBackUrl

	if self:shouldUseFunStore() then
		if pg.global.sdkManager:isFunStoreEnabled() then
			order.funStoreCallbackUrl = callbackUrl
			order.funStoreOpened = true
			order.funStoreFallbackTriggered = false

			self:_openFunStore(order, giftUid, giftDesc, callbackUrl)

			return
		elseif self.forcedDirectBuyChannel then
			RechargeUtils.openThirdPartyPay()
			self:resetState(true)

			return
		end
	end

	local isBuy = pg.global.sdkManager:tryBuyProduct(order.productId, order.orderId, order.productName, order.productDesc, order.packageId, order.productIconUrl, giftUid, giftDesc, callbackUrl)

	if not isBuy then
		self:onPayCallback(0)
	else
		self:resetState(true)
	end
end

function RechargeSystem:_openFunStore(order, giftUid, giftDesc, callbackUrl)
	local config = ClientUtils.isPublicClient() and FUN_STORE_CONFIG.prod or FUN_STORE_CONFIG.test
	local extend = {
		roleId = pg.me:getCopyPlayerUid(),
		serverId = pg.me.serverArea,
		oid = order.orderId,
		currency = order.currency,
		currency_symbol = order.currencySymbol,
		sku_id = order.packageId,
		product_icon_url = order.productIconUrl,
		buy_type = order.productType == RechargeConst.RECHARGE_TYPE.RECHARGE and "coin" or "cash"
	}

	if giftUid and giftUid ~= "" then
		extend.gift_uid = giftUid
		extend.gift_desc = giftDesc or ""
	end

	if callbackUrl and callbackUrl ~= "" then
		extend.callbackUrl = callbackUrl
	end

	pg.global.sdkManager:openFunStore({
		product_id = order.productId,
		display_price = order.displayPrice,
		order_id = order.orderId,
		url = self.funStoreUrl,
		extend = extend
	}, pg.me.uid, config.gameProject, GlobalData.Language)

	if self.forcedDirectBuyChannel then
		self:resetState(true)
	end
end

function RechargeSystem:onFunStoreFallbackToIap(productId)
	if self.forcedDirectBuyChannel then
		if self:isForcedDirectBuyEnabled() then
			RechargeUtils.openThirdPartyPay()
		end

		return
	end

	if self.rechargeState ~= RechargeConst.STATE.PAYING then
		return
	end

	local order = self.pendingOrder

	if not order or not order.funStoreOpened or order.funStoreFallbackTriggered then
		return
	end

	if productId and productId ~= "" and tostring(productId) ~= tostring(order.productId) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("FunStore fallback ignored mismatched productId=%s currentProductId=%s", tostring(productId), tostring(order.productId))
		end

		return
	end

	order.funStoreFallbackTriggered = true

	local giftUid = self.giftInfo and self.giftInfo.uid
	local giftDesc = self.giftInfo and self.giftInfo.desc
	local isBuy = pg.global.sdkManager:tryBuyProduct(order.productId, order.orderId, order.productName, order.productDesc, order.packageId, order.productIconUrl, giftUid, giftDesc, order.funStoreCallbackUrl)

	if not isBuy then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("FunStore fallback TryBuy returned false orderId=%s productId=%s", tostring(order.orderId), tostring(order.productId))
		end

		self:onPayCallback(0)
	else
		self:resetState(true)
	end
end

function RechargeSystem:cancelBuy()
	if self.rechargeState == RechargeConst.STATE.IDLE then
		return
	end

	self:resetState()
end

function RechargeSystem:onOrderResponse(packageId, productId, orderId, callBackUrl)
	self:cancelOrderTimer()

	local displayInfo = RechargeUtils.getProductPayInfo(productId)
	local configInfo = RechargeUtils.getProductConfigInfo(productId)

	self.pendingOrder = {
		productId = productId,
		orderId = orderId,
		productName = displayInfo.productName,
		productDesc = displayInfo.productDesc,
		productIconUrl = displayInfo.iconUrl,
		price = displayInfo.sdkInfo and displayInfo.sdkInfo.amount or "0",
		displayPrice = displayInfo.sdkInfo and displayInfo.sdkInfo.price or "",
		currency = displayInfo.sdkInfo and displayInfo.sdkInfo.currency or "",
		currencySymbol = displayInfo.sdkInfo and displayInfo.sdkInfo.currency_symbol or "",
		productType = configInfo and configInfo.type,
		packageId = packageId,
		callBackUrl = callBackUrl
	}
	self.rechargeState = RechargeConst.STATE.PAYING

	self:startPaymentTimer()
	logger:info("onOrderResponse pendingOrder = %s", inspect(self.pendingOrder))
	self:tryBuyProduct()
end

function RechargeSystem:onOrderFail(productId, retStatus)
	logger:warn("onOrderFail productId=%s retStatus=%s", tostring(productId), tostring(retStatus))

	if tonumber(retStatus) == RechargeConst.ORDER_ERROR.INVALID_PRODUCT then
		PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()
	end

	pg.global.showBubbleMessage(60006)
	self:resetState()
end

function RechargeSystem:getState()
	return self.rechargeState
end

function RechargeSystem:getPendingOrder()
	return self.pendingOrder
end

function RechargeSystem:onPayCallback(resCode)
	if resCode == 1 then
		if self.buyCallback then
			self.buyCallback()

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_QUICK_PAYMENT) then
				pg.global.ui:close(UIConst.UI_ID_QUICK_PAYMENT)
			end
		end
	else
		pg.global.showBubbleMessage(60006)

		if self.pendingOrder and self.pendingOrder.orderId then
			pg.me:deletePayOrder(self.pendingOrder.orderId)

			local order = self.pendingOrder
			local payLog = {
				order_id = order.orderId,
				base_price = order.price,
				iap_product_id = order.packageId,
				iap_product_name = order.productName,
				from_page = self.curPayCategoryType or "",
				is_sandbox = _G_IsDebugMode and 1 or 0,
				fail_reason_code = tostring(resCode)
			}

			LuaUIUtils.sendCustomLog(Const.BILogName.PAYMENT_FAIL, payLog)
		end
	end

	self:resetState()
end

function RechargeSystem:startOrderTimer(productId)
	self:cancelOrderTimer()

	self.orderTimerId = self:startTimer(function()
		self:onOrderFail(productId, RechargeConst.ORDER_ERROR.TIMEOUT)
	end, RechargeConst.ORDER_TIMEOUT_SEC)
end

function RechargeSystem:cancelOrderTimer()
	if self.orderTimerId then
		self:killTimer(self.orderTimerId)

		self.orderTimerId = nil
	end
end

function RechargeSystem:startPaymentTimer()
	self:cancelPaymentTimer()

	self.paymentTimerId = self:startTimer(function()
		self:resetState(true)
	end, RechargeConst.PAYMENT_TIMEOUT_SEC)
end

function RechargeSystem:cancelPaymentTimer()
	if self.paymentTimerId then
		self:killTimer(self.paymentTimerId)

		self.paymentTimerId = nil
	end
end

function RechargeSystem:payCoinSuccess(packageId, packageAmount, firstItems, realItems, extraItems)
	local itemList = {}

	for k, v in pairs(realItems) do
		table.insert(itemList, {
			itemId = k,
			itemCount = v
		})
	end

	for k, v in pairs(extraItems) do
		table.insert(itemList, {
			isRechargeAdd = true,
			itemId = k,
			itemCount = v
		})
	end

	for k, v in pairs(firstItems) do
		table.insert(itemList, {
			isRechargeFirst = true,
			itemId = k,
			itemCount = v
		})
	end

	if itemList then
		local cfgInfo = RechargeData[packageId]

		if cfgInfo then
			local skdInfo = RechargeUtils.getSDKProductInfo(cfgInfo.product_id)

			if skdInfo then
				local data = {}

				data.sdkInfo = skdInfo
				data.cfgInfo = cfgInfo

				local strPrice = RechargeUtils.getProductsPrice(data)
				local rechargeDes = packageAmount > 1 and pg.getFormatText(pg.getGameString("SHOP_CHARGE_GET_WEB"), packageAmount, strPrice) or pg.getFormatText(pg.getGameString("SHOP_CHARGE_GET"), strPrice)

				pg.global.ui.itemObtain:open({
					source = 20019,
					itemList = itemList,
					rechargeDes = rechargeDes
				})
			end
		end
	end

	facade:sendMsgToUI(MessageName.CASH_SHOP_REWARD_CHANGED)

	if self.buyCallback and (self.rechargeState == RechargeConst.STATE.IDLE or self.pendingOrder and self.pendingOrder.funStoreOpened) then
		self:onPayCallback(1)
	end
end

function RechargeSystem:resetState(keepBuyCallback)
	self:cancelOrderTimer()
	self:cancelPaymentTimer()

	self.rechargeState = RechargeConst.STATE.IDLE

	if not keepBuyCallback then
		self.buyCallback = nil
	end

	self.pendingOrder = nil
	self.giftInfo = nil
end

return RechargeSystem
