-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CustomList.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CustomType = require("Core.PropertySync.CustomType")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local logger = LoggerManager.getLogger("CustomList")
local Switch = require("Core.Common.Switch")
local CustomList = class.LiteClass("CustomList", CustomType)
local ipairs = ipairs
local type = type
local rawget = rawget
local assert = assert
local next = next
local error = error
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local string_format = string.format
local getRawSetter = getRawSetter

CustomList.__CUSTOM_LIST__ = true

local raw_next = raw_next

local function pairsIterator(t, k)
	local v

	k, v = raw_next(t, k)

	if v ~= nil then
		return k, v
	end
end

local function ipairsIterator(t, i)
	i = i + 1

	local v = t[i]

	if v ~= nil then
		return i, v
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

		local classType = tbl.__ClassType
		local oldv = tbl._properties[k]

		if oldv ~= nil then
			if v ~= nil then
				if oldv == v then
					return
				end

				if type(oldv) ~= type(v) then
					error(string_format("%s modify property [%s] value dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, type(oldv), type(v)))
				end

				local valueTypeDeclare = classType.__ValueTypeDeclare__

				if not valueTypeDeclare.customClass then
					tbl._properties[k] = v
				else
					if v.__ClassType ~= nil then
						if v.__ClassType.typeName ~= valueTypeDeclare.typeStr then
							error(string_format("%s modify property [%s] value dismatch, need %s but get %s!", tbl.__ClassType.typeName, k, valueTypeDeclare.typeStr, v.__ClassType.typeName))
						end

						if v._id <= PropertyTypes.ID_NOT_INIT then
							error(string_format("%s modify property [%s] with invalid %s instance!", tbl.__ClassType.typeName, k, v.__ClassType.typeName))
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

					tbl._properties[k] = v

					oldv:_setInvalid()
				end

				tbl:_onSubPropertyChangedInRuntime(valueTypeDeclare, k, v)
			else
				error(string_format("%s delete property [%s] unsupported, use remove method instead!", tbl.__ClassType.typeName, k))
			end
		else
			error(string_format("%s index property [%s] out of range, use insert method instead!", tbl.__ClassType.typeName, k))
		end
	end,
	__pairs = function(tbl)
		return pairsIterator, tbl._properties, nil
	end,
	__ipairs = function(tbl)
		return ipairsIterator, tbl._properties, 0
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
		tbl:_lazyload()

		return ipairsIterator, tbl._properties, 0
	end,
	__len = function(tbl)
		tbl:_lazyload()

		return tbl._propertiesCnt
	end
}

function CustomList:ctor(list)
	CustomList.super.ctor(self)

	if list ~= nil then
		self:init(list)
	end
end

function CustomList:init(list)
	if self._id >= PropertyTypes.ID_INIT then
		error(string_format("%s repeat init!", self.__ClassType.typeName))
	end

	local rawsetter = getRawSetter(self)
	local userdata = list.__bin_data

	if userdata ~= nil then
		self._id = PropertyTypes.ID_LAZY_INIT

		rawsetter(self, "_properties", userdata)
		setmetatable(self, lazy_mt)
	else
		self._id = PropertyTypes.ID_INIT

		local _properties = {}
		local _propertiesCnt = 0
		local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

		if not valueTypeDeclare.customClass then
			for k, v in ipairs(list) do
				if type(v) ~= valueTypeDeclare.typeStr then
					error(string_format("%s init property [%s] with dismatch value, need %s but get %s!", self.__ClassType.typeName, k, valueTypeDeclare.typeStr, type(v)))
				end

				_properties[k] = v
				_propertiesCnt = _propertiesCnt + 1
			end
		else
			for k, v in ipairs(list) do
				v = valueTypeDeclare:createCustomObj(v)

				v:_setName(k)
				v:_setDeclare(valueTypeDeclare)

				_properties[k] = v
				_propertiesCnt = _propertiesCnt + 1
			end
		end

		rawsetter(self, "_properties", _properties)
		rawsetter(self, "_propertiesCnt", _propertiesCnt)
		setmetatable(self, mt)
	end

	return true
end

function CustomList:_lazyload()
	local originID = self._id

	if originID ~= PropertyTypes.ID_LAZY_INIT and originID ~= PropertyTypes.ID_INVLIAD then
		error(string_format("%s do lazy load when _id=%s", self.__ClassType.typeName, originID))

		return
	end

	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadStart(self._root._owner)
	end

	local list = phonestcore.userdataDecode(self._properties)

	getRawSetter(self)(self, "_properties", {})

	self._id = PropertyTypes.ID_NOT_INIT

	setmetatable(self, mt)
	CustomList.init(self, list)

	if originID == PropertyTypes.ID_LAZY_INIT then
		local owner = self._root._owner

		self._id = owner:_genNextPropertyId()

		local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__
		local delegator = rawget(self, "_delegator")

		if valueTypeDeclare.customClass then
			for _, v in ipairs(self._properties) do
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

		LoggerLazyLoad:loadEnd(self._root._owner, self.__ClassType.typeName, list, "_lazyload")
	end
end

function CustomList:insert(pos, value)
	if self._id == PropertyTypes.ID_INVLIAD then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%s is invalid, write closed, only read open", self.__ClassType.typeName)
		end

		return
	end

	if self._id == PropertyTypes.ID_LAZY_INIT then
		self:_lazyload()
	end

	local cnt = self._propertiesCnt
	local p, v

	if value == nil then
		p = cnt + 1
		v = pos
	else
		assert(type(pos) == "number")

		if pos <= 0 or pos > cnt + 1 then
			error(string_format("%s insert property [%s] out of range!", self.__ClassType.typeName, pos))
		end

		p = pos
		v = value
	end

	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if not valueTypeDeclare.customClass then
		if type(v) ~= valueTypeDeclare.typeStr then
			error(string_format("%s insert property [%s] value type dismatch, need %s but get %s!", self.__ClassType.typeName, p, valueTypeDeclare.typeStr, type(v)))
		end
	else
		if v.__ClassType ~= nil then
			if v.__ClassType.typeName ~= valueTypeDeclare.typeStr then
				error(string_format("%s insert property [%s] value type dismatch, need %s but get %s!", self.__ClassType.typeName, p, valueTypeDeclare.typeStr, v.__ClassType.typeName))
			end

			if v._id <= PropertyTypes.ID_NOT_INIT then
				error(string_format("%s insert property [%s] with invalid %s instance!", self.__ClassType.typeName, p, v.__ClassType.typeName))
			end
		else
			v = valueTypeDeclare:createCustomObj(v)
		end

		v:_setName(p)
		v:_setDeclare(valueTypeDeclare)

		if self._root then
			v:_setParent(self)
			v:_setOwner(self._root._owner)
		end

		local delegator = rawget(self, "_delegator")

		if delegator ~= nil then
			v:setDelegator(delegator)
		end
	end

	table_insert(self._properties, p, v)

	self._propertiesCnt = cnt + 1

	if valueTypeDeclare.customClass then
		for i = p + 1, cnt + 1 do
			self._properties[i]._name = i
		end
	end

	self:_onSubPropertyCreatedInRuntime(valueTypeDeclare, p, v)
end

function CustomList:remove(pos)
	if self._id == PropertyTypes.ID_INVLIAD then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%s is invalid, write closed, only read open", self.__ClassType.typeName)
		end

		return
	end

	if self._id == PropertyTypes.ID_LAZY_INIT then
		self:_lazyload()
	end

	local cnt = self._propertiesCnt

	if pos == nil then
		pos = cnt

		if pos <= 0 then
			return
		end
	else
		assert(type(pos) == "number")

		if pos <= 0 or cnt < pos then
			error(string_format("%s remove property [%s] out of range!", self.__ClassType.typeName, pos))
		end
	end

	local v = table_remove(self._properties, pos)

	self._propertiesCnt = cnt - 1

	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		v:_setInvalid()

		for i = pos, cnt - 1 do
			self._properties[i]._name = i
		end
	end

	self:_onSubPropertyDeletedInRuntime(valueTypeDeclare, pos, v)

	return v
end

function CustomList:sort(sortFunc)
	if self._id == PropertyTypes.ID_INVLIAD then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%s is invalid, write closed, only read open", self.__ClassType.typeName)
		end

		return
	end

	if self._id == PropertyTypes.ID_LAZY_INIT then
		self:_lazyload()
	end

	if sortFunc == nil then
		function sortFunc(a, b)
			return a < b
		end
	end

	table_sort(self._properties, sortFunc)

	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for p, v in ipairs(self._properties) do
			v._name = p
		end
	end

	if self._parent then
		local propDeclares = self._parent.__ClassType.__Name2PropertyDeclare__
		local declare = propDeclares[self._name]

		if declare == nil then
			declare = self._parent.__ClassType.__ValueTypeDeclare__
		end

		self._parent:_onSubPropertyChangedInRuntime(declare, self._name, self)
	elseif self._root then
		assert(self._root == self)

		local owner = self._root._owner
		local propDeclares = owner:getClass().__Name2PropertyDeclare__
		local declare = propDeclares[self._name]

		if declare == nil then
			declare = owner:getClass().__ValueTypeDeclare__
		end

		owner:_onRootPropertyChangedInRuntime(declare, self._name, self)
	end
end

function CustomList:getPersistentValue()
	return CustomList.super.getPersistentValue(self)
end

function CustomList:_getPersistentValue()
	local plist = {}
	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			local d = v:getPersistentValue()

			table_insert(plist, d)
		end
	else
		for _, v in ipairs(self._properties) do
			table_insert(plist, v)
		end
	end

	return plist
end

function CustomList:getOwnClientValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local clist = {}
	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			local d = v:getOwnClientValue()

			assert(d ~= nil)
			table_insert(clist, d)
		end
	else
		for _, v in ipairs(self._properties) do
			table_insert(clist, v)
		end
	end

	clist.__id__ = self._id

	if self:_isRoot() then
		clist.__tp__ = self.__ClassType.typeName
	end

	return clist
end

function CustomList:getAllClientsValue()
	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local clist = {}
	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			local d = v:getAllClientsValue()

			assert(d ~= nil)
			table_insert(clist, d)
		end
	else
		for _, v in ipairs(self._properties) do
			table_insert(clist, v)
		end
	end

	clist.__id__ = self._id

	if self:_isRoot() then
		clist.__tp__ = self.__ClassType.typeName
	end

	return clist
end

function CustomList:getOwnAndAllClientsValue(aoiscope)
	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil, nil
	end

	local ownDict = {}
	local allDict = {}
	local classType = self.__ClassType
	local valueTypeDeclare = classType.__ValueTypeDeclare__
	local allType = PropertyTypes.AOI_ALL_CLIENTS

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			local o, a = v:getOwnAndAllClientsValue(aoiscope)

			assert(o ~= nil and v ~= nil)
			table_insert(ownDict, o)

			if aoiscope == allType then
				table_insert(allDict, a)
			end
		end
	else
		for _, v in ipairs(self._properties) do
			table_insert(ownDict, v)

			if aoiscope == allType then
				table_insert(allDict, v)
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

function CustomList:getOwnClientPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_SERVER_ONLY then
		return nil
	end

	local cids = {
		__id__ = self._id
	}
	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			cids[k] = v:getOwnClientPropertyIds()
		end
	end

	return cids
end

function CustomList:getAllClientsPropertyIds()
	if self._id < PropertyTypes.ID_SYNC_START then
		return nil
	end

	if self:_getAoiscope() <= PropertyTypes.AOI_OWN_CLIENT then
		return nil
	end

	local cids = {
		__id__ = self._id
	}
	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			cids[k] = v:getAllClientsPropertyIds()
		end
	end

	return cids
end

function CustomList:getJournalPropertyIds()
	if self:_getPersist() ~= PropertyTypes.PS_PER then
		return nil
	end

	local jdict = {}

	if self._id < PropertyTypes.ID_SYNC_START then
		jdict._ = {
			-1,
			PropertyTypes.PS_PATTERN_DEFAULT,
			PropertyTypes.CUSTOM_TYPE_LIST
		}

		return jdict
	end

	local classType = self.__ClassType
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	if valueTypeDeclare:isCustomType() then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			jdict[k] = v:getJournalPropertyIds()
		end
	end

	jdict._ = {
		self._id,
		PropertyTypes.PS_PATTERN_DEFAULT,
		PropertyTypes.CUSTOM_TYPE_LIST
	}

	return jdict
end

function CustomList:getJournalValue()
	assert(self._id >= PropertyTypes.ID_SYNC_START)

	if self:_getPersist() ~= PropertyTypes.PS_PER then
		return nil
	end

	local jdict = {}
	local classType = self.__ClassType
	local valueTypeDeclare = classType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		for k, v in ipairs(self._properties) do
			assert(k == v._name)

			jdict[k] = v:getJournalValue()
		end
	else
		for k, v in ipairs(self._properties) do
			jdict[k] = v
		end
	end

	jdict._ = {
		self._id,
		PropertyTypes.PS_PATTERN_DEFAULT,
		PropertyTypes.CUSTOM_TYPE_LIST
	}

	return jdict
end

function CustomList:isCustomList()
	return true
end

function CustomList:customTypeName()
	return "customList"
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
		tbl:_rolazyload()

		return ipairsIterator, tbl._properties, 0
	end,
	__len = function(tbl)
		tbl:_rolazyload()

		return tbl._propertiesCnt or 0
	end
}

