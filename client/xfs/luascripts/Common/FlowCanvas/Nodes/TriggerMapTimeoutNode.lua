-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\TriggerMapTimeoutNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local TriggerMapTimeoutNode = Class.LiteClass("TriggerMapTimeoutNode", FlowNode)

function TriggerMapTimeoutNode:ctor(nodeId, nodeData, graph)
	TriggerMapTimeoutNode.super.ctor(self, nodeId, nodeData, graph)
end

function TriggerMapTimeoutNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_TimeOut = self:addFlowOutput("TimeOut")
	self.valueInput_TimeOutSecond = self:addValueInput("TimeOutSecond")
end

function TriggerMapTimeoutNode:On_In_PortCalled(context, inputPortName)
	local timerKey = context.graphTimerKey
	local timer = context:getTimer(timerKey)
	local timeroutSecond = self:getContextValue(context, self.valueInput_TimeOutSecond)

	if timeroutSecond ~= 0 and not timer then
		context:addContextTimer(timerKey, timeroutSecond, self, "On_Timeout")
	end
end

function TriggerMapTimeoutNode:removeTimer(context)
	context:removeContextTimer(context.graphTimerKey, self.nodeId)
end

function TriggerMapTimeoutNode:On_Timeout(context)
	local timer = context:getTimer(context.graphTimerKey)

	if not timer then
		return
	end

	local space = context:getSpace()

	if not space then
		return
	end

	space:onGraphTimeout(context.sandboxId)
	self:removeTimer(context)
	self.flowOut_TimeOut:call(context)
end

return TriggerMapTimeoutNode
