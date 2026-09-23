-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryReward\\LotteryRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LotteryUtils = require("Utils.LotteryUtils")
local GachaPoolData = require("Data.gacha_pool_data")
local ItemData = require("Data.item_data")
local LotteryRewardModel = Class.LightClass("LotteryRewardModel", UIModel)

function LotteryRewardModel.compareRewardItem(left, right)
	if left._isSkin ~= right._isSkin then
		return left._isSkin
	end

	if not left._isSkin then
		if left._quality ~= right._quality then
			return left._quality > right._quality
		end

		if left.num ~= right.num then
			return left.num > right.num
		end
	end

	return left._originalIndex < right._originalIndex
end

function LotteryRewardModel:buildRewardList(drawItems)
	local itemList = {}

	if not drawItems then
		return itemList
	end

	for originalIndex, drawItem in ipairs(drawItems) do
		local itemId = tonumber(drawItem.itemId)

		if itemId then
			local poolConfig = GachaPoolData[tonumber(drawItem.poolRecordId)]
			local itemConfig = ItemData[itemId]

			itemList[#itemList + 1] = {
				id = itemId,
				num = tonumber(drawItem.itemNum) or 1,
				drawItem = drawItem,
				_isSkin = Utils.isTable(poolConfig) and tonumber(poolConfig.type) == 1,
				_quality = Utils.isTable(itemConfig) and (tonumber(itemConfig.quality) or 0) or 0,
				_originalIndex = originalIndex
			}
		end
	end

	table.sort(itemList, LotteryRewardModel.compareRewardItem)

	return itemList
end

function LotteryRewardModel:getShareReward(drawItems)
	if not drawItems then
		return nil
	end

	for _, drawItem in ipairs(drawItems) do
		local poolConfig = GachaPoolData[tonumber(drawItem.poolRecordId)]

		if Utils.isTable(poolConfig) and tonumber(poolConfig.isShare) == 1 then
			return drawItem
		end
	end

	return nil
end

function LotteryRewardModel:getDrawButtonText(drawCount)
	return ClientTextUtils.getFormatText(ClientTextUtils.getGameString("LOTTERY_GACHA"), tonumber(drawCount) or 1)
end

function LotteryRewardModel:getTipsText(drawCount)
	return ClientTextUtils.getFormatText(ClientTextUtils.getGameString("LOTTERY_REWARD_TIPS"), self:getDrawButtonText(drawCount))
end

function LotteryRewardModel:getCurCanShareCount(drawId)
	return LotteryUtils.getCurCanShareCount(drawId)
end

function LotteryRewardModel:buildViewData(info)
	info = Utils.isTable(info) and info or {}

	local shareReward = self:getShareReward(info.drawItems)
	local costInfo = Utils.isTable(info.costInfo) and info.costInfo or {}
	local drawCount = tonumber(info.drawCount) or tonumber(costInfo.drawCount) or 1
	local curCanShareCount = self:getCurCanShareCount(info.drawId)

	return {
		itemList = self:buildRewardList(info.drawItems),
		canShare = shareReward ~= nil and curCanShareCount > 0,
		shareReward = shareReward,
		curCanShareCount = curCanShareCount,
		drawCount = drawCount,
		title = ClientTextUtils.getGameString("LOTTERY_REWARD_TITLE"),
		tips = self:getTipsText(drawCount),
		consumeItemId = costInfo.itemId,
		consumeNum = tonumber(costInfo.consumeNum) or 0,
		hasDiscount = costInfo.hasDiscount == true,
		discountText = costInfo.discountText or ""
	}
end

return LotteryRewardModel
