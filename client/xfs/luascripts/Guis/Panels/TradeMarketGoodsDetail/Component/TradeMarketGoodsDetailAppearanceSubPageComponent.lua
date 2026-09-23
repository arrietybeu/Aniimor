-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketGoodsDetailAppearanceSubPageComponent.lua

local Class = require("Core.Framework.Class")
local TradeMarketGoodsDetailSubPageComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsDetailSubPageComponent")
local TradeMarketAppearanceDisplayComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketAppearanceDisplayComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local NoticeDef = require("Common.NoticeDef")
local TradeConst = require("Common.Const.TradeConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TradeMarketGoodsDetailAppearanceSubPageComponent = Class.LightClass("TradeMarketGoodsDetailAppearanceSubPageComponent", TradeMarketGoodsDetailSubPageComponent)

function TradeMarketGoodsDetailAppearanceSubPageComponent:initView()
	TradeMarketGoodsDetailSubPageComponent.initView(self)

	self.appearanceDisplay = TradeMarketAppearanceDisplayComponent.new(self.ctrl, self.transform)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:onEnter()
	self:_setupEllipsesButton()
	TradeMarketGoodsDetailSubPageComponent.onEnter(self)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:onExit()
	self:setOtherUIVisible(true)
	self:_clearEllipsesButton()
	self.appearanceDisplay:onExit()
	TradeMarketGoodsDetailSubPageComponent.onExit(self)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:onDestroy()
	self:_clearEllipsesButton()

	if self.appearanceDisplay then
		self.appearanceDisplay:onExit()

		self.appearanceDisplay = nil
	end

	TradeMarketGoodsDetailSubPageComponent.onDestroy(self)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_getAppearanceDisplayData()
	return {
		itemId = self.ctrl.itemId,
		isPetAppearance = self.ctrl.isPetAppearance
	}
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_getEllipsesData()
	local data = {}
	local model = self.ctrl.model

	if self.appearanceDisplay:canSwitchGender() then
		data[#data + 1] = self.appearanceDisplay:isFemaleGender() and model.boyEllipses or model.girlEllipses
	end

	data[#data + 1] = model.hideUIEllipses

	return data
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_setupEllipsesButton()
	local view = self.ctrl.view

	function view.btnClickShowUButton.luaClick()
		self:setOtherUIVisible(true)
	end

	function view.btnEllipsesUButton.luaRenderTooltip(button, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local listUList = objectReference:GetRefValue("listUList")

		function listUList.luaRenderItem(listButton, index, data)
			self:_renderEllipsesList(listButton, index, data)
		end

		function listUList.luaClick(listButton, data)
			self:_onEllipsesListClick(data)
			button:ClosePopup()
		end

		listUList:SetList(self:_getEllipsesData())
	end

	view.btnEllipsesUButton:SetActive(self._contentLoaded == true)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_clearEllipsesButton()
	local view = self.ctrl and self.ctrl.view

	if not view then
		return
	end

	view.btnEllipsesUButton.luaRenderTooltip = nil

	view.btnEllipsesUButton:SetActive(false)

	view.btnClickShowUButton.luaClick = nil

	view.btnClickShowUButton:SetActive(false)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_renderEllipsesList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtUText = objectReference:GetRefValue("txtUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtUText, pg.getGameString(data.name))

	iconUImage.url = data.icon
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_onEllipsesListClick(data)
	local model = self.ctrl.model

	if data.clickType == model.EllipsesType.SwitchGender then
		self.appearanceDisplay:switchGender()
	elseif data.clickType == model.EllipsesType.HideUI then
		self:setOtherUIVisible(false)
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:setOtherUIVisible(isShow)
	local view = self.ctrl.view

	view.btnClickShowUButton:SetActive(not isShow)
	view.widget:TryChangePage("HideUI", isShow and 0 or 1)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_findObjectRef()
	local objectReference = self:_getObjectReference()

	if not objectReference then
		return
	end

	self.appearanceDisplay:bindObjectReference(objectReference)

	self.btnShoppingCart = objectReference:GetRefValue("btnShoppingCart")
	self.btnGift = objectReference:GetRefValue("btnGift")
	self.btnBuy = objectReference:GetRefValue("btnBuy")
	self.btnBuy1 = objectReference:GetRefValue("btnBuy1")
	self.btnObtain = objectReference:GetRefValue("btnObtain")
	self.btnReplaceUButton = objectReference:GetRefValue("btnReplaceUButton")
	self.txtLockD = objectReference:GetRefValue("txtLockD")
	self.txtSoldOut = objectReference:GetRefValue("txtSoldOut")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.txtPlayerTitle = objectReference:GetRefValue("txtPlayerTitle")
	self.txtPetTitle = objectReference:GetRefValue("txtPetTitle")
	self.txtObtain = objectReference:GetRefValue("txtObtain")
	self.txtObtainBtnName = objectReference:GetRefValue("txtObtainBtnName")
	self.txtRedirect = objectReference:GetRefValue("txtRedirect")
	self.btnRedirect = objectReference:GetRefValue("btnRedirect")
	self.btnChangePet = objectReference:GetRefValue("btnChangePet")
	self.imgPet = objectReference:GetRefValue("imgPet")
	self.inventoryUWidget = objectReference:GetRefValue("inventoryUWidget")
	self.txtInventory = objectReference:GetRefValue("txtInventory")
	self.rewardUWidget = objectReference:GetRefValue("rewardUWidget")
	self.txtDirectPurchase = objectReference:GetRefValue("txtDirectPurchase ")
	self.jumpUWidget = objectReference:GetRefValue("jumpUWidget")
	self.txtBtnBuyName = objectReference:GetRefValue("txtBtnBuyName")
	self.txtGotoWear = objectReference:GetRefValue("txtGotoWear")
	self.costItem = objectReference:GetRefValue("costItem")
	self.tipsCountDownUWidget = objectReference:GetRefValue("tipsCountDownUWidget")
	self.txtCountDownUSDFText = objectReference:GetRefValue("txtCountDownUSDFText")
	self.btnAttentionUButton = objectReference:GetRefValue("btnAttentionUButton")
	self.progressAttentionUProgress = objectReference:GetRefValue("progressAttentionUProgress")
	self.btnSellUButton = objectReference:GetRefValue("btnSellUButton")
	self.boothFeeUWidget = objectReference:GetRefValue("boothFeeUWidget")
	self.txtBoothFeeUSDFText = objectReference:GetRefValue("txtBoothFeeUSDFText")
	self.unitPriceUWidget = objectReference:GetRefValue("unitPriceUWidget")
	self.txtUnitPriceUSDFText = objectReference:GetRefValue("txtUnitPriceUSDFText")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")

	local costBtnOC = self.costItem:GetComponent("ObjectReference")

	self.costIcon = costBtnOC:GetRefValue("imgIcon")
	self.costTxtNum = costBtnOC:GetRefValue("txtNum")

	self.btnShoppingCart:SetActiveFastest(false)
	self.btnGift:SetActiveFastest(false)
	self:initBasicView()
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:_addObjectListener()
	self:initFollowView()

	function self.costItem.luaRenderTooltip(btn, tooltip)
		LuaUIUtils.refreshItemInfo(tooltip, {
			itemId = TradeMarketUtils.getTradeCurrency()
		})
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:initPage()
	self.ctrl.view.btnEllipsesUButton:SetActive(true)
	self.ctrl.view.iconPropUImage:SetActive(false)

	self.costIcon.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	self.appearanceDisplay:setData(self:_getAppearanceDisplayData())
	self.appearanceDisplay:onEnter()
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:refreshPage()
	if self.ctrl.operation == TradeMarketUtils.Operation.Buy then
		self:refreshOnBuy()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Sell then
		-- block empty
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Remove then
		-- block empty
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:initBasicView()
	if self.ctrl.operation == TradeMarketUtils.Operation.Buy then
		self:initOnBuy()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Sell then
		self:initOnSell()
	elseif self.ctrl.operation == TradeMarketUtils.Operation.Remove then
		self:initOnRemove()
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:initOnBuy()
	ClientTextUtils.setText(self.txtBtnBuyName, pg.getGameString("SHOP_BUY"))
	self.inventoryUWidget:SetActiveFastest(false)
	self.btnBuy:SetActiveFastest(true)
	self.btnSellUButton:SetActiveFastest(false)

	function self.btnBuy.luaClick()
		self:clickBuyBtn()
	end

	if self.ctrl.tradeItemCfg.isMultiple == 1 then
		self.numSelectorUNumSelector:SetActiveFastest(true)

		self.numSelectorUNumSelector.minValue = 1
		self.numSelectorUNumSelector.maxValue = 1

		function self.numSelectorUNumSelector.luaValueChanged(val)
			self.curBuyNum = val
		end
	else
		self.numSelectorUNumSelector:SetActiveFastest(false)
	end

	self:refreshOnBuy()
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:clickBuyBtn()
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

		local requested = self.ctrl:buyCurrentGoods(self.curBuyNum, function(noticeCode)
			if not self.ctrl.canAdjustCount or noticeCode ~= NoticeDef.SUCCESS then
				self.isBuying = false

				self:refreshOnBuy()
			end
		end)

		if not requested then
			self.isBuying = false

			self:refreshOnBuy()
		end
	end, buyData.unitPrice * self.curBuyNum, self.ctrl.itemName, self.curBuyNum)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:onBuyByPriceResult(data)
	self.isBuying = false

	self:refreshOnBuy()
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:refreshOnBuy()
	local buyData = self.ctrl:getCurrentBuyData()

	if buyData then
		self.curPrice = buyData.unitPrice
		self.curBuyNum = math.min(self.curBuyNum or 1, buyData.maxCount)

		self.numSelectorUNumSelector:SetActiveFastest(self.ctrl.canAdjustCount)

		self.numSelectorUNumSelector.minValue = 1
		self.numSelectorUNumSelector.maxValue = buyData.maxCount
		self.numSelectorUNumSelector.stepSize = 1
		self.numSelectorUNumSelector.value = self.curBuyNum

		self.costItem:SetActiveFastest(true)

		self.btnBuy.visualInteractable = not self.isBuying

		ClientTextUtils.setText(self.costTxtNum, self.curPrice * self.curBuyNum)
	else
		self.curPrice = nil
		self.curBuyNum = 1

		self.numSelectorUNumSelector:SetActiveFastest(false)
		self.costItem:SetActiveFastest(false)

		self.btnBuy.visualInteractable = false
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:initOnSell()
	self.unitPriceUWidget:SetActiveFastest(true)
	ClientTextUtils.setText(self.txtBtnBuyName, pg.getGameString("DECOMPOSE"))
	ClientTextUtils.setText(self.txtUnitPriceUSDFText, pg.getGameString("SINGLE_SELL_PRICE"))
	self.inventoryUWidget:SetActiveFastest(false)
	self.btnBuy:SetActiveFastest(false)
	self.btnSellUButton:SetActiveFastest(true)

	function self.btnSellUButton.luaClick()
		self:clickSellBtn()
	end

	self.numSelectorUNumSelector:SetActiveFastest(true)

	self.recommendedPriceData = TradeMarketUtils.getRecommendedPriceData(self.ctrl.itemId)
	self.numSelectorUNumSelector.enabledManualInput = self.recommendedPriceData.isFreePrice == 1

	self.numSelectorUNumSelector:SetAllValue(self.recommendedPriceData.recommendedPrice, self.recommendedPriceData.minPrice, self.recommendedPriceData.maxPrice, self.recommendedPriceData.stepPrice, false)

	self.curPrice = self.recommendedPriceData.recommendedPrice
	self.boothFeeCurrencyType = TradeMarketUtils.getBoothFeeCurrency()
	self.boothFeeFormat = string.format("%s <sprite name=\"ui_item_%d_small\">", pg.getGameString("STALL_FEE"), self.boothFeeCurrencyType)

	self:refreshBoothFee()

	function self.numSelectorUNumSelector.luaValueChanged(val)
		self.curPrice = val

		self:refreshBoothFee()
		TradeMarketUtils.showPriceLimitTip(self.recommendedPriceData, val)
	end
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:refreshBoothFee()
	self.curBoothFee = TradeMarketUtils.calcStallFee(self.curPrice or 0)

	local ownBoothFee = ClientUtils.getItemCountById(self.boothFeeCurrencyType) or 0

	self.isBoothFeeEnough = ownBoothFee >= self.curBoothFee

	local boothFeeText = self.isBoothFeeEnough and tostring(self.curBoothFee) or string.format("<color=#ff5959>%d</color>", self.curBoothFee)

	ClientTextUtils.setText(self.txtBoothFeeUSDFText, string.format("%s %s", self.boothFeeFormat, boothFeeText))

	self.btnSellUButton.visualInteractable = self.isBoothFeeEnough and self.ctrl:canSellAsset()
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:clickSellBtn()
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

		pg.me:reqSellTradeItem(TradeConst.TRADE_TYPE_ITEM, self.ctrl.itemId, tostring(assetId), 1, self.curPrice, function(noticeCode)
			self.isSelling = false

			if noticeCode ~= NoticeDef.SUCCESS then
				return
			end

			local tradeItemCfg = self.ctrl.tradeItemCfg

			self.ctrl:dismiss()
			TradeMarketUtils.openNoticeTipUI(tradeItemCfg)
		end)
	end, self.curPrice, self.curBoothFee, self.ctrl.itemName, 1, dayNum)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:initOnRemove()
	self.unitPriceUWidget:SetActiveFastest(false)
	self.boothFeeUWidget:SetActiveFastest(false)
	self.inventoryUWidget:SetActiveFastest(false)
	self.tipsCountDownUWidget:SetActive(true)
	ClientTextUtils.setText(self.txtCountDownUSDFText, "")
	ClientTextUtils.setText(self.txtBtnBuyName, pg.getGameString("BTN_CANCEL_SELL"))
	self.btnBuy:SetActiveFastest(false)
	self.btnSellUButton:SetActiveFastest(true)

	function self.btnSellUButton.luaClick()
		self:clickRemoveBtn()
	end

	self.numSelectorUNumSelector:SetActiveFastest(false)
end

function TradeMarketGoodsDetailAppearanceSubPageComponent:clickRemoveBtn()
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

function TradeMarketGoodsDetailAppearanceSubPageComponent:refreshModelView()
	self.appearanceDisplay:refreshModelView()
end

return TradeMarketGoodsDetailAppearanceSubPageComponent
