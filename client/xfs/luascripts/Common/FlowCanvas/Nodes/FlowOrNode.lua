-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FlowOrNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local FlowOrNode = Class.LiteClass("FlowOrNode", FlowNode)

function FlowOrNode:ctor(nodeId, nodeData, graph)
	FlowOrNode.super.ctor(self, nodeId, nodeData, graph)
end

function FlowOrNode:registerPorts()
	local portCount = self.nodeData.portCount or 2

	for i = 1, portCount do
		self:addFlowInput(tostring(i), function(context, inputPortName)
			self:On_PortCalled(context, inputPortName)
		end)
	end

	self:addFlowInput("Reset", function(context, inputPortName)
		self:On_Reset_PortCalled(context, inputPortName)
	end)

	self.flowOut_Success = self:addFlowOutput("Success")
	self.outFlagKey = self.nodeId .. "outFlag"

	local rawFlag = self.nodeData.enableOneShotLock

	self.enableOneShotLock = rawFlag == nil and true or rawFlag
end

function FlowOrNode:On_PortCalled(context, inputPortName)
	if self.enableOneShotLock then
		local outFlag = context:getContextValue(self.outFlagKey)

		if outFlag then
			return
		end

		context:setContextValue(self.outFlagKey, true)
	end

	self.flowOut_Success:call(context)
end

function FlowOrNode:On_Reset_PortCalled(context, inputPortName)
	local outFlag = context:getContextValue(self.outFlagKey)

	if outFlag then
		context:setContextValue(self.outFlagKey, nil)
	end
end

return FlowOrNode
