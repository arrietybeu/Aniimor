-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetAlivePuppetCountNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetAlivePuppetCountNode = Class.LiteClass("GetAlivePuppetCountNode", FlowNode)

function GetAlivePuppetCountNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetAlivePuppetCountNode:registerPorts()
	self.valueInput_templateId = self:addValueInput("templateId")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetAlivePuppetCountNode:Get_Value_Value(context)
	local space = context:getSpace()

	if not space then
		return 0
	end

	local templateId = self:getContextValue(context, self.valueInput_templateId)

	if space.getAlivePuppetCount then
		return space:getAlivePuppetCount(templateId)
	else
		return 0
	end
end

return GetAlivePuppetCountNode
