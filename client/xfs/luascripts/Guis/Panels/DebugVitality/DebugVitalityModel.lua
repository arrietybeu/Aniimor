-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DebugVitality\\DebugVitalityModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("DebugVitalityModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local DebugVitalityModel = Class.LightClass("DebugVitalityModel", UIModel)
local ItemDebugData = require("Data.item_debug_data")
local CurrencyAutoChangeData = require("Data.currency_auto_change_data")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")

function DebugVitalityModel:getItemInfo()
	local res = {}
	local min_interval = math.maxInt

	for id, _ in pairs(ItemDebugData) do
		local vData = CurrencyAutoChangeData[id]
		local cData = ItemData[id]
		local interval = math.maxInt

		if vData and cData then
			local tp = vData.cycleType
			local ve = vData.changeValue
			local cy = vData.cycleValue
			local serverLimit = pg.me and pg.me.energyAutoLimit and pg.me.energyAutoLimit[id]
			local maxValue = serverLimit or vData.autoChangeRange and vData.autoChangeRange[2]
			local item = {
				id = id,
				icon = LuaUIUtils.getIconByItemId(id),
				name = pg.getLocalizationText(cData.itemName),
				ownNum = ClientUtils.getItemCountById(id, true),
				changeType = tp,
				changeNum = vData.changeValue,
				maxValue = maxValue
			}

			if maxValue then
				item.ownNumStr = string.format("%d/%d", item.ownNum, maxValue)
			else
				item.ownNumStr = item.ownNum
			end

			local changeStr = "NoType"

			if tp == 1 then
				changeStr = string.format("%d/%d天", ve, cy)
			elseif tp == 2 then
				changeStr = string.format("%d/%d周", ve, cy)
			elseif tp == 3 then
				changeStr = string.format("%d/%d月", ve, cy)
			elseif tp == 4 then
				interval = cy
				changeStr = string.format("%d/%d秒", ve, cy)
			end

			item.desc = changeStr
			res[#res + 1] = item
		end

		if interval < min_interval then
			min_interval = interval
		end
	end

	return res, min_interval
end

function DebugVitalityModel:refreshDataList(dataList)
	local max = dataList.Count - 1

	for i = 0, max do
		local item = dataList[i]

		item.ownNum = ClientUtils.getItemCountById(item.id, true)

		if item.maxValue then
			item.ownNumStr = string.format("%d/%d", item.ownNum, item.maxValue)
		else
			item.ownNumStr = item.ownNum
		end
	end
end

return DebugVitalityModel
