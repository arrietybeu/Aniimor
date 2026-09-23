-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashGift\\CashGiftCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashGiftCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local CashShopConst = require("Const.CashShopConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local CashGiftModel = require("Guis.Panels.CashGift.CashGiftModel")
local CashGiftView = require("Guis.Panels.CashGift.CashGiftView")
local CashGiftCtrl = Class.LightClass("CashGiftCtrl", UICtrl)

CashGiftCtrl.modelClz = CashGiftModel
CashGiftCtrl.viewClz = CashGiftView
CashGiftCtrl.messages = {
	[MessageName.CASH_SHOP_ON_BUY_ITEM] = {
		"onGiveResult",
		true
	}
}

function CashGiftCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._commodityId = info.commodityId
	self.productInfo = info.productInfo
	self.categoryType = info.categoryType
	self._playerId = info.playerId
	self._buyCount = 1

	self.model:setCommodityId(self._commodityId)
	self.model:setReceiverGender(self:_resolveReceiverGender(info.receiverGender))
	self.model:setHasProductInfo(self.productInfo)
	self.view:setupGiftView(self.model)
	self:addListener()
end

function CashGiftCtrl:_resolveReceiverGender(receiverGender)
	receiverGender = tonumber(receiverGender)

	if receiverGender then
		return receiverGender
	end

	local playerInfo = pg.game.chat:getPlayerInfo(self._playerId)
	local presetData = playerInfo and pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey)

	return presetData and tonumber(presetData.body) or nil
end

function CashGiftCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:_refreshAll()
end

function CashGiftCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CashGiftCtrl:onShow()
	return
end

function CashGiftCtrl:onHide()
	facade:sendMsgToUI(MessageName.CASH_GIFT_PANEL_CLOSED)
end

function CashGiftCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnBuy.luaClick()
		self:_onConfirmGift()
	end

	if self.view.numSelector then
		function self.view.numSelector.luaValueChanged(value)
			self._buyCount = value

			self:_refreshCost()
		end
	end

	if self.view.msgInputField then
		function self.view.msgInputField.luaValueChanged(text)
			self:_refreshMsgInputLimit(text)
		end
	end
end

function CashGiftCtrl:_refreshAll()
	self._buyCount = 1

	self.view:refreshCommodityInfo(self.model)
	self:_refreshPlayerInfo()
	self:_refreshCost()

	if not self.productInfo then
		local cost = self.model:getCost()

		self.view:refreshCurrencyList(cost)
	else
		self.view:refreshCurrencyList(nil)
	end

	if self.model:isSuit() or self.model:isGiftBox() then
		self.view:refreshItemList(self.model:getSuitOrGiftItemList())
	end

	self:_refreshMsgInputLimit(self.view.msgInputField and self.view.msgInputField.text or "")
end

function CashGiftCtrl:_refreshPlayerInfo()
	local playerId = self._playerId
	local displayName = LuaUIUtils.getPlayerDisplayName(tostring(playerId))
	local _h = CashGiftCtrl._platformHooks

	if _h and _h.resolveGiftReceiverName then
		displayName = _h.resolveGiftReceiverName(self, tostring(playerId), displayName)
	end

	self.view:refreshPlayerInfo(displayName)
end

function CashGiftCtrl:_refreshCost()
	if self.productInfo then
		local priceText = RechargeUtils.getProductsPrice(self.productInfo)

		self.view:refreshCostByProductPrice(priceText)
	else
		local cost, errorCode = self.model:getCost(self._buyCount)

		self._costCalcErr = errorCode

		self.view:refreshCostDisplay(cost, self._buyCount)
	end
end

function CashGiftCtrl:_refreshMsgInputLimit(text)
	local maxLen = self.model:getSendLimit()
	local finalText = text or ""
	local len = finalText ~= "" and string.utf8len(finalText) or 0

	if maxLen > 0 and maxLen < len then
		finalText = string.utf8sub(finalText, 1, maxLen)
		len = string.utf8len(finalText)

		if self.view and self.view.msgInputField then
			self.view.msgInputField:SetTextWithoutNotify(finalText)
		end
	end

	if self.view then
		self.view:refreshInputLimit(len, maxLen)
	end
end

function CashGiftCtrl:_onConfirmGiftImpl()
	local giftMsg = self.view.msgInputField and self.view.msgInputField.text or ""

	pg.me:sensitiveWordsCheck(giftMsg, function(text)
		if self.productInfo then
			self:sendProductGit(text)
		else
			self:sendShopGiit(text)
		end
	end)
end

function CashGiftCtrl:_onConfirmGift()
	local _h = CashGiftCtrl._platformHooks

	if _h and _h._onConfirmGift then
		return _h._onConfirmGift(self)
	end

	self:_onConfirmGiftImpl()
end

function CashGiftCtrl:sendProductGit(giftMsg)
	pg.game.recharge:requestBuy(self.productInfo.packageId, self.productInfo.productId, self.productInfo.cfgInfo and self.productInfo.cfgInfo.des or "", self.categoryType, function()
		self:onGiveSuccess()
	end, self._playerId, giftMsg)
end

function CashGiftCtrl:sendShopGiit(giftMsg)
	local cost, errorCode = self.model:getCost(self._buyCount)

	if errorCode then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	local canAfford, _, _, affordErrorCode = ClientCashShopUtils.canAffordCommodity(self._commodityId, self._buyCount, {
		forGive = true
	})

	if affordErrorCode then
		ClientCashShopUtils.showCommodityPriceCalcError(affordErrorCode)

		return
	end

	if cost and cost[1] and not canAfford then
		local costItemCfg = ItemData[cost[1]]

		if costItemCfg then
			pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, pg.getLocalizationText(costItemCfg.itemName))
		end

		return
	end

	ClientCashShopUtils.openGiveConfirm(self._playerId, self._commodityId, cost, self._buyCount, giftMsg, self.model:getReceiverGender())
end

function CashGiftCtrl:onGiveSuccess()
	pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_GIVE_GIFT_SUCCESS"))
	self:dismiss()
end

function CashGiftCtrl:onGiveResult(result)
	if result.success and result.give then
		self:onGiveSuccess()
	end
end

return CashGiftCtrl
