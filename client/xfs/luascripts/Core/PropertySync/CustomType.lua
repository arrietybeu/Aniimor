-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CustomType.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local bit = bit
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local logger = LoggerManager.getLogger("CustomType")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local CommonSwitch = require("Common.CommonSwitch")
local CustomType = class.LiteClass("CustomType")
local math_min = math.min
local math_floor = math.floor
local pairs = pairs
local type = type
local rawget = rawget
local assert = assert
local next = next
local error = error
local table_insert = table.insert
local string_format = string.format
local getRawSetter = getRawSetter

CustomType.__CUSTOM_TYPE__ = true

local function markPersistentDirty(customObj, declare, name, value, opType)
	local root = customObj._root
	local owner = root._owner

	if root:_getPersist() ~= PropertyTypes.PS_PER then
		return
	end

	local persist

	if declare.customClass then
		persist = value:_getPersist()
	else
		persist = math_min(declare.persist, customObj:_getPersist())
	end

	if persist ~= PropertyTypes.PS_PER then
		return
	end

	local markSubDirty = owner.markPersistentSubPropertyDirty

	if markSubDirty ~= nil then
		markSubDirty(owner, customObj, opType, name, declare.customClass ~= nil)

		return
	end

	local markRootDirty = owner.markPersistentRootDirty

	if markRootDirty ~= nil then
		markRootDirty(owner, root._name)
	end
end

function CustomType:ctor()
	local rawsetter = getRawSetter(self)

	rawsetter(self, "toString", nil)
	rawsetter(self, "getClassType", nil)
	rawsetter(self, "className", nil)
	rawsetter(self, "__IsInstance", nil)

	local getClass = self.getClass

	rawsetter(self, "__ClassType", type(getClass) == "function" and getClass(self) or nil)
	rawsetter(self, "getClass", nil)
	rawsetter(self, "__iterator", false)
	rawsetter(self, "_id", PropertyTypes.ID_NOT_INIT)
end

function CustomType:_setName(name)
	getRawSetter(self)(self, "_name", name)
end

function CustomType:enableQuickCopy()
	return false
end

function CustomType:_setDeclare(declare)
	local rawsetter = getRawSetter(self)

	rawsetter(self, "_persist_aoiscope", declare.persist * 8 + declare.aoiscope)

	if declare.feature ~= PropertyTypes.P_FEATURE_NONE then
		rawsetter(self, "_feature", declare.feature)
	end
end

function CustomType:_setOwner(owner)
	if self._root == self then
		getRawSetter(self)(self, "_owner", owner)
	end

	if self._id == PropertyTypes.ID_INIT then
		self._id = owner:_genNextPropertyId()
	end

	if self._id > PropertyTypes.ID_LAZY_INIT then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:_setOwner(owner)
			end
		end
	end
end

function CustomType:_getPersist()
	return math_floor(self._persist_aoiscope / 8)
end

function CustomType:_getAoiscope()
	return self._persist_aoiscope % 8
end

function CustomType:setDelegator(delegator)
	getRawSetter(self)(self, "_delegator", delegator)

	if self._id > PropertyTypes.ID_LAZY_INIT then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:setDelegator(delegator)
			end
		end
	end
end

function CustomType:getDelegator()
	return self._delegator
end

function CustomType:_markRoot()
	getRawSetter(self)(self, "_root", self)
end

function CustomType:_isRoot()
	return self._root == self
end

function CustomType:_setParent(parent)
	local rawsetter = getRawSetter(self)

	rawsetter(self, "_parent", parent)

	if parent ~= nil then
		assert(parent._root ~= nil)

		local aoiscope = math_min(self._persist_aoiscope % 8, parent._persist_aoiscope % 8)
		local persist = math_min(math_floor(self._persist_aoiscope / 8), math_floor(parent._persist_aoiscope / 8))

		rawsetter(self, "_persist_aoiscope", persist * 8 + aoiscope)
		rawsetter(self, "_root", parent._root)
	else
		assert(self._root ~= nil)
	end

	if self._id > PropertyTypes.ID_LAZY_INIT then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				CustomType._setParent(v, self)
			end
		end
	end
end

