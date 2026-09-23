-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\WaitNode.lua

local Class = require("Core.Framework.Class")
local SandboxFlowNode = require("Common.FlowCanvas.Nodes.SandboxFlowNode")
local WaitNode = Class.LiteClass("WaitNode", SandboxFlowNode)

function WaitNode:ctor(nodeId, nodeData, graph)
	WaitNode.super.ctor(self, nodeId, nodeData, graph)

	self.waitTime = nodeData.waitTime
end

function WaitNode:registerPorts()
	WaitNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Break", function(context, inputPortName)
		self:On_Break_PortCalled(context, inputPortName)
	end)
	self:addFlowInput("Cancel", function(context, inputPortName)
		self:On_Cancel_PortCalled(context, inputPortName)
	end)
end

function WaitNode:On_In_PortCalled(context, inputPortName)
	self:addTimer(context)
end

function WaitNode:On_Reset_PortCalled(context, inputPortName)
	self:removeTimer(context)
	self:addTimer(context)
end

function WaitNode:On_Break_PortCalled(context, inputPortName)
	self:On_Timeout(context)
end

function WaitNode:On_Cancel_PortCalled(context, inputPortName)
	self:removeTimer(context)
end

return WaitNode
