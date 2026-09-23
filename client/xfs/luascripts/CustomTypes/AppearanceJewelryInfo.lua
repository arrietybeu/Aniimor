-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\AppearanceJewelryInfo.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local AppearanceJewelryInfo = class.LiteClass("AppearanceJewelryInfo", CustomDict)

function AppearanceJewelryInfo:toTable(configId, str)
	local dict = string.toTable(str)

	dict.configId = configId

	self:init(dict)
end

return AppearanceJewelryInfo
