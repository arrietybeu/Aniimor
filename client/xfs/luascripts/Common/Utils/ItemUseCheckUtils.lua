-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ItemUseCheckUtils.lua

local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local NoticeDef = require("Common.NoticeDef")
local PetConfigData = require("Data.pet_config_data")
local ItemUseCheckUtils = {}

function ItemUseCheckUtils.check_propertyEnhance(petInfo, confirmEnhance, confirmAdjust)
	if not petInfo then
		return false, NoticeDef.ERROR_CLIENT_PARAM
	end

	local configData = petInfo:getConfigData()

	if not configData then
		return false, NoticeDef.ERROR_CONFIG_NIL
	end

	local maxPropertyEnhancedCount = PetConfigData.PET_PROPENHANCE_MAX_COUNT or 2
	local propertyEnhancedCount = Utils.getPetPropertyEnhancedCount(petInfo)

	if maxPropertyEnhancedCount <= propertyEnhancedCount then
		return false, NoticeDef.ERROR_ALREADY_ENHANCED
	end

	local maxEnhance = PetConfigData.individualPropEnhanceMax

	if not maxEnhance then
		return false, NoticeDef.ERROR_CONFIG_HAS_ERROR
	end

	local allMaxEnhanced, hasMaxEnhanced, hasTotalMaxLevel = true, false, false

	for index = 1, Const.BASE_PROPERTY_CNT do
		local baseProp = petInfo.basePropertyList[index]

		if not baseProp then
			return false, NoticeDef.ERROR_CONFIG_HAS_ERROR
		end

		if maxEnhance <= baseProp:getBaseIndividualLevel() then
			hasMaxEnhanced = true
		else
			allMaxEnhanced = false
		end

		local individualLevelMax = Utils.getBaseIndividualLevelMax(index, petInfo:getConfigData())

		if individualLevelMax <= baseProp.indLv then
			hasTotalMaxLevel = true
		end
	end

	if allMaxEnhanced then
		return false, NoticeDef.ERROR_ALL_MAX_ENHANCED
	end

	if hasMaxEnhanced and not confirmEnhance then
		return false, NoticeDef.ERROR_HAS_MAX_ENHANCED
	end

	if hasTotalMaxLevel and not confirmAdjust then
		return false, NoticeDef.ERROR_PROP_TOTAL_MAX_LEVEL
	end

	return true
end

return ItemUseCheckUtils
