-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ResetNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ResetNode = Class.LiteClass("ResetNode", FlowNode)

function ResetNode:ctor(nodeId, nodeData, graph)
	ResetNode.super.ctor(self, nodeId, nodeData, graph)
end

function ResetNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)
end

function ResetNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space then
		return
	end

	local sandboxId = context.sandboxId

	space:resetSandbox(sandboxId)
end

return ResetNode
