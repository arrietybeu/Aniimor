-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PlayerIsInCombatNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PlayerIsInCombatNode = Class.LiteClass("PlayerIsInCombatNode", FlowNode)

function PlayerIsInCombatNode:ctor(nodeId, nodeData, graph)
	PlayerIsInCombatNode.super.ctor(self, nodeId, nodeData, graph)
end

function PlayerIsInCombatNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_True = self:addFlowOutput("True")
	self.flowOut_False = self:addFlowOutput("False")
end

function PlayerIsInCombatNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space.ownerPlayer

	if not player then
		return
	end

	if player:isInCombat() then
		self.flowOut_True:call(context)
	else
		self.flowOut_False:call(context)
	end
end

return PlayerIsInCombatNode
