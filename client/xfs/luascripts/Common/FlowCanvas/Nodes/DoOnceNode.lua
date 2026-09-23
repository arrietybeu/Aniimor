-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DoOnceNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local DoOnceNode = Class.LiteClass("DoOnceNode", FlowNode)

function DoOnceNode:ctor(nodeId, nodeData, graph)
	DoOnceNode.super.ctor(self, nodeId, nodeData, graph)
end

function DoOnceNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Reset", function(context, inputPortName)
		self:On_Reset_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.calledKey = self.nodeId .. "called"
end

function DoOnceNode:On_In_PortCalled(context, inputPortName)
	local called = context:getContextValue(self.calledKey)

	if called then
		return
	end

	context:setContextValue(self.calledKey, true)
	self.flowOut_Out:call(context)
end

function DoOnceNode:On_Reset_PortCalled(context, inputPortName)
	local called = context:getContextValue(self.calledKey)

	if called then
		context:setContextValue(self.calledKey, false)
	end
end

return DoOnceNode
