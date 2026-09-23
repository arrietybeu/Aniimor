-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CustomDict.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CustomType = require("Core.PropertySync.CustomType")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local logger = LoggerManager.getLogger("CustomDict")
local Switch = require("Core.Common.Switch")
local CustomDict = class.LiteClass("CustomDict", CustomType)
local pairs = pairs
local type = type
local rawget = rawget
local assert = assert
local next = next
local tonumber = tonumber
local tostring = tostring
local error = error
local table_insert = table.insert
local string_format = string.format
local getRawSetter = getRawSetter

CustomDict.__CUSTOM_DICT__ = true

local raw_next = raw_next

local function pairsIterator(t, k)
	local v

	k, v = raw_next(t, k)

	if v ~= nil then
		if k == "_" then
			return pairsIterator(t, k)
		end

		return k, v
	end
end

local mt = {
	__index = function(tbl, k)
		local v = tbl._properties[k]

		if v ~= nil then
			return v
		else
			local classType = tbl.__ClassType

			return classType[k]
		end
	end,
	__newindex = function(tbl, k, v)
		if tbl._id == PropertyTypes.ID_INVLIAD then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, write closed, only read open", tbl.__ClassType.typeName)
			end

			return
		end

		if _G_IsDebugMode and type(k) == "number" and k ~= math.floor(k) then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, key is not integer", tbl.__ClassType.typeName, debug.traceback())
			end

			return
		end

		local classType = tbl.__ClassType
		local _properties = tbl._properties
		local oldv = _properties[k]

		if oldv ~= nil then
			if v ~= nil then
				if oldv == v then
					return
				end

				if type(oldv) ~= type(v) then
					error(string_format("%s modify property %s value dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, type(oldv), type(v)))
				end

				local propDeclares = classType.__Name2PropertyDeclare__
				local declare = propDeclares[k]

				if declare == nil then
					declare = classType.__ValueTypeDeclare__
				end

				if not declare.customClass then
					_properties[k] = v
				else
					if v.__ClassType ~= nil then
						if v.__ClassType.typeName ~= declare.typeStr then
							error(string_format("%s modify property %s value dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, declare.typeStr, v.__ClassType.typeName))
						end

						if v._id <= PropertyTypes.ID_NOT_INIT then
							error(string_format("%s modify property %s with invalid %s instance!", tbl.__ClassType.typeName, k, v.__ClassType.typeName))
						end
					else
						v = declare:createCustomObj(v)
					end

					v:_setName(k)
					v:_setDeclare(declare)

					if tbl._root then
						v:_setParent(tbl)
						v:_setOwner(tbl._root._owner)
					end

					local delegator = rawget(tbl, "_delegator")

					if delegator ~= nil then
						v:setDelegator(delegator)
					end

					_properties[k] = v

					oldv:_setInvalid()
				end

				tbl:_onSubPropertyChangedInRuntime(declare, k, v)
			else
				local propDeclares = classType.__Name2PropertyDeclare__
				local declare = propDeclares[k]

				if declare ~= nil then
					error(string_format("%s delete fixed property %s unsupported!", tbl.__ClassType.typeName, k))
				end

				declare = classType.__ValueTypeDeclare__

				if declare.customClass then
					oldv:_setInvalid()
				end

				local cnt = tbl._propertiesCnt

				tbl._propertiesCnt = cnt - 1
				_properties[k] = nil

				tbl:_onSubPropertyDeletedInRuntime(declare, k, oldv)
			end
		elseif v ~= nil then
			local valueTypeDeclare = classType.__ValueTypeDeclare__

			if valueTypeDeclare ~= nil then
				if v ~= nil then
					if type(k) ~= valueTypeDeclare.keyType then
						error(string_format("%s add unfixed property %s key type dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, valueTypeDeclare.keyType, type(k)))
					end

					if not valueTypeDeclare.customClass then
						if type(v) ~= valueTypeDeclare.typeStr then
							error(string_format("%s add unfixed property %s value type dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, valueTypeDeclare.typeStr, type(v)))
						end
					else
						if v.__ClassType ~= nil then
							if v.__ClassType.typeName ~= valueTypeDeclare.typeStr then
								error(string_format("%s add unfixed property %s value type dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, valueTypeDeclare.typeStr, v.__ClassType.typeName))
							end

							if v._id <= PropertyTypes.ID_NOT_INIT then
								error(string_format("%s add unfixed property %s with invalid %s instance!", tbl.__ClassType.typeName, k, v.__ClassType.typeName))
							end
						else
							v = valueTypeDeclare:createCustomObj(v)
						end

						v:_setName(k)
						v:_setDeclare(valueTypeDeclare)

						if tbl._root then
							v:_setParent(tbl)
							v:_setOwner(tbl._root._owner)
						end

						local delegator = rawget(tbl, "_delegator")

						if delegator ~= nil then
							v:setDelegator(delegator)
						end
					end

					_properties[k] = v

					local cnt = tbl._propertiesCnt

					tbl._propertiesCnt = cnt + 1

					tbl:_onSubPropertyCreatedInRuntime(valueTypeDeclare, k, v)
				end
			else
				error(string_format("%s add unfixed property %s undefined!", tbl.__ClassType.typeName, k))
			end
		end
	end,
	__pairs = function(tbl)
		return pairsIterator, tbl._properties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		return tbl._propertiesCnt
	end
}
local lazy_mt = {
	__index = function(tbl, k)
		local classType = tbl.__ClassType
		local v = classType[k]

		if v ~= nil then
			return v
		end

		tbl:_lazyload()

		v = tbl._properties[k]

		return v
	end,
	__newindex = function(tbl, k, v)
		if tbl._id == PropertyTypes.ID_INVLIAD then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, write closed, only read open", tbl.__ClassType.typeName)
			end

			return
		end

		tbl:_lazyload()

		tbl[k] = v
	end,
	__pairs = function(tbl)
		tbl:_lazyload()

		return pairsIterator, tbl._properties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		tbl:_lazyload()

		return tbl._propertiesCnt
	end
}

function CustomDict:ctor(dict)
	CustomDict.super.ctor(self)

	if dict ~= nil then
		self:init(dict)
	end
end

function CustomDict:init(dict)
	if self._id >= PropertyTypes.ID_INIT then
		error(string_format("%s repeat init!", self.__ClassType.typeName))
	end

	local rawsetter = getRawSetter(self)
	local userdata = dict.__bin_data

	if userdata ~= nil then
		self._id = PropertyTypes.ID_LAZY_INIT

		rawsetter(self, "_properties", userdata)
		setmetatable(self, lazy_mt)
	else
		self._id = PropertyTypes.ID_INIT

		local _properties = {}
		local _propertiesCnt = 0
		local classType = self.__ClassType
		local propDeclares = classType.__Name2PropertyDeclare__
		local valueTypeDeclare = classType.__ValueTypeDeclare__

		if dict._ ~= nil then
			dict._ = nil
		end

		for name, declare in pairs(propDeclares) do
			local v = dict[name]

			if not declare.customClass then
				if v == nil then
					v = declare.default
				elseif type(v) ~= declare.typeStr then
					error(string_format("%s init property %s value type dismatch, need %s but get %s!", self.__ClassType.typeName, name, declare.typeStr, type(v)))
				end
			else
				if v == nil then
					v = {}
				end

				v = declare:createCustomObj(v)

				v:_setName(name)
				v:_setDeclare(declare)
			end

			_properties[name] = v
		end

		if valueTypeDeclare ~= nil then
			for k, v in pairs(dict) do
				if propDeclares[k] == nil then
					if type(k) ~= "string" and not valueTypeDeclare.intTypeKey then
						error(string_format("%s init property %s failed, key is not string", self.__ClassType.typeName, k))
					end

					if valueTypeDeclare.intTypeKey and type(k) ~= "number" then
						k = tonumber(k)
					end

					if k ~= nil then
						if not valueTypeDeclare.customClass then
							if type(v) ~= valueTypeDeclare.typeStr then
								error(string_format("%s init property %s value type dismatch, need %s but get %s!", self.__ClassType.typeName, k, valueTypeDeclare.typeStr, type(v)))
							end
						else
							v = valueTypeDeclare:createCustomObj(v)

							v:_setName(k)
							v:_setDeclare(valueTypeDeclare)
						end

						_properties[k] = v
						_propertiesCnt = _propertiesCnt + 1
					end
				end
			end
		end

		if next(propDeclares) == nil then
			_properties._ = ""
		end

		rawsetter(self, "_properties", _properties)
		rawsetter(self, "_propertiesCnt", _propertiesCnt)
		setmetatable(self, mt)
	end

	return true
end

function CustomDict:_lazyload()
	local originID = self._id

	if originID ~= PropertyTypes.ID_LAZY_INIT and originID ~= PropertyTypes.ID_INVLIAD then
		error(string_format("%s do lazy load when _id=%s", self.__ClassType.typeName, originID))

		return
	end

	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadStart(self._root._owner)
	end

	local dict = phonestcore.userdataDecode(self._properties)

	getRawSetter(self)(self, "_properties", {})

	self._id = PropertyTypes.ID_NOT_INIT

	setmetatable(self, mt)
	CustomDict.init(self, dict)

	if originID == PropertyTypes.ID_LAZY_INIT then
		local owner = self._root._owner

		self._id = owner:_genNextPropertyId()

		local delegator = rawget(self, "_delegator")

		for _, v in pairs(self._properties) do
			if type(v) == "table" then
				v:_setParent(self)
				v:_setOwner(owner)

				if delegator ~= nil then
					v:setDelegator(delegator)
				end
			end
		end

		self:_onLazyLoadInRuntime()
	else
		self:_setInvalid()
	end

	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadEnd(self._root._owner, self.__ClassType.typeName, dict, "_lazyload")
	end
end

function CustomDict:getPersistentValue()
	return CustomDict.super.getPersistentValue(self)
end

function CustomDict:_getPersistentValue()
	local pdict = {}
	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k]

			if declare ~= nil then
				assert(type(k) == "string")

				if declare.customClass then
					pdict[k] = v:getPersistentValue()
				elseif declare.persist == PropertyTypes.PS_PER then
					pdict[k] = v
				end
			else
				assert(valueTypeDeclare ~= nil)

				if valueTypeDeclare.intTypeKey then
					k = tostring(k)
				end

				assert(type(k) == "string")

				if pdict[k] ~= nil then
					error("%s persistent property %s repeated!", self.__ClassType.typeName, k)
				end

				if valueTypeDeclare.customClass then
					pdict[k] = v:getPersistentValue()
				else
					pdict[k] = v
				end
			end
		else
			pdict[k] = v
		end
	end

	assert(next(pdict) ~= nil)

	return pdict
end

function CustomDict:getOwnClientValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local cdict = {}
	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k]

			if declare ~= nil then
				if declare.customClass then
					cdict[k] = v:getOwnClientValue()
				elseif declare.aoiscope > PropertyTypes.AOI_SERVER_ONLY then
					cdict[k] = v
				end
			else
				assert(valueTypeDeclare ~= nil)

				if valueTypeDeclare.customClass then
					cdict[k] = v:getOwnClientValue()
				else
					cdict[k] = v
				end
			end
		end
	end

	cdict.__id__ = self._id

	if self:_isRoot() then
		cdict.__tp__ = classType.typeName
	end

	return cdict
end

function CustomDict:getAllClientsValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local cdict = {}
	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k]

			if declare ~= nil then
				if declare.customClass then
					cdict[k] = v:getAllClientsValue()
				elseif declare.aoiscope > PropertyTypes.AOI_OWN_CLIENT then
					cdict[k] = v
				end
			else
				assert(valueTypeDeclare ~= nil)

				if valueTypeDeclare.customClass then
					cdict[k] = v:getAllClientsValue()
				else
					cdict[k] = v
				end
			end
		end
	end

	cdict.__id__ = self._id

	if self:_isRoot() then
		cdict.__tp__ = classType.typeName
	end

	return cdict
end

function CustomDict:getOwnAndAllClientsValue(aoiscope)
	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil, nil
	end

	local ownDict = {}
	local allDict = {}
	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__
	local ownType = PropertyTypes.AOI_OWN_CLIENT
	local allType = PropertyTypes.AOI_ALL_CLIENTS

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k]

			if declare ~= nil then
				if declare.customClass then
					ownDict[k], allDict[k] = v:getOwnAndAllClientsValue(aoiscope)
				else
					local declare_aoiscope = declare.aoiscope

					if ownType <= declare_aoiscope then
						ownDict[k] = v
					end

					if declare_aoiscope == allType then
						allDict[k] = v
					end
				end
			else
				assert(valueTypeDeclare ~= nil)

				if valueTypeDeclare.customClass then
					ownDict[k], allDict[k] = v:getOwnAndAllClientsValue(aoiscope)
				else
					ownDict[k] = v

					if aoiscope == allType then
						allDict[k] = v
					end
				end
			end
		end
	end

	ownDict.__id__ = self._id
	allDict.__id__ = self._id

	if self:_isRoot() then
		ownDict.__tp__ = classType.typeName
		allDict.__tp__ = classType.typeName
	end

	return ownDict, allDict
end

function CustomDict:getOwnClientPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__
	local cids = {
		__id__ = self._id
	}

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k] or valueTypeDeclare

			if declare.customClass then
				cids[k] = v:getOwnClientPropertyIds()
			end
		end
	end

	return cids
end

function CustomDict:getAllClientsPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__
	local cids = {
		__id__ = self._id
	}

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k] or valueTypeDeclare

			if declare.customClass then
				cids[k] = v:getAllClientsPropertyIds()
			end
		end
	end

	return cids
end

function CustomDict:getJournalPropertyIds()
	if self:_getPersist() ~= PropertyTypes.PS_PER then
		return nil
	end

	local jdict = {}

	if self._id < PropertyTypes.ID_SYNC_START then
		jdict._ = {
			-1,
			PropertyTypes.PS_PATTERN_INT_KEY,
			PropertyTypes.CUSTOM_TYPE_DICT
		}

		return jdict
	end

	local classType = self.__ClassType
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(self._properties) do
		if k ~= "_" and type(v) == "table" then
			jdict[k] = v:getJournalPropertyIds()
		end
	end

	if valueTypeDeclare and valueTypeDeclare.intTypeKey then
		jdict._ = {
			self._id,
			PropertyTypes.PS_PATTERN_INT_KEY,
			PropertyTypes.CUSTOM_TYPE_DICT
		}
	else
		jdict._ = {
			self._id,
			PropertyTypes.PS_PATTERN_DEFAULT,
			PropertyTypes.CUSTOM_TYPE_DICT
		}
	end

	return jdict
end

function CustomDict:getJournalValue()
	assert(self._id >= PropertyTypes.ID_SYNC_START)

	if self:_getPersist() ~= PropertyTypes.PS_PER then
		return nil
	end

	local jdict = {}
	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(self._properties) do
		if k ~= "_" then
			local declare = propDeclares[k]

			if declare ~= nil then
				if declare.customClass then
					jdict[k] = v:getJournalValue()
				elseif declare.persist == PropertyTypes.PS_PER then
					jdict[k] = v
				end
			else
				assert(valueTypeDeclare ~= nil)

				if valueTypeDeclare.customClass then
					jdict[k] = v:getJournalValue()
				else
					jdict[k] = v
				end
			end
		end
	end

	if valueTypeDeclare and valueTypeDeclare.intTypeKey then
		jdict._ = {
			self._id,
			PropertyTypes.PS_PATTERN_INT_KEY,
			PropertyTypes.CUSTOM_TYPE_DICT
		}
	else
		jdict._ = {
			self._id,
			PropertyTypes.PS_PATTERN_DEFAULT,
			PropertyTypes.CUSTOM_TYPE_DICT
		}
	end

	return jdict
end

function CustomDict:isCustomDict()
	return true
end

function CustomDict:customTypeName()
	return "customDict"
end

local mtRO = {
	__index = mt.__index,
	__newindex = function(tbl, k, v)
		local oldValue = tbl._properties[k]

		tbl._properties[k] = v

		local owner = tbl._owner

		if owner then
			if type(v) == "table" then
				owner:_queryPropertyChangedCallback(tbl, k, oldValue, v, v:customTypeName())
			else
				owner:_queryPropertyChangedCallback(tbl, k, oldValue, v, type(v))
			end
		end
	end,
	__pairs = mt.__pairs,
	__ipairs = mt.__ipairs,
	__len = function(tbl)
		return tbl._propertiesCnt or 0
	end
}
local lazy_mtRO = {
	__index = function(tbl, k)
		local classType = tbl.__ClassType
		local v = classType[k]

		if v ~= nil then
			return v
		end

		tbl:_rolazyload()

		v = tbl._properties[k]

		return v
	end,
	__newindex = function(tbl, k, v)
		tbl:_rolazyload()

		local oldValue = tbl._properties[k]

		tbl._properties[k] = v

		local owner = tbl._owner

		if owner then
			if type(v) == "table" then
				owner:_queryPropertyChangedCallback(tbl, k, oldValue, v, v:customTypeName())
			else
				owner:_queryPropertyChangedCallback(tbl, k, oldValue, v, type(v))
			end
		end
	end,
	__pairs = function(tbl)
		tbl:_rolazyload()

		return pairsIterator, tbl._properties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		tbl:_rolazyload()

		return tbl._propertiesCnt or 0
	end
}

function CustomDict:roinit(name, value, owner, parent, fixed, aoiscopeForLazy)
	if self._id >= PropertyTypes.ID_INIT then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s repeat init!", self.__ClassType.typeName)
		end

		return
	end

	local rawsetter = getRawSetter(self)

	rawsetter(self, "_owner", owner)
	rawsetter(self, "_parent", parent)
	rawsetter(self, "_name", name)
	rawsetter(self, "_unfixed", not fixed)
	rawsetter(self, "_readonly", true)

	if parent ~= nil then
		rawsetter(self, "_root", parent._root)
	else
		rawsetter(self, "_root", self)
	end

	rawsetter(self, "_aoiscopeForLazy", aoiscopeForLazy)

	local userdata = value.__bin_data

	if userdata ~= nil then
		self._id = value.__id__ or PropertyTypes.ID_LAZY_INIT

		rawsetter(self, "_properties", userdata)
		rawsetter(self, "_propertiesCnt", 0)
		setmetatable(self, lazy_mtRO)
	else
		local id = value.__id__

		if id ~= nil then
			self._id = id
			value.__id__ = nil
		else
			self._id = PropertyTypes.ID_INIT
		end

		rawsetter(self, "_properties", {})
		rawsetter(self, "_propertiesCnt", 0)

		value._ = nil

		local classType = self.__ClassType
		local propDeclares = classType.__Name2PropertyDeclare__
		local valueTypeDeclare = classType.__ValueTypeDeclare__

		if aoiscopeForLazy == nil then
			for k, v in pairs(value) do
				local declare = propDeclares[k]

				if declare == nil then
					declare = valueTypeDeclare
				end

				if declare == nil then
					if LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string_format("%s roinit property %s failed, property not declared", self.__ClassType.typeName, k))
					end

					return
				end

				if declare.customClass then
					v = declare:createCustomObjRO(k, v, owner, self)
				end

				self._properties[k] = v

				if not declare.isFixedDeclare then
					self._propertiesCnt = self._propertiesCnt + 1
				end
			end
		else
			for k, declare in pairs(propDeclares) do
				if aoiscopeForLazy <= declare.aoiscope then
					local v = value[k]

					if not declare.customClass then
						if v == nil then
							v = declare.default
						elseif type(v) ~= declare.typeStr then
							error(string_format("%s roinit property %s value type dismatch, need %s but get %s!", self.__ClassType.typeName, k, declare.typeStr, type(v)))
						end
					else
						if v == nil then
							v = {}
						end

						v = declare:createCustomObjRO(k, v, owner, self, aoiscopeForLazy)
					end

					self._properties[k] = v
				end
			end

			for k, v in pairs(value) do
				if propDeclares[k] == nil then
					if valueTypeDeclare ~= nil then
						if type(k) ~= "string" and not valueTypeDeclare.intTypeKey then
							error(string_format("%s roinit property %s failed, key is not string", self.__ClassType.typeName, k))
						end

						if valueTypeDeclare.intTypeKey and type(k) ~= "number" then
							k = tonumber(k)

							if not k then
								error(string_format("%s roinit property failed, key for valueType is not number", self.__ClassType.typeName))
							end
						end

						if not valueTypeDeclare.customClass then
							if type(v) ~= valueTypeDeclare.typeStr then
								error(string_format("%s roinit property %s value type dismatch, need %s but get %s!", self.__ClassType.typeName, k, valueTypeDeclare.typeStr, type(v)))
							end
						else
							v = valueTypeDeclare:createCustomObjRO(k, v, owner, self, aoiscopeForLazy)
						end

						self._properties[k] = v

						local cnt = self._propertiesCnt

						self._propertiesCnt = cnt + 1
					elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error(string_format("%s roinit property %s failed, property not declared", self.__ClassType.typeName, k))
					end
				end
			end
		end

		setmetatable(self, mtRO)
	end
end

function CustomDict:_rolazyload()
	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadStart(self._root._owner)
	end

	local dict = phonestcore.userdataDecode(self._properties)
	local rawsetter = getRawSetter(self)

	rawsetter(self, "_properties", {})
	rawsetter(self, "_propertiesCnt", 0)

	self._id = PropertyTypes.ID_NOT_INIT

	setmetatable(self, mtRO)
	assert(self._aoiscopeForLazy ~= nil)
	self:roinit(self._name, dict, self._owner, self._parent, not self._unfixed, self._aoiscopeForLazy)

	local cache = self._owner:_getPropertyCache()

	self:_attachToCache(cache)

	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadEnd(self._root._owner, self.__ClassType.typeName, dict, "_rolazyload")
	end
end

function CustomDict:rochange(value)
	if self._id < PropertyTypes.ID_SYNC_START then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s on change with invalid id %d!", self.__ClassType.typeName, self._id)
		end

		return
	end

	local id = value.__id__

	value.__id__ = nil

	assert(id ~= nil)

	if id ~= self._id then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s on change but id [%d-%d] not match!", self.__ClassType.typeName, self._id, id)
		end

		return
	end

	local classType = self.__ClassType
	local propDeclares = classType.__Name2PropertyDeclare__
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	for k, v in pairs(value) do
		local ov = self._properties[k]

		if ov ~= nil then
			if type(ov) == "table" then
				if ov._id == v.__id__ and ov._id >= PropertyTypes.ID_SYNC_START then
					ov:rochange(v)
				else
					ov:_detachFromCache(self._owner:_getPropertyCache())

					local declare = propDeclares[k]

					if declare == nil then
						declare = valueTypeDeclare
					end

					if declare.customClass then
						v = declare:createCustomObjRO(k, v, self._owner, self)

						v:_attachToCache(self._owner:_getPropertyCache())
					end

					self._properties[k] = v
				end
			else
				self._properties[k] = v
			end
		else
			assert(propDeclares[k] == nil)

			if valueTypeDeclare.customClass then
				v = valueTypeDeclare:createCustomObjRO(k, v, self._owner, self)

				v:_attachToCache(self._owner:_getPropertyCache())
			end

			self._properties[k] = v
			self._propertiesCnt = self._propertiesCnt + 1
		end
	end

	local removed = {}

	for k, _ in pairs(self._properties) do
		if value[k] == nil then
			table_insert(removed, k)
		end
	end

	for _, k in ipairs(removed) do
		local ov = self._properties[k]

		if type(ov) == "table" then
			ov:_detachFromCache(self._owner:_getPropertyCache())
		end

		assert(propDeclares[k] == nil)

		self._properties[k] = nil
		self._propertiesCnt = self._propertiesCnt - 1
	end
end

return CustomDict
