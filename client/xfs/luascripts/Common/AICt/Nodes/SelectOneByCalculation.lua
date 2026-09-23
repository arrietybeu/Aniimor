-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SelectOneByCalculation.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local SelectOneByCalculation = Class.LightClass("SelectOneByCalculation", CTRNode)
local SelectorMethod = {
	Min = 2,
	Max = 1
}

function SelectOneByCalculation:registerPorts()
	self.valueInTable = self:addValueInput("inTable")
	self.valueCalcResult = self:addValueInput("calcResult")

	self:addValueOutput("out", function(flow)
		return self:Get_out_Value(flow)
	end)
	self:addValueOutput("element", function(flow)
		return self:Get_element_Value(flow)
	end)
end

function SelectOneByCalculation:_doCompare(retA, retB)
	if not retA then
		return false
	end

	if not retB then
		return true
	end

	if self.nodeData.selectorMethod == SelectorMethod.Max then
		return retB < retA
	else
		return retA < retB
	end
end

function SelectOneByCalculation:Get_out_Value(flow)
	local elements = self:getInputValue(self.valueInTable, flow)

	if elements == nil then
		return nil
	end

	local finalElement, finalCalcRet

	for _, v in ipairs(elements) do
		self.curElement = v

		local calcRet = self:getInputValue(self.valueCalcResult, flow)

		if self:_doCompare(calcRet, finalCalcRet) then
			finalElement = self.curElement
			finalCalcRet = calcRet
		end
	end

	return finalElement
end

function SelectOneByCalculation:Get_element_Value(flow)
	return self.curElement
end

return SelectOneByCalculation
