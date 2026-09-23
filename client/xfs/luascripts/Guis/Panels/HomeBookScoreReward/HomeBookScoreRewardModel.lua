-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookScoreReward\\HomeBookScoreRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local HomeBookScoreRewardModel = Class.LightClass("HomeBookScoreRewardModel", UIModel)

function HomeBookScoreRewardModel:getCurrentGradeConfig()
	if not pg.me then
		return nil
	end

	return HomeBookDataUtils.getCurGradeConfig(pg.me:getHomeHandbookScore())
end

function HomeBookScoreRewardModel:getRewards()
	local result = {}

	if not pg.me then
		return result
	end

	local score = pg.me:getHomeHandbookScore()
	local receivedGrade = pg.me:getHomeHandbookLastReceivedGrade()
	local rewards = HomeBookDataUtils.getScoreRewards()

	for _, reward in ipairs(rewards) do
		local grade = reward.config.grade or 0
		local state = 0

		if grade <= receivedGrade then
			state = 1
		elseif grade <= score then
			state = 2
		end

		result[#result + 1] = {
			id = reward.id,
			grade = grade,
			rewardId = reward.config.reward,
			state = state,
			isClaimable = state == 2,
			redDotPath = HomeBookRedDotUtils.getScoreRewardPath(reward.id)
		}
	end

	return result
end

return HomeBookScoreRewardModel
