-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\StringIntMapWithChangeEvent.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local StringIntMap = require("CustomTypes.StringIntMap")
local StringIntMapWithChangeEvent = class.LiteClass("StringIntMapWithChangeEvent", StringIntMap)

function StringIntMapWithChangeEvent:enableQuickCopy()
	return true
end

return StringIntMapWithChangeEvent
