-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\TradeUtils.lua

local TradeConst = require("Common.Const.TradeConst")
local ItemConst = require("Common.Const.ItemConst")
local TradeUtils = {}

function TradeUtils.makeTradeItemKey(tradeType, tradeItemId)
	return tostring(tradeType) .. ":" .. tostring(tradeItemId)
end

function TradeUtils.calcBucketId(tradeItemKey)
	local hash = 5381

	for i = 1, #tradeItemKey do
		hash = (hash * 33 + tradeItemKey:byte(i)) % 16777259
	end

	return hash % TradeConst.SHARD_BUCKET_NUM
end

function TradeUtils.makeRouteHint(bucketId)
	return "trade_" .. tostring(bucketId)
end

function TradeUtils.getTradeFreezeEndTs(item)
	local props = item and item.props
	local tradeData = props and props[ItemConst.ItemPropertyDef.TradeData]

	return tradeData and (tradeData.freezeEndTs or 0) or 0
end

function TradeUtils.isItemCanTrade(item)
	local props = item and item.props
	local tradeData = props and props[ItemConst.ItemPropertyDef.TradeData]

	return tradeData and tradeData.canTrade == true
end

function TradeUtils.getPetTradeFreezeEndTs(petInfo)
	local tradeData = petInfo and petInfo.tradeData

	return tradeData and (tradeData.freezeEndTs or 0) or 0
end

function TradeUtils.isPetCanTrade(petInfo)
	local tradeData = petInfo and petInfo.tradeData

	return tradeData and tradeData.canTrade == true
end

function TradeUtils.makeTradeBuyAddContext(txnId, tradeItemConfig, freezeHours, now)
	local context = {
		opNUID = txnId
	}
	local tradeData = {}

	if tradeItemConfig.isFrozen == 1 and freezeHours > 0 then
		tradeData.freezeEndTs = now + freezeHours * 3600
	end

	if tradeItemConfig.isFreePrice == 1 and tradeItemConfig.needCanTrade == 1 then
		tradeData.canTrade = true
	end

	if next(tradeData) then
		context.tradeData = tradeData
	end

	return context
end

function TradeUtils.makeTradePetBuyAddContext(txnId, tradeItemConfig, freezeHours, now)
	local context = {
		opNUID = txnId
	}

	if not tradeItemConfig then
		return context
	end

	local tradeData = {}

	if tradeItemConfig.isFrozen == 1 and freezeHours > 0 then
		tradeData.freezeEndTs = now + freezeHours * 3600
	end

	if tradeItemConfig.isFreePrice == 1 and tradeItemConfig.needCanTrade == 1 then
		tradeData.canTrade = true
	end

	if next(tradeData) then
		context.tradeData = tradeData
	end

	return context
end

return TradeUtils
