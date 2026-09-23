-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\ParamAdapter.lua

local unpack = unpack or table.unpack
local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EOperatorType = enums.EOperatorType
local EOperatorName = enums.EOperatorName
local constCharByte = enums.constCharByte
local constPropertyValueType = enums.constPropertyValueType
local StringUtils = common.StringUtils
local ParamAdapter = functions.class("ParamAdapter")

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("ParamAdapter", ParamAdapter)

local _M = ParamAdapter
local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ParamAdapter")

function _M:ctor()
	self.isMethod = false
	self.intanceName = false
	self.className = false
	self.paramName = false
	self.type = constPropertyValueType.default
	self.value = false
	self.setValue = false
	self.valueIsFunction = false
	self.realTypeIsArray = false
	self.realTypeIsStruct = false
	self.realTypeName = false
	self.paramProperties = {}
end

function _M._unpackParams(agent, tick, paramProperties)
	return unpack(_M.unpackParamsTable(agent, tick, paramProperties))
end

function _M.unpackParamsTable(agent, tick, paramProperties)
	local retValues = {}

	for _, paramProp in ipairs(paramProperties) do
		table.insert(retValues, paramProp:getValue(agent, tick))
	end

	return retValues
end

function _M:run(agent, tick)
	if self.isMethod and self.valueIsFunction then
		self.value(agent, tick, _M._unpackParams(agent, tick, self.paramProperties))
	end
end

function _M:runSpecialParam(agent, tick, param)
	if self.isMethod and self.valueIsFunction then
		self.value(agent, tick, param)
	end
end

function _M:setValueCast(agent, tick, opr, cast)
	local result = opr:getValue(agent, tick)

	self.setValue(agent, tick, result)
end

function _M:getValue(agent, tick)
	if not self.isMethod and not self.valueIsFunction then
		return self.value
	end

	return self.value(agent, tick, _M._unpackParams(agent, tick, self.paramProperties))
end

local function _compute(left, right, computeType)
	if type(left) ~= "number" or type(right) ~= "number" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_compute() error!!! left or right is not number.", left, EOperatorName[computeType], right)
		end

		macros.BEHAVIAC_ASSERT(false)
	elseif computeType == EOperatorType.E_ADD then
		return left + right
	elseif computeType == EOperatorType.E_SUB then
		return left - right
	elseif computeType == EOperatorType.E_MUL then
		return left * right
	elseif computeType == EOperatorType.E_DIV then
		if right == 0 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("_compute() error!!! Divide right is zero.", left, EOperatorName[computeType], right)
			end

			return left
		end

		return left / right
	end

	macros.BEHAVIAC_ASSERT(false)

	return left
end

function _M:compute(agent, tick, opr1, opr2, operator)
	local r1 = opr1:getValue(agent, tick)
	local r2 = opr2:getValue(agent, tick)

	if opr1.realTypeIsStruct or opr2.realTypeIsStruct then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[_M:compute()] struct compute is not supported yet!!!", r1, EOperatorName[operator], r2)
		end

		return
	end

	local result = _compute(r1, r2, operator)

	self.setValue(agent, tick, result)
end

local function _compare(left, right, operatorType)
	if left == nil or right == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_compare() failed!!! Left or right operand is nil --", left, EOperatorName[operatorType], right)
		end

		return false
	else
		if operatorType == EOperatorType.E_EQUAL then
			return left == right
		elseif operatorType == EOperatorType.E_NOTEQUAL then
			return left ~= right
		elseif operatorType == EOperatorType.E_GREATER then
			return right < left
		elseif operatorType == EOperatorType.E_GREATEREQUAL then
			return right <= left
		elseif operatorType == EOperatorType.E_LESS then
			return left < right
		elseif operatorType == EOperatorType.E_LESSEQUAL then
			return left <= right
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_compare() failed!!! Unknown operator type --", left, operatorType, right)
		end

		return false
	end
end

