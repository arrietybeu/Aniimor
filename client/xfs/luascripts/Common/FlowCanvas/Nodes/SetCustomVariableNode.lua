-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SetCustomVariableNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SetCustomVariableNode = Class.LiteClass("SetCustomVariableNode", FlowNode)
local CustomVariableOp = {
	function(player, k, v)
		player.triggerMap:setCustomVariable(k, v)
	end,
	function(player, k, v)
		player.triggerMap:addCustomVariable(k, v)
	end,
	function(player, k, v)
		player.triggerMap:addCustomVariable(k, -v)
	end,
	function(player, k, v)
		player.triggerMap:mulCustomVariable(k, v)
	end,
	function(player, k, v)
		player.triggerMap:divCustomVariable(k, v)
	end
}

function SetCustomVariableNode:ctor(nodeId, nodeData, graph)
	SetCustomVariableNode.super.ctor(self, nodeId, nodeData, graph)
end

function SetCustomVariableNode:registerPorts()
	self:addFlowInput("In", function(context, inputName)
		return self:On_In_PortCalled(context, inputName)
	end)

	self.valueInput_Value = self:addValueInput("Value")
	self.flowOut_Out = self:addFlowOutput("Out")
	self.Operation = self.nodeData.Operation
	self.Variable = self.nodeData.Variable
end

function SetCustomVariableNode:On_In_PortCalled(context, inputName)
	if not self.Operation or not self.Variable then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("SetCustomVariableNode:On_In_PortCalled NodeId %s Operation %s Variable %s", self.nodeId, self.Operation, self.Variable)
		end

		return
	end

	if self.Operation > #CustomVariableOp then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("SetCustomVariableNode:On_In_PortCalled NodeId %s Operation %s", self.nodeId, self.Operation)
		end

		return
	end

	local value = self:getContextValue(context, self.valueInput_Value)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("SetCustomVariableNode:On_In_PortCalled NodeId %s player nil", self.nodeId)
		end

		return
	end

	CustomVariableOp[self.Operation](player, self.Variable, value)
	self.flowOut_Out:call(context)
end

return SetCustomVariableNode
