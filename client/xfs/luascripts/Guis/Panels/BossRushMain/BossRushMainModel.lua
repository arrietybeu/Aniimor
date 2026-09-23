-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushMain\\BossRushMainModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushMainModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local EventCommonGuideData = require("Data.event_common_guide_data")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossRushMainModel = Class.LightClass("BossRushMainModel", UIModel)
local BossRushRewardData = require("Data.bossrush_reward_data")
local BOSS_RUSH_GUIDE_ID = 1006

local function getRewardQuality(reward)
	if not reward or reward.type ~= 0 or not reward.id then
		return -1
	end

	local itemData = ItemData[reward.id]

	return itemData and itemData.quality or 0
end

function BossRushMainModel:getMaxCurCycleStar(cycleId)
	if cycleId <= 0 then
		logger:error("BossRushMainModel:getMaxCurCycleStar cycle not legal", cycleId)

		return 60
	end

	local maxStar = 0

	for star, rewardInfo in pairs(BossRushRewardData) do
		for startCycleId, endCycleData in pairs(rewardInfo) do
			if cycleId and startCycleId <= cycleId then
				for endCycleId, rewardData in pairs(endCycleData) do
					if cycleId <= endCycleId and (rewardData.awardId or 0) > 0 then
						maxStar = math.max(maxStar, star)

						break
					end
				end
			end
		end
	end

	return maxStar
end

function BossRushMainModel:getRewardPreviewItemsByRarityDesc()
	local guideData = EventCommonGuideData[BOSS_RUSH_GUIDE_ID]
	local dropId = guideData and guideData.showRewardId

	if not dropId then
		return {}
	end

	local rewards = LuaUIUtils.getRewardItemByDropId(dropId)
	local rewardOrderMap = {}
	local itemRewards = {}

	for index, reward in ipairs(rewards) do
		if reward.type == 0 and reward.id then
			itemRewards[#itemRewards + 1] = reward
			rewardOrderMap[reward] = index
		end
	end

	table.sort(itemRewards, function(a, b)
		local aQuality = getRewardQuality(a)
		local bQuality = getRewardQuality(b)

		if aQuality ~= bQuality then
			return bQuality < aQuality
		end

		return (rewardOrderMap[a] or 0) < (rewardOrderMap[b] or 0)
	end)

	return itemRewards
end

return BossRushMainModel
