-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\DynamicFeature\\iFeature.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CustomTypeFactory = require("Core.PropertySync.CustomTypeFactory")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("iFeature")
local ClientRepo = require("Core.Client.ClientRepo")
local SafeCallback = require("Core.Framework.SafeCallback")
local pairs = pairs
local type = type
local rawset = rawset
local rawget = rawget
local assert = assert
local next = next
local unpack = unpack
local table_insert = table.insert
local table_remove = table.remove
local tonumber = tonumber
local iFeature = Class.LiteClass("iFeature")

function iFeature:ctor()
	self.master = nil
	self.featureName = nil

	self:declacreProperty()
end

function iFeature:init(master, data)
	self.master = master
	self.featureName = data.featureName

	self:initProperty(data.__Properties__ or {})
end

function iFeature:onEnterSpace()
	return
end

function iFeature:onLeaveSpace()
	return
end

function iFeature:destroy()
	self.master = nil
end

function iFeature:onMasterModelLoaded()
	return
end

function iFeature:serverMsg(funcname, ...)
	if self.master then
		self.master:serverMsg("RPC_CS_FeatureMsg", self.featureName, funcname, {
			...
		})
	end
end

function iFeature:FM_SC_FeatureTest(arg1, arg2, arg3)
	return
end

function iFeature:FM_SC_Property(propertyid, optype, name, allval)
	if allval ~= "" then
		allval = ClientRepo.protoCodec:decode(allval)
	end

	self:__syncProperty__(propertyid, optype, name, allval, true)
end

function iFeature:declacreProperty()
	self.__Properties__ = {}
	self.__PropertiesCnt__ = 0
	self.__CustomPropertiesCache__ = {}
	self.__NextPropertyId__ = 1
end

function iFeature:initProperty(dict)
	local properties = self.__Properties__

	setmetatable(properties, self:getClass())
	setmetatable(self, {
		__index = properties,
		__newindex = function(tbl, k, v)
			if properties[k] ~= nil then
				properties[k] = v
			else
				rawset(tbl, k, v)
			end
		end
	})

	for name, value in pairs(dict) do
		if rawget(self, name) ~= nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("property %s is coverd", name)
		end

		if type(value) == "table" then
			local customType = value.__tp__

			assert(customType ~= nil)

			value.__tp__ = nil

			local customObj = CustomTypeFactory.createReadonly(customType, name, value, self, nil, true, false)

			customObj:_attachToCache(self.__CustomPropertiesCache__)

			self.__Properties__[name] = customObj
		else
			self.__Properties__[name] = value
		end
	end
end

function iFeature:_changeRootProperty(k, v, triggerCb)
	local typeVal = type(v)
	local oldVal, newVal

	if typeVal == "table" then
		local customType = v.__tp__

		assert(customType ~= nil)

		v.__tp__ = nil
		oldVal = self.__Properties__[k]
		typeVal = oldVal:customTypeName()

		if oldVal._id == v.__id__ and oldVal._id >= PropertyTypes.ID_SYNC_START then
			newVal = oldVal
			oldVal = oldVal:deepCopy()

			newVal:rochange(v)
		else
			oldVal:_detachFromCache(self.__CustomPropertiesCache__)

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

function iFeature:_changeSubProperty(propertyId, k, v, triggerCb)
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
		else
			oldVal = customObj._properties[k]
			newVal = v
		end

		customObj._properties[k] = newVal

		if triggerCb then
			self:_queryPropertyChangedCallback(customObj, k, oldVal, newVal, typeVal)
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to change sub property %s, but not exist in property cache", propertyId, k)
	end
end

function iFeature:__OpChange__(propertyId, k, v, triggerCb)
	if propertyId <= 0 then
		self:_changeRootProperty(k, v, triggerCb)
	else
		self:_changeSubProperty(propertyId, k, v, triggerCb)
	end
end

function iFeature:__OpAdd__(propertyId, k, v, triggerCb)
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

function iFeature:_checkCallbackSwallowed(cbname, result)
	if result == PropertyTypes.CALLBACK_SWALLOW then
		return true
	end

	if result ~= nil and result ~= PropertyTypes.CALLBACK_RAISE and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("%s property callback %s should return CALLBACK_SWALLOW or CALLBACK_RAISE", self:getClassType(), cbname)
	end

	return false
end

function iFeature:__OpDel__(propertyId, k, triggerCb)
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

function iFeature:__OpInsert__(propertyId, k, v, triggerCb)
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
				local oldv = customObj:quickCopy(k, nil, customObj._propertiesCnt - 1)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to insert sub property [%s], but not exist in property cache", propertyId, k)
	end
end

function iFeature:__OpRemove__(propertyId, k, triggerCb)
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
				local oldv = customObj:quickCopy(k, obj, customObj._propertiesCnt + 1)

				self:_queryPropertyChangedCallback(parentObj, customObj._name, oldv, customObj, customObj:customTypeName())
			end
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("property id=%s notified to remove sub property [%s], but not exist in property cache", propertyId, k)
	end
end

function iFeature:__syncProperty__(propertyId, opType, name, value, triggerCb)
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

function iFeature:_getPropertyCallback(op, callbackName)
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

function iFeature:_queryPropertyChangedCallback(customObj, k, oldVal, newVal, typeVal)
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

return iFeature
