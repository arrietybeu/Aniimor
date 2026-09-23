-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetSandboxPhaseNode.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local SetSandboxPhaseNode = Class.LiteClass("SetSandboxPhaseNode", FlowNode)

function SetSandboxPhaseNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function SetSandboxPhaseNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_Value = self:addValueInput("Value")

	self:addValueOutput("Phase", function(context)
		return self:Get_Phase_Value(context)
	end)
end

function SetSandboxPhaseNode:On_In_PortCalled(context, inputPortName)
	local phase = self:getContextValue(context, self.valueInput_Value)

	context:setSandboxPhase(phase)
	self.flowOut_Out:call(context)
end

function SetSandboxPhaseNode:Get_Phase_Value(context)
	return context:getSandboxPhase(context.sandboxId)
end

return SetSandboxPhaseNode
