-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryAssistStrength\\PetCarryAssistStrengthModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryAssistStrengthModel")
local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local UIModel = require("Guis.UIModel")
local ItemConst = require("Common.Const.ItemConst")
local PetConfigData = require("Data.pet_config_data")
local ItemData = require("Data.item_data")
local AssistCarryData = require("Data.assist_carry_data")
local PetCarryAssistStrengthModel = Class.LightClass("PetCarryAssistStrengthModel", UIModel)

PetCarryAssistStrengthModel.CARRY_ASSIST_STRENGTH_TYPE = {
	"PET_EQUIPMENT_GEM_UPGRADE_TAB_1",
	"PET_EQUIPMENT_GEM_UPGRADE_TAB_2",
	"PET_EQUIPMENT_GEM_UPGRADE_TAB_3"
}
PetCarryAssistStrengthModel.CARRY_ASSIST_STRENGTH_SORT = {
	"PET_EQUIPMENT_GEM_SORT_1",
	"PET_EQUIPMENT_GEM_SORT_2",
	"PET_EQUIPMENT_GEM_SORT_3"
}

function PetCarryAssistStrengthModel:setSortOption(optionIdx)
	self.sortOptionIdx = optionIdx
end

function PetCarryAssistStrengthModel:getSortOption()
	return self.sortOptionIdx or 0
end

function PetCarryAssistStrengthModel:getCarrySortOptions()
	local options = {}

	for idx, sortDesc in ipairs(self.CARRY_ASSIST_STRENGTH_SORT) do
		options[idx] = {
			sortId = idx,
			label = pg.getGameString(sortDesc)
		}
	end

	return options
end

function PetCarryAssistStrengthModel:getCarryStrengthTypes()
	local types = {}

	for idx, sortDesc in ipairs(self.CARRY_ASSIST_STRENGTH_TYPE) do
		types[idx] = {
			label = pg.getGameString(sortDesc),
			type = idx + 1,
			quality = idx + 2
		}
	end

	return types
end

function PetCarryAssistStrengthModel:switchSortAscending()
	self.sortAscending = not self.sortAscending
end

function PetCarryAssistStrengthModel:getSortAscending()
	return self.sortAscending
end

function PetCarryAssistStrengthModel:setStrengthType(type)
	self.strengthType = type
end

function PetCarryAssistStrengthModel:getStrengthType()
	return self.strengthType or 2
end

function PetCarryAssistStrengthModel:setAssistTypeOption(assistType)
	self.assistTab = assistType
end

function PetCarryAssistStrengthModel:getAssistTypeOption()
	return self.assistTab or 1
end

function PetCarryAssistStrengthModel:getSelectedCarries()
	if not self.carrySelectList then
		self.carrySelectList = {}

		for i = 1, PetConfigData.upgradeQualityNeedGemsNum do
			self.carrySelectList[i] = {
				index = i
			}
		end
	end

	return self.carrySelectList
end

function PetCarryAssistStrengthModel:canAddSelectedCarries()
	local index = 0

	for _, v in ipairs(self.carrySelectList) do
		if v.carryData then
			index = index + 1
		end
	end

	return index < PetConfigData.upgradeQualityNeedGemsNum
end

function PetCarryAssistStrengthModel:getAddSelectedCarries()
	local count = 0

	for _, v in ipairs(self.carrySelectList) do
		if v.carryData then
			count = count + 1
		end
	end

	return count, PetConfigData.upgradeQualityNeedGemsNum
end

function PetCarryAssistStrengthModel:setSelectedIndex(index)
	self.selectIndex = index
end

function PetCarryAssistStrengthModel:setSelected(isSelect, data, selectIndex)
	if self.carryDataList then
		for _, v in ipairs(self.carryDataList) do
			if v.invId == data.invId and v.genID == data.genID then
				v.selectedAsExp = isSelect

				if isSelect then
					if self.selectIndex then
						self.carrySelectList[self.selectIndex].carryData = v
					else
						for _, sItem in ipairs(self.carrySelectList) do
							if not sItem.carryData then
								sItem.carryData = v

								return
							end
						end
					end
				elseif selectIndex then
					self.carrySelectList[selectIndex].carryData = nil
				else
					for _, sItem in ipairs(self.carrySelectList) do
						if sItem.carryData and sItem.carryData.invId == data.invId and sItem.carryData.genID == data.genID then
							sItem.carryData = nil

							return
						end
					end
				end
			end
		end
	end

	self.selectIndex = nil
