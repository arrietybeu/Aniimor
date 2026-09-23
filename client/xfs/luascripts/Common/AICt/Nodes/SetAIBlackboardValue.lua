-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SetAIBlackboardValue.lua

local DoAction = require("Common.AICt.Nodes.DoAction")
local Class = require("Core.Framework.Class")
local SetAIBlackboardValue = Class.LightClass("SetAIBlackboardValue", DoAction)

function SetAIBlackboardValue:getEventName()
	return "SetAIBlackboardValue"
end

function SetAIBlackboardValue:getContext(context, flow)
	DoAction.getContext(self, context, flow)

	context.blackboardName = self.nodeData.blackboardName
end

return SetAIBlackboardValue
