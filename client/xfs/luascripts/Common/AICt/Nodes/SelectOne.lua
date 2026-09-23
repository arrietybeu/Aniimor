-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AICt\\Nodes\\SelectOne.lua

local CTRNode = require("Common.AICt.CTRNode")
local Class = require("Core.Framework.Class")
local SelectOne = Class.LightClass("SelectOne", CTRNode)
local SelectorType = {
	List = 1,
	Table = 2
}
local SelectorMethod = {
	Random = 3,
	Min = 2,
	Max = 1
}
local Field = {
	Value = 2,
	Key = 1
}

function SelectOne:registerPorts()
	self.valueInput_inTable = self:addValueInput("inTable")

	self:addValueOutput("out", function(flow)
		return self:get_out_Value(flow)
	end)
end

function SelectOne:get_out_Value(flow)
	local elements = self:getInputValue(self.valueInput_inTable, flow)
	local retKey, retValue

	if self.nodeData.selectorType == SelectorType.List then
		retKey, retValue = self:selectList(elements)
	else
		retKey, retValue = self:selectTable(elements)
	end

	if self.nodeData.outField == Field.Key then
		return retKey
	else
		return retValue
	end
end

function SelectOne:selectList(elements)
	if elements == nil or #elements == 0 then
		return
	end

	local key1 = 1
	local value1 = elements[key1]

	for i = 2, #elements do
		local key2 = i
		local value2 = elements[key2]

		key1, value1 = self:selectorMethod(key1, value1, key2, value2)
	end

	return key1, value1
end

function SelectOne:selectTable(elements)
	if elements == nil or next(elements) == nil then
		return
	end

	local key1 = next(elements)
	local value1 = elements[key1]

	for key2, value2 in pairs(elements) do
		key1, value1 = self:selectorMethod(key1, value1, key2, value2)
	end

	return key1, value1
end

function SelectOne:selectorMethod(key1, value1, key2, value2)
	if self.nodeData.selectorMethod == SelectorMethod.Max then
		return self:maxMethod(key1, value1, key2, value2)
	elseif self.nodeData.selectorMethod == SelectorMethod.Min then
		return self:minMethod(key1, value1, key2, value2)
	elseif self.nodeData.selectorMethod == SelectorMethod.Random then
		return self:randomMethod(key1, value1, key2, value2)
	end

	return key1, value1
end

function SelectOne:maxMethod(key1, value1, key2, value2)
	if self.nodeData.selectorField == Field.Key then
		if key2 < key1 then
			return key1, value1
		else
			return key2, value2
		end
	elseif value2 < value1 then
		return key1, value1
	else
		return key2, value2
	end
end

function SelectOne:minMethod(key1, value1, key2, value2)
	if self.nodeData.selectorField == Field.Key then
		if key1 < key2 then
			return key1, value1
		else
			return key2, value2
		end
	elseif value1 < value2 then
		return key1, value1
	else
		return key2, value2
	end
end

function SelectOne:randomMethod(key1, value1, key2, value2)
	local random = math.random(1, 2)

	if random == 1 then
		return key1, value1
	else
		return key2, value2
	end
end

return SelectOne
