-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashCart\\CashCartModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashCartModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local CommodityData = require("Data.shopmall_commodity_data")
local ShopmallTabGroupData = require("Data.shopmall_tab_group_data")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CashCartModel = Class.LightClass("CashCartModel", UIModel)

function CashCartModel.getPlayerCartCommodityList()
	local result = {}
	local shopMallCart = pg.me and pg.me.shopMallCart

	if shopMallCart then
		for commodityId, cartItem in pairs(shopMallCart) do
			local finalCommodityId = tonumber(cartItem.shopCommodityId) or tonumber(commodityId)

			if finalCommodityId then
				result[#result + 1] = {
					commodityId = finalCommodityId,
					buyCount = math.max(1, tonumber(cartItem.num) or 1),
					time = tonumber(cartItem.time) or 0
				}
			end
		end
	end

	table.sort(result, function(a, b)
		if a.time == b.time then
			return a.commodityId < b.commodityId
		end

		return a.time > b.time
	end)

	return result
end

function CashCartModel:setCommodityList(commodityList)
	self._selectedByCommodityId = {}
	self._countByCommodityId = {}
	self._unavailableCommodityIds = {}

	local groupOrder = {}
	local groupItems = {}
	local unavailableItems = {}

	for _, cartItem in ipairs(commodityList or {}) do
		local commodityId = cartItem.commodityId
		local commodityInfo = CommodityData[commodityId]

		if commodityInfo then
			local data = {}

			for k, v in pairs(commodityInfo) do
				data[k] = v
			end

			data.tIndex = 0
			data.commodityId = commodityId
			data.buyCount = math.max(1, tonumber(cartItem.buyCount) or 1)
			data.selected = true

			if self:isCommodityPurchasable(data) then
				local groupId = commodityInfo.tabGroupId or 0

				if not groupItems[groupId] then
					groupItems[groupId] = {}
					groupOrder[#groupOrder + 1] = groupId
				end

				groupItems[groupId][#groupItems[groupId] + 1] = data
			else
				data.isUnavailable = true
				unavailableItems[#unavailableItems + 1] = data
				self._unavailableCommodityIds[#self._unavailableCommodityIds + 1] = commodityId
			end

			self._selectedByCommodityId[commodityId] = true
			self._countByCommodityId[commodityId] = data.buyCount
		else
			logger:warning("setCommodityList: commodityId=%s 配置不存在", tostring(commodityId))
		end
	end

	self._listData = {}

	for _, groupId in ipairs(groupOrder) do
		local groupData = ShopmallTabGroupData[groupId]

		self._listData[#self._listData + 1] = {
			tIndex = 1,
			groupId = groupId,
			tabName = groupData and groupData.tabName
		}

		for _, item in ipairs(groupItems[groupId]) do
			self._listData[#self._listData + 1] = item
		end
	end

	if #unavailableItems > 0 then
		self._listData[#self._listData + 1] = {
			tIndex = 1,
			gameStringKey = "SHOP_CART_LOCK",
			isUnavailableGroup = true
		}

		for _, item in ipairs(unavailableItems) do
			self._listData[#self._listData + 1] = item
		end
	end
end

function CashCartModel:getListData()
	return self._listData or {}
end

function CashCartModel:isCommodityPurchasable(data)
	if not data or not ClientCashShopUtils.isCommodityOnShelf(data, data.commodityId) then
		return false
	end

	return ClientCashShopUtils.getCommodityState(data) == ClientCashShopUtils.COMMODITY_STATE.NORMAL
end

function CashCartModel:setCommoditySelected(commodityId, selected)
	self._selectedByCommodityId[commodityId] = selected == true
end

function CashCartModel:setAllSelected(selected)
	local target = selected == true

	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 then
			data.selected = target
			self._selectedByCommodityId[data.commodityId] = target
		end
	end
end

function CashCartModel:isAllSelected()
	local hasCommodity = false

	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 then
			hasCommodity = true

			if not self._selectedByCommodityId[data.commodityId] then
				return false
			end
		end
	end

	return hasCommodity
end

function CashCartModel:getSelectedCommodityIds(purchasableOnly)
	local result = {}

	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 and self._selectedByCommodityId[data.commodityId] and (not purchasableOnly or self:isCommodityPurchasable(data)) then
			result[#result + 1] = data.commodityId
		end
	end

	return result
end

function CashCartModel:getUnavailableCommodityIds()
	local result = {}

	for _, commodityId in ipairs(self._unavailableCommodityIds or {}) do
		result[#result + 1] = commodityId
	end

	return result
end

function CashCartModel:cancelCommodityCountEditing()
	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 then
			data.isEditingCount = false
			data.pendingBuyCount = nil
		end
	end
end

function CashCartModel:setCommodityCount(commodityId, count)
	local finalCount = math.max(1, tonumber(count) or 1)

	self._countByCommodityId[commodityId] = finalCount

	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 and data.commodityId == commodityId then
			data.buyCount = finalCount

			break
		end
	end
end

function CashCartModel:getSelectedCostList()
	local costByItemId = {}
	local itemIdOrder = {}

	for _, data in ipairs(self._listData or {}) do
		if data.tIndex == 0 and self._selectedByCommodityId[data.commodityId] and self:isCommodityPurchasable(data) then
			local costs = ClientCashShopUtils.getCommodityCostList(data.commodityId, self._countByCommodityId[data.commodityId] or data.buyCount or 1)

			for _, cost in ipairs(costs or {}) do
				if not costByItemId[cost.itemId] then
					costByItemId[cost.itemId] = 0
					itemIdOrder[#itemIdOrder + 1] = cost.itemId
				end

				costByItemId[cost.itemId] = costByItemId[cost.itemId] + (cost.totalPrice or 0)
			end
		end
	end

	local result = {}

	for _, itemId in ipairs(itemIdOrder) do
		result[#result + 1] = {
			itemId = itemId,
			itemCount = costByItemId[itemId]
		}
	end

	return result
end

return CashCartModel
