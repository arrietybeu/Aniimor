-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SwitchSandboxNotifyNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SwitchSandboxNotifyNode = Class.LiteClass("SwitchSandboxNotifyNode", FlowNode)

function SwitchSandboxNotifyNode:ctor(nodeId, nodeData, graph)
	SwitchSandboxNotifyNode.super.ctor(self, nodeId, nodeData, graph)
end

function SwitchSandboxNotifyNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_ToSandboxId = self:addValueInput("ToSandboxId")
	self.valueInput_FromSandboxId = self:addValueInput("FromSandboxId")
end

function SwitchSandboxNotifyNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local toSandboxId = self:getContextValue(context, self.valueInput_ToSandboxId)
	local fromSandboxId = self:getContextValue(context, self.valueInput_FromSandboxId)

	self:switchSandbox(context, space, fromSandboxId, toSandboxId)
	self:notifyClients(context, space)
	self.flowOut_Out:call(context)
end

function SwitchSandboxNotifyNode:switchSandbox(context, space, fromSandboxId, toSandboxId)
	if fromSandboxId and fromSandboxId ~= 0 and space.manualSandboxUnLoad then
		space:manualSandboxUnLoad(fromSandboxId)
	end

	if toSandboxId and toSandboxId ~= 0 and space.manualSandboxLoad and space.resetSandbox then
		space:resetSandbox(toSandboxId)
		space:manualSandboxLoad(toSandboxId)
	end
end

function SwitchSandboxNotifyNode:notifyClients(context, space)
	local sandbox = space.sandboxes and space.sandboxes[context.sandboxId]

	if not sandbox or not space.sandboxClientMsg then
		return
	end

	space:sandboxClientMsg(sandbox, "RPC_SC_SwitchSandboxNotify", self.valueInput_ToSandboxId)
end

return SwitchSandboxNotifyNode
