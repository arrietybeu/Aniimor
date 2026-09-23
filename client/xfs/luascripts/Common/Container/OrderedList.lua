-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\OrderedList.lua

local Class = require("Core.Framework.Class")
local Bisect = require("Common.Utils.Bisect")
local OrderedList = Class.LightClass("OrderedList")

function OrderedList:ctor(key_func)
	self.elements = {}
	self.key_func = key_func
	self.elementKeys = setmetatable({}, {
		__index = function(t, k)
			return self:getOrderKey(self.elements[k])
		end
	})
end

function OrderedList:add(ele)
	local key = self:getOrderKey(ele)
	local index = Bisect.bisect(self.elementKeys, key, nil, #self.elements)

	table.insert(self.elements, index, ele)
end

function OrderedList:getOrderKey(ele)
	return self.key_func and self.key_func(ele) or ele
end

function OrderedList:get(index)
	return self.elements[index]
end

function OrderedList:getLength()
	return #self.elements
end

return OrderedList
