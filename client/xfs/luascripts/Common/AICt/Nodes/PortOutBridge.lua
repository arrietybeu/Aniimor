-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\PortOutBridge.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local PortOutBridge = Class.LightClass("PortOutBridge", CTRNode)
local SubGraphData = require("Common.Data.AICtrData.aictr_sub_graph_data")

function PortOutBridge:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = SubGraphData[graph.graphId] or {}

	self.cOutPorts = rawData.outPorts or {}
end

function PortOutBridge:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		flow:continue()
	end)

	for k, _ in pairs(self.cOutPorts) do
		self[k] = self:addValueInput(k)
	end
end

function PortOutBridge:getPortValue(flow, pName)
	return self:getInputValue(self[pName], flow)
end

return PortOutBridge
