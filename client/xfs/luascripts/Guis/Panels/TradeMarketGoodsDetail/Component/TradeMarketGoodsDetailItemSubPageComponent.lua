-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketGoodsDetailItemSubPageComponent.lua

local Class = require("Core.Framework.Class")
local TradeMarketGoodsDetailSubPageComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsDetailSubPageComponent")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local TradeConst = require("Common.Const.TradeConst")
local TradeMarketGoodsDetailItemSubPageComponent = Class.LightClass("TradeMarketGoodsDetailItemSubPageComponent", TradeMarketGoodsDetailSubPageComponent)

function TradeMarketGoodsDetailItemSubPageComponent:_findObjectRef()
	self.objectReference = self:_getObjectReference()

	if not self.objectReference then
		return
	end

	self.layoutSellObjectReference = self.objectReference:GetRefValue("layoutSellObjectReference")
	self.layoutBuyObjectReference = self.objectReference:GetRefValue("layoutBuyObjectReference")
	self.layoutRemoveObjectReference = self.objectReference:GetRefValue("layoutRemoveObjectReference")
	self.btnAttentionUButton = self.objectReference:GetRefValue("btnAttentionUButton")
	self.progressAttentionUProgress = self.objectReference:GetRefValue("progressAttentionUProgress")
	self.layoutSellObj = self.layoutSellObjectReference.gameObject
	self.layoutBuyObj = self.layoutBuyObjectReference.gameObject
	self.layoutRemoveObj = self.layoutRemoveObjectReference.gameObject
end

function TradeMarketGoodsDetailItemSubPageComponent:onDestroy()
	self.layoutSellObjectReference = nil
	self.layoutBuyObjectReference = nil
	self.layoutRemoveObjectReference = nil
	self.layoutSellObj = nil
	self.layoutBuyObj = nil
	self.layoutRemoveObj = nil
	self.btnBuyUButton = nil
	self.numSelectorBuyUNumSelector = nil
	self.listCoinsUList = nil
	self.isBuying = nil

	TradeMarketGoodsDetailSubPageComponent.onDestroy(self)
end

function TradeMarketGoodsDetailItemSubPageComponent:_addObjectListener()
	self:initFollowView()
	self:initGoodsDetailView()
end

function TradeMarketGoodsDetailItemSubPageComponent:initPage()
	return
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshPage()
	if self.ctrl.operation == TradeMarketUtils.Operation.Buy then
		self:refreshOnBuy()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Sell then
		-- block empty
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Remove then
		-- block empty
	end
end

function TradeMarketGoodsDetailItemSubPageComponent:initGoodsDetailView()
	self.view.btnEllipsesUButton:SetActive(false)

	local itemData = ItemData[self.ctrl.itemId]

	self.view.iconPropUImage:SetActive(true)

	self.view.iconPropUImage.url = itemData.icon

	TradeMarketUtils.renderItemBasicInfo(self.ctrl.itemId, self.objectReference)

	if self.ctrl.operation == TradeMarketUtils.Operation.Buy then
		self.layoutBuyObj:SetActiveEx(true)
		self.layoutSellObj:SetActiveEx(false)
		self.layoutRemoveObj:SetActiveEx(false)

		self.curBuyCount = 1

		self:renderLayoutBuy()
		self:refreshOnBuy()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Sell then
		self.layoutBuyObj:SetActiveEx(false)
		self.layoutSellObj:SetActiveEx(true)
		self.layoutRemoveObj:SetActiveEx(false)

		self.curSellCount = 1
		self.curSinglePrice = 1

		self:renderLayoutSell()
		self:refreshLayoutSell()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Remove then
		self.layoutBuyObj:SetActiveEx(false)
		self.layoutSellObj:SetActiveEx(false)
		self.layoutRemoveObj:SetActiveEx(true)
		self:renderLayoutRemove()
	end
end

