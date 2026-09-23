-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\MacroIn.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local MacroIn = Class.LightClass("MacroIn", CTRNode)
local ConditionGraphData = require("Common.Data.AICtrData.aictr_condition_graph_data")

function MacroIn:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = ConditionGraphData[self.graph.graphId] or {}

	self.cInPorts = rawData.inPorts or {}
end

function MacroIn:registerPorts()
	for k, v in pairs(self.cInPorts) do
		self:addValueOutput(k, function(flow)
			return self:get_parent_port_value(flow, k, v)
		end)
	end
end

function MacroIn:get_parent_port_value(flow, pName, defaultValue)
	local subContext = flow.subContext[self.graph.graphId] or {}

	if subContext[pName] ~= nil then
		return subContext[pName]
	else
		return defaultValue
	end
end

return MacroIn
