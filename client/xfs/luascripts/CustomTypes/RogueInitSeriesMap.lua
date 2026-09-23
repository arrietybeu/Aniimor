-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RogueInitSeriesMap.lua

local Class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local Utils = require("Common.Utils.Utils")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local RandomBuffSeriesData = require("Data.random_buff_series_name")
local RogueInitSeriesData = require("Data.rogue_init_series_data")
local table_insert = table.insert
local RogueInitSeriesMap = Class.LiteClass("RogueInitSeriesMap", CustomDict)

function RogueInitSeriesMap:hadInited()
	return self.hadInit
end

function RogueInitSeriesMap:setInited(flag)
	self.hadInit = flag
end

function RogueInitSeriesMap:isSeriesSelected()
	return self.curSeries ~= -1
end

function RogueInitSeriesMap:setSeriesSelected(seriesId)
	local initSeriesInfo = self[seriesId]

	if initSeriesInfo == nil then
		return false
	end

	self.curSeries = seriesId
	self.curRealSeries = initSeriesInfo.realSeries

	return true
end

function RogueInitSeriesMap:getCurRealSeries()
	return self.curRealSeries
end

function RogueInitSeriesMap:hadRecordInitSeriesBuff()
	return self.hadRecordBuff
end

function RogueInitSeriesMap:setRecordInitSeriesBuff(flag)
	self.hadRecordBuff = flag
end

function RogueInitSeriesMap:needNotifySeriesInfo()
	return not self.hadNotifySeriesInfo
end

function RogueInitSeriesMap:setNotifySeriesInfo(flag)
	self.hadNotifySeriesInfo = flag
end

function RogueInitSeriesMap:getInitSeriesInfo()
	return self[self.curSeries]
end

function RogueInitSeriesMap:getUnlockSeriesList(rogueExtraBuffSeries)
	local unlockSeries = {}

	for series, data in pairs(RandomBuffSeriesData) do
		if data.initLock == 0 or lume.findInList(rogueExtraBuffSeries, series) then
			table_insert(unlockSeries, series)
		end
	end

	return unlockSeries
end

function RogueInitSeriesMap:randomInitSeriesInfo(player, unlockSeries, itemSetTypes)
	local randomSeries = self:randomInitSeriesList(unlockSeries)

	for _, series in ipairs(randomSeries) do
		local seriesConfigInfo = self:randomInitSeriesConfigData(series, itemSetTypes)
		local buffInfo = self:randomInitSeriesBuffInfo(player, seriesConfigInfo)
		local itemInfo = self:generateInitSeriesItemInfo(seriesConfigInfo)

		self:addRandomInitSeriesInfo(series, buffInfo, itemInfo, series)
	end

	return randomSeries
end

function RogueInitSeriesMap:randomInitSeriesDelayInfo(player, unlockSeries, itemSetTypes)
	local randomSeries = lume.randomchoice(unlockSeries)
	local buffSeriesConfigInfo = self:randomInitSeriesConfigData(randomSeries, itemSetTypes)
	local buffInfo = self:randomInitSeriesBuffInfo(player, buffSeriesConfigInfo)
	local itemInfo = self:generateInitSeriesItemInfo(buffSeriesConfigInfo)
	local itemSeriesConfigInfo = self:randomInitSeriesConfigData(Const.ROGUE_SERIES_SELECT_DELAY_VALUE, itemSetTypes)
	local delayItemInfo = self:generateInitSeriesItemInfo(itemSeriesConfigInfo)

	for itemId, itemCount in pairs(delayItemInfo) do
		itemInfo[itemId] = (itemInfo[itemId] or 0) + itemCount
	end

	self:addRandomInitSeriesInfo(Const.ROGUE_SERIES_SELECT_DELAY_VALUE, buffInfo, itemInfo, randomSeries)
end

