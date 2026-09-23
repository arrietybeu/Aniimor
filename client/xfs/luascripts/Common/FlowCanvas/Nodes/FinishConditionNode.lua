-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\FinishConditionNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local FinishConditionNode = Class.LiteClass("FinishConditionNode", ListenBaseNode)
local ServerEventConst = require("Const.ServerEventConst")
local Const = require("Common.Const.Const")

function FinishConditionNode:ctor(nodeId, nodeData, graph)
	FinishConditionNode.super.ctor(self, nodeId, nodeData, graph)
end

local MathOp = {
	["+"] = function(a, b)
		return a + b
	end,
	["-"] = function(a, b)
		return a - b
	end,
	["*"] = function(a, b)
		return a * b
	end,
	["/"] = function(a, b)
		return a / b
	end,
	["%"] = function(a, b)
		return a % b
	end,
	[">"] = function(a, b)
		return b < a
	end,
	[">="] = function(a, b)
		return b <= a
	end,
	["=="] = function(a, b)
		return a == b
	end,
	["<"] = function(a, b)
		return a < b
	end,
	["<="] = function(a, b)
		return a <= b
	end
}

function FinishConditionNode:registerPorts()
	FinishConditionNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Reset", function(context, inputPortName)
		self:On_Reset_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.eventParams = {}
	self.curPhase = 1

	for i, data in pairs(self.nodeData.eventParams) do
		self.eventParams[i] = {}
		self.eventParams[i].updateType = data.updateType
		self.eventParams[i].condition = data.condition
		self.eventParams[i].updateValue = tonumber(data.updateValue)
		self.eventParams[i].curValue = tonumber(data.curValue)
		self.eventParams[i].desValue = tonumber(data.desValue)
	end
end

function FinishConditionNode:On_Reset_PortCalled(context, inputPortName)
	self.curPhase = 1

	for i, data in pairs(self.nodeData.eventParams) do
		if self.eventParams[i] == nil then
			self.eventParams[i] = {}
			self.eventParams[i].updateType = data.updateType
			self.eventParams[i].condition = data.condition
			self.eventParams[i].curValue = tonumber(data.curValue)
			self.eventParams[i].desValue = tonumber(data.desValue)
		end

		self.eventParams[i].updateValue = tonumber(data.updateValue)
	end
end

function FinishConditionNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	self:updateCurValue()

	if self:checkFinishCondition(context) then
		self.curPhase = self.curPhase + 1

		context:setSandboxPhase(self.curPhase)
	end
end

function FinishConditionNode:updateCurValue()
	if self.eventParams[self.curPhase] == nil then
		return
	end

	local curPhaseData = self.eventParams[self.curPhase]

	if curPhaseData.updateType == nil then
		return
	end

	local func = MathOp[curPhaseData.updateType]

	if func == nil then
		return
	end

	if curPhaseData.curValue == nil or curPhaseData.updateValue == nil then
		return
	end

	curPhaseData.curValue = func(curPhaseData.curValue, curPhaseData.updateValue)
end

function FinishConditionNode:checkFinishCondition(context)
	if self.eventParams[self.curPhase] == nil then
		if context ~= nil then
			context:setSandboxPhase(self.curPhase)
		end

		return false
	end

	local curPhaseData = self.eventParams[self.curPhase]

	if curPhaseData == nil or curPhaseData.curValue == nil or curPhaseData.condition == nil or curPhaseData.desValue == nil then
		return false
	end

	local func = MathOp[curPhaseData.condition]

	if func == nil then
		return false
	end

	local result = func(curPhaseData.curValue, curPhaseData.desValue)

	return result
end

return FinishConditionNode
