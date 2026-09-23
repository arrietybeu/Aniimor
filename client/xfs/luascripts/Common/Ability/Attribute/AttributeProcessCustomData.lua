-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Attribute\\AttributeProcessCustomData.lua

local Class = require("Core.Framework.Class")
local AttributeProcessCustomData = Class.LiteClass("AttributeProcessCustomData")

function AttributeProcessCustomData:ctor(attributeMap, combatContext)
	self.attributeMap = attributeMap
	self.combatContext = combatContext
end

return AttributeProcessCustomData
