-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InventoryItem\\PetJewelryItemBag.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ItemDefines = require("Common.ItemBag.ItemDefines")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetJewelryItemBag = class.LiteClass("PetJewelryItemBag", CustomDict)
local table_sort = table.sort

function PetJewelryItemBag:ctor()
	PetJewelryItemBag.super.ctor(self)
	rawset(self, "inCallback", false)
	rawset(self, "inOperation", false)
	rawset(self, "overflowItems", {})
	rawset(self, "handlingOverflowItems", false)
end

function PetJewelryItemBag:getCount()
	return self.count
end

function PetJewelryItemBag:getCapacity()
	return self.capacity
end

function PetJewelryItemBag:hasSpace(n)
	return self.count + n <= self.capacity
end

function PetJewelryItemBag:getSpace()
	local space = self.capacity - self.count

	if space < 0 then
		return 0
	end

	return space
end

function PetJewelryItemBag:isFull()
	return not self:hasSpace(1)
end

function PetJewelryItemBag:isInvalidItem(item)
	return item == nil or item.id == nil or item.getCount == nil or item:getCount() ~= 1 or false
end

local function __sort_by_id(a, b)
	if a.id == b.id then
		return a.genID < b.genID
	else
		return a.id < b.id
	end
end

local function __sort_by_genID(a, b)
	return a.genID < b.genID
end

local function sort_items(items, sort_function)
	if #items == 0 then
		return items
	end

	table_sort(items, sort_function)

	return items
end

function PetJewelryItemBag:get(genID)
	local item = self[genID]

	if item == nil then
		return nil
	end

	return item
end

function PetJewelryItemBag:getByFilter(filter)
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

function PetJewelryItemBag:getItemsById(id)
	local function filter_by_configId(item)
		return item.id == id
	end

	return self:getByFilter(filter_by_configId)
end

function PetJewelryItemBag:getItemsByIdWithBind(id, isBind)
	if not isBind then
		return {}
	end

	local function filter_by_configIdWithBind(item)
		return item.id == id and item:getIsBind()
	end

	return self:getByFilter(filter_by_configIdWithBind)
end

function PetJewelryItemBag:__toArraBy(sort_function)
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

function PetJewelryItemBag:toArrayById()
	return self:__toArraBy(__sort_by_genID)
end

function PetJewelryItemBag:toArrayByCfgId()
	return self:__toArraBy(__sort_by_id)
end

function PetJewelryItemBag:getAll()
	return self:__toArraBy(nil)
end

function PetJewelryItemBag:calcIdNumMap(idNumMap)
	for _, item in self:items() do
		idNumMap[item.id] = (idNumMap[item.id] or 0) + 1
	end
end

function PetJewelryItemBag:calcIdNumWithBindMap(idNumWithBindMap)
	for _, item in self:items() do
		ItemUtils.modifyItemCountToRet(idNumWithBindMap, item.id, 1, false)
	end
end

function PetJewelryItemBag:__calcSpace(items)
	local count = self.count

	for _, item in pairs(items or EMPTY_TABLE) do
		if not self:isInvalidItem(item) then
			count = count + 1
		end
	end

	return count
end

function PetJewelryItemBag:canHoldItems(items)
	if self.overflowMode == ItemDefines.BagOverFlowMode.Default then
		return self:__calcSpace(items) <= self.capacity
	elseif self.overflowMode == ItemDefines.BagOverFlowMode.AllowOverflowOnlyOnce then
		if self:getSpace() >= 1 then
			return true
		end

		return self:__calcSpace(items) <= self.capacity
	else
		return true
	end
end

return PetJewelryItemBag
