-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetSellDetail\\TradeMarketPetSellDetailCtrl.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeMarketPetDetailBaseCtrl = require("Guis.Panels.TradeMarketPetDetail.TradeMarketPetDetailBaseCtrl")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local TradeConst = require("Common.Const.TradeConst")
local MessageName = require("Const.MessageName")
local TradeUtils = require("Common.Utils.TradeUtils")
local Time = require("Core.Common.Time")
local TradeMarketPetSellDetailCtrl = Class.LightClass("TradeMarketPetSellDetailCtrl", TradeMarketPetDetailBaseCtrl)
local PERFECT_PROPERTY_SCORE_STAGE = table.maxn(Const.STAGE_TO_RATING_STR)

TradeMarketPetSellDetailCtrl.messages = {
	[MessageName.ON_GET_TRADE_LISTINGS] = {
		"onGetTradeListings",
		true
	}
}

function TradeMarketPetSellDetailCtrl:addListener()
	TradeMarketPetSellDetailCtrl.super.addListener(self)

	function self.view.numSelectorUNumSelector.luaValueChanged(value)
		self.curPrice = value

		self:refreshBoothFee()
	end

	function self.view.btnPurchaseUButton.luaClick()
		self:onSellClicked()
	end

	function self.view.listPetUList.luaClick(button, data)
		if not data or not data.listingId then
			return
		end

		TradeMarketUtils.openBuyPetDetailUI(data.tradeItemId or self.petTemplateId, data)
	end
end

function TradeMarketPetSellDetailCtrl:onOpen(info)
	self.petData = info.petData

	TradeMarketPetSellDetailCtrl.super.onOpen(self, info)
	self.view.widget:TryChangePage("Launch", 1)
	self.view.listCoinsUList:SetActiveFastest(false)
	ClientTextUtils.setText(self.view.btnTxtNameUText, pg.getGameString("DECOMPOSE"))
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TRADE_SELL_TIP_TITLE"))

	self.boothFeeCurrencyType = TradeMarketUtils.getBoothFeeCurrency()
	self.boothFeeFormatStr = TradeMarketUtils.getBoothFeeStr(self.boothFeeCurrencyType)

	self:initPriceSelector()
	self:refreshPetDetailView()
end

function TradeMarketPetSellDetailCtrl:initPriceSelector()
	local petData = self.petData

	if not petData then
		return
	end

	local cfgId = petData.templateId or petData.id
	local isPerfect = (petData.propertyScoreStage or 1) >= PERFECT_PROPERTY_SCORE_STAGE

	self.recommendedPriceData = TradeMarketUtils.getPetRecommendedPriceData(cfgId, petData.label, isPerfect)

	if not self.recommendedPriceData then
		return
	end

	local numSelector = self.view.numSelectorUNumSelector

	numSelector.minValue = self.recommendedPriceData.minPrice
	numSelector.maxValue = self.recommendedPriceData.maxPrice
	numSelector.stepSize = self.recommendedPriceData.stepPrice
	numSelector.value = self.recommendedPriceData.recommendedPrice
	self.curPrice = numSelector.value

	self:refreshBoothFee()
end

function TradeMarketPetSellDetailCtrl:refreshBoothFee()
	self.curBoothFee = TradeMarketUtils.calcStallFee(self.curPrice or 0)

	local ownBoothFee = ClientUtils.getItemCountById(self.boothFeeCurrencyType) or 0

	self.isBoothFeeEnough = ownBoothFee >= self.curBoothFee

	local boothFeeText = self.isBoothFeeEnough and tostring(self.curBoothFee) or string.format("<color=#ff5959>%d</color>", self.curBoothFee)

	ClientTextUtils.setText(self.view.txtBoothFeeUSDFText, string.format("%s %s", self.boothFeeFormatStr, boothFeeText))

	self.view.btnPurchaseUButton.visualInteractable = self.isBoothFeeEnough and self:canSellPet()
end

function TradeMarketPetSellDetailCtrl:refreshPetDetailView()
	if not self.petData then
		self:refreshPetDetail({
			isEmpty = true
		})

		return
	end

	local previewPetInfo = pg.me and pg.me:getPetInfo(self.petData.id) or nil

	self:refreshPetDetail(self.petData, previewPetInfo or self.petData)
end

function TradeMarketPetSellDetailCtrl:canSellPet()
	local petInfo = self.petData and pg.me and pg.me:getPetInfo(self.petData.id)

	if not petInfo then
		return false
	end

	local frozenEndTs = TradeUtils.getPetTradeFreezeEndTs(petInfo)

	if frozenEndTs > (Time.secondCache or Time.getSecond()) then
		return false
	end

	return self.tradeItemCfg.needCanTrade ~= 1 or TradeUtils.isPetCanTrade(petInfo)
end

function TradeMarketPetSellDetailCtrl:onSellClicked()
	if not self.petData or not self.curPrice or self.isSelling then
		return
	end

	if self.isBoothFeeEnough == false then
		pg.global.ui.tips:showTextTip(pg.getGameString("TRADE_NO_BOOTH_FEE_TIP"))

		return
	end

	if not self:canSellPet() then
		return
	end

	local dayNum = self.tradeItemCfg.sellingTime / 24

	TradeMarketUtils.openSellConfirmUI(function()
		if self.isSelling or not self:canSellPet() then
			return
		end

		self.isSelling = true

		pg.me:reqSellTradeItem(TradeConst.TRADE_TYPE_PET, self.petData.templateId, tostring(self.petData.id), 1, self.curPrice, function(noticeCode)
			self.isSelling = false

			if noticeCode ~= NoticeDef.SUCCESS then
				return
			end

			local tradeItemCfg = self.tradeItemCfg

			self:dismiss()
			TradeMarketUtils.openNoticeTipUI(tradeItemCfg)
		end)
	end, self.curPrice, self.curBoothFee, self.petName, 1, dayNum)
end

function TradeMarketPetSellDetailCtrl:onDestroy()
	self.view.numSelectorUNumSelector.luaValueChanged = nil
	self.view.btnPurchaseUButton.luaClick = nil
	self.view.listPetUList.luaClick = nil
	self.recommendedPriceData = nil
	self.curPrice = nil
	self.curBoothFee = nil
	self.isBoothFeeEnough = nil
	self.isSelling = nil
	self.petData = nil

	TradeMarketPetSellDetailCtrl.super.onDestroy(self)
end

return TradeMarketPetSellDetailCtrl
