-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PropSelectCom\\PropSelectComModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PropSelectComModel = Class.LightClass("PropSelectComModel", UIModel)
local ItemEffectData = require("Data.item_effect_data")
local TributeValueRangeData = require("Data.tribute_valueRange_data")
local ItemData = require("Data.item_data")
local ItemSelectData = require("Data.item_select_data")
local LeylineFlowerTributeData = require("Data.leylineflower_tribute_data")
local ItemSelectTabData = require("Data.item_select_tab_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")

function PropSelectComModel:getBagItemBySType(sTypeList)
	local itemList = {}

	ItemUtils.eachSupportedTypedBag(pg.me, function(_, itemBag)
		local iList = itemBag:getByFilter(function(item)
			local effectData = ItemEffectData[item.id]

			for i = 1, #sTypeList do
				if effectData and effectData.sType == sTypeList[i] then
					return true
				end
			end

			return false
		end)

		table.mergeList(itemList, iList)
	end)

	return itemList
end

function PropSelectComModel:getBagItemByType(typeList)
	local itemList = {}

	ItemUtils.eachSupportedTypedBag(pg.me, function(_, itemBag)
		local iList = itemBag:getByFilter(function(item)
			local itemData = ItemData[item.id]

			for i = 1, #typeList do
				if itemData and itemData.type == typeList[i] then
					return true
				end
			end

			return false
		end)

		table.mergeList(itemList, iList)
	end)

	return itemList
end

function PropSelectComModel:buildPropInfos(configId, tabIndex, fromLeylineFlower, reservedItems)
	local configGroup = ItemSelectData[configId]
	local group = configGroup.group
	local tabConfigs = ItemSelectTabData[group]
	local config = tabConfigs[tabIndex]
	local items = {}
	local itemIdCheck = {}

	local function applyReserved(item)
		if reservedItems and reservedItems[item.id] then
			item.ownNum = math.max(0, item.ownNum - reservedItems[item.id])
		end
	end

	for i = 1, 4 do
		if config["type" .. i] == 1 then
			local bagItems = self:getBagItemBySType(config["param" .. i])

			for _, bagItem in ipairs(bagItems) do
				local item = LuaUIUtils.getItemInfoById(bagItem.id)

				if fromLeylineFlower and not LeylineFlowerTributeData[bagItem.id] then
					item = nil
				end

				if item then
					local effectData = ItemEffectData[bagItem.id]

					for j, sType in ipairs(config["param" .. i]) do
						if effectData and effectData.sType == sType then
							item.numParam = config["numParam" .. i][j]
							item.numType = config["numType" .. i]

							break
						end
					end

					local cData = ItemData[bagItem.id]

					if cData then
						item.shortName = cData.itemName
						item.shortDesc = cData.funcRep
					end

					applyReserved(item)

					if not itemIdCheck[item.id] then
						items[#items + 1] = item
						itemIdCheck[item.id] = true
					end
				end
			end
		elseif config["type" .. i] == 2 then
			for j, id in ipairs(config["param" .. i]) do
				local item = LuaUIUtils.getItemInfoById(id)

				if fromLeylineFlower and not LeylineFlowerTributeData[id] then
					item = nil
				end

				if item then
					item.numParam = config["numParam" .. i][j]
					item.numType = config["numType" .. i]

					local cData = ItemData[id]

					if cData then
						item.shortName = cData.itemName
						item.shortDesc = cData.funcRep
					end

					applyReserved(item)

					if not itemIdCheck[item.id] then
						items[#items + 1] = item
						itemIdCheck[item.id] = true
					end
				end
			end
		elseif config["type" .. i] == 3 then
			local bagItems = self:getBagItemByType(config["param" .. i])

			for _, bagItem in ipairs(bagItems) do
				local item = LuaUIUtils.getItemInfoById(bagItem.id)

				if fromLeylineFlower and not LeylineFlowerTributeData[bagItem.id] then
					item = nil
				end

				if item then
					local itemData = ItemData[bagItem.id]

					for j, type in ipairs(config["param" .. i]) do
						if itemData and itemData.type == type then
							item.numParam = config["numParam" .. i][j]
							item.numType = config["numType" .. i]

							break
						end
					end

					if itemData then
						item.shortName = itemData.itemName
						item.shortDesc = itemData.funcRep
					end

					applyReserved(item)

					if not itemIdCheck[item.id] then
						items[#items + 1] = item
						itemIdCheck[item.id] = true
					end
				end
			end
		end
	end

	return items
end

function PropSelectComModel:findValueRange(value)
	for key, v in pairs(TributeValueRangeData) do
		if value >= v.valueStage[1] and value <= v.valueStage[2] then
			return key, v
		end
	end
end

function PropSelectComModel:countItemRMBValue(itemId, itemCount)
	local cData = LeylineFlowerTributeData[itemId]
	local value = cData and itemCount > 0 and (cData.value or 0) * itemCount or 0
	local _, range = self:findValueRange(value)

	range = range or TributeValueRangeData[1]

	local rating = range and pg.getLocalizationText(range.valueName)
	local text = string.format(pg.getGameString("LEYLINEFLOWER_PROP_TIP"), rating)

	return text, value
end

function PropSelectComModel:checkNumValuePageState(numValue)
	local key = self:findValueRange(numValue)

	return key or 0
end

function PropSelectComModel:getTabInfo(configId)
	local configGroup = ItemSelectData[configId]
	local group = configGroup.group
	local tabConfigs = ItemSelectTabData[group]
	local ret = {}

	for tabIndex, v in pairs(tabConfigs) do
		ret[tabIndex] = {
			icon = v.icon,
			index = tabIndex,
			configId = configId
		}
	end

	return ret
end

return PropSelectComModel
