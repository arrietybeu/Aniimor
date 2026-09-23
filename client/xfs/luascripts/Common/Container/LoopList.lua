-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\LoopList.lua

local Class = require("Core.Framework.Class")
local LoopList = Class.LiteClass("LoopList")

function LoopList:ctor(length, addReplace, addFun)
	self._data = {}
	self._dataLength = length + 1
	self._currentVirtualStartIndex = 0
	self._currentVirtualEndIndex = 0

	if addReplace == nil then
		self._addReplace = true
	else
		self._addReplace = addReplace
	end

	self._addFun = addFun
end

function LoopList:_indexValid(virtualIndex)
	if self._currentVirtualStartIndex > self._currentVirtualEndIndex then
		return virtualIndex >= self._currentVirtualStartIndex or virtualIndex <= self._currentVirtualEndIndex
	end

	return virtualIndex >= self._currentVirtualStartIndex and virtualIndex < self._currentVirtualEndIndex
end

function LoopList:getCount()
	return (self._currentVirtualEndIndex - self._currentVirtualStartIndex + self._dataLength) % self._dataLength
end

function LoopList:getIndex(index)
	if index >= self._dataLength or index < 0 then
		return nil
	end

	local virtualIndex = (self._currentVirtualStartIndex + index) % self._dataLength

	if self:_indexValid(virtualIndex) == false then
		return nil
	end

	return self._data[virtualIndex]
end

function LoopList:add(value)
	if self:isFull() then
		if self._addReplace == true then
			if self._addFun then
				self._addFun(self._data, self._currentVirtualEndIndex, value)
			else
				self._data[self._currentVirtualEndIndex] = value
			end

			self._currentVirtualEndIndex = (self._currentVirtualEndIndex + 1) % self._dataLength
			self._currentVirtualStartIndex = (self._currentVirtualStartIndex + 1) % self._dataLength
		end
	else
		if self._addFun then
			self._addFun(self._data, self._currentVirtualEndIndex, value)
		else
			self._data[self._currentVirtualEndIndex] = value
		end

		self._currentVirtualEndIndex = (self._currentVirtualEndIndex + 1) % self._dataLength
	end
end

function LoopList:clear()
	self._currentVirtualStartIndex = self._currentVirtualEndIndex
end

function LoopList:isEmpty()
	return self._currentVirtualEndIndex == self._currentVirtualStartIndex
end

function LoopList:isFull()
	return (self._currentVirtualEndIndex + 1) % self._dataLength == self._currentVirtualStartIndex
end

function LoopList:removeLast()
	local virtualIndex = (self._currentVirtualEndIndex - 1 + self._dataLength) % self._dataLength

	if self:_indexValid(virtualIndex) then
		self._currentVirtualEndIndex = virtualIndex

		return true
	end

	return false
end

function LoopList:removeFirst()
	if self:_indexValid(self._currentVirtualStartIndex) then
		self._currentVirtualStartIndex = (self._currentVirtualStartIndex + 1) % self._dataLength

		return true
	end

	return false
end

function LoopList:getFirst()
	return self:getIndex(0)
end

function LoopList:getLast()
	return self:getIndex(self:getCount() - 1)
end

return LoopList
