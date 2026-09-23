-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGiftBuy\\FriendGiftBuyModel.lua

local Class = require("Core.Framework.Class")
local NoticeDef = require("Common.NoticeDef")
local ItemShopData = require("Data.item_shop_data")
local ShopClassifyData = require("Data.shop_classify_data")
local ShopCommodityData = require("Data.shop_commodity_data")
local ShopBaseModel = require("Guis.Panels.Shop.ShopBaseModel")
local FriendGiftBuyModel = Class.LightClass("FriendGiftBuyModel", ShopBaseModel)
local SHOP_CLASSIFY_ID = 32

function FriendGiftBuyModel:getShopClassifyId()
	return SHOP_CLASSIFY_ID
end

function FriendGiftBuyModel:isFriendGiftCommodity(commodityConfig)
	local classifyConfig = ShopClassifyData[SHOP_CLASSIFY_ID]

	return commodityConfig and classifyConfig and table.contains(classifyConfig.classify, commodityConfig.tag)
end

function FriendGiftBuyModel:resolveCommodityId(itemId)
	if not itemId then
		return nil, NoticeDef.SHOP_CLIENT_PARAM_ERROR
	end

	local commodityIds = ItemShopData[itemId]

	if not commodityIds or not ShopClassifyData[SHOP_CLASSIFY_ID] then
		return nil, NoticeDef.SHOP_CONFIG_PARAM_ERROR
	end

	local matchedClassify = false

	for _, commodityId in ipairs(commodityIds) do
		local commodityConfig = ShopCommodityData[commodityId]
		local isCurrentItem = commodityConfig and commodityConfig.itemId == itemId
		local isCurrentShop = isCurrentItem and self:isFriendGiftCommodity(commodityConfig)

		if isCurrentShop then
			matchedClassify = true

			if commodityConfig.onSale == 1 then
				return commodityId
			end
		end
	end

	local errorCode = matchedClassify and NoticeDef.SHOP_COMMODITY_NOT_SALE or NoticeDef.SHOP_CONFIG_PARAM_ERROR

	return nil, errorCode
end

function FriendGiftBuyModel:validateCommodity(commodityId, buyCount)
	if type(buyCount) ~= "number" or buyCount < 1 or buyCount % 1 ~= 0 then
		return NoticeDef.SHOP_CLIENT_PARAM_ERROR
	end

	if buyCount > self:getBuyLimit() then
		return NoticeDef.SHOP_COMMODITY_LIMITNUM
	end

	local commodityConfig = self:getShopItemConfig(commodityId)

	if not commodityConfig or not ShopClassifyData[SHOP_CLASSIFY_ID] then
		return NoticeDef.SHOP_CONFIG_PARAM_ERROR
	end

	if not self:isFriendGiftCommodity(commodityConfig) then
		return NoticeDef.SHOP_CONFIG_PARAM_ERROR
	end

	if commodityConfig.onSale ~= 1 then
		return NoticeDef.SHOP_COMMODITY_NOT_SALE
	end

	if not self:isShopTagOpen(commodityConfig.tag) then
		return NoticeDef.SHOP_TAG_NOT_INTIME
	end

	if not self:isPropInLimitTime(commodityConfig) then
		return NoticeDef.SHOP_COMMODITY_NOT_INTIME
	end

	if not self:isPropUnlock(commodityId) then
		return NoticeDef.SHOP_COMMODITY_CONDITION
	end

	local isSellOut, leftCount = self:isPropSellOut(commodityId)

	if isSellOut or leftCount < buyCount then
		return NoticeDef.SHOP_COMMODITY_LIMITNUM
	end
end

function FriendGiftBuyModel:getPrimaryCost(commodityId, buyCount)
	local costList = self:getBuyPriceInfo(commodityId, buyCount)

	if not costList or #costList ~= 1 then
		return nil, NoticeDef.SHOP_CONFIG_PARAM_ERROR
	end

	return costList[1]
end

function FriendGiftBuyModel:getMaxBuyCount(commodityId)
	local leftCount = self:getLeftBuyPropCount(commodityId)

	return math.max(1, math.min(self:getBuyLimit(), leftCount))
end

return FriendGiftBuyModel
