-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PortalNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local PortalNode = Class.LiteClass("PortalNode", FlowNode)

function PortalNode:ctor(nodeId, nodeData, graph)
	PortalNode.super.ctor(self, nodeId, nodeData, graph)
end

function PortalNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_portalId = self:addValueInput("portalId")
	self.resetCamera = self.nodeData.resetCamera or false
	self.valueInput_PlayerId = self:addValueInput("playerId")
	self.playType = self.nodeData.playType or SandboxConst.NODE_TARGET_TYPE.AllPlayersInSandbox
end

function PortalNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local playerId = self:getContextValue(context, self.valueInput_PlayerId)

	for _, player in pairs(context:getTargetPlayers(self.playType, playerId)) do
		player:portal(space.sceneId, self:getContextValue(context, self.valueInput_portalId))

		if self.resetCamera then
			player:doEventByData({
				"resetPlayerCamera"
			})
		end
	end

	self.flowOut_Out:call(context)
end

return PortalNode
