-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeFormSmall\\PetChangeFormSmallModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetChangeFormSmallModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetFormChangeData = require("Data.pet_form_change_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local PetEvolveItemSubData = require("Data.pet_evolve_item_sub_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetChangeFormSmallModel = Class.LightClass("PetChangeFormSmallModel", UIModel)

function PetChangeFormSmallModel:getNeedItemByTemplateId(templateId)
	local petFormChangeInfo = PetFormChangeData[templateId]

	if not petFormChangeInfo then
		return
	end

	local itemId = petFormChangeInfo.needItem and petFormChangeInfo.needItem[1]
	local needNum = petFormChangeInfo.needItem and petFormChangeInfo.needItem[2]
	local itemInfo = LuaUIUtils.getItemInfoById(itemId)

	itemInfo.needNum = needNum

	local altData = PetEvolveItemSubData[itemId]

	if altData and altData.alternativeItem then
		itemInfo.altOwnNum = math.ceil(ItemUtils.getItemCountById(pg.me, altData.alternativeItem, true) * altData.alternativeItemNum / altData.num)
	else
		itemInfo.altOwnNum = 0
	end

	itemInfo.res = itemInfo.ownNum + itemInfo.altOwnNum >= itemInfo.needNum

	return itemInfo
end

function PetChangeFormSmallModel:getRealCostData(templateId)
	local petFormChangeInfo = PetFormChangeData[templateId]

	if not petFormChangeInfo then
		return false
	end

	local itemId = petFormChangeInfo.needItem and petFormChangeInfo.needItem[1]
	local needNum = petFormChangeInfo.needItem and petFormChangeInfo.needItem[2]
	local res, resIdNumDict = ItemUtils.getChangeFormNeedItemResult(pg.me, {
		itemId,
		needNum
	})
	local resList = {}

	if res then
		for resItemId, count in pairs(resIdNumDict) do
			resList[#resList + 1] = {
				resItemId,
				count
			}
		end
	end

	return res, resIdNumDict, resList
end

function PetChangeFormSmallModel:getIsCatched(templateId)
	if pg.me then
		local handbookMap = pg.me.petHandbookMap

		if handbookMap then
			return handbookMap:isCatched(templateId, Const.GROUP_TYPE_SELF)
		end
	end

	return false
end

function PetChangeFormSmallModel:getAllTargetInfo(fromTemplateId)
	local baseId = Utils.getBasePetPrototypeId(fromTemplateId)
	local ids = PetBasePrototypeToPrototypeMap[baseId] or {}
	local targetInfoList = {}

	for index, id in ipairs(ids) do
		if id ~= fromTemplateId and PetFormChangeData[id] then
			local puppetInfo = {}

			puppetInfo.templateId = id
			puppetInfo.isCatched = self:getIsCatched(id)

			local pData = PetData[id] or {}

			puppetInfo.iconName = pData.iconName
			puppetInfo.name = pData.name

			table.insert(targetInfoList, puppetInfo)
		end
	end

	table.sort(targetInfoList, function(a, b)
		if a.isCatched ~= b.isCatched then
			return a.isCatched
		else
			return a.templateId < b.templateId
		end
	end)

	return targetInfoList
end

function PetChangeFormSmallModel:getPetDataList(petId)
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

return PetChangeFormSmallModel
