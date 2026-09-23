-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\ClientRealPropertyComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local SafeCallback = require("Core.Framework.SafeCallback")
local SafeCallbackWithReturn = require("Core.Framework.SafeCallbackWithReturn")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CustomTypeFactory = require("Core.PropertySync.CustomTypeFactory")
local RpcDataCodec = require("Core.PropertySync.RpcDataCodec")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local CommonSwitch = require("Common.CommonSwitch")
local Config = require("Config.Config")
local logger = LoggerManager.getLogger("ClientRealPropertyComponent")
local ClientRealPropertyComponent = class.Component("ClientRealPropertyComponent")
local pairs = pairs
local type = type
local rawset = raw_rawset
local raw_rawset = raw_rawset
local rawget = rawget
local assert = assert
local raw_next = raw_next
local next = raw_next
local unpack = unpack
local table_insert = table.insert
local table_remove = table.remove
local tonumber = tonumber
local mt = {
	__index = function(tbl, k)
		local v = tbl.__Properties__[k]

		if v ~= nil then
			return v
		else
			local vtbl = tbl:getClass().getVtbl()

			return vtbl[k]
		end
	end,
	__newindex = function(tbl, k, v)
		if tbl.__Properties__[k] ~= nil then
			error(string.format("%s modify property %s readonly!", tbl:getClassType(), k))
		else
			rawset(tbl, k, v)
		end
	end
}

function ClientRealPropertyComponent:init(dict)
	local realDict, aoiscopeForLazy

	if dict.__bin_data == nil then
		local properties = dict.__Properties__

		if properties == nil then
			return true
		end

		realDict = properties
	else
		local binData = dict.__bin_data

		dict.__bin_data = nil

		local decodeType = dict.__decode_type

		dict.__decode_type = nil

		local ClientRepo = require("Core.Client.ClientRepo")
		local ctable, ptable, idx
		local decodeClassName = self.className

		if CommonSwitch.CompactClientInitDataVerify then
			local VerifyCodec = require("Core.PropertySync.RpcDataVerifyCodec")

			ctable, ptable, idx = VerifyCodec.tryDecodeLazyVerify(RpcDataCodec, binData, ClientRepo.protoCodec, function(data, decodeContext)
				return phonestcore.lazyDecode(data, decodeType, decodeContext.className or decodeClassName)
			end, function(refIdx)
				phonestcore.lazyUnref(refIdx)
			end, {
				className = decodeClassName,
				entityType = self:getClassType(),
				entityId = self.id
			})
		end

		if ctable == nil then
			ctable, ptable, idx = phonestcore.lazyDecode(binData, decodeType, decodeClassName)
		end

		assert(ptable ~= nil)
		assert(ctable ~= nil)

		self.__Properties__ = ptable
		self.__PropertiesIdx__ = idx
		aoiscopeForLazy = ctable.__aoiscope__

		local customDict = ClientRepo.protoCodec:decode(ctable.__custom__ or "")

		ctable.__aoiscope__ = nil
		ctable.__custom__ = nil

		assert(aoiscopeForLazy ~= nil)

		if customDict and raw_next(customDict) ~= nil then
			for k, v in raw_next, customDict do
				dict[k] = v
			end
		end

		if ctable and raw_next(ctable) ~= nil then
			for k, v in raw_next, ctable do
				dict[k] = v
			end
		end

		realDict = ptable
	end

	self.__Properties__ = {}
	self.__PropertiesCnt__ = 0

	if type(phonestcore.newPropertyRefCache) == "function" then
		self.__CustomPropertiesCache__ = phonestcore.newPropertyRefCache()
	else
		self.__CustomPropertiesCache__ = {}
	end

	self.__NextPropertyId__ = 1

	local properties = self.__Properties__

	setmetatable(properties, self:getClass().__objMetatable)
	setmetatable(self, {
		__index = properties,
		__newindex = function(tbl, k, v)
			if properties[k] ~= nil then
				properties[k] = v
			else
				raw_rawset(tbl, k, v)
			end
		end
	})

	for name, value in raw_next, realDict do
		if rawget(self, name) ~= nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("property %s is coverd", name)
		end

		if type(value) == "table" then
			local customType = value.__tp__

			assert(customType ~= nil)

			value.__tp__ = nil

			local customObj = CustomTypeFactory.createReadonly(customType, name, value, self, nil, true, aoiscopeForLazy)

			if customObj then
				customObj:_attachToCache(self.__CustomPropertiesCache__)

				properties[name] = customObj
			end
		else
			properties[name] = value
		end
	end

	return true
