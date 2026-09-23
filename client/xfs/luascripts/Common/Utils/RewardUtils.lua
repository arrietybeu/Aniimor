-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\RewardUtils.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local DropData = require("Data.drop_data")
local ItemData = require("Data.item_data")
local RewardUtils = {}

function RewardUtils.getDisplayRewardList(rewardId)
	local totalRewardInfo = DropData[rewardId] or {}
	local totalDisplayRewardInfo = totalRewardInfo.displayReward or {}

	return RewardUtils.refactorDisplayReward(totalDisplayRewardInfo)
end

function RewardUtils.refactorDisplayReward(displayReward)
	local rewardList = {}

	for index, rewardInfo in ipairs(displayReward) do
		local itemId = rewardInfo[1]
		local itemCount = rewardInfo[2] or 0
		local itemData = ItemData[itemId]
		local iconId = itemData.icon or 0

		rewardList[index] = {
			itemId = itemId,
			itemName = itemData.itemName,
			quality = itemData.quality,
			funcRep = itemData.funcRep,
			iconURL = LuaUIUtils.getIconByIconId(iconId),
			count = itemCount
		}
	end

	return rewardList
end

return RewardUtils
