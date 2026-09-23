-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\ParamAdapterNew.lua

local functions = require("Common.AI.Behaviac.Functions")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ParamAdapter")
local enums = require("Common.AI.Behaviac.Enums")
local ListPool = require("Common.Container.ListPool")
local EOperatorType = enums.EOperatorType
local EOperatorName = enums.EOperatorName
local unpack = unpack or table.unpack
local ParamAdapterNew = functions.class("ParamAdapterNew")
local ParamAdapterType = enums.ParamAdapterNewType
local __resetState = "__resetState"
local functionNameTable = {
	resetStateFuncNameTable = {}
}

function ParamAdapterNew._runMethod(agent, tick, methodName, ...)
	if agent[methodName] then
		return agent[methodName](agent, ...)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(methodName .. " --> error: method is not implemented yet!!!")
	end
end

function ParamAdapterNew._unpackParams(agent, tick, paramProperties)
	if not paramProperties then
		return nil
	end

	local tempUnpackTable = ListPool.getList(3)

	for i, v in ipairs(paramProperties) do
		if type(v) == "table" then
			if v.field then
				table.insert(tempUnpackTable, ParamAdapterNew._getProperty(agent, tick, v.field))
			else
				table.insert(tempUnpackTable, v.const)
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("@cyj 参数类型错误", v)
		end
	end

	ListPool.returnList(tempUnpackTable, 3, true)

	return unpack(tempUnpackTable, 1, #tempUnpackTable)
end

function ParamAdapterNew._getProperty(agent, tick, propertyName)
	local localVar = tick and tick:getLocalVariable(propertyName)

	if localVar ~= nil then
		return localVar
	else
		local globalVar = agent:getBlackBoardProperty(propertyName)

		if globalVar ~= nil then
			return globalVar
		end
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("@zxc 未设置变量值", tick.m_relativeTreePath, propertyName)
	end
end

function ParamAdapterNew._setProperty(agent, tick, propertyName, value)
	if not tick:setLocalVariable(propertyName, value, true) then
		agent:setBlackBoardProperty(propertyName, value)
	end
end

function ParamAdapterNew._compare(left, right, operatorType)
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

function ParamAdapterNew._compareStruct(left, right, operatorType)
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

function ParamAdapterNew._compute(left, right, computeType)
	if computeType == EOperatorType.E_ADD then
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
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("_compute() error!!! Unknown operator type --", left, EOperatorName[computeType], right)
	end

	return left
end

function ParamAdapterNew._computeTable(left, right, computeType, resultTable)
	if resultTable == nil then
		return
	end

	local len = math.min(#left, #right)

	if computeType == EOperatorType.E_ADD then
		for i = 1, len do
			resultTable[i] = left[i] + right[i]
		end
	elseif computeType == EOperatorType.E_SUB then
		for i = 1, len do
			resultTable[i] = left[i] - right[i]
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("_compute() error!!! Unknown operator type --", left, EOperatorName[computeType], right)
	end
end

function ParamAdapterNew:ctor(type, paramTable)
	self.type = type
	self.paramProperties = paramTable
end

function ParamAdapterNew:run(agent, tick)
	local methodName = self.paramProperties.func

	if self.type == ParamAdapterType.SelfMethod then
		return ParamAdapterNew._runMethod(agent, tick, methodName, ParamAdapterNew._unpackParams(agent, tick, self.paramProperties.params))
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:run() failed!!! Unknown type --", self.type)
	end
end

function ParamAdapterNew:runSpecialParam(agent, tick, param)
	local methodName = self.paramProperties.func

	if self.type == ParamAdapterType.SelfMethod__resetState then
		if not functionNameTable.resetStateFuncNameTable[methodName] then
			functionNameTable.resetStateFuncNameTable[methodName] = methodName .. __resetState
		end

		local methodName__resetState = functionNameTable.resetStateFuncNameTable[methodName]

		if agent[methodName__resetState] then
			agent[methodName__resetState](agent, param)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(methodName__resetState .. " --> error: method is not implemented yet!!!")
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:runSpecialParam() failed!!! Unknown type --", self.type)
	end
end

function ParamAdapterNew:setValueCast(agent, tick, opr, cast)
	if self.type == ParamAdapterType.Field then
		local result = opr:getValue(agent, tick)

		ParamAdapterNew._setProperty(agent, tick, self.paramProperties.field, result)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:setValueCast() failed!!! Unknown type --", self.type)
	end
end

function ParamAdapterNew:getValue(agent, tick)
	if self.paramProperties.func then
		return ParamAdapterNew._runMethod(agent, tick, self.paramProperties.func, ParamAdapterNew._unpackParams(agent, tick, self.paramProperties.params))
	elseif self.paramProperties.const ~= nil then
		return self.paramProperties.const
	elseif self.paramProperties.field then
		return ParamAdapterNew._getProperty(agent, tick, self.paramProperties.field)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:getValue() failed!!! Unknown field --", self.paramProperties)
	end
end

function ParamAdapterNew:compute(agent, tick, opr1, opr2, operator)
	if self.type == ParamAdapterType.Field then
		local r1 = opr1:getValue(agent, tick)
		local r2 = opr2:getValue(agent, tick)
		local r1Type = type(r1)
		local r2Type = type(r2)

		if r1Type == "number" and r2Type == "number" then
			local result = ParamAdapterNew._compute(r1, r2, operator)

			ParamAdapterNew._setProperty(agent, tick, self.paramProperties.field, result)
		elseif r1Type == "table" and r2Type == "table" then
			local resultTable = ParamAdapterNew._getProperty(agent, tick, self.paramProperties.field)

			ParamAdapterNew._computeTable(r1, r2, operator, resultTable)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("compute() error!!! left or right is not number or table.", r1, EOperatorName[operator], r2)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:compute() failed!!! Unknown type --", self.type)
	end
end

function ParamAdapterNew:compare(agent, tick, opr, operatorType)
	if self.type == ParamAdapterType.Field or self.type == ParamAdapterType.SelfMethod then
		local l = self:getValue(agent, tick)
		local r = opr:getValue(agent, tick)

		if l == nil or r == nil then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("ParamAdapterNew:compare() failed!!! Left or right operand is nil --", l, EOperatorName[operatorType], r)
			end

			return false
		end

		if type(l) == "table" and type(r) == "table" then
			return ParamAdapterNew._compareStruct(l, r, operatorType)
		elseif type(l) == type(r) then
			return ParamAdapterNew._compare(l, r, operatorType)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ParamAdapterNew:compare() failed!!! Left and right operand type mismatch --", l, EOperatorName[operatorType], r)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("ParamAdapterNew:compare() failed!!! Unknown type --", self.type)
	end
end

function ParamAdapterNew:getParamPropertiesDebugMsg(agent, tick)
	local msg = ""

	if self.paramProperties.params then
		for _, param in ipairs(self.paramProperties.params) do
			if param.const then
				msg = msg .. tostring(param.const) .. ","
			elseif param.field then
				msg = msg .. tostring(ParamAdapterNew._getProperty(agent, tick, param.field)) .. ","
			elseif param.func then
				msg = msg .. tostring(ParamAdapterNew._runMethod(agent, tick, param.func, ParamAdapterNew._unpackParams(agent, tick, param.params))) .. ","
			end
		end
	end

	return msg
end

function ParamAdapterNew:getMethodName()
	return self.paramProperties.func
end

return ParamAdapterNew
