-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenSandboxCustomNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenSandboxCustomNode = Class.LiteClass("ListenSandboxCustomNode", ListenBaseNode)

function ListenSandboxCustomNode:ctor(nodeId, nodeData, graph)
	ListenSandboxCustomNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenSandboxCustomNode:registerPorts()
	ListenSandboxCustomNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.flowOut_Init = self:addFlowOutput("Init")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.firstIn = "firstIn" .. self.nodeId
end

function ListenSandboxCustomNode:On_In_PortCalled(context, inputPortName)
	local uid = self.uid

	if not uid then
		return
	end

	local space = context:getSpace()

	if not space then
		return
	end

	local eventName = self:getContextValue(context, self.valueInput_EventName)
	local sandboxId = context.sandboxId
	local sandbox = space.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local firstIn = context:getContextValue(self.firstIn)

	if sandbox.eventState[uid] and not firstIn then
		context:setContextValue(self.firstIn, true)
		self.flowOut_Init:call(context)
	end

	local eventName = ServerEventConst.SANDBOX_EVENT .. sandboxId .. eventName

	local function listener()
		sandbox.eventState[uid] = true

		space:saveSandboxEventState(sandboxId)
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenSandboxCustomNode
