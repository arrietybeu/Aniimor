-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ListenSandboxEventNode.lua

local Class = require("Core.Framework.Class")
local ServerEventConst = require("Const.ServerEventConst")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ListenSandboxEventNode = Class.LiteClass("ListenSandboxEventNode", ListenBaseNode)

function ListenSandboxEventNode:ctor(nodeId, nodeData, graph)
	ListenSandboxEventNode.super.ctor(self, nodeId, nodeData, graph)
end

function ListenSandboxEventNode:registerPorts()
	ListenSandboxEventNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_LevelItemId = self:addValueInput("LevelItemId")
end

function ListenSandboxEventNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local levelItemId = self:getContextValue(context, self.valueInput_LevelItemId)
	local sandboxId = context.sandboxId
	local levelItem = space:getLevelItem(sandboxId, levelItemId)

	if not levelItem then
		return
	end

	local eventType = self.nodeData.eventType
	local eventName = ServerEventConst.SANDBOX_EVENT .. sandboxId .. levelItemId .. eventType

	local function listener()
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return ListenSandboxEventNode
