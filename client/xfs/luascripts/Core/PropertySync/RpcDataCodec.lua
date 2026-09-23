-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\RpcDataCodec.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local CompactPropertySchema = require("Core.PropertySync.CompactPropertySchema")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("RpcDataCodec")
local isVisible = CompactPropertySchema.isVisible
local RpcDataCodec = {
	VERSION = 2
}
local META_VERSION = "__cid__"
local META_CLASS = "__class__"
local META_SCOPE = "__scope__"
local SKIP_KEYS = {
	[META_VERSION] = true,
	[META_CLASS] = true,
	[META_SCOPE] = true
}
local META_CUSTOM_TYPE = "__ct__"
local META_CUSTOM_VALUE = "__v__"
local LEGACY_CUSTOM_TYPE = "__tp__"
local META_ID = "__id__"
local ROOT_PROPERTIES = "__Properties__"
local DYNAMIC_FEATURES = "dynamicFeatures"
local FIXED_FIELDS = "_f_"
local UNFIXED_FIELDS = "_u_"
local PRIMITIVE_TYPES = {
	boolean = true,
	table = true,
	string = true,
	number = true,
	float = true,
	double = true,
	int = true
}

local function primitiveEquals(a, b)
	local ta = type(a)

	if ta ~= type(b) then
		return false
	end

	if ta == "number" or ta == "string" or ta == "boolean" then
		return a == b
	end

	return false
end

local function getEntityClassName(entity)
	if type(entity) == "string" then
		return entity
	end

	if entity == nil then
		return nil
	end

	if type(entity.getClassType) == "function" then
		local ok, ret = pcall(entity.getClassType, entity)

		if ok and ret ~= nil then
			return ret
		end
	end

	if entity.typeName ~= nil or entity.className ~= nil then
		return entity.typeName or entity.className
	end

	if type(entity.getClass) == "function" then
		local cls = entity:getClass()

		return cls and (cls.typeName or cls.className or cls.__cname)
	end

	return nil
end

local function normalizeClientEntityType(entityType)
	if type(entityType) ~= "string" then
		return nil
	end

	if entityType == "ClientMainPlayer" or entityType == "ClientPlayer" then
		return "Player"
	end

	return entityType:gsub("^Client", "")
end

function RpcDataCodec.normalizeClientEntityType(entityType)
	return normalizeClientEntityType(entityType)
end

