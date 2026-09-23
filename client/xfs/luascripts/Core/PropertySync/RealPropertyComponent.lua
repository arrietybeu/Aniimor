-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\RealPropertyComponent.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local LoggerManager = require("Core.Log.LoggerManager")
local SyncStrategyMgr = require("Core.PropertySync.SyncStrategy.SyncStrategyMgr")
local logger = LoggerManager.getLogger("RealPropertyComponent")
local CommonSwitch = require("Common.CommonSwitch")
local GameServerRepo

if pg.component == "game" then
	GameServerRepo = require("Core.Server.GameServerRepo")
end

local pairs = pairs
local type = type
local rawset = rawset
local rawget = rawget
local assert = assert
local next = next
local error = error
local ipairs = ipairs
local string_format = string.format
local RealPropertyComponent = class.Component("RealPropertyComponent")
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
		local oldv = tbl.__Properties__[k]

		if oldv ~= nil then
			if v ~= nil then
				if oldv == v then
					return
				end

				if type(v) ~= type(oldv) then
					error(string_format("%s modify property %s value dismatch, need %s but get %s!", tbl:getClassType(), k, type(oldv), type(v)))
				end

				local propDeclares = tbl:getClass().__Name2PropertyDeclare__
				local declare = propDeclares[k]

				if not declare.customClass then
					tbl.__Properties__[k] = v
				else
					if v.__ClassType ~= nil then
						if v.__ClassType.typeName ~= declare.typeStr then
							error(string_format("%s modify property %s value dismatch, need %s but get %s!", tbl:getClassType(), k, declare.typeStr, v.__ClassType.typeName))
						end

						if v._id <= PropertyTypes.ID_NOT_INIT then
							error(string_format("%s modify property %s with invalid %s instance!", tbl:getClassType(), k, v.__ClassType.typeName))
						end
					else
						v = declare:createCustomObj(v)
					end

					v:_setName(k)
					v:_setDeclare(declare)
					v:_markRoot()
					v:_setParent(nil)
					v:_setOwner(tbl)

					local delegator = rawget(tbl, "_delegator")

					if delegator ~= nil then
						v:setDelegator(delegator)
					end

					tbl.__Properties__[k] = v

					oldv:_setInvalid()
				end

				tbl:_onRootPropertyChangedInRuntime(declare, k, v)
			else
				error(string_format("%s delete fixed property %s unsupported!", tbl:getClassType(), k))
			end
		else
			rawset(tbl, k, v)
		end
	end,
	__pairs = function(tbl)
		return next, tbl, nil
	end,
	__ipairs = function(tbl)
		return next, tbl, nil
	end,
	__len = function(tbl)
		return 0
	end
}

function RealPropertyComponent:ctor()
	local propDeclares = self:getClass().__Name2PropertyDeclare__

	if next(propDeclares) == nil then
		return
	end

	self.__Properties__ = {}
	self.__NextPropertyId__ = 1
end

function RealPropertyComponent:setDelegator(delegator)
	rawset(self, "_delegator", delegator)

	for _, value in pairs(self.__Properties__) do
		if type(value) == "table" then
			value:setDelegator(delegator)
		end
	end
end

function RealPropertyComponent:_onRootPropertyChangedInRuntime(declare, name, value)
	if declare.persist == PropertyTypes.PS_PER then
		local markDirty = self.markPersistentRootDirty

		if markDirty ~= nil then
			markDirty(self, name)
		end
	end

	if not SyncStrategyMgr.running then
		local aoiscope = declare.aoiscope
		local persist = declare.persist
		local delegator = rawget(self, "_delegator")
		local owner = delegator or self

		if not owner.__startfinish then
			return
		end

		if aoiscope > PropertyTypes.AOI_SERVER_ONLY then
			owner:propertySync2Client(aoiscope, -1, PropertyTypes.OP_CHANGE, name, value)
		end

		if delegator ~= nil and delegator.onPropertyModify then
			delegator:onPropertyModify(self, self._id, PropertyTypes.OP_CHANGE, name, value)
		end
	else
		SyncStrategyMgr.onRootPropertyChangedInRuntime(self, declare, name, value)
	end
end

function RealPropertyComponent:getLazyload()
	return self.__LazyLoad__ or false
