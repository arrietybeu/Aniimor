-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SwitchIntListNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SwitchIntListNode = Class.LiteClass("SwitchIntListNode", FlowNode)

function SwitchIntListNode:ctor(nodeId, nodeData, graph)
	SwitchIntListNode.super.ctor(self, nodeId, nodeData, graph)
end

function SwitchIntListNode:registerPorts()
	self:addFlowInput("In", function(context, inputPortName)
		self:On_In_PortCalled(context, inputPortName)
	end)

	local targetInts = self.nodeData.targetInts or {
		0,
		1,
		2
	}

	self.valueInput_Value = self:addValueInput("Value")

	local uniqueInts = {}
	local seen = {}

	for _, v in ipairs(targetInts) do
		if not seen[v] then
			seen[v] = true

			table.insert(uniqueInts, v)
		end
	end

	table.sort(uniqueInts)

	for _, intValue in ipairs(uniqueInts) do
		self["flowOut_" .. intValue] = self:addFlowOutput(tostring(intValue))
	end

	self.flowOut_Default = self:addFlowOutput("Default")
end

function SwitchIntListNode:On_In_PortCalled(context, inputPortName)
	local value = self:getContextValue(context, self.valueInput_Value)

	if not value then
		return
	end

	if self["flowOut_" .. value] then
		self["flowOut_" .. value]:call(context)
	else
		self.flowOut_Default:call(context)
	end
end

return SwitchIntListNode
