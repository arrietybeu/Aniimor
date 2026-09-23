-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\AddEntityTag.lua

local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local AddEntityTag = Class.LightClass("AddEntityTag", DoAction)

function AddEntityTag:getEventName()
	return "AddEntityTag"
end

function AddEntityTag:getContext(context, flow)
	DoAction.getContext(self, context, flow)

	context.tag = self.nodeData.tag
end

return AddEntityTag
