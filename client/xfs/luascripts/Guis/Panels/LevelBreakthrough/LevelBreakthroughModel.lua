-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthrough\\LevelBreakthroughModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetData = require("Data.pet_data")
local PetLevelData = require("Data.pet_level_data")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local LevelBreakthroughModel = Class.LightClass("LevelBreakthroughModel", UIModel)

function LevelBreakthroughModel:getPetDetails(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local t = {}
	local pData = PetData[petInfo.templateId] or {}

	t.gender = petInfo.gender
	t.iconName = pData.iconName
	t.id = petInfo.id
	t.templateId = petInfo.templateId
	t.label = petInfo.label
	t.level = petInfo.level

	local _, level = Utils.getPetExpMaxAdd(pg.me, petId)

	t.maxLevel = level

	local nLv = petInfo.level + 1
	local nLvData = PetLevelData[nLv]

	if nLvData then
		t.expRate = petInfo.exp / (nLvData.needExp or 0)
	else
		t.expRate = 0
	end

	t.curExp = petInfo.exp
	t.maxExp = nLvData.needExp or 0

	return t
end

function LevelBreakthroughModel:getNextBreakthroughLevel(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local maxLevel = #PetLevelData
	local nextBreakthroughLevel

	for level = petInfo.level + 1, maxLevel do
		local levelData = PetLevelData[level]

		if levelData.breakthroughItemNums then
			nextBreakthroughLevel = level

			break
		end
	end

	if nextBreakthroughLevel then
		for level = nextBreakthroughLevel + 1, maxLevel do
			local levelData = PetLevelData[level]

			if levelData.breakthroughItemNums then
				return level - 1
			end
		end

		return maxLevel
	end

	return maxLevel
end

function LevelBreakthroughModel:getRequiredItems(petTemplateId, petId)
	local t = {}
	local petInfo = pg.me:getPetInfo(petId)

	if not petId then
		return t
	end

	local refTemplateId = Utils.getRefIdByPetPrototypeId(petTemplateId)

	if not refTemplateId then
		return t
	end

	if not PetData[refTemplateId] then
		return t
	end

	local itemIds = Utils.getBreakthroughItems(petInfo.templateId)

	if not itemIds then
		return t
	end

	local pldNext = PetLevelData[petInfo.level + 1]

	if not pldNext then
		return t
	end

	if not Utils.canLevelBreakthrough(petId) then
		return t
	end

	local success, idNumDict, altIdNumDict, replacedInfo = ItemUtils.getBreakthrouthNeedItemResult(pg.me, itemIds, pldNext.breakthroughItemNums)

	for itmId, itemNum in pairs(idNumDict) do
		local temp = {}

		temp.id = itmId

		local iData = ItemData[itmId]

		temp.name = iData.itemName
		temp.icon = LuaUIUtils.getIconByIconId(iData.icon)
		temp.quality = iData.quality
		temp.ownNum = ItemUtils.getItemCountById(pg.me, itmId)
		temp.requiredNum = itemNum
		temp.isReplace = altIdNumDict[itmId] and true or false
		t[#t + 1] = temp
	end

	return t, success, replacedInfo
end

return LevelBreakthroughModel
