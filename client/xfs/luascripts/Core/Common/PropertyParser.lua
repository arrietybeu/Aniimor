-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\PropertyParser.lua

local PropertyDeclare = require("Core.PropertySync.PropertyDeclare")
local ValueTypeDeclare = require("Core.PropertySync.ValueTypeDeclare")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CustomTypeFactory = require("Core.PropertySync.CustomTypeFactory")
local OpStr2OpType = {
	changed = PropertyTypes.OP_CHANGE,
	entryAdded = PropertyTypes.OP_ADD,
	entryDeleted = PropertyTypes.OP_DEL,
	itemInserted = PropertyTypes.OP_INSERT,
	itemRemoved = PropertyTypes.OP_REMOVE
}
local PropertyParser = {
	_entities = {},
	_components = {},
	_custom = {},
	_universal = {}
}

function PropertyParser.parse(cls, properties, valueType, intTypeKey, customData)
	if cls.__Name2PropertyDeclare__ == nil then
		cls.__Name2PropertyDeclare__ = {}
	end

	for k, v in pairs(properties) do
		local propType, default, aoiscope, persist, feature = unpack(v)

		if propType ~= "int" and propType ~= "string" and propType ~= "double" and propType ~= "boolean" and propType ~= "table" then
			local customCls = PropertyParser._custom[propType]

			if customCls == nil then
				local customTypeConf = customData[propType]

				if customTypeConf == nil then
					error("PropertyParser error: customType " .. propType .. " not found!")
				end

				customCls = require(customTypeConf.NameSpace)
				customCls.__Name2PropertyDeclare__ = {}
				PropertyParser._custom[propType] = customCls

				PropertyParser.parse(customCls, customTypeConf.Properties or {}, customTypeConf.__ValueType__, customTypeConf.__IntTypeKey__, customData)
			end

			local declare = PropertyDeclare(k, customCls, default, aoiscope, persist, feature)

			cls.__Name2PropertyDeclare__[k] = declare
		else
			local declare = PropertyDeclare(k, propType, default, aoiscope, persist, feature)

			cls.__Name2PropertyDeclare__[k] = declare
		end
	end

	if valueType ~= nil then
		if valueType ~= "int" and valueType ~= "string" and valueType ~= "double" and valueType ~= "boolean" then
			local customCls = PropertyParser._custom[valueType]

			if customCls == nil then
				local customTypeConf = customData[valueType]

				if customTypeConf == nil then
					error("PropertyParser error: customType " .. valueType .. " not found!")
				end

				customCls = require(customTypeConf.NameSpace)
				customCls.__Name2PropertyDeclare__ = {}
				PropertyParser._custom[valueType] = customCls

				PropertyParser.parse(customCls, customTypeConf.Properties or {}, customTypeConf.__ValueType__, customTypeConf.__IntTypeKey__, customData)
			end

			cls.__ValueTypeDeclare__ = ValueTypeDeclare(customCls, intTypeKey)
		else
			cls.__ValueTypeDeclare__ = ValueTypeDeclare(valueType, intTypeKey)
		end
	end
end

function PropertyParser.parseCustomTypes(config)
	local customData = config.Custom or {}

	for name, conf in pairs(customData) do
		local customCls = PropertyParser._custom[name]

		if customCls == nil then
			customCls = require(conf.NameSpace)
			customCls.__Name2PropertyDeclare__ = {}
			PropertyParser._custom[name] = customCls

			local properties = conf.Properties or {}
			local valueType = conf.__ValueType__
			local intTypeKey = conf.__IntTypeKey__

			PropertyParser.parse(customCls, properties, valueType, intTypeKey, customData)
		end

		if not CustomTypeFactory.hasRegistered(name) then
			CustomTypeFactory.register(name, customCls)
		end
	end
end

