-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\MethodOrIndex.lua

local class = require("Core.Framework.Class")
local MethodOrIndex = class.Class("MethodOrIndex")
local DEFAULT_START_INDEX = 129

function MethodOrIndex:ctor()
	self.method2Index = {}
	self.index2Method = {}
	self.startIndex = DEFAULT_START_INDEX
end

function MethodOrIndex:addRelation(method, index)
	self.method2Index[method] = index
	self.index2Method[index] = method
end

function MethodOrIndex:encode(method)
	local index = self.method2Index[method]

	if index ~= nil then
		return "", index, false
	end

	index = self.startIndex
	self.startIndex = self.startIndex + 1
	self.method2Index[method] = index
	self.index2Method[index] = method

	return "", index, true
end

function MethodOrIndex:decode(index)
	return self.index2Method[index]
end

function MethodOrIndex:clear()
	self.method2Index = {}
	self.index2Method = {}
	self.startIndex = DEFAULT_START_INDEX
end

function MethodOrIndex:destroy()
	self.method2Index = nil
	self.index2Method = nil
end

return MethodOrIndex
