-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientDispatcherComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local CoreConst = require("Core.Common.Const")
local RpcMethod = require("Core.Common.RpcMethod")
local RpcIndex = require("Core.Common.RpcIndex")
local EntityManager = require("Core.Common.EntityManager")
local ClientUtils = require("Utils.ClientUtils")
local phonestcore = require("phonestcore")
local ClientRepo = require("Core.Client.ClientRepo")
local lume = require("Core.Common.lume")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CommonSwitch = require("Common.CommonSwitch")
local TimerManager = require("Core.Timer.TimerManager")
local IDManager = require("Core.Common.IDManager")
local RpcDataCodec = require("Core.PropertySync.RpcDataCodec")

local function decodeEntityInitForLogic(entityType, initDict)
	if CommonSwitch.CompactClientInitDataVerify then
		local VerifyCodec = require("Core.PropertySync.RpcDataVerifyCodec")

		return VerifyCodec.decodeEntityInitOrNormal(RpcDataCodec, entityType, initDict)
	end

	return RpcDataCodec.decodeEntityInit(entityType, initDict)
end

local ClientDispatcherComponent = Class.Component("ClientDispatcherComponent")

function ClientDispatcherComponent:ctor()
	self.entities = {}
	self._delayDestroyQueue = {}
	self._reliableSpaceMsgs = {}
end

function ClientDispatcherComponent:destroy()
	for entityId, _ in pairs(self.entities) do
		local entity = EntityManager.getEntity(entityId)

		if entity then
			ClientUtils.safeDestroy(entity)
		end
	end

	self.entities = {}

	self:_clearAllDelayDestroy()

	for _, req in pairs(self._reliableSpaceMsgs) do
		if req.callbackId then
			self:delCallback(req.callbackId)
		end
	end

	self._reliableSpaceMsgs = {}
end

function ClientDispatcherComponent:RPC_SC_DispatchOtherEntityClientMsg(entId, index, parameters)
	local ent = EntityManager.getEntity(entId)

	if ent == nil then
		local me = pg and pg.me or nil
		local pendingTeleport = me and me.blockedHomelandEntryPendingTeleport or nil

		if pendingTeleport ~= nil and pendingTeleport.spaceDict ~= nil and tostring(entId or "") == tostring(pendingTeleport.spaceDict.id or "") then
			return
		end

		local methodName = RpcIndex.INDEX2RPC[index]

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DispatchOtherEntityClientMsg ent is error, for entId=%s, index=%s, method=%s", entId, index, methodName)
		end

		return
	end

	local methodName = RpcIndex.INDEX2RPC[index]

	if methodName == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DispatchOtherEntityClientMsg ent %s got invalid raw index %s", entId, index)
		end

		return
	end

	local method = ent[methodName]

	if method == nil or not Class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DispatchOtherEntityClientMsg ent %s has no rpc method %s", entId, methodName)
		end

		return
	end

	method(CoreConst.ACCESSOR_SERVER, ent, unpack(parameters))
end

function ClientDispatcherComponent:RPC_SC_DispatchOtherEntityPropertySync(entId, parameters)
	local ent = EntityManager.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DispatchOtherEntityPropertySync ent is error, for entId=%s", entId)
		end

		return
	end

	local propertyid, optype, name, value = unpack(parameters)

	ent:__syncProperty__(propertyid, optype, name, value, true)
end

function ClientDispatcherComponent:RPC_SC_DispatchOtherEntityPropertyIdSync(entId, parameters)
	local ent = EntityManager.getEntity(entId)

	if ent == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("RPC_SC_DispatchOtherEntityPropertyIdSync ent is error, for entId=%s", entId)
		end

		return
	end

	local propertyid, name, value = unpack(parameters)

	ent:__syncPropertyId__(propertyid, name, value)
end

function ClientDispatcherComponent:onLeaveSpace()
	for entityId, _ in pairs(self.entities) do
		local entity = EntityManager.getEntity(entityId)

		if entity then
			ClientUtils.safeDestroy(entity)
		end
	end

	self.entities = {}

	self:_clearAllDelayDestroy()

	for _, req in pairs(self._reliableSpaceMsgs) do
		if req.callbackId then
			self:delCallback(req.callbackId)
		end
	end

	self._reliableSpaceMsgs = {}
