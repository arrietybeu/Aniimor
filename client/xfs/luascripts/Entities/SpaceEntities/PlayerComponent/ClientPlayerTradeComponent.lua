-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerTradeComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientPlayerTradeComponent")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local TradeConst = require("Common.Const.TradeConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientPlayerTradeComponent = Class.Component("ClientPlayerTradeComponent")
local DEFAULT_PAGE_LIMIT = 20
local DEFAULT_PAGE_OFFSET = 0
local RUSH_REGISTER_SUCCESS_CODES = {
	[NoticeDef.SUCCESS] = true,
	[NoticeDef.TRADE_IN_RUSH_WINDOW] = true,
	[NoticeDef.TRADE_IN_RUSH] = true
}

function ClientPlayerTradeComponent:wrapTradeRpcCallback(callback)
	return function(noticeCode, ...)
		if noticeCode ~= NoticeDef.SUCCESS then
			ClientUtils.showBubbleMessage(noticeCode)
		end

		callback(noticeCode, ...)
	end
end

function ClientPlayerTradeComponent:reqBuyTradeItem(bucketId, listingId, count, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqBuyTradeItem bucketId:%d  listingId:%s  count:%d", bucketId, listingId, count)
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeBuy", bucketId, listingId, count, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqBuyTradeItemByPrice(tradeItemKey, unitPrice, count, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqBuyTradeItemByPrice tradeItemKey:%s  unitPrice:%s  count:%d", tradeItemKey, unitPrice, count)
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeBuyByPrice", tradeItemKey, unitPrice, count, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqSellTradeItem(tradeType, tradeItemId, assetId, count, unitPrice, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqSellTradeItem tradeType:%s  tradeItemId:%s  assetId:%s count:%s  unitPrice:%s", tradeType, tradeItemId, assetId, count, unitPrice)
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeList", tradeType, tradeItemId, assetId, count, unitPrice, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqRemoveTradeItem(listingId, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqRemoveTradeItem listingId:%s", listingId)
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeRemoveListing", listingId, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqRushTradeItem(bucketId, listingId, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqRushTradeItem bucketId:%s  listingId:%s", bucketId, listingId)
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeRush", bucketId, listingId, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqFollowTradeItem(tradeItemKey, followState, callback)
	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeWatch", tradeItemKey, followState, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:onTradeWatchAdded(tradeItemKey)
	self:notifyTradeFollowChanged(tradeItemKey, true)
end

function ClientPlayerTradeComponent:onTradeWatchDeleted(tradeItemKey)
	self:notifyTradeFollowChanged(tradeItemKey, false)
end

function ClientPlayerTradeComponent:notifyTradeFollowChanged(tradeItemKey, followState)
	facade:sendMsgToUI(MessageName.ON_TRADE_FOLLOW_CHANGED, {
		tradeItemKey = tradeItemKey,
		followState = followState
	})
end

function ClientPlayerTradeComponent:isTradeItemFollow(tradeItemKey)
	return self.tradeWatchList and self.tradeWatchList[tradeItemKey] == true
end

function ClientPlayerTradeComponent:reqGetTradeListings(statusList, tradeItemKey, limit, offset, callback)
	self.tradeListingsCache = nil

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reqGetTradeListings statusList:%s tradeItemKey:%s  limit:%s  offset:%s", statusList, tradeItemKey, limit, offset)
	end

	limit = limit or DEFAULT_PAGE_LIMIT
	offset = offset or DEFAULT_PAGE_OFFSET
	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeGetListings", statusList, tradeItemKey, limit, offset, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqGetListingsByPrice(status, tradeItemKey, limit, offset, callback)
	limit = limit or DEFAULT_PAGE_LIMIT
	offset = offset or DEFAULT_PAGE_OFFSET
	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeGetListingsByPrice", status, tradeItemKey, limit, offset, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqGetMyListings(callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_CS_TradeGetMyListings")
	end

	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeGetMyListings", self:wrapTradeRpcCallback(function(code, ...)
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("RPC_CS_TradeGetMyListings  ", code)
		end

		callback(code, ...)
	end))
end