end

function RealPropertyComponent:init(dict)
	local propDeclares = self:getClass().__Name2PropertyDeclare__

	if next(propDeclares) == nil then
		return true
	end

	local realDict

	if dict.__bin_data ~= nil then
		self.__LazyLoad__ = true

		local binData = dict.__bin_data

		dict.__bin_data = nil

		local decodeType = dict.__decode_type

		dict.__decode_type = nil

		local ctable, ptable, idx = phonestcore.lazyDecode(binData, decodeType, self.className)
		local customDict = GameServerRepo.protoCodec:decode(ctable.__custom__ or "")

		assert(ptable ~= nil)

		ctable.__custom__ = nil
		self.__Properties__ = ptable
		self.__PropertiesIdx__ = idx

		if customDict and next(customDict) ~= nil then
			for k, v in pairs(customDict) do
				dict[k] = v
			end
		end

		if ctable and next(ctable) ~= nil then
			for k, v in pairs(ctable) do
				dict[k] = v
			end
		end

		realDict = ptable
	else
		realDict = dict
	end

	local properties = self.__Properties__
	local vtbl = self:getClass().getVtbl()

	for name, declare in pairs(propDeclares) do
		local value = realDict[name]

		if dict[name] ~= nil then
			value = dict[name]
		end

		if not declare.customClass then
			if value == nil then
				value = declare.default
			elseif type(value) ~= declare.typeStr then
				error(string_format("%s init property %s with dismatch value, need %s but get %s", self:getClassType(), name, declare.typeStr, type(value)))
			end
		else
			if value == nil then
				value = {}
			end

			value = declare:createCustomObj(value)

			value:_setName(name)
			value:_setDeclare(declare)
			value:_markRoot()
			value:_setParent(nil)
			value:_setOwner(self)
		end

		if rawget(self, name) ~= nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("property %s is coverd", name)
		end

		properties[name] = value
	end

	setmetatable(properties, self:getClass().__objMetatable)
	setmetatable(self, {
		__index = properties,
		__newindex = mt.__newindex,
		__pairs = mt.__pairs,
		__ipairs = mt.__ipairs,
		__len = mt.__len
	})

	return true
end

function RealPropertyComponent:getAllProperties()
	if self.__Properties__ == nil then
		return nil
	end

	local propertiesDict = {}

	for name, value in pairs(self.__Properties__) do
		if (type(value) == "table" or type(value) == "userdata") and value.getRawTable then
			propertiesDict[name] = value:getRawTable()
		else
			propertiesDict[name] = value
		end
	end

	return propertiesDict
end

function RealPropertyComponent:attachMigrateProperties(migrateDict, sparseEnabled)
	if self.__Properties__ == nil then
		return migrateDict
	end

	if self.__LazyLoad__ then
		local lazyLoadDict = {}

		lazyLoadDict.__custom__ = GameServerRepo.protoCodec:encode(migrateDict or {})

		local migrateData = phonestcore.lazyEncode(lazyLoadDict, phonestcore.LazyEncodeMigrate, self.className, self.__PropertiesIdx__, sparseEnabled == true)

		return migrateData
	else
		local propDeclares = self:getClass().__Name2PropertyDeclare__

		for name, value in pairs(self.__Properties__) do
			local declare = propDeclares[name]

			if declare.persist == PropertyTypes.PS_PER then
				if type(value) == "table" and value.getPersistentValue then
					migrateDict[name] = value:getPersistentValue()
				else
					migrateDict[name] = value
				end
			end
		end

		return migrateDict
	end
end

function RealPropertyComponent:attachOwnClientProperties(clientDict)
	if self.__Properties__ == nil then
		return clientDict
	end

	if self.__LazyLoad__ then
		local lazyLoadDict = {}

		lazyLoadDict.__aoiscope__ = PropertyTypes.AOI_OWN_CLIENT
		lazyLoadDict.__custom__ = GameServerRepo.protoCodec:encode(clientDict or {})

		local clientData = phonestcore.lazyEncode(lazyLoadDict, phonestcore.LazyEncodeOwnClient, self.className, self.__PropertiesIdx__)

		return clientData
	else
		local propDeclares = self:getClass().__Name2PropertyDeclare__
		local propertiesDict = {}

		for name, value in pairs(self.__Properties__) do
			local declare = propDeclares[name]

			if declare.aoiscope > PropertyTypes.AOI_SERVER_ONLY then
				if not declare.customClass then
					propertiesDict[name] = value
				else
					local cdict = value:getOwnClientValue()

					propertiesDict[name] = cdict
				end
			end
		end

		if next(propertiesDict) then
			clientDict.__Properties__ = propertiesDict
		end

		return clientDict
	end
