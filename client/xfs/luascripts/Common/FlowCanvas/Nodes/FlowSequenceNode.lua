-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FlowSequenceNode.lua

local Class = require("Core.Framework.Class")
local SandboxFlowNode = require("Common.FlowCanvas.Nodes.SandboxFlowNode")
local FlowSequenceNode = Class.LiteClass("FlowSequenceNode", SandboxFlowNode)

function FlowSequenceNode:ctor(nodeId, nodeData, graph)
	FlowSequenceNode.super.ctor(self, nodeId, nodeData, graph)
end

function FlowSequenceNode:registerPorts()
	FlowSequenceNode.super.registerPorts(self)

	local portCount = self.nodeData.portCount or 2

	for i = 1, portCount do
		self:addFlowInput(tostring(i), function(context, inputPortName)
			self:On_PortCalled(context, inputPortName)
		end)
	end

	self.flowOut_Success = self:addFlowOutput("Success")
	self.flowOut_Fail = self:addFlowOutput("Fail")
	self.outFlagKey = self.nodeId .. "outFlag"
	self.sequenceKey = self.nodeId .. "sequence"
end

function FlowSequenceNode:On_Reset_PortCalled(context, inputPortName)
	local outFlag = context:getContextValue(self.outFlagKey)

	if outFlag then
		context:setContextValue(self.outFlagKey, nil)
		context:removeSequenceFlow(self.sequenceKey)
	end
end

function FlowSequenceNode:On_PortCalled(context, inputPortName)
	local outFlog = context:getContextValue(self.outFlagKey)

	if outFlog then
		return
	end

	self:addTimer(context)

	local sequence = context:addSequeceFlow(self.sequenceKey, inputPortName)
	local portCount = self.nodeData.portCount or 2
	local endFinish = 0

	for i = portCount, 1, -1 do
		local state = sequence[tostring(i)]

		if state and endFinish == 0 then
			endFinish = i
		end

		if i < endFinish and not state then
			context:removeSequenceFlow(self.sequenceKey)
			context:setContextValue(self.outFlagKey, true)
			self:removeTimer(context)
			self.flowOut_Fail:call(context)

			return
		end
	end

	if endFinish == portCount then
		context:setContextValue(self.outFlagKey, true)
		self:removeTimer(context)
		self.flowOut_Success:call(context)
	end
end

function FlowSequenceNode:On_Timeout(context)
	local outFlog = context:getContextValue(self.outFlagKey)

	if outFlog then
		return
	end

	context:setContextValue(self.outFlagKey, true)
	FlowSequenceNode.super.On_Timeout(self, context)
end

return FlowSequenceNode
