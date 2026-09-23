-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\TradeMarketGoodsDetailCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketGoodsDetailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeConst = require("Common.Const.TradeConst")
local NoticeDef = require("Common.NoticeDef")
local TradeMarketGoodsDetailItemSubPageComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsDetailItemSubPageComponent")
local TradeMarketGoodsDetailAppearanceSubPageComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsDetailAppearanceSubPageComponent")
local TradeMarketGoodsPriceListComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsPriceListComponent")
local TradeMarketGoodsListingListComponent = require("Guis.Panels.TradeMarketGoodsDetail.Component.TradeMarketGoodsListingListComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeItemData = require("Data.trade_items_data")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local TradeUtils = require("Common.Utils.TradeUtils")
local TradeMarketGoodsDetailCtrl = Class.LightClass("TradeMarketGoodsDetailCtrl", UICtrl)

TradeMarketGoodsDetailCtrl.GOODS_TYPE = {
	ITEM = 1,
	APPEARANCE = 2
}
TradeMarketGoodsDetailCtrl.messages = {
	[MessageName.ON_GET_TRADE_LISTINGS] = {
		"onGetTradeListings",
		true
	},
	[MessageName.ON_GET_TRADE_LISTINGS_BY_PRICE] = {
		"onGetListingsByPrice",
		true
	},
	[MessageName.ON_TRADE_BUY_BY_PRICE_RESULT] = {
		"onBuyByPriceResult",
		true
	},
	[MessageName.ON_TRADE_FOLLOW_CHANGED] = {
		"onTradeFollowChanged",
		true
	}
}

local REFRESH_INTERVAL = 2
local REFRESH_CLICK_MAX_NUM = 3
local NOTICE_SORT_MODE = {
	PRICE = 1,
	TIME = 2
}
local LIST_TAB_STATUS_MAP = {
	[TradeMarketUtils.ListTab.OnSale] = TradeConst.LISTING_STATUS.SELLING,
	[TradeMarketUtils.ListTab.OnNotice] = TradeConst.LISTING_STATUS.NOTICE,
	[TradeMarketUtils.ListTab.OnHistory] = TradeConst.LISTING_STATUS.SETTLED
}
local STATUS_LIST_TAB_MAP = {
	[TradeConst.LISTING_STATUS.SELLING] = TradeMarketUtils.ListTab.OnSale,
	[TradeConst.LISTING_STATUS.NOTICE] = TradeMarketUtils.ListTab.OnNotice,
	[TradeConst.LISTING_STATUS.SETTLED] = TradeMarketUtils.ListTab.OnHistory
}

function TradeMarketGoodsDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:initData()
end

function TradeMarketGoodsDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnRefreshUButton.luaClick()
		local curTime = Time.realSecondCache

		if not self.lastClickRefreshTime or curTime >= self.lastClickRefreshTime + REFRESH_INTERVAL then
			self:requestListings(self.curListTabIndex, true)

			self.lastClickRefreshTime = curTime
			self.intervalClickRefreshNum = 0
		else
			self.intervalClickRefreshNum = (self.intervalClickRefreshNum or 0) + 1

			if self.intervalClickRefreshNum >= REFRESH_CLICK_MAX_NUM then
				ClientUtils.showBubbleMessageRaw(pg.getGameString("OPERATE_TOO_MANY"))
			end
		end
	end

	function self.view.btnSortUButton.luaClick()
		self:onNoticeSortClicked()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderListTabItem(button, index, data)
	end

	function self.view.listTabUList.luaClick(button, data)
		self:refreshPriceView(data)
	end

	function self.view.listGoodsUList.luaRenderItem(button, index, data)
		if self.listingComponent then
			self.listingComponent:renderItem(button, index, data, self.curListTabIndex)
		end
	end

	function self.view.listGoodsUList.luaClick(button, data)
		if self.listingComponent then
			self.listingComponent:onItemClicked(button, data)
		end
	end
end

function TradeMarketGoodsDetailCtrl:onDestroy()
	self:_exitSubPage()

	self._subPage = nil

	self:_destroyListingComponents()
	UICtrl.onDestroy(self)
end

function TradeMarketGoodsDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._detailOpenInfo = info or {}
	self.operation = self._detailOpenInfo.operation or TradeMarketUtils.Operation.Buy
	self.itemId = self._detailOpenInfo.itemId
	self.tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Goods, self.itemId)
	self.itemName = TradeMarketUtils.getItemName(self.itemId)
	self.tradeItemCfg = TradeItemData[self.itemId] or {}
	self.canAdjustCount = self.tradeItemCfg.isMultiple == 1

	local isAppearanceGoods, isPetAppearance = TradeMarketUtils.isAppearanceGoods(self.itemId)

	self.isPetAppearance = isPetAppearance
	self.goodsType = isAppearanceGoods and TradeMarketGoodsDetailCtrl.GOODS_TYPE.APPEARANCE or TradeMarketGoodsDetailCtrl.GOODS_TYPE.ITEM
	self.goodsData = self._detailOpenInfo.goodsData
	self.listingData = self._detailOpenInfo.listingData
	self.isFollowRequesting = false
	self.noticeSortMode = NOTICE_SORT_MODE.PRICE

	self:_destroyListingComponents()
	self:_createListingComponents()
	self:refreshPage()
