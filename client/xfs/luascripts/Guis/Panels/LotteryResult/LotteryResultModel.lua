-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryResult\\LotteryResultModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemData = require("Data.item_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local AppearanceMakeupPresetData = require("Data.appearance_makeup_preset_data")
local ShopConstantData = require("Data.shopmall_constant_data")
local LotteryResultModel = Class.LightClass("LotteryResultModel", UIModel)

function LotteryResultModel:getLocalizedConfigText(value)
	local localizationId = tonumber(value)

	if localizationId then
		return pg.getLocalizationText(localizationId)
	end

	if type(value) == "string" and value ~= "" and not string.startsWith(value, "$") then
		return pg.getGameString(value)
	end

	return ""
end

function LotteryResultModel:getShopConstantText(definition)
	local config = ShopConstantData[definition]

	return self:getLocalizedConfigText(config and config.number or nil)
end

function LotteryResultModel:getRewardRarity(itemConfig)
	local quality = Utils.isTable(itemConfig) and tonumber(itemConfig.quality) or nil

	if not quality then
		return ""
	end

	local definitions = {
		"Intera_" .. tostring(quality) .. "_稀有度",
		"Intera" .. tostring(quality) .. "_稀有度",
		"Intera_" .. tostring(quality)
	}

	for _, definition in ipairs(definitions) do
		local rarityText = self:getShopConstantText(definition)

		if rarityText ~= "" then
			return rarityText
		end
	end

	return pg.getGameString("LOTTERY_REWARD_RARITY_" .. tostring(quality))
end

function LotteryResultModel:getRewardTypeDefinition(itemId)
	if AppearanceSuitData[itemId] then
		return "Suit"
	end

	if AvatarHairSuitData[itemId] then
		return "Hair"
	end

	if AppearanceMakeupPresetData[itemId] then
		return "face"
	end

	local appearanceConfig = AppearanceData[itemId]

	if not Utils.isTable(appearanceConfig) then
		return "Avatar"
	end

	if tonumber(appearanceConfig.type) == 2 then
		return "Avatar"
	end

	if tonumber(appearanceConfig.type) == 3 then
		return "Hair"
	end

	if tonumber(appearanceConfig.type) == 4 then
		return "face"
	end

	local resource = tostring(appearanceConfig.res or ""):lower()

	if resource:find("_head_", 1, true) then
		return "head"
	end

	if resource:find("_face_", 1, true) then
		return "face"
	end

	if resource:find("_back_", 1, true) then
		return "back"
	end

	if resource:find("_ear_", 1, true) then
		return "earring"
	end

	if resource:find("_neck_", 1, true) then
		return "necklace"
	end

	return "jewelry_type"
end

function LotteryResultModel:getRewardType(itemId)
	local definition = self:getRewardTypeDefinition(itemId)
	local config = ShopConstantData[definition]

	return ClientCashShopUtils.getAvatarTypeText(tonumber(config and config.number))
end

function LotteryResultModel:buildViewData(info)
	info = Utils.isTable(info) and info or {}

	local itemId = tonumber(info.itemId)
	local itemConfig = itemId and ItemData[itemId] or nil

	return {
		rewardName = itemConfig and pg.getLocalizationText(itemConfig.itemName) or "",
		rewardRarity = self:getRewardRarity(itemConfig),
		rewardType = itemId and self:getRewardType(itemId) or ""
	}
end

return LotteryResultModel
