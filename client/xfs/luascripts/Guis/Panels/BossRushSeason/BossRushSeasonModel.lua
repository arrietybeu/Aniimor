-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushSeason\\BossRushSeasonModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushSeasonModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local BossRushSeasonRewardData = require("Data.bossrush_season_reward_data")
local BossRushSeasonModel = Class.LightClass("BossRushSeasonModel", UIModel)

function BossRushSeasonModel:getData(seasonId)
	local rewardList = {}

	for needStar, seasonBeginData in pairs(BossRushSeasonRewardData) do
		for seasonBegin, seasonEndData in pairs(seasonBeginData) do
			if seasonBegin <= seasonId then
				for seasonEnd, rewardData in pairs(seasonEndData) do
					if seasonId <= seasonEnd and (rewardData.awardId or rewardData.seasonBuff) then
						rewardList[#rewardList + 1] = {
							needStar = needStar,
							awardId = rewardData.awardId,
							seasonBuff = rewardData.seasonBuff
						}
					end
				end
			end
		end
	end

	table.sort(rewardList, function(a, b)
		return a.needStar < b.needStar
	end)

	return rewardList
end

return BossRushSeasonModel
