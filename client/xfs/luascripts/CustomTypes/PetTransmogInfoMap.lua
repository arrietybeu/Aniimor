-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetTransmogInfoMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetTransmogInfoMap = class.LiteClass("PetTransmogInfoMap", CustomDict)

function PetTransmogInfoMap:getInfo(petId)
	if string.isNilOrEmpty(petId) then
		return nil
	end

	return self[petId]
end

function PetTransmogInfoMap:getSelectedScheme(petId)
	local transmogInfo = self:getInfo(petId)

	return transmogInfo and transmogInfo:getSelectedScheme() or nil
end

function PetTransmogInfoMap:getSelectedSchemeRaw(petId)
	local transmogInfo = self:getInfo(petId)

	return transmogInfo and transmogInfo:getSelectedSchemeRaw() or nil
end

return PetTransmogInfoMap