function ClientPlayerTradeComponent:reqGetTradeRecords(displayType, limit, offset, callback)
	limit = limit or DEFAULT_PAGE_LIMIT
	offset = offset or DEFAULT_PAGE_OFFSET
	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeGetRecords", displayType, limit, offset, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:reqGetTradeOverview(displayType, displaySubType, callback)
	displayType = displayType or 0
	displaySubType = displaySubType or 0
	callback = callback or function()
		return
	end

	return self:serverMsg("RPC_CS_TradeGetOverview", displayType, displaySubType, self:wrapTradeRpcCallback(callback))
end

function ClientPlayerTradeComponent:RPC_SC_TradeListResult(noticeCode, listingId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_TradeListResult noticeCode:%s listingId:%s", noticeCode, listingId)
	end

	if noticeCode ~= NoticeDef.SUCCESS then
		ClientUtils.showBubbleMessage(noticeCode)

		return
	end

	self:reqGetMyListings()
end

function ClientPlayerTradeComponent:RPC_SC_TradeListingsResult(statusList, tradeItemKey, limit, offset, listings, total)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_TradeListingsResult statusList:%s tradeItemKey:%s  limit:%s  offset:%s", statusList, tradeItemKey, limit, offset)
	end

	listings = listings or {}

	facade:sendMsgToUI(MessageName.ON_GET_TRADE_LISTINGS, {
		statusList = statusList,
		tradeItemKey = tradeItemKey,
		limit = limit,
		offset = offset,
		listings = listings,
		total = total or 0
	})
end

function ClientPlayerTradeComponent:RPC_SC_TradeListingsByPriceResult(status, tradeItemKey, limit, offset, priceGroups, total)
	facade:sendMsgToUI(MessageName.ON_GET_TRADE_LISTINGS_BY_PRICE, {
		status = status,
		priceGroups = priceGroups or {},
		total = total or 0
	})
end

function ClientPlayerTradeComponent:RPC_SC_TradeMyListingsResult(listings)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_TradeMyListingsResult")
	end

	facade:sendMsgToUI(MessageName.ON_GET_TRADE_MY_ON_SALE, {
		listings = listings or {}
	})
end

function ClientPlayerTradeComponent:RPC_SC_TradeRecordsResult(displayType, limit, offset, records, total)
	facade:sendMsgToUI(MessageName.ON_GET_TRADE_RECORDS, {
		displayType = displayType,
		limit = limit,
		offset = offset,
		records = records or {},
		total = total or 0
	})
end

function ClientPlayerTradeComponent:RPC_SC_TradeOverviewResult(displayType, displaySubType, items)
	facade:sendMsgToUI(MessageName.ON_GET_TRADE_OVERVIEW, {
		displayType = displayType,
		displaySubType = displaySubType,
		items = items or {}
	})
end

function ClientPlayerTradeComponent:RPC_SC_TradeBuyResult(noticeCode, action, listingId, count)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_TradeBuyResult noticeCode:%s action:%s listingId:%s count:%s", noticeCode, action, listingId, count)
	end

	if action == TradeConst.BUY_ACTION.RUSH then
		if not RUSH_REGISTER_SUCCESS_CODES[noticeCode] then
			return
		end

		if not pg.global.ui:checkUIOpen(UIConst.UI_ID_TRADE_MARKET_PANIC_BUY) then
			pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_PANIC_BUY, {
				listingId = listingId,
				count = count
			})
		end

		return
	end

	if action == TradeConst.BUY_ACTION.RUSH_SETTLE then
		pg.global.ui:close(UIConst.UI_ID_TRADE_MARKET_PANIC_BUY)
	end
end

function ClientPlayerTradeComponent:RPC_SC_TradeBuyByPriceResult(tradeItemKey, unitPrice, requestedCount, purchasedCount)
	facade:sendMsgToUI(MessageName.ON_TRADE_BUY_BY_PRICE_RESULT, {
		tradeItemKey = tradeItemKey,
		unitPrice = unitPrice,
		requestedCount = requestedCount,
		purchasedCount = purchasedCount
	})
end

return ClientPlayerTradeComponent
