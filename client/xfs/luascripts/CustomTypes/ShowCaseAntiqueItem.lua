-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ShowCaseAntiqueItem.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ShowCaseAntiqueItem = class.LiteClass("ShowCaseAntiqueItem", CustomDict)

function ShowCaseAntiqueItem:isValid()
	return ToBool(self.id)
end

function ShowCaseAntiqueItem:isActive()
	return self.active
end

return ShowCaseAntiqueItem
