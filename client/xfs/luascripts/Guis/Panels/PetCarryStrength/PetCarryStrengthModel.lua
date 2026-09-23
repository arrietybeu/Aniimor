-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrength\\PetCarryStrengthModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryStrengthModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetCarryStrengthModel = Class.LightClass("PetCarryStrengthModel", UIModel)
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemData = require("Data.item_data")
local Lume = require("Core.Common.lume")
local CarryStrengthChecker = require("Guis.Panels.PetCarryStrength.Helper.CarryStrengthChecker")
local CoreCarryLevelData = require("Data.core_carry_level_data")
local Utils = require("Common.Utils.Utils")
local CoreCarryData = require("Data.core_carry_data")
local PetConfigData = require("Data.pet_config_data")

PetCarryStrengthModel.CARRY_STRENGTH_FILTER = {
	"EPIC_FOLLOWING_MATERIAL",
	"LEGEND_FOLLOWING_MATERIAL",
	"RARE_FOLLOWING_MATERIAL"
}
PetCarryStrengthModel.CARRY_STRENGTH_FILTER_QUALITY = {
	5,
	4,
	3
}
PetCarryStrengthModel.FILTER_QUALITY_MAP = {
	5,
	4,
	3
}
PetCarryStrengthModel.CARRY_STRENGTH_SORT = {
	"DEFAULT_SORT",
	"QUALITY",
	"STRENGTH_LEVEL"
}

function PetCarryStrengthModel:ctor()
	self.expItems = {}

	if PetConfigData.coreCarryExpItem and next(PetConfigData.coreCarryExpItem) then
		for i, v in ipairs(PetConfigData.coreCarryExpItem) do
			self.expItems[v] = 1
		end
	end
end

function PetCarryStrengthModel:setStrengthCarry(strengthCarry)
	self.strengthCarry = strengthCarry
end

function PetCarryStrengthModel:getCarrySortOptions()
	local options = {}

	for idx, sortDesc in ipairs(self.CARRY_STRENGTH_SORT) do
		options[idx] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return options
end

function PetCarryStrengthModel:setSortOption(optionIdx)
	self.sortOptionIdx = optionIdx
end

function PetCarryStrengthModel:getSortOption()
	return self.sortOptionIdx or 0
end

function PetCarryStrengthModel:switchSortAscending()
	self.sortAscending = not self.sortAscending
end

function PetCarryStrengthModel:getSortAscending()
	return self.sortAscending
end

function PetCarryStrengthModel:getCarryFilterOptions()
	local options = {}

	for idx, sortDesc in ipairs(self.CARRY_STRENGTH_FILTER) do
		options[idx] = {
			sortId = idx,
			label = pg.getGameString(sortDesc),
			quality = self.CARRY_STRENGTH_FILTER_QUALITY[idx]
		}
	end

	return options
end

function PetCarryStrengthModel:setFilterOption(optionIdx)
	self.filterOptionIdx = optionIdx
end

function PetCarryStrengthModel:getFilterOption()
	return self.filterOptionIdx or 2
end

function PetCarryStrengthModel:getCarryDataList()
	local familyId = self.strengthCarry.familyId or 0
	local curGenID = self.strengthCarry.genID or 0
	local sortType = self:getSortOption() + 1
	local selected = {}

	if self.carryDataList then
		for _, v in ipairs(self.carryDataList) do
			if v.selectedAsExp then
				local sid = v.type == ItemConst.ITEM_TYPE.CoreCarryCost and v.itemId or v.genID
				local sinfo = v.type == ItemConst.ITEM_TYPE.CoreCarryCost and v.selectedNum or v.invId

				selected[sid] = sinfo
			end
		end
	end

	self.carryDataList = {}

	local expItem = PetConfigData.coreCarryExpItem

	if expItem and next(expItem) then
		local expItemCfg = ItemData[expItem[1]]

		if expItemCfg then
			local bag = ItemUtils.getTypedBag(pg.me, expItemCfg.invId) or {}

			if bag.count > 0 then
				for genId, item in bag:items() do
					if self.expItems[item.id] then
						local expData = {
							itemId = item.id,
							invId = item.invId,
							genID = item.genID
						}

						LuaUIUtils.parseItemCfgData(expData)

						expData.selectedNum = selected[item.id] or 0
						expData.selectedAsExp = selected[item.id] and true or false

						table.insert(self.carryDataList, expData)
					end
				end
			end
		end
	end

	local getCarryDataList = pg.global.ui.petTrainingNew.model:getCarryPropList(function(item)
		local cData = ItemData[item.id]

		if cData == nil or cData.type ~= ItemConst.ITEM_TYPE_CARRY_CORE then
			return false
		end

		if CoreCarryData[item.id] == nil or CoreCarryData[item.id].familyId ~= familyId then
			return false
		end

		if curGenID == item.genID then
			return false
		end

		return true
	end, function(a, b)
		if sortType == 1 then
			if self.sortAscending then
				return a.index < b.index
			else
				return a.index > b.index
			end
		elseif sortType == 2 then
			if self.sortAscending then
				return a.quality < b.quality
			else
				return a.quality > b.quality
			end
		elseif sortType == 3 then
			if self.sortAscending then
				return a.cLevel < b.cLevel
			else
				return a.cLevel > b.cLevel
			end
		else
			return false
		end
	end, function(data)
		local notEquipped = not data.isEquipped

		if notEquipped then
			data.selectedAsExp = selected[data.genID] ~= nil
		end

		return notEquipped
	end)

	if getCarryDataList and next(getCarryDataList) then
		for i, v in ipairs(getCarryDataList) do
			table.insert(self.carryDataList, v)
		end
	end

	return self.carryDataList
