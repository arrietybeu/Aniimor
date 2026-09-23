-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonInfo\\GrabEggsSeasonInfoModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsSeasonInfoModel = Class.LightClass("GrabEggsSeasonInfoModel", UIModel)
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local EggRankBaseData = require("Data.egg_rank_base_data")
local EggRankDailyBoxData = require("Data.egg_rank_daily_box_data")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")

local function sortByQualityDesc(items, getQuality)
	local indexed = {}

	for index, item in ipairs(items) do
		indexed[index] = {
			item = item,
			index = index,
			quality = getQuality(item) or 0
		}
	end

	table.sort(indexed, function(left, right)
		if left.quality ~= right.quality then
			return left.quality > right.quality
		end

		return left.index < right.index
	end)

	local result = {}

	for index, data in ipairs(indexed) do
		result[index] = data.item
	end

	return result
end

local function getRewardQuality(reward)
	local itemConfig = reward and reward.id and ItemData[reward.id]

	return itemConfig and itemConfig.quality or 0
end

function GrabEggsSeasonInfoModel:ctor()
	return
end

function GrabEggsSeasonInfoModel:getSeasonDisplayInfo()
	return GrabEggsRankUtils.getSeasonDisplayInfo()
end

function GrabEggsSeasonInfoModel:getCurrentRank()
	local bigRank = pg.me.eggLv or 1
	local smallRank = pg.me.secEggLv or 1

	return bigRank, smallRank
end

function GrabEggsSeasonInfoModel:getRankDisplayInfo()
	local bigRank, smallRank = self:getCurrentRank()
	local cfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]

	if not cfg then
		return
	end

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		name = pg.getLocalizationText(cfg.name),
		icon = cfg.icon,
		levelText = string.format("%d-%d", bigRank, smallRank)
	}
end

function GrabEggsSeasonInfoModel:forEachRank(callback, bigUpTo, secUpTo)
	local maxBigRank = 0

	for bigRank, _ in pairs(EggRankBaseData) do
		if maxBigRank < bigRank then
			maxBigRank = bigRank
		end
	end

	for bigRank = 1, maxBigRank do
		local bigCfg = EggRankBaseData[bigRank]

		if bigCfg then
			for smallRank, cfg in ipairs(bigCfg) do
				if bigUpTo and (bigUpTo < bigRank or bigRank == bigUpTo and secUpTo < smallRank) then
					return
				end

				if callback(cfg, bigRank, smallRank) then
					return
				end
			end
		end
	end
end

function GrabEggsSeasonInfoModel:getMaxBoxSlotCount()
	local total = 0

	self:forEachRank(function(cfg)
		total = total + (cfg.boxNumber or 0)
	end)

	return total
end

function GrabEggsSeasonInfoModel:getUnlockedBoxSlotCount()
	local bigRank, smallRank = self:getCurrentRank()
	local total = 0

	self:forEachRank(function(cfg)
		total = total + (cfg.boxNumber or 0)
	end, bigRank, smallRank)

	return total
end

function GrabEggsSeasonInfoModel:getSlotUnlockRankName(slotIndex)
	local total = 0
	local rankName

	self:forEachRank(function(cfg)
		total = total + (cfg.boxNumber or 0)

		if total >= slotIndex then
			rankName = pg.getLocalizationText(cfg.name)

			return true
		end
	end)

	return rankName
end

function GrabEggsSeasonInfoModel:getDailyBoxLimit()
	local bigRank, smallRank = self:getCurrentRank()
	local cfg = EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]

	return cfg and cfg.boxUpLimit or 0
end

function GrabEggsSeasonInfoModel:getDailyBoxAcquired()
	return pg.me.refreshCountDaily or 0
end

function GrabEggsSeasonInfoModel:getBoxDisplayData(box, rewardId)
	if not box or box.id == 0 then
		return nil
	end

	local boxCfg = EggRankDailyBoxData[box.id]

	if not boxCfg then
		return nil
	end

	local remainSec = (box.timestamp or 0) - Time.secondCache
	local totalSec = (box.timestamp or 0) - (box.achievedTime or 0)

	return {
		id = box.id,
		quality = tonumber(boxCfg.quality),
		reward = boxCfg.reward,
		remainSec = math.max(0, remainSec),
		totalSec = math.max(1, totalSec),
		isReady = remainSec <= 0,
		rewardId = rewardId,
		icon = boxCfg.icon
	}
end

function GrabEggsSeasonInfoModel:getDailyBoxStatus()
	local limit = self:getDailyBoxLimit()
	local acquired = self:getDailyBoxAcquired()

	return {
		acquired = acquired,
		limit = limit,
		remaining = math.max(0, limit - acquired),
		isFull = limit <= acquired
	}
end

function GrabEggsSeasonInfoModel:buildBoxSlotList()
	local maxSlot = self:getMaxBoxSlotCount()
	local unlockedSlot = self:getUnlockedBoxSlotCount()
	local boxList = pg.me.rewardBoxList
	local dailyStatus = self:getDailyBoxStatus()
	local slots = {}

	for i = 1, maxSlot do
		if unlockedSlot < i then
			slots[i] = {
				isLocked = true
			}
		else
			local box = boxList and boxList[i]

			if box and box.id ~= 0 then
				slots[i] = self:getBoxDisplayData(box, i)
			elseif dailyStatus.isFull then
				slots[i] = {
					isFull = true
				}
			else
				slots[i] = {
					isEmpty = true
				}
			end
		end
	end

	return slots
end

function GrabEggsSeasonInfoModel:hasReadyRewardBox()
	local boxList = pg.me.rewardBoxList

	if not boxList then
		return false
	end

	local now = Time.secondCache
	local unlockedCount = self:getUnlockedBoxSlotCount()

	for i = 1, unlockedCount do
		local box = boxList[i]

		if box and box.id ~= 0 and now >= (box.timestamp or 0) then
			return true
		end
	end

	return false
end

function GrabEggsSeasonInfoModel:getBoxRewardPreviewList()
	local previewList = {}

	for boxId = 1, #EggRankDailyBoxData do
		local cfg = EggRankDailyBoxData[boxId]

		if cfg then
			local rewards = {}

			for _, dropId in ipairs(cfg.reward or EMPTY_TABLE) do
				local dropRewards = LuaUIUtils.getRewardItemByDropId(dropId) or {}

				for _, reward in ipairs(dropRewards) do
					rewards[#rewards + 1] = reward
				end
			end

			previewList[#previewList + 1] = {
				icon = cfg.icon,
				name = pg.getLocalizationText(cfg.name),
				quality = cfg.quality or 0,
				rewards = sortByQualityDesc(rewards, getRewardQuality)
			}
		end
	end

	return sortByQualityDesc(previewList, function(data)
		return data.quality
	end)
end

return GrabEggsSeasonInfoModel
