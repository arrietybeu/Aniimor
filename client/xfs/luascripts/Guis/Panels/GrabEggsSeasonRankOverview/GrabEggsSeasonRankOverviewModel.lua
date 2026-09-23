-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankOverview\\GrabEggsSeasonRankOverviewModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local GrabEggsSeasonRankOverviewModel = Class.LightClass("GrabEggsSeasonRankOverviewModel", UIModel)

function GrabEggsSeasonRankOverviewModel:getRankGroups()
	return GrabEggsRankUtils.buildRankGroups()
end

function GrabEggsSeasonRankOverviewModel:getCurrentBigRank()
	local bigRank = GrabEggsRankUtils.getCurrentRank()

	return bigRank
end

function GrabEggsSeasonRankOverviewModel:hasClaimableReward(rewardNodes)
	return GrabEggsRankUtils.hasClaimableReward(rewardNodes)
end

function GrabEggsSeasonRankOverviewModel:isRewardItemClaimable(reward)
	return GrabEggsRankUtils.isRewardItemClaimable(reward)
end

return GrabEggsSeasonRankOverviewModel