end

function PetCarryAssistStrengthModel:clearSelectedCarries()
	local isSelect = false

	if self.carryDataList and next(self.carryDataList) then
		for _, v in ipairs(self.carryDataList) do
			if v.selectedAsExp then
				v.selectedAsExp = false
				isSelect = true
			end
		end
	end

	for i = 1, PetConfigData.upgradeQualityNeedGemsNum do
		if self.carrySelectList[i].carryData then
			self.carrySelectList[i].carryData = nil
		end
	end

	self.selectIndex = nil

	return isSelect
end

function PetCarryAssistStrengthModel:onCompoundAssist()
	for _, v in ipairs(self.carrySelectList) do
		if v.carryData then
			v.carryData = nil
		end
	end

	self.selectIndex = nil
end

function PetCarryAssistStrengthModel:autoSelectedCarries()
	if self.carryDataList == nil then
		self:getCarryDataList()
	end

	local isSelect = self:clearSelectedCarries()

	if isSelect then
		return
	end

	local strengthType = self:getStrengthType()
	local dataList = Lume.ifilter(self.carryDataList, function(data)
		return not data.isLocked and data.quality == strengthType
	end)

	table.sort(dataList, function(a, b)
		if a.cpValue < b.cpValue then
			return true
		end
	end)

	local sIndex = 0

	for _, v in ipairs(dataList) do
		if sIndex >= PetConfigData.upgradeQualityNeedGemsNum then
			return
		end

		v.selectedAsExp = true
		sIndex = sIndex + 1
		self.carrySelectList[sIndex].carryData = v
	end

	self.selectIndex = nil
end

function PetCarryAssistStrengthModel:getCarryDataList()
	local assistTab = self:getAssistTypeOption()
	local strengthType = self:getStrengthType()
	local sortType = self:getSortOption() + 1
	local selected = {}

	if self.carryDataList then
		for _, v in ipairs(self.carryDataList) do
			if v.selectedAsExp then
				selected[v.genID] = v.invId
			end
		end
	end

	self.carryDataList = pg.global.ui.petTrainingNew.model:getCarryPropList(function(item)
		local cData = ItemData[item.id]

		return cData and cData.type == ItemConst.ITEM_TYPE_CARRY_ASSISTED
	end, function(a, b)
		local sameTypeA = a.quality == strengthType
		local sameTypeB = b.quality == strengthType

		if sameTypeA ~= sameTypeB then
			return sameTypeA and not sameTypeB
		end

		if sortType == 1 then
			if a.cpValue ~= b.cpValue then
				if self.sortAscending then
					return a.cpValue < b.cpValue
				else
					return a.cpValue > b.cpValue
				end
			end
		elseif sortType == 2 then
			if a.quality ~= b.quality then
				if self.sortAscending then
					return a.quality < b.quality
				else
					return a.quality > b.quality
				end
			end
		elseif sortType == 3 and a.familyId ~= b.familyId then
			if self.sortAscending then
				return a.familyId < b.familyId
			else
				return a.familyId > b.familyId
			end
		end

		return false
	end, function(data)
		local notEquipped = not data.isEquipped

		if notEquipped then
			data.selectedAsExp = selected[data.genID] ~= nil
		end

		return notEquipped
	end)

	local showList = {}

	if self.carryDataList and next(self.carryDataList) and self.carryDataList then
		for _, carryData in ipairs(self.carryDataList) do
			if carryData and carryData.assistType == assistTab then
				showList[#showList + 1] = carryData
			end
		end
	end

	return showList
end

function PetCarryAssistStrengthModel:isSameAssist(selectCarries)
	local curReward

	for i, v in ipairs(selectCarries) do
		if v.carryData and next(v.carryData) then
			local aCfg = AssistCarryData[v.carryData.itemId]

			if not curReward then
				curReward = aCfg.upgradeReward
			elseif aCfg.upgradeReward ~= curReward then
				return false
			end
		else
			return false
		end
	end

	if not curReward then
		return false
	end

	local aCfg = AssistCarryData[selectCarries[1].carryData.itemId]

	return true, aCfg.name
end

function PetCarryAssistStrengthModel:overrideCarryData(data)
	pg.global.ui.petTrainingNew.model:overrideCarryFullInfo(data)
end

function PetCarryAssistStrengthModel:clearData()
	self.carrySelectList = nil
	self.carryDataList = nil
end

return PetCarryAssistStrengthModel
