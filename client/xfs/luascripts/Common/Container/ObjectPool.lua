-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\ObjectPool.lua

local Class = require("Core.Framework.Class")
local ObjectPool = Class.LightClass("ObjectPool")

function ObjectPool:ctor()
	self.availableObjects = {}
	self.maxCount = 0
	self.factoryFunc = nil
	self.clearFunc = nil
end

function ObjectPool:setup(maxCount, factoryFunc, disposeFunc, clearFun)
	if factoryFunc ~= nil and type(factoryFunc) == "function" then
		self.factoryFunc = factoryFunc
	end

	if disposeFunc ~= nil and type(disposeFunc) == "function" then
		self.disposeFunc = disposeFunc
	end

	if clearFun ~= nil and type(clearFun) == "function" then
		self.clearFunc = clearFun
	end

	self:setMaxCount(maxCount)
end

function ObjectPool:setMaxCount(maxCount)
	self.maxCount = maxCount

	self:shrinkPool()
end

function ObjectPool:get(create)
	local count = #self.availableObjects

	if count > 0 then
		local ret = self.availableObjects[count]

		self.availableObjects[count] = nil

		return ret
	end

	if create and self.factoryFunc ~= nil then
		return self.factoryFunc()
	end

	return nil
end

function ObjectPool:getWithCtor(create, ...)
	local obj = self:get(create)

	if obj.ctor then
		obj:ctor(...)
	end

	return obj
end

function ObjectPool:returnObject(obj)
	if obj == nil then
		return
	end

	local count = #self.availableObjects

	if count >= self.maxCount then
		if self.disposeFunc then
			self.disposeFunc(obj)
		end

		if self.clearFunc then
			self.clearFunc(obj)
		end

		return
	end

	self.availableObjects[#self.availableObjects + 1] = obj

	if self.clearFunc then
		self.clearFunc(obj)
	end
end

function ObjectPool:isFull()
	return #self.availableObjects >= self.maxCount
end

function ObjectPool:shrinkPool()
	local disposeFunc = self.disposeFunc

	while #self.availableObjects > self.maxCount do
		local index = #self.availableObjects

		if disposeFunc then
			disposeFunc(self.availableObjects[index])
		end

		self.availableObjects[index] = nil
	end
end

function ObjectPool:clear()
	local disposeFunc = self.disposeFunc

	if disposeFunc then
		for _, obj in pairs(self.availableObjects) do
			disposeFunc(obj)
		end
	end

	self.availableObjects = {}
end

return ObjectPool
