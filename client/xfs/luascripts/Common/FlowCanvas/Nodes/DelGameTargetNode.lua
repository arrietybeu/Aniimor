-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DelGameTargetNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local DelGameTargetNode = Class.LiteClass("DelGameTargetNode", FlowNode)

function DelGameTargetNode:ctor(nodeId, nodeData, graph)
	DelGameTargetNode.super.ctor(self, nodeId, nodeData, graph)
end

function DelGameTargetNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_GameTargetId = self:addValueInput("GameTargetId")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function DelGameTargetNode:On_In_PortCalled(context, inputPortName)
	local gameTargetId = self:getContextValue(context, self.valueInput_GameTargetId)

	if not gameTargetId then
		self.logger:error("@node ShowGameTargetNode/On_In_PortCalled gameTargetId is nil nodeId=%s graphId=%s", self.nodeId, self.graph and self.graph.graphId)

		return
	end

	local player = self:_getPlayer(context)

	if not player then
		self.logger:debug("@node DelGameTargetNode/On_In_PortCalled main player is nil  nodeId=%s graphId=%s", self.nodeId, self.graph and self.graph.graphId)

		return
	end

	self.logger:info("@node DelGameTargetNode/On_In_PortCalled gameTargetId=%s nodeId=%s graphId=%s", gameTargetId, self.nodeId, self.graph and self.graph.graphId)
	player:delTarget(gameTargetId)
	self.flowOut_Out:call(context)
end

function DelGameTargetNode:_getPlayer(context)
	local space = context:getSpace()

	if not space then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	return player
end

return DelGameTargetNode
