-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementReleaseReview\\PetManagementReleaseReviewModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ItemData = require("Data.item_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local PetManagementReleaseReviewModel = Class.LightClass("PetManagementReleaseReviewModel", UIModel)

function PetManagementReleaseReviewModel:getPetInfos(releasePetIds)
	local ret = {}

	for petId, _ in pairs(releasePetIds) do
		ret[#ret + 1] = PetManagementDataHelper.setUpPetInfo(pg.me:getPetInfo(petId))
	end

	local sortKey = {
		"labelScore",
		"hasRareFeature",
		"cp",
		"rating",
		"level",
		"reverseTime"
	}

	PetManagementDataHelper.templateFun(ret, false, table.unpack(sortKey))

	return ret
end

function PetManagementReleaseReviewModel:parsePropData(data)
	local res = {}

	if data == nil or #data == 0 then
		return res
	end

	local me = pg.me

	for i, v in ipairs(data) do
		local item = {
			id = v[1],
			num = v[2]
		}
		local iData = ItemData[item.id]

		if iData then
			item.name = iData.itemName
			item.icon = LuaUIUtils.getIconByIconId(iData.icon)
			item.quality = iData.quality
			item.ownNum = v.ownNum or ItemUtils.getItemCountById(me, item.id)
			item.hideOwnNum = v.hideOwnNum
		end

		res[i] = item
	end

	return res
end

return PetManagementReleaseReviewModel
