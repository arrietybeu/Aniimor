-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeGashaponRule\\HomeGashaponRuleModel.lua

local Class = require("Core.Framework.Class")
local HomeGashaponModel = require("Guis.Panels.HomeGashapon.HomeGashaponModel")
local HomelandLotteryTierData = require("Data.homeland_lottery_tier_data")
local HomelandLotteryRewardData = require("Data.homeland_lottery_reward_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeGashaponRuleModel = Class.LightClass("HomeGashaponRuleModel", HomeGashaponModel)

function HomeGashaponRuleModel:getTierRules()
	local tierRules = {}
	local tierRuleMap = {}
	local tierWeightMap = {}
	local totalWeight = 0

	for tierId, tierConfig in pairs(HomelandLotteryTierData) do
		local weight = tierConfig.weight
		local tierRule = {
			tierId = tierId,
			name = tierConfig.des,
			sortId = tierId,
			rewards = {}
		}

		tierRules[#tierRules + 1] = tierRule
		tierRuleMap[tierId] = tierRule
		tierWeightMap[tierId] = weight
		totalWeight = totalWeight + weight
	end

	local orderedRewardConfigs = {}

	for configId, rewardConfig in pairs(HomelandLotteryRewardData) do
		orderedRewardConfigs[#orderedRewardConfigs + 1] = {
			configId = configId,
			config = rewardConfig
		}
	end

	table.sort(orderedRewardConfigs, function(left, right)
		return left.configId < right.configId
	end)

	for _, rewardEntry in ipairs(orderedRewardConfigs) do
		local rewardConfig = rewardEntry.config
		local rewards = tierRuleMap[rewardConfig.tierId].rewards
		local dropRewards = LuaUIUtils.getRewardItemByDropId(rewardConfig.rewardId)

		for _, dropReward in ipairs(dropRewards) do
			rewards[#rewards + 1] = dropReward
		end
	end

	for _, tierRule in ipairs(tierRules) do
		local weight = tierWeightMap[tierRule.tierId]

		tierRule.percent = weight / totalWeight * 100
	end

	table.sort(tierRules, function(left, right)
		if left.sortId == right.sortId then
			return left.tierId < right.tierId
		end

		return left.sortId < right.sortId
	end)

	return tierRules
end

return HomeGashaponRuleModel
