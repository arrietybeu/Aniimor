-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\DoGraph.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local DoGraph = Class.LightClass("DoGraph", CTRNode)
local CTRConst = require("Common.AICt.CTRConst")
local SubGraphData = require("Common.Data.AICtrData.aictr_sub_graph_data")
local ConditionUtils = require("Common.AICt.ConditionUtils")
local CTRPool = require("Common.AICt.CTRPool")
local TablePool = require("Common.Container.TablePool")

function DoGraph:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	local rawData = SubGraphData[self.nodeData.graphName] or {}

	self.cInPorts = rawData.inPorts or {}
	self.cOutPorts = rawData.outPorts or {}
end

function DoGraph:registerPorts()
	self:addFlowInput("flowIn", function(flow)
		self:On_In_PortCalled(flow)
	end)

	self.flowOut = self:addFlowOutput("flowOut")
	self.condition = self:addValueInput("condition")

	for k, _ in pairs(self.cInPorts) do
		self[k] = self:addValueInput(k)
	end

	for k, _ in pairs(self.cOutPorts) do
		self:addValueOutput(k, function(flow)
			return self:get_out_Value(flow, k)
		end)
	end
end

function DoGraph:On_In_PortCalled(flow)
	if self:onCallFlowInternal(flow) == false then
		return
	end

	self:callFlowOut(self.flowOut, flow)
end

function DoGraph:onCallFlowInternal(flow)
	local cd = self:getInputValue(self.condition, flow)

	self:checkCondition(cd, flow)

	if not cd then
		return false
	end

	local graphId = self.nodeData.graphName
	local context = TablePool.getTable(3)

	context._entActorId = flow.context._entActorId
	context._behaviorId = flow.context._behaviorId

	for k, _ in pairs(self.cInPorts) do
		context[k] = self:getInputValue(self[k], flow)
	end

	ConditionUtils.DoSubGraph(flow, graphId, context)
	TablePool.returnTable(context, 3)

	if flow.__subFlow and flow.__subFlow:checkIsFinished() then
		return true
	end

	flow:setContinueNode(self)

	return false
end

function DoGraph:doFlowOut(flow)
	if flow.__subFlow ~= nil and flow.__subFlow:continue() then
		flow:setContinueNode(self)

		return
	end

	DoGraph.super.doFlowOut(self, flow)
end

function DoGraph:onDispose(flow)
	if flow.__subFlow ~= nil then
		flow.__subFlow:dispose()
	end
end

function DoGraph:GetInterruptResult(flow)
	if flow.__subFlow ~= nil then
		return flow.__subFlow:checkInterruptable()
	end

	return false
end

function DoGraph:get_out_Value(flow, pName)
	return false
end

return DoGraph
