-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchCountryReward\\PetResearchCountryRewardModel.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local UIModel = require("Guis.UIModel")
local PetResearchCountryRewardModel = Class.LightClass("PetResearchCountryRewardModel", UIModel)

function PetResearchCountryRewardModel:getCountryRewardData(countryId)
	local ret = {}

	self.hasReward = false
	countryId = countryId or self.countryId

	local countryContent = PetResearchUtils.getCountryResearchContentById(countryId)
	local petHandbookMap = pg.me.petHandbookMap
	local curStar, curExp = petHandbookMap:getCountryTotalLevel(countryId)
	local totalStar = table.maxn(countryContent)

	self.defaultSelectIdx = totalStar

	for starLevel = 1, totalStar do
		local item = {}
		local starInfo = countryContent[starLevel]
		local rewardStatues = petHandbookMap:getCountryLevelRewardStatus(countryId, starLevel)
		local state = 0

		item.maxProgressValue = 1
		item.progressValue = 1

		if rewardStatues == Const.REWARD_STATUS_INIT then
			if curStar + 1 == starLevel then
				local nextLevel = math.min(totalStar, curStar + 1)

				item.maxProgressValue = countryContent[nextLevel].needResearchPoint
				item.progressValue = curExp

				if starLevel < self.defaultSelectIdx then
					self.defaultSelectIdx = starLevel
				end
			else
				item.maxProgressValue = 1
				item.progressValue = 0
			end
		elseif rewardStatues == Const.REWARD_STATUS_CANREWARD then
			state = 2
			self.hasReward = true

			if starLevel < self.defaultSelectIdx then
				self.defaultSelectIdx = starLevel
			end
		elseif rewardStatues == Const.REWARD_STATUS_DONE then
			state = 1
		end

		item.rewardStatues = rewardStatues
		item.state = state
		item.isGolden = starInfo.isGolden

		local rewards = LuaUIUtils.getRewardItemByDropId(starInfo.reward)

		for _, reward in ipairs(rewards) do
			reward.state = state
			reward.redDotKey = countryId .. starLevel
		end

		item.itemRewards = rewards
		item.curLevel = starLevel
		item.allLevel = totalStar
		ret[#ret + 1] = item
	end

	return ret
end

return PetResearchCountryRewardModel
