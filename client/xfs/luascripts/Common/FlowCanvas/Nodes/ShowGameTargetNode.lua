-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ShowGameTargetNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ShowGameTargetNode = Class.LiteClass("ShowGameTargetNode", FlowNode)

function ShowGameTargetNode:ctor(nodeId, nodeData, graph)
	ShowGameTargetNode.super.ctor(self, nodeId, nodeData, graph)
end

function ShowGameTargetNode:registerPorts()
	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_GameTargetId = self:addValueInput("GameTargetId")

	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function ShowGameTargetNode:On_In_PortCalled(context, inputPortName)
	local gameTargetId = self:getContextValue(context, self.valueInput_GameTargetId)

	if not gameTargetId then
		self.logger:error("@node ShowGameTargetNode/On_In_PortCalled gameTargetId is nil nodeId=%s graphId=%s", self.nodeId, self.graph and self.graph.graphId)

		return
	end

	local player = self:_getPlayer(context)

	if not player then
		self.logger:debug("@node ShowGameTargetNode/On_In_PortCalled main player is nil  nodeId=%s graphId=%s", self.nodeId, self.graph and self.graph.graphId)

		return
	end

	self.logger:info("@node ShowGameTargetNode/On_In_PortCalled gameTargetId=%s nodeId=%s graphId=%s", gameTargetId, self.nodeId, self.graph and self.graph.graphId)
	player:showTarget(gameTargetId)
	self.flowOut_Out:call(context)
end

function ShowGameTargetNode:_getPlayer(context)
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

function ShowGameTargetNode:onContextDestroy(context)
	local gameTargetId = self:getContextValue(context, self.valueInput_GameTargetId)
	local player = self:_getPlayer(context)

	if player and gameTargetId then
		self.logger:info("@node ShowGameTargetNode/onContextDestroy delTarget gameTargetId=%s nodeId=%s graphId=%s", gameTargetId, self.nodeId, self.graph and self.graph.graphId)
		player:delTarget(gameTargetId)
	end

	ShowGameTargetNode.super.onContextDestroy(self, context)
end

return ShowGameTargetNode
