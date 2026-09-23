-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\TradeConst.lua

local TradeConst = {}

TradeConst.SHARD_BUCKET_NUM = 8
TradeConst.TRADE_TYPE_ITEM = 1
TradeConst.TRADE_TYPE_PET = 2
TradeConst.PRICE_MODE_RECOMMEND = 0
TradeConst.PRICE_MODE_FREE = 1
TradeConst.BUY_ACTION = {
	RUSH = 2,
	BUY = 1,
	RUSH_SETTLE = 3
}
TradeConst.LISTING_STATUS = {
	REMOVED = "removed",
	RUSH = "rush",
	EXPIRED = "expired",
	SETTLED = "settled",
	AUDIT = "audit",
	SOLD = "sold",
	SELLING = "selling",
	NOTICE = "notice",
	ERROR = "error"
}
TradeConst.BUY_ACTION = {
	RUSH = 2,
	BUY = 1,
	RUSH_SETTLE = 3
}
TradeConst.ACTIVE_STATUS_SET = {
	[TradeConst.LISTING_STATUS.NOTICE] = true,
	[TradeConst.LISTING_STATUS.RUSH] = true,
	[TradeConst.LISTING_STATUS.SELLING] = true,
	[TradeConst.LISTING_STATUS.AUDIT] = true,
	[TradeConst.LISTING_STATUS.EXPIRED] = true
}
TradeConst.TERMINAL_STATUS_SET = {
	[TradeConst.LISTING_STATUS.SOLD] = true,
	[TradeConst.LISTING_STATUS.SETTLED] = true,
	[TradeConst.LISTING_STATUS.REMOVED] = true
}
TradeConst.TXN_MARK = {
	BUYER_PAID = "buyerPaid",
	SELLER_MAILED = "sellerMailed",
	SELLER_ASSET_ESCROWED = "sellerAssetEscrowed",
	SELLER_SETTLED = "sellerSettled",
	BUYER_DELIVERED = "buyerDelivered"
}
TradeConst.TXN_TYPE_TRADE_LIST = "trade_list"
TradeConst.TXN_TYPE_TRADE_BUY = "trade_buy"
TradeConst.TXN_TYPE_TRADE_SETTLE = "trade_settle"
TradeConst.SHINY_SCORE_STAGE_THRESHOLD = 4
TradeConst.RUSH_RETRY_NEXT_ON_FAIL = true
TradeConst.RUSH_SETTLE_REPLY_TIMEOUT = 10
TradeConst.TRADE_TAX_RATE = 0.05
TradeConst.TRADE_MAIL_SRC_ID = "trade_seller_gain"
TradeConst.TRADE_NOTICE_DURATION = 3600
TradeConst.TRADE_RUSH_DURATION = 1800
TradeConst.TRADE_AUDIT_DURATION = 86400
TradeConst.MONGO_COLLECTION_LISTING = "trade_listing"
TradeConst.MONGO_COLLECTION_HISTORY = "trade_history"
TradeConst.MONGO_COLLECTION_PRICE = "trade_price"
TradeConst.LISTING_LOAD_LIMIT = 10000
TradeConst.SERVICE_TICK_SUB_INTERVAL = 1
TradeConst.BUCKET_TICK_INTERVAL = 5
TradeConst.FUNCTION_UNLOCK_NAME = "TRADE"
TradeConst.DEFAULT_STALL_SLOTS = 10
TradeConst.WATCH_LIST_LIMIT = 100

return TradeConst
