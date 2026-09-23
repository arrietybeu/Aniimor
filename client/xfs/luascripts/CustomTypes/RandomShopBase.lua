-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RandomShopBase.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local RandomShopBase = class.LiteClass("RandomShopBase", CustomDict)

function RandomShopBase:getShopId()
	return self.shopId
end

function RandomShopBase:getShopType()
	return self.shopType
end

return RandomShopBase
