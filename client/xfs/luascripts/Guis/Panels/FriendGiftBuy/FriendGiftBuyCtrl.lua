-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGiftBuy\\FriendGiftBuyCtrl.lua

local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendGiftBuyCtrl = Class.LightClass("FriendGiftBuyCtrl", UICtrl)

FriendGiftBuyCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onResourceChanged",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onResourceChanged",
		true
	},
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItems",
		true
	}
}

function FriendGiftBuyCtrl:checkCanOpen(showNotice, info)
	if not UICtrl.checkCanOpen(self, showNotice, info) then
		return false
	end

	local _, errorCode = self:resolveOpenCommodity(info)

	if not errorCode then
		return true
	end

	if showNotice then
		ClientUtils.showBubbleMessage(errorCode)
	end

	return false
end

function FriendGiftBuyCtrl:resolveOpenCommodity(info)
	local itemId = info and info.itemId
	local commodityId, errorCode = self.model:resolveCommodityId(itemId)

	if errorCode then
		return nil, errorCode
	end

	errorCode = self.model:validateCommodity(commodityId, 1)

	if errorCode then
		return nil, errorCode
	end

	local _, costErrorCode = self.model:getPrimaryCost(commodityId, 1)

	return commodityId, costErrorCode
end

function FriendGiftBuyCtrl:addListener()
	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmBuy()
	end

	function self.view.numSelectorUNumSelector.luaValueChanged(value)
		self:onBuyCountChanged(value)
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end
end

function FriendGiftBuyCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local commodityId, errorCode = self:resolveOpenCommodity(info)

	if errorCode then
		ClientUtils.showBubbleMessage(errorCode)
		self:dismiss()

		return
	end

	self.openSerial = (self.openSerial or 0) + 1
	self.itemId = info.itemId
	self.commodityId = commodityId
	self.buyCount = info.buyCount

	ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getGameString("FRIEND_GIFT_BUY_TITLE"))
	self:refreshUI()
end

function FriendGiftBuyCtrl:isPurchaseContextCurrent(openSerial, commodityId, buyCount)
	return self._isOpen and self.openSerial == openSerial and self.commodityId == commodityId and self.buyCount == buyCount
end

function FriendGiftBuyCtrl:refreshUI()
	local ownCount = ItemUtils.getItemCountById(pg.me, self.itemId)

	LuaUIUtils.renderRewardItem(self.view.itemUButton, {
		id = self.itemId,
		num = ownCount
	})
	ClientTextUtils.setText(self.view.itemNameUSDFText, LuaUIUtils.getNameByItemId(self.itemId))
	self:refreshNumSelector()
	self:refreshCost()

	local confirmObjectReference = self.view.btnConfirmUButton:GetComponent("ObjectReference")
	local txtNameUText = confirmObjectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("MONTH_CARD_BUTTON"))
end

function FriendGiftBuyCtrl:refreshNumSelector()
	local selector = self.view.numSelectorUNumSelector
	local maxCount = self.model:getMaxBuyCount(self.commodityId)

	selector.minValue = 1
	selector.maxValue = maxCount
	self.buyCount = math.min(self.buyCount, maxCount)

	selector:SetValueWithoutNotify(self.buyCount)
end

function FriendGiftBuyCtrl:onBuyCountChanged(value)
	self.buyCount = value

	self:refreshCost()
end

function FriendGiftBuyCtrl:refreshCost()
	local cost, errorCode = self.model:getPrimaryCost(self.commodityId, self.buyCount)

	if errorCode then
		ClientUtils.showBubbleMessage(errorCode)
		self:dismiss()

		return
	end

	local ownCount = self.model:getCostItemOwnCount(cost[1])
	local costText = ClientTextUtils.formatSeparatedNumber(cost[2])

	if ownCount < cost[2] then
		costText = pg.getFormatText("<style=Debuff>{0}</style>", costText)
	end

	ClientTextUtils.setText(self.view.text1ConsumeUSDFText, pg.getGameString("CONSUME_LABEL"))
	ClientTextUtils.setText(self.view.textConsumeUSDFText, pg.getFormatText("{0}<nobr>/{1}</nobr>", costText, ClientTextUtils.formatSeparatedNumber(ownCount)))

	self.view.iconUImage.url = LuaUIUtils.getIconByItemId(cost[1])
