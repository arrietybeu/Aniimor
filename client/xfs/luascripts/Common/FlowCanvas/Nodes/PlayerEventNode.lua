-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PlayerEventNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SandboxConst = require("Common.Const.SandboxConst")
local PlayerEventNode = Class.LiteClass("PlayerEventNode", FlowNode)

function PlayerEventNode:ctor(nodeId, nodeData, graph)
	PlayerEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function PlayerEventNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.valueInput_PlayerId = self:addValueInput("playerId")
	self.eventParams = {}

	if self.nodeData.actionData then
		self.eventParams = self.nodeData.actionData.eventParams or {}
	end

	self.playType = self.nodeData.playType or SandboxConst.NODE_TARGET_TYPE.AllPlayersInSandbox
end

function PlayerEventNode:On_In_PortCalled(context, inputPortName)
	local eventName = self:getContextValue(context, self.valueInput_EventName)
	local eventParam = self.eventParams

	if not eventName or not eventParam then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("PlayerEventNode:On_In_PortCalled eventName %s eventParam %s", eventName, eventParam)
		end

		return
	end

	local playerId = self:getContextValue(context, self.valueInput_PlayerId)

	for _, player in pairs(context:getTargetPlayers(self.playType, playerId)) do
		player:doEventByData({
			eventName,
			eventParam
		})
	end

	self.flowOut_Out:call(context)
end

return PlayerEventNode