local function _compareStruct(left, right, operatorType)
	if left == nil or right == nil then
		logger:error("_compareStruct() failed!!! Left or right operand is nil --", left, EOperatorName[operatorType], right)

		return false
	else
		if operatorType == EOperatorType.E_EQUAL then
			for k, v in pairs(left) do
				if v ~= right[k] then
					return false
				end
			end

			return true
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("_compareStruct() failed!!! Unknown operator type --", left, EOperatorName[operatorType], right)
		end

		return false
	end
end

function _M:compare(agent, tick, opr, operatorType)
	local l = self:getValue(agent, tick)
	local r = opr:getValue(agent, tick)

	if self.realTypeName == opr.realTypeName and (self.realTypeIsStruct or opr.realTypeIsStruct) then
		return _compareStruct(l, r, operatorType)
	else
		return _compare(l, r, operatorType)
	end
end

function _M:buildMethod(intanceName, className, methodName, paramStr)
	self.isMethod = true
	self.intanceName = intanceName
	self.paramName = methodName
	self.paramProperties = _M.s_createParamProperties(paramStr)

	local function methodIsNotImplementedYetError()
		logger:error(intanceName .. "." .. className .. "::" .. methodName .. " --> error: method is not implemented yet!!!")
	end

	function self.value(agent, tick, ...)
		agent[methodName] = agent[methodName] or methodIsNotImplementedYetError

		return agent[methodName](agent, ...)
	end

	self.valueIsFunction = true
end

function _M:getMethodName()
	return self.paramName
end

