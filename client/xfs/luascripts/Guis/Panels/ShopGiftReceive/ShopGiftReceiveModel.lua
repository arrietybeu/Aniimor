-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopGiftReceive\\ShopGiftReceiveModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShopGiftReceiveModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopGiftReceiveModel = Class.LightClass("ShopGiftReceiveModel", UIModel)
local ItemData = require("Data.item_data")
local ItemTypeShowData = require("Data.item_type_show_data")
local ShopMallCommodityData = require("Data.shopmall_commodity_data")
local ShopMallRechargeData = require("Data.shopmall_recharge_data")
local ItemEffectData = require("Data.item_effect_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")

ShopGiftReceiveModel.GIFT_KIND_OUTFIT = 0
ShopGiftReceiveModel.GIFT_KIND_MONTHLY = 1
ShopGiftReceiveModel.GIFT_KIND_BP = 2
ShopGiftReceiveModel.GIFT_KIND_OTHER = 3

local OUTFIT_DISPLAY_TYPES = {
	[3000] = true,
	[8000] = true
}
local BP_S_TYPES = {
	[ItemConst.USEITEM_TYPE_OPEN_BPGEAR_PAY1] = true,
	[ItemConst.USEITEM_TYPE_OPEN_BPGEAR_PAY2] = true
}
local MONTHLY_S_TYPES = {
	[ItemConst.USEITEM_TYPE_OPEN_MONTHCARD] = true
}

function ShopGiftReceiveModel:getRechargeGiftItemId(rechargeId)
	if not rechargeId then
		return nil
	end

	local rechargeData = ShopMallRechargeData[tostring(rechargeId)] or ShopMallRechargeData[rechargeId]

	if rechargeData then
		return rechargeData.sendGiftltemld
	end

	return nil
end

function ShopGiftReceiveModel:getRechargeItemSType(rechargeId)
	local itemId = self:getRechargeGiftItemId(rechargeId)

	if not itemId then
		return nil
	end

	local effectData = ItemEffectData[itemId]

	return effectData and effectData.sType or nil
end

function ShopGiftReceiveModel:isBP(rechargeId)
	local sType = self:getRechargeItemSType(rechargeId)

	return sType and BP_S_TYPES[sType] or false
end

function ShopGiftReceiveModel:isMonthly(rechargeId)
	local sType = self:getRechargeItemSType(rechargeId)

	return sType and MONTHLY_S_TYPES[sType] or false
end

function ShopGiftReceiveModel:getGiftKind(itemId, rechargeId)
	if rechargeId then
		if self:isBP(rechargeId) then
			return ShopGiftReceiveModel.GIFT_KIND_BP
		end

		if self:isMonthly(rechargeId) then
			return ShopGiftReceiveModel.GIFT_KIND_MONTHLY
		end
	end

	local itemConfig = itemId and ItemData[itemId] or nil

	if not itemConfig then
		return ShopGiftReceiveModel.GIFT_KIND_OTHER
	end

	local displayType = itemConfig.displayType

	if displayType and OUTFIT_DISPLAY_TYPES[displayType] then
		return ShopGiftReceiveModel.GIFT_KIND_OUTFIT
	else
		return ShopGiftReceiveModel.GIFT_KIND_OTHER
	end
end

function ShopGiftReceiveModel:getGiftQuality(itemId)
	local itemConfig = itemId and ItemData[itemId] or nil

	if not itemConfig then
		return 1
	end

	return math.max(1, math.min(6, itemConfig.quality or 1))
end

function ShopGiftReceiveModel:getItemName(itemId)
	local itemConfig = itemId and ItemData[itemId] or nil

	if not itemConfig then
		return ""
	end

	return pg.getLocalizationText(itemConfig.itemName)
end

function ShopGiftReceiveModel:getItemIcon(itemId)
	local itemConfig = itemId and ItemData[itemId] or nil

	if not itemConfig then
		return ""
	end

	return itemConfig.icon
end

function ShopGiftReceiveModel:getItemSubTitle(itemId)
	local itemConfig = itemId and ItemData[itemId] or nil

	if not itemConfig or not itemConfig.displayType then
		return ""
	end

	local showData = ItemTypeShowData[itemConfig.displayType]

	if showData then
		return pg.getLocalizationText(showData.type)
	end

	return ""
end

function ShopGiftReceiveModel:getAvatarPic(commodityId)
	if not commodityId then
		return ""
	end

	local commodity = ShopMallCommodityData[commodityId]

	if commodity and commodity.avatarPic then
		return commodity.avatarPic
	end

	return ""
end

function ShopGiftReceiveModel:getConvertedItemId(itemId)
	if not itemId then
		return itemId
	end

	local kind = self:getGiftKind(itemId)

	if kind ~= ShopGiftReceiveModel.GIFT_KIND_OUTFIT then
		return itemId
	end

	local replacedTable = ItemUtils.getReplacedItemCountTable(pg.me, {
		[itemId] = 1
	})

	if replacedTable then
		return next(replacedTable) or itemId
	end

	return itemId
end

function ShopGiftReceiveModel:getSuitAppearanceItems(itemId)
	if not itemId then
		return nil
	end

	local kind = self:getGiftKind(itemId)

	if kind ~= ShopGiftReceiveModel.GIFT_KIND_OUTFIT then
		return nil
	end

	return ClientCashShopUtils.getSuitAppearanceItems(itemId)
end

return ShopGiftReceiveModel