end

function TradeMarketGoodsDetailCtrl:onShow()
	if self._subPage and not self._subPageEntered then
		self._subPageEntered = true

		self._subPage:onEnter()
	end
end

function TradeMarketGoodsDetailCtrl:onHide()
	self:_exitSubPage()
end

function TradeMarketGoodsDetailCtrl:isSellCurrency()
	local itemConfig = self.goodsData and self.goodsData.itemConfig or ItemData[self.itemId]

	return itemConfig and itemConfig.type == ItemConst.ITEM_TYPE.Currency or false
end

function TradeMarketGoodsDetailCtrl:getSellAssetId()
	if self:isSellCurrency() then
		return self.itemId
	end

	return self.goodsData and self.goodsData.genID
end

function TradeMarketGoodsDetailCtrl:getSellOwnCount()
	if self:isSellCurrency() then
		return ClientUtils.getItemCountById(self.itemId) or 0
	end

	return self.goodsData and self.goodsData.count or 0
end

function TradeMarketGoodsDetailCtrl:isSellAssetFrozen()
	if self:isSellCurrency() then
		return false
	end

	local packSlot = self.goodsData and self.goodsData.packSlot
	local frozenEndTs = TradeUtils.getTradeFreezeEndTs(packSlot)

	return frozenEndTs > (Time.secondCache or Time.getSecond())
end

function TradeMarketGoodsDetailCtrl:canSellAsset()
	if not self:getSellAssetId() or self:isSellAssetFrozen() then
		return false
	end

	if self.tradeItemCfg.needCanTrade ~= 1 or self:isSellCurrency() then
		return true
	end

	return TradeUtils.isItemCanTrade(self.goodsData and self.goodsData.packSlot)
end

function TradeMarketGoodsDetailCtrl:refreshPage()
	self:initBasicView()
	self:refreshCurrency()
	self:initListTab()

	local subPage = self:_ensureSubPage()

	if not subPage then
		return
	end

	if self._subPageEntered then
		subPage:refreshPage()
	else
		self._subPageEntered = true

		subPage:onEnter()
	end
end

function TradeMarketGoodsDetailCtrl:initBasicView()
	local title

	if self.operation == TradeMarketUtils.Operation.Buy then
		title = "TRADE_GOODS_BUY_TITLE"
	elseif self.operation == TradeMarketUtils.Operation.Sell then
		title = "TRADE_GOODS_SELL_TITLE"
	elseif self.operation == TradeMarketUtils.Operation.Remove then
		title = "TRADE_GOODS_REMOVE_TITLE"
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString(title))
	ClientTextUtils.setText(self.view.txtRefreshUSDFText, pg.getGameString("REFRESH"))
	self:refreshNoticeSortButton()
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
end

function TradeMarketGoodsDetailCtrl:initListTab()
	self.listTabData = TradeMarketUtils.getListTab(self.tradeItemCfg.isNotice == 1, true)

	self.view.listTabUList:SetList(self.listTabData)

	local initialTabData = self.listTabData[1]
	local listingTabIndex = self.listingData and STATUS_LIST_TAB_MAP[self.listingData.status]

	initialTabData = listingTabIndex and self:getListTabData(listingTabIndex) or initialTabData

	self:refreshListingView(initialTabData)
end

function TradeMarketGoodsDetailCtrl:refreshPriceView(data)
	self:refreshListingView(data)
end

