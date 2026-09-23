-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureHistory\\FishingCaptureHistoryModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local FishingCaptureHistoryModel = Class.LightClass("FishingCaptureHistoryModel", UIModel)
local PAGE_SIZE = 3

function FishingCaptureHistoryModel:ctor()
	UIModel.ctor(self)

	self._list = {}
	self._entries = {}
	self._curPage = 1
	self._totalPage = 1
end

local ITEM_ID_2_PRI = {
	nil,
	1,
	[110011] = 9,
	[1017] = 10
}

function FishingCaptureHistoryModel._buildEntry(record)
	local rewardItemIds = {}

	if record.rewards then
		for itemId, _ in pairs(record.rewards) do
			if itemId and itemId > 0 then
				rewardItemIds[#rewardItemIds + 1] = itemId
			end
		end

		table.sort(rewardItemIds, function(a, b)
			local pa = ITEM_ID_2_PRI[a] or 0
			local pb = ITEM_ID_2_PRI[b] or 0

			return pa == pb and a < b or pb < pa
		end)
	end

	return {
		record = record,
		petTemplateId = record.petTemplateId and record.petTemplateId > 0 and record.petTemplateId or nil,
		sortedItemIds = rewardItemIds
	}
end

function FishingCaptureHistoryModel:setHistoryList(rawHistory)
	self._list = {}
	self._entries = {}

	if rawHistory then
		for i = 1, #rawHistory do
			self._list[#self._list + 1] = rawHistory[i]
		end

		table.sort(self._list, function(a, b)
			return a.settleTime > b.settleTime
		end)

		for _, record in ipairs(self._list) do
			self._entries[#self._entries + 1] = FishingCaptureHistoryModel._buildEntry(record)
		end
	end

	self._totalPage = math.max(1, math.ceil(#self._entries / PAGE_SIZE))
	self._curPage = 1
end

function FishingCaptureHistoryModel:getCurrentPageData()
	local start = (self._curPage - 1) * PAGE_SIZE + 1
	local result = {}

	for i = start, math.min(start + PAGE_SIZE - 1, #self._entries) do
		result[#result + 1] = self._entries[i]
	end

	return result
end

function FishingCaptureHistoryModel:tryPrevPage()
	if self._curPage > 1 then
		self._curPage = self._curPage - 1

		return true
	end

	return false
end

function FishingCaptureHistoryModel:tryNextPage()
	if self._curPage < self._totalPage then
		self._curPage = self._curPage + 1

		return true
	end

	return false
end

function FishingCaptureHistoryModel:getPageInfo()
	return self._curPage, self._totalPage
end

function FishingCaptureHistoryModel:isEmpty()
	return #self._entries == 0
end

return FishingCaptureHistoryModel
