-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetJewelryCustom.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local PetJewelryCustom = class.LiteClass("PetJewelryCustom", CustomDict)

function PetJewelryCustom:getCount()
	local count = 0

	for index, _ in pairs(self) do
		if type(index) == "number" then
			count = count + 1
		end
	end

	return count
end

return PetJewelryCustom