end

function ClientRealPropertyComponent:destroy()
	if self.__PropertiesIdx__ ~= nil then
		phonestcore.lazyUnref(self.__PropertiesIdx__)

		self.__PropertiesIdx__ = nil
	end

	local cache = rawget(self, "__CustomPropertiesCache__")

	if cache ~= nil and type(cache.clear) == "function" then
		cache:clear()
	end

	rawset(self, "__CustomPropertiesCache__", nil)
	rawset(self, "__Properties__", nil)
end

function ClientRealPropertyComponent:getAllProperties()
	if self.__Properties__ == nil then
		return nil
	end

	local propertiesDict = {}

	for name, value in pairs(self.__Properties__) do
		if type(value) == "table" then
			propertiesDict[name] = value:getRawTable()
		else
			propertiesDict[name] = value
		end
	end

	return propertiesDict
end

function ClientRealPropertyComponent:_getCachedProperty(propertyId)
	local cache = self.__CustomPropertiesCache__

	if cache == nil then
		return nil
	end

	return cache[propertyId]
end

function ClientRealPropertyComponent:_getPropertyCache()
	return self.__CustomPropertiesCache__
end

function ClientRealPropertyComponent:_getPropertyCallback(op, callbackName)
	local callbacks = self:getClass().__PropertyCallbacks__[op]

	if callbacks ~= nil then
		local callbackInfo = callbacks[callbackName]

		if callbackInfo ~= nil then
			local propertyType, funcName = unpack(callbackInfo)
			local func = self[funcName]

			if func == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("%s has no property callback %s", self:getClassType(), funcName)
				end

				return nil, nil, nil
			else
				return func, funcName, propertyType
			end
		else
			return nil, nil, nil
		end
	else
		return nil, nil, nil
	end
end

function ClientRealPropertyComponent:_checkCallbackSwallowed(cbname, result)
	if result == PropertyTypes.CALLBACK_SWALLOW then
		return true
	end

	if result ~= nil and result ~= PropertyTypes.CALLBACK_RAISE and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("%s property callback %s should return CALLBACK_SWALLOW or CALLBACK_RAISE", self:getClassType(), cbname)
	end

	return false
end

function ClientRealPropertyComponent:_queryPropertyChangedCallback(customObj, k, oldVal, newVal, typeVal)
	if customObj == nil then
		local cb, cbname, propertyType = self:_getPropertyCallback(PropertyTypes.OP_CHANGE, k)

		if cb ~= nil then
			if typeVal == propertyType then
				SafeCallback(cb, self, oldVal, newVal)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("%s property callback %s type error, need %s got %s", self:getClassType(), cbname, propertyType, typeVal)
			end
		end

		return
	end

	local swallowed = false
	local path, unfixedNames = customObj:_traceSubNode(k)
	local cb, cbname, propertyType = self:_getPropertyCallback(PropertyTypes.OP_CHANGE, path)

	if cb ~= nil then
		if typeVal == propertyType then
			local ret

			if unfixedNames then
				ret = cb(self, oldVal, newVal, unpack(unfixedNames))
			else
				ret = cb(self, oldVal, newVal)
			end

			swallowed = self:_checkCallbackSwallowed(cbname, ret)
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s property callback %s type error, need %s got %s", self:getClassType(), cbname, propertyType, typeVal)
		end
	end

	if not swallowed then
		local parentObj = customObj._parent
		local oldv = customObj:quickCopy(k, oldVal)

		self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
	end
end

