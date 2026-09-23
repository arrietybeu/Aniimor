-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogStarUpgrade\\PetTransmogStarUpgradeModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local Const = require("Common.Const.Const")
local PetTransmogStarUpgradeModel = Class.LightClass("PetTransmogStarUpgradeModel", UIModel)

function PetTransmogStarUpgradeModel:ctor()
	self.petId = nil
	self.newlyUnlockedSet = {}
end

function PetTransmogStarUpgradeModel:setContext(petId, newlyUnlockedList)
	self.petId = petId
	self.newlyUnlockedSet = {}

	if newlyUnlockedList then
		for _, idx in ipairs(newlyUnlockedList) do
			self.newlyUnlockedSet[idx] = true
		end
	end
end

function PetTransmogStarUpgradeModel:getPetId()
	return self.petId
end

function PetTransmogStarUpgradeModel:isNewlyUnlocked(holeIndex)
	return self.newlyUnlockedSet[holeIndex] == true
end

function PetTransmogStarUpgradeModel:isFlashNewlyUnlocked()
	return self:isNewlyUnlocked(Const.PetTransmogSlotType.Flash)
end

function PetTransmogStarUpgradeModel:getNewlyUnlockedName()
	local minIndex

	for idx in pairs(self.newlyUnlockedSet) do
		if not minIndex or idx < minIndex then
			minIndex = idx
		end
	end

	if not minIndex then
		return ""
	end

	return PetTransmogUtils.getHoleName(self.petId, minIndex)
end

function PetTransmogStarUpgradeModel:getStarList()
	local petId = self.petId
	local count = PetTransmogUtils.getHoleCount()
	local scheme = PetTransmogUtils.getCurrentScheme(petId)
	local list = {}

	for i = 1, count do
		list[i] = {
			index = i,
			unlocked = PetTransmogUtils.isHoleUnlocked(petId, i),
			quality = PetTransmogUtils.getHoleQuality(scheme, i),
			isNewlyUnlocked = self:isNewlyUnlocked(i)
		}
	end

	return list
end

function PetTransmogStarUpgradeModel:isAllUnlocked()
	local petId = self.petId
	local count = PetTransmogUtils.getHoleCount()
	local unlocked = PetTransmogUtils.getUnlockedHoles(petId)

	return unlocked and count <= #unlocked or false
end

return PetTransmogStarUpgradeModel
