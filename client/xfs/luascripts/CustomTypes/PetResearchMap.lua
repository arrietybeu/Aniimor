-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetResearchMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetResearchMap = class.LiteClass("PetResearchMap", CustomDict)

function PetResearchMap:getInfo(key, upsert)
	if not self[key] and upsert and pg.component == "game" then
		self[key] = {}
	end

	return self[key]
end

function PetResearchMap:isUnlock(key)
	return self[key] and self[key]:isUnlock()
end

function PetResearchMap:getUnlockNum()
	local num = 0

	for _, researchInfo in self:items() do
		num = num + (researchInfo:isUnlock() and 1 or 0)
	end

	return num
end

return PetResearchMap
