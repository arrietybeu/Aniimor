-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityGot\\VitalityGotModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityGotModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local VitalityGotModel = Class.LightClass("VitalityGotModel", UIModel)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CurrencyAutoChangeData = require("Data.currency_auto_change_data")
local ShopCommodityData = require("Data.shop_commodity_data")
local ShopMallCommodityData = require("Data.shopmall_commodity_data")
local ItemData = require("Data.item_data")

function VitalityGotModel:getPropDataList(itemId)
	local defaultIdx = 0
	local res = {}
	local itemCfg = ItemData[itemId]
	local itemName = itemCfg and pg.getLocalizationText(itemCfg.itemName) or ""
	local getCfg = CurrencyAutoChangeData[itemId]

	if getCfg and getCfg.useItemId then
		local item = LuaUIUtils.getItemInfoById(getCfg.useItemId)

		if item.ownNum > 0 then
			defaultIdx = 0
			item.itemEffect = getCfg.itemEffect
			res[#res + 1] = item
		end
	end

	local addedMoneyShop = false

	if getCfg and getCfg.moneyShopItemId then
		addedMoneyShop = self:appendMoneyShopItem(res, getCfg.moneyShopItemId, itemName)
	end

	if not addedMoneyShop and getCfg and getCfg.shopItemId then
		self:appendShopItem(res, getCfg.shopItemId, itemName)
	end

	return res, defaultIdx
end

function VitalityGotModel:appendMoneyShopItem(res, moneyShopItemId, itemName)
	local shopData = ShopMallCommodityData[moneyShopItemId]

	if not shopData or not ClientCashShopUtils.isCommodityOnShelf(shopData, moneyShopItemId) then
		return false
	end

	local cost = ClientCashShopUtils.getCommodityPrimaryCost(moneyShopItemId, 1)
	local item = cost and LuaUIUtils.getItemInfoById(cost[1]) or nil

	if not item then
		return false
	end

	item.limitCount = ClientCashShopUtils.getCommodityLeftLimit(moneyShopItemId)
	item.moneyShopItemId = moneyShopItemId
	item.costNum = cost[2]
	item.obtainNum = shopData.num
	item.limitType = shopData.limitType
	item.obtainName = itemName
	item.isMoneyShop = true
	res[#res + 1] = item

	return true
end

function VitalityGotModel:appendShopItem(res, shopId, itemName)
	local shopData = ShopCommodityData[shopId]

	if not shopData then
		return false
	end

	local cost = pg.global.ui.shop.model:getBuyPriceInfo(shopId, 1)
	local item = LuaUIUtils.getItemInfoById(cost[1][1])

	item.limitCount = pg.global.ui.shop.model:getLeftBuyPropCount(shopId)
	item.shopItemId = shopId
	item.costNum = cost[1][2]
	item.obtainNum = shopData.itemNum
	item.limitType = shopData.limitType
	item.obtainName = itemName
	item.isShop = true
	res[#res + 1] = item

	return true
end

return VitalityGotModel
