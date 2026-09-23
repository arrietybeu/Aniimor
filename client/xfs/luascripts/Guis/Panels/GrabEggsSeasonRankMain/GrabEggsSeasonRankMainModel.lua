-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonRankMain\\GrabEggsSeasonRankMainModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local GrabEggsSeasonRankMainModel = Class.LightClass("GrabEggsSeasonRankMainModel", UIModel)

function GrabEggsSeasonRankMainModel:getPageData()
	return GrabEggsRankUtils.buildMainPageData()
end

function GrabEggsSeasonRankMainModel:getSeasonDisplayInfo()
	return GrabEggsRankUtils.getSeasonDisplayInfo()
end

function GrabEggsSeasonRankMainModel:getRankIconBoardUrl(bigRank)
	return GrabEggsRankUtils.getRankIconBoardUrl(bigRank)
end

function GrabEggsSeasonRankMainModel:hasClaimableReward()
	return GrabEggsRankUtils.hasClaimableReward()
end

function GrabEggsSeasonRankMainModel:isRewardItemClaimable(reward)
	return GrabEggsRankUtils.isRewardItemClaimable(reward)
end

local function hasConfiguredReward(nodes)
	for _, node in ipairs(nodes or EMPTY_TABLE) do
		if #(node.dropIds or {}) > 0 then
			return true
		end
	end

	return false
end

local function getStageRewardTitle(group)
	local firstSmallRank, lastSmallRank

	for _, node in ipairs(group.stageRewardNodes or EMPTY_TABLE) do
		if node.param == 0 and #(node.dropIds or {}) > 0 then
			firstSmallRank = firstSmallRank or node.smallRank
			lastSmallRank = node.smallRank
		end
	end

	if not firstSmallRank then
		return group.name
	end

	local firstRoman = GrabEggsRankUtils.getDisplayRoman(group.bigRank, firstSmallRank)
	local lastRoman = GrabEggsRankUtils.getDisplayRoman(group.bigRank, lastSmallRank)

	if firstSmallRank == lastSmallRank then
		return string.format("%s (%s)", group.name, firstRoman)
	end

	return string.format("%s (%s~%s)", group.name, firstRoman, lastRoman)
end

function GrabEggsSeasonRankMainModel:getRewardOverviewTabClaimableState()
	local result = {
		[0] = false,
		false
	}

	for _, group in ipairs(GrabEggsRankUtils.buildRankGroups()) do
		result[0] = result[0] or GrabEggsRankUtils.hasClaimableReward(group.rankRewardNodes)
		result[1] = result[1] or GrabEggsRankUtils.hasClaimableReward(group.stageRewardNodes)
	end

	return result
end

function GrabEggsSeasonRankMainModel:getRewardOverviewData(tabType)
	local result = {}
	local groups = GrabEggsRankUtils.buildRankGroups()

	for _, group in ipairs(groups) do
		local rewardNodes = tabType == 1 and group.stageRewardNodes or group.rankRewardNodes
		local rewards = tabType == 1 and group.stageRewards or group.rankRewards

		if hasConfiguredReward(rewardNodes) then
			result[#result + 1] = {
				bigRank = group.bigRank,
				name = tabType == 1 and getStageRewardTitle(group) or group.name,
				icon = group.icon,
				isCurrent = group.isCurrent,
				rewards = rewards
			}
		end
	end

	return result
end

return GrabEggsSeasonRankMainModel
