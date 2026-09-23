-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\PortInBridge.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local PortInBridge = Class.LightClass("PortInBridge", CTRNode)
local SubGraphData = require("Common.Data.AICtrData.aictr_sub_graph_data")

function PortInBridge:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = SubGraphData[graph.graphId] or {}

	self.cInPorts = rawData.inPorts or {}
end

function PortInBridge:registerPorts()
	self.flowOut = self:addFlowOutput("flowOut")

	for k, v in pairs(self.cInPorts) do
		self:addValueOutput(k, function(flow)
			if flow.context[k] ~= nil then
				return flow.context[k]
			else
				return v
			end
		end)
	end
end

function PortInBridge:executeTrigger(flow)
	self:callFlowOut(self.flowOut, flow)
end

return PortInBridge
