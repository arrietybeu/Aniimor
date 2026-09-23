-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBaseOpComponent.lua

local Class = require("Core.Framework.Class")
local math_random = math.random
local table_nums = table.nums
local next = next
local IBaseOpComponent = Class.Component("IBaseOpComponent")

function IBaseOpComponent:add(op1, op2)
	return op1 + op2
end

function IBaseOpComponent:sub(op1, op2)
	return op1 - op2
end

function IBaseOpComponent:mul(op1, op2)
	return op1 * op2
end

function IBaseOpComponent:div(op1, op2)
	return op1 / op2
end

function IBaseOpComponent:mod(op1, op2)
	return op1 % op2
end

function IBaseOpComponent:isGreaterThan(op1, op2)
	return op2 < op1
end

function IBaseOpComponent:isGreaterOrEqual(op1, op2)
	return op2 <= op1
end

function IBaseOpComponent:isLessThan(op1, op2)
	return op1 < op2
end

function IBaseOpComponent:isLessOrEqual(op1, op2)
	return op1 <= op2
end

function IBaseOpComponent:isEqual(op1, op2)
	return op1 == op2
end

function IBaseOpComponent:isNil(op1)
	return op1 == nil
end

function IBaseOpComponent:isTableEmpty(op1)
	return not op1 or next(op1) == nil
end

function IBaseOpComponent:randomInteger(min, max)
	return math_random(min, max)
end

function IBaseOpComponent:getTableLength(tab)
	return tab and table_nums(tab) or 0
end

function IBaseOpComponent:getTableValueByKey(tab, key)
	if tab then
		return tab[key]
	end
end

return IBaseOpComponent
