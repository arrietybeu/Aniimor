-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankReward\\RankRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RankRewardData = require("Data.rank_reward_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RankRewardModel = Class.LightClass("RankRewardModel", UIModel)

function RankRewardModel:getRewardList(rewardId, currentRank)
	local config = RankRewardData[rewardId]
	local rewardList = {}

	for index, rankRange in ipairs(config.rankSet) do
		local dropId = config.rankReward[index]

		rewardList[#rewardList + 1] = {
			title = self:getRankRangeText(rankRange),
			isCurrent = self:isCurrentRank(rankRange, currentRank),
			rewards = LuaUIUtils.getRewardItemByDropId(dropId) or {}
		}
	end

	return rewardList
end

function RankRewardModel:getRankRangeText(rankRange)
	return pg.getFormatText(pg.getGameString("RANK_REWARD_RANGE"), rankRange[1], rankRange[2])
end

function RankRewardModel:isCurrentRank(rankRange, currentRank)
	return currentRank >= rankRange[1] and currentRank <= rankRange[2]
end

return RankRewardModel
