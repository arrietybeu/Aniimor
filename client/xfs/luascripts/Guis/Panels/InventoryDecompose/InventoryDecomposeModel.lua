-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryDecompose\\InventoryDecomposeModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("InventoryDecomposeModel")
local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local InventoryDecomposeModel = Class.LightClass("InventoryDecomposeModel", UIModel)
local ItemData = require("Data.item_data")
local InventoryData = require("Data.inventory_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")

function InventoryDecomposeModel:getResultList(selectedGensTable, propList)
	local t = {}

	for _, v in pairs(propList) do
		local resolveGetItems = ItemData[v.itemId].resolveGetItem

		if resolveGetItems ~= nil then
			for _, vv in pairs(resolveGetItems) do
				local itemId = vv[1]
				local count = vv[2]
				local itemNum = selectedGensTable[v.index] * count

				if (ItemUtils.isEquip(v.itemId) or ItemUtils.isRepairKit(v.itemId)) and v.packSlot then
					itemNum = LuaUIUtils.getPropDecomposeNum(v, count)
				end

				if t[itemId] then
					t[itemId] = t[itemId] + itemNum
				else
					t[itemId] = itemNum
				end
			end
		end
	end

	local tResult = {}

	for k, v in pairs(t) do
		local configData = ItemData[k]

		tResult[#tResult + 1] = {
			itemId = k,
			itemNum = v,
			icon = configData.icon,
			quality = configData.quality
		}
	end

	return tResult
end

function InventoryDecomposeModel:getDecomposeServerList(selectedGensTable, propList)
	local serverList = {}

	for invId, v in pairs(InventoryData) do
		if v.hideInBag ~= 1 then
			local t = {}
			local bag = ItemUtils.getTypedBag(pg.me, invId)

			if bag ~= nil then
				for _, v in ipairs(propList) do
					if v.index then
						t[v.index] = nil

						for k1, v1 in pairs(selectedGensTable) do
							if bag[k1] ~= nil and k1 == v.index then
								t[v.index] = v1
							end
						end
					end
				end
			end

			if Lume.count(t) > 0 then
				serverList[#serverList + 1] = {
					invId,
					t
				}
			end
		end
	end

	return serverList
end

function InventoryDecomposeModel:getFillUIPropList(propList)
	local count = #propList
	local fillCount = 0

	if count < 15 then
		fillCount = 15 - count
	else
		fillCount = 5 - count % 5
	end

	for i = 1, fillCount do
		propList[#propList + 1] = {
			tIndex = 1
		}
	end

	return propList
end

return InventoryDecomposeModel
