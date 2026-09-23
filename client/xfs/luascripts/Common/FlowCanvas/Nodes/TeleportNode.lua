-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\TeleportNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local TeleportNode = Class.LiteClass("TeleportNode", FlowNode)

function TeleportNode:ctor(nodeId, nodeData, graph)
	TeleportNode.super.ctor(self, nodeId, nodeData, graph)
end

function TeleportNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_sceneId = self:addValueInput("sceneId")
	self.valueInput_portalId = self:addValueInput("portalId")
end

function TeleportNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	for _, player in pairs(context:getGraphPlayers()) do
		player:checkAndTeleportToScene(self:getContextValue(context, self.valueInput_sceneId), self:getContextValue(context, self.valueInput_portalId))
	end

	self.flowOut_Out:call(context)
end

return TeleportNode
