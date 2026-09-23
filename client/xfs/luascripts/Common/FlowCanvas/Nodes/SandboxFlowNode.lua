-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SandboxFlowNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxFlowNode = Class.LiteClass("SandboxFlowNode", FlowNode)

function SandboxFlowNode:ctor(nodeId, nodeData, graph)
	SandboxFlowNode.super.ctor(self, nodeId, nodeData, graph)
end

function SandboxFlowNode:registerPorts()
	self.flowOut_TimeOut = self:addFlowOutput("TimeOut")
	self.valueInput_TimeOutSecond = self:addValueInput("TimeOutSecond")
	self.timerKey = self.nodeId .. "timer"

	self:addFlowInput("Reset", function(context, inputPortName)
		self:On_Reset_PortCalled(context, inputPortName)
	end)
end

function SandboxFlowNode:On_Reset_PortCalled(context, inputPortName)
	local timer = context:getTimer(self.timerKey)

	if not timer then
		return
	end

	self:removeTimer(context)
end

function SandboxFlowNode:addTimer(context)
	local timer = context:getTimer(self.timerKey)
	local timeroutSecond = self:getContextValue(context, self.valueInput_TimeOutSecond)

	if timeroutSecond ~= 0 and not timer then
		context:addContextTimer(self.timerKey, timeroutSecond, self, "On_Timeout")
	end
end

function SandboxFlowNode:removeTimer(context)
	context:removeContextTimer(self.timerKey, self.nodeId)
end

function SandboxFlowNode:On_Timeout(context)
	local timer = context:getTimer(self.timerKey)

	if not timer then
		return
	end

	self:removeTimer(context)
	self.flowOut_TimeOut:call(context)
end

return SandboxFlowNode
