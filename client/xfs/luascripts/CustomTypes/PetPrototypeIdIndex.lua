-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetPrototypeIdIndex.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local PetPrototypeIdIndex = class.LiteClass("PetPrototypeIdIndex", CustomDict)

function PetPrototypeIdIndex:getByPetPrototypeId(petPrototypeId)
	return self.index[petPrototypeId]
end

return PetPrototypeIdIndex
