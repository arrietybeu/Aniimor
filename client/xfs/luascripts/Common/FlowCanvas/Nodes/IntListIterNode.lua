-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\IntListIterNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local IntListIterNode = Class.LiteClass("IntListIterNode", FlowNode)

function IntListIterNode:ctor(nodeId, nodeData, graph)
	IntListIterNode.super.ctor(self, nodeId, nodeData, graph)
end

function IntListIterNode:registerPorts()
	self.valueOutput_value = self:addValueOutput("value", function(context)
		return self.nodeData.list[self.list_index]
	end)

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
end

function IntListIterNode:On_In_PortCalled(context, inputPortName)
	self.list_index = 1

	for i = 1, #self.nodeData.list do
		self.flowOut_Out:call(context)

		self.list_index = self.list_index + 1
	end
end

return IntListIterNode
