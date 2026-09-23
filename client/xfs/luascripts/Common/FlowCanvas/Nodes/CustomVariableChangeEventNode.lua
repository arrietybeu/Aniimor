-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\CustomVariableChangeEventNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local CustomVariableChangeEventNode = Class.LiteClass("CustomVariableChangeEventNode", FlowNode)

function CustomVariableChangeEventNode:ctor(nodeId, nodeData, graph)
	CustomVariableChangeEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function CustomVariableChangeEventNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.Variable = self.nodeData.Variable or 0

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function CustomVariableChangeEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()
	local player = space.ownerPlayer

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("CustomVariableChangeEventNode:On_In_PortCalled NodeId %s player nil", self.nodeId)
		end

		return
	end

	local eventName = ServerEventConst.CUSTOM_VARIABLE_CHANGE .. player.id .. self.Variable

	local function listener()
		self.flowOut_Out:call(context)
	end

	context:registerSpaceEventListener(self.nodeId, eventName, listener)
end

function CustomVariableChangeEventNode:Get_Value_Value(context)
	local space = context:getSpace()
	local player = space.ownerPlayer

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("CustomVariableChangeEventNode:Get_Value_Value NodeId %s player nil", self.nodeId)
		end

		return
	end

	return player.triggerMap:getCustomVariable(self.Variable)
end

return CustomVariableChangeEventNode
