-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\HomelandFurnitureItemBag.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemDefines = require("Common.ItemBag.ItemDefines")
local ItemSummary = require("Common.ItemBag.ItemSummary")
local ItemPileSimulator = require("Common.ItemBag.ItemPileSimulator")
local HomelandFurnitureItemBag = class.LiteClass("HomelandFurnitureItemBag", CustomDict)
local table_sort = table.sort

function HomelandFurnitureItemBag:ctor()
	HomelandFurnitureItemBag.super.ctor(self)
	rawset(self, "inCallback", false)
	rawset(self, "inOperation", false)
	rawset(self, "overflowItems", {})
	rawset(self, "handlingOverflowItems", false)
end

function HomelandFurnitureItemBag:getCount()
	return self.count
end

function HomelandFurnitureItemBag:getCapacity()
	return self.capacity
end

function HomelandFurnitureItemBag:hasSpace(n)
	return self.count + n <= self.capacity
end

function HomelandFurnitureItemBag:getSpace()
	local space = self.capacity - self.count

	if space < 0 then
		return 0
	end

	return space
end

function HomelandFurnitureItemBag:isFull()
	return not self:hasSpace(1)
end

function HomelandFurnitureItemBag:isInvalidItem(item)
	return item == nil or item.id == nil or item.count < 0 or false
end

local function __sort_by_id(a, b)
	if a.id == b.id then
		if a.count == b.count then
			return a.genID < b.genID
		else
			return a.count > b.count
		end
	else
		return a.id < b.id
	end
end

local function __sort_by_genID(a, b)
	if a.genID == b.genID then
		return a.count > b.count
	else
		return a.genID < b.genID
	end
end

local function sort_items(items, sort_function)
	if #items == 0 then
		return items
	end

	table_sort(items, sort_function)

	return items
end

function HomelandFurnitureItemBag:get(genID)
	local item = self[genID]

	if item == nil then
		return nil
	end

	return item
end

function HomelandFurnitureItemBag:getByFilter(filter)
	local items = {}

	if filter == nil then
		return items
	end

	for _, item in self:items() do
		local satisfied = filter(item) or false

		if satisfied or false then
			items[#items + 1] = item
		end
	end

	return sort_items(items, __sort_by_id)
end

function HomelandFurnitureItemBag:getItemsById(id)
	local function filter_by_configId(item)
		return item.id == id
	end

	return self:getByFilter(filter_by_configId)
end

function HomelandFurnitureItemBag:getItemsByIdWithBind(id, isBind)
	if not isBind then
		return {}
	end

	return self:getItemsById(id)
end

function HomelandFurnitureItemBag:__toArraBy(sort_function)
	local items = {}

	for _, item in self:items() do
		items[#items + 1] = item
	end

	if sort_function then
		return sort_items(items, sort_function)
	else
		return items
	end
end

function HomelandFurnitureItemBag:toArrayById()
	return self:__toArraBy(__sort_by_genID)
end

function HomelandFurnitureItemBag:toArrayByCfgId()
	return self:__toArraBy(__sort_by_id)
end

function HomelandFurnitureItemBag:getAll()
	return self:__toArraBy(nil)
end

function HomelandFurnitureItemBag:calcIdNumMap(idNumMap)
	local summary = ItemSummary()

	summary:collectFromDict(self)
	summary:calcIdNumMap(idNumMap)
end

function HomelandFurnitureItemBag:calcIdNumWithBindMap(idNumWithBindMap, onItem)
	local summary = ItemSummary()

	summary:collectFromDict(self, onItem)
	summary:calcIdNumWithBindMap(idNumWithBindMap)
end

function HomelandFurnitureItemBag:__calcSpace(items, allowMultiPile)
	return ItemPileSimulator.calcSpace(self, items, allowMultiPile)
end

function HomelandFurnitureItemBag:canHoldItems(items)
	local allowMultiPile = self.allowMultiPile

	if self.overflowMode == ItemDefines.BagOverFlowMode.Default then
		return self:__calcSpace(items, allowMultiPile) <= self.capacity
	elseif self.overflowMode == ItemDefines.BagOverFlowMode.AllowOverflowOnlyOnce then
		if self:getSpace() >= 1 then
			return true
		end

		return self:__calcSpace(items, allowMultiPile) <= self.capacity
	else
		return true
	end
end

return HomelandFurnitureItemBag
