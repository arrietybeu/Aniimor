-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ActivateRespawnNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ActivateRespawnNode = Class.LiteClass("ActivateRespawnNode", FlowNode)

function ActivateRespawnNode:ctor(nodeId, nodeData, graph)
	ActivateRespawnNode.super.ctor(self, nodeId, nodeData, graph)
end

function ActivateRespawnNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_RespawnId = self:addValueInput("RespawnId")
	self.valueInput_EntityId = self:addValueInput("EntityId")
end

function ActivateRespawnNode:On_In_PortCalled(context, inputPortName)
	local respawnId = self:getContextValue(context, self.valueInput_RespawnId)
	local entityId = self:getContextValue(context, self.valueInput_EntityId)

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ActivateRespawnNode:Activate Respawn:", entityId, "true", respawnId)
	end

	if respawnId ~= 0 and not string.isNilOrEmpty(entityId) then
		local space = context:getSpace()

		space:setSavePortals(entityId, true, respawnId)
	end

	self.flowOut_Out:call(context)
end

return ActivateRespawnNode
