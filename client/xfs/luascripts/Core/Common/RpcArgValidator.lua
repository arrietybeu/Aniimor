-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RpcArgValidator.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Switch = require("Core.Common.Switch")
local Const = require("Core.Common.Const")
local StringEx = require("Core.Framework.String")
local RpcArgValidator = {}
local DEFAULT_BUILD_OPTS = {
	allowUnknownField = false,
	checkRequired = false,
	deepCustom = false
}

function RpcArgValidator.parseArgTypes(config)
	RpcArgValidator.__argTypes = config.ArgTypes
	RpcArgValidator.__customTypes = config.Custom or {}
	RpcArgValidator.__customFieldCache = {}
end

function RpcArgValidator.isNumberType(argType)
	for numberType, _ in pairs(Const.ARG_TYPE_NUMBER) do
		local isNumber = StringEx.startswith(argType, numberType)

		if isNumber then
			return true
		end
	end

	return false
end

function RpcArgValidator.isTableType(argType)
	return StringEx.startswith(argType, "table")
end

local function _hasCustomProperties(ct)
	return ct ~= nil and ct.Properties ~= nil and next(ct.Properties) ~= nil
end

function RpcArgValidator.isCustomArgType(argType)
	if RpcArgValidator.__argTypes[argType] ~= nil then
		return true
	end

	return _hasCustomProperties(RpcArgValidator.__customTypes[argType])
end

function RpcArgValidator._getArgTypeConfig(argType)
	local t = RpcArgValidator.__argTypes[argType]

	if t then
		return t
	end

	local cached = RpcArgValidator.__customFieldCache[argType]

	if cached then
		return cached
	end

	local ct = RpcArgValidator.__customTypes[argType]

	if not _hasCustomProperties(ct) then
		return nil
	end

	local content = {}

	for fieldName, fieldDef in pairs(ct.Properties) do
		local fieldType = fieldDef[1]

		if fieldType == "int" or fieldType == "float" or fieldType == "double" then
			fieldType = "number"
		end

		content[fieldName] = fieldType
	end

	RpcArgValidator.__customFieldCache[argType] = content

	return content
end

function RpcArgValidator.parseArgConfig(functionName, argType)
	return RpcArgValidator.buildValidator(functionName, argType, {
		allowUnknownField = false,
		checkRequired = false,
		deepCustom = Switch.RpcDebug
	})
end

function RpcArgValidator._mergeBuildOpts(opts)
	local merged = {}

	for k, v in pairs(DEFAULT_BUILD_OPTS) do
		merged[k] = v
	end

	for k, v in pairs(opts or EMPTY_TABLE) do
		merged[k] = v
	end

	return merged
end

function RpcArgValidator._joinPath(path, field)
	if path == nil or path == "" then
		return tostring(field)
	end

	return string.format("%s.%s", path, tostring(field))
end

function RpcArgValidator._withPath(path, errMsg)
	if path == nil or path == "" then
		return errMsg
	end

	return string.format("%s: %s", path, errMsg)
end

function RpcArgValidator._makePathValidator(baseValidator)
	return function(x, path)
		local valid, errMsg = baseValidator(x)

		if not valid and path ~= nil and path ~= "" then
			return false, RpcArgValidator._withPath(path, errMsg)
		end

		return valid, errMsg
	end
end

function RpcArgValidator.buildValidator(functionName, argType, opts)
	opts = RpcArgValidator._mergeBuildOpts(opts)

	if RpcArgValidator.isCustomArgType(argType) then
		return RpcArgValidator.generateCustomArgTypeValidator(functionName, argType, opts)
	end

	if RpcArgValidator.isNumberType(argType) then
		return RpcArgValidator._makePathValidator(RpcArgValidator.generateNumberValidator(functionName, argType))
	end

	if RpcArgValidator.isTableType(argType) then
		return RpcArgValidator._makePathValidator(RpcArgValidator.generateTableValidator(functionName, argType))
	end

	if argType == "string" then
		return RpcArgValidator._makePathValidator(RpcArgValidator.generateStringValidator(functionName, argType))
	end

	if argType == "boolean" then
		return RpcArgValidator._makePathValidator(RpcArgValidator.generateBooleanValidator(functionName, argType))
	end

	error("RpcArgValidator.parseArgConfig found unsupported type: " .. functionName .. "-" .. argType)
end

