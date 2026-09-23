-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NourishTribute\\NourishTributeModel.lua

local Class = require("Core.Framework.Class")
local PropSelectComModel = require("Guis.Panels.PropSelectCom.PropSelectComModel")
local ItemSelectData = require("Data.item_select_data")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NourishTributeModel = Class.LightClass("NourishTributeModel", PropSelectComModel)
local FIXED_COST_NUM_TYPE = 1

local function getSortedTabIndices(tabInfos)
	local tabIndices = {}

	for tabIndex in pairs(tabInfos) do
		tabIndices[#tabIndices + 1] = tabIndex
	end

	table.sort(tabIndices)

	return tabIndices
end

function NourishTributeModel:getSelectorTitle(configId)
	local config = ItemSelectData[configId]

	return config and config.title
end

function NourishTributeModel:getDirectionalItems(configId, blockId)
	local result = {}
	local added = {}
	local areaEthnicGroups = LeylineFlowerUtils.getAreaEthnicGroups(blockId)
	local tabInfos = self:getTabInfo(configId)

	for _, tabIndex in ipairs(getSortedTabIndices(tabInfos)) do
		local items = self:buildPropInfos(configId, tabIndex, true)

		for _, item in ipairs(items) do
			local isTurboRefreshTribute = LeylineFlowerUtils.isTurboRefreshTribute(item.id)
			local ethnicGroups

			if isTurboRefreshTribute then
				ethnicGroups = LeylineFlowerUtils.getTributeEthnicGroups(item.id)
			else
				ethnicGroups = LeylineFlowerUtils.filterEthnicGroupsByArea(LeylineFlowerUtils.getTributeEthnicGroups(item.id), areaEthnicGroups)
			end

			if item.numType == FIXED_COST_NUM_TYPE and (isTurboRefreshTribute or #ethnicGroups > 0) and not added[item.id] then
				item.ethnicGroups = ethnicGroups
				result[#result + 1] = item
				added[item.id] = true
			end
		end
	end

	return result
end

function NourishTributeModel:getAttractedPets(item)
	return LuaUIUtils.getEthnicGroupPetData(item.ethnicGroups)
end

return NourishTributeModel
