-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellGoods\\TradeMarketSellGoodsModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellGoodsModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local TradeItemData = require("Data.trade_items_data")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local TradeUtils = require("Common.Utils.TradeUtils")
local Time = require("Core.Common.Time")
local TradeMarketSellGoodsModel = Class.LightClass("TradeMarketSellGoodsModel", UIModel)
local DEFAULT_INVENTORY_IDS = {
	ItemConst.INV_TYPE_PLAYER,
	ItemConst.INV_TYPE_PET,
	ItemConst.INV_TYPE_BALL,
	ItemConst.INV_TYPE_COMMON,
	ItemConst.INV_TYPE_PET_JEWELRY,
	ItemConst.INV_TYPE_HOMELAND
}
local ITEM_TYPE_SORT_PRIORITY = {
	[ItemConst.ITEM_TYPE.Currency] = 1,
	[ItemConst.ITEM_TYPE.EGG] = 2
}
local DEFAULT_ITEM_TYPE_SORT_PRIORITY = 3

function TradeMarketSellGoodsModel:_getInventoryIds()
	if pg.me.inventoryIds and #pg.me.inventoryIds > 0 then
		return pg.me.inventoryIds
	end

	return DEFAULT_INVENTORY_IDS
end

function TradeMarketSellGoodsModel:getCanSellGoodsData()
	local items = {}

	if not pg.me then
		return items
	end

	local curOADate = TradeMarketUtils.getCurOADate()
	local curTimeTs = Time.secondCache or Time.getSecond()

	for itemId in pairs(TradeItemData) do
		local itemConfig = ItemData[itemId]

		if itemConfig and itemConfig.invId == ItemConst.INV_TYPE_SPECIAL and self:checkCanSell(nil, itemId, curOADate) then
			local count = ClientUtils.getItemCountById(itemId) or 0

			if count > 0 then
				items[#items + 1] = {
					canSell = true,
					isFrozen = false,
					itemId = itemId,
					invId = ItemConst.INV_TYPE_SPECIAL,
					count = count,
					itemConfig = itemConfig,
					tradeConfig = TradeItemData[itemId],
					itemName = itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or "",
					num = count
				}
			end
		end
	end

	if pg.me then
		for _, invId in ipairs(self:_getInventoryIds()) do
			local itemBag = ItemUtils.getTypedBag(pg.me, invId)

			if itemBag and itemBag.items then
				for _, packSlot in itemBag:items() do
					local itemId = packSlot.id
					local count = packSlot.count or 0
					local itemConfig = ItemData[itemId]

					if count > 0 and self:checkCanSell(packSlot, itemId, curOADate) then
						local frozenEndTs = TradeUtils.getTradeFreezeEndTs(packSlot)
						local isFrozen = curTimeTs < frozenEndTs

						items[#items + 1] = {
							itemId = itemId,
							invId = invId,
							genID = packSlot.genID,
							count = count,
							packSlot = packSlot,
							itemConfig = itemConfig,
							tradeConfig = TradeItemData[itemId],
							itemName = itemConfig.itemName and pg.getLocalizationText(itemConfig.itemName) or "",
							num = count,
							isFrozen = isFrozen,
							frozenEndTs = isFrozen and frozenEndTs or nil,
							canSell = not isFrozen
						}
					end
				end
			end
		end
	end

	table.sort(items, function(a, b)
		local priorityA = ITEM_TYPE_SORT_PRIORITY[a.itemConfig.type] or DEFAULT_ITEM_TYPE_SORT_PRIORITY
		local priorityB = ITEM_TYPE_SORT_PRIORITY[b.itemConfig.type] or DEFAULT_ITEM_TYPE_SORT_PRIORITY

		if priorityA ~= priorityB then
			return priorityA < priorityB
		end

		local rankA = a.tradeConfig.rank or math.huge
		local rankB = b.tradeConfig.rank or math.huge

		if rankA ~= rankB then
			return rankA < rankB
		end

		if a.itemId ~= b.itemId then
			return a.itemId < b.itemId
		end

		return (a.genID or 0) < (b.genID or 0)
	end)

	return items
end

function TradeMarketSellGoodsModel:checkCanSell(packSlot, itemId, curOADate)
	local data = TradeItemData[itemId]

	if not data or not ItemData[itemId] then
		return false
	end

	if data.displayType ~= TradeMarketUtils.SubPageType.Goods then
		return false
	end

	local startTime = tonumber(data.startTime)

	if startTime and startTime > 0 and curOADate < startTime then
		return false
	end

	if packSlot and packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED) then
		return false
	end

	if data.needCanTrade == 1 and not TradeUtils.isItemCanTrade(packSlot) then
		return false
	end

	return true
end

function TradeMarketSellGoodsModel:getSellingData(listings)
	local sellingData = {}

	for _, listing in ipairs(listings or EMPTY_TABLE) do
		if listing.displayType == TradeMarketUtils.SubPageType.Goods then
			sellingData[#sellingData + 1] = listing
		end
	end

	local sellingCount = #sellingData
	local sellMaxCount = TradeMarketUtils.getGoodsSellMaxCount()

	for _ = sellingCount + 1, sellMaxCount do
		sellingData[#sellingData + 1] = {
			isEmpty = true,
			tIndex = 1
		}
	end

	return sellingData, sellingCount
end

return TradeMarketSellGoodsModel
