-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemBag\\ItemSummary.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("Item")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemSummary = Class.LightClass("ItemSummary")
local pairs = pairs

function ItemSummary:ctor()
	self.items = {}
	self.stackcount = {}
	self.totalCount = 0
end

function ItemSummary:collectFromDict(dict, onItem)
	local summary = self.items
	local genItemCountBindInfo = ItemUtils.genItemCountBindInfo
	local modifyItemCountToRet = ItemUtils.modifyItemCountToRet
	local getItemCountFromCountPairWithBind = ItemUtils.getItemCountFromCountPairWithBind

	for _, item in dict:items() do
		if onItem then
			onItem(item)
		end

		local id = item.id

		if summary[id] == nil then
			summary[id] = genItemCountBindInfo()
			self.stackcount[id] = item:maxCount()
		end

		if getItemCountFromCountPairWithBind(summary[id]) == 0 then
			self.totalCount = self.totalCount + 1
		end

		modifyItemCountToRet(summary, id, item.count, item:isStatusLocked())
	end

	return summary
end

function ItemSummary:collectFrom(items)
	local summary = self.items
	local genItemCountBindInfo = ItemUtils.genItemCountBindInfo
	local modifyItemCountToRet = ItemUtils.modifyItemCountToRet
	local getItemCountFromCountPairWithBind = ItemUtils.getItemCountFromCountPairWithBind

	for _, item in pairs(items) do
		local id = item.id

		if summary[id] == nil then
			summary[id] = genItemCountBindInfo()
			self.stackcount[id] = item:maxCount()
		end

		if getItemCountFromCountPairWithBind(summary[id]) == 0 then
			self.totalCount = self.totalCount + 1
		end

		modifyItemCountToRet(summary, id, item.count, item:isStatusLocked())
	end

	return summary
end

function ItemSummary:getTotalPiles()
	local space = 0
	local getItemCountFromCountPairWithBind = ItemUtils.getItemCountFromCountPairWithBind

	for id, countPair in pairs(self.items) do
		local maxCount = self.stackcount[id]

		if maxCount <= 0 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("item in bag maxCount invalid, force use 1, itemId=%d, curCount=%s", id, inspect(countPair))
			end

			maxCount = 1
		end

		local itemCount = getItemCountFromCountPairWithBind(countPair, true)
		local pileCount = math.modf(itemCount / maxCount)

		space = space + pileCount

		if itemCount % maxCount > 0 then
			space = space + 1
		end
	end

	return space
end

function ItemSummary:getCountById()
	return self.totalCount
end

function ItemSummary:calcIdNumMap(idNumMap)
	for id, countPair in pairs(self.items) do
		for boundType, itemCount in pairs(countPair) do
			idNumMap[id] = (idNumMap[id] or 0) + itemCount
		end
	end
end

function ItemSummary:calcIdNumWithBindMap(idNumWithBindMap)
	for id, countPair in pairs(self.items) do
		idNumWithBindMap[id] = idNumWithBindMap[id] or {}

		for boundType, countInfo in pairs(countPair) do
			idNumWithBindMap[id][boundType] = idNumWithBindMap[id][boundType] or {}

			for lockedType, itemCount in pairs(countInfo) do
				idNumWithBindMap[id][boundType][lockedType] = (idNumWithBindMap[id][boundType][lockedType] or 0) + itemCount
			end
		end
	end
end

return ItemSummary