function PropertyParser._iterParseComponent(name, compMap, customData, compCache)
	if compCache[name] ~= nil then
		return
	end

	local conf = compMap[name]

	if conf == nil then
		error("component " .. name .. " not found")
	end

	local comp = require(conf.NameSpace)
	local properties = conf.Properties or {}

	PropertyParser.parse(comp, properties, nil, nil, customData)

	if conf.ComponentMethod ~= nil then
		comp.__Name2ComponentMethod__ = {}

		for k, v in pairs(conf.ComponentMethod) do
			comp.__Name2ComponentMethod__[k] = v
		end
	end

	PropertyParser._parsePropertyCallback(comp, conf)

	local superComp = comp.super

	if superComp then
		PropertyParser._iterParseComponent(superComp.typeName, compMap, customData, compCache)

		for k, declare in pairs(superComp.__Name2PropertyDeclare__) do
			if comp.__Name2PropertyDeclare__[k] ~= nil then
				error(string.format("[WARNING] The property %s redeclared in the component %s and %s!", k, comp.typeName, superComp.typeName))
			end

			comp.__Name2PropertyDeclare__[k] = declare
		end

		for opType, cbs in pairs(superComp.__PropertyCallbacks__) do
			if comp.__PropertyCallbacks__[opType] == nil then
				comp.__PropertyCallbacks__[opType] = {}
			end

			for keyPath, cb in pairs(cbs) do
				if comp.__PropertyCallbacks__[opType][keyPath] then
					error(string.format("[WARNING] The propertyCallback %s redeclared in the component %s and %s!", keyPath, comp.typeName, superComp.typeName))
				end

				comp.__PropertyCallbacks__[opType][keyPath] = cb
			end
		end
	end

	compCache[name] = comp
end

function PropertyParser.parseComponent(config)
	local customData = config.Custom or {}
	local components = config.Components

	for name, conf in pairs(components) do
		PropertyParser._iterParseComponent(name, components, customData, PropertyParser._components)
	end
end

function PropertyParser._iterParseClass(name, classMap, customData, classCache)
	if classCache[name] ~= nil then
		return
	end

	local conf = classMap[name]

	if conf == nil then
		error("class " .. name .. " not found")
	end

	local cls = require(conf.NameSpace)
	local properties = conf.Properties or {}

	PropertyParser.parse(cls, properties, nil, nil, customData)

	if conf.TickInterval ~= nil then
		cls.__TickInterval__ = conf.TickInterval
	end

	PropertyParser._parsePropertyCallback(cls, conf)

	local superCls = cls.superType

	if superCls then
		PropertyParser._iterParseClass(superCls.typeName, classMap, customData, classCache)

		for k, declare in pairs(superCls.__Name2PropertyDeclare__) do
			if cls.__Name2PropertyDeclare__[k] ~= nil then
				error(string.format("[WARNING] The property %s redeclared in the class %s and %s!", k, cls.typeName, superCls.typeName))
			end

			cls.__Name2PropertyDeclare__[k] = declare
		end

		for opType, cbs in pairs(superCls.__PropertyCallbacks__) do
			if cls.__PropertyCallbacks__[opType] == nil then
				cls.__PropertyCallbacks__[opType] = {}
			end

			for keyPath, cb in pairs(cbs) do
				if cls.__PropertyCallbacks__[opType][keyPath] then
					error(string.format("[WARNING] The propertyCallback %s redeclared in the class %s and %s!", keyPath, cls.typeName, superCls.typeName))
				end

				cls.__PropertyCallbacks__[opType][keyPath] = cb
			end
		end
	end

	classCache[name] = cls
end

function PropertyParser.parseEntity(config)
	local customData = config.Custom or {}
	local entities = config.Entities

	for name, _ in pairs(entities) do
		PropertyParser._iterParseClass(name, entities, customData, PropertyParser._entities)
	end
end

function PropertyParser.parseUniversal(config)
	local customData = config.Custom or {}
	local universal = config.Universal

	for name, _ in pairs(universal) do
		PropertyParser._iterParseClass(name, universal, customData, PropertyParser._universal)
	end
end

function PropertyParser._parsePropertyCallback(cls, conf)
	if cls.__PropertyCallbacks__ == nil then
		cls.__PropertyCallbacks__ = {}
	end

	local propertyCallbacks = conf.PropertyCallbacks or {}

	for op, callbacks in pairs(propertyCallbacks) do
		local opType = OpStr2OpType[op]

		assert(opType ~= nil)

		if cls.__PropertyCallbacks__[opType] == nil then
			cls.__PropertyCallbacks__[opType] = {}
		end

		for keyPath, info in pairs(callbacks) do
			local propertyType, funcName = unpack(info)

			cls.__PropertyCallbacks__[opType][keyPath] = {
				propertyType,
				funcName
			}
		end
	end
