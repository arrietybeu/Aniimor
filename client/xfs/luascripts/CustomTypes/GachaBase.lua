-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\GachaBase.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local GachaBase = class.LiteClass("GachaBase", CustomDict)

function GachaBase:isFirstTenPul()
	return self.gachaFirstTenPull
end

return GachaBase
