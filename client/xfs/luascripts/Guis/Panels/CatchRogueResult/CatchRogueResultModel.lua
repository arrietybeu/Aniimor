-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueResult\\CatchRogueResultModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueResultModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local PetPrototypeData = require("Data.pet_prototype_data")
local PetConfigData = require("Data.pet_config_data")
local ElementNameToId = require("Data.element_name_to_id")
local PetData = require("Data.pet_data")
local CatchRogueResultModel = Class.LightClass("CatchRogueResultModel", UIModel)
local Const = require("Common.Const.Const")

function CatchRogueResultModel:getCatchRogueResult()
	if not pg.me or not pg.me.catchRogueInfo then
		return false
	end

	local catchRogueInfo = pg.me.catchRogueInfo
	local success = catchRogueInfo:isTopFloor(catchRogueInfo:getCurSettleFloorCount())

	return success
end

function CatchRogueResultModel:getCatchPetList()
	if not pg.me or not pg.me.catchRogueInfo then
		return {}
	end

	local result = {}
	local petIndexMap = {}
	local curCatchPetList = pg.me:getCurCatchRoguePetList()

	for i = 1, #curCatchPetList do
		local pet = curCatchPetList[i]
		local petInfo = self:generatePetInfo(pet)
		local templateId = petInfo.templateId
		local index = petIndexMap[templateId]
		local isShowRareVfx = Utils.matchFormTypeByTempId(templateId, {
			Const.FormName2Id.rainbow,
			Const.FormName2Id.thunderstorm,
			Const.FormName2Id.snow
		})

		petInfo.showRareVfx = isShowRareVfx

		if index then
			result[index].num = result[index].num + 1
		else
			petInfo.num = 1
			petIndexMap[templateId] = #result + 1
			result[#result + 1] = petInfo
		end
	end

	return result
end

function CatchRogueResultModel:generatePetInfo(pet)
	local petInfo = pet:getRawTable()
	local pData = PetData[pet.templateId] or {}

	petInfo.id = pet.id
	petInfo.templateId = pet.templateId
	petInfo.gender = pet.gender
	petInfo.name = LuaUIUtils.getPetNameByPetInfo(pet)
	petInfo.iconName = pData.iconName
	petInfo.cp = pet and pet:getCpValue() or 0
	petInfo.label = pet.label
	petInfo.isShiny = Utils.isLabelShiny(pet.label)
	petInfo.isVariant = Utils.isLabelVariant(pet.label)

	local petPrototypeId = Utils.getPetPetPrototypeId(pet.templateId)
	local prototypeData = PetPrototypeData[petPrototypeId] or {}
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.level = pet.level

	local petType = PetData[pet.templateId].functionId

	petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]

	return petInfo
end

return CatchRogueResultModel
