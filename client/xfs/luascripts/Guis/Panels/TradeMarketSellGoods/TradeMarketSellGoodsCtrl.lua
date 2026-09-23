-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellGoods\\TradeMarketSellGoodsCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellGoodsCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local TradeMarketSellGoodsCtrl = Class.LightClass("TradeMarketSellGoodsCtrl", UICtrl)

TradeMarketSellGoodsCtrl.messages = {
	[MessageName.ON_GET_TRADE_MY_ON_SALE] = {
		"onGetMyListings",
		true
	}
}

function TradeMarketSellGoodsCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function TradeMarketSellGoodsCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnHistoryUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_HISTORY)
	end

	function self.view.searchUTMPInputField.luaEndEdit(text)
		self:searchBagGoods(text)
	end

	function self.view.searchUTMPInputField.luaValueChanged(text)
		self:refreshBagGoodsSearchState(text)
		self:searchBagGoods(text)
	end

	function self.view.btnSearchUButton.luaClick()
		self:searchBagGoods(self.view.searchUTMPInputField.text)
	end

	function self.view.btnDeleteUButton.luaClick()
		self.view.searchUTMPInputField:SetTextWithoutNotify("")
		self:refreshBagGoodsSearchState("")
		self:searchBagGoods("")
	end

	function self.view.listPropsUList.luaRenderItem(button, index, data)
		self:renderBagGoods(button, index, data)
	end

	function self.view.listPropsUList.luaClick(button, data)
		if not data or data.isFrozen == true then
			return
		end

		TradeMarketUtils.openGoodsDetailSellUI(data.itemId, nil, data)
	end

	function self.view.listGoodsUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderMySellGoodsItem(button, index, data)
	end

	function self.view.listGoodsUList.luaClick(button, data)
		if not data or data.isEmpty then
			return
		end

		TradeMarketUtils.openGoodsDetailRemoveUI(data)
	end

	self.view.btnInfoUButton.enabledTooltip = false

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(id)
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TITLE_SELL_PROPS"))
	ClientTextUtils.setText(self.view.leftTitleUSDFText, pg.getGameString("CONSIGNMENT_ITEM"))
	ClientTextUtils.setText(self.view.btnHistoryTxtNameUText, pg.getGameString("TRADE_HISTORY"))
	ClientTextUtils.setText(self.view.placeHolderUSDFText, pg.getGameString("CHAT_TIP_INPUT_ITEM_NAME"))
	self:refreshBagGoodsSearchState(self.view.searchUTMPInputField.text)
end

function TradeMarketSellGoodsCtrl:onDestroy()
	self:_clearFreezeRefreshTimer()
	UICtrl.onDestroy(self)
end

function TradeMarketSellGoodsCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.hasShown = false

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d/%d", 0, TradeMarketUtils.getGoodsSellMaxCount()))
end

function TradeMarketSellGoodsCtrl:onShow()
	self.hasShown = true

	self:refreshViewData()
end

function TradeMarketSellGoodsCtrl:onVisibleChange(visible)
	if visible and self.hasShown then
		self:refreshViewData()
	else
		self:_clearFreezeRefreshTimer()
	end
end

function TradeMarketSellGoodsCtrl:refreshViewData()
	self:refreshBagGoodsData()
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
	pg.me:reqGetMyListings(function(code, data)
		if code == NoticeDef.SUCCESS and not data then
			self:onGetMyListings(data)
		end
	end)
end

function TradeMarketSellGoodsCtrl:refreshBagGoodsData()
	self.goodsData = self.model:getCanSellGoodsData()

	self:searchBagGoods(self.view.searchUTMPInputField.text)
	self:_scheduleFreezeRefresh(self.goodsData)
end

function TradeMarketSellGoodsCtrl:onGetMyListings(data)
	local sellingData, sellingCount = self.model:getSellingData(data and data.listings)

	self.view.listGoodsUList:SetList(sellingData)
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d/%d", sellingCount, TradeMarketUtils.getGoodsSellMaxCount()))
end

function TradeMarketSellGoodsCtrl:onHide()
	self:_clearFreezeRefreshTimer()
end

function TradeMarketSellGoodsCtrl:initView()
	return
end

function TradeMarketSellGoodsCtrl:renderSellingGoods(button, index, data)
	return
end

