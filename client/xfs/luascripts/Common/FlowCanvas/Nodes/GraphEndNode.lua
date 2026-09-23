-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GraphEndNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local GraphEndNode = Class.LiteClass("GraphEndNode", FlowNode)

function GraphEndNode:ctor(nodeId, nodeData, graph)
	GraphEndNode.super.ctor(self, nodeId, nodeData, graph)
end

function GraphEndNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.valueInput_Result = self:addValueInput("Success")
	self.flowOut_Out = self:addFlowOutput("Out")
end

function GraphEndNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local timerKey = context.graphTimerKey
	local timer = context:getTimer(timerKey)

	if timer then
		context:removeContextTimer(timerKey, self.nodeId)
	end

	local inputResult = self:getContextValue(context, self.valueInput_Result) or false

	self.flowOut_Out:call(context)
	context.sandbox:onGraphEnd(inputResult)
end

return GraphEndNode
