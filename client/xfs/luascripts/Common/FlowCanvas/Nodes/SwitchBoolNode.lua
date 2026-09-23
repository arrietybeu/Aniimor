-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SwitchBoolNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SwitchBoolNode = Class.LiteClass("SwitchBoolNode", FlowNode)

function SwitchBoolNode:ctor(nodeId, nodeData, graph)
	SwitchBoolNode.super.ctor(self, nodeId, nodeData, graph)
end

function SwitchBoolNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_Condition = self:addValueInput("Condition")
	self.flowOut_True = self:addFlowOutput("True")
	self.flowOut_False = self:addFlowOutput("False")
	self.flowOut_Then = self:addFlowOutput("Then")
end

function SwitchBoolNode:On_In_PortCalled(context, inputPortName)
	local condition = self:getContextValue(context, self.valueInput_Condition)

	if condition == true then
		self.flowOut_True:call(context)
	elseif condition == false then
		self.flowOut_False:call(context)
	end

	self.flowOut_Then:call(context)
end

return SwitchBoolNode
