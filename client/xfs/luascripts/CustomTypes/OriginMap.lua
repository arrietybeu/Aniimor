-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\OriginMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local LoggerConst = require("Core.Log.LoggerConst")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local LoggerManager = require("Core.Log.LoggerManager")
local class = require("Core.Framework.Class")
local OriginMapValue = require("CustomTypes.OriginMapValue")
local json = require("json")
local logger = LoggerManager.getLogger("OriginMap")
local FIXED_KEY = "ORIGIN_MAP_KEY"
local OriginMap = class.LiteClass("OriginMap", CustomDict)
local string_format = string.format
local type = type
local getRawSetter = getRawSetter

local function pairsIterator(t, k)
	local v

	k, v = next(t, k)

	if v ~= nil then
		if k == "_" then
			return pairsIterator(t, k)
		end

		return k, v
	end
end

local mt = {
	__index = function(tbl, k)
		local v = tbl._realProperties[k]

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

		if _G_IsDebugMode and type(k) ~= "string" then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, key is not string", tbl.__ClassType.typeName, debug.traceback())
			end

			return
		end

		local classType = tbl.__ClassType
		local _properties = tbl._properties
		local _realProperties = tbl._realProperties
		local oldv = _realProperties[k]

		if oldv ~= nil then
			if v ~= nil then
				if oldv == v then
					return
				end

				if type(v) == "table" then
					local newv = OriginMapValue(tbl)

					if not newv:init(v) then
						return
					end

					_realProperties[k] = newv
				else
					_realProperties[k] = v
				end

				_properties[FIXED_KEY] = json.encode(_realProperties)

				tbl:_onSubPropertyChangedInRuntime(classType.__ValueTypeDeclare__, FIXED_KEY, _properties[FIXED_KEY])
			else
				_realProperties[k] = nil
				_properties[FIXED_KEY] = json.encode(_realProperties)
				tbl._propertiesCnt = tbl._propertiesCnt - 1

				tbl:_onSubPropertyChangedInRuntime(classType.__ValueTypeDeclare__, FIXED_KEY, _properties[FIXED_KEY])
			end

			if type(oldv) == "table" and oldv.resetOwner then
				oldv:resetOwner()
			end
		elseif v ~= nil then
			if type(v) == "table" then
				local newv = OriginMapValue(tbl)

				if not newv:init(v) then
					return
				end

				_realProperties[k] = newv
			else
				_realProperties[k] = v
			end

			tbl._propertiesCnt = tbl._propertiesCnt + 1
			_properties[FIXED_KEY] = json.encode(_realProperties)

			tbl:_onSubPropertyChangedInRuntime(classType.__ValueTypeDeclare__, FIXED_KEY, _properties[FIXED_KEY])
		end
	end,
	__pairs = function(tbl)
		return pairsIterator, tbl._realProperties, nil
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

		v = tbl._realProperties[k]

		return v
	end,
	__newindex = function(tbl, k, v)
		if tbl._id == PropertyTypes.ID_INVLIAD then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, write closed, only read open", tbl.__ClassType.typeName)
			end

			return
		end

		if _G_IsDebugMode and type(k) ~= "string" then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("%s is invalid, key is not string", tbl.__ClassType.typeName, debug.traceback())
			end

			return
		end

		tbl:_lazyload()

		tbl[k] = v
	end,
	__pairs = function(tbl)
		tbl:_lazyload()

		return pairsIterator, tbl._realProperties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		tbl:_lazyload()

		return tbl._propertiesCnt
	end
}

function OriginMap:_originTableChanged()
	self._properties[FIXED_KEY] = json.encode(self._realProperties)

	self:_onSubPropertyChangedInRuntime(self.__ClassType.__ValueTypeDeclare__, FIXED_KEY, self._properties[FIXED_KEY])
end

function OriginMap:_lazyload()
	local originID = self._id

	if originID ~= PropertyTypes.ID_LAZY_INIT and originID ~= PropertyTypes.ID_INVLIAD then
		error(string_format("%s do lazy load when _id=%s", self.__ClassType.typeName, originID))

		return
	end

	local dict = phonestcore.userdataDecode(self._properties)

	setmetatable(self, mt)
	OriginMap.init(self, dict)

	if originID == PropertyTypes.ID_LAZY_INIT then
		local owner = self._root._owner

		self._id = owner:_genNextPropertyId()

		self:_onLazyLoadInRuntime()
	else
		self:_setInvalid()
	end
end

