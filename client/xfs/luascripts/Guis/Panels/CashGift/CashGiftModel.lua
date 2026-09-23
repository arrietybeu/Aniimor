-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashGift\\CashGiftModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashGiftModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemData = require("Data.item_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local ShopmallGiftData = require("Data.shopmall_gift_data")
local CashGiftModel = Class.LightClass("CashGiftModel", UIModel)
local GIFT_BOX_ITEM_TYPE = 14

function CashGiftModel:setCommodityId(commodityId)
	self._commodityId = commodityId
	self._commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)
	self._itemInfo = ClientCashShopUtils.getItemDataByCommodityId(commodityId)
	self._displayItemId = nil
end

function CashGiftModel:getCommodityId()
	return self._commodityId
end

function CashGiftModel:getCommodityInfo()
	return self._commodityInfo
end

function CashGiftModel:getItemInfo()
	return self._itemInfo
end

function CashGiftModel:setReceiverGender(receiverGender)
	self._receiverGender = receiverGender
end

function CashGiftModel:getReceiverGender()
	return self._receiverGender
end

function CashGiftModel:getCost(buyCount)
	local info = self._commodityInfo

	if not info then
		return nil
	end

	return ClientCashShopUtils.getCommodityPrimaryCost(self._commodityId, buyCount or 1, {
		forGive = true
	})
end

function CashGiftModel:getMaxBuyCount()
	local info = self._commodityInfo

	if not info then
		return 1
	end

	local maxCount, errorCode = ClientCashShopUtils.getCommodityMaxBuyCount(self._commodityId, {
		forGive = true
	})

	if errorCode then
		return 0, errorCode
	end

	return math.max(1, maxCount)
end

function CashGiftModel:isSuit()
	local info = self._commodityInfo

	return info and ClientCashShopUtils.isSuitType(info.avatarType)
end

function CashGiftModel:isGiftBox()
	local itemInfo = self._itemInfo

	return itemInfo and itemInfo.type == GIFT_BOX_ITEM_TYPE
end

function CashGiftModel:setHasProductInfo(productInfo)
	self._hasProductInfo = productInfo ~= nil
	self._productInfo = productInfo
	self._productDisplayIcon = nil
	self._productDisplayName = nil
	self._productDisplayDesc = nil

	if self._hasProductInfo then
		local cfgInfo = productInfo and productInfo.cfgInfo

		self._productDisplayIcon = cfgInfo and cfgInfo.icon
		self._productDisplayName = cfgInfo and cfgInfo.name
		self._productDisplayDesc = cfgInfo and (cfgInfo.des or cfgInfo.productDes)

		local itemId = cfgInfo and (cfgInfo.sendGiftltemld or cfgInfo.overselling and cfgInfo.overselling[1])

		if itemId then
			self._displayItemId = itemId
			self._itemInfo = ItemData[itemId] or self._itemInfo
		end
	end
end

function CashGiftModel:hasProductInfo()
	return self._hasProductInfo
end

function CashGiftModel:getItemId()
	if self._displayItemId then
		return self._displayItemId
	end

	if self._commodityInfo then
		return self._commodityInfo.itemId
	end
end

function CashGiftModel:getProductDisplayIcon()
	return self._productDisplayIcon
end

function CashGiftModel:getProductDisplayName()
	return self._productDisplayName
end

function CashGiftModel:getProductDisplayDesc()
	return self._productDisplayDesc
end

function CashGiftModel:getKindPage()
	if self._hasProductInfo then
		return 1
	elseif self:isSuit() or self:isGiftBox() then
		return 0
	else
		return 2
	end
end

function CashGiftModel:getSuitOrGiftItemList()
	local info = self._commodityInfo

	if not info then
		return {}
	end

	if self:isSuit() then
		return ClientCashShopUtils.getSuitAppearanceItems(info.itemId, self._receiverGender) or {}
	elseif self:isGiftBox() then
		local giftData = ShopmallGiftData[info.itemId]

		if not giftData or not giftData.FixItems then
			return {}
		end

		local list = {}

		for _, item in ipairs(giftData.FixItems) do
			local itemId = ClientCashShopUtils.getGenderConvertedItemId(item[1], self._receiverGender) or item[1]

			list[#list + 1] = {
				id = itemId,
				num = item[2]
			}
		end

		return list
	end

	return {}
end

function CashGiftModel:getSendLimit()
	return ShopConstantData.send_limit and tonumber(ShopConstantData.send_limit.number) or 50
end

function CashGiftModel:getDefaultSendWord()
	return ShopConstantData.sendword and pg.getGameString(ShopConstantData.sendword.number) or ""
end

return CashGiftModel