end

function PetCarryStrengthModel:autoSelectedCarries(item)
	if self.carryDataList == nil then
		self:getCarryDataList()
	end

	local isClear = false

	for _, v in ipairs(self.carryDataList) do
		if v.selectedAsExp then
			isClear = true
		end

		v.selectedAsExp = false
	end

	if isClear then
		return
	end

	local filterOption = self:getFilterOption() + 1
	local quality = self.FILTER_QUALITY_MAP[filterOption]
	local res = Lume.ifilter(self.carryDataList, function(data)
		return not data.isLocked and data.quality <= quality
	end)

	table.sort(res, function(a, b)
		local isExpA = self.expItems[a.itemId] ~= nil
		local isExpB = self.expItems[b.itemId] ~= nil

		if isExpA ~= isExpB then
			return isExpA
		end

		if isExpA then
			if a.itemId ~= b.itemId then
				return a.itemId < b.itemId
			end

			return (a.genID or 0) < (b.genID or 0)
		end

		local qualityA, qualityB = a.quality or 0, b.quality or 0

		if qualityA ~= qualityB then
			return qualityA < qualityB
		end

		local levelA, levelB = a.cLevel or 0, b.cLevel or 0

		if levelA ~= levelB then
			return levelA < levelB
		end

		return (a.genID or 0) < (b.genID or 0)
	end)
	CarryStrengthChecker.autoAddCarries(item, res)
end

function PetCarryStrengthModel:getSelectedCarries()
	local res = {}
	local dataList = self.carryDataList or {}

	for _, v in ipairs(dataList) do
		if v.selectedAsExp then
			res[#res + 1] = v
			v.tIndex = 0
		end
	end

	local selectCount = #res

	if selectCount < 6 then
		for _ = 1, 6 - selectCount do
			res[#res + 1] = {
				isEmpty = true,
				tIndex = 1
			}
		end
	end

	return res
end

function PetCarryStrengthModel:getConsumeDataList()
	local carryDataList = self.carryDataList or {}
	local containHighLv = false
	local dataList = {}
	local expItemList = {}

	for _, v in ipairs(carryDataList) do
		if v.selectedAsExp then
			if v.selectedNum and v.selectedNum ~= 0 then
				expItemList[v.itemId] = v.selectedNum
			else
				dataList[#dataList + 1] = {
					v.invId,
					v.genID
				}

				if v.cLevel and v.cLevel > 0 then
					containHighLv = true
				end
			end
		end
	end

	return dataList, expItemList, containHighLv
end

function PetCarryStrengthModel:getPropertyUpInfo(carryData, newLv, assistAdd)
	local isNewLv = newLv > carryData.cLevel
	local cData = CoreCarryLevelData[newLv]
	local enhanceRatio = cData and cData.enhanceRatio or 0
	local carryAttrs = {}

	if assistAdd ~= nil and assistAdd ~= 0 then
		table.insert(carryAttrs, {
			tIndex = 1,
			assistAdd = assistAdd
		})
	end

	local attrList = carryData.mainProperties

	for i, v in ipairs(attrList) do
		local item = {
			tIndex = 0
		}

		table.merge(item, v)
		table.insert(carryAttrs, item)

		if isNewLv then
			if item.value < 0 then
				item.nValue = (1 - enhanceRatio) * item.value
			else
				item.nValue = (1 + enhanceRatio) * item.value
			end

			item.nDesc = Utils.formatAttrDesc(item.nValue, 1, true)
		else
			item.nDesc = ""
		end
	end

	return carryAttrs
end

function PetCarryStrengthModel:overrideCarryData(data)
	pg.global.ui.petTrainingNew.model:overrideCarryFullInfo(data)
end

function PetCarryStrengthModel:clearData()
	self.carryDataList = nil
end

return PetCarryStrengthModel
