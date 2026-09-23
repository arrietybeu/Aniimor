-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CompactPropertySchema.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CompactPropertySchema = {
	_entitySchemaCache = {},
	_customSchemaCache = {}
}
local PRIMITIVE_TYPES = {
	string = true,
	number = true,
	boolean = true,
	table = true,
	float = true,
	double = true,
	int = true
}
local SCOPE_TO_STRING_MAP = {
	ServerOnly = "ServerOnly",
	OwnClient = "OwnClient",
	AllClients = "AllClients",
	[PropertyTypes.AOI_ALL_CLIENTS] = "AllClients",
	[PropertyTypes.AOI_OWN_CLIENT] = "OwnClient",
	[PropertyTypes.AOI_SERVER_ONLY] = "ServerOnly"
}
local DECODE_SCOPES = {
	"all",
	"own",
	"onlyOwn",
	"onlyOwnInherited"
}

local function scopeToString(scope)
	return SCOPE_TO_STRING_MAP[scope] or scope
end

local function isVisible(scope, targetScope)
	scope = scopeToString(scope)

	if targetScope == "all" then
		return scope == "AllClients"
	end

	if targetScope == "own" then
		return scope == "AllClients" or scope == "OwnClient"
	end

	if targetScope == "onlyOwn" then
		return scope == "OwnClient"
	end

	if targetScope == "onlyOwnInherited" then
		return scope ~= "ServerOnly"
	end

	return scope ~= "ServerOnly"
end

local function parseConfigDeclare(name, def)
	if type(def) ~= "table" then
		return nil
	end

	local typeName = def[1]
	local default, scope, persist

	if type(def[2]) == "string" and (def[2] == "AllClients" or def[2] == "OwnClient" or def[2] == "ServerOnly") then
		scope = def[2]
		persist = def[3]
		default = def[4]
	else
		default = def[2]
		scope = def[3]
		persist = def[4]
	end

	return {
		name = name,
		typeName = typeName,
		default = default,
		scope = scopeToString(scope),
		persist = persist,
		isCustom = typeName ~= nil and not PRIMITIVE_TYPES[typeName]
	}
end

local function parseRuntimeDeclare(name, declare)
	if type(declare) ~= "table" then
		return nil
	end

	local typeName = declare.typeStr

	typeName = typeName == "number" and (declare.propType == PropertyTypes.PT_INT and "int" or "double") or declare.customClass ~= nil and declare.customClass.typeName or typeName

	return {
		name = name,
		typeName = typeName,
		default = declare.default,
		scope = scopeToString(declare.aoiscope),
		persist = declare.persist,
		isCustom = declare.customClass ~= nil,
		customClass = declare.customClass
	}
end