function CustomType:_setInvalid()
	if self._id > PropertyTypes.ID_LAZY_INIT then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:_setInvalid()
			end
		end
	end

	self._id = PropertyTypes.ID_INVLIAD
end

function CustomType:isInvalid()
	return self._id == PropertyTypes.ID_INVLIAD
end

function CustomType:_isWrapper()
	if self._parent ~= self._root then
		return false
	end

	if rawget(self, "_feature") == nil then
		return false
	end

	return bit.band(self._feature, PropertyTypes.P_FEATURE_WRAP) ~= 0
end

function CustomType:_onLazyLoadInRuntime()
	if self._root == nil then
		return
	end

	local owner = self._root._owner

	if not owner.__startfinish then
		return
	end

	local aoiscope = self:_getAoiscope()
	local parent = rawget(self, "_parent")

	if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
		if parent ~= nil then
			owner:propertyIdSync2Client(aoiscope, parent._id, self._name, self)
		else
			owner:propertyIdSync2Client(aoiscope, -1, self._name, self)
		end
	end
end

function CustomType:_onSubPropertyChangedInRuntime(declare, name, value)
	if self._root == nil then
		return
	end

	markPersistentDirty(self, declare, name, value, PropertyTypes.OP_CHANGE)

	local owner = self._root._owner

	if not owner.__startfinish then
		return
	end

	if not SyncStrategyMgr.running then
		local delegator = rawget(self, "_delegator")

		if delegator ~= nil then
			owner = delegator
		end

		local aoiscope, persist

		if not declare.customClass then
			aoiscope = math_min(declare.aoiscope, self:_getAoiscope())
			persist = math_min(declare.persist, self:_getPersist())
		else
			aoiscope = value:_getAoiscope()
			persist = value:_getPersist()
		end

		if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
			owner:propertySync2Client(aoiscope, self._id, PropertyTypes.OP_CHANGE, name, value)
		end

		if delegator ~= nil and delegator.onPropertyModify then
			delegator:onPropertyModify(self, self._id, PropertyTypes.OP_CHANGE, name, value)
		end
	else
		SyncStrategyMgr.onSubPropertyChangedInRuntime(owner, self, declare, name, value)
	end
end

function CustomType:_onSubPropertyDeletedInRuntime(declare, name, value)
	if self._root == nil then
		return
	end

	markPersistentDirty(self, declare, name, value, PropertyTypes.OP_DEL)

	local owner = self._root._owner

	if not owner.__startfinish then
		return
	end

	if not SyncStrategyMgr.running then
		local delegator = rawget(self, "_delegator")

		if delegator ~= nil then
			owner = delegator
		end

		local optype

		if self:isCustomList() then
			optype = PropertyTypes.OP_REMOVE
		else
			optype = PropertyTypes.OP_DEL
		end

		local aoiscope = self:_getAoiscope()

		if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
			owner:propertySync2Client(aoiscope, self._id, optype, name, nil)
		end

		if delegator ~= nil and delegator.onPropertyModify then
			delegator:onPropertyModify(self, self._id, optype, name, value)
		end
	else
		SyncStrategyMgr.onSubPropertyDeletedInRuntime(owner, self, declare, name, value)
	end
end

function CustomType:_onSubPropertyCreatedInRuntime(declare, name, value)
	if self._root == nil then
		return
	end

	markPersistentDirty(self, declare, name, value, PropertyTypes.OP_ADD)

	local owner = self._root._owner

	if not owner.__startfinish then
		return
	end

	if not SyncStrategyMgr.running then
		local delegator = rawget(self, "_delegator")

		if delegator ~= nil then
			owner = delegator
		end

		local optype

		if self:isCustomList() then
			optype = PropertyTypes.OP_INSERT
		else
			optype = PropertyTypes.OP_ADD
		end

		local aoiscope = self:_getAoiscope()

		if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
			owner:propertySync2Client(aoiscope, self._id, optype, name, value)
		end

		if delegator ~= nil and delegator.onPropertyModify then
			delegator:onPropertyModify(self, self._id, optype, name, value)
		end
	else
		SyncStrategyMgr.onSubPropertCreatedInRuntime(owner, self, declare, name, value)
	end
end