function TradeMarketGoodsDetailCtrl:refreshListingView(data)
	if not data then
		return
	end

	self.listingComponent = self:_getListingComponent(data.tabIndex)

	if not self.listingComponent then
		return
	end

	self.curListTabIndex = data.tabIndex

	self.view.listTabUList:SelectItem(data.index, false)
	self.view.btnSortUButton:SetActiveFastest(data.tabIndex == TradeMarketUtils.ListTab.OnNotice)
	TradeMarketUtils.renderListTabTip(self.view.txtTipsUSDFText, data.tabIndex, not self.canAdjustCount)

	local status = LIST_TAB_STATUS_MAP[data.tabIndex]

	self.listingComponent:setStatus(status)

	if data.tabIndex == TradeMarketUtils.ListTab.OnHistory then
		self:showEmptyListingView(data.tabIndex)
		self:refreshSubPageView()

		return
	end

	local curServerData = self.listingComponent:getData(status)

	if curServerData == nil then
		self:showEmptyListingView(data.tabIndex)
		self:requestListings(data.tabIndex, false)
		self:refreshSubPageView()

		return
	end

	if data.tabIndex == TradeMarketUtils.ListTab.OnNotice then
		self:sortNoticeListings(curServerData)
	end

	if #curServerData == 0 then
		self:showEmptyListingView(data.tabIndex)
	else
		self.view.emptyUWidget:SetActive(false)
		self.view.listGoodsUList:SetActive(true)
		self.view.listGoodsUList:SetList(curServerData)
	end

	self.listingComponent:onListRendered(status, curServerData)
	self:refreshSubPageView()
end

function TradeMarketGoodsDetailCtrl:onNoticeSortClicked()
	if self.curListTabIndex ~= TradeMarketUtils.ListTab.OnNotice then
		return
	end

	if self.noticeSortMode == NOTICE_SORT_MODE.TIME then
		self.noticeSortMode = NOTICE_SORT_MODE.PRICE
	else
		self.noticeSortMode = NOTICE_SORT_MODE.TIME
	end

	self:refreshNoticeSortButton()

	local listings = self.normalListingComponent and self.normalListingComponent:getData(TradeConst.LISTING_STATUS.NOTICE)

	if listings then
		self:refreshListingView(self:getListTabData(TradeMarketUtils.ListTab.OnNotice))
	end
end

function TradeMarketGoodsDetailCtrl:refreshNoticeSortButton()
	local textKey = self.noticeSortMode == NOTICE_SORT_MODE.TIME and "PRICE_SORT" or "TIME_SORT"

	ClientTextUtils.setText(self.view.txtSortUSDFText, pg.getGameString(textKey))
end

function TradeMarketGoodsDetailCtrl:sortNoticeListings(listings)
	if not listings or #listings <= 1 then
		return
	end

	local curTime = Time.secondCache or 0
	local isTimeSort = self.noticeSortMode == NOTICE_SORT_MODE.TIME

	local function getRemainingTime(data)
		local noticeEndTs = data.noticeEndTs or 0

		if noticeEndTs <= curTime then
			return math.huge
		end

		return noticeEndTs - curTime
	end

	table.sort(listings, function(a, b)
		local aPrimary = isTimeSort and getRemainingTime(a) or a.unitPrice or 0
		local bPrimary = isTimeSort and getRemainingTime(b) or b.unitPrice or 0

		if aPrimary ~= bPrimary then
			return aPrimary < bPrimary
		end

		local aSecondary = isTimeSort and (a.unitPrice or 0) or getRemainingTime(a)
		local bSecondary = isTimeSort and (b.unitPrice or 0) or getRemainingTime(b)

		if aSecondary ~= bSecondary then
			return aSecondary < bSecondary
		end

		return tostring(a.listingId or "") < tostring(b.listingId or "")
	end)
end

function TradeMarketGoodsDetailCtrl:showEmptyListingView(tabIndex)
	self.view.emptyUWidget:SetActive(true)
	self.view.listGoodsUList:SetActive(false)
	TradeMarketUtils.renderEmptyTip(self.view.txtEmptyUSDFText, tabIndex)
end

function TradeMarketGoodsDetailCtrl:requestListings(tabIndex, forceRefresh)
	if tabIndex == TradeMarketUtils.ListTab.OnHistory then
		return
	end

	local status = LIST_TAB_STATUS_MAP[tabIndex]

	self.listingComponent:request(status, forceRefresh)
end

function TradeMarketGoodsDetailCtrl:onGetListingsByPrice(data)
	if not self.priceListingComponent then
		return
	end

	self.priceListingComponent:onGetListingsByPrice(data)
end

function TradeMarketGoodsDetailCtrl:onGetTradeListings(data)
	if not self.normalListingComponent then
		return
	end

	self.normalListingComponent:onGetTradeListings(data)
end

function TradeMarketGoodsDetailCtrl:onBuyByPriceResult(data)
	if not self.priceListingComponent then
		return
	end

	self.priceListingComponent:onBuyByPriceResult(data)

	if self._subPage and self._subPage._contentLoaded and self._subPage.onBuyByPriceResult then
		self._subPage:onBuyByPriceResult(data)
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
end

function TradeMarketGoodsDetailCtrl:onListingDataChanged(status)
	local tabIndex = STATUS_LIST_TAB_MAP[status]

	if tabIndex ~= self.curListTabIndex then
		return
	end

	self:refreshListingView(self:getListTabData(tabIndex))