end

function ClientDispatcherComponent:start()
	return
end

function ClientDispatcherComponent:shouldDelayBlockedHomelandEntryClientEntityCreate()
	local me = pg and pg.me or nil

	return not self.replayingBlockedHomelandEntryDelayedCreates and me ~= nil and me.blockedHomelandEntryPendingTeleport ~= nil
end

function ClientDispatcherComponent:delayBlockedHomelandEntryClientEntityCreate(entityType, entityId, entityContent, rebind)
	self.blockedHomelandEntryDelayedCreates = self.blockedHomelandEntryDelayedCreates or {}
	self.blockedHomelandEntryDelayedCreates[#self.blockedHomelandEntryDelayedCreates + 1] = {
		entityType = entityType,
		entityId = entityId,
		entityContent = entityContent,
		rebind = rebind
	}
end

function ClientDispatcherComponent:replayBlockedHomelandEntryDelayedClientEntities()
	local delayedCreates = self.blockedHomelandEntryDelayedCreates

	if delayedCreates == nil or #delayedCreates == 0 then
		return
	end

	self.blockedHomelandEntryDelayedCreates = nil
	self.replayingBlockedHomelandEntryDelayedCreates = true

	for _, data in ipairs(delayedCreates) do
		self:_createClientEntity(data.entityType, data.entityId, data.entityContent, data.rebind)
	end

	self.replayingBlockedHomelandEntryDelayedCreates = nil
end

function ClientDispatcherComponent:discardBlockedHomelandEntryDelayedClientEntities()
	self.blockedHomelandEntryDelayedCreates = nil
end

function ClientDispatcherComponent:RPC_SC_CreateMultiClientEntity(isSimpleInfo, rebind, aoiEntityData, gamePlayData, ownPetEntityData, createMode)
	local oldEntitieKeys = lume.keys(self.entities)
	local newEntities = {}

	for _, entityData in ipairs(ownPetEntityData) do
		local entityType, entityId, initData, lazyload = unpack(entityData)
		local initDict

		if lazyload then
			initDict = {
				__bin_data = initData,
				__decode_type = phonestcore.LazyDecodeClient
			}
		else
			initDict = ClientRepo.protoCodec:decode(initData)
			initDict = decodeEntityInitForLogic(entityType, initDict)
		end

		self:_createClientEntity(entityType, entityId, initDict, rebind)

		newEntities[entityId] = true
	end

	for _, entityData in ipairs(aoiEntityData) do
		if isSimpleInfo then
			local entityType, entityId, staticId, pos, displayLevel, templateId = unpack(entityData)

			pg.game.entityCount:addEntityInfo(entityId, entityType, staticId, pos, displayLevel, templateId)
		else
			local entityType, entityId, initData, lazyload = unpack(entityData)
			local initDict

			if lazyload then
				initDict = {
					__bin_data = initData,
					__decode_type = phonestcore.LazyDecodeClient
				}
			else
				initDict = ClientRepo.protoCodec:decode(initData)
				initDict = decodeEntityInitForLogic(entityType, initDict)
			end

			self:_createClientEntity(entityType, entityId, initDict, rebind)
			pg.game.entityCount:markEntityCreated(entityId)

			newEntities[entityId] = true
		end
	end

	for _, entityData in ipairs(gamePlayData) do
		local entityType, entityId, initData, lazyload = unpack(entityData)
		local initDict

		if lazyload then
			initDict = {
				__bin_data = initData,
				__decode_type = phonestcore.LazyDecodeClient
			}
		else
			initDict = ClientRepo.protoCodec:decode(initData)
			initDict = decodeEntityInitForLogic(entityType, initDict)
		end

		self:_createClientEntity(entityType, entityId, initDict, rebind)

		newEntities[entityId] = true
	end

	for _, entityId in ipairs(oldEntitieKeys) do
		if newEntities[entityId] == nil then
			self:_destroyClientEntity(entityId)
		end
	end

	if createMode == CoreConst.CreateClientEntityMode.Seamless then
		pg.game.seamless:seam_sys_onSwitchFinished(self.sceneId)
		pg.game.seamless:startCheckClientReady()
	else
		pg.game.seamless:seam_sys_setSwitchState(false)
	end
