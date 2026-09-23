-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandInventory\\HomelandInventoryModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InventoryModel = require("Guis.Panels.Inventory.InventoryModel")
local HomelandInventoryModel = Class.LightClass("HomelandInventoryModel", UIModel)
local HomeEventTextData = require("Data.home_event_text_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("HomelandInventoryModel")

function HomelandInventoryModel:ctor()
	self.SORT_DESC = {
		[InventoryModel.SORT_IDX_DEFAULT] = "DEFAULT_SORT",
		[InventoryModel.SORT_IDX_QUALITY] = "QUALITY",
		[InventoryModel.SORT_IDX_TYPE] = "TYPE"
	}
	self.sortIsAscending = true
	self.curInvType = -1
	self.LISTBAG_TAG = "ListBag"
	self.LISTINVENTORY_TAG = "ListInventory"
	self.HOME_SPLIT = "_"
end

function HomelandInventoryModel:setSortIdxType(idxType)
	self.sortIdxType = idxType
end

function HomelandInventoryModel:setSortAscendingOrder(isAscending)
	self.sortIsAscending = isAscending
end

function HomelandInventoryModel:getSortIdxType()
	if not self.sortIdxType then
		self.sortIdxType = InventoryModel.SORT_IDX_DEFAULT
	end

	return self.sortIdxType
end

function HomelandInventoryModel:getSortOptions()
	local ret = {}

	for idx, sortDesc in pairs(self.SORT_DESC) do
		ret[idx + 1] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return ret
end

function HomelandInventoryModel:getInventoryData()
	local res = {}
	local itemMap = pg.space.itemMap or {}

	for itemId, num in pairs(itemMap) do
		local itemData = ItemData[itemId]

		if itemData then
			table.insert(res, {
				index = 0,
				enableChecked = false,
				id = itemId,
				icon = itemData.icon,
				quality = itemData.quality,
				num = num,
				type = itemData.type
			})
		else
			logger:error("getInventoryData item not exist:", itemId)
		end
	end

	return res
end

function HomelandInventoryModel:getInventoryList(idxType, isDesc)
	local res = self:getInventoryData()

	if idxType == InventoryModel.SORT_IDX_DEFAULT or idxType == InventoryModel.SORT_IDX_QUALITY then
		if isDesc then
			res = self:sortRateDESC(res)
		else
			res = self:sortRateASC(res)
		end
	elseif isDesc then
		res = self:sortTypeDESC(res)
	else
		res = self:sortTypeASC(res)
	end

	local index = 0

	for _, item in pairs(res) do
		item.index = index
		index = index + 1
	end

	return res
end

function HomelandInventoryModel:getBagData()
	local res = {}
	local index = 0

	ItemUtils.eachSupportedTypedBag(pg.me, function(_, itemBag)
		for _, packSlot in itemBag:items() do
			local itemId = packSlot.id
			local itemData = ItemData[itemId]

			if itemData and itemData.isHomeItem == 1 then
				table.insert(res, {
					enableChecked = false,
					id = itemId,
					icon = itemData.icon,
					quality = itemData.quality,
					num = packSlot.count,
					type = itemData.type,
					index = index
				})

				index = index + 1
			end
		end
	end)

	return res
end

function HomelandInventoryModel:getBagList(idxType, isDesc)
	local res = self:getBagData()

	if idxType == InventoryModel.SORT_IDX_DEFAULT or idxType == InventoryModel.SORT_IDX_QUALITY then
		if isDesc then
			res = self:sortRateDESC(res)
		else
			res = self:sortRateASC(res)
		end
	elseif isDesc then
		res = self:sortTypeDESC(res)
	else
		res = self:sortTypeASC(res)
	end

	local index = 0

	for _, item in pairs(res) do
		item.index = index
		index = index + 1
	end

	return res
end

function HomelandInventoryModel:sortRateDESC(res)
	table.sort(res, function(a, b)
		if a.rate ~= b.rate then
			return a.rate > b.rate
		elseif a.quality ~= b.quality then
			return a.quality > b.quality
		elseif a.type ~= b.type then
			return a.type > b.type
		elseif a.num ~= b.num then
			return a.num > b.num
		else
			return a.id > b.id
		end
	end)

	return res
end

function HomelandInventoryModel:sortRateASC(res)
	table.sort(res, function(a, b)
		if a.rate ~= b.rate then
			return a.rate < b.rate
		elseif a.quality ~= b.quality then
			return a.quality < b.quality
		elseif a.type ~= b.type then
			return a.type > b.type
		elseif a.num ~= b.num then
			return a.num < b.num
		else
			return a.id < b.id
		end
	end)

	return res
end

function HomelandInventoryModel:sortTypeDESC(res)
	table.sort(res, function(a, b)
		if a.type ~= b.type then
			return a.type > b.type
		elseif a.rate ~= b.rate then
			return a.rate > b.rate
		elseif a.quality ~= b.quality then
			return a.quality > b.quality
		elseif a.num ~= b.num then
			return a.num > b.num
		else
			return a.id > b.id
		end
	end)

	return res
end

function HomelandInventoryModel:sortTypeASC(res)
	table.sort(res, function(a, b)
		if a.type ~= b.type then
			return a.type < b.type
		elseif a.rate ~= b.rate then
			return a.rate < b.rate
		elseif a.quality ~= b.quality then
			return a.quality < b.quality
		elseif a.num ~= b.num then
			return a.num < b.num
		else
			return a.id < b.id
		end
	end)

	return res
end

return HomelandInventoryModel
