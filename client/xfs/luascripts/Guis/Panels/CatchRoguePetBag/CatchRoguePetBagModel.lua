-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRoguePetBag\\CatchRoguePetBagModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRoguePetBagModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local PetNatureData = require("Data.pet_nature_data")
local ElementNameToId = require("Data.element_name_to_id")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CatchRoguePetBagModel = Class.LightClass("CatchRoguePetBagModel", UIModel)

function CatchRoguePetBagModel:getPetListInfo()
	local curCatchPetList = pg.me:getCurCatchRoguePetList()
	local result = {}

	for i = 1, #curCatchPetList do
		local pet = curCatchPetList[i]
		local petInfo = self:generatePetInfo(pet)

		result[#result + 1] = petInfo
	end

	return result
end

function CatchRoguePetBagModel:generatePetInfo(pet)
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
	petInfo.isBoss = Utils.isLabelElite(pet.label)
	petInfo.isMini = Utils.isLabelRainbow(pet.label)
	petInfo.bodySizeType = pet.bodySizeType

	local prototypeData = PetProtoTypeData[pet.templateId]
	local elementType = prototypeData.elementType or {}
	local elementIds, elementNames = LuaUIUtils.getElementInfo(pData.elementType, ElementNameToId[elementType[1]])

	petInfo.elementIds = elementIds
	petInfo.elementNames = elementNames
	petInfo.level = pet.level

	local petType = PetData[pet.templateId].functionId

	petInfo.petTypeUrl = PetConfigData.petFunctionIcon[petType]

	return petInfo
end

return CatchRoguePetBagModel
