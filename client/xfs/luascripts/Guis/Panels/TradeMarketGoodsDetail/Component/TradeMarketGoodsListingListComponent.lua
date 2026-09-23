-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketGoodsListingListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeConst = require("Common.Const.TradeConst")
local NoticeDef = require("Common.NoticeDef")
local TradeMarketGoodsListingListComponent = Class.LightClass("TradeMarketGoodsListingListComponent")
local TRADE_LISTINGS_LIMIT = 20
local TRADE_LISTINGS_OFFSET = 0

function TradeMarketGoodsListingListComponent:ctor(ctrl)
	self.ctrl = ctrl
	self.dataByStatus = {}
	self.totalByStatus = {}
	self.selectedListingIdByStatus = {}
	self.selectedListingByStatus = {}
	self.currentStatus = nil
end

function TradeMarketGoodsListingListComponent:setStatus(status)
	self.currentStatus = status
end

function TradeMarketGoodsListingListComponent:request(status, forceRefresh)
	if not status then
		return
	end

	if not forceRefresh and self.dataByStatus[status] ~= nil then
		self.ctrl:onListingDataChanged(status)

		return
	end

	pg.me:reqGetTradeListings({
		status
	}, self.ctrl.tradeItemKey, TRADE_LISTINGS_LIMIT, TRADE_LISTINGS_OFFSET, function()
		return
	end)
end

function TradeMarketGoodsListingListComponent:onGetTradeListings(data)
	if not data or not data.statusList or data.tradeItemKey ~= self.ctrl.tradeItemKey then
		return
	end

	local status = data.statusList[1]

	if not status then
		return
	end

	local listings = data.listings or {}

	self.dataByStatus[status] = listings
	self.totalByStatus[status] = data.total or #listings

	self.ctrl:onListingDataChanged(status)
end

function TradeMarketGoodsListingListComponent:getData(status)
	return status and self.dataByStatus[status] or nil
end

function TradeMarketGoodsListingListComponent:renderItem(button, index, data, tabIndex)
	TradeMarketUtils.renderListingItem(button, index, data, tabIndex)
end

function TradeMarketGoodsListingListComponent:onItemClicked(button, data)
	if not data or not data.listingId or not self.currentStatus then
		return
	end

	self.selectedListingIdByStatus[self.currentStatus] = data.listingId
	self.selectedListingByStatus[self.currentStatus] = data

	for index, listingData in ipairs(self.dataByStatus[self.currentStatus] or EMPTY_TABLE) do
		if listingData.listingId == data.listingId then
			self.ctrl.view.listGoodsUList:SelectItem(index - 1, false)

			break
		end
	end

	self.ctrl:onListingSelectionChanged(data)
end

function TradeMarketGoodsListingListComponent:onListRendered(status, data)
	local selectedListingId = self.selectedListingIdByStatus[status]

	if not selectedListingId and self.ctrl.listingData and self.ctrl.listingData.status == status then
		selectedListingId = self.ctrl.listingData.listingId
	end

	local selectedIndex, selectedListingData

	for index, listingData in ipairs(data or EMPTY_TABLE) do
		if listingData.listingId == selectedListingId then
			selectedIndex = index
			selectedListingData = listingData

			break
		end
	end

	if not selectedListingData and data and data[1] then
		selectedIndex = 1
		selectedListingData = data[1]
	end

	self.selectedListingIdByStatus[status] = selectedListingData and selectedListingData.listingId or nil
	self.selectedListingByStatus[status] = selectedListingData

	if selectedIndex then
		self.ctrl.view.listGoodsUList:SelectItem(selectedIndex - 1, false)
	end

	self.ctrl:onListingSelectionChanged(selectedListingData)
end

function TradeMarketGoodsListingListComponent:getCurrentBuyData()
	if self.currentStatus ~= TradeConst.LISTING_STATUS.SELLING then
		return nil
	end

	local listingData = self.selectedListingByStatus[self.currentStatus]

	if not listingData or not listingData.listingId or listingData.bucketId == nil then
		return nil
	end

	if listingData.status ~= TradeConst.LISTING_STATUS.SELLING or tostring(listingData.sellerUid) == tostring(pg.me.uid) then
		return nil
	end

	if listingData.remainCount ~= nil and listingData.remainCount <= 0 then
		return nil
	end

	return {
		maxCount = 1,
		unitPrice = listingData.unitPrice or 0,
		listingData = listingData
	}
end

function TradeMarketGoodsListingListComponent:buyCurrentGoods(count, callback)
	local buyData = self:getCurrentBuyData()

	if not buyData then
		return false
	end

	callback = callback or function()
		return
	end

	local listingData = buyData.listingData

	pg.me:reqBuyTradeItem(listingData.bucketId, listingData.listingId, 1, function(noticeCode)
		if noticeCode == NoticeDef.SUCCESS or noticeCode == NoticeDef.TRADE_LISTING_NOT_EXIST or noticeCode == NoticeDef.TRADE_LISTING_STATUS_INVALID or noticeCode == NoticeDef.TRADE_STOCK_NOT_ENOUGH then
			self:refreshSellingListings()
		end

		callback(noticeCode)
	end)

	return true
end

function TradeMarketGoodsListingListComponent:refreshSellingListings()
	self.dataByStatus = {}
	self.totalByStatus = {}
	self.selectedListingIdByStatus[TradeConst.LISTING_STATUS.SELLING] = nil
	self.selectedListingByStatus[TradeConst.LISTING_STATUS.SELLING] = nil

	self.ctrl:onListingSelectionChanged(nil)
	self:request(TradeConst.LISTING_STATUS.SELLING, true)
end

function TradeMarketGoodsListingListComponent:destroy()
	self.ctrl = nil
	self.dataByStatus = nil
	self.totalByStatus = nil
	self.selectedListingIdByStatus = nil
	self.selectedListingByStatus = nil
	self.currentStatus = nil
end

return TradeMarketGoodsListingListComponent
