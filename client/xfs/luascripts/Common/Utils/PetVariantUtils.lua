-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PetVariantUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local lume = require("Core.Common.lume")
local Const = require("Common.Const.Const")
local FriendshipLevelData = require("Data.friendship_level_data")
local SysConfigData = require("Data.sys_config_data")
local PetVariantUtils = {}
local bit = bit

function PetVariantUtils.genVariantInfo(petInfoDict, isVariantFriend, friendshipLevel, randomFunc)
	local variantInfo = {
		isVariant = false,
		individualLevelUpMap = {}
	}
	local fldd = FriendshipLevelData[friendshipLevel]

	if fldd == nil then
		return variantInfo, false
	end

	randomFunc = randomFunc or math.random

	local needVariant = isVariantFriend or randomFunc() < (fldd.changeRate or 0)
	local randCountWeightTable, randIndexWeightTable

	if needVariant then
		variantInfo.isVariant = true
		randCountWeightTable, randIndexWeightTable = fldd.changeAdd or {}, fldd.changeAddIv or {}
	else
		randCountWeightTable, randIndexWeightTable = fldd.notChangeAdd or {}, fldd.notChangeAddIv or {}
	end

	local individualLevelUpMap = variantInfo.individualLevelUpMap
	local randCount = lume.weightedchoice(randCountWeightTable)

	for i = 1, randCount or 0 do
		local realIndexWeightTable = {}

		for index, weight in pairs(randIndexWeightTable) do
			local baseProp = petInfoDict.basePropertyList and petInfoDict.basePropertyList[index]
			local valid = true

			if baseProp == nil then
				valid = false
			else
				local baseLevel = (baseProp.indLv or 0) - (baseProp.iLvLn or 0)

				if baseLevel >= (SysConfigData.CHANGE_PET_IV_MAX or 0) then
					valid = false
				end
			end

			if valid then
				realIndexWeightTable[index] = weight
			end
		end

		local randIndex = lume.weightedchoice(realIndexWeightTable)

		if randIndex then
			individualLevelUpMap[randIndex] = (individualLevelUpMap[randIndex] or 0) + 1
		end
	end

	return variantInfo, true
end

function PetVariantUtils.captureIndividualLevelMap(petInfoDict, variantInfo)
	local levelMap = {}

	if not petInfoDict or not variantInfo then
		return levelMap
	end

	for index in pairs(variantInfo.individualLevelUpMap or EMPTY_TABLE) do
		local propIndex = tonumber(index)
		local baseProp = propIndex and petInfoDict.basePropertyList and petInfoDict.basePropertyList[propIndex]

		if baseProp then
			levelMap[propIndex] = baseProp.indLv or 0
		end
	end

	return levelMap
end

function PetVariantUtils.applyVariantInfo(petInfoDict, variantInfo, baseIndividualLevelMap)
	if not petInfoDict or not variantInfo then
		return
	end

	if variantInfo.isVariant then
		petInfoDict.label = bit.bor(petInfoDict.label or 0, Const.PET_LABEL_MASK.VARIANT)
	end

	local normalizedMap = {}

	for index, count in pairs(variantInfo.individualLevelUpMap or EMPTY_TABLE) do
		local propIndex = tonumber(index)
		local upCount = tonumber(count) or 0

		if propIndex and upCount ~= 0 then
			normalizedMap[propIndex] = (normalizedMap[propIndex] or 0) + upCount

			local baseProp = petInfoDict.basePropertyList and petInfoDict.basePropertyList[propIndex]

			if baseProp then
				local baseLevel = baseIndividualLevelMap and baseIndividualLevelMap[propIndex]

				if baseLevel ~= nil then
					baseProp.indLv = baseLevel + upCount
				else
					baseProp.indLv = (baseProp.indLv or 0) + upCount
				end
			end
		end
	end

	variantInfo.individualLevelUpMap = normalizedMap
end

return PetVariantUtils