local function collectMapKeys(map)
	if type(map) ~= "table" then
		return ""
	end

	local keys = {}

	for k, _ in pairs(map) do
		keys[#keys + 1] = tostring(k)
	end

	table.sort(keys)

	return table.concat(keys, ",")
end

local function logUnknownPropertyKey(entityType, className, schema, properties, scope, key)
	local fixedFields = type(properties) == "table" and properties[FIXED_FIELDS] or nil
	local unfixedFields = type(properties) == "table" and properties[UNFIXED_FIELDS] or nil

	logger:error("[CompactClientInitData] unknown property key=%s entityType=%s class=%s schema=%s scope=%s fixedKeys=[%s] unfixedKeys=[%s]", tostring(key), tostring(entityType), tostring(className), schema and schema.name or "nil", tostring(scope), collectMapKeys(fixedFields), collectMapKeys(unfixedFields))
end

local function isCustomObject(value)
	if type(value) ~= "table" then
		return false
	end

	local classType = rawget(value, "__ClassType")

	return type(classType) == "table" and classType.typeName ~= nil
end

local encodeAny, decodeAny, decodeDynamicFeatures

local function isPrimitiveType(typeName)
	return typeName == nil or PRIMITIVE_TYPES[typeName] == true
end

local function getCustomSchemaOrError(typeName, context)
	if isPrimitiveType(typeName) then
		return nil
	end

	local schema = CompactPropertySchema.getCustomSchema(typeName)

	if schema == nil then
		error(string.format("missing compact custom schema for %s at %s", tostring(typeName), tostring(context)))
	end

	return schema
end

local function getDeclaredCustomType(declare, ownerName, fieldName)
	if declare.typeName == nil then
		error(string.format("missing compact custom type at %s.%s", tostring(ownerName), tostring(fieldName)))
	end

	return declare.typeName
end

local function schemaHasOwnClient(schema, visiting)
	if schema == nil then
		return false
	end

	visiting = visiting or {}

	if visiting[schema.name] then
		return false
	end

	visiting[schema.name] = true

	for _, name in ipairs(schema.orderedNames) do
		local declare = schema.declares[name]

		if declare.scope == "OwnClient" then
			visiting[schema.name] = nil

			return true
		end

		if declare.scope == "AllClients" and declare.isCustom then
			local childSchema = CompactPropertySchema.getCustomSchema(declare.typeName)

			if schemaHasOwnClient(childSchema, visiting) then
				visiting[schema.name] = nil

				return true
			end
		end
	end

	if schema.valueType ~= nil and not isPrimitiveType(schema.valueType) then
		local valueSchema = CompactPropertySchema.getCustomSchema(schema.valueType)

		if schemaHasOwnClient(valueSchema, visiting) then
			visiting[schema.name] = nil

			return true
		end
	end

	visiting[schema.name] = nil

	return false
end

local function getNestedScope(declare, scope)
	if scope == "onlyOwn" and declare.scope == "OwnClient" then
		return "onlyOwnInherited"
	end

	return scope
end

local function shouldEncodeDeclare(declare, scope)
	if isVisible(declare.scope, scope) then
		return true
	end

	if scope ~= "onlyOwn" or declare.scope ~= "AllClients" or not declare.isCustom then
		return false
	end

	return schemaHasOwnClient(CompactPropertySchema.getCustomSchema(declare.typeName))
end

local function getCustomPropsAndId(value)
	if isCustomObject(value) then
		local props = rawget(value, "_properties")

		if type(props) ~= "table" then
			if type(value.getRawTable) == "function" then
				props = value:getRawTable()
			else
				props = {}
			end
		end

		return props, rawget(value, "_id")
	end

	if type(value) ~= "table" then
		return nil, nil
	end

	return value, rawget(value, META_ID)
end

local function encodePureContainer(value, valueType, scope, id)
	local out = {}

	if id ~= nil then
		out[META_ID] = id
	end

	for k, v in pairs(value or EMPTY_TABLE) do
		if k ~= LEGACY_CUSTOM_TYPE and k ~= META_ID and k ~= "_" then
			out[k] = encodeAny(v, scope, valueType)
		end
	end

	return out
end

local function encodeCustomBody(value, scope, schema, directFixedBody, id)
	local fixedFields, unfixedFields

	for k, v in pairs(value or EMPTY_TABLE) do
		if k ~= LEGACY_CUSTOM_TYPE and k ~= META_ID and k ~= "_" then
			local declare = schema and schema.declares[k]

			if declare ~= nil then
				if shouldEncodeDeclare(declare, scope) then
					local compactKey = schema.nameToIndex[k]
					local nestedScope = getNestedScope(declare, scope)

					if declare.isCustom then
						local expectedType = getDeclaredCustomType(declare, schema and schema.name, k)

						fixedFields = fixedFields or {}
						fixedFields[compactKey] = encodeAny(v, nestedScope, expectedType)
					elseif not primitiveEquals(v, declare.default) then
						fixedFields = fixedFields or {}
						fixedFields[compactKey] = encodeAny(v, nestedScope)
					end
				end
			elseif scope ~= "onlyOwn" then
				unfixedFields = unfixedFields or {}
				unfixedFields[k] = encodeAny(v, scope)
			end
		end
	end

	if directFixedBody and unfixedFields == nil then
		local body = fixedFields or {}

		if id ~= nil then
			body[META_ID] = id
		end

		return body
	end

	local body = {}

	if id ~= nil then
		body[META_ID] = id
	end

	if fixedFields ~= nil then
		body[FIXED_FIELDS] = fixedFields
	end

	if unfixedFields ~= nil then
		body[UNFIXED_FIELDS] = unfixedFields
	end

	return body
end

local function encodeExpectedCustom(value, typeName, scope, schema)
	if isCustomObject(value) then
		local classType = rawget(value, "__ClassType")

		if classType and classType.typeName ~= nil and classType.typeName ~= typeName then
			return nil
		end
	elseif type(value) == "table" then
		local rawType = rawget(value, LEGACY_CUSTOM_TYPE)

		if type(rawType) == "string" and rawType ~= typeName then
			return nil
		end
	end

	local props, id = getCustomPropsAndId(value)

	if props == nil then
		return value
	end

	schema = schema or CompactPropertySchema.getCustomSchema(typeName)

	if schema and schema.isPureContainer then
		return encodePureContainer(props, schema.valueType, scope, id)
	end

	return encodeCustomBody(props, scope, schema, true, id)
end

local function encodeCustomTable(value, typeName, id, scope, schema)
	schema = schema or CompactPropertySchema.getCustomSchema(typeName)

	local out = {
		[META_CUSTOM_TYPE] = typeName
	}

	if id ~= nil then
		out[META_ID] = id
	end

	local body

	if schema and schema.isPureContainer then
		local rawContainer = encodePureContainer(value, schema.valueType, scope)

		body = {}

		if next(rawContainer) ~= nil then
			body[UNFIXED_FIELDS] = rawContainer
		end
	else
		body = encodeCustomBody(value, scope, schema)
	end

	out[META_CUSTOM_VALUE] = body

	return out
end

local function encodeCustomObject(value, scope)
	local classType = rawget(value, "__ClassType")
	local typeName = classType and classType.typeName

	if typeName == nil then
		return nil
	end

	local props = rawget(value, "_properties")

	if type(props) ~= "table" then
		if type(value.getRawTable) == "function" then
			props = value:getRawTable()
		else
			props = {}
		end
	end

	local schema = CompactPropertySchema.getCustomSchema(classType)

	return encodeCustomTable(props, typeName, rawget(value, "_id"), scope, schema)
end

function encodeAny(value, scope, expectedType)
	if expectedType ~= nil then
		local expectedSchema = getCustomSchemaOrError(expectedType, "encodeAny")

		if expectedSchema ~= nil then
			local expectedValue = encodeExpectedCustom(value, expectedType, scope, expectedSchema)

			if expectedValue ~= nil then
				return expectedValue
			end
		end
	end

	if type(value) ~= "table" then
		return value
	end

	if isCustomObject(value) then
		return encodeCustomObject(value, scope)
	end

	local rawType = rawget(value, LEGACY_CUSTOM_TYPE)

	if type(rawType) == "string" then
		return encodeCustomTable(value, rawType, rawget(value, META_ID), scope)
	end

	local out = {}

	for k, v in pairs(value) do
		out[k] = encodeAny(v, scope)
	end

	return out
end

local function encodeProperties(schema, properties, scope)
	local fixedFields, unfixedFields

	for k, v in pairs(properties or EMPTY_TABLE) do
		local declare = schema and schema.declares[k]

		if declare ~= nil then
			if shouldEncodeDeclare(declare, scope) then
				local compactKey = schema.nameToIndex[k]
				local nestedScope = getNestedScope(declare, scope)

				if declare.isCustom then
					local expectedType = getDeclaredCustomType(declare, schema and schema.name, k)

					fixedFields = fixedFields or {}
					fixedFields[compactKey] = encodeAny(v, nestedScope, expectedType)
				elseif not primitiveEquals(v, declare.default) then
					fixedFields = fixedFields or {}
					fixedFields[compactKey] = encodeAny(v, nestedScope)
				end
			end
		elseif scope ~= "onlyOwn" then
			unfixedFields = unfixedFields or {}
			unfixedFields[k] = encodeAny(v, scope)
		end
	end

	local out = {}

	if fixedFields ~= nil then
		out[FIXED_FIELDS] = fixedFields
	end

	if unfixedFields ~= nil then
		out[UNFIXED_FIELDS] = unfixedFields
	end

	return out
end

function RpcDataCodec.encodeEntityInit(entity, initDict, scope)
	if type(initDict) ~= "table" then
		return initDict
	end

	if initDict[META_VERSION] ~= nil then
		return initDict
	end

	scope = scope or "all"

	local schema = CompactPropertySchema.getEntitySchema(entity)
	local className = schema and schema.name or getEntityClassName(entity)
	local out = {
		[META_VERSION] = RpcDataCodec.VERSION,
		[META_CLASS] = className,
		[META_SCOPE] = scope
	}

	for k, v in pairs(initDict) do
		if k == ROOT_PROPERTIES then
			out[k] = encodeProperties(schema, v, scope)
		else
			out[k] = encodeAny(v, scope)
		end
	end

	if out[ROOT_PROPERTIES] == nil and schema ~= nil then
		for _, name in ipairs(schema.orderedNames) do
			local declare = schema.declares[name]

			if shouldEncodeDeclare(declare, scope) then
				out[ROOT_PROPERTIES] = {}

				break
			end
		end
	end

	return out
end

function RpcDataCodec.encodeNonLazyLoadEntityInitData(entity, initDict, scope, protoCodec)
	local compactDict = RpcDataCodec.encodeEntityInit(entity, initDict, scope)

	return protoCodec:encode(compactDict)
end

local function fillPrimitiveDefaults(schema, out, scope)
	if schema == nil then
		return
	end

	local defaults = schema.primitiveDefaultsByScope and schema.primitiveDefaultsByScope[scope]

	if defaults ~= nil then
		for i = 1, #defaults do
			local declare = defaults[i]

			if out[declare.name] == nil then
				out[declare.name] = declare.default
			end
		end

		return
	end

	for _, name in ipairs(schema.orderedNames) do
		local declare = schema.declares[name]

		if out[name] == nil and not declare.isCustom and isVisible(declare.scope, scope) then
			out[name] = declare.default
		end
	end
end

local function decodePureContainer(value, schema, scope, keepTypeMarker, typeName)
	local out = value or {}

	for k, v in pairs(value or EMPTY_TABLE) do
		if k ~= META_ID then
			out[k] = decodeAny(v, scope, false, schema and schema.valueType)
		end
	end

	if keepTypeMarker then
		out[LEGACY_CUSTOM_TYPE] = typeName
	end

	return out
end

local function decodeCustomBody(typeName, body, scope, keepTypeMarker)
	local schema = CompactPropertySchema.getCustomSchema(typeName)
	local out = {}

	if keepTypeMarker then
		out[LEGACY_CUSTOM_TYPE] = typeName
	end

	if type(body) == "table" and body[META_ID] ~= nil then
		out[META_ID] = body[META_ID]
	end

	for k, v in pairs(body[UNFIXED_FIELDS] or EMPTY_TABLE) do
		out[k] = decodeAny(v, scope, false)
	end

	for k, v in pairs(body[FIXED_FIELDS] or EMPTY_TABLE) do
		local declare = schema and schema.indexToDeclare[k]

		if declare == nil then
			error(string.format("unknown compact custom key %s for %s", tostring(k), tostring(typeName)))
		end

		local name = declare.name
		local nestedScope = getNestedScope(declare, scope)
		local expectedType = declare.isCustom and getDeclaredCustomType(declare, typeName, name) or nil

		out[name] = decodeAny(v, nestedScope, false, expectedType)
	end

	if body[FIXED_FIELDS] == nil and body[UNFIXED_FIELDS] == nil then
		for k, v in pairs(body) do
			if k ~= META_ID then
				local name = k
				local declare

				if type(k) == "number" then
					declare = schema and schema.indexToDeclare[k < 0 and -k or k]

					if declare == nil then
						error(string.format("unknown compact custom key %s for %s", tostring(k), tostring(typeName)))
					end

					name = declare.name
				else
					declare = schema and schema.declares[name]
				end

				local nestedScope = declare and getNestedScope(declare, scope) or scope
				local expectedType = declare and declare.isCustom and getDeclaredCustomType(declare, typeName, name) or nil

				out[name] = decodeAny(v, nestedScope, false, expectedType)
			end
		end
	end

	fillPrimitiveDefaults(schema, out, scope)

	return out
end

local function decodeCustom(value, scope, keepTypeMarker)
	local typeName = value[META_CUSTOM_TYPE]
	local schema = CompactPropertySchema.getCustomSchema(typeName)
	local body = value[META_CUSTOM_VALUE] or {}
	local out

	if schema and schema.isPureContainer then
		out = decodePureContainer(body[UNFIXED_FIELDS] or body, schema, scope, keepTypeMarker, typeName)
	else
		out = decodeCustomBody(typeName, body, scope, keepTypeMarker)
	end

	if value[META_ID] ~= nil then
		out[META_ID] = value[META_ID]
	end

	return out
end

local function decodeExpectedCustom(value, scope, keepTypeMarker, expectedType)
	local schema = getCustomSchemaOrError(expectedType, "decodeExpectedCustom")

	if schema.isPureContainer then
		return decodePureContainer(value, schema, scope, keepTypeMarker, expectedType)
	end

	return decodeCustomBody(expectedType, value or {}, scope, keepTypeMarker)
end

function decodeAny(value, scope, keepTypeMarker, expectedType)
	if type(value) ~= "table" then
		return value
	end

	if value[META_CUSTOM_TYPE] ~= nil then
		return decodeCustom(value, scope, keepTypeMarker)
	end

	if expectedType ~= nil then
		local expectedValue = decodeExpectedCustom(value, scope, keepTypeMarker, expectedType)

		return expectedValue
	end

	for k, v in pairs(value) do
		value[k] = decodeAny(v, scope, false)
	end

	return value
end

function decodeDynamicFeatures(features, scope)
	if type(features) ~= "table" then
		return features
	end

	for featureName, featureData in pairs(features) do
		if type(featureData) == "table" then
			for k, v in pairs(featureData) do
				if k == ROOT_PROPERTIES and type(v) == "table" then
					for propName, propValue in pairs(v) do
						v[propName] = decodeAny(propValue, scope, true)
					end

					featureData[k] = v
				else
					featureData[k] = decodeAny(v, scope, false)
				end
			end
		end
	end

	return features
end

local function decodeProperties(schema, properties, scope, entityType, className)
	local out = {}

	properties = properties or {}

	for k, v in pairs(properties[UNFIXED_FIELDS] or EMPTY_TABLE) do
		out[k] = decodeAny(v, scope, true)
	end

	for k, v in pairs(properties[FIXED_FIELDS] or EMPTY_TABLE) do
		local declare = schema and schema.indexToDeclare[k]

		if declare == nil then
			logUnknownPropertyKey(entityType, className, schema, properties, scope, k)
			error(string.format("unknown compact property key %s for %s", tostring(k), schema and schema.name or "nil"))
		end

		local name = declare.name
		local nestedScope = getNestedScope(declare, scope)
		local expectedType = declare.isCustom and getDeclaredCustomType(declare, className, name) or nil

		out[name] = decodeAny(v, nestedScope, true, expectedType)
	end

	if properties[FIXED_FIELDS] == nil and properties[UNFIXED_FIELDS] == nil then
		for k, v in pairs(properties) do
			local name = k
			local declare

			if type(k) == "number" then
				declare = schema and schema.indexToDeclare[k < 0 and -k or k]

				if declare == nil then
					logUnknownPropertyKey(entityType, className, schema, properties, scope, k)
					error(string.format("unknown compact property key %s for %s", tostring(k), schema and schema.name or "nil"))
				end

				name = declare.name
			else
				declare = schema and schema.declares[name]
			end

			local nestedScope = declare and getNestedScope(declare, scope) or scope
			local expectedType = declare and declare.isCustom and getDeclaredCustomType(declare, className, name) or nil

			out[name] = decodeAny(v, nestedScope, true, expectedType)
		end
	end

	fillPrimitiveDefaults(schema, out, scope)

	return out
end

function RpcDataCodec.decodeEntityInit(entityType, initDict)
	if type(initDict) ~= "table" or initDict[META_VERSION] == nil then
		return initDict
	end

	local className = initDict[META_CLASS] or normalizeClientEntityType(entityType)
	local scope = initDict[META_SCOPE] or "all"
	local schema = CompactPropertySchema.getEntitySchema(className)
	local out = {}

	for k, v in pairs(initDict) do
		if not SKIP_KEYS[k] then
			if k == ROOT_PROPERTIES then
				out[k] = decodeProperties(schema, v, scope, entityType, className)
			elseif k == DYNAMIC_FEATURES then
				out[k] = decodeDynamicFeatures(v, scope)
			else
				out[k] = decodeAny(v, scope)
			end
		end
	end

	if out[ROOT_PROPERTIES] == nil and schema ~= nil then
		out[ROOT_PROPERTIES] = decodeProperties(schema, {}, scope, entityType, className)
	end

	return out
end

return RpcDataCodec
