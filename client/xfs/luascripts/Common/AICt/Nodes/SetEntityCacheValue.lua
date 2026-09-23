-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SetEntityCacheValue.lua

local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local SetEntityCacheValue = Class.LightClass("SetEntityCacheValue", DoAction)

function SetEntityCacheValue:getEventName()
	return "SetEntityCacheValue"
end

function SetEntityCacheValue:getContext(context, flow)
	DoAction.getContext(self, context, flow)

	context.keyName = self.nodeData.keyName
end

return SetEntityCacheValue
