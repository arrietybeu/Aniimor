-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DungeonDoActionNode.lua

local Class = require("Core.Framework.Class")
local DungeonNode = require("Common.FlowCanvas.Nodes.DungeonNode")
local DungeonDoActionNode = Class.LiteClass("DungeonDoActionNode", DungeonNode)

function DungeonDoActionNode:ctor(nodeId, nodeData, graph)
	DungeonDoActionNode.super.ctor(self, nodeId, nodeData, graph)
end

function DungeonDoActionNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
end

function DungeonDoActionNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	self:doActions(space, self.nodeData.actions)
	self.flowOut_Out:call(context)
end

return DungeonDoActionNode
