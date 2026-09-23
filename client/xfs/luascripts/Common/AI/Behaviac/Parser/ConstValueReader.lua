-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\ConstValueReader.lua

local _M = {}
local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local constCharByte = enums.constCharByte
local EBTStatus = enums.EBTStatus
local Logging = common.d_log
local StringUtils = common.StringUtils
local EnumBehaviorAction = BaseEnum.EBTBehaviorAction
local basic_type_value_read_func_ = {
	bool = function(str)
		if str == "true" then
			return true
		else
			return false
		end
	end,
	Boolean = function(str)
		if str == "true" then
			return true
		else
			return false
		end
	end,
	byte = tonumber,
	ubyte = tonumber,
	Byte = tonumber,
	char = tonumber,
	Char = tonumber,
	SByte = tonumber,
	decimal = tonumber,
	Decimal = tonumber,
	double = tonumber,
	Double = tonumber,
	float = tonumber,
	int = tonumber,
	Int16 = tonumber,
	Int32 = tonumber,
	Int64 = tonumber,
	long = tonumber,
	llong = tonumber,
	sbyte = tonumber,
	short = tonumber,
	ushort = tonumber,
	uint = tonumber,
	UInt16 = tonumber,
	UInt32 = tonumber,
	UInt64 = tonumber,
	ulong = tonumber,
	ullong = tonumber,
	Single = tonumber,
	number = tonumber,
	table = function(str)
		return load("return " .. str)()
	end,
	string = function(str)
		local str, bQuote = StringUtils.trimEnclosedDoubleQuotes(str)

		return str
	end,
	String = function(str)
		local str, bQuote = StringUtils.trimEnclosedDoubleQuotes(str)

		return str
	end,
	["std::string"] = function(str)
		local str, bQuote = StringUtils.trimEnclosedDoubleQuotes(str)

		return str
	end,
	["char*"] = function(str)
		local str, bQuote = StringUtils.trimEnclosedDoubleQuotes(str)

		return str
	end,
	["const char*"] = function(str)
		local str, bQuote = StringUtils.trimEnclosedDoubleQuotes(str)

		return str
	end,
	["behaviac::EBTStatus"] = function(str)
		return EBTStatus[str]
	end,
	EBTBehaviorAction = function(str)
		return EnumBehaviorAction[str]
	end
}

local function _testIsStruct(valueStr)
	return string.byte(valueStr, 1) == constCharByte.LeftBraces
end

function _M.readAnyType(typeName, valueStr)
	local isArray = false
	local isStruct = false

	if string.find(typeName, "vector<") then
		isArray = true
		typeName = string.gmatch(typeName, "vector<(.+)>")()
	end

	if isArray then
		return _M.readArray(typeName, valueStr), isArray, isStruct
	end

	local f = basic_type_value_read_func_[typeName]

	if f then
		return f(valueStr), isArray, isStruct
	else
		isStruct = _testIsStruct(valueStr)

		if isStruct then
			return _M.readStruct(typeName, valueStr), isArray, isStruct
		else
			return _M.readEnum(typeName, valueStr), isArray, isStruct
		end
	end
end

function _M.readStruct(typeName, valueStr)
	local retStruct = {}
	local tokens = StringUtils.splitTokensForStruct(valueStr)

	for _, expression in ipairs(tokens) do
		local key = expression[1]
		local val = expression[2]
		local strLen = string.len(val)

		if strLen > 0 then
			if _testIsStruct(val) then
				retStruct[key] = _M.readStruct(typeName, val)
			else
				local isArray, posEnd, elements = StringUtils.checkArrayString(val, 1, strLen)

				if isArray then
					local arrayT = {}

					for _, e in ipairs(elements) do
						table.insert(arrayT, _M.readStruct(typeName, e))
					end

					retStruct[key] = arrayT
				else
					retStruct[key] = val
				end
			end
		end
	end

	return retStruct
end

function _M.readEnum(typeName, valueStr)
	return AgentMeta.getEnum(typeName, valueStr)
end

function _M.readArray(typeName, valueStr)
	local retArray = {}
	local retData = StringUtils.split(valueStr, ":")

	if #retData > 1 then
		local arrayData = StringUtils.split(retData[2], "|")

		for _, v in ipairs(arrayData) do
			local singleValue = _M.readAnyType(typeName, v)

			table.insert(retArray, singleValue)
		end
	end

	return retArray
end

return _M
