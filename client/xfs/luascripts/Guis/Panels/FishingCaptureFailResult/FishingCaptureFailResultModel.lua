-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureFailResult\\FishingCaptureFailResultModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FishingCaptureFailResultModel = Class.LightClass("FishingCaptureFailResultModel", UIModel)

function FishingCaptureFailResultModel:ctor()
	UIModel.ctor(self)

	self._settlementData = nil
end

function FishingCaptureFailResultModel:setSettlementData(data)
	self._settlementData = data
end

function FishingCaptureFailResultModel:getSettlementData()
	return self._settlementData
end

function FishingCaptureFailResultModel:getRewardList()
	local res = {}

	if not self._settlementData or not self._settlementData.rewards then
		return res
	end

	for itemId, itemNum in pairs(self._settlementData.rewards) do
		local cfg = ItemData[itemId]

		if cfg then
			local temp = {
				isCaptureBind = false,
				index = 0,
				itemId = itemId,
				icon = LuaUIUtils.getIconByItemId(itemId),
				quality = cfg and cfg.quality or 0,
				num = itemNum
			}

			table.insert(res, temp)
		end
	end

	return res
end

return FishingCaptureFailResultModel
