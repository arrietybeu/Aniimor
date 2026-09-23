-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SwitchValue.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local SwitchValue = Class.LightClass("SwitchValue", CTRNode)

function SwitchValue:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)
end

function SwitchValue:registerPorts()
	local cdCount = self.nodeData.numb

	self.conditions = {}
	self.cases = {}

	for i = 1, cdCount do
		self.conditions[i] = self:addValueInput("condition" .. i - 1)
		self.cases[i] = self:addValueInput("case" .. i - 1)
	end

	self.default_Input = self:addValueInput("default")

	self:addValueOutput("result", function(flow)
		return self:Get_result_Value(flow)
	end)
end

function SwitchValue:Get_result_Value(flow)
	for i, v in ipairs(self.conditions) do
		local condition = self:getInputValue(v, flow)

		if condition then
			return self:getInputValue(self.cases[i], flow)
		end
	end

	return self:getInputValue(self.default_Input, flow)
end

return SwitchValue
