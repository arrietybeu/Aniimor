-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\QuitSpaceNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local QuitSpaceNode = Class.LiteClass("QuitSpaceNode", FlowNode)

function QuitSpaceNode:ctor(nodeId, nodeData, graph)
	QuitSpaceNode.super.ctor(self, nodeId, nodeData, graph)
end

function QuitSpaceNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
end

function QuitSpaceNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	for _, player in pairs(context:getGraphPlayers()) do
		player:quitSpace()
	end

	self.flowOut_Out:call(context)
end

return QuitSpaceNode