end

function TradeMarketGoodsDetailCtrl:onListingSelectionChanged(listingData)
	self.selectedListingData = listingData

	self:refreshSubPageView()
end

function TradeMarketGoodsDetailCtrl:getListTabData(tabIndex)
	for _, tabData in ipairs(self.listTabData or EMPTY_TABLE) do
		if tabData.tabIndex == tabIndex then
			return tabData
		end
	end
end

function TradeMarketGoodsDetailCtrl:toggleFollowTradeItem()
	if self.isFollowRequesting then
		return
	end

	self.isFollowRequesting = true

	self:refreshFollowState()

	local followState = not pg.me:isTradeItemFollow(self.tradeItemKey)

	pg.me:reqFollowTradeItem(self.tradeItemKey, followState, function(noticeCode)
		if noticeCode == NoticeDef.SUCCESS then
			return
		end

		self.isFollowRequesting = false

		self:refreshFollowState()
	end)
end

function TradeMarketGoodsDetailCtrl:onTradeFollowChanged(data)
	if not data or data.tradeItemKey ~= self.tradeItemKey then
		return
	end

	self.isFollowRequesting = false

	self:refreshFollowState()
end

function TradeMarketGoodsDetailCtrl:refreshFollowState()
	if self._subPage and self._subPage._contentLoaded then
		self._subPage:refreshFollowState()
	end
end

function TradeMarketGoodsDetailCtrl:_createListingComponents()
	if self.canAdjustCount then
		self.priceListingComponent = TradeMarketGoodsPriceListComponent.new(self)
	end

	self.normalListingComponent = TradeMarketGoodsListingListComponent.new(self)
end

function TradeMarketGoodsDetailCtrl:_getListingComponent(tabIndex)
	if self.canAdjustCount and tabIndex == TradeMarketUtils.ListTab.OnSale then
		return self.priceListingComponent
	end

	return self.normalListingComponent
end

function TradeMarketGoodsDetailCtrl:_destroyListingComponents()
	if self.priceListingComponent then
		self.priceListingComponent:destroy()

		self.priceListingComponent = nil
	end

	if self.normalListingComponent then
		self.normalListingComponent:destroy()

		self.normalListingComponent = nil
	end

	self.listingComponent = nil
end

function TradeMarketGoodsDetailCtrl:_ensureSubPage()
	local cls, uContainer = self:_getSubPageConfig(self.goodsType)

	self._subPage = cls.new(self, uContainer)

	self:_refreshSubPageVisible(self.goodsType)

	return self._subPage
end

function TradeMarketGoodsDetailCtrl:_getSubPageConfig(pageType)
	if pageType == TradeMarketGoodsDetailCtrl.GOODS_TYPE.APPEARANCE then
		return TradeMarketGoodsDetailAppearanceSubPageComponent, self.view.appearanceUContainer
	end

	return TradeMarketGoodsDetailItemSubPageComponent, self.view.propsUContainer
end

function TradeMarketGoodsDetailCtrl:_refreshSubPageVisible(pageType)
	if self.view.propsUContainer then
		self.view.propsUContainer:SetActive(pageType == TradeMarketGoodsDetailCtrl.GOODS_TYPE.ITEM)
	end

	if self.view.appearanceUContainer then
		self.view.appearanceUContainer:SetActive(pageType == TradeMarketGoodsDetailCtrl.GOODS_TYPE.APPEARANCE)
	end
end

function TradeMarketGoodsDetailCtrl:_exitSubPage()
	if self._subPage and self._subPageEntered then
		self._subPage:onExit()
	end

	self._subPageEntered = false
end

function TradeMarketGoodsDetailCtrl:refreshCurrency()
	return
end

function TradeMarketGoodsDetailCtrl:refreshSubPageView()
	if self._subPage and self._subPage._contentLoaded then
		self._subPage:refreshPage()
	end
end

function TradeMarketGoodsDetailCtrl:refreshModelView()
	if self._subPage and self._subPage.refreshModelView then
		self._subPage:refreshModelView()
	end
end

function TradeMarketGoodsDetailCtrl:getCurrentBuyData()
	return self.listingComponent and self.listingComponent:getCurrentBuyData() or nil
end

function TradeMarketGoodsDetailCtrl:buyCurrentGoods(count, callback)
	callback = callback or function()
		return
	end

	if not self.listingComponent then
		return false
	end

	return self.listingComponent:buyCurrentGoods(count, callback)
end

function TradeMarketGoodsDetailCtrl:getFirstOnSaleGoods()
	return self:getCurrentBuyData()
end

return TradeMarketGoodsDetailCtrl