function CustomType:reuse()
	if self._id ~= PropertyTypes.ID_INVLIAD then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s reuse but not invalid", self.__ClassType.typeName)
		end

		return
	end

	local rawsetter = getRawSetter(self)

	rawsetter(self, "_root", nil)
	rawsetter(self, "_parent", nil)
	rawsetter(self, "_delegator", nil)

	if type(self._properties) == "userdata" then
		self._id = PropertyTypes.ID_LAZY_INIT
	else
		self._id = PropertyTypes.ID_INIT

		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:reuse()
			end
		end
	end
end

function CustomType:isCustomType()
	return true
end

function CustomType:isCustomDict()
	return false
end

function CustomType:isCustomList()
	return false
end

function CustomType:customTypeName()
	return "customType"
end

function CustomType:getRootOwner()
	return self._root and self._root._owner
end

function CustomType:getPersistentValue()
	if self:_getPersist() ~= PropertyTypes.PS_PER then
		return nil
	end

	if type(self._properties) == "userdata" then
		if rawget(self, "_readonly") then
			self:_rolazyload()
		else
			self:_lazyload()
		end
	end

	return self:_getPersistentValue()
end

function CustomType:getRawTable()
	if type(self._properties) == "userdata" then
		if rawget(self, "_readonly") then
			self:_rolazyload()
		else
			self:_lazyload()
		end
	end

	local raw = {}

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			if type(v) == "table" then
				raw[k] = v:getRawTable()
			else
				raw[k] = v
			end
		end
	end

	return raw
end

function CustomType:rawset(name, value)
	if type(self._properties) == "table" and self._properties[name] ~= nil then
		error(string_format("%s rawset %s would cover sub property", self.__ClassType.typeName, name))
	end

	getRawSetter(self)(self, name, value)
end

function CustomType:items()
	if type(self._properties) == "userdata" then
		if rawget(self, "_readonly") then
			self:_rolazyload()
		else
			self:_lazyload()
		end
	end

	local props = self._properties
	local iterator = self.__iterator

	if iterator ~= false then
		return iterator, props, nil
	end

	local cnext = raw_next

	if type(props) == "userdata" then
		local metatable = getmetatable(props)

		if metatable and metatable.__next then
			cnext = metatable.__next
		end
	end

	local propDeclares = self.__ClassType.__Name2PropertyDeclare__

	function iterator(t, k)
		local v

		k, v = cnext(t, k)

		if v ~= nil then
			if k == "_" then
				return iterator(t, k)
			elseif propDeclares[k] == nil then
				return k, v
			else
				return iterator(t, k)
			end
		end
	end

	self.__iterator = iterator

	return iterator, props, nil
end

function CustomType:fast_items()
	if type(self._properties) == "userdata" then
		if rawget(self, "_readonly") then
			self:_rolazyload()
		else
			self:_lazyload()
		end
	end

	local props = self._properties
	local iterator = self.__iterator

	if iterator ~= false then
		return iterator, props, nil
	end

	local cnext = raw_next

	if type(props) == "userdata" then
		local metatable = getmetatable(props)

		if metatable and metatable.__next then
			cnext = metatable.__next
		end
	end

	local propDeclares = self.__ClassType.__Name2PropertyDeclare__

	if raw_next(propDeclares) then
		function iterator(t, k)
			local v

			k, v = cnext(t, k)

			if v ~= nil then
				if k == "_" then
					return iterator(t, k)
				elseif propDeclares[k] == nil then
					return k, v
				else
					return iterator(t, k)
				end
			end
		end
	else
		function iterator(t, k)
			local v

			k, v = cnext(t, k)

			if k == "_" then
				return iterator(t, k)
			else
				return k, v
			end
		end
	end

	self.__iterator = iterator

	return iterator, props, nil
end

function CustomType:_attachToCache(cache)
	if cache == nil then
		return
	end

	if self._id < PropertyTypes.ID_SYNC_START then
		return
	end

	if cache[self._id] ~= nil and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("%s attach to cache, id %s repeated!", self.__ClassType.typeName, self._id)
	end

	cache[self._id] = self

	if type(self._properties) == "table" then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:_attachToCache(cache)
			end
		end
	end
end

