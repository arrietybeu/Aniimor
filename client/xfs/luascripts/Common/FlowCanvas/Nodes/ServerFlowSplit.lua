-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\ServerFlowSplit.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local ServerFlowSplit = Class.LiteClass("ServerFlowSplit", FlowNode)

function ServerFlowSplit:ctor(nodeId, nodeData, graph)
	ServerFlowSplit.super.ctor(self, nodeId, nodeData, graph)
end

function ServerFlowSplit:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	local portCount = self.nodeData.portCount or 5

	for i = 1, portCount do
		self["flowOut_" .. i] = self:addFlowOutput(tostring(i))
	end
end

function ServerFlowSplit:On_In_PortCalled(context, inputPortName)
	local portCount = self.nodeData.portCount or 5

	for i = 1, portCount do
		self["flowOut_" .. i]:call(context)
	end
end

return ServerFlowSplit
