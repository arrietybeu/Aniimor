-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ArkChestRefreshMap.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local lume = require("Core.Common.lume")
local ArkChestRefreshData = require("Data.ark_chest_refresh_data")
local ArkChestRefreshMap = class.LiteClass("ArkChestRefreshMap", CustomDict)
local REFRESH_TYPE_DAILY = 1
local REFRESH_TYPE_WEEKLY = 2
local REFRESH_TYPE_MONTHLY = 3

function ArkChestRefreshMap:isChestInfoRefreshed(configId)
	return self[configId] ~= nil
end

function ArkChestRefreshMap:getChestRefreshInfo(configId)
	return self[configId]
end

function ArkChestRefreshMap:_genRefreshData(posList, cfgData, canRepeat, chestNum)
	chestNum = chestNum or cfgData.chestNum
	canRepeat = canRepeat or cfgData.canRepeat == 1

	local posListCopy = lume.clone(posList or {})

	lume.shuffle(posListCopy)

	local actualNum = math.min(chestNum, #posListCopy)
	local pityNum = 0
	local selectedChestIds = {}

	if cfgData.pityChestNum and cfgData.pityChestId then
		pityNum = math.min(actualNum, cfgData.pityChestNum)

		for i = 1, pityNum do
			selectedChestIds[i] = cfgData.pityChestId[1]
		end
	end

	if canRepeat then
		for i = 1 + pityNum, actualNum do
			selectedChestIds[i] = lume.weightRandomChoiceOne(cfgData.chestList, cfgData.chestRatio)
		end
	else
		local unrepeatNum = math.min(actualNum - pityNum, #cfgData.chestList)

		actualNum = unrepeatNum + pityNum

		lume.appendArray(selectedChestIds, lume.weightRandomChoiceN(cfgData.chestList, cfgData.chestRatio, unrepeatNum))
	end

	local posIds = {}
	local chestIds = {}

	for i = 1, actualNum do
		posIds[i] = posListCopy[i]
		chestIds[i] = selectedChestIds[i]
	end

	return posIds, chestIds
end

function ArkChestRefreshMap:genAndSaveRefreshData(configId, cfgData, sceneGroupData)
	local posIds = {}
	local chestIds = {}

	if cfgData.chestGroupList then
		local groupListCopy = lume.clone(cfgData.chestGroupList)

		lume.shuffle(groupListCopy)

		local actualGroupNum = math.min(cfgData.chestNum, #groupListCopy)
		local tmpPosIds, tmpChestIds

		for i = 1, actualGroupNum do
			local posList = sceneGroupData[groupListCopy[i]]

			if posList then
				tmpPosIds, tmpChestIds = self:_genRefreshData(posList, cfgData, true, #posList)

				lume.appendArray(posIds, tmpPosIds)
				lume.appendArray(chestIds, tmpChestIds)
			end
		end
	else
		posIds, chestIds = self:_genRefreshData(cfgData.chestPosList, cfgData)
	end

	self[configId] = {
		configId = configId,
		posIds = posIds,
		chestIds = chestIds
	}
end

function ArkChestRefreshMap:dailyReset()
	return self:_clearDataByType(REFRESH_TYPE_DAILY)
end

function ArkChestRefreshMap:weeklyReset()
	return self:_clearDataByType(REFRESH_TYPE_WEEKLY)
end

function ArkChestRefreshMap:monthlyReset()
	return self:_clearDataByType(REFRESH_TYPE_MONTHLY)
end

function ArkChestRefreshMap:_clearDataByType(refreshType)
	local cleared = {}

	for configId, _ in pairs(self) do
		local cfgData = ArkChestRefreshData[configId]

		if cfgData and cfgData.type == refreshType then
			table.insert(cleared, configId)
		end
	end

	for _, configId in ipairs(cleared) do
		self[configId] = nil
	end

	return cleared
end

return ArkChestRefreshMap