function CustomType:_detachFromCache(cache)
	if cache == nil then
		return
	end

	if self._id < PropertyTypes.ID_SYNC_START then
		return
	end

	if cache[self._id] == nil and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("%s detach from cache, id %s not found!", self.__ClassType.typeName, self._id)
	end

	cache[self._id] = nil

	if type(self._properties) == "table" then
		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:_detachFromCache(cache)
			end
		end
	end
end

function CustomType:_onSyncPropertyId(name, value, cache)
	if type(self._properties) == "userdata" then
		self:_rolazyload()
	end

	if name ~= nil then
		local customObj = self._properties[name]

		customObj:_onSyncPropertyId(nil, value, cache)
	else
		local id = value.__id__

		value.__id__ = nil
		self._id = id

		self:_attachToCache(cache)

		for k, v in pairs(value) do
			self:_onSyncPropertyId(k, v, cache)
		end
	end
end

function CustomType:_pathFromRoot2Myself()
	if self._path == nil then
		local rawsetter = getRawSetter(self)

		if self._parent == nil then
			rawsetter(self, "_path", self._name)
		else
			local path = self._parent:_pathFromRoot2Myself()

			if self._unfixed then
				rawsetter(self, "_path", string_format("%s.*", path))
			else
				rawsetter(self, "_path", string_format("%s.%s", path, self._name))
			end
		end
	end

	return self._path
end

function CustomType:_gatherUnfixedNames()
	local unfixedNames

	if self._parent ~= nil then
		unfixedNames = self._parent:_gatherUnfixedNames()
	end

	if self._unfixed then
		if unfixedNames ~= nil then
			table_insert(unfixedNames, self._name)
		else
			unfixedNames = {
				self._name
			}
		end
	end

	return unfixedNames
end

function CustomType:_traceSubNode(subNodeName)
	local path = self:_pathFromRoot2Myself()
	local unfixedNames = self:_gatherUnfixedNames()
	local temp
	local propDeclares = self.__ClassType.__Name2PropertyDeclare__

	if propDeclares[subNodeName] ~= nil then
		temp = subNodeName
	else
		temp = "*"

		if unfixedNames ~= nil then
			table_insert(unfixedNames, subNodeName)
		else
			unfixedNames = {
				subNodeName
			}
		end
	end

	return string_format("%s.%s", path, temp), unfixedNames
end

function CustomType:quickCopy(setK, setV, setPropertiesCnt, opCode)
	if type(self._properties) == "userdata" then
		self:_rolazyload()
	end

	if not self:enableQuickCopy() then
		return self
	end

	local propertyTable = {}
	local customCls = self.__ClassType
	local copyObj = customCls()
	local copyRawSetter = getRawSetter(copyObj)

	if self:isCustomList() then
		for idx, v in ipairs(self._properties) do
			propertyTable[idx] = v
		end
	else
		for k, v in pairs(self._properties) do
			propertyTable[k] = v
		end
	end

	if self:isCustomList() then
		if opCode == PropertyTypes.OP_REMOVE then
			table.remove(propertyTable, setK)
		elseif opCode == PropertyTypes.OP_INSERT then
			table.insert(propertyTable, setK, setV)
			copyRawSetter(copyObj, setK, setV)
		else
			propertyTable[setK] = setV
		end
	else
		propertyTable[setK] = setV

		copyRawSetter(copyObj, setK, setV)
	end

	local metatable = getmetatable(self)

	copyRawSetter(copyObj, "_properties", propertyTable)

	if setPropertiesCnt then
		copyRawSetter(copyObj, "_propertiesCnt", setPropertiesCnt)
	end

	setmetatable(copyObj, metatable)

	return copyObj
end

function CustomType:deepCopy()
	if type(self._properties) == "userdata" then
		self:_rolazyload()
	end

	local customCls = self.__ClassType
	local copyObj = customCls()
	local metatable = getmetatable(self)

	setmetatable(copyObj, metatable)

	local copyRawSetter = getRawSetter(copyObj)

	copyRawSetter(copyObj, "_properties", {})

	for k, v in pairs(self._properties) do
		if type(v) == "table" then
			copyObj._properties[k] = v:deepCopy()
		else
			copyObj._properties[k] = v
		end
	end

	copyRawSetter(copyObj, "_propertiesCnt", self._propertiesCnt)

	return copyObj
end

return CustomType
