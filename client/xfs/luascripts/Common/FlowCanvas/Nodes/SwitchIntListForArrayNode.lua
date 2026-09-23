-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\SwitchIntListForArrayNode.lua

local Class = require("Core.Framework.Class")
local FlowNode = require("Common.FlowCanvas.Nodes.FlowNode")
local SwitchIntListForArrayNode = Class.LiteClass("SwitchIntListForArrayNode", FlowNode)

function SwitchIntListForArrayNode:ctor(nodeId, nodeData, graph)
	SwitchIntListForArrayNode.super.ctor(self, nodeId, nodeData, graph)
end

function SwitchIntListForArrayNode:registerPorts()
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

function SwitchIntListForArrayNode:CallFlowByValue(context, value)
	if self["flowOut_" .. value] then
		self["flowOut_" .. value]:call(context)

		return true
	end

	return false
end

function SwitchIntListForArrayNode:On_In_PortCalled(context, inputPortName)
	local value = self:getContextValue(context, self.valueInput_Value)

	if not value then
		return
	end

	if type(value) ~= "table" then
		if not self:CallFlowByValue(context, value) then
			self.flowOut_Default:call(context)
		end

		return
	end

	for _, intValue in ipairs(value) do
		if not self:CallFlowByValue(context, intValue) then
			self.flowOut_Default:call(context)
		end
	end
end

return SwitchIntListForArrayNode
