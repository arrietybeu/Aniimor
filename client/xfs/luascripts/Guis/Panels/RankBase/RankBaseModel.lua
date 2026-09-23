-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankBase\\RankBaseModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RankBaseData = require("Data.rank_base_data")
local RankBaseModel = Class.LightClass("RankBaseModel", UIModel)
local EMPTY_LIST = {}

function RankBaseModel:getRankTabData(rankId)
	local rankData = RankBaseData[rankId]
	local tab1List = table.keys(rankData)

	table.sort(tab1List)

	local tabCount = self:getRankTabCount(rankData, tab1List)
	local tab1 = tab1List[1]
	local firstTabData = rankData[tab1]
	local tab2List = table.keys(firstTabData)

	table.sort(tab2List)

	local tab2 = tab2List[1]
	local leftTabList = self:getLeftTabList(rankId, rankData, tab1List)
	local leftTab = leftTabList[1]

	if leftTab ~= nil then
		return leftTabList, leftTab.secondTabList[1] or leftTab, tabCount
	end

	return leftTabList, {
		rankId = rankId,
		tab1 = tab1,
		tab2 = tab2
	}, tabCount
end

function RankBaseModel:getRankTabCount(rankData, tab1List)
	local count = 0

	for _, tab1 in ipairs(tab1List) do
		count = count + table.nums(rankData[tab1])
	end

	return count
end

function RankBaseModel:getLeftTabList(rankId, rankData, tab1List)
	local leftTabList = {}

	for _, tab1 in ipairs(tab1List) do
		local firstTabData = rankData[tab1]
		local tab2List = table.keys(firstTabData)

		table.sort(tab2List)

		local tab2 = tab2List[1]

		leftTabList[#leftTabList + 1] = {
			tIndex = 0,
			rankId = rankId,
			tab1 = tab1,
			tab2 = tab2,
			textKey = rankData[tab1][tab2].tabName1,
			secondTabList = self:getSecondTabList(rankId, tab1, tab2List)
		}
	end

	return leftTabList
end

function RankBaseModel:getSecondTabList(rankId, tab1, tab2List)
	if #tab2List == 1 and tab2List[1] == 0 then
		return EMPTY_LIST
	end

	local secondTabList = {}

	for _, tab2 in ipairs(tab2List) do
		secondTabList[#secondTabList + 1] = {
			tIndex = 0,
			rankId = rankId,
			tab1 = tab1,
			tab2 = tab2,
			textKey = RankBaseData[rankId][tab1][tab2].tabName2
		}
	end

	return secondTabList
end

function RankBaseModel:getRankConfig(rankId, tab1, tab2)
	return RankBaseData[rankId][tab1][tab2]
end

return RankBaseModel
