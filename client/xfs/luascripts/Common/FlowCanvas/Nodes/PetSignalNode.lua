-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\PetSignalNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local PetSignalNode = Class.LiteClass("PetSignalNode", FlowNode)
local TriggerConst = require("Common.Const.TriggerConst")

function PetSignalNode:ctor(nodeId, nodeData, graph)
	PetSignalNode.super.ctor(self, nodeId, nodeData, graph)
end

function PetSignalNode:registerPorts()
	PetSignalNode.super.registerPorts(self)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_PetPrototypeId = self:addValueInput("PetPrototypeId")
	self.valueInput_SignalId = self:addValueInput("SignalId")
end

function PetSignalNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space or not space.sandboxes then
		return
	end

	local sandbox = space.sandboxes[context.sandboxId]

	if not sandbox then
		return
	end

	local petPrototypeId = self:getContextValue(context, self.valueInput_PetPrototypeId)
	local signalId = self:getContextValue(context, self.valueInput_SignalId)

	for playerId, player in pairs(sandbox.players) do
		player.triggerMap:onTrigger(TriggerConst.TRIGGER_TARGET_SANDBOX_SIGNAL_ID, petPrototypeId, 1, signalId)
	end

	self.flowOut_Out:call(context)
end

return PetSignalNode