end

function FriendGiftBuyCtrl:onResourceChanged()
	if not self.commodityId then
		return
	end

	self:refreshUI()
end

function FriendGiftBuyCtrl:onConfirmBuy()
	local errorCode = self.model:validateCommodity(self.commodityId, self.buyCount)

	if errorCode then
		ClientUtils.showBubbleMessage(errorCode)

		return
	end

	local cost

	cost, errorCode = self.model:getPrimaryCost(self.commodityId, self.buyCount)

	if errorCode then
		ClientUtils.showBubbleMessage(errorCode)

		return
	end

	local isEnough, notEnoughItems = self.model:isCurrencyEnough(self.commodityId, self.buyCount)

	if not isEnough then
		self:handleCurrencyNotEnough(notEnoughItems, cost)

		return
	end

	local exchangeNum = self.model:getBoundCashExchangeNum(self.commodityId, self.buyCount)

	if exchangeNum and exchangeNum > 0 then
		self:openBoundCashExchangeConfirm(exchangeNum)

		return
	end

	self:sendBuyRequest(self.openSerial, self.commodityId, self.buyCount)
end

function FriendGiftBuyCtrl:handleCurrencyNotEnough(notEnoughItems, cost)
	if self:tryOpenQuickPay(notEnoughItems, cost) then
		return
	end

	for _, itemId in ipairs(notEnoughItems) do
		local itemConfig = self.model:getItemConfig(itemId)

		ClientUtils.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, pg.getLocalizationText(itemConfig.itemName))
	end
end

function FriendGiftBuyCtrl:tryOpenQuickPay(notEnoughItems, cost)
	local currencyId = cost[1]
	local canQuickPay = currencyId == ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND or currencyId == ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND

	if not canQuickPay or not table.contains(notEnoughItems, currencyId) then
		return false
	end

	local commodityConfig = self.model:getShopItemConfig(self.commodityId)

	RechargeUtils.openQuickPay({
		itemId = commodityConfig.itemId,
		itemNum = commodityConfig.itemNum * self.buyCount,
		needCount = cost[2],
		currencyID = currencyId,
		buyCallBack = CallbackHandler(self, "onQuickPayCompleted", self.openSerial, self.commodityId, self.buyCount)
	})

	return true
end

function FriendGiftBuyCtrl:onQuickPayCompleted(openSerial, commodityId, buyCount)
	if not self:isPurchaseContextCurrent(openSerial, commodityId, buyCount) then
		return
	end

	self:onConfirmBuy()
end

function FriendGiftBuyCtrl:openBoundCashExchangeConfirm(exchangeNum)
	local cashDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND), exchangeNum)
	local coinDesc = pg.getFormatText("{0} {1}", LuaUIUtils.getItemShowText(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND), exchangeNum)
	local changeDesc = pg.getFormatText(self.model:getGameString("SHOPMALL_EXCHANGE_TEXT"), cashDesc, coinDesc)
	local commodityConfig = self.model:getShopItemConfig(self.commodityId)

	pg.global.ui.commonUseConfirm:open({
		muteCheckEnough = true,
		type = 1,
		title = self.model:getGameString("SHOP_BUY_READY"),
		tipTop = changeDesc,
		data = {
			{
				commodityConfig.itemId,
				commodityConfig.itemNum * self.buyCount,
				hideOwnNum = true,
				ownNum = 1
			}
		},
		costId = ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND,
		exchangeCostId = ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND,
		confirmCb = CallbackHandler(self, "sendBuyRequest", self.openSerial, self.commodityId, self.buyCount)
	})
end

function FriendGiftBuyCtrl:sendBuyRequest(openSerial, commodityId, buyCount)
	if not self:isPurchaseContextCurrent(openSerial, commodityId, buyCount) then
		return
	end

	self.model:buyCommodity(self.model:getShopClassifyId(), commodityId, buyCount)
end

function FriendGiftBuyCtrl:onBuyItems(data)
	if data.shopItemId ~= self.commodityId then
		return
	end

	self:dismiss()
end

return FriendGiftBuyCtrl