function RpcArgValidator.generateNumberValidator(functionName, argType)
	local splittedNumber = StringEx.split(argType, ":")
	local rawConstraint = splittedNumber[2]

	if rawConstraint == nil then
		if splittedNumber[1] == "int" then
			return function(x)
				if type(x) ~= "number" then
					return false, string.format("type int got %s", type(x))
				end

				if x ~= x then
					return false, string.format("type int got %s", x)
				end

				if math.floor(x) ~= x then
					return false, string.format("type int got float %s", x)
				end

				return true, ""
			end
		else
			if Const.ARG_TYPE_NUMBER[splittedNumber[1]] == nil then
				error(functionName .. " has wrong constraint format " .. splittedNumber[1])
			end

			return function(x)
				if type(x) ~= "number" then
					return false, string.format("type %s got %s", argType, type(x))
				end

				if x ~= x then
					return false, string.format("type %s got %s", argType, x)
				end

				return true, ""
			end
		end
	end

	local constraint = rawConstraint:gsub("%s+", "")
	local lowerMark, upperMark = constraint:sub(1, 1), constraint:sub(-1)
	local bound = StringEx.split(constraint:sub(2, -2), ",")
	local lowerBound, upperBound = tonumber(bound[1]), tonumber(bound[2])

	if lowerBound == nil and bound[1] ~= "-inf" then
		error(functionName .. " has wrong constraint " .. rawConstraint)
	end

	if upperBound == nil and bound[2] ~= "inf" then
		error(functionName .. " has wrong constraint " .. rawConstraint)
	end

	if lowerBound == nil then
		lowerBound = -1 / 0
	end

	if upperBound == nil then
		upperBound = 1 / 0
	end

	local lowerCheck, upperCheck

	if lowerMark == "(" then
		function lowerCheck(x)
			return x > lowerBound
		end
	elseif lowerMark == "[" then
		function lowerCheck(x)
			return x >= lowerBound
		end
	end

	if upperMark == ")" then
		function upperCheck(x)
			return x < upperBound
		end
	elseif upperMark == "]" then
		function upperCheck(x)
			return x <= upperBound
		end
	end

	if splittedNumber[1] == "int" then
		return function(x)
			if type(x) ~= "number" then
				return false, string.format("type int got %s", type(x))
			end

			if x ~= x then
				return false, string.format("type int got %s", x)
			end

			if math.floor(x) ~= x then
				return false, string.format("type int got float %s", x)
			end

			if (lowerCheck == nil or lowerCheck(x)) and (upperCheck == nil or upperCheck(x)) then
				return true, ""
			end

			return false, string.format("value %s violates constraint %s", tostring(x), rawConstraint)
		end
	else
		return function(x)
			if type(x) ~= "number" then
				return false, string.format("type %s got %s", argType, type(x))
			end

			if x ~= x then
				return false, string.format("type %s got %s", argType, x)
			end

			if (lowerCheck == nil or lowerCheck(x)) and (upperCheck == nil or upperCheck(x)) then
				return true, ""
			end

			return false, string.format("value %s violates constraint %s", tostring(x), rawConstraint)
		end
	end
end

function RpcArgValidator.generateTableValidator(functionName, argType)
	local splitted = StringEx.split(argType, ":")

	if splitted[2] == nil then
		if splitted[1] ~= "table" then
			error(functionName .. " has wrong constraint format " .. splitted[1])
		end

		return function(x)
			if type(x) ~= "table" then
				return false, string.format("type %s got %s", argType, type(x))
			end

			return true, ""
		end
	end

	local lenLimit = tonumber(splitted[2])

	return function(x)
		if type(x) ~= "table" then
			return false, string.format("type %s got %s", argType, type(x))
		end

		local count = 0

		for _, _ in pairs(x) do
			count = count + 1

			if count > lenLimit then
				return false, string.format("table violates len limit %d", lenLimit)
			end
		end

		return true, ""
	end
end

function RpcArgValidator.generateStringValidator(functionName, argType)
	return function(x)
		if type(x) ~= "string" then
			return false, string.format("type %s got %s", argType, type(x))
		end

		return true, ""
	end
end

function RpcArgValidator.generateBooleanValidator(functionName, argType)
	return function(x)
		if type(x) ~= "boolean" then
			return false, string.format("type %s got %s", argType, type(x))
		end

		return true, ""
	end
end

local function _getClassTypeName(x, t)
	if t == "userdata" then
		local ok, name = pcall(function()
			return x._typeName
		end)

		if ok and type(name) == "string" then
			return name
		end

		return nil
	end

	if t == "table" then
		local classType = rawget(x, "__ClassType")

		if type(classType) == "table" then
			return classType.typeName
		end

		return nil
	end

	return nil
end

function RpcArgValidator.generateCustomArgTypeValidator(functionName, argType, opts)
	if not opts.deepCustom then
		return RpcArgValidator._makePathValidator(function(x)
			local t = type(x)

			if t ~= "table" and t ~= "userdata" then
				return false, string.format("type %s got %s", argType, t)
			end

			local typeName = _getClassTypeName(x, t)

			if typeName ~= nil and typeName ~= argType then
				return false, string.format("type %s got %s", argType, tostring(typeName))
			end

			return true, ""
		end)
	end

	local argTypeConfig = RpcArgValidator._getArgTypeConfig(argType)
	local argTypeValidators = {}

	for k, v in pairs(argTypeConfig) do
		argTypeValidators[k] = RpcArgValidator.buildValidator(functionName, v, opts)
	end

	return function(x, path)
		path = path or argType

		local t = type(x)

		if t ~= "table" and t ~= "userdata" then
			return false, RpcArgValidator._withPath(path, string.format("type %s got %s", argType, t))
		end

		local typeName = _getClassTypeName(x, t)

		if typeName ~= nil then
			if typeName == argType then
				return true, ""
			end

			return false, RpcArgValidator._withPath(path, string.format("type %s got %s", argType, tostring(typeName)))
		end

		if opts.checkRequired then
			for fieldName, _ in pairs(argTypeConfig) do
				if x[fieldName] == nil then
					return false, RpcArgValidator._withPath(RpcArgValidator._joinPath(path, fieldName), "missing required field")
				end
			end
		end

		for k, v in pairs(x) do
			if k == "__tp__" or k == "__id__" then
				-- block empty
			elseif not opts.allowUnknownField and argTypeConfig[k] == nil then
				return false, RpcArgValidator._withPath(RpcArgValidator._joinPath(path, k), string.format("undefined field for %s", argType))
			elseif argTypeConfig[k] ~= nil then
				local valid, errMsg = argTypeValidators[k](v, RpcArgValidator._joinPath(path, k))

				if not valid then
					return false, errMsg
				end
			end
		end

		return true, ""
	end
end

return RpcArgValidator
