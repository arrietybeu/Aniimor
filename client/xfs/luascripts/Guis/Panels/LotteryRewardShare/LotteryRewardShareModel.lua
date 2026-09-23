-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryRewardShare\\LotteryRewardShareModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local GachaEntryData = require("Data.gacha_entry_data")
local LotteryRewardShareModel = Class.LightClass("LotteryRewardShareModel", UIModel)

function LotteryRewardShareModel:getGiftUrl(drawId)
	local entryConfig = GachaEntryData[tonumber(drawId)]

	if not Utils.isTable(entryConfig) or type(entryConfig.giftUrl) ~= "string" or entryConfig.giftUrl == "" then
		return nil
	end

	return entryConfig.giftUrl
end

return LotteryRewardShareModel