end

function ClientDispatcherComponent:RPC_SC_CreateClientEntityInfo(entityId, entityType, staticId, pos, displayLevel, templateId)
	pg.game.entityCount:addEntityInfo(entityId, entityType, staticId, pos, displayLevel, templateId)
end

function ClientDispatcherComponent:RPC_SC_RequestCreateClientEntityFailed(entityId)
	pg.game.entityCount:removeEntityInfo(entityId)
end

function ClientDispatcherComponent:RPC_SC_CreateClientEntity(entityType, entityId, initData, lazyload)
	local initDict

	if lazyload then
		initDict = {
			__bin_data = initData,
			__decode_type = phonestcore.LazyDecodeClient
		}
	else
		initDict = ClientRepo.protoCodec:decode(initData)
		initDict = decodeEntityInitForLogic(entityType, initDict)
	end

	self:_createClientEntity(entityType, entityId, initDict, false)
	pg.game.entityCount:markEntityCreated(entityId)
end

function ClientDispatcherComponent:_createClientEntity(entityType, entityId, entityContent, rebind)
	if self:shouldDelayBlockedHomelandEntryClientEntityCreate() then
		self:delayBlockedHomelandEntryClientEntityCreate(entityType, entityId, entityContent, rebind)

		return
	end

	if self._delayDestroyQueue[entityId] then
		self:_cancelDelayDestroy(entityId)

		local oldEntity = EntityManager.getEntity(entityId)

		if oldEntity then
			ClientUtils.safeDestroy(oldEntity)
		end
	end

	local entity = EntityManager.getEntity(entityId)

	if not rebind and self.entities[entityId] == true and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("_creatClientEntityAndStart repeat %s, %s", entityType, entityId)
	end

	entity = entity or ClientUtils.createClientEntity(entityType, entityId, entityContent)

	if entity then
		self.entities[entity.id] = true
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("_creatClientEntityAndStart failed %s, %s", entityType, entityId)
	end
end

function ClientDispatcherComponent:RPC_SC_DestroyClientEntity(entityId, reason)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:log2Tag("LuaVerbose", "RPC_SC_DestroyClientEntity %s", entityId)
	end

	pg.game.entityCount:removeEntityInfo(entityId)

	local entity = EntityManager.getEntity(entityId)

	if entity == nil then
		return
	end

	local delayTime = entity.delayClientDestroyTime

	if delayTime and delayTime > 0 and not self:_isDelayDestroyForbidden(entity) then
		self:_addDelayDestroy(entityId, delayTime)
	else
		self:_destroyClientEntity(entityId)
	end
end

function ClientDispatcherComponent:_destroyClientEntity(entityId)
	local entity = EntityManager.getEntity(entityId)

	if entity then
		self.entities[entity.id] = nil

		ClientUtils.safeDestroy(entity)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("_destroyClientEntity failed, entity %s not existed", entityId)
	end
end

function ClientDispatcherComponent:_isDelayDestroyForbidden(entity)
	return Utils.isPlayer(entity) or Utils.isPet(entity)
end

function ClientDispatcherComponent:_addDelayDestroy(entityId, delayTime)
	self:_cancelDelayDestroy(entityId)

	self.entities[entityId] = nil

	local timerId = TimerManager.addTimer(delayTime, function()
		self._delayDestroyQueue[entityId] = nil

		local entity = EntityManager.getEntity(entityId)

		if entity then
			ClientUtils.safeDestroy(entity)
		end
	end)

	self._delayDestroyQueue[entityId] = timerId

	if pg.logDebug() then
		self.logger:debug("__delay _addDelayDestroy entity %s, delayTime %s", entityId, delayTime)
	end
end

