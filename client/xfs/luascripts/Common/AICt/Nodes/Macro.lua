-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Macro.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local Macro = Class.LightClass("Macro", CTRNode)
local ConditionGraphData = require("Common.Data.AICtrData.aictr_condition_graph_data")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Macro")

function Macro:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = ConditionGraphData[self.nodeData.graphName] or {}

	self.cInPorts = rawData.inPorts or {}
	self.cOutPorts = rawData.outPorts or {}
end

function Macro:registerPorts()
	for k, _ in pairs(self.cInPorts) do
		self[k] = self:addValueInput(k)
	end

	for k, _ in pairs(self.cOutPorts) do
		self:addValueOutput(k, function(flow)
			return self:get_out_Value(flow, k)
		end)
	end
end

function Macro:get_out_Value(flow, pName)
	local graphId = self.nodeData.graphName

	flow.subContext = flow.subContext or {}
	flow.subContext[graphId] = flow.subContext[graphId] or {}

	local context = flow.subContext[graphId]

	for k, v in pairs(self.cInPorts) do
		context[k] = self:getInputValue(self[k], flow)
	end

	local graph = ConditionUtils.getGraph(graphId)

	if graph == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("【Macro】:Condition graph not found! - " .. graphId)
		end

		return false
	end

	local res = graph:onGetConditionGraphPortRes(flow, pName)

	return res
end

return Macro
