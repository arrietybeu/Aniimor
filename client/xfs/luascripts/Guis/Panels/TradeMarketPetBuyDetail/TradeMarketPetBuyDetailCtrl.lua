-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetBuyDetail\\TradeMarketPetBuyDetailCtrl.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TradeConst = require("Common.Const.TradeConst")
local NoticeDef = require("Common.NoticeDef")
local TradeMarketPetDetailBaseCtrl = require("Guis.Panels.TradeMarketPetDetail.TradeMarketPetDetailBaseCtrl")
local TradeMarketPetSnapshotDetailComponent = require("Guis.Panels.TradeMarketPetDetail.Component.TradeMarketPetSnapshotDetailComponent")
local TradeMarketPetBuyDetailCtrl = Class.LightClass("TradeMarketPetBuyDetailCtrl", TradeMarketPetDetailBaseCtrl)

TradeMarketPetBuyDetailCtrl.messages = {
	[MessageName.ON_GET_TRADE_LISTINGS] = {
		"onGetTradeListings",
		true
	},
	[MessageName.ON_TRADE_FOLLOW_CHANGED] = {
		"onTradeFollowChanged",
		true
	}
}

function TradeMarketPetBuyDetailCtrl:createPetDetailComponent()
	return TradeMarketPetSnapshotDetailComponent.new(self)
end

function TradeMarketPetBuyDetailCtrl:addListener()
	TradeMarketPetBuyDetailCtrl.super.addListener(self)

	function self.view.btnPurchaseUButton.luaClick()
		self:onBuyClicked()
	end

	function self.view.listPetUList.luaClick(button, data)
		self:onPetListingClicked(data)
	end

	function self.view.listCoinsUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local imgIcon = objectReference:GetRefValue("imgIcon")
		local txtNum = objectReference:GetRefValue("txtNum")
		local btnClick = objectReference:GetRefValue("btnClick")

		imgIcon.url = TradeMarketUtils.getTradeCurrencyUrlPath()

		ClientTextUtils.setText(txtNum, self.curListingData and self.curListingData.unitPrice or 0)

		function button.luaRenderTooltip(btn, tooltip)
			LuaUIUtils.refreshItemInfo(tooltip, {
				itemId = TradeMarketUtils.getTradeCurrency()
			})
		end
	end

	function self.view.btnAttentionUButton.luaClick()
		self:toggleFollowTradeItem()
	end

	self.view.progressAttentionUProgress.minValue = 0
	self.view.progressAttentionUProgress.maxValue = TradeMarketUtils.getFollowFullCount()
	self.view.progressAttentionUProgress.value = 0
end

function TradeMarketPetBuyDetailCtrl:onOpen(info)
	TradeMarketPetBuyDetailCtrl.super.onOpen(self, info)

	self.isFollowRequesting = false
	self.isBuying = false

	self.view.widget:TryChangePage("Launch", 0)
	self.view.listCoinsUList:SetList({
		{}
	})
	ClientTextUtils.setText(self.view.btnTxtNameUText, pg.getGameString("SHOP_BUY"))
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TRADE_PET_BUY_TITLE"))
	self:selectListing(info.listingData)
end

function TradeMarketPetBuyDetailCtrl:refreshPetDetailView()
	local petInfo = self.petData

	if not petInfo or not petInfo.templateId then
		self:refreshPetDetail({
			isEmpty = true
		}, {
			templateId = self.petTemplateId
		})

		return
	end

	self:refreshPetDetail(petInfo, petInfo)
end

function TradeMarketPetBuyDetailCtrl:selectListing(listingData)
	self.curListingData = listingData
	self.petData = listingData and listingData.assetSnapshot or nil

	self:refreshPetDetailView()
	self:refreshBuyState()
end

function TradeMarketPetBuyDetailCtrl:onPetListingClicked(listingData)
	if self.isBuying then
		return
	end

	self:selectListing(listingData)
end

function TradeMarketPetBuyDetailCtrl:onPetListingsChanged(listings)
	if not listings or #listings == 0 then
		if self.curListingData and self:isCurrentPetListingStatus(self.curListingData.status) and self.petInfiniteScrollList and self.petInfiniteScrollList:hasMore() then
			return
		end

		self:selectListing(nil)

		return
	end

	if self.curListingData and self.curListingData.listingId then
		for index, listingData in ipairs(listings) do
			if listingData.listingId == self.curListingData.listingId then
				self.view.listPetUList:SelectItem(index - 1, false)

				return
			end
		end

		if self:isCurrentPetListingStatus(self.curListingData.status) and self.petInfiniteScrollList and self.petInfiniteScrollList:hasMore() then
			return
		end
	end

	self.view.listPetUList:SelectItem(0, false)
	self:selectListing(listings[1])
