-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogItemGet\\PetTransmogItemGetCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ItemData = require("Data.item_data")
local ItemConst = require("Common.Const.ItemConst")
local MAX_BUY_COUNT = 99
local PetTransmogItemGetCtrl = Class.LightClass("PetTransmogItemGetCtrl", UICtrl)

PetTransmogItemGetCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshUI",
		true
	}
}

function PetTransmogItemGetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local commodityId = info and info.commodityId or PetTransmogUtils.getBaseNumber("need_item_id_shopmall")

	self.model:setContext(commodityId, info and info.defaultBuyCount or 1)
end

function PetTransmogItemGetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info and info.commodityId then
		self.model:setContext(info.commodityId, info.defaultBuyCount or 1)
	elseif info and info.defaultBuyCount then
		self.model:setBuyCount(info.defaultBuyCount)
	end
end

function PetTransmogItemGetCtrl:onShow()
	self:refreshUI()
end

function PetTransmogItemGetCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnConfirm then
		function self.view.btnConfirm.luaClick()
			self:onBtnConfirm()
		end
	end

	if self.view.numSelector then
		function self.view.numSelector.luaValueChanged(value)
			local affordableCount = self:_getAffordableBuyCount()
			local count = math.floor(tonumber(value) or 1)

			count = math.min(math.max(1, count), MAX_BUY_COUNT)

			if value == MAX_BUY_COUNT then
				count = affordableCount
			end

			self.model:setBuyCount(count)

			if count ~= value then
				self.view.numSelector.value = count
			end

			self:refreshCost()
		end
	end
end

function PetTransmogItemGetCtrl:_getCommodityCfg()
	return ClientCashShopUtils.getCommodityData(self.model:getCommodityId())
end

function PetTransmogItemGetCtrl:_getCost(buyCount)
	local commodityId = self.model:getCommodityId()

	if not commodityId then
		return nil
	end

	return ClientCashShopUtils.getCommodityPrimaryCost(commodityId, buyCount or 1)
end

function PetTransmogItemGetCtrl:_getAffordableBuyCount()
	local cfg = self:_getCommodityCfg()
	local cost = self:_getCost()

	if not cfg then
		return 1
	end

	local maxCount = MAX_BUY_COUNT
	local currencyId = cost and cost[1]
	local unitPrice = cost and cost[2]

	if currencyId and unitPrice and unitPrice > 0 then
		local owned = pg.me and pg.me:getItemCountById(currencyId, true) or 0

		maxCount = math.min(maxCount, math.floor(owned / unitPrice))
	end

	return math.max(1, maxCount)
end

function PetTransmogItemGetCtrl:refreshUI()
	local cfg = self:_getCommodityCfg()

	if not cfg then
		return
	end

	local itemId = cfg.itemId
	local itemNum = cfg.num

	if self.view.item then
		LuaUIUtils.renderRewardItem(self.view.item, {
			num = itemNum,
			id = itemId
		})
	end

	local itemData = ItemData[itemId]

	if itemData and self.view.itemName then
		ClientTextUtils.setText(self.view.itemName, pg.getLocalizationText(itemData.itemName))
	end

	local cost = self:_getCost(1)

	if self.view.currencyList and cost and cost[1] then
		local list = {
			ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND
		}

		if cost[1] ~= ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND then
			table.insert(list, cost[1])
		end

		LuaUIUtils.setTopCurrencyItemList(self.view.currencyList, nil, list)
	end

	self:_setupSelector()
	self:refreshCost()
end

function PetTransmogItemGetCtrl:_setupSelector()
	if not self.view.numSelector then
		return
	end

	local cur = self.model:getBuyCount()

	if cur < 1 then
		cur = 1
	end

	if cur > MAX_BUY_COUNT then
		cur = MAX_BUY_COUNT
	end

	self.model:setBuyCount(cur)

	self.view.numSelector.minValue = 1
	self.view.numSelector.maxValue = MAX_BUY_COUNT
	self.view.numSelector.value = cur
end

function PetTransmogItemGetCtrl:refreshCost()
	local count = self.model:getBuyCount() or 1
	local cost, errorCode = self:_getCost(count)

	self._costCalcErr = errorCode

	local total = cost and cost[2] or 0

	if self.view.txtCost and cost and cost[1] then
		local owned = pg.me and pg.me:getItemCountById(cost[1], true) or 0

		LuaUIUtils.renderShopBuyConsumeText(self.view.txtCost, cost[1], owned, total, UIConst.ITEM_STATE.FULL)
	elseif self.view.txtCost then
		ClientTextUtils.setText(self.view.txtCost, "")
	end

	if self.view.txtPrize and cost and cost[1] then
		local itemDes = LuaUIUtils.getItemShowText(cost[1])
		local shopItemDes = pg.getFormatText("{0}{1} {2}", pg.getGameString("PETTRANSMOGRIFY_TOTAL_PRICE"), itemDes, total)

		ClientTextUtils.setText(self.view.txtPrize, shopItemDes)
	elseif self.view.txtPrize then
		ClientTextUtils.setText(self.view.txtPrize, "")
	end
end

function PetTransmogItemGetCtrl:onBtnConfirm()
	local commodityId = self.model:getCommodityId()
	local count = math.min(self.model:getBuyCount() or 1, MAX_BUY_COUNT)
	local cost, errorCode = self:_getCost(count)

	if errorCode then
		ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

		return
	end

	if not commodityId or not cost then
		return
	end

	ClientCashShopUtils.openBuyConfirm(commodityId, cost, count)
	self:dismiss()
end

return PetTransmogItemGetCtrl