function TradeMarketGoodsDetailItemSubPageComponent:renderLayoutBuy()
	local objectReference = self.layoutBuyObjectReference

	self.btnBuyUButton = objectReference:GetRefValue("btnBuyUButton")
	self.numSelectorBuyUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.listCoinsUList = objectReference:GetRefValue("listCoinsUList")

	local btnOC = self.btnBuyUButton:GetComponent("ObjectReference")
	local txtNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("SHOP_BUY"))

	self.curBuyCount = 1
	self.numSelectorBuyUNumSelector.minValue = 1
	self.numSelectorBuyUNumSelector.stepSize = 1

	function self.numSelectorBuyUNumSelector.luaValueChanged(val)
		self.curBuyCount = val

		self.listCoinsUList:RefreshList()
	end

	function self.listCoinsUList.luaRenderItem(button, index, data)
		self:renderCoinItem(button, index, data)
	end

	self.listCoinsUList:SetList({
		{}
	})

	function self.btnBuyUButton.luaClick()
		local buyData = self.ctrl:getCurrentBuyData()

		if not buyData or self.isBuying then
			return
		end

		TradeMarketUtils.openBuyConfirmUI(function()
			if self.isBuying then
				return
			end

			self.isBuying = true

			self:refreshOnBuy()

			local requested = self.ctrl:buyCurrentGoods(self.curBuyCount, function(noticeCode)
				if not self.ctrl.canAdjustCount or noticeCode ~= NoticeDef.SUCCESS then
					self.isBuying = false

					self:refreshOnBuy()
				end
			end)

			if not requested then
				self.isBuying = false

				self:refreshOnBuy()
			end
		end, buyData.unitPrice * self.curBuyCount, self.ctrl.itemName, self.curBuyCount)
	end
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshOnBuy()
	local buyData = self.ctrl:getCurrentBuyData()

	if buyData then
		self.curPrice = buyData.unitPrice
		self.curBuyCount = math.min(self.curBuyCount or 1, buyData.maxCount)

		self.numSelectorBuyUNumSelector:SetActiveFastest(self.ctrl.canAdjustCount)

		self.numSelectorBuyUNumSelector.minValue = 1
		self.numSelectorBuyUNumSelector.maxValue = buyData.maxCount
		self.numSelectorBuyUNumSelector.value = self.curBuyCount

		self.listCoinsUList:SetActiveFastest(true)
		self.listCoinsUList:RefreshList()
	else
		self.curPrice = nil
		self.curBuyCount = 1

		self.numSelectorBuyUNumSelector:SetActiveFastest(false)
		self.listCoinsUList:SetActiveFastest(false)
	end

	self.btnBuyUButton.visualInteractable = buyData ~= nil and not self.isBuying
end

function TradeMarketGoodsDetailItemSubPageComponent:onBuyByPriceResult(data)
	self.isBuying = false

	self:refreshOnBuy()
	TradeMarketUtils.refreshItemCount(self.ctrl.itemId, self.objectReference)
end

function TradeMarketGoodsDetailItemSubPageComponent:renderCoinItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgIcon = objectReference:GetRefValue("imgIcon")
	local txtNum = objectReference:GetRefValue("txtNum")
	local btnClick = objectReference:GetRefValue("btnClick")

	imgIcon.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	ClientTextUtils.setText(txtNum, (self.curPrice or 0) * self.curBuyCount)
end

