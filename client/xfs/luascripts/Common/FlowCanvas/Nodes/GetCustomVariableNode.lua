-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\GetCustomVariableNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local Class = require("Core.Framework.Class")
local GetCustomVariableNode = Class.LiteClass("GetCustomVariableNode", FlowNode)

function GetCustomVariableNode:ctor(nodeId, nodeData, graph)
	FlowNode.ctor(self, nodeId, nodeData, graph)
end

function GetCustomVariableNode:registerPorts()
	self.Variable = self.nodeData.Variable

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)
end

function GetCustomVariableNode:Get_Value_Value(context)
	if not self.Variable then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetCustomVariableNode:Get_Value_Value  NodeId %s Variable %s", self.nodeId, self.Variable)
		end

		return
	end

	local space = context:getSpace()
	local player = space.ownerPlayer

	if not player then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("GetCustomVariableNode:Get_Value_Value NodeId %s player nil", self.nodeId)
		end

		return
	end

	return player.triggerMap:getCustomVariable(self.Variable)
end

return GetCustomVariableNode
