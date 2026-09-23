-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistoryGoods\\TradeMarketHistoryGoodsCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryGoodsCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ItemData = require("Data.item_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local TradeMarketAppearanceDisplayComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketAppearanceDisplayComponent")
local TradeMarketHistoryGoodsCtrl = Class.LightClass("TradeMarketHistoryGoodsCtrl", UICtrl)

TradeMarketHistoryGoodsCtrl.messages = {}

function TradeMarketHistoryGoodsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._appearanceLoadToken = 0
	self._appearanceLoading = false
end

function TradeMarketHistoryGoodsCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("TRADE_HISTORY"))

	function self.view.btnClick.luaRenderTooltip(btn, tooltip)
		LuaUIUtils.refreshItemInfo(tooltip, {
			itemId = TradeMarketUtils.getTradeCurrency()
		})
	end
end

function TradeMarketHistoryGoodsCtrl:onDestroy()
	self._appearanceLoadToken = self._appearanceLoadToken + 1
	self._appearanceLoading = false

	if self.appearanceDisplay then
		self.appearanceDisplay:onExit()

		self.appearanceDisplay = nil
	end

	UICtrl.onDestroy(self)
end

function TradeMarketHistoryGoodsCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TRADE_HISTORY"))

	self.appearanceDisplay = TradeMarketAppearanceDisplayComponent.new(self, self.view.appearanceUContainer.transform)
	self.info = info
	self.itemId = info.tradeItemId
	self.isAppearanceGoods, self.isPetAppearance = TradeMarketUtils.isAppearanceGoods(self.itemId)

	self:_refreshGoodsTypeView()
end

function TradeMarketHistoryGoodsCtrl:onShow()
	return
end

function TradeMarketHistoryGoodsCtrl:onHide()
	return
end

function TradeMarketHistoryGoodsCtrl:_getAppearanceDisplayData()
	return {
		itemId = self.itemId,
		isPetAppearance = self.isPetAppearance
	}
end

function TradeMarketHistoryGoodsCtrl:_refreshGoodsTypeView()
	self.view.propsUContainer:SetActive(not self.isAppearanceGoods)
	self.view.appearanceUContainer:SetActive(self.isAppearanceGoods)
	self.view.iconPropUImage:SetActive(not self.isAppearanceGoods)
	self:refreshBasicView()

	if self.isAppearanceGoods then
		self.appearanceDisplay:setData(self:_getAppearanceDisplayData())
		self:_loadAppearanceContent()
	else
		self._appearanceLoadToken = self._appearanceLoadToken + 1
		self._appearanceLoading = false

		if self.appearanceDisplay then
			self.appearanceDisplay:onExit()
		end

		if self.view.propsUContainer:CheckURLLoaded() then
			self:_onPropsContentLoaded()
		else
			self.view.propsUContainer:LoadDefaultUrlManually(function()
				self:_onPropsContentLoaded()
			end)
		end
	end
end

function TradeMarketHistoryGoodsCtrl:refreshBasicView()
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, UIConst.UI_ID_TRADE_MARKET_HISTORY_GOODS)

	self.view.imgIcon.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	ClientTextUtils.setText(self.view.txtNum, self.info.dealPrice)

	local tradedTime = LuaUIUtils.timeStampToUtcString(self.info.dealTs, UIConst.TargetTimeType.Long, false)
	local timeStr

	timeStr = self.info.isBuyer and "PURCHASE" or "SOLD"

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, string.format("%s %s", tradedTime, pg.getGameString(timeStr)))

	if self.info.auditEndTs and self.info.auditEndTs > 0 then
		self.view.reviewUWidget:SetActiveFastest(true)
		LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, self.info.auditEndTs, UIConst.TimeType.Short)
	else
		self.view.reviewUWidget:SetActiveFastest(false)
	end
end

function TradeMarketHistoryGoodsCtrl:_loadAppearanceContent()
	if self.appearanceDisplay:isReady() or self._appearanceLoading then
		return
	end

	local uContainer = self.view.appearanceUContainer

	self._appearanceLoading = true
	self._appearanceLoadToken = self._appearanceLoadToken + 1

	local loadToken = self._appearanceLoadToken

	if uContainer:CheckURLLoaded() then
		self:_onAppearanceContentLoaded(loadToken)

		return
	end

	uContainer:LoadDefaultUrlManually(function()
		self:_onAppearanceContentLoaded(loadToken)
	end)
end

function TradeMarketHistoryGoodsCtrl:_onAppearanceContentLoaded(loadToken)
	if loadToken ~= self._appearanceLoadToken then
		return
	end

	self._appearanceLoading = false

	local content = self.view.appearanceUContainer.content

	if not content then
		return
	end

	local objectReference = content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	self.appearanceDisplay:bindObjectReference(objectReference)
	self.appearanceDisplay:onEnter()

	local btnShoppingCart = objectReference:GetRefValue("btnShoppingCart")
	local btnGift = objectReference:GetRefValue("btnGift")
	local btnBuy = objectReference:GetRefValue("btnBuy")
	local inventoryUWidget = objectReference:GetRefValue("inventoryUWidget")

	btnShoppingCart:SetActiveFastest(false)
	btnGift:SetActiveFastest(false)
	btnBuy:SetActiveFastest(false)
	inventoryUWidget:SetActiveFastest(false)
end

function TradeMarketHistoryGoodsCtrl:_onPropsContentLoaded()
	local content = self.view.propsUContainer.content

	if not content then
		return
	end

	local objectReference = content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local itemData = ItemData[self.itemId]

	self.view.iconPropUImage.url = itemData.icon

	TradeMarketUtils.renderItemBasicInfo(self.itemId, objectReference)

	local layoutSellObjectReference = objectReference:GetRefValue("layoutSellObjectReference")
	local layoutBuyObjectReference = objectReference:GetRefValue("layoutBuyObjectReference")
	local layoutRemoveObjectReference = objectReference:GetRefValue("layoutRemoveObjectReference")

	layoutSellObjectReference.gameObject:SetActiveEx(false)
	layoutBuyObjectReference.gameObject:SetActiveEx(false)
	layoutRemoveObjectReference.gameObject:SetActiveEx(false)
end

return TradeMarketHistoryGoodsCtrl