end

function TradeMarketPetBuyDetailCtrl:canBuyCurrentListing()
	local listingData = self.curListingData

	return listingData ~= nil and self.petData ~= nil and listingData.listingId ~= nil and listingData.bucketId ~= nil and (listingData.status == TradeConst.LISTING_STATUS.SELLING or listingData.status == TradeConst.LISTING_STATUS.RUSH) and tostring(listingData.sellerUid) ~= tostring(pg.me.uid) and not self.isBuying
end

function TradeMarketPetBuyDetailCtrl:refreshBuyState()
	local hasListing = self.curListingData ~= nil and self.petData ~= nil

	self.view.listCoinsUList:SetActiveFastest(hasListing)
	self.view.btnAttentionUButton:SetActiveFastest(hasListing)

	self.view.btnPurchaseUButton.visualInteractable = self:canBuyCurrentListing()

	if hasListing then
		self.view.listCoinsUList:RefreshList()
	end

	self:refreshFollowState()
end

function TradeMarketPetBuyDetailCtrl:toggleFollowTradeItem()
	if not self.curListingData or self.isFollowRequesting then
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

function TradeMarketPetBuyDetailCtrl:onTradeFollowChanged(data)
	if not data or data.tradeItemKey ~= self.tradeItemKey then
		return
	end

	self.isFollowRequesting = false

	self:refreshFollowState()
	self:refreshPetListingsFromCache(true)
end

function TradeMarketPetBuyDetailCtrl:refreshFollowState()
	local hasListing = self.curListingData ~= nil and self.petData ~= nil

	self.view.btnAttentionUButton:SetActiveFastest(hasListing)

	self.view.btnAttentionUButton.visualInteractable = hasListing and not self.isFollowRequesting
	self.view.progressAttentionUProgress.value = hasListing and pg.me:isTradeItemFollow(self.tradeItemKey) and TradeMarketUtils.getFollowFullCount() or 0
end

function TradeMarketPetBuyDetailCtrl:onBuyClicked()
	if not self:canBuyCurrentListing() then
		return
	end

	local listingData = self.curListingData

	TradeMarketUtils.openBuyConfirmUI(function()
		self:buyPetListing(listingData)
	end, listingData.unitPrice, self.petName, 1)
end

function TradeMarketPetBuyDetailCtrl:buyPetListing(listingData)
	if not self:canBuyCurrentListing() or not listingData or listingData.listingId ~= self.curListingData.listingId then
		return
	end

	self.isBuying = true

	self:refreshBuyState()
	pg.me:reqBuyTradeItem(listingData.bucketId, listingData.listingId, 1, function(noticeCode)
		self.isBuying = false

		if noticeCode == NoticeDef.SUCCESS then
			self:clearPetListingCache(self.curListTabIndex)

			self.petListingRequests = {}

			self:selectListing(nil)
			LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
			self.petInfiniteScrollList:reset(0)

			return
		end

		if noticeCode == NoticeDef.TRADE_LISTING_NOT_EXIST or noticeCode == NoticeDef.TRADE_LISTING_STATUS_INVALID or noticeCode == NoticeDef.TRADE_STOCK_NOT_ENOUGH then
			self:clearPetListingCache(self.curListTabIndex)

			self.petListingRequests = {}

			self:selectListing(nil)
			self.petInfiniteScrollList:reset(0)

			return
		end

		self:refreshBuyState()
	end)
end

function TradeMarketPetBuyDetailCtrl:onDestroy()
	if self.petInfiniteScrollList then
		self.petInfiniteScrollList:destroy()

		self.petInfiniteScrollList = nil
	end

	self.view.btnSortUButton.luaClick = nil
	self.view.listTab3thUList.luaRenderItem = nil
	self.view.listTab3thUList.luaClick = nil
	self.view.listPetUList.luaRenderItem = nil
	self.view.listPetUList.luaClick = nil
	self.view.listCoinsUList.luaRenderItem = nil
	self.view.btnAttentionUButton.luaClick = nil
	self.view.btnPurchaseUButton.luaClick = nil
	self.curListingData = nil
	self.petData = nil
	self.isFollowRequesting = nil
	self.isBuying = nil

	TradeMarketPetBuyDetailCtrl.super.onDestroy(self)
end

return TradeMarketPetBuyDetailCtrl
