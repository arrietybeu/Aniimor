-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerSetLogicTimeNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ServerSetLogicTimeNode = Class.LiteClass("ServerSetLogicTimeNode", FlowNode)

function ServerSetLogicTimeNode:ctor(nodeId, nodeData, graph)
	ServerSetLogicTimeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ServerSetLogicTimeNode:registerPorts()
	self.valueInput_hour = self:addValueInput("Hour")
	self.valueInput_minute = self:addValueInput("Minute")

	self:addFlowInput("In", function(context, inputPortName)
		return self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
end

function ServerSetLogicTimeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local hour = self:getContextValue(context, self.valueInput_hour)
	local minute = self:getContextValue(context, self.valueInput_minute)

	space:setLogicTime(hour, minute)
	self.flowOut_Out:call(context)
end

return ServerSetLogicTimeNode