function TradeMarketSellGoodsCtrl:searchBagGoods(keyword)
	if string.isNilOrEmpty(keyword) then
		self.view.listPropsUList:SetList(self.goodsData or {})

		return
	end

	local ret = {}

	for _, data in ipairs(self.goodsData or EMPTY_TABLE) do
		if data.itemName and string.find(data.itemName, keyword, 1, true) then
			ret[#ret + 1] = data
		end
	end

	self.view.listPropsUList:SetList(ret)
end

function TradeMarketSellGoodsCtrl:refreshBagGoodsSearchState(text)
	self.view.btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))
end

function TradeMarketSellGoodsCtrl:_clearFreezeRefreshTimer()
	if self._freezeRefreshTimer then
		TimerManager.removeTimer(self._freezeRefreshTimer)

		self._freezeRefreshTimer = nil
	end
end

function TradeMarketSellGoodsCtrl:_scheduleFreezeRefresh(goodsData)
	self:_clearFreezeRefreshTimer()

	local curTimeTs = Time.secondCache or Time.getSecond()
	local nearestEndTs

	for _, data in ipairs(goodsData or EMPTY_TABLE) do
		if data.isFrozen == true and data.frozenEndTs and curTimeTs < data.frozenEndTs and (not nearestEndTs or nearestEndTs > data.frozenEndTs) then
			nearestEndTs = data.frozenEndTs
		end
	end

	if nearestEndTs then
		self._freezeRefreshTimer = TimerManager.addTimer(math.max(nearestEndTs - curTimeTs, 0.1), function()
			self._freezeRefreshTimer = nil

			self:refreshBagGoodsData()
		end)
	end
end

function TradeMarketSellGoodsCtrl:renderBagGoods(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local viewableWidget = objectReference:GetRefValue("viewableWidget")
	local selectedStateUComponent = objectReference:GetRefValue("selectedStateUComponent")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local selectedULayoutBox = objectReference:GetRefValue("selectedULayoutBox")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
	local disabledUImage = objectReference:GetRefValue("disabledUImage")
	local genIdTransform = objectReference:GetRefValue("genIdTransform")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local stateNewULayoutBox = objectReference:GetRefValue("stateNewULayoutBox")
	local slotIndex = objectReference:GetRefValue("slotIndex")
	local noneUWidget = objectReference:GetRefValue("noneUWidget")
	local itemNameUText = objectReference:GetRefValue("itemNameUText")
	local checkedUButton = objectReference:GetRefValue("checkedUButton")
	local selectedName = objectReference:GetRefValue("selectedName")
	local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
	local uIComPropCardAnimation = objectReference:GetRefValue("uIComPropCardAnimation")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local checkNumberUText = objectReference:GetRefValue("checkNumberUText")
	local cancelUButton = objectReference:GetRefValue("cancelUButton")
	local rateUComponent = objectReference:GetRefValue("rateUComponent")
	local rateUBaseText = objectReference:GetRefValue("rateUBaseText")
	local carryItem = objectReference:GetRefValue("carryItem")
	local buttonUpUButton = objectReference:GetRefValue("buttonUpUButton")
	local gemstoneUContainer = objectReference:GetRefValue("gemstoneUContainer")
	local itemLableUContainer = objectReference:GetRefValue("itemLableUContainer")
	local frozenUContainer = objectReference:GetRefValue("frozenUContainer")

	button.interactable = data.isFrozen ~= true
	button.visualInteractable = data.isFrozen ~= true

	ClientTextUtils.setText(txtNumUText, data.num)

	iconUImage.url = data.itemConfig.icon

	frozenUContainer:SetActiveFastest(data.isFrozen == true)

	if data.isFrozen == true then
		frozenUContainer:LoadDefaultUrlManually(function(widget)
			local widgetOC = widget:GetComponent("ObjectReference")
			local countDownUCountDown = widgetOC:GetRefValue("countDownUCountDown")
			local txtFrozenUSDFText = widgetOC:GetRefValue("txtFrozenUSDFText")

			ClientTextUtils.setText(txtFrozenUSDFText, pg.getGameString("FREEZING"))
			LuaUIUtils.setCountDownTime(countDownUCountDown, data.frozenEndTs, UIConst.TimeType.Short)
		end)
	end
end

return TradeMarketSellGoodsCtrl
