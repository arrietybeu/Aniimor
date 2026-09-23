-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\RemoveEntityTag.lua

local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local RemoveEntityTag = Class.LightClass("RemoveEntityTag", DoAction)

function RemoveEntityTag:getEventName()
	return "RemoveEntityTag"
end

function RemoveEntityTag:getContext(context, flow)
	DoAction.getContext(self, context, flow)

	context.tag = self.nodeData.tag
end

return RemoveEntityTag