function ClientRealPropertyComponent:_dispatchCppCompatContainerCallback(opType, name, oldVal, newVal, callbackChain)
	if opType ~= PropertyTypes.OP_ADD and opType ~= PropertyTypes.OP_DEL and opType ~= PropertyTypes.OP_INSERT and opType ~= PropertyTypes.OP_REMOVE then
		return false, false
	end

	local direct = callbackChain and callbackChain[1]

	if direct == nil then
		return false, false
	end

	local parentEntry = callbackChain[2]
	local callbackPath = direct.parentPath or parentEntry and parentEntry.path

	if callbackPath == nil and direct.path ~= nil then
		callbackPath = string.gsub(direct.path, "%.%*$", "")
	end

	if callbackPath == nil or callbackPath == "" then
		return false, false
	end

	local cb, cbname, _ = self:_getPropertyCallback(opType, callbackPath)

	if cb == nil then
		return false, false
	end

	local keyOrIndex, extraArgs
	local extraCount = 0
	local unfixedNames = direct.unfixedNames

	if unfixedNames ~= nil then
		local cnt = #unfixedNames

		if cnt > 0 then
			keyOrIndex = unfixedNames[cnt]

			if cnt > 1 then
				extraArgs = {}

				for i = 1, cnt - 1 do
					extraArgs[i] = unfixedNames[i]
				end

				extraCount = cnt - 1
			end
		end
	end

	if keyOrIndex == nil then
		if opType == PropertyTypes.OP_INSERT or opType == PropertyTypes.OP_REMOVE then
			keyOrIndex = tonumber(name) or name
		else
			keyOrIndex = name
		end
	end

	local entryVal

	if opType == PropertyTypes.OP_ADD or opType == PropertyTypes.OP_INSERT then
		entryVal = newVal
	else
		entryVal = oldVal
	end

	local ret

	if extraArgs ~= nil then
		ret = SafeCallbackWithReturn(cb, self, keyOrIndex, entryVal, unpack(extraArgs, 1, extraCount))
	else
		ret = SafeCallbackWithReturn(cb, self, keyOrIndex, entryVal)
	end

	return true, self:_checkCallbackSwallowed(cbname, ret)
end

function ClientRealPropertyComponent:_changeRootProperty(k, v, triggerCb)
	local typeVal = type(v)
	local oldVal, newVal

	if typeVal == "table" then
		local customType = v.__tp__

		assert(customType ~= nil)

		v.__tp__ = nil
		oldVal = self.__Properties__[k]
		typeVal = oldVal and oldVal:customTypeName() or customType

		if oldVal ~= nil and oldVal._id == v.__id__ and oldVal._id >= PropertyTypes.ID_SYNC_START then
			newVal = oldVal
			oldVal = oldVal:deepCopy()

			newVal:rochange(v)
		else
			if oldVal ~= nil then
				oldVal:_detachFromCache(self.__CustomPropertiesCache__)
			end

			newVal = CustomTypeFactory.createReadonly(customType, k, v, self, nil, true)

			newVal:_attachToCache(self.__CustomPropertiesCache__)
		end
	else
		oldVal = self.__Properties__[k]
		newVal = v
	end

	self.__Properties__[k] = newVal

	if triggerCb then
		self:_queryPropertyChangedCallback(nil, k, oldVal, newVal, typeVal)
	end
end

function ClientRealPropertyComponent:_changeSubProperty(propertyId, k, v, triggerCb)
	local typeVal = type(v)
	local customObj = self.__CustomPropertiesCache__[propertyId]

	assert(customObj ~= nil)
	assert(v ~= nil)

	if customObj ~= nil then
		local declare
		local cls = customObj.__ClassType

		if customObj:isCustomList() then
			k = tonumber(k)
			declare = cls.__ValueTypeDeclare__
		else
			local propDeclares = cls.__Name2PropertyDeclare__

			declare = propDeclares[k]

			if declare == nil then
				if cls.__ValueTypeDeclare__ and cls.__ValueTypeDeclare__.intTypeKey then
					k = tonumber(k)
				end

				declare = cls.__ValueTypeDeclare__
			end
		end

		local oldVal, newVal

		if typeVal == "table" then
			oldVal = customObj._properties[k]

			if oldVal == nil then
				typeVal = declare.customClass and declare.customClass.typeName
				newVal = declare:createCustomObjRO(k, v, self, customObj)

				newVal:_attachToCache(self.__CustomPropertiesCache__)
			else
				typeVal = oldVal:customTypeName()

				if oldVal._id == v.__id__ and oldVal._id >= PropertyTypes.ID_SYNC_START then
					newVal = oldVal
					oldVal = oldVal:deepCopy()

					newVal:rochange(v)
				else
					oldVal:_detachFromCache(self.__CustomPropertiesCache__)

					newVal = declare:createCustomObjRO(k, v, self, customObj)

					newVal:_attachToCache(self.__CustomPropertiesCache__)
				end
			end
		else
			oldVal = customObj._properties[k]
			newVal = v
		end

		customObj._properties[k] = newVal

		if customObj._originPropertyChanged then
			customObj:_originPropertyChanged()
		end

		if triggerCb then
			self:_queryPropertyChangedCallback(customObj, k, oldVal, newVal, typeVal)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to change sub property %s, but not exist in property cache", propertyId, k)
	end
end

