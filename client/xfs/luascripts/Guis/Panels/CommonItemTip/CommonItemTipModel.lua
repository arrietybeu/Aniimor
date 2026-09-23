-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonItemTip\\CommonItemTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local CommonItemTipModel = Class.LightClass("CommonItemTipModel", UIModel)
local ItemSourceData = require("Data.item_source_data")
local LuaUIUtils = require("Utils.LuaUIUtils")

function CommonItemTipModel:getDetailSourceInfo(sourceList)
	local dataList = {}

	if ToBool(sourceList) then
		for _, idx in pairs(sourceList) do
			local sourceEntry = ItemSourceData[idx]

			if sourceEntry then
				local conditionPass = LuaUIUtils.checkItemSourceCondition(sourceEntry)

				if conditionPass or sourceEntry.showForce == 1 then
					local data = {}

					table.merge(data, sourceEntry)

					data.conditionPass = conditionPass

					table.insert(dataList, data)
				end
			end
		end
	end

	return dataList
end

return CommonItemTipModel
