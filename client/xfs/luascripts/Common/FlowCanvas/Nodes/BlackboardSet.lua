-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\BlackboardSet.lua

local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local BlackboardSet = Class.LiteClass("BlackboardSet", FlowNode)
local BlackboardOp = {
	function(x, y)
		return y
	end,
	function(x, y)
		return x + y
	end,
	function(x, y)
		return x - y
	end,
	function(x, y)
		return x * y
	end,
	function(x, y)
		return x / y
	end
}

function BlackboardSet:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)

	self.variableName = nodeData.variableName
end

function BlackboardSet:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_Value = self:addValueInput("Value")
	self.Operation = self.nodeData.Operation or 1

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function BlackboardSet:On_In_PortCalled(context, inputPortName)
	local value = self:getContextValue(context, self.valueInput_Value)
	local finalValue = BlackboardOp[self.Operation](context:getBlackboardVariable(self.variableName), value)

	context:setBlackboardVariable(self.variableName, finalValue)
	self.flowOut_Out:call(context)
end

function BlackboardSet:Get_Value_Value(context)
	return context:getBlackboardVariable(self.variableName)
end

return BlackboardSet
