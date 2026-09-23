-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetFeatureUnlockMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetFeatureUnlockMap = class.LiteClass("PetFeatureUnlockMap", CustomDict)

function PetFeatureUnlockMap:addFeatureUnlock(basePetPrototypeId, featureId)
	if pg.component ~= "game" then
		return
	end

	self[basePetPrototypeId] = self[basePetPrototypeId] or {}
	self[basePetPrototypeId][featureId] = true
end

function PetFeatureUnlockMap:getFeatureUnlockCount(basePetPrototypeId, featureId)
	if basePetPrototypeId ~= 0 then
		local info = self[basePetPrototypeId]

		if featureId ~= 0 then
			return info and info[featureId] and 1 or 0
		else
			return info and #info or 0
		end
	else
		local totalCount = 0

		for _, info in self:items() do
			totalCount = totalCount + (featureId ~= 0 and (info[featureId] and 1 or 0) or #info)
		end

		return totalCount
	end
end

return PetFeatureUnlockMap
