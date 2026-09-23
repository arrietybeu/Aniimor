-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetCarryRecommendInfoMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetCarryRecommendInfoMap = class.LiteClass("PetCarryRecommendInfoMap", CustomDict)

function PetCarryRecommendInfoMap:getValidRecommendInfo(petId)
	local recommendInfo = self[petId]

	if not recommendInfo or recommendInfo.appliedType ~= 1 and recommendInfo.appliedType ~= 2 then
		return nil
	end

	local player = self:getRootOwner()
	local carryPosMap = player and player.petCoreCarryPosMap
	local currentSnapshot = carryPosMap and carryPosMap:getCarrySnapshot(petId)
	local currentItemIds = currentSnapshot and currentSnapshot.itemIds
	local currentItemGenIds = currentSnapshot and currentSnapshot.itemGenIds
	local appliedItemIds = recommendInfo.appliedItemIds
	local appliedItemGenIds = recommendInfo.appliedItemGenIds

	if not currentItemIds or not currentItemGenIds or not appliedItemIds or not appliedItemGenIds or #currentItemIds ~= #appliedItemIds or #currentItemGenIds ~= #appliedItemGenIds then
		return nil
	end

	for index, itemId in ipairs(currentItemIds) do
		if itemId ~= appliedItemIds[index] or currentItemGenIds[index] ~= appliedItemGenIds[index] then
			return nil
		end
	end

	return recommendInfo
end

return PetCarryRecommendInfoMap