function TradeMarketGoodsDetailItemSubPageComponent:renderLayoutSell()
	local objectReference = self.layoutSellObjectReference

	self.btnSellUButton = objectReference:GetRefValue("btnSellUButton")

	local boothFeeUWidget = objectReference:GetRefValue("boothFeeUWidget")

	self.txtBoothFeeUSDFText = objectReference:GetRefValue("txtBoothFeeUSDFText")
	self.quantityUWidget = objectReference:GetRefValue("quantityUWidget")

	local unitPriceUWidget = objectReference:GetRefValue("unitPriceUWidget")
	local totalPriceUWidget = objectReference:GetRefValue("totalPriceUWidget")
	local txtQuantityUSDFText = objectReference:GetRefValue("txtQuantityUSDFText")

	self.numSelectorQuantityUNumSelector = objectReference:GetRefValue("numSelectorQuantityUNumSelector")

	local txtUnitPriceUSDFText = objectReference:GetRefValue("txtUnitPriceUSDFText")

	self.numSelectorUnitPriceUNumSelector = objectReference:GetRefValue("numSelectorUnitPriceUNumSelector")

	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	self.txtTotalNumUSDFText = objectReference:GetRefValue("txtTotalNumUSDFText")

	local btnOC = self.btnSellUButton:GetComponent("ObjectReference")
	local txtNameUText = btnOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("DECOMPOSE"))
	ClientTextUtils.setText(txtQuantityUSDFText, pg.getGameString("QUANTITY"))
	ClientTextUtils.setText(txtUnitPriceUSDFText, pg.getGameString("SINGLE_SELL_PRICE"))
	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PETTRANSMOGRIFY_TOTAL_PRICE"))

	self.boothFeeCurrencyType = TradeMarketUtils.getBoothFeeCurrency()
	self.boothFeeStr = TradeMarketUtils.getBoothFeeStr(self.boothFeeCurrencyType)
	self.recommendedPriceData = TradeMarketUtils.getRecommendedPriceData(self.ctrl.itemId)

	function self.numSelectorQuantityUNumSelector.luaValueChanged(val)
		self.curSellCount = val

		self:refreshTotalPrice()
		self:refreshBoothFee()
	end

	function self.numSelectorUnitPriceUNumSelector.luaValueChanged(val)
		self.curSinglePrice = val

		self:refreshTotalPrice()
		self:refreshBoothFee()
		TradeMarketUtils.showPriceLimitTip(self.recommendedPriceData, val)
	end

	function self.btnSellUButton.luaClick()
		if self.isBoothFeeEnough == false then
			pg.global.ui.tips:showTextTip(pg.getGameString("TRADE_NO_BOOTH_FEE_TIP"))

			return
		end

		if not self.ctrl:canSellAsset() then
			return
		end

		local assetId = self.ctrl:getSellAssetId()

		if not assetId then
			return
		end

		local dayNum = self.ctrl.tradeItemCfg.sellingTime / 24

		TradeMarketUtils.openSellConfirmUI(function()
			if self.isSelling then
				return
			end

			self.isSelling = true

			pg.me:reqSellTradeItem(TradeConst.TRADE_TYPE_ITEM, self.ctrl.itemId, tostring(assetId), self.curSellCount, self.curSinglePrice, function(noticeCode)
				self.isSelling = false

				if noticeCode ~= NoticeDef.SUCCESS then
					return
				end

				local tradeItemCfg = self.ctrl.tradeItemCfg

				self.ctrl:dismiss()
				TradeMarketUtils.openNoticeTipUI(tradeItemCfg)
			end)
		end, self.curTotalPrice, self.curBoothFee, self.ctrl.itemName, self.curSellCount, dayNum)
	end
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshLayoutSell()
	local countText = self.objectReference:GetRefValue("countText")
	local ownNum = self.ctrl:getSellOwnCount()

	if countText then
		ClientTextUtils.setText(countText, ownNum)
	end

	if self.ctrl.tradeItemCfg.isMultiple == 1 then
		self.quantityUWidget:SetActiveFastest(true)

		self.numSelectorQuantityUNumSelector.minValue = 1
		self.numSelectorQuantityUNumSelector.maxValue = ownNum
		self.numSelectorQuantityUNumSelector.value = 1
		self.numSelectorQuantityUNumSelector.stepSize = 1
	else
		self.quantityUWidget:SetActiveFastest(false)
	end

	self.curSellCount = 1

	local isFree = self.recommendedPriceData.isFreePrice == 1

	self.numSelectorUnitPriceUNumSelector.enabledManualInput = isFree

	self.numSelectorUnitPriceUNumSelector:SetAllValue(self.recommendedPriceData.recommendedPrice, self.recommendedPriceData.minPrice, self.recommendedPriceData.maxPrice, self.recommendedPriceData.stepPrice, false)

	self.curSinglePrice = self.recommendedPriceData.recommendedPrice

	self:refreshTotalPrice()
	self:refreshBoothFee()
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshTotalPrice()
	self.curTotalPrice = self.curSellCount * self.curSinglePrice

	ClientTextUtils.setText(self.txtTotalNumUSDFText, self.curTotalPrice)
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshBoothFee()
	self.curBoothFee = TradeMarketUtils.calcStallFee(self.curTotalPrice)

	local ownBoothFee = ClientUtils.getItemCountById(self.boothFeeCurrencyType) or 0

	self.isBoothFeeEnough = ownBoothFee >= self.curBoothFee

	local boothFeeText = self.isBoothFeeEnough and tostring(self.curBoothFee) or string.format("<color=#ff5959>%d</color>", self.curBoothFee)

	ClientTextUtils.setText(self.txtBoothFeeUSDFText, string.format("%s %s", self.boothFeeStr, boothFeeText))

	self.btnSellUButton.visualInteractable = self.isBoothFeeEnough and self.ctrl:canSellAsset()
end

function TradeMarketGoodsDetailItemSubPageComponent:renderLayoutRemove()
	local objectReference = self.layoutRemoveObjectReference
	local btnRemoveUButton = objectReference:GetRefValue("btnRemoveUButton")
	local textRequireUSDFText = objectReference:GetRefValue("textRequireUSDFText")
	local btnOC = btnRemoveUButton:GetComponent("ObjectReference")
	local uIBtn1stConfirmUButton = btnOC:GetRefValue("uIBtn1stConfirmUButton")
	local txtNameUText = btnOC:GetRefValue("txtNameUText")
	local lockUImage = btnOC:GetRefValue("lockUImage")
	local keyHotKeyContent = btnOC:GetRefValue("keyHotKeyContent")

	ClientTextUtils.setText(textRequireUSDFText, string.format("%s %s", pg.getGameString("TRADE_REMOVE_COUNTDOWN"), 0))
	ClientTextUtils.setText(txtNameUText, pg.getGameString("BTN_CANCEL_SELL"))

	function btnRemoveUButton.luaClick()
		local listingData = self.ctrl.listingData

		if self.isRemoving or not listingData or not listingData.listingId then
			return
		end

		self.isRemoving = true

		pg.me:reqRemoveTradeItem(listingData.listingId, function(noticeCode)
			self.isRemoving = false

			if noticeCode ~= NoticeDef.SUCCESS then
				return
			end

			pg.global.ui.tips:showTextTip(pg.getGameString("TRADE_REMOVE_OK_TIP"))
			self.ctrl:dismiss()
		end)
	end
end

function TradeMarketGoodsDetailItemSubPageComponent:refreshOwnerCount()
	return
end

return TradeMarketGoodsDetailItemSubPageComponent
