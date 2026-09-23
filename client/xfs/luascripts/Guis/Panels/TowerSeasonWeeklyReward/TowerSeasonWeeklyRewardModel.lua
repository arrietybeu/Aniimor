-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSeasonWeeklyReward\\TowerSeasonWeeklyRewardModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSeasonWeeklyRewardModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local RogueDifficultyData = require("Data.rogue_difficulty_data")
local RogueUtils = require("Utils.RogueUtils")
local TowerSeasonWeeklyRewardModel = Class.LightClass("TowerSeasonWeeklyRewardModel", UIModel)

function TowerSeasonWeeklyRewardModel:getLevelData()
	local levelData = {}
	local levelTypeList = {}

	for levelId, levelInfo in ipairs(RogueDifficultyData) do
		local key = levelInfo.elementType

		if levelTypeList[key] == nil then
			levelTypeList[key] = #levelData + 1

			table.insert(levelData, {
				elementType = key,
				levels = {},
				selected = #levelData == 0
			})
		end

		local tabData = levelData[levelTypeList[key]]

		table.insert(tabData.levels, {
			levelId = levelId,
			info = levelInfo
		})
	end

	return levelData
end

function TowerSeasonWeeklyRewardModel:canGetReward(levelId)
	return RogueUtils.isSeasonWeeklyRewardUnlocked(levelId)
end

function TowerSeasonWeeklyRewardModel:isRewardReceived(levelId)
	return RogueUtils.isSeasonWeeklyRewardReceived(levelId)
end

return TowerSeasonWeeklyRewardModel
