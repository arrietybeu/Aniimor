-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenSandboxPhaseChangeNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenSandboxPhaseChangeNode = Class.LiteClass("ListenSandboxPhaseChangeNode", ListenBaseNode)

function ListenSandboxPhaseChangeNode:ctor(nodeId, nodeData, graph)
	ListenSandboxPhaseChangeNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenSandboxPhaseChangeNode:registerPorts()
	ListenSandboxPhaseChangeNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.valueInput_SandboxId = self:addValueInput("SandboxId")

	self:addValueOutput("Value", function(context)
		return self:Get_Value_Value(context)
	end)

	self.firstIn = "firstIn" .. self.nodeId
end

function ListenSandboxPhaseChangeNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local firstIn = context:getContextValue(self.firstIn)

	if not firstIn then
		context:setContextValue(self.firstIn, true)
		self.flowOut_Init:call(context)
	end

	local sandboxId = self:getContextValue(context, self.valueInput_SandboxId)

	if not sandboxId or sandboxId == 0 then
		sandboxId = context.sandboxId
	end

	local eventName = ServerEventConst.SANDBOX_PHASE .. sandboxId

	local function listener(args)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

function ListenSandboxPhaseChangeNode:Get_Value_Value(context)
	local sandboxId = self:getContextValue(context, self.valueInput_SandboxId)

	if not sandboxId or sandboxId == 0 then
		sandboxId = context.sandboxId
	end

	return context:getSandboxPhase(sandboxId)
end

return ListenSandboxPhaseChangeNode
