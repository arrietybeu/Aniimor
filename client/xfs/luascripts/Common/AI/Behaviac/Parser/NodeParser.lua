-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\NodeParser.lua

local _M = {}
local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local ParamAdapter = require("Common.AI.Behaviac.Parser.ParamAdapter")
local ParamAdapterNew = require("Common.AI.Behaviac.Parser.ParamAdapterNew")
local PrototypeAdapter = require("Common.AI.Behaviac.Parser.PrototypeAdapter")
local EOperatorType = enums.EOperatorType
local StringUtils = common.StringUtils

function _M.parseMethod(methodInfo)
	return ParamAdapterNew.new(enums.ParamAdapterNewType.SelfMethod, methodInfo), methodInfo.func
end

function _M.parseResetStateMethod(methodInfo)
	return ParamAdapterNew.new(enums.ParamAdapterNewType.SelfMethod__resetState, methodInfo), methodInfo.func
end

function _M.parseTaskPrototype(prototypeInfo)
	if StringUtils.isNullOrEmpty(prototypeInfo) then
		return nil, false
	end

	local prototypeName, paramStr = string.gmatch(prototypeInfo, "(.+%..+::.+)%((.*)%)")()

	macros.BEHAVIAC_ASSERT(prototypeName, "[_M.parseTaskPrototype()] " .. prototypeInfo)

	local prototype = PrototypeAdapter.new()

	prototype:buildTaskPrototype(prototypeName, paramStr)

	return prototype, prototypeName
end

function _M.parseProperty(propertyStr)
	return ParamAdapterNew.new(enums.ParamAdapterNewType.Field, propertyStr)
end

function _M.parseSubTreeProperty(subTreeProperties)
	local retProperties = {}

	if #subTreeProperties > 0 then
		for _, propTable in ipairs(subTreeProperties) do
			local prop = {}
			local paramProp = ParamAdapterNew.new(enums.ParamAdapterNewType.Field, propTable.Value)

			prop.Name = propTable.Name
			prop.Value = paramProp

			table.insert(retProperties, prop)
		end
	end

	return retProperties
end

function _M.parseMethodOutMethodName(methodInfo)
	return _M.parseMethod(methodInfo, true)
end

local operator_type_parser_ = {
	Invalid = EOperatorType.E_INVALID,
	Assign = EOperatorType.E_ASSIGN,
	Add = EOperatorType.E_ADD,
	Sub = EOperatorType.E_SUB,
	Mul = EOperatorType.E_MUL,
	Div = EOperatorType.E_DIV,
	Equal = EOperatorType.E_EQUAL,
	NotEqual = EOperatorType.E_NOTEQUAL,
	Greater = EOperatorType.E_GREATER,
	Less = EOperatorType.E_LESS,
	GreaterEqual = EOperatorType.E_GREATEREQUAL,
	LessEqual = EOperatorType.E_LESSEQUAL
}

function _M.parseOperatorType(operatorTypeStr)
	return operator_type_parser_[operatorTypeStr]
end

return _M
