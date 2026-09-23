-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomeHandbookItemMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local HomeHandbookItemMap = class.LiteClass("HomeHandbookItemMap", CustomDict)

function HomeHandbookItemMap:isUnlocked(itemId)
	return self[itemId] ~= nil
end

return HomeHandbookItemMap