end

function PropertyParser._parseClassPropertyDeclare(cls, classToConfigName)
	local properties = {}

	for k, declare in pairs(cls.__Name2PropertyDeclare__) do
		local ptype

		if declare.typeStr == "number" then
			if declare.propType == PropertyTypes.PT_INT then
				ptype = "int"
			elseif declare.propType == PropertyTypes.PT_DOUBLE then
				ptype = "double"
			else
				error(string.format("%s property %s type %s error", cls.typeName, k, declare.propType))
			end
		elseif declare.customClass and classToConfigName then
			ptype = classToConfigName[declare.customClass] or declare.typeStr
		else
			ptype = declare.typeStr
		end

		local default = declare.default
		local aoiscope

		if declare.aoiscope == PropertyTypes.AOI_ALL_CLIENTS then
			aoiscope = "AllClients"
		elseif declare.aoiscope == PropertyTypes.AOI_OWN_CLIENT then
			aoiscope = "OwnClient"
		elseif declare.aoiscope == PropertyTypes.AOI_SERVER_ONLY then
			aoiscope = "ServerOnly"
		else
			error(string.format("%s property %s aoiscope %s error", cls.typeName, k, declare.aoiscope))
		end

		local persist

		if declare.persist == PropertyTypes.PS_PER then
			persist = "PER"
		elseif declare.persist == PropertyTypes.PS_NPER then
			persist = "NPER"
		else
			error(string.format("%s property %s persist %s error", cls.typeName, k, declare.persist))
		end

		properties[k] = {
			ptype,
			aoiscope,
			persist,
			default
		}
	end

	return properties
end

function PropertyParser.parsePropertyDeclareForLazy()
	local bundleDeclares = {
		PropertyParser._entities,
		PropertyParser._universal
	}
	local bundleConfig = {}
	local customTypeConfig = {}
	local classToConfigName = {}

	for cfgName, cls in pairs(PropertyParser._custom) do
		classToConfigName[cls] = cfgName
	end

	for _, bundleDeclare in ipairs(bundleDeclares) do
		for name, cls in pairs(bundleDeclare) do
			local properties = PropertyParser._parseClassPropertyDeclare(cls, classToConfigName)

			if next(properties) ~= nil then
				bundleConfig[name] = properties
			end
		end
	end

	for name, cls in pairs(PropertyParser._custom) do
		customTypeConfig[name] = {}

		if cls.__CUSTOM_DICT__ then
			customTypeConfig[name].CustomType = "CustomDict"
		elseif cls.__CUSTOM_LIST__ then
			customTypeConfig[name].CustomType = "CustomList"
		else
			error(string.format("%s type unknown", name))
		end

		if cls.__ValueTypeDeclare__ then
			local valueType
			local valueTypeDeclare = cls.__ValueTypeDeclare__

			if valueTypeDeclare.typeStr == "number" then
				if valueTypeDeclare.propType == PropertyTypes.PT_INT then
					valueType = "int"
				elseif valueTypeDeclare.propType == PropertyTypes.PT_DOUBLE then
					valueType = "double"
				else
					error(string.format("%s ValueType %s error", name, valueTypeDeclare.propType))
				end
			elseif valueTypeDeclare.customClass then
				valueType = classToConfigName[valueTypeDeclare.customClass] or valueTypeDeclare.typeStr
			else
				valueType = valueTypeDeclare.typeStr
			end

			customTypeConfig[name].ValueType = valueType

			if cls.__ValueTypeDeclare__.intTypeKey then
				customTypeConfig[name].IntTypeKey = true
			end
		end

		local properties = PropertyParser._parseClassPropertyDeclare(cls, classToConfigName)

		customTypeConfig[name].Properties = properties
	end

	return bundleConfig, customTypeConfig
end

return PropertyParser