function ClientRealPropertyComponent:__OpChange__(propertyId, k, v, triggerCb)
	if propertyId <= 0 then
		self:_changeRootProperty(k, v, triggerCb)
	else
		self:_changeSubProperty(propertyId, k, v, triggerCb)
	end
end

function ClientRealPropertyComponent:__OpAdd__(propertyId, k, v, triggerCb)
	local customObj = self.__CustomPropertiesCache__[propertyId]

	assert(customObj ~= nil)

	if customObj ~= nil then
		local valueTypeDeclare = customObj.__ClassType.__ValueTypeDeclare__

		assert(valueTypeDeclare ~= nil)

		if valueTypeDeclare and valueTypeDeclare.intTypeKey then
			k = tonumber(k)
		end

		local obj

		if type(v) == "table" then
			obj = valueTypeDeclare:createCustomObjRO(k, v, self, customObj)

			obj:_attachToCache(self.__CustomPropertiesCache__)
		else
			obj = v
		end

		customObj._properties[k] = obj
		customObj._propertiesCnt = customObj._propertiesCnt + 1

		if triggerCb then
			local swallowed = false
			local path = customObj:_pathFromRoot2Myself()
			local unfixedNames = customObj:_gatherUnfixedNames()
			local cb, cbname, _ = self:_getPropertyCallback(PropertyTypes.OP_ADD, path)

			if cb ~= nil then
				local ret

				if unfixedNames then
					ret = cb(self, k, obj, unpack(unfixedNames))
				else
					ret = cb(self, k, obj)
				end

				swallowed = self:_checkCallbackSwallowed(cbname, ret)
			end

			if not swallowed then
				local parentObj = customObj._parent
				local oldv = customObj:quickCopy(k, nil, customObj._propertiesCnt - 1)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to add sub property %s, but not exist in property cache", propertyId, k)
	end
end

function ClientRealPropertyComponent:__OpDel__(propertyId, k, triggerCb)
	local customObj = self.__CustomPropertiesCache__[propertyId]

	assert(customObj ~= nil)

	if customObj ~= nil then
		local valueTypeDeclare = customObj.__ClassType.__ValueTypeDeclare__

		assert(valueTypeDeclare ~= nil)

		if valueTypeDeclare and valueTypeDeclare.intTypeKey then
			k = tonumber(k)
		end

		local obj = customObj._properties[k]

		assert(obj ~= nil)

		if type(obj) == "table" then
			obj:_detachFromCache(self.__CustomPropertiesCache__)
		end

		customObj._properties[k] = nil
		customObj._propertiesCnt = customObj._propertiesCnt - 1

		if triggerCb then
			local swallowed = false
			local path = customObj:_pathFromRoot2Myself()
			local unfixedNames = customObj:_gatherUnfixedNames()
			local cb, cbname, _ = self:_getPropertyCallback(PropertyTypes.OP_DEL, path)

			if cb ~= nil then
				local ret

				if unfixedNames then
					ret = cb(self, k, obj, unpack(unfixedNames))
				else
					ret = cb(self, k, obj)
				end

				swallowed = self:_checkCallbackSwallowed(cbname, ret)
			end

			if not swallowed then
				local parentObj = customObj._parent
				local oldv = customObj:quickCopy(k, obj, customObj._propertiesCnt + 1)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to delete sub property %s, but not exist in property cache", propertyId, k)
	end
end

function ClientRealPropertyComponent:__OpInsert__(propertyId, k, v, triggerCb)
	local customObj = self.__CustomPropertiesCache__[propertyId]

	assert(customObj ~= nil)

	if customObj ~= nil then
		k = tonumber(k)

		local obj
		local valueTypeDeclare = customObj.__ClassType.__ValueTypeDeclare__

		assert(valueTypeDeclare ~= nil)

		if valueTypeDeclare:isCustomType() then
			obj = valueTypeDeclare:createCustomObjRO(k, v, self, customObj)

			obj:_attachToCache(self.__CustomPropertiesCache__)
			table_insert(customObj._properties, k, obj)

			customObj._propertiesCnt = customObj._propertiesCnt + 1

			for i = k + 1, customObj._propertiesCnt do
				customObj._properties[i]._name = i
			end
		else
			obj = v

			table_insert(customObj._properties, k, obj)

			customObj._propertiesCnt = customObj._propertiesCnt + 1
		end

		if triggerCb then
			local swallowed = false
			local path = customObj:_pathFromRoot2Myself()
			local unfixedNames = customObj:_gatherUnfixedNames()
			local cb, cbname, _ = self:_getPropertyCallback(PropertyTypes.OP_INSERT, path)

			if cb ~= nil then
				local ret

				if unfixedNames then
					ret = cb(self, k, obj, unpack(unfixedNames))
				else
					ret = cb(self, k, obj)
				end

				swallowed = self:_checkCallbackSwallowed(cbname, ret)
			end

			if not swallowed then
				local parentObj = customObj._parent
				local oldv = customObj:quickCopy(k, nil, customObj._propertiesCnt - 1, PropertyTypes.OP_REMOVE)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to insert sub property [%s], but not exist in property cache", propertyId, k)
	end
