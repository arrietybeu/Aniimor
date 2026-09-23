-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GiftPackReward\\GiftPackRewardModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("GiftPackRewardModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ShopMallCommodityData = require("Data.shopmall_commodity_data")
local ShopMallGiftData = require("Data.shopmall_gift_data")
local GiftPackRewardModel = Class.LightClass("GiftPackRewardModel", UIModel)

function GiftPackRewardModel:costItemEnough(commodityId)
	local commodityData = ShopMallCommodityData[commodityId]
	local giftData = ShopMallGiftData[commodityData.itemId]

	if giftData.giftPackType == 3 then
		return true
	end

	return ClientCashShopUtils.canAffordCommodity(commodityId, 1)
end

return GiftPackRewardModel