local function buildSchema(name, declares, config)
	local schema = {
		name = name,
		declares = {},
		nameToIndex = {},
		indexToName = {},
		indexToDeclare = {},
		orderedNames = {},
		primitiveDefaultsByScope = {
			all = {},
			own = {},
			onlyOwn = {},
			onlyOwnInherited = {}
		},
		valueType = config and config.__ValueType__,
		intTypeKey = config and config.__IntTypeKey__
	}

	for fieldName, declare in pairs(declares or EMPTY_TABLE) do
		local parsed

		if declare.typeStr ~= nil or declare.propType ~= nil then
			parsed = parseRuntimeDeclare(fieldName, declare)
		else
			parsed = parseConfigDeclare(fieldName, declare)
		end

		if parsed ~= nil then
			schema.declares[fieldName] = parsed
			schema.orderedNames[#schema.orderedNames + 1] = fieldName
		end
	end

	table.sort(schema.orderedNames)

	for i, fieldName in ipairs(schema.orderedNames) do
		local compactKey = i
		local declare = schema.declares[fieldName]

		schema.nameToIndex[fieldName] = compactKey
		schema.indexToName[compactKey] = fieldName
		schema.indexToDeclare[compactKey] = declare

		if not declare.isCustom then
			for _, scope in ipairs(DECODE_SCOPES) do
				if isVisible(declare.scope, scope) then
					local defaults = schema.primitiveDefaultsByScope[scope]

					defaults[#defaults + 1] = declare
				end
			end
		end
	end

	schema.hasFixedDeclares = #schema.orderedNames > 0
	schema.isPureContainer = schema.valueType ~= nil and not schema.hasFixedDeclares

	return schema
end

local function getConfigCustomType(typeName)
	local ok, Config = pcall(require, "Config.Config")

	if ok and Config and Config.Custom then
		return Config.Custom[typeName]
	end

	return nil
end

function CompactPropertySchema.setPropertyConfig(bundleConfig, customTypeConfig)
	CompactPropertySchema._bundleConfig = bundleConfig or {}
	CompactPropertySchema._customTypeConfig = customTypeConfig or {}
	CompactPropertySchema._entitySchemaCache = {}
	CompactPropertySchema._customSchemaCache = {}
end

function CompactPropertySchema.getEntitySchema(entityOrClassName)
	local className = type(entityOrClassName) == "string" and entityOrClassName or nil

	if className == nil and entityOrClassName ~= nil then
		if type(entityOrClassName.getClassType) == "function" then
			local ok, ret = pcall(entityOrClassName.getClassType, entityOrClassName)

			if ok then
				className = ret
			end
		end

		if className == nil then
			className = entityOrClassName.typeName or entityOrClassName.className
		end

		if className == nil and type(entityOrClassName.getClass) == "function" then
			local cls = entityOrClassName:getClass()

			className = cls and (cls.typeName or cls.className or cls.__cname)
		end
	end

	if className == nil then
		return nil
	end

	local cached = CompactPropertySchema._entitySchemaCache[className]

	if cached ~= nil then
		return cached
	end

	local declares, config

	if type(entityOrClassName) ~= "string" and entityOrClassName ~= nil and entityOrClassName.getClass then
		local cls = entityOrClassName:getClass()

		declares = cls and cls.__Name2PropertyDeclare__
		config = cls
	end

	if declares == nil and CompactPropertySchema._bundleConfig ~= nil then
		config = CompactPropertySchema._bundleConfig[className]
		declares = config and (config.Properties or config)
	end

	if declares == nil then
		return nil
	end

	local schema = buildSchema(className, declares, config)

	CompactPropertySchema._entitySchemaCache[className] = schema

	return schema
end

function CompactPropertySchema.getCustomSchema(typeOrName)
	local typeName = type(typeOrName) == "string" and typeOrName or nil

	if typeName == nil and typeOrName ~= nil then
		local classType = typeOrName.__ClassType or typeOrName

		typeName = classType.typeName
	end

	if typeName == nil then
		return nil
	end

	local cached = CompactPropertySchema._customSchemaCache[typeName]

	if cached ~= nil then
		return cached
	end

	local declares, config

	if type(typeOrName) ~= "string" and typeOrName ~= nil then
		local classType = typeOrName.__ClassType or typeOrName

		declares = classType.__Name2PropertyDeclare__
		config = classType
	end

	local configFromCache

	if CompactPropertySchema._customTypeConfig ~= nil then
		configFromCache = CompactPropertySchema._customTypeConfig[typeName]
	end

	if declares == nil and configFromCache ~= nil then
		config = configFromCache
		declares = config.Properties or {}
	elseif configFromCache ~= nil and (config == nil or config.__ValueType__ == nil) then
		config = configFromCache
	end

	if declares == nil then
		config = getConfigCustomType(typeName)
		declares = config and (config.Properties or {})
	elseif config == nil or config.__ValueType__ == nil then
		local fallbackConfig = getConfigCustomType(typeName)

		if fallbackConfig ~= nil then
			config = fallbackConfig
		end
	end

	if declares == nil then
		return nil
	end

	local schema = buildSchema(typeName, declares, config)

	CompactPropertySchema._customSchemaCache[typeName] = schema

	return schema
end

local function copyDefaultValue(value)
	if type(value) ~= "table" then
		return value
	end

	local copied = {}

	for k, v in pairs(value) do
		copied[k] = copyDefaultValue(v)
	end

	return copied
end

function CompactPropertySchema.genDefaultValue(declare, keepTypeMarker)
	local value = copyDefaultValue(declare.default)

	if declare.isCustom then
		value = type(value) == "table" and value or {}

		if keepTypeMarker == false then
			value.__tp__ = nil
		else
			value.__tp__ = declare.typeName
		end
	end

	return value
end

CompactPropertySchema.isVisible = isVisible

return CompactPropertySchema