end

function ClientRealPropertyComponent:__OpRemove__(propertyId, k, triggerCb)
	local customObj = self.__CustomPropertiesCache__[propertyId]

	assert(customObj ~= nil)

	if customObj ~= nil then
		k = tonumber(k)

		local valueTypeDeclare = customObj.__ClassType.__ValueTypeDeclare__

		assert(valueTypeDeclare ~= nil)

		local obj = table_remove(customObj._properties, k)

		assert(obj ~= nil)

		customObj._propertiesCnt = customObj._propertiesCnt - 1

		if valueTypeDeclare:isCustomType() then
			obj:_detachFromCache(self.__CustomPropertiesCache__)

			for i = k, customObj._propertiesCnt do
				customObj._properties[i]._name = i
			end
		end

		if triggerCb then
			local swallowed = false
			local path = customObj:_pathFromRoot2Myself()
			local unfixedNames = customObj:_gatherUnfixedNames()
			local cb, cbname, _ = self:_getPropertyCallback(PropertyTypes.OP_REMOVE, path)

			if cb ~= nil then
				local ret

				if unfixedNames then
					ret = cb(self, k, obj, unpack(unfixedNames))
				else
					ret = cb(self, k, obj)
				end

				swallowed = self:_checkCallbackSwallowed(cbname, ret)
			end

			if not swallowed then
				local parentObj = customObj._parent
				local oldv = customObj:quickCopy(k, obj, customObj._propertiesCnt + 1, PropertyTypes.OP_INSERT)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to remove sub property [%s], but not exist in property cache", propertyId, k)
	end
end

function ClientRealPropertyComponent:__syncProperty__(propertyId, opType, name, value, triggerCb)
	if opType == PropertyTypes.OP_CHANGE then
		self:__OpChange__(propertyId, name, value, triggerCb)
	elseif opType == PropertyTypes.OP_ADD then
		self:__OpAdd__(propertyId, name, value, triggerCb)
	elseif opType == PropertyTypes.OP_DEL then
		assert(value == "")
		self:__OpDel__(propertyId, name, triggerCb)
	elseif opType == PropertyTypes.OP_INSERT then
		self:__OpInsert__(propertyId, name, value, triggerCb)
	elseif opType == PropertyTypes.OP_REMOVE then
		assert(value == "")
		self:__OpRemove__(propertyId, name, triggerCb)
	elseif LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("__syncProperty__ with unknown opType %s", opType)
	end
end

function ClientRealPropertyComponent:__syncPropertyId__(propertyId, name, value)
	if propertyId <= 0 then
		local customObj = self.__Properties__[name]

		customObj:_onSyncPropertyId(nil, value, self.__CustomPropertiesCache__)
	else
		local customObj = self:_getCachedProperty(propertyId)

		if customObj:isCustomList() then
			name = tonumber(name)
		else
			local cls = customObj.__ClassType
			local propDeclares = cls.__Name2PropertyDeclare__
			local declare = propDeclares[name]

			if declare == nil and cls.__ValueTypeDeclare__ and cls.__ValueTypeDeclare__.intTypeKey then
				name = tonumber(name)
			end
		end

		customObj:_onSyncPropertyId(name, value, self.__CustomPropertiesCache__)
	end
end

function ClientRealPropertyComponent:_Engine_onPropertyFrameSync(ownerid, syncdata)
	local owner = self

	if ownerid ~= "" then
		owner = self:getRealOwner(ownerid)
	end

	SyncStrategyMgr.onClientSyncProperty(PropertyTypes.SYNC_MODE_FRAME, owner, syncdata)
end

function ClientRealPropertyComponent:_genNextPropertyId()
	local id = self.__NextPropertyId__

	self.__NextPropertyId__ = self.__NextPropertyId__ + 1

	return id
end

return ClientRealPropertyComponent