function OriginMap:init(dict)
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
		local _realProperties = {}
		local _propertiesCnt = 0

		if dict._ ~= nil then
			dict._ = nil
		end

		local data = dict[FIXED_KEY]

		if data ~= nil then
			_properties[FIXED_KEY] = data

			for k, v in pairs(json.decode(data)) do
				if type(v) == "table" then
					local newv = OriginMapValue(self)

					if newv:init(v) then
						_realProperties[k] = newv
						_propertiesCnt = _propertiesCnt + 1
					end
				else
					_realProperties[k] = v
					_propertiesCnt = _propertiesCnt + 1
				end
			end
		elseif next(dict) then
			_properties[FIXED_KEY] = json.encode(dict)

			for k, v in pairs(dict) do
				if type(v) == "table" then
					local newv = OriginMapValue(self)

					if newv:init(v) then
						_realProperties[k] = newv
						_propertiesCnt = _propertiesCnt + 1
					end
				else
					_realProperties[k] = v
					_propertiesCnt = _propertiesCnt + 1
				end
			end
		end

		_properties._ = ""

		rawsetter(self, "_properties", _properties)
		rawsetter(self, "_realProperties", _realProperties)
		rawsetter(self, "_propertiesCnt", _propertiesCnt)
		setmetatable(self, mt)
	end

	return true
end

function OriginMap:getPersistentValue()
	return OriginMap.super.getPersistentValue(self)
end

function OriginMap:_getPersistentValue()
	local pdict = {
		[FIXED_KEY] = self._properties[FIXED_KEY] or "{}"
	}

	return pdict
end

function OriginMap:getOwnClientValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local cdict = {
		[FIXED_KEY] = self._properties[FIXED_KEY]
	}

	cdict.__id__ = self._id

	if self:_isRoot() then
		local classType = self.__ClassType

		cdict.__tp__ = classType.typeName
	end

	return cdict
end

function OriginMap:getAllClientsValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local cdict = {}
	local classType = self.__ClassType

	for k, v in pairs(self._realProperties) do
		cdict[k] = v
	end

	cdict.__id__ = self._id

	if self:_isRoot() then
		cdict.__tp__ = classType.typeName
	end

	return cdict
end

function OriginMap:getOwnAndAllClientsValue(aoiscope)
	local aoiscope = self:_getAoiscope()

	if aoiscope <= PropertyTypes.AOI_SERVER_ONLY then
		return nil, nil
	end

	local ownDict = {}
	local allDict = {}
	local classType = self.__ClassType
	local ownType = PropertyTypes.AOI_OWN_CLIENT
	local allType = PropertyTypes.AOI_ALL_CLIENTS

	for k, v in pairs(self._realProperties) do
		if k ~= "_" then
			if ownType <= aoiscope then
				ownDict[k] = v
			end

			if allType <= aoiscope then
				allDict[k] = v
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

function OriginMap:getOwnClientPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local cids = {
		__id__ = self._id
	}

	return cids
end

function OriginMap:getAllClientsPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local cids = {
		__id__ = self._id
	}

	return cids
end

function OriginMap:isCustomDict()
	return true
end

function OriginMap:customTypeName()
	return "OriginMap"
end

local mtRO = {
	__index = mt.__index,
	__newindex = function(tbl, k, v)
		error(string.format("%s modify property %s readonly!", tbl.__ClassType.typeName, k))
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

		v = tbl._realProperties[k]

		return v
	end,
	__newindex = function(tbl, k, v)
		error(string.format("%s modify property %s readonly!", tbl.__ClassType.typeName, k))
	end,
	__pairs = function(tbl)
		tbl:_rolazyload()

		return pairsIterator, tbl._realProperties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		tbl:_rolazyload()

		return tbl._propertiesCnt or 0
	end
}

function OriginMap:roinit(name, value, owner, parent, fixed, aoiscopeForLazy)
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

		rawsetter(self, "_lazyBin", userdata)
		rawsetter(self, "_properties", {})
		rawsetter(self, "_realProperties", {})
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
		rawsetter(self, "_realProperties", {})
		rawsetter(self, "_propertiesCnt", 0)

		value._ = nil

		if value[FIXED_KEY] ~= nil then
			self._properties[FIXED_KEY] = value[FIXED_KEY]
			self._realProperties = json.decode(value[FIXED_KEY])

			for k, v in pairs(self._realProperties) do
				self._propertiesCnt = self._propertiesCnt + 1
			end
		end

		setmetatable(self, mtRO)
	end
end

function OriginMap:_rolazyload()
	local pendingJson = self._properties[FIXED_KEY]
	local dict = phonestcore.userdataDecode(self._lazyBin)
	local rawsetter = getRawSetter(self)

	rawsetter(self, "_lazyBin", nil)
	rawsetter(self, "_properties", {})
	rawsetter(self, "_realProperties", {})
	rawsetter(self, "_propertiesCnt", 0)
	setmetatable(self, mtRO)
	assert(self._aoiscopeForLazy ~= nil)
	self:roinit(self._name, dict, self._owner, self._parent, not self._unfixed, self._aoiscopeForLazy)

	if pendingJson ~= nil then
		self._properties[FIXED_KEY] = pendingJson

		self:_originPropertyChanged()
	end
end

function OriginMap:rochange(value)
	error(string_format("rochange operation not supported for %s!", self.__ClassType.typeName))
end

function OriginMap:_originPropertyChanged()
	self._realProperties = json.decode(self._properties[FIXED_KEY])
	self._propertiesCnt = 0

	for k, v in pairs(self._realProperties) do
		self._propertiesCnt = self._propertiesCnt + 1
	end
end

return OriginMap
