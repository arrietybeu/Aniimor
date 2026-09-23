-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetJewelryCustomOne.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local PetJewelryCustomOne = class.LiteClass("PetJewelryCustomOne", CustomDict)

function PetJewelryCustomOne:getCount()
	local count = 0

	for index, _ in pairs(self) do
		if type(index) == "number" then
			count = count + 1
		end
	end

	return count
end

return PetJewelryCustomOne
