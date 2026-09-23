-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\WaitForNode.lua

local Class = require("Core.Framework.Class")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local WaitForNode = Class.LiteClass("WaitForNode", ListenBaseNode)

function WaitForNode:ctor(nodeId, nodeData, graph)
	WaitForNode.super.ctor(self, nodeId, nodeData, graph)
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function WaitForNode:registerPorts()
	WaitForNode.super.registerPorts(self)

	self.valueInput_EventName = self:addValueInput("EventName")
	self.flowOut_Out = self:addFlowOutput("Out")
end

function WaitForNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId
	local eventName = self:getContextValue(context, self.valueInput_EventName)

	eventName = eventName .. sandboxId

	local function listener()
		self:removeTimer(context)
		self:checkDoOnce(context)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return WaitForNode
