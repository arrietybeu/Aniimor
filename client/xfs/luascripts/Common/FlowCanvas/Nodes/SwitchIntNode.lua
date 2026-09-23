-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SwitchIntNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SwitchIntNode = Class.LiteClass("SwitchIntNode", FlowNode)

function SwitchIntNode:ctor(nodeId, nodeData, graph)
	SwitchIntNode.super.ctor(self, nodeId, nodeData, graph)
end

function SwitchIntNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	local startInt = self.nodeData.startInt or 0
	local endInt = self.nodeData.endInt or 1

	self.valueInput_Value = self:addValueInput("Value")

	for i = startInt, endInt do
		self["flowOut_" .. i] = self:addFlowOutput(tostring(i))
	end

	self.flowOut_Default = self:addFlowOutput("Default")
end

function SwitchIntNode:On_In_PortCalled(context, inputPortName)
	local value = self:getContextValue(context, self.valueInput_Value)

	if not value then
		return
	end

	if self["flowOut_" .. value] then
		self["flowOut_" .. value]:call(context)
	else
		self.flowOut_Default:call(context)
	end
end

return SwitchIntNode
