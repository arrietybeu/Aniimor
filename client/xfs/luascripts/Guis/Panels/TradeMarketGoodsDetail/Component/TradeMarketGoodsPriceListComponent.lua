-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketGoodsDetail\\Component\\TradeMarketGoodsPriceListComponent.lua

local Class = require("Core.Framework.Class")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeConst = require("Common.Const.TradeConst")
local TradeMarketGoodsPriceListComponent = Class.LightClass("TradeMarketGoodsPriceListComponent")
local LISTINGS_BY_PRICE_LIMIT = 7
local LISTINGS_BY_PRICE_OFFSET = 0

function TradeMarketGoodsPriceListComponent:ctor(ctrl)
	self.ctrl = ctrl
	self.dataByStatus = {}
	self.totalByStatus = {}
	self.currentStatus = nil
end

function TradeMarketGoodsPriceListComponent:setStatus(status)
	self.currentStatus = status
end

function TradeMarketGoodsPriceListComponent:request(status, forceRefresh)
	if not status then
		return
	end

	if not forceRefresh and self.dataByStatus[status] ~= nil then
		self.ctrl:onListingDataChanged(status)

		return
	end

	pg.me:reqGetListingsByPrice(status, self.ctrl.tradeItemKey, LISTINGS_BY_PRICE_LIMIT, LISTINGS_BY_PRICE_OFFSET, function()
		return
	end)
end

function TradeMarketGoodsPriceListComponent:onGetListingsByPrice(data)
	if not data or not data.status then
		return
	end

	self.dataByStatus[data.status] = data.priceGroups or {}
	self.totalByStatus[data.status] = data.total or 0

	self.ctrl:onListingDataChanged(data.status)
end

function TradeMarketGoodsPriceListComponent:getData(status)
	return status and self.dataByStatus[status] or nil
end

function TradeMarketGoodsPriceListComponent:renderItem(button, index, data, tabIndex)
	TradeMarketUtils.renderPriceItem(button, index, data.unitPrice, data.totalCount, nil, tabIndex)
end

function TradeMarketGoodsPriceListComponent:onItemClicked(button, data)
	return
end

function TradeMarketGoodsPriceListComponent:onListRendered(status, data)
	return
end

function TradeMarketGoodsPriceListComponent:getCurrentBuyData()
	if self.currentStatus ~= TradeConst.LISTING_STATUS.SELLING then
		return nil
	end

	local data = self.dataByStatus[self.currentStatus]
	local priceGroup = data and data[1]

	if not priceGroup then
		return nil
	end

	local maxCount = priceGroup.totalCount or 0

	if maxCount <= 0 then
		return nil
	end

	return {
		unitPrice = priceGroup.unitPrice or 0,
		maxCount = maxCount,
		priceGroup = priceGroup
	}
end

function TradeMarketGoodsPriceListComponent:buyCurrentGoods(count, callback)
	local buyData = self:getCurrentBuyData()

	if not buyData then
		return false
	end

	callback = callback or function()
		return
	end
	count = math.min(math.max(count or 1, 1), buyData.maxCount)

	pg.me:reqBuyTradeItemByPrice(self.ctrl.tradeItemKey, buyData.unitPrice, count, callback)

	return true
end

function TradeMarketGoodsPriceListComponent:onBuyByPriceResult(data)
	if not data or data.tradeItemKey ~= self.ctrl.tradeItemKey then
		return
	end

	self.dataByStatus[TradeConst.LISTING_STATUS.SELLING] = nil

	self:request(TradeConst.LISTING_STATUS.SELLING, true)
end

function TradeMarketGoodsPriceListComponent:destroy()
	self.ctrl = nil
	self.dataByStatus = nil
	self.totalByStatus = nil
	self.currentStatus = nil
end

return TradeMarketGoodsPriceListComponent
