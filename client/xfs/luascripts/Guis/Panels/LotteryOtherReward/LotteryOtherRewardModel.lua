-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryOtherReward\\LotteryOtherRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local GachaEntryData = require("Data.gacha_entry_data")
local ShopTagMappingData = require("Common.Data.shop_tag_mapping_data")
local ShopCommodityData = require("Data.shop_commodity_data")
local ItemData = require("Data.item_data")
local LotteryOtherRewardModel = Class.LightClass("LotteryOtherRewardModel", UIModel)

function LotteryOtherRewardModel:getRewardGroupList(drawId)
	local entryConfig = GachaEntryData[tonumber(drawId)]
	local shopId = Utils.isTable(entryConfig) and tonumber(entryConfig.shopId) or nil
	local shopConfig = shopId and ShopTagMappingData[shopId] or nil

	if not Utils.isTable(shopConfig) or not Utils.isTable(shopConfig.goodsList) then
		return {}
	end

	local groupMap = {}

	for _, commodityId in ipairs(shopConfig.goodsList) do
		local commodityConfig = ShopCommodityData[commodityId]

		if Utils.isTable(commodityConfig) and tonumber(commodityConfig.showInReward) ~= 1 then
			local itemConfig = ItemData[commodityConfig.itemId]
			local rarity = Utils.isTable(itemConfig) and tonumber(itemConfig.quality) or nil

			if rarity then
				local groupData = groupMap[rarity]

				if not groupData then
					groupData = {
						rarity = rarity,
						itemList = {}
					}
					groupMap[rarity] = groupData
				end

				groupData.itemList[#groupData.itemList + 1] = {
					id = commodityConfig.itemId,
					num = commodityConfig.itemNum or 1,
					commodityId = commodityId
				}
			end
		end
	end

	local groupList = {}

	for _, groupData in pairs(groupMap) do
		groupList[#groupList + 1] = groupData
	end

	table.sort(groupList, function(left, right)
		return left.rarity > right.rarity
	end)

	return groupList
end

return LotteryOtherRewardModel
