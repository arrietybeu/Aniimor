-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeGashapon\\HomeGashaponModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeObjectData = require("Data.home_object_data")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeGashaponModel = Class.LightClass("HomeGashaponModel", UIModel)
local RESET_LOOKBACK = {
	172800,
	691200,
	2764800
}

local function getCostCountByOrdinal(configs, drawOrdinal)
	local lastCostCount = 0

	for _, config in ipairs(configs) do
		local upper = config[1]
		local costCount = config[2]

		lastCostCount = costCount

		if drawOrdinal <= upper then
			return costCount
		end
	end

	return lastCostCount
end

local function getDrawLimitByLevel(configs, homeLevel)
	for _, config in ipairs(configs) do
		local level = config[1]
		local value = config[2]

		if homeLevel == level then
			return value
		end
	end

	return 0
end

local function getNextResetTime(ref)
	local resetType = HomelandConfigData.homeLotteryResetType
	local resetParam = HomelandConfigData.homeLotteryResetParam

	if resetType == 1 then
		return TimeUtils.getAreaCurOrNextDayResetTime(ref, resetParam[2], resetParam[3], resetParam[4])
	elseif resetType == 2 then
		return TimeUtils.getAreaCurOrNextWeekResetTime(ref, resetParam[1], resetParam[2], resetParam[3], resetParam[4])
	elseif resetType == 3 then
		return TimeUtils.getAreaCurOrNextMonthResetTime(ref, resetParam[1], resetParam[2], resetParam[3], resetParam[4])
	end
end

local function getCurrentPeriodStart()
	local resetType = HomelandConfigData.homeLotteryResetType
	local nextReset = getNextResetTime(Time.secondCache)

	if not nextReset then
		return 0
	end

	return getNextResetTime(nextReset - RESET_LOOKBACK[resetType]) or 0
end

function HomeGashaponModel:ctor()
	UIModel.ctor(self)
end

function HomeGashaponModel:getCostItemId()
	return HomelandConfigData.homeLotteryCostItemId or 0
end

function HomeGashaponModel:getCurrentPeriodStart()
	return getCurrentPeriodStart()
end

function HomeGashaponModel:getNextResetTime()
	return getNextResetTime(Time.secondCache) or 0
end

function HomeGashaponModel:getTitleTextId()
	local homeObjectId = HomelandConfigData.homeLotteryFurnitureId
	local homeObjectConfig = HomeObjectData[homeObjectId] or {}

	return homeObjectConfig.name or 0
end

function HomeGashaponModel:getCostCount(drawCount)
	return getCostCountByOrdinal(HomelandConfigData.homeLotteryCostItemCount, drawCount)
end

function HomeGashaponModel:getHomeLevel()
	if pg.me and pg.me.homeBasicInfo and pg.me.homeBasicInfo.level then
		return pg.me.homeBasicInfo.level
	end

	return 0
end

function HomeGashaponModel:getDrawLimit()
	return getDrawLimitByLevel(HomelandConfigData.homeLotteryDrawLimit, self:getHomeLevel())
end

function HomeGashaponModel:getDrawCount()
	local drawCount = pg.me.homeLotteryDrawCount or 0
	local periodStart = pg.me.homeLotteryPeriodStartTs or 0

	if periodStart ~= getCurrentPeriodStart() then
		return 0
	end

	return drawCount
end

function HomeGashaponModel:getDisplayRewards()
	local rewards = LuaUIUtils.getRewardItemByDropId(HomelandConfigData.gashaponDisplayRewards) or {}

	self:fillRewardQuality(rewards)
	self:sortRewards(rewards)

	return rewards
end

function HomeGashaponModel:fillRewardQuality(rewards)
	for _, rewardInfo in ipairs(rewards) do
		local itemConfig = rewardInfo.id and ItemData[rewardInfo.id] or {}

		rewardInfo.quality = rewardInfo.quality or itemConfig.quality or 0
	end
end

function HomeGashaponModel:sortRewards(rewards)
	table.sort(rewards, function(a, b)
		if a.quality ~= b.quality then
			return a.quality > b.quality
		end

		return (a.id or a.petId or 0) < (b.id or b.petId or 0)
	end)
end

return HomeGashaponModel
