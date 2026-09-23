-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\MacroOut.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local MacroOut = Class.LightClass("MacroOut", CTRNode)
local ConditionGraphData = require("Common.Data.AICtrData.aictr_condition_graph_data")

function MacroOut:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = ConditionGraphData[self.graph.graphId] or {}

	self.cOutPorts = rawData.outPorts or {}
end

function MacroOut:registerPorts()
	for k, _ in pairs(self.cOutPorts) do
		self[k] = self:addValueInput(k)
	end
end

function MacroOut:getPortValue(flow, pName)
	return self:getInputValue(self[pName], flow)
end

return MacroOut
