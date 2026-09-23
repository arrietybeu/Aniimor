-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetOverview\\PetOverviewModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetOverviewModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetData = require("Data.pet_data")
local PetOverviewModel = Class.LightClass("PetOverviewModel", UIModel)

function PetOverviewModel.getPetOverviewData(areaId, showTab)
	local petData = PetResearchUtils.tryGetPetInfos(nil, nil, nil, areaId, showTab)
	local ret = {}
	local oneGroup = {
		groupData = {}
	}

	oneGroup.tIndex = 0

	local num = 0
	local maxNum = 9

	for _, value in ipairs(petData) do
		table.insert(oneGroup.groupData, value)

		num = num + 1

		if num == maxNum then
			table.insert(ret, oneGroup)

			oneGroup = {
				groupData = {}
			}
			num = 0
			maxNum = maxNum == 9 and 8 or 9
			oneGroup.tIndex = maxNum == 9 and 0 or 1
		end
	end

	if #oneGroup.groupData > 0 then
		table.insert(ret, oneGroup)
	end

	return ret
end

function PetOverviewModel:getPetIconName(petId)
	if not petId then
		return ""
	end

	local pData = PetData[petId] or {}

	return pData.iconName
end

return PetOverviewModel
