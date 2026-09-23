-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaCSharpList.lua

local LuaCSharpArr = require("Utils.LuaCSharpArr")
local TYPE_INT = "int"
local TYPE_DOUBLE = "double"
local COUNT_INDEX = 1
local DATA_START_INDEX = 2
local LuaCSharpList = {
	class = "LuaCSharpList"
}

setmetatable(LuaCSharpList, LuaCSharpList)

function LuaCSharpList.__index(_, k)
	return rawget(LuaCSharpList, k)
end

local function checkCapacity(capacity)
	if type(capacity) ~= "number" or capacity < 0 or capacity % 1 ~= 0 then
		error(string.format("LuaCSharpList capacity must be a non-negative integer, got %s", tostring(capacity)), 3)
	end
end

local function checkIndex(self, index, upper, upperLabel)
	if type(index) ~= "number" or index % 1 ~= 0 then
		error(string.format("LuaCSharpList index must be an integer, got %s", tostring(index)), 3)
	end

	if index < 1 or upper < index then
		error(string.format("LuaCSharpList index out of range, index=%d %s=%d", index, upperLabel, upper), 3)
	end
end

local function checkType(valueType, value)
	if type(value) ~= "number" then
		error(string.format("LuaCSharpList %s value must be number, got %s", valueType, type(value)), 3)
	end

	if valueType == TYPE_INT and value % 1 ~= 0 then
		error(string.format("LuaCSharpList int value must be integer, got %s", tostring(value)), 3)
	end
end

local function getDefaultValue(valueType, defaultVal)
	if defaultVal == nil then
		return 0
	end

	checkType(valueType, defaultVal)

	return defaultVal
end

local function physicalIndex(index)
	return DATA_START_INDEX + index - 1
end

local function setCountRaw(self, count)
	self.__count = count

	rawset(self, COUNT_INDEX, count)
end

local function initMeta(self, valueType, capacity, count)
	rawset(self, "__valueType", valueType)
	rawset(self, "__capacity", capacity)
	rawset(self, "__count", count or 0)
	setmetatable(self, LuaCSharpList)
	rawset(self, COUNT_INDEX, self.__count)

	return self
end

local function newList(valueType, capacity, defaultVal)
	checkCapacity(capacity)

	local value = getDefaultValue(valueType, defaultVal)
	local data = {}

	data[COUNT_INDEX] = 0

	for i = 1, capacity do
		data[physicalIndex(i)] = value
	end

	return initMeta(data, valueType, capacity, 0)
end

local function newByTable(valueType, tbl, capacity)
	if type(tbl) ~= "table" then
		error(string.format("LuaCSharpList source must be table, got %s", type(tbl)), 3)
	end

	local count = #tbl
	local finalCapacity = capacity or count

	checkCapacity(finalCapacity)

	if finalCapacity < count then
		error(string.format("LuaCSharpList capacity too small, capacity=%d count=%d", finalCapacity, count), 3)
	end

	local data = {}

	data[COUNT_INDEX] = count

	for i = 1, count do
		local value = tbl[i]

		if value == nil then
			error(string.format("LuaCSharpList source must be a dense array, nil at index %d", i), 3)
		end

		checkType(valueType, value)

		data[physicalIndex(i)] = value
	end

	local defaultVal = 0

	for i = count + 1, finalCapacity do
		data[physicalIndex(i)] = defaultVal
	end

	return initMeta(data, valueType, finalCapacity, count)
end

function LuaCSharpList.newInt(capacity, defaultVal)
	return newList(TYPE_INT, capacity, defaultVal)
end

function LuaCSharpList.newDouble(capacity, defaultVal)
	return newList(TYPE_DOUBLE, capacity, defaultVal)
end

function LuaCSharpList.newByTableInt(tbl, capacity)
	return newByTable(TYPE_INT, tbl, capacity)
end

function LuaCSharpList.newByTableDouble(tbl, capacity)
	return newByTable(TYPE_DOUBLE, tbl, capacity)
end

function LuaCSharpList:getCount()
	return self.__count
end

function LuaCSharpList:setCount(count)
	checkCapacity(count)

	if count > self.__capacity then
		error(string.format("LuaCSharpList count out of range, count=%d capacity=%d", count, self.__capacity), 2)
	end

	setCountRaw(self, count)
end

function LuaCSharpList:getCapacity()
	return self.__capacity
end

function LuaCSharpList:getValueType()
	return self.__valueType
end

function LuaCSharpList:get(index)
	checkIndex(self, index, self.__count, "count")

	return rawget(self, physicalIndex(index))
end

function LuaCSharpList:rawGet(index)
	checkIndex(self, index, self.__capacity, "capacity")

	return rawget(self, physicalIndex(index))
end

function LuaCSharpList:set(index, value)
	checkIndex(self, index, self.__capacity, "capacity")
	checkType(self.__valueType, value)
	rawset(self, physicalIndex(index), value)

	if index > self.__count then
		setCountRaw(self, index)
	end
end

function LuaCSharpList:rawSet(index, value)
	checkIndex(self, index, self.__capacity, "capacity")
	checkType(self.__valueType, value)
	rawset(self, physicalIndex(index), value)
end

function LuaCSharpList:push(value)
	if self.__count >= self.__capacity then
		error(string.format("LuaCSharpList push overflow, count=%d capacity=%d", self.__count, self.__capacity), 2)
	end

	self:set(self.__count + 1, value)
end

function LuaCSharpList:clear()
	setCountRaw(self, 0)
end

function LuaCSharpList:getCSharpAccess()
	return LuaCSharpArr.GetCSharpAccess(self)
end

function LuaCSharpList:destroyCSharpAccess()
	LuaCSharpArr.DestroyCSharpAccess(self)
end

return LuaCSharpList
