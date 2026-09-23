-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryItemUse\\InventoryItemUseModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InventoryItemUseModel = Class.LightClass("InventoryItemUseModel", UIModel)
local ItemEffectData = require("Data.item_effect_data")
local ItemData = require("Data.item_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetLevelData = require("Data.pet_level_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")

function InventoryItemUseModel:getPetDataList(petId)
	local groupId = self.selectGroupId

	groupId = groupId or pg.me.curPetFormationIndex

	local petInfos = pg.global.ui.petManagement.model:getGroupInfoById(groupId)
	local index = 1

	for i, v in ipairs(petInfos) do
		if v.id == petId then
			index = i

			break
		end
	end

	return petInfos, index
end

function InventoryItemUseModel:getExpPropDataList(itemId)
	local dataList = {}

	for id, v in pairs(ItemEffectData) do
		if v.sType == 1 then
			local cData = ItemData[id]
			local res = {
				id = id,
				icon = cData.icon,
				ownNum = ItemUtils.getItemCountById(pg.me, id),
				quality = cData.quality
			}

			dataList[#dataList + 1] = res
		end
	end

	table.sort(dataList, function(a, b)
		return a.id < b.id
	end)

	local index = 1

	for i, v in ipairs(dataList) do
		if v.id == itemId then
			index = i

			break
		end
	end

	return dataList, index
end

function InventoryItemUseModel:getPetBaseInfo(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return 0, 0
	end

	local res = {
		maxExp = 0,
		curLv = petInfo.level,
		curExp = petInfo.exp
	}
	local cData = PetLevelData[res.curLv + 1]

	if cData then
		res.maxExp = cData.needExp
	end

	cData = PetData[petInfo.templateId] or {}

	if cData then
		res.icon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
	end

	return res
end

function InventoryItemUseModel:checkCanUpgrade(petId)
	local me = pg.me
	local petInfo = me:getPetInfo(petId)

	if petInfo == nil then
		return false
	end

	return petInfo.level < pg.me:getMaxControlLevel()
end

return InventoryItemUseModel