end

function RealPropertyComponent:attachAllClientsProperties(clientDict)
	if self.__Properties__ == nil then
		return clientDict
	end

	if self.__LazyLoad__ then
		local lazyLoadDict = {}

		lazyLoadDict.__aoiscope__ = PropertyTypes.AOI_ALL_CLIENTS
		lazyLoadDict.__custom__ = GameServerRepo.protoCodec:encode(clientDict or {})

		local clientData = phonestcore.lazyEncode(lazyLoadDict, phonestcore.LazyEncodeAllClients, self.className, self.__PropertiesIdx__)

		return clientData
	else
		local propDeclares = self:getClass().__Name2PropertyDeclare__
		local propertiesDict = {}

		for name, value in pairs(self.__Properties__) do
			local declare = propDeclares[name]

			if declare.aoiscope == PropertyTypes.AOI_ALL_CLIENTS then
				if not declare.customClass then
					propertiesDict[name] = value
				else
					local cdict = value:getAllClientsValue()

					propertiesDict[name] = cdict
				end
			end
		end

		if next(propertiesDict) then
			clientDict.__Properties__ = propertiesDict
		end

		return clientDict
	end
end

function RealPropertyComponent:propertyIdSync2Client(aoiscope, propertyid, name, value)
	if self.aoi or self.syncMsgToClient == true then
		local ownids, allids

		if aoiscope >= PropertyTypes.AOI_OWN_CLIENT then
			ownids = value:getOwnClientPropertyIds()
		end

		if ownids and next(ownids) ~= nil then
			self:sendPropertyIdSync2OwnClient(propertyid, name, ownids)
		end

		if aoiscope == PropertyTypes.AOI_ALL_CLIENTS then
			allids = value:getAllClientsPropertyIds()
		end

		if allids and next(allids) ~= nil then
			self:sendPropertyIdSync2AllClients(propertyid, name, allids)
		end
	end
end

function RealPropertyComponent:propertySync2Client(aoiscope, propertyid, optype, name, value, ownclient, allclients)
	if self.aoi or self.syncMsgToClient == true then
		local ownval, allval

		if aoiscope >= PropertyTypes.AOI_OWN_CLIENT then
			if aoiscope == PropertyTypes.AOI_OWN_CLIENT then
				if (type(value) == "table" or type(value) == "userdata") and value.getOwnClientValue then
					ownval = value:getOwnClientValue()
				else
					ownval = value
				end

				if ownval == nil then
					ownval = ""
				end

				if self.propAuth then
					self:sendPropertySync2OwnClient(propertyid, optype, name, ownval)
				end
			else
				if (type(value) == "table" or type(value) == "userdata") and value.getOwnAndAllClientsValue then
					ownval, allval = value:getOwnAndAllClientsValue(aoiscope)
				end

				if ownval == nil then
					ownval = value == nil and "" or value
				end

				if self.propAuth then
					self:sendPropertySync2OwnClient(propertyid, optype, name, ownval)
				end

				if allval == nil then
					allval = value == nil and "" or value
				end

				self:sendPropertySync2AllClients(propertyid, optype, name, allval)
			end
		end
	end
end

function RealPropertyComponent:_genNextPropertyId()
	local id = self.__NextPropertyId__

	self.__NextPropertyId__ = self.__NextPropertyId__ + 1

	return id
end

function RealPropertyComponent:destroy()
	if self.__LazyLoad__ then
		if self.__PropertiesIdx__ ~= nil then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("unregister lazyload property table in cpp for ", self.id)
			end

			phonestcore.lazyUnref(self.__PropertiesIdx__)

			self.__PropertiesIdx__ = nil
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("lazyload but __PropertiesIdx__ is nil for ", self.id)
		end
	end
end

return RealPropertyComponent
