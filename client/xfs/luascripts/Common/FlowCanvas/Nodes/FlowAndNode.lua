-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FlowAndNode.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local SandboxFlowNode = require("Common.FlowCanvas.Nodes.SandboxFlowNode")
local FlowAndNode = Class.LiteClass("FlowAndNode", SandboxFlowNode)

function FlowAndNode:ctor(nodeId, nodeData, graph)
	FlowAndNode.super.ctor(self, nodeId, nodeData, graph)
end

function FlowAndNode:registerPorts()
	FlowAndNode.super.registerPorts(self)

	local portCount = self.nodeData.portCount or 2

	for i = 1, portCount do
		local originalPortName = tostring(i)

		self:addFlowInput(originalPortName, function(context, inputPortName)
			self:On_PortCalled(context, inputPortName)
		end)
		self:addFlowInput("Reset" .. originalPortName, function(context, inputPortName)
			self:On_Reset_One_PortCalled(context, inputPortName, originalPortName)
		end)
	end

	self.flowOut_Success = self:addFlowOutput("Success")
	self.valueInput_FinishCount = self:addValueInput("FinishCount")
	self.finishKey = self.nodeId .. "finished"
	self.outFlagKey = self.nodeId .. "outFlag"
	self.sequenceKey = self.nodeId .. "sequence"
end

function FlowAndNode:On_Reset_One_PortCalled(context, inputPortName, originalPortName)
	local sequence = context:getSequenceFlow(self.sequenceKey)

	if not sequence then
		return
	end

	sequence[originalPortName] = nil

	local finished = lume.tableLength(sequence)

	context:setContextValue(self.finishKey, finished)
end

function FlowAndNode:On_Reset_PortCalled(context, inputPortName)
	context:setContextValue(self.finishKey, nil)
	context:setContextValue(self.outFlagKey, nil)
	context:removeSequenceFlow(self.sequenceKey)
end

function FlowAndNode:On_PortCalled(context, inputPortName)
	local outFlog = context:getContextValue(self.outFlagKey)

	if outFlog then
		return
	end

	local finished = context:getContextValue(self.finishKey)

	if not finished then
		finished = 0

		self:addTimer(context)
	end

	local sequence = context:addSequeceFlow(self.sequenceKey, inputPortName)

	finished = lume.tableLength(sequence)

	context:setContextValue(self.finishKey, finished)

	local finishCount = self:getContextValue(context, self.valueInput_FinishCount)

	if finishCount == 0 then
		finishCount = self.nodeData.portCount
	end

	if finishCount <= finished then
		self:removeTimer(context)
		context:setContextValue(self.outFlagKey, true)
		self.flowOut_Success:call(context)
	end
end

function FlowAndNode:On_Timeout(context)
	local outFlog = context:getContextValue(self.outFlagKey)

	if outFlog then
		return
	end

	context:setContextValue(self.outFlagKey, true)
	FlowAndNode.super.On_Timeout(self, context)
end

return FlowAndNode
