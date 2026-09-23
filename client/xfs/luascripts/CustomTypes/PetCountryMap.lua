-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetCountryMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetCountryMap = class.LiteClass("PetCountryMap", CustomDict)

function PetCountryMap:getInfo(countryId, upsert)
	if self[countryId] == nil and upsert and pg.component == "game" then
		self[countryId] = {}
	end

	return self[countryId]
end

return PetCountryMap