function _M:buildProperty(propertyStr)
	self.isMethod = false

	local t = type(propertyStr)

	if t == "boolean" then
		self.type = constPropertyValueType.const
		self.value = propertyStr
		self.valueIsFunction = false
		self.realTypeIsArray = false
		self.realTypeIsStruct = false
		self.realTypeName = t
	elseif t == "number" then
		self.type = constPropertyValueType.const
		self.value = propertyStr
		self.valueIsFunction = false
		self.realTypeIsArray = false
		self.realTypeIsStruct = false
		self.realTypeName = t
	elseif t == "string" then
		local tokens = StringUtils.splitTokens(propertyStr)

		if #tokens <= 1 then
			local typeName = "string"
			local valueNum
			local valueStr, bQuote = StringUtils.trimEnclosedDoubleQuotes(propertyStr)

			if not bQuote then
				valueNum = tonumber(valueStr)
				typeName = valueNum and "number"
			end

			self.type = constPropertyValueType.const
			self.value = typeName == "number" and valueNum or valueStr
			self.valueIsFunction = false
			self.realTypeIsArray = false
			self.realTypeIsStruct = false
			self.realTypeName = typeName
		elseif tokens[1] == "const" then
			macros.BEHAVIAC_ASSERT(#tokens == 3, "_M.parseProperty #tokens == 3")

			local typeName = tokens[2]
			local valueStr = tokens[3]
			local isArray = false
			local isStruct = false

			self.type = constPropertyValueType.const
			self.value, isArray, isStruct = ConstValueReader.readAnyType(typeName, valueStr)
			self.valueIsFunction = false
			self.realTypeIsArray = isArray
			self.realTypeIsStruct = isStruct
			self.realTypeName = typeName
		else
			local propStr = ""
			local typeName = ""
			local indexPropStr = ""

			macros.BEHAVIAC_ASSERT(#tokens == 2 or #tokens == 3, "_M.parseProperty non-static #tokens ~= 2, 3")

			typeName = tokens[1]
			propStr = tokens[2]
			self.type = constPropertyValueType.default

			if #tokens >= 3 then
				indexPropStr = tokens[3]
			end

			local indexMember = 0

			if #indexPropStr > 0 then
				indexMember = tonumber(indexPropStr)
			end

			local intanceName, className, propertyName = string.gmatch(propStr, "(.+)%.(.+)::(.+)")()

			macros.BEHAVIAC_ASSERT(propertyName, "_M.parseProperty() property name can't be nil")

			function self.value(agent, tick)
				if tick and tick:getLocalVariable(propertyName) ~= nil then
					return tick:getLocalVariable(propertyName)
				elseif agent:getBlackBoardProperty(propertyName) ~= nil then
					return agent:getBlackBoardProperty(propertyName)
				end

				agent.ent.logger:error("@cyj 未设置该黑板变量值", propertyName)
			end

			function self.setValue(agent, tick, value)
				if tick and tick:getLocalVariable(propertyName) ~= nil then
					tick:setLocalVariable(propertyName, value)

					return
				elseif agent:getBlackBoardProperty(propertyName) ~= nil then
					agent:setBlackBoardProperty(propertyName, value)

					return
				else
					agent:setBlackBoardProperty(propertyName, value)

					return
				end
			end

			self.valueIsFunction = true
			self.realTypeIsArray = false
			self.realTypeIsStruct = false
			self.realTypeName = typeName
		end
	elseif t == "table" then
		local mytype = propertyStr.type
		local val = propertyStr.value

		if mytype == "const" then
			if type(val) ~= "string" then
				self.type = constPropertyValueType.const
				self.value = val
				self.valueIsFunction = false
				self.realTypeIsArray = false
				self.realTypeIsStruct = false
				self.realTypeName = type(val)
			else
				local typeName = type(val)
				local valueStr = val
				local isArray = false
				local isStruct = false

				self.type = constPropertyValueType.const
				self.value, isArray, isStruct = ConstValueReader.readAnyType(typeName, valueStr)
				self.valueIsFunction = false
				self.realTypeIsArray = isArray
				self.realTypeIsStruct = isStruct
				self.realTypeName = typeName
			end
		else
			local propStr = ""
			local typeName = ""
			local indexPropStr = ""
			local tokens = StringUtils.splitTokens(val)

			macros.BEHAVIAC_ASSERT(#tokens == 2 or #tokens == 3, "_M.parseProperty non-static #tokens ~= 2, 3")

			typeName = mytype
			propStr = type(val)
			self.type = constPropertyValueType.default

			if #tokens >= 1 then
				indexPropStr = tokens[1]
			end

			local indexMember = 0

			if #indexPropStr > 0 then
				indexMember = tonumber(indexPropStr)
			end

			local intanceName, className, propertyName = string.gmatch(propStr, "(.+)%.(.+)::(.+)")()

			macros.BEHAVIAC_ASSERT(propertyName, "_M.parseProperty() property name can't be nil")

			function self.value(agent, tick)
				if tick and tick:getLocalVariable(propertyName) ~= nil then
					return tick:getLocalVariable(propertyName)
				elseif agent:getBlackBoardProperty(propertyName) ~= nil then
					return agent:getBlackBoardProperty(propertyName)
				end

				agent.ent.logger:error("@cyj 未设置该黑板变量值", propertyName)
			end

			function self.setValue(agent, tick, value)
				if tick and tick:getLocalVariable(propertyName) ~= nil then
					tick:setLocalVariable(propertyName, value)

					return
				elseif agent:getBlackBoardProperty(propertyName) ~= nil then
					agent:setBlackBoardProperty(propertyName, value)

					return
				else
					agent:setBlackBoardProperty(propertyName, value)

					return
				end
			end

			self.valueIsFunction = true
			self.realTypeIsArray = false
			self.realTypeIsStruct = false
			self.realTypeName = typeName
		end
	end
end

function _M:getParamPropertiesDebugMsg(agent, tick)
	local msg = ""

	for _, param in ipairs(self.paramProperties) do
		if type(param.value) == "string" then
			msg = msg .. param.value .. ","
		elseif type(param.value) == "function" then
			msg = msg .. tostring(param.value(agent, tick)) .. ","
		else
			msg = msg .. tostring(param.value) .. ","
		end
	end

	return msg
end

function _M.s_createParamProperties(paramStr)
	local retProperties = {}

	if paramStr and #paramStr > 0 then
		for _, propStr in ipairs(paramStr) do
			local prop = _M.new()

			prop:buildProperty(propStr)
			table.insert(retProperties, prop)
		end
	end

	return retProperties
end

return _M
