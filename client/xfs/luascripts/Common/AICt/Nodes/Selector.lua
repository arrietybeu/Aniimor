-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\Selector.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local Selector = Class.LightClass("Selector", CTRNode)
local SelectorType = {
	Table = 2,
	List = 1
}
local SelectorMethod = {
	Key = 1,
	value = 2
}

function Selector:ctor(nodeId, nodeData, graph)
	CTRNode.ctor(self, nodeId, nodeData, graph)

	self.selectTmp = nil
end

function Selector:registerPorts()
	self.valueInput_inTable = self:addValueInput("inTable")
	self.valueInput_condition = self:addValueInput("condition")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
	self:addValueOutput("element", function(flow)
		return self:Get_element_Value(flow)
	end)
end

function Selector:Get_out_Value(flow)
	local elements = self:getInputValue(self.valueInput_inTable, flow)

	if elements == nil then
		return
	end

	local enough

	if self.nodeData.selectorType == SelectorType.List then
		for k, v in ipairs(elements) do
			self.selectTmp = self.nodeData.selectorMethod == SelectorMethod.Key and k or v

			local res = self:getInputValue(self.valueInput_condition, flow)

			if res then
				if enough == nil then
					enough = flow:getTempList()
				end

				enough[#enough + 1] = self.selectTmp
			end
		end
	else
		for k, v in pairs(elements) do
			self.selectTmp = self.nodeData.selectorMethod == SelectorMethod.Key and k or v

			local res = self:getInputValue(self.valueInput_condition, flow)

			if res then
				if enough == nil then
					enough = flow:getTempList()
				end

				enough[#enough + 1] = self.selectTmp
			end
		end
	end

	return enough
end

function Selector:Get_element_Value()
	return self.selectTmp
end

return Selector