function RogueInitSeriesMap:addRandomInitSeriesInfo(seriesId, buffInfo, itemInfo, realSeries)
	self[seriesId] = {
		buffInfo = buffInfo,
		itemInfo = itemInfo,
		realSeries = realSeries
	}
end

function RogueInitSeriesMap:randomInitSeriesList(unlockSeries)
	if lume.tableLength(unlockSeries) > Const.ROGUE_INIT_SERIES_CONSTANT_RANDOM_NUM then
		return lume.randomchoiceN(unlockSeries, Const.ROGUE_INIT_SERIES_CONSTANT_RANDOM_NUM)
	end

	return unlockSeries
end

function RogueInitSeriesMap:randomInitSeriesConfigData(series, itemSetTypes)
	local seriesInfo = RogueInitSeriesData[series]

	if seriesInfo == nil or lume.tableLength(seriesInfo) == 0 then
		return nil
	end

	local ids = {}
	local weights = {}

	itemSetTypes = itemSetTypes or {
		[0] = true
	}

	for id, info in pairs(seriesInfo) do
		local itemSetType = info.itemSetType or 0

		if itemSetTypes[itemSetType] then
			table_insert(ids, id)
			table_insert(weights, info.itemSetWeight or 0)
		end
	end

	if #ids == 0 then
		return nil
	end

	local selectId = lume.weightRandomChoiceOne(ids, weights)

	return seriesInfo[selectId]
end

function RogueInitSeriesMap:randomInitSeriesBuffInfo(player, seriesConfigInfo)
	local buffInfo = {}

	if not seriesConfigInfo then
		return buffInfo
	end

	local buffInfoData = seriesConfigInfo.buffInfo

	for _, data in ipairs(buffInfoData) do
		if data[1] == 0 then
			for _, buffId in ipairs(data[2]) do
				table_insert(buffInfo, buffId)
			end
		end
	end

	for _, data in ipairs(buffInfoData) do
		if data[1] == 1 then
			local seriesList, starList, count = data[2], data[3], data[4]
			local buffs = player:selectRogueBuffPool(seriesList, starList, buffInfo)
			local selectBuffs = player:randomRogueNormalBuff(buffs, count, false, false)

			for _, buffId in ipairs(selectBuffs) do
				table_insert(buffInfo, buffId)
			end
		end
	end

	return buffInfo
end

function RogueInitSeriesMap:generateInitSeriesItemInfo(seriesConfigInfo)
	local itemInfo = {}

	if not seriesConfigInfo then
		return itemInfo
	end

	local itemInfoData = seriesConfigInfo.itemInfo

	for _, itemData in pairs(itemInfoData) do
		itemInfo[itemData[1]] = (itemInfo[itemData[1]] or 0) + itemData[2]
	end

	return itemInfo
end

function RogueInitSeriesMap:debugInfo()
	local sPrint = "curSeries=" .. tostring(self.curSeries) .. ",curRealSeries=" .. tostring(self.curRealSeries) .. ",hadInit=" .. tostring(self.hadInit) .. ",hadRecordBuff=" .. tostring(self.hadRecordBuff) .. ",hadNotifySeriesInfo=" .. tostring(self.hadNotifySeriesInfo) .. " |"

	for seriesId, seriesInfo in pairs(self) do
		if type(seriesId) == "number" then
			sPrint = sPrint .. " [seriesId=" .. seriesId

			local buffInfo = ""

			for _, buffId in ipairs(seriesInfo.buffInfo) do
				buffInfo = buffInfo .. tostring(buffId) .. ","
			end

			local itemInfo = ""

			for itemId, itemCount in pairs(seriesInfo.itemInfo) do
				itemInfo = itemInfo .. tostring(itemId) .. "=" .. tostring(itemCount) .. ","
			end

			sPrint = sPrint .. ", realSeries=" .. tostring(seriesInfo.realSeries) .. ", buffInfo={" .. buffInfo .. "}, itemInfo={" .. itemInfo .. "}]"
		end
	end

	return sPrint
end

return RogueInitSeriesMap