local function insert()
	error("list readonly, can not insert!")
end

local function remove()
	error("list readonly, can not remove!")
end

local function sort()
	error("list readonly, can not sort!")
end

function CustomList:roinit(name, value, owner, parent, fixed, aoiscopeForLazy)
	if self._id >= PropertyTypes.ID_INIT then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s repeat roinit!", self.__ClassType.typeName)
		end

		return
	end

	local rawsetter = getRawSetter(self)

	rawsetter(self, "insert", insert)
	rawsetter(self, "remove", remove)
	rawsetter(self, "sort", sort)
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

		local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

		if valueTypeDeclare.customClass then
			for k, v in ipairs(value) do
				v = valueTypeDeclare:createCustomObjRO(k, v, owner, self, aoiscopeForLazy)
				self._properties[k] = v
				self._propertiesCnt = self._propertiesCnt + 1
			end
		else
			for k, v in ipairs(value) do
				self._properties[k] = v
				self._propertiesCnt = self._propertiesCnt + 1
			end
		end

		setmetatable(self, mtRO)
	end
end

function CustomList:_rolazyload()
	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadStart(self._root._owner)
	end

	local list = phonestcore.userdataDecode(self._properties)
	local rawsetter = getRawSetter(self)

	rawsetter(self, "_properties", {})
	rawsetter(self, "_propertiesCnt", 0)

	self._id = PropertyTypes.ID_NOT_INIT

	setmetatable(self, mtRO)
	assert(self._aoiscopeForLazy ~= nil)
	self:roinit(self._name, list, self._owner, self._parent, not self._unfixed, self._aoiscopeForLazy)

	local cache = self._owner:_getPropertyCache()

	self:_attachToCache(cache)

	if Switch.LazyLoadDebug then
		local LoggerLazyLoad = require("Core.Log.LoggerLazyLoad")

		LoggerLazyLoad:loadEnd(self._root._owner, self.__ClassType.typeName, list, "_rolazyload")
	end
end

function CustomList:rochange(value)
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

	local valueTypeDeclare = self.__ClassType.__ValueTypeDeclare__

	if valueTypeDeclare.customClass then
		local idx = {}
		local properties = self._properties

		self._properties = {}
		self._propertiesCnt = 0

		for k, v in ipairs(value) do
			local subid = v.__id__

			idx[subid] = true

			local ov = self._owner:_getCachedProperty(subid)

			if ov ~= nil then
				ov:rochange(v)

				ov._name = k
				self._properties[k] = ov
			else
				v = valueTypeDeclare:createCustomObjRO(k, v, self._owner, self)

				v:_attachToCache(self._owner:_getPropertyCache())

				self._properties[k] = v
			end

			self._propertiesCnt = self._propertiesCnt + 1
		end

		for _, v in ipairs(properties) do
			if idx[v._id] == nil then
				v:_detachFromCache(self._owner:_getPropertyCache())
			end
		end
	else
		self._properties = {}
		self._propertiesCnt = 0

		for k, v in ipairs(value) do
			self._properties[k] = v
			self._propertiesCnt = self._propertiesCnt + 1
		end
	end
end

return CustomList
