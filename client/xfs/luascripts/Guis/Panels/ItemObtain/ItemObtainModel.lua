-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemObtain\\ItemObtainModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemObtainModel = Class.LightClass("ItemObtainModel", UIModel)
local ItemConst = require("Common.Const.ItemConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ItemConstSourceData = require("Data.item_const_source_data")

function ItemObtainModel:parseItemList(rawDataList, sourceType)
	for _, rawData in ipairs(rawDataList) do
		if rawData.itemId == ItemConst.ITEM_SPECIAL_PET_DISPLAY then
			rawData.isPet = true

			local content = rawData.content

			rawData.icon = LuaUIUtils.getPetIconByTemplateId(content.templateId, LuaUIUtils.PET_ICON, content.label)
		else
			LuaUIUtils.parseItemCfgData(rawData)
		end
	end

	if sourceType == ItemConstSourceData.ITEM_SOURCE_SANDBOX_ROGUELIKE and ClientActivityUtils.isRogueRewardUp() then
		local playerUpRewardInfo = pg.me.upRogueExchangeRewardInfo

		table.sort(rawDataList, function(a, b)
			local aCnt = playerUpRewardInfo[a.itemId] or 0
			local bCnt = playerUpRewardInfo[b.itemId] or 0

			if aCnt ~= bCnt then
				return aCnt < bCnt
			end

			local aQuality = a.quality or 0
			local bQuality = b.quality or 0

			if aQuality ~= bQuality then
				return bQuality < aQuality
			elseif a.itemId ~= b.itemId then
				return a.itemId < b.itemId
			else
				return (a.genID or 0) < (b.genID or 0)
			end
		end)
	else
		table.sort(rawDataList, function(a, b)
			local aQuality = a.quality or 0
			local bQuality = b.quality or 0

			if aQuality ~= bQuality then
				return bQuality < aQuality
			elseif a.itemId ~= b.itemId then
				return a.itemId < b.itemId
			else
				return (a.genID or 0) < (b.genID or 0)
			end
		end)
	end
end

return ItemObtainModel
