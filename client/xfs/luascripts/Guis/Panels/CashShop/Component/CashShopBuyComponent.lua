-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\CashShopBuyComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local SysConfigData = require("Data.sys_config_data")
local UIConst = require("Const.UIConst")
local COMMODITY_STATE = ClientCashShopUtils.COMMODITY_STATE
local CashShopBuyComponent = Class.LightClass("CashShopBuyComponent", UIComponent)

function CashShopBuyComponent:onCtor(info)
	self.itemInfoContainer = info and info.itemInfoContainer or nil
end

function CashShopBuyComponent:onDestroy()
	self._curCommodityId = nil
	self.purchaseModuleWidget = nil
end

function CashShopBuyComponent:onShowBuyShopItemDetail(data)
	local commodityId = data.commodityId

	self._curCommodityId = commodityId

	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo then
		return
	end

	local itemId = commodityInfo.itemId

	if pg.me then
		local t = ItemUtils.getReplacedItemCountTable(pg.me, {
			[itemId] = 1
		})

		itemId = next(t) or itemId
	end

	local ownNum = ClientUtils.getItemCountById(itemId) or 0

	self._buyCount = 1
	self._maxCount = self:_getNumSelectorMaxCount(commodityInfo)
	self.purchaseModuleWidget = nil

	local selectedCommodityId = commodityId

	LuaUIUtils.renderShopItemInfo(self.itemInfoContainer, {
		skipFoldHotkey = true,
		fromParamCount = true,
		itemId = itemId,
		itemCount = ownNum,
		uiStyle = UIConst.ITEM_INFO_STATE.SHOP
	}, function()
		if self._curCommodityId ~= selectedCommodityId then
			return nil
		end

		return self:_getPurchaseModuleData()
	end)
end

function CashShopBuyComponent:_getNumSelectorMaxCount(commodityInfo)
	local limitNum = commodityInfo.limitNum or 0
	local leftLimit = ClientCashShopUtils.getCommodityLeftLimit(self._curCommodityId)
	local singleBuyLimit = SysConfigData.SHOP_BUY_LIMIT or ClientCashShopUtils.DEFAULT_MAX_BUY_COUNT

	if limitNum <= 0 then
		return math.min(ClientCashShopUtils.DEFAULT_MAX_BUY_COUNT, singleBuyLimit)
	end

	if limitNum > 1 and leftLimit > 1 then
		return math.max(1, math.min(limitNum, leftLimit, singleBuyLimit))
	end

	return 1
end

function CashShopBuyComponent:_getPurchaseModuleData()
	local commodityId = self._curCommodityId
	local commodityInfo = ClientCashShopUtils.getCommodityData(commodityId)

	if not commodityInfo then
		return nil
	end

	local buyState = self:_getBuyState()

	self._curBuyState = buyState

	local consumeList, errorCode = ClientCashShopUtils.getCommodityConsumeList(commodityId, self._buyCount)

	self._curCost = consumeList and consumeList[1] or nil
	self._costCalcErr = errorCode

	local coinCost = {}
	local itemCost = {}

	for _, costData in ipairs(consumeList or EMPTY_TABLE) do
		if ItemUtils.isCommonMoney(costData[1]) then
			coinCost[#coinCost + 1] = costData
		else
			itemCost[#itemCost + 1] = {
				id = costData[1],
				num = costData[2]
			}
		end
	end

	local hasLimit = commodityInfo.avatarType == nil and commodityInfo.limitNum and commodityInfo.limitNum > 0
	local limitLeft = hasLimit and ClientCashShopUtils.getCommodityLeftLimit(commodityId) or 0

	return {
		validate = function()
			return self.ctrl ~= nil and self._curCommodityId == commodityId
		end,
		commodityId = commodityId,
		commodityState = buyState,
		buyCount = self._buyCount,
		maxCount = self._maxCount,
		coinCost = coinCost,
		itemCost = itemCost,
		hasLimit = hasLimit,
		limitTitle = hasLimit and LuaUIUtils.getLimitTitleString(commodityInfo.limitType) or nil,
		limitLeft = limitLeft,
		limitTotal = commodityInfo.limitNum,
		getCostItemOwnCount = function(itemId)
			return ClientUtils.getItemCountById(itemId) or 0
		end,
		onCountChanged = function(value)
			if self._curCommodityId ~= commodityId then
				return
			end

			self._buyCount = value

			self:_refreshBuyStatePanel()
		end,
		onConfirm = function()
			if self._curCommodityId ~= commodityId then
				return
			end

			self:_onConfirmToBuy()
		end,
		onRendered = function(content, buyCount)
			if self._curCommodityId ~= commodityId then
				return
			end

			self.purchaseModuleWidget = content
			self._buyCount = buyCount
		end
	}
end

function CashShopBuyComponent:_getBuyState()
	local commodityState = ClientCashShopUtils.getCommodityState({
		commodityId = self._curCommodityId
	})

	if commodityState ~= COMMODITY_STATE.NORMAL then
		return commodityState
	end

	local consumeList, errorCode = ClientCashShopUtils.getCommodityConsumeList(self._curCommodityId, self._buyCount)

	self._curCost = consumeList and consumeList[1] or nil
	self._costCalcErr = errorCode

	if errorCode then
		return COMMODITY_STATE.NOTENOUGH
	end

	if not consumeList or #consumeList == 0 then
		return COMMODITY_STATE.FREE
	end

	local canAfford, _, _, affordErrorCode = ClientCashShopUtils.canAffordCommodity(self._curCommodityId, self._buyCount)

	self._costCalcErr = affordErrorCode

	if affordErrorCode then
		return COMMODITY_STATE.NOTENOUGH
	end

	if not canAfford then
		return COMMODITY_STATE.NOTENOUGH
	end

	return COMMODITY_STATE.NORMAL
end

function CashShopBuyComponent:_refreshBuyStatePanel()
	if not IsNil(self.purchaseModuleWidget) then
		ClientCashShopUtils.renderItemInfoPurchase(self.purchaseModuleWidget, self:_getPurchaseModuleData())
	end
end

function CashShopBuyComponent:_onConfirmToBuy()
	local buyState = self._curBuyState

	if buyState == COMMODITY_STATE.LOCKED then
		local commodityInfo = ClientCashShopUtils.getCommodityData(self._curCommodityId)
		local lockText = commodityInfo and LuaUIUtils.getCommodityUnlockDesc(commodityInfo) or ""

		pg.global.ui.tips:showTextTip(lockText ~= "" and lockText or pg.getGameString("SHOP_SELLOUT"))

		return
	end

	if buyState == COMMODITY_STATE.SOLDOUT then
		pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_SELLOUT"))

		return
	end

	if buyState ~= COMMODITY_STATE.NORMAL and buyState ~= COMMODITY_STATE.FREE and buyState ~= COMMODITY_STATE.NOTENOUGH then
		return
	end

	if self._costCalcErr then
		ClientCashShopUtils.showCommodityPriceCalcError(self._costCalcErr)

		return
	end

	ClientCashShopUtils.openBuyConfirm(self._curCommodityId, self._curCost, self._buyCount)
end

return CashShopBuyComponent
