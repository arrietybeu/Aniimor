-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalitySettlement\\VitalitySettlementModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetData = require("Data.pet_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local PetAccessoryTransformData = require("Data.pet_accessory_transform_data")
local VitalitySettlementModel = Class.LightClass("VitalitySettlementModel", UIModel)

function VitalitySettlementModel:getScoreListData()
	local phase, day = ActivityUtils.getNewEnergyTheme(pg.me)
	local themeId = ActivityUtils.getEnergyThemeId(pg.me)
	local themeData = EnergyMatchThemeData[phase] and EnergyMatchThemeData[phase][themeId] or {}
	local listData = {}

	for i, info in ipairs(themeData.award or EMPTY_TABLE) do
		local data = {}

		data.index = i
		data.showVX = false
		data.score = info[1]

		table.insert(listData, data)
	end

	table.sort(listData, function(a, b)
		return (a.score or 0) < (b.score or 0)
	end)

	return listData
end

function VitalitySettlementModel:setPetProId(petId)
	local pInfo = pg.me:getPetInfo(petId)

	self.adjustPetCurId = petId
	self.adjustPetProId = pInfo.petPrototypeId

	local res = {
		scale = 1,
		offset = {}
	}
	local cData = PetAccessoryTransformData[pInfo.templateId]

	if cData and cData.modelPos and #cData.modelPos >= 3 then
		res.offset = Vector3.New(cData.modelPos[1], cData.modelPos[2], cData.modelPos[3])
		res.scale = cData.scale or 1
	else
		res.offset = Vector3.constZero
	end

	return res
end

function VitalitySettlementModel:parseDefaultAccessInfo(curTemplateId, accessoryId, sliderInfo)
	local refId = PetData[curTemplateId].refId or curTemplateId
	local resTb

	if curTemplateId and accessoryId then
		local t = pgUtils.GetAccessoryConfigFromLocal(curTemplateId, accessoryId)

		t = t or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)

		if t then
			resTb = t
		end
	end

	resTb = resTb or {
		accessoryId = accessoryId,
		resId = AppearanceJewelryPetData[accessoryId].res,
		localPosition = sliderInfo.defaultPos,
		localRotation = Vector3.zero,
		scale = sliderInfo.defaultAccessScale
	}

	return resTb
end

function VitalitySettlementModel:clearCacheData()
	self.adjustPetProId = nil
	self.adjustPetCurId = nil
end

return VitalitySettlementModel
