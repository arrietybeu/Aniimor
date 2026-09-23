-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\PropertyDeclare.lua

local class = require("Core.Framework.Class")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local bit = bit
local PropertyDeclare = class.Class("PropertyDeclare")

function PropertyDeclare:ctor(name, propType, default, aoiscope, persist, feature)
	if propType == "int" then
		self.propType = PropertyTypes.PT_INT
		self.typeStr = "number"
	elseif propType == "double" then
		self.propType = PropertyTypes.PT_DOUBLE
		self.typeStr = "number"
	elseif propType == "string" then
		self.propType = PropertyTypes.PT_STRING
		self.typeStr = "string"
	elseif propType == "boolean" then
		self.propType = PropertyTypes.PT_BOOLEAN
		self.typeStr = "boolean"
	elseif propType == "table" then
		self.propType = PropertyTypes.PT_TABLE
		self.typeStr = "table"
	elseif propType.__IsClass then
		if propType.__CUSTOM_DICT__ then
			self.propType = PropertyTypes.PT_DICT
			self.typeStr = propType.typeName
			self.customClass = propType
		elseif propType.__CUSTOM_LIST__ then
			self.propType = PropertyTypes.PT_LIST
			self.typeStr = propType.typeName
			self.customClass = propType
		else
			error(string.format("declare property '%s' with invalid propType '%s'", name or "", propType.typeName))
		end
	else
		error(string.format("declare property '%s' with invalid propType '%s'", name or "", propType))
	end

	self.name = name
	self.default = default

	if aoiscope == "AllClients" then
		self.aoiscope = PropertyTypes.AOI_ALL_CLIENTS
	elseif aoiscope == "OwnClient" then
		self.aoiscope = PropertyTypes.AOI_OWN_CLIENT
	elseif aoiscope == "ServerOnly" then
		self.aoiscope = PropertyTypes.AOI_SERVER_ONLY
	elseif aoiscope == "DummyAOI" then
		self.aoiscope = PropertyTypes.AOI_DUMMY
	else
		error(string.format("declare property '%s' with invalid aoiscope '%s'", name or "", aoiscope))
	end

	if persist == "PER" then
		self.persist = PropertyTypes.PS_PER
	elseif persist == "NPER" then
		self.persist = PropertyTypes.PS_NPER
	elseif persist == "DummyPER" then
		self.persist = PropertyTypes.PS_DUMMY
	else
		error(string.format("declare property '%s' with unknown persist flag '%s'", name or "", persist))
	end

	self.feature = PropertyTypes.P_FEATURE_NONE

	if feature ~= nil then
		for _, f in ipairs(feature) do
			if f == "wrap" then
				self.feature = bit.bor(self.feature, PropertyTypes.P_FEATURE_WRAP)
			elseif f == "delay" then
				self.feature = bit.bor(self.feature, PropertyTypes.P_FEATURE_DELAY)
			else
				error(string.format("declare property '%s' with unknown feature type '%s'", name or "", f))
			end
		end
	end

	self.isFixedDeclare = true
end

function PropertyDeclare:createCustomObj(dict)
	local obj = self.customClass()

	obj:init(dict)

	return obj
end

function PropertyDeclare:createCustomObjRO(name, value, owner, parent, aoiscopeForLazy)
	local obj = self.customClass()

	obj:roinit(name, value, owner, parent, self.isFixedDeclare, aoiscopeForLazy)

	return obj
end

function PropertyDeclare:isNativeType()
	return self.propType > PropertyTypes.PT_START and self.propType < PropertyTypes.PT_NATIVE_END
end

function PropertyDeclare:isCustomType()
	return self.propType > PropertyTypes.PT_CUSTOM_START and self.propType < PropertyTypes.PT_END
end

return PropertyDeclare