function ClientDispatcherComponent:_cancelDelayDestroy(entityId)
	local timerId = self._delayDestroyQueue[entityId]

	if not timerId then
		return false
	end

	TimerManager.removeTimer(timerId)

	self._delayDestroyQueue[entityId] = nil

	return true
end

function ClientDispatcherComponent:_clearAllDelayDestroy()
	for entityId, timerId in pairs(self._delayDestroyQueue) do
		TimerManager.removeTimer(timerId)

		local entity = EntityManager.getEntity(entityId)

		if entity then
			ClientUtils.safeDestroy(entity)
		end
	end

	self._delayDestroyQueue = {}
end

function ClientDispatcherComponent:forceDestroyDelayedEntity(entityId)
	if not self:_cancelDelayDestroy(entityId) then
		return false
	end

	local entity = EntityManager.getEntity(entityId)

	if entity then
		ClientUtils.safeDestroy(entity)
	end

	if pg.logDebug() then
		self.logger:debug("__delay forceDestroyDelayedEntity entity %s", entityId, entity)
	end

	return true
end

function ClientDispatcherComponent:serverEntityMsg(entityId, methodName, params)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("call serverEntityMsg", entityId, methodName)
	end

	local index = RpcIndex.sendRpcIndex(methodName)

	self:serverMsg("RPC_CS_ServerEntityMsg", entityId, index, params or {})
end

function ClientDispatcherComponent:RPC_SC_ClientEntityMsg(entityId, index, params)
	local entity = pg.getEntity(entityId)

	if entity == nil then
		local methodName = RpcIndex.INDEX2RPC[index]

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientEntityMsg invalid entity", entityId, index, methodName)
		end

		return
	end

	local methodName = RpcIndex.INDEX2RPC[index]

	if methodName == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientEntityMsg has no rpc index %s", index)
		end

		return
	end

	local method = entity[methodName]

	if method == nil or not Class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("ClientEntityMsg has no rpc method %s", methodName)
		end

		return
	end

	method(CoreConst.ACCESSOR_SERVER, entity, unpack(params))
end

function ClientDispatcherComponent:serverSpaceMsg(methodName, params, callback)
	local index = RpcIndex.sendRpcIndex(methodName)

	if callback then
		return self:serverMsg("RPC_CS_SpaceMethod", index, params or {}, callback)
	end

	self:serverMsg("RPC_CS_SpaceMethod", index, params or {})
end

function ClientDispatcherComponent:reliableServerSpaceMsg(methodName, params)
	local requestId = IDManager.genB64ID()

	self._reliableSpaceMsgs[requestId] = {
		methodName = methodName,
		params = params,
		spaceId = pg.space.id
	}

	self:_sendReliableServerSpaceMsg(requestId)
end

function ClientDispatcherComponent:resendReliableServerSpaceMsgs()
	for requestId, _ in pairs(self._reliableSpaceMsgs) do
		self:_sendReliableServerSpaceMsg(requestId)
	end
end

function ClientDispatcherComponent:_sendReliableServerSpaceMsg(requestId)
	local req = self._reliableSpaceMsgs[requestId]

	if req.callbackId then
		self:delCallback(req.callbackId)
	end

	if not pg.space or pg.space.id ~= req.spaceId then
		self._reliableSpaceMsgs[requestId] = nil

		return
	end

	local index = RpcIndex.sendRpcIndex(req.methodName)

	req.callbackId = self:serverMsg("RPC_CS_ReliableSpaceMethod", index, req.params or {}, requestId, function()
		self._reliableSpaceMsgs[requestId] = nil
	end)
end

function ClientDispatcherComponent:RPC_SC_SpaceMethod(index, params)
	if self.space == nil then
		return
	end

	local methodName = RpcIndex.INDEX2RPC[index]

	if methodName == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("entityMessage SpaceMethod has no rpc index %s", index)
		end

		return
	end

	local method = self.space[methodName]

	if method == nil or not Class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("entityMessage SpaceMethod has no rpc method %s", methodName)
		end

		return
	end

	method(CoreConst.ACCESSOR_SERVER, self.space, unpack(params))
end

return ClientDispatcherComponent
