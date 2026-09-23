-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAuthorityComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local GlobalData = require("Core.Client.GlobalData")
local ClientUtils = require("Utils.ClientUtils")
local EntityManager = require("Core.Common.EntityManager")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local CompactPropertySchema = require("Core.PropertySync.CompactPropertySchema")
local ClientAuthorityComponent = class.Component("ClientAuthorityComponent")
local logger = LoggerManager.getLogger("ClientAuthorityComponent")

local function getAuthorityOwnClientPropertyValue(ent, propertyId, name)
	if propertyId <= 0 then
		return ent[name]
	end

	local customObj = ent:_getCachedProperty(propertyId)

	if customObj == nil then
		return nil
	end

	return customObj[name]
end

local function isAuthorityOwnClientPropertyEqual(ent, propertyId, name, declare, newValue)
	if declare.isCustom then
		return false
	end

	return newValue == getAuthorityOwnClientPropertyValue(ent, propertyId, name)
end

function ClientAuthorityComponent:init(dict)
	self:refreshAuthorityProperty()

	return true
end

function ClientAuthorityComponent:start()
	self:refreshAuthority()
end

function ClientAuthorityComponent:on_authorityId_changed(oldVal, newVal)
	self:refreshAuthority()
	self:postComponentMethod("EVENT_OnAuthorityChanged")
end

function ClientAuthorityComponent:EVENT_EModelCreate()
	self:refreshAuthority()
end

function ClientAuthorityComponent:onEnterSpace()
	self:refreshAuthority()
	self:refreshPosSyncState()
end

function ClientAuthorityComponent:refreshAuthorityProperty()
	local authority = ClientUtils.getClientAuthority(self)

	self.authority = authority
	self.isMainAuthority = ClientUtils.isClientMainAuthority(authority)
end

function ClientAuthorityComponent:refreshAuthority()
	self:refreshAuthorityProperty()

	if self.isMainAuthority then
		self:setServerProxy(GlobalData.Player)
	else
		self:setServerProxy(nil)
	end

	self:refreshPosSyncState()
	self:refreshVelocitySyncState()
	self:refreshEModelAuthority()
end

function ClientAuthorityComponent:refreshPosSyncState()
	local enablePosSync = ClientUtils.getEnablePosSync(self)

	if self.aoi then
		self.aoi.isLocalAuthority = self.isMainAuthority
		self.aoi.isSender = enablePosSync
	end

	if self.eModel then
		local syncToServer = enablePosSync and not self.isClientEnt
		local canMove = self.entityCanMove or syncToServer

		self.eModel:SetEnablePosSync(canMove, syncToServer)

		self.eModel.syncToServer = enablePosSync and self.isMainAuthority and not self.isClientEnt
	end
end

function ClientAuthorityComponent:getPosSyncOverrideState()
	if self.posSyncReasons == nil or next(self.posSyncReasons) == nil then
		return nil
	end

	for _, v in pairs(self.posSyncReasons) do
		if not v then
			return false
		end
	end

	return true
end

function ClientAuthorityComponent:setTempPosSync(enable, reason)
	if self.posSyncReasons == nil then
		self.posSyncReasons = {}
	end

	reason = reason or Const.TEMP_POS_SYNC_REASON.DEFAULT
	self.posSyncReasons[reason] = enable

	self:refreshPosSyncState()
end

function ClientAuthorityComponent:clearTempPosSync(reason)
	if self.posSyncReasons then
		self.posSyncReasons[reason] = nil
	end

	self:refreshPosSyncState()
end

function ClientAuthorityComponent:refreshVelocitySyncState()
	if self.eModel then
		self.eModel:SetEnableVelocitySync(self.isMainAuthority and Utils.isEnvObj(self))
	end
end

function ClientAuthorityComponent:refreshEModelAuthority()
	if self.eModel then
		self.eModel.isMainAuthority = self.isMainAuthority
	end
end

function ClientAuthorityComponent:RPC_SC_NotifyNewAuthorityOwnProps(entId, payload)
	local ent = EntityManager.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_SC_NotifyNewAuthorityOwnProps ent is nil, entId=%s", entId)
		end

		return
	end

	for _, entry in ipairs(payload and payload.entries or EMPTY_TABLE) do
		local propertyId, name, declare = self:resolveAuthorityOwnClientPropertyEntry(entId, entry)

		if name ~= nil and entry.value ~= nil then
			if not isAuthorityOwnClientPropertyEqual(ent, propertyId, name, declare, entry.value) then
				ent:__syncProperty__(propertyId, PropertyTypes.OP_CHANGE, name, entry.value, true)
			end
		elseif name ~= nil and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_SC_NotifyNewAuthorityOwnProps value is nil, entId=%s, schemaName=%s, propertyId=%s, index=%s", entId, entry.schemaName, entry.propertyId, entry.index)
		end
	end
end

function ClientAuthorityComponent:RPC_SC_NotifyClearAuthorityOwnProps(entId, clearInfo)
	local ent = EntityManager.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("RPC_SC_NotifyClearAuthorityOwnProps ent is nil, entId=%s", entId)
		end

		return
	end

	local genDefaultValue = CompactPropertySchema.genDefaultValue

	for _, entry in ipairs(clearInfo and clearInfo.entries or EMPTY_TABLE) do
		local propertyId, name, declare = self:resolveAuthorityOwnClientPropertyEntry(entId, entry)

		if declare ~= nil then
			local keepTypeMarker = propertyId <= 0
			local defaultValue = genDefaultValue(declare, keepTypeMarker)

			if not isAuthorityOwnClientPropertyEqual(ent, propertyId, name, declare, defaultValue) then
				ent:__syncProperty__(propertyId, PropertyTypes.OP_CHANGE, name, defaultValue, true)
			end
		end
	end
end

function ClientAuthorityComponent:resolveAuthorityOwnClientPropertyEntry(entId, entry)
	if type(entry) ~= "table" or type(entry.propertyId) ~= "number" then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("resolveAuthorityOwnClientPropertyEntry invalid entry, entId=%s", entId)
		end

		return nil, nil, nil
	end

	local schema

	if entry.propertyId <= 0 then
		schema = CompactPropertySchema.getEntitySchema(entry.schemaName)
	else
		schema = CompactPropertySchema.getCustomSchema(entry.schemaName)
	end

	if schema == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("resolveAuthorityOwnClientPropertyEntry schema is nil, entId=%s, schemaName=%s, propertyId=%s", entId, entry.schemaName, entry.propertyId)
		end

		return nil, nil, nil
	end

	local name = schema.indexToName[entry.index]
	local declare = name and schema.declares[name]

	if declare == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("resolveAuthorityOwnClientPropertyEntry unknown index, entId=%s, schemaName=%s, propertyId=%s, index=%s", entId, entry.schemaName, entry.propertyId, entry.index)
		end

		return nil, nil, nil
	end

	return entry.propertyId, name, declare
end

return ClientAuthorityComponent
