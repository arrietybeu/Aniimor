-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomePetBoxMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandConfigData = require("Data.homeland_config_data")
local Const = require("Common.Const.Const")
local HomePetBoxMap = class.LiteClass("HomePetBoxMap", CustomDict)

HomePetBoxMap.POSITION_KEY = {
	SLOT_INDEX = 2,
	AREA_ID = 1
}
HomePetBoxMap.ERROR = {
	BOX_FULL = "BOX_FULL",
	SLOT_OCCUPIED = "SLOT_OCCUPIED",
	PET_NOT_FOUND = "PET_NOT_FOUND",
	PET_ALREADY_EXISTS = "PET_ALREADY_EXISTS",
	INVALID_SLOT_INDEX = "INVALID_SLOT_INDEX",
	AREA_LOCKED = "AREA_LOCKED",
	AREA_NOT_SUPPORTED = "AREA_NOT_SUPPORTED"
}

function HomePetBoxMap:getSlotCount()
	local home = self:getRootOwner()

	if not home then
		return HomelandConfigData.maxPetCount or 0
	end

	return HomeLandUtils.getPetMaxCount(home)
end

function HomePetBoxMap:isValidSlotIndex(slotIndex)
	return slotIndex > 0 and slotIndex <= self:getSlotCount()
end

function HomePetBoxMap:getPetIndex(targetPetId)
	local petPositionMap = self.petPositionMap
	local petPosition = petPositionMap and petPositionMap[targetPetId]

	if petPosition ~= nil then
		local areaId = petPosition[HomePetBoxMap.POSITION_KEY.AREA_ID]
		local slotIndex = petPosition[HomePetBoxMap.POSITION_KEY.SLOT_INDEX]

		if self:getPetId(areaId, slotIndex) == targetPetId then
			return areaId, slotIndex
		end
	end

	for areaId in pairs(Const.HOME_PET_BOX_SUPPORTED_AREA_SET) do
		local boxInfo = self[areaId]

		if boxInfo then
			for slotIndex, petId in boxInfo:items() do
				if petId == targetPetId then
					return areaId, slotIndex
				end
			end
		end
	end

	return nil, nil
end

function HomePetBoxMap:getPetId(areaId, slotIndex)
	local boxInfo = self[areaId]

	return boxInfo and boxInfo[slotIndex] or nil
end

function HomePetBoxMap:getAreaPetCount(areaId)
	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		return 0
	end

	local boxInfo = self[areaId]

	return boxInfo and (boxInfo.count or 0) or 0
end

function HomePetBoxMap:getTotalPetCount()
	local count = 0

	for areaId in pairs(Const.HOME_PET_BOX_SUPPORTED_AREA_SET) do
		count = count + self:getAreaPetCount(areaId)
	end

	return count
end

function HomePetBoxMap:getRemainingPetCount()
	local home = self:getRootOwner()
	local petCount = home and home.pets and HomeLandUtils.getPetCurCount(home) or self:getTotalPetCount()

	return math.max(self:getSlotCount() - petCount, 0)
end

function HomePetBoxMap:canHoldPetCount(addCount)
	addCount = math.max(addCount or 0, 0)

	return addCount <= self:getRemainingPetCount()
end

function HomePetBoxMap:getFirstEmptySlot(areaId)
	local boxInfo = self[areaId]
	local slotCount = self:getSlotCount()

	for slotIndex = 1, slotCount do
		if not boxInfo or not boxInfo[slotIndex] then
			return slotIndex
		end
	end

	return nil
end

return HomePetBoxMap
