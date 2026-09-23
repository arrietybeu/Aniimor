-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryHistory\\LotteryHistoryModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local LotteryHistoryModel = Class.LightClass("LotteryHistoryModel", UIModel)

LotteryHistoryModel.DEFAULT_PAGE_SIZE = 5

function LotteryHistoryModel:ctor()
	UIModel.ctor(self)

	self._historyList = {}
	self._pageIndex = 1
	self._pageSize = LotteryHistoryModel.DEFAULT_PAGE_SIZE
end

function LotteryHistoryModel:setPageSize(pageSize)
	pageSize = tonumber(pageSize)

	if pageSize and pageSize >= 1 then
		self._pageSize = math.floor(pageSize)

		return
	end

	self._pageSize = LotteryHistoryModel.DEFAULT_PAGE_SIZE
end

function LotteryHistoryModel:refreshHistory(drawId)
	self._historyList = self:buildHistoryList(drawId)
	self._pageIndex = 1
end

function LotteryHistoryModel:getTotalPages()
	local pageSize = self._pageSize or LotteryHistoryModel.DEFAULT_PAGE_SIZE

	return math.max(1, math.ceil(#(self._historyList or {}) / pageSize))
end

function LotteryHistoryModel:setPageIndex(pageIndex)
	pageIndex = math.floor(tonumber(pageIndex) or 1)
	self._pageIndex = math.max(1, math.min(pageIndex, self:getTotalPages()))
end

function LotteryHistoryModel:getPageIndex()
	return self._pageIndex or 1
end

function LotteryHistoryModel:getCurrentPageList()
	local result = {}
	local historyList = self._historyList or {}
	local pageSize = self._pageSize or LotteryHistoryModel.DEFAULT_PAGE_SIZE
	local startIndex = (self:getPageIndex() - 1) * pageSize + 1
	local endIndex = math.min(startIndex + pageSize - 1, #historyList)

	for index = startIndex, endIndex do
		result[#result + 1] = historyList[index]
	end

	return result
end

function LotteryHistoryModel:getDrawRecords(drawId)
	local gachaMap = pg.me and pg.me.gachaMap or nil

	if not Utils.isTable(gachaMap) then
		return nil
	end

	local gachaBase = gachaMap[tonumber(drawId)]

	if not Utils.isTable(gachaBase) then
		return nil
	end

	return gachaBase.drawRecords
end

function LotteryHistoryModel:getQualityText(quality)
	quality = tonumber(quality)

	if not quality then
		return ""
	end

	return pg.getGameString("LOTTERY_REWARD_RARITY_" .. tostring(quality))
end

function LotteryHistoryModel:getDrawTimeText(timestamp)
	timestamp = tonumber(timestamp)

	if not timestamp or timestamp <= 0 then
		return ""
	end

	return LuaUIUtils.timeStampToSystemLocalString(timestamp)
end

function LotteryHistoryModel:buildHistoryList(drawId)
	local result = {}
	local drawRecords = self:getDrawRecords(drawId)

	if not drawRecords then
		return result
	end

	for recordIndex = #drawRecords, 1, -1 do
		local drawRecord = drawRecords[recordIndex]
		local itemRecords = drawRecord and drawRecord.itemRecords or nil

		if itemRecords then
			local drawTimeText = self:getDrawTimeText(drawRecord.drawTime)

			for _, itemRecord in ipairs(itemRecords) do
				local itemId = tonumber(itemRecord.itemId)
				local itemConfig = itemId and ItemData[itemId] or nil

				result[#result + 1] = {
					itemId = itemId,
					itemNum = tonumber(itemRecord.itemNum) or 1,
					name = itemConfig and pg.getLocalizationText(itemConfig.itemName) or "",
					quality = self:getQualityText(itemConfig and itemConfig.quality or nil),
					time = drawTimeText,
					drawRecord = drawRecord,
					itemRecord = itemRecord
				}
			end
		end
	end

	return result
end

return LotteryHistoryModel
