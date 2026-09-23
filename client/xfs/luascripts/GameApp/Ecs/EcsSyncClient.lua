-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ecs\\EcsSyncClient.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TablePool = require("Common.Container.TablePool")
local EcsSyncExchange = require("GameApp.Ecs.EcsSyncExchange")
local StateSchema = require("Common.Ecs.EcsSyncStateSchema")
local EcsSyncClient = Class.LightClass("EcsSyncClient")
local MAX_BATCH_STATES = StateSchema.MAX_BATCH_STATES
local MAX_AUTHORITY_READY_PER_BATCH = StateSchema.MAX_AUTHORITY_READY_PER_BATCH
local MAX_BUFF_CHANGES_PER_BATCH = StateSchema.MAX_BUFF_CHANGES_PER_BATCH
local MAX_FULL_STATE_SYNC_IDS = StateSchema.MAX_FULL_STATE_SYNC_IDS
local MAX_REMOVE_INFOS_PER_PUSH = StateSchema.MAX_REMOVE_INFOS_PER_PUSH
local MULTIPLAYER_STATE_SEND_INTERVAL = 0.2
local SINGLE_PLAYER_STATE_SEND_INTERVAL = 0.5
local MULTIPLAYER_IDLE_TICK_INTERVAL = 0.2
local SINGLE_PLAYER_IDLE_TICK_INTERVAL = 0.5
local FULL_SYNC_COOLDOWN = 1
local FULL_SYNC_RESPONSE_TIMEOUT = 5
local UPLOAD_RESULT_TIMEOUT = 5
local REMOVE_VERSION_RETENTION_SECONDS = StateSchema.REMOVE_RETENTION_SECONDS
local REMOVE_VERSION_PRUNE_INTERVAL = 5
local MAX_UINT32 = StateSchema.MAX_UINT32
local MAX_SAFE_INTEGER = StateSchema.MAX_SAFE_INTEGER
local LARGE_TABLE_TYPE = 3
local AUTHORITY_PHASE_WAITING_APPLY = "WAITING_APPLY"
local AUTHORITY_PHASE_READY_TO_ANNOUNCE = "READY_TO_ANNOUNCE"
local EcsSyncHelper = {}

function EcsSyncHelper.findUploadedState(batch, syncId, partId)
	for _, uploadedState in ipairs(batch.payload.states) do
		if uploadedState.syncId == syncId and uploadedState.partId == partId then
			return uploadedState
		end
	end
end

function EcsSyncClient:ctor(exchange)
	self.exchange = exchange
	self.enabled = false
	self.syncSessionId = nil
	self.lastPushSeq = 0
	self.syncVersion = 0
	self.nextBatchId = 1
	self.syncObjectsById = {}
	self.syncObjectsByLegacyKey = {}
	self.submittedBindingsByLegacyKey = {}
	self.unconfirmedBatches = {}
	self.removeVersions = {}
	self.nextRemoveVersionPruneTime = 0
	self.lastFullSyncTime = -math.huge
	self.fullSyncWaitUntil = 0
	self.pendingFullSyncAll = false
	self.pendingFullSyncIds = {}
	self.pendingBuffChanges = {}
	self.pendingSendParts = {}
	self.pendingAuthorityReadyObjects = {}
	self.nextStateSendTime = 0
	self.nextIdleTickTime = 0
end

function EcsSyncClient:_retireUnconfirmedBatches()
	local retiringBatches = self.unconfirmedBatches

	self.unconfirmedBatches = {}

	for _, batch in pairs(retiringBatches) do
		self:_recycleBatch(batch)
	end
end

function EcsSyncClient:_clearState()
	self:_retireUnconfirmedBatches()

	self.lastPushSeq = 0
	self.syncVersion = 0
	self.nextBatchId = 1
	self.syncObjectsById = {}
	self.syncObjectsByLegacyKey = {}
	self.submittedBindingsByLegacyKey = {}
	self.removeVersions = {}
	self.nextRemoveVersionPruneTime = 0
	self.lastFullSyncTime = -math.huge
	self.fullSyncWaitUntil = 0
	self.pendingFullSyncAll = false
	self.pendingFullSyncIds = {}
	self.pendingBuffChanges = {}
	self.pendingSendParts = {}
	self.pendingAuthorityReadyObjects = {}
	self.nextStateSendTime = 0
	self.nextIdleTickTime = 0
end

function EcsSyncClient:_getRemoveVersion(syncId, partId)
	local entry = self.removeVersions[syncId]

	if not entry then
		return
	end

	if partId == nil then
		return entry.objectVersion
	end

	return entry.partVersions[partId]
end

function EcsSyncClient:_clearRemoveVersion(syncId, partId)
	local entry = self.removeVersions[syncId]

	if not entry then
		return
	end

	if partId == nil then
		entry.objectVersion = nil
		entry.objectRemovedAt = nil
	else
		entry.partVersions[partId] = nil
		entry.partRemovedAt[partId] = nil
	end

	if not entry.objectVersion and not next(entry.partVersions) then
		self.removeVersions[syncId] = nil
	end
end

function EcsSyncClient:_setRemoveVersion(syncId, partId, version, removedAt)
	local entry = self.removeVersions[syncId]

	if not entry then
		entry = {
			partVersions = {},
			partRemovedAt = {}
		}
		self.removeVersions[syncId] = entry
	end

	if partId == nil then
		entry.objectVersion = version
		entry.objectRemovedAt = removedAt
	else
		entry.partVersions[partId] = version
		entry.partRemovedAt[partId] = removedAt
	end
end

function EcsSyncClient:_pruneRemoveVersions()
	local now = Time.realSecondCache

	if now < self.nextRemoveVersionPruneTime then
		return
	end

	self.nextRemoveVersionPruneTime = now + REMOVE_VERSION_PRUNE_INTERVAL

	local expiredSyncIds

	for syncId, entry in pairs(self.removeVersions) do
		if entry.objectRemovedAt and now - entry.objectRemovedAt >= REMOVE_VERSION_RETENTION_SECONDS then
			entry.objectVersion = nil
			entry.objectRemovedAt = nil
		end

		local expiredPartIds

		for partId, removedAt in pairs(entry.partRemovedAt) do
			if now - removedAt >= REMOVE_VERSION_RETENTION_SECONDS then
				expiredPartIds = expiredPartIds or TablePool.getTable(LARGE_TABLE_TYPE)
				expiredPartIds[#expiredPartIds + 1] = partId
			end
		end

		if expiredPartIds then
			for _, partId in ipairs(expiredPartIds) do
				entry.partVersions[partId] = nil
				entry.partRemovedAt[partId] = nil
			end

			table.clearArray(expiredPartIds)
			TablePool.returnTable(expiredPartIds, LARGE_TABLE_TYPE)
		end

		if not entry.objectVersion and not next(entry.partVersions) then
			expiredSyncIds = expiredSyncIds or TablePool.getTable(LARGE_TABLE_TYPE)
			expiredSyncIds[#expiredSyncIds + 1] = syncId
		end
	end

	if expiredSyncIds then
		for _, syncId in ipairs(expiredSyncIds) do
			self.removeVersions[syncId] = nil
		end

		table.clearArray(expiredSyncIds)
		TablePool.returnTable(expiredSyncIds, LARGE_TABLE_TYPE)
	end
end

function EcsSyncClient:shutdown()
	self.enabled = false
	self.syncSessionId = nil

	if appFacade.ecsMgr then
		appFacade.ecsMgr:ConfigureEcsSync(false, "")
	end

	if self.exchange then
		self.exchange:resetGeneration()
	end

	self:_clearState()
end

function EcsSyncClient:initialize(fullState)
	if type(fullState) ~= "table" or type(fullState.syncSessionId) ~= "string" then
		self:shutdown()

		return false
	end

	if not self.exchange then
		self:shutdown()

		return false
	end

	if not self.exchange:isEnabled() and not self.exchange:bind() then
		self:shutdown()

		return false
	end

	if self.syncSessionId ~= fullState.syncSessionId then
		self.exchange:resetGeneration()
		self:_clearState()
	end

	self.enabled = true
	self.syncSessionId = fullState.syncSessionId

	appFacade.ecsMgr:ConfigureEcsSync(true, self.syncSessionId)

	if not self:applyFullState(fullState) then
		self:shutdown()

		return false
	end

	return true
end

function EcsSyncClient:_isLocalAuthority(syncObject)
	return syncObject and pg.me and syncObject.authorityId == pg.me.id
end

function EcsSyncClient:_isSinglePlayerWorld()
	return pg.space and pg.space.isMultiPlayerEnv and not pg.space:isMultiPlayerEnv()
end

function EcsSyncClient:_getStateSendInterval()
	if self:_isSinglePlayerWorld() then
		return SINGLE_PLAYER_STATE_SEND_INTERVAL
	end

	return MULTIPLAYER_STATE_SEND_INTERVAL
end

function EcsSyncClient:_getIdleTickInterval()
	if self:_isSinglePlayerWorld() then
		return SINGLE_PLAYER_IDLE_TICK_INTERVAL
	end

	return MULTIPLAYER_IDLE_TICK_INTERVAL
end

function EcsSyncClient:_hasPendingFullSync()
	return self.pendingFullSyncAll or next(self.pendingFullSyncIds) ~= nil
end

function EcsSyncClient:_setSyncObjectSimulationPaused(syncObject, paused, resumeAuthority)
	if syncObject.simulationPaused == paused then
		return false
	end

	local queued = self.exchange:setSimulationPaused(syncObject.syncId, paused, resumeAuthority == true)

	if not queued then
		return false
	end

	syncObject.simulationPaused = paused

	return true
end

function EcsSyncClient:_reconcileSyncObjectAuthority(syncObject, resumeAuthority)
	local paused = not self:_isLocalAuthority(syncObject) or syncObject.authorityPhase ~= nil

	return self:_setSyncObjectSimulationPaused(syncObject, paused, resumeAuthority == true and not paused)
end

function EcsSyncClient:_isSyncObjectWritable(syncObject)
	return self:_isLocalAuthority(syncObject) and syncObject.authorityPhase == nil
end

function EcsSyncClient:_setSyncObjectAuthorityPhase(syncObject, authorityPhase)
	syncObject.authorityPhase = authorityPhase
	self.pendingAuthorityReadyObjects = self.pendingAuthorityReadyObjects or {}
	self.pendingAuthorityReadyObjects[syncObject] = authorityPhase == AUTHORITY_PHASE_READY_TO_ANNOUNCE and true or nil
end

function EcsSyncClient:_getPart(syncId, partId)
	local syncObject = self.syncObjectsById[syncId]

	return syncObject and syncObject.parts[partId]
end

function EcsSyncClient:_getOrCreatePart(syncObject, partId)
	local part = syncObject.parts[partId]

	if not part then
		part = {
			syncId = syncObject.syncId,
			partId = partId
		}
		syncObject.parts[partId] = part
	end

	return part
end

function EcsSyncClient:_removePart(syncObject, partId)
	if syncObject then
		local part = syncObject.parts[partId]

		if part then
			self.pendingSendParts[part] = nil
			syncObject.parts[partId] = nil
		end
	end
end

function EcsSyncClient:_registerSyncObject(syncObject)
	local submitted = self.submittedBindingsByLegacyKey[syncObject.legacyKey]

	if not submitted or submitted.syncId ~= syncObject.syncId or submitted.authorityVersion ~= syncObject.authorityVersion then
		local registered = self.exchange:registerSyncObject(syncObject.legacyKey, syncObject.syncId, syncObject.authorityVersion)

		if registered then
			local previousLegacyKey = syncObject.submittedLegacyKey

			if previousLegacyKey and previousLegacyKey ~= syncObject.legacyKey then
				local previous = self.submittedBindingsByLegacyKey[previousLegacyKey]

				if previous and previous.syncId == syncObject.syncId then
					self.submittedBindingsByLegacyKey[previousLegacyKey] = nil
				end
			end

			self.submittedBindingsByLegacyKey[syncObject.legacyKey] = {
				syncId = syncObject.syncId,
				authorityVersion = syncObject.authorityVersion
			}
			syncObject.submittedLegacyKey = syncObject.legacyKey
		end
	end
end

function EcsSyncClient:_clearSubmittedSyncObjectBinding(syncObject)
	if not syncObject then
		return
	end

	local legacyKey = syncObject.submittedLegacyKey or syncObject.legacyKey
	local submitted = legacyKey and self.submittedBindingsByLegacyKey[legacyKey]

	if submitted and submitted.syncId == syncObject.syncId then
		self.submittedBindingsByLegacyKey[legacyKey] = nil
	end

	syncObject.submittedLegacyKey = nil
end

function EcsSyncClient:_queueValidatedPartServerState(syncObject, serverState, forceApply, updateVersion)
	local partId = serverState.partId
	local partRemoveVersion = self:_getRemoveVersion(syncObject.syncId, partId)

	if partRemoveVersion then
		if not updateVersion or updateVersion <= partRemoveVersion then
			return
		end

		self:_clearRemoveVersion(syncObject.syncId, partId)
	end

	local part = self:_getOrCreatePart(syncObject, partId)
	local currentServerState = part.serverState

	if currentServerState and currentServerState.serverVersion > serverState.serverVersion then
		return
	end

	if not forceApply and StateSchema.equals(currentServerState, serverState, true) then
		return
	end

	local localCompressedId = syncObject.legacyKey * 256 + partId

	part.serverState = serverState

	local queued = self.exchange:queueServerState(localCompressedId, syncObject.syncId, partId, serverState, forceApply == true)

	if not queued then
		return false
	end

	return true
end

function EcsSyncClient:_resetSyncObjectSendState(syncId)
	for batchId, batch in pairs(self.unconfirmedBatches) do
		batch.ignoredSyncIds[syncId] = true

		local hasActiveState = false

		for _, uploadedState in ipairs(batch.payload.states) do
			if not batch.ignoredSyncIds[uploadedState.syncId] then
				hasActiveState = true

				break
			end
		end

		if not hasActiveState then
			for _, part in ipairs(batch.parts) do
				if part and part.sendingBatchId == batchId then
					part.sendingBatchId = nil
				end
			end

			self.unconfirmedBatches[batchId] = nil

			self:_recycleBatch(batch)
		end
	end

	local syncObject = self.syncObjectsById[syncId]

	if syncObject then
		self:_setSyncObjectAuthorityPhase(syncObject, nil)

		for _, part in pairs(syncObject.parts) do
			self.pendingSendParts[part] = nil
			part.waitingToSend = nil
			part.sendingBatchId = nil
		end
	end
end

function EcsSyncClient:_applyValidatedSyncObject(objectData, forceApply, updateVersion)
	updateVersion = updateVersion or objectData.syncVersion

	local objectRemoveVersion = self:_getRemoveVersion(objectData.syncId, nil)

	if objectRemoveVersion then
		if not updateVersion or updateVersion <= objectRemoveVersion then
			return
		end

		self:_clearRemoveVersion(objectData.syncId, nil)
	end

	local syncObject = self.syncObjectsById[objectData.syncId]

	if syncObject and syncObject.authorityVersion > objectData.authorityVersion then
		return syncObject
	end

	syncObject = syncObject or {
		parts = {}
	}

	local previousLegacyKey = syncObject.legacyKey
	local previousMappedObject = self.syncObjectsByLegacyKey[objectData.legacyKey]
	local authorityChanged = syncObject.authorityVersion and syncObject.authorityVersion ~= objectData.authorityVersion

	syncObject.syncId = objectData.syncId
	syncObject.authorityVersion = objectData.authorityVersion
	syncObject.authorityId = objectData.authorityId
	syncObject.legacyKey = objectData.legacyKey
	syncObject.syncVersion = updateVersion or syncObject.syncVersion or 0
	self.syncObjectsById[syncObject.syncId] = syncObject

	if previousLegacyKey and previousLegacyKey ~= syncObject.legacyKey and self.syncObjectsByLegacyKey[previousLegacyKey] == syncObject then
		self.syncObjectsByLegacyKey[previousLegacyKey] = nil
	end

	self.syncObjectsByLegacyKey[syncObject.legacyKey] = syncObject

	self:_registerSyncObject(syncObject)

	if previousMappedObject ~= syncObject and previousMappedObject then
		self:_resetSyncObjectSendState(previousMappedObject.syncId)
	end

	if authorityChanged then
		self:_resetSyncObjectSendState(syncObject.syncId)
	end

	local queuedStateCount = 0

	for _, serverState in ipairs(objectData.parts or EMPTY_TABLE) do
		if self:_queueValidatedPartServerState(syncObject, serverState, forceApply, updateVersion) then
			queuedStateCount = queuedStateCount + 1
		end
	end

	local waitsForAuthority = self:_isLocalAuthority(syncObject) and objectData.writable == false

	if queuedStateCount > 0 and waitsForAuthority then
		self.exchange:setAuthorityReadyBarrier(syncObject.syncId, syncObject.authorityVersion)
	end

	local authorityPhase = waitsForAuthority and (queuedStateCount > 0 and AUTHORITY_PHASE_WAITING_APPLY or AUTHORITY_PHASE_READY_TO_ANNOUNCE) or nil

	self:_setSyncObjectAuthorityPhase(syncObject, authorityPhase)
	self:_reconcileSyncObjectAuthority(syncObject, self:_isLocalAuthority(syncObject) and syncObject.authorityPhase == nil)

	return syncObject
end

function EcsSyncClient:registerSyncObject(objectData, forceApply, updateVersion)
	if not self.enabled or not StateSchema.validateSyncObject(objectData) then
		return
	end

	for _, serverState in ipairs(objectData.parts or EMPTY_TABLE) do
		if not StateSchema.validateServerState(serverState) then
			self:requestFullSync(objectData.syncId)

			return
		end
	end

	return self:_applyValidatedSyncObject(objectData, forceApply, updateVersion)
end

function EcsSyncClient:applyFullState(fullState)
	if not self.enabled or type(fullState) ~= "table" or fullState.syncSessionId ~= self.syncSessionId or not StateSchema.isIntegerInRange(fullState.syncVersion, 0, MAX_SAFE_INTEGER) or not StateSchema.isIntegerInRange(fullState.pushSeq, 0, MAX_SAFE_INTEGER) or fullState.scopeSyncIds ~= nil and StateSchema.getDenseArrayLength(fullState.scopeSyncIds, MAX_FULL_STATE_SYNC_IDS) == nil or type(fullState.syncObjects) ~= "table" or type(fullState.removeInfos) ~= "table" or StateSchema.getDenseArrayLength(fullState.syncObjects, MAX_SAFE_INTEGER) == nil or StateSchema.getDenseArrayLength(fullState.removeInfos, MAX_SAFE_INTEGER) == nil then
		return false
	end

	local scopeSyncIdSet

	if fullState.scopeSyncIds then
		scopeSyncIdSet = {}

		for _, syncId in ipairs(fullState.scopeSyncIds) do
			if not StateSchema.isIntegerInRange(syncId, 1, MAX_UINT32) or scopeSyncIdSet[syncId] then
				return false
			end

			scopeSyncIdSet[syncId] = true
		end
	end

	local seenSyncIds = {}
	local seenPartIdSets = {}

	for index, syncObject in ipairs(fullState.syncObjects) do
		if not StateSchema.validateSyncObject(syncObject) or seenSyncIds[syncObject.syncId] then
			return false
		end

		seenSyncIds[syncObject.syncId] = true

		local seenPartIds = {}

		for _, serverState in ipairs(syncObject.parts or EMPTY_TABLE) do
			if not StateSchema.validateServerState(serverState) or seenPartIds[serverState.partId] then
				return false
			end

			seenPartIds[serverState.partId] = true
		end

		seenPartIdSets[index] = seenPartIds
	end

	for _, removeInfo in ipairs(fullState.removeInfos) do
		if not StateSchema.isValidRemoveInfo(removeInfo) then
			return false
		end
	end

	local canReconcileObjectSet = fullState.syncVersion >= self.syncVersion

	self.syncVersion = math.max(self.syncVersion, fullState.syncVersion)
	self.lastPushSeq = math.max(self.lastPushSeq, fullState.pushSeq or 0)

	local registeredObjects = {}

	for index, syncObject in ipairs(fullState.syncObjects) do
		local registered = self:_applyValidatedSyncObject(syncObject, false, fullState.syncVersion)

		if not registered then
			return false
		end

		registeredObjects[index] = registered
	end

	if canReconcileObjectSet then
		for index, registered in ipairs(registeredObjects) do
			local seenPartIds = seenPartIdSets[index]
			local missingPartIds = {}

			for partId in pairs(registered.parts) do
				if not seenPartIds[partId] then
					missingPartIds[#missingPartIds + 1] = partId
				end
			end

			for _, partId in ipairs(missingPartIds) do
				self:_applyRemoveInfo({
					syncId = registered.syncId,
					partId = partId,
					removeVersion = math.max(1, fullState.syncVersion)
				})
			end
		end
	end

	for _, removeInfo in ipairs(fullState.removeInfos) do
		self:_applyRemoveInfo(removeInfo)
	end

	if canReconcileObjectSet then
		local missingSyncIds = {}

		if scopeSyncIdSet then
			for syncId in pairs(scopeSyncIdSet) do
				if not seenSyncIds[syncId] and self.syncObjectsById[syncId] then
					missingSyncIds[#missingSyncIds + 1] = syncId
				end
			end
		else
			for syncId in pairs(self.syncObjectsById) do
				if not seenSyncIds[syncId] then
					missingSyncIds[#missingSyncIds + 1] = syncId
				end
			end
		end

		for _, syncId in ipairs(missingSyncIds) do
			self:_applyRemoveInfo({
				syncId = syncId,
				removeVersion = math.max(1, fullState.syncVersion)
			})
		end
	end

	self.fullSyncWaitUntil = 0

	if scopeSyncIdSet then
		for syncId in pairs(scopeSyncIdSet) do
			self.pendingFullSyncIds[syncId] = nil
		end
	else
		self.pendingFullSyncAll = false
		self.pendingFullSyncIds = {}
	end

	return true
end

function EcsSyncClient:applyStateChanges(changes)
	if not self.enabled or type(changes) ~= "table" or changes.syncSessionId ~= self.syncSessionId or not StateSchema.isIntegerInRange(changes.syncVersion, 0, MAX_SAFE_INTEGER) or type(changes.states) ~= "table" or type(changes.removeInfos) ~= "table" or StateSchema.getDenseArrayLength(changes.states, MAX_BATCH_STATES) == nil or StateSchema.getDenseArrayLength(changes.removeInfos, MAX_REMOVE_INFOS_PER_PUSH) == nil then
		return
	end

	local pushSeq = changes.pushSeq

	if not StateSchema.isIntegerInRange(pushSeq, 1, MAX_SAFE_INTEGER) or pushSeq <= self.lastPushSeq then
		return
	end

	for _, serverState in ipairs(changes.states) do
		if not StateSchema.validateServerState(serverState, true) then
			local invalidSyncId = type(serverState) == "table" and serverState.syncId or nil

			self:requestFullSync(invalidSyncId)

			return
		end
	end

	for _, removeInfo in ipairs(changes.removeInfos) do
		if not StateSchema.isValidRemoveInfo(removeInfo) then
			self:requestFullSync()

			return
		end
	end

	if pushSeq > self.lastPushSeq + 1 then
		self:requestFullSync()
	end

	self.lastPushSeq = pushSeq
	self.syncVersion = math.max(self.syncVersion, changes.syncVersion)

	for _, serverState in ipairs(changes.states) do
		local syncObject = self.syncObjectsById[serverState.syncId]

		if not syncObject then
			self:requestFullSync(serverState.syncId)
		elseif self:_getRemoveVersion(syncObject.syncId, nil) then
			-- block empty
		else
			self:_queueValidatedPartServerState(syncObject, serverState, false, changes.syncVersion)
		end
	end

	for _, removeInfo in ipairs(changes.removeInfos) do
		self:_applyRemoveInfo(removeInfo)
	end
end

function EcsSyncClient:_applyRemoveInfo(removeInfo)
	assert(StateSchema.isValidRemoveInfo(removeInfo))

	local removeVersion = removeInfo.removeVersion

	if removeVersion <= (self:_getRemoveVersion(removeInfo.syncId, removeInfo.partId) or -1) then
		return
	end

	local syncObject = self.syncObjectsById[removeInfo.syncId]
	local removePartId = removeInfo.partId == nil and -1 or removeInfo.partId

	if not self.exchange:applyRemove(removeInfo.syncId, removePartId) then
		return
	end

	self:_setRemoveVersion(removeInfo.syncId, removeInfo.partId, removeVersion, Time.realSecondCache)

	if removeInfo.partId ~= nil then
		self:_removePart(syncObject, removeInfo.partId)

		return
	end

	self:_resetSyncObjectSendState(removeInfo.syncId)

	if syncObject then
		self:_setSyncObjectSimulationPaused(syncObject, false, false)
		self:_clearSubmittedSyncObjectBinding(syncObject)

		self.syncObjectsById[syncObject.syncId] = nil

		if self.syncObjectsByLegacyKey[syncObject.legacyKey] == syncObject then
			self.syncObjectsByLegacyKey[syncObject.legacyKey] = nil
		end
	end
end

function EcsSyncClient:onAuthorityChange(message)
	if not self.enabled or type(message) ~= "table" or message.syncSessionId ~= self.syncSessionId or not StateSchema.isIntegerInRange(message.syncVersion, 0, MAX_SAFE_INTEGER) or type(message.syncObject) ~= "table" then
		return
	end

	local current = self.syncObjectsById[message.syncObject.syncId]

	if current and StateSchema.isIntegerInRange(message.syncObject.authorityVersion, 1, MAX_UINT32) and current.authorityVersion > message.syncObject.authorityVersion then
		return
	end

	self.syncVersion = math.max(self.syncVersion, message.syncVersion)
	message.syncObject.writable = false

	local syncObject = self:registerSyncObject(message.syncObject, true, message.syncVersion)

	if not syncObject then
		return
	end
end

function EcsSyncClient:_consumeExchangePendingState(array, start)
	local decodeUInt32 = EcsSyncExchange.decodeUInt32
	local syncId = decodeUInt32(array[start + EcsSyncExchange.EVENT_SYNC_ID])
	local authorityVersion = decodeUInt32(array[start + EcsSyncExchange.EVENT_AUTHORITY_VERSION])
	local syncObject = self.syncObjectsById[syncId]

	if not syncObject or syncObject.authorityVersion ~= authorityVersion or not self:_isLocalAuthority(syncObject) then
		return
	end

	local partId = array[start + EcsSyncExchange.EVENT_PART_ID]
	local part = self:_getOrCreatePart(syncObject, partId)
	local record = part.exchangePendingState

	if not record then
		record = {
			elements = {
				0,
				0,
				0,
				0,
				0,
				0
			}
		}
		part.exchangePendingState = record
	end

	local preserveImmediate = part.waitingToSend and part.waitingToSend.immediate == true

	record.syncId = syncId
	record.partId = partId
	record.authorityVersion = authorityVersion

	StateSchema.readFlat(array, start + EcsSyncExchange.EVENT_STATE, decodeUInt32, record)

	record.immediate = preserveImmediate or array[start + EcsSyncExchange.EVENT_IMMEDIATE] ~= 0
	part.waitingToSend = record
	self.pendingSendParts[part] = true
end

function EcsSyncClient:_consumeExchangeAuthorityReady(syncId, authorityVersion)
	local syncObject = self.syncObjectsById[syncId]

	if syncObject and syncObject.authorityVersion == authorityVersion and syncObject.authorityPhase == AUTHORITY_PHASE_WAITING_APPLY then
		self:_setSyncObjectAuthorityPhase(syncObject, AUTHORITY_PHASE_READY_TO_ANNOUNCE)
	end
end

function EcsSyncClient:_sendBatch(states, parts, immediates)
	local batchId = self.nextBatchId

	self.nextBatchId = self.nextBatchId + 1

	local payload = StateSchema.createUploadRequest(self.syncSessionId, batchId, states)
	local batch = TablePool.getTable()

	batch.batchId = batchId
	batch.sentAt = Time.realSecondCache
	batch.payload = payload
	batch.parts = parts
	batch.immediates = immediates
	batch.ignoredSyncIds = TablePool.getTable(LARGE_TABLE_TYPE)
	self.unconfirmedBatches[batchId] = batch

	for _, part in ipairs(parts) do
		if part then
			part.sendingBatchId = batchId
		end
	end

	pg.me:reliableServerSpaceMsg("RPC_CS_EcsUploadState", {
		payload
	})
end

function EcsSyncClient:_recycleBatch(batch)
	batch.payload = nil

	if batch.parts then
		table.clearArray(batch.parts)
		TablePool.returnTable(batch.parts, LARGE_TABLE_TYPE)

		batch.parts = nil
	end

	if batch.immediates then
		table.clearArray(batch.immediates)
		TablePool.returnTable(batch.immediates, LARGE_TABLE_TYPE)

		batch.immediates = nil
	end

	if batch.ignoredSyncIds then
		TablePool.returnTable(batch.ignoredSyncIds, LARGE_TABLE_TYPE)

		batch.ignoredSyncIds = nil
	end

	TablePool.returnTable(batch)
end

function EcsSyncClient:_sendWaitingStates()
	local pending = self.pendingSendParts

	self.pendingSendParts = {}

	local batchStates, batchParts, batchImmediates
	local stateCount = 0

	for part in pairs(pending) do
		local record = part.waitingToSend
		local syncObject = self.syncObjectsById[part.syncId]
		local isActivePart = syncObject and syncObject.parts[part.partId] == part

		if record and isActivePart and not part.sendingBatchId and self:_isSyncObjectWritable(syncObject) then
			if not batchStates then
				batchStates = {}
				batchParts = TablePool.getTable(LARGE_TABLE_TYPE)
				batchImmediates = TablePool.getTable(LARGE_TABLE_TYPE)
			end

			batchStates[#batchStates + 1] = StateSchema.copyForUpload(record, part.serverState and part.serverState.serverVersion or 0)
			batchParts[#batchParts + 1] = part
			batchImmediates[#batchImmediates + 1] = record.immediate == true
			record.immediate = false
			part.waitingToSend = nil
			stateCount = stateCount + 1

			if #batchStates >= MAX_BATCH_STATES then
				self:_sendBatch(batchStates, batchParts, batchImmediates)

				batchStates = nil
				batchParts = nil
				batchImmediates = nil
			end
		elseif record and isActivePart then
			self.pendingSendParts[part] = true
		end
	end

	if batchStates then
		self:_sendBatch(batchStates, batchParts, batchImmediates)
	end

	return stateCount
end

function EcsSyncClient:_releaseBatch(batch, requeueStates)
	local hasImmediateWaiting = false

	for index, part in ipairs(batch.parts) do
		if part and part.sendingBatchId == batch.batchId then
			part.sendingBatchId = nil

			if requeueStates and not part.waitingToSend then
				local uploadedState = batch.payload.states[index]

				part.waitingToSend = StateSchema.copyState(uploadedState, nil, {
					syncId = uploadedState.syncId,
					partId = uploadedState.partId,
					authorityVersion = uploadedState.authorityVersion,
					immediate = batch.immediates and batch.immediates[index] == true
				})
				self.pendingSendParts[part] = true
			end

			hasImmediateWaiting = hasImmediateWaiting or part.waitingToSend and part.waitingToSend.immediate == true
		end
	end

	return hasImmediateWaiting
end

function EcsSyncClient:_tickUploadTimeout(now)
	local expiredBatchIds

	for batchId, batch in pairs(self.unconfirmedBatches) do
		if batch.sentAt and now - batch.sentAt >= UPLOAD_RESULT_TIMEOUT then
			expiredBatchIds = expiredBatchIds or TablePool.getTable(LARGE_TABLE_TYPE)
			expiredBatchIds[#expiredBatchIds + 1] = batchId
		end
	end

	if not expiredBatchIds then
		return false
	end

	local repairSyncIds, repairSyncIdSet
	local hasUploadTimeout = false

	for _, batchId in ipairs(expiredBatchIds) do
		local batch = self.unconfirmedBatches[batchId]

		if batch then
			hasUploadTimeout = true
			repairSyncIds = repairSyncIds or TablePool.getTable(LARGE_TABLE_TYPE)
			repairSyncIdSet = repairSyncIdSet or TablePool.getTable(LARGE_TABLE_TYPE)

			for _, uploadedState in ipairs(batch.payload.states) do
				local syncId = uploadedState.syncId

				if not batch.ignoredSyncIds[syncId] and not repairSyncIdSet[syncId] then
					repairSyncIdSet[syncId] = true
					repairSyncIds[#repairSyncIds + 1] = syncId
				end
			end

			self:_releaseBatch(batch, true)

			self.unconfirmedBatches[batchId] = nil

			self:_recycleBatch(batch)
		end
	end

	if repairSyncIds and #repairSyncIds > 0 then
		self:requestFullSync(repairSyncIds)
	end

	table.clearArray(expiredBatchIds)
	TablePool.returnTable(expiredBatchIds, LARGE_TABLE_TYPE)

	if repairSyncIds then
		table.clearArray(repairSyncIds)
		table.clear(repairSyncIdSet)
		TablePool.returnTable(repairSyncIds, LARGE_TABLE_TYPE)
		TablePool.returnTable(repairSyncIdSet, LARGE_TABLE_TYPE)
	end

	if hasUploadTimeout then
		self.nextStateSendTime = 0
	end

	return hasUploadTimeout
end

function EcsSyncClient:onUploadResult(uploadResult)
	if not self.enabled or type(uploadResult) ~= "table" or uploadResult.syncSessionId ~= self.syncSessionId or not StateSchema.isIntegerInRange(uploadResult.syncVersion, 0, MAX_SAFE_INTEGER) then
		return
	end

	self.syncVersion = math.max(self.syncVersion, uploadResult.syncVersion)

	local batch = self.unconfirmedBatches[uploadResult.batchId]

	if not batch then
		return
	end

	if uploadResult.errorCode == "RATE_LIMITED" then
		self:_releaseBatch(batch, true)

		self.unconfirmedBatches[batch.batchId] = nil

		self:_recycleBatch(batch)

		self.nextStateSendTime = Time.realSecondCache + self:_getStateSendInterval()

		return
	end

	for _, accepted in ipairs(uploadResult.accepted or EMPTY_TABLE) do
		if not batch.ignoredSyncIds[accepted.syncId] then
			local uploadedState = EcsSyncHelper.findUploadedState(batch, accepted.syncId, accepted.partId)
			local syncObject = self.syncObjectsById[accepted.syncId]

			if uploadedState and syncObject and syncObject.authorityVersion == uploadedState.authorityVersion then
				local part = self:_getPart(accepted.syncId, accepted.partId)

				part = part or self:_getOrCreatePart(syncObject, accepted.partId)

				if part then
					if part.sendingBatchId == batch.batchId then
						part.sendingBatchId = nil
					end

					if part.waitingToSend and part.waitingToSend.immediate then
						self.nextStateSendTime = 0
					end
				end

				local removedVersion = self:_getRemoveVersion(accepted.syncId, accepted.partId)

				if removedVersion and removedVersion < uploadResult.syncVersion then
					self:_clearRemoveVersion(accepted.syncId, accepted.partId)
				end

				local current = part and part.serverState

				if not current or accepted.serverVersion >= current.serverVersion then
					part.serverState = StateSchema.copyState(uploadedState, accepted.serverVersion)
				end
			end
		end
	end

	for _, rejected in ipairs(uploadResult.rejected or EMPTY_TABLE) do
		if not batch.ignoredSyncIds[rejected.syncId] then
			local uploadedState = EcsSyncHelper.findUploadedState(batch, rejected.syncId, rejected.partId)
			local syncObject = self.syncObjectsById[rejected.syncId]

			if uploadedState and syncObject and syncObject.authorityVersion == uploadedState.authorityVersion then
				local part = self:_getPart(rejected.syncId, rejected.partId)

				if part and part.sendingBatchId == batch.batchId then
					part.sendingBatchId = nil

					if part.waitingToSend and part.waitingToSend.immediate then
						self.nextStateSendTime = 0
					end
				end

				if rejected.fullSyncObject then
					self:registerSyncObject(rejected.fullSyncObject, true, uploadResult.syncVersion)
				elseif rejected.errorCode == "UNKNOWN_SYNC_ID" then
					self:requestFullSync(rejected.syncId)
				end
			end
		end
	end

	if self:_releaseBatch(batch, false) then
		self.nextStateSendTime = 0
	end

	self.unconfirmedBatches[batch.batchId] = nil

	self:_recycleBatch(batch)

	if uploadResult.errorCode then
		self:requestFullSync()
	end
end

function EcsSyncClient:requestFullSync(syncIds)
	if not self.enabled or not pg.me then
		return
	end

	if syncIds == nil then
		if self.pendingFullSyncAll then
			return
		end

		self.pendingFullSyncAll = true
		self.pendingFullSyncIds = {}
	else
		if type(syncIds) == "number" then
			if StateSchema.isIntegerInRange(syncIds, 1, MAX_UINT32) and not self.pendingFullSyncAll then
				self.pendingFullSyncIds[syncIds] = true
			end

			return
		end

		if type(syncIds) ~= "table" or self.pendingFullSyncAll then
			return
		end

		for _, syncId in ipairs(syncIds) do
			if StateSchema.isIntegerInRange(syncId, 1, MAX_UINT32) and not self.pendingFullSyncIds[syncId] then
				self.pendingFullSyncIds[syncId] = true
			end
		end
	end
end

function EcsSyncClient:_flushFullSyncRequest()
	if not self.enabled or not pg.me then
		return
	end

	local now = Time.realSecondCache

	if now < self.fullSyncWaitUntil then
		return
	end

	if now - self.lastFullSyncTime < FULL_SYNC_COOLDOWN then
		return
	end

	local requestSyncIds
	local isGlobal = self.pendingFullSyncAll

	if not isGlobal then
		if not next(self.pendingFullSyncIds) then
			return
		end

		requestSyncIds = {}

		for syncId in pairs(self.pendingFullSyncIds) do
			requestSyncIds[#requestSyncIds + 1] = syncId
		end

		table.sort(requestSyncIds)

		if #requestSyncIds > MAX_FULL_STATE_SYNC_IDS then
			isGlobal = true
			self.pendingFullSyncAll = true
			self.pendingFullSyncIds = {}
			requestSyncIds = nil
		end
	end

	self.lastFullSyncTime = now
	self.fullSyncWaitUntil = now + FULL_SYNC_RESPONSE_TIMEOUT

	pg.me:reliableServerSpaceMsg("RPC_CS_EcsRequestFullState", {
		StateSchema.createFullStateRequest(self.syncSessionId, requestSyncIds)
	})
end

function EcsSyncClient:_tickAuthorityChange()
	local pending = self.pendingAuthorityReadyObjects

	self.pendingAuthorityReadyObjects = {}

	local readyObjects

	for syncObject in pairs(pending) do
		local isActive = self.syncObjectsById[syncObject.syncId] == syncObject

		if isActive and syncObject.authorityPhase == AUTHORITY_PHASE_READY_TO_ANNOUNCE and self:_isLocalAuthority(syncObject) then
			self:_setSyncObjectAuthorityPhase(syncObject, nil)
			self:_reconcileSyncObjectAuthority(syncObject, true)

			readyObjects = readyObjects or {}
			readyObjects[#readyObjects + 1] = {
				syncId = syncObject.syncId,
				authorityVersion = syncObject.authorityVersion
			}
		end
	end

	if not readyObjects then
		return
	end

	local readyCount = #readyObjects

	if readyCount <= MAX_AUTHORITY_READY_PER_BATCH then
		pg.me:reliableServerSpaceMsg("RPC_CS_EcsAuthorityReady", {
			StateSchema.createAuthorityReadyRequest(self.syncSessionId, readyObjects)
		})

		return
	end

	local offset = 1

	while offset <= readyCount do
		local batch = {}
		local last = math.min(offset + MAX_AUTHORITY_READY_PER_BATCH - 1, readyCount)

		for index = offset, last do
			batch[#batch + 1] = readyObjects[index]
		end

		pg.me:reliableServerSpaceMsg("RPC_CS_EcsAuthorityReady", {
			StateSchema.createAuthorityReadyRequest(self.syncSessionId, batch)
		})

		offset = last + 1
	end
end

function EcsSyncClient:queueBuffCountChange(actorId, element, layer, srcActorId)
	if not self.enabled then
		return false
	end

	self.pendingBuffChanges[#self.pendingBuffChanges + 1] = {
		actorId = actorId,
		element = element,
		layer = layer,
		srcActorId = srcActorId or 0
	}

	return true
end

function EcsSyncClient:_flushBuffCountChanges()
	if #self.pendingBuffChanges == 0 or not pg.me then
		return
	end

	local pending = self.pendingBuffChanges

	self.pendingBuffChanges = {}

	if #pending <= MAX_BUFF_CHANGES_PER_BATCH then
		pg.me:serverSpaceMsg("RPC_CS_EcsBuffCountChangeBatch", {
			StateSchema.createBuffChangeRequest(self.syncSessionId, pending)
		})

		return
	end

	local offset = 1

	while offset <= #pending do
		local changes = {}
		local last = math.min(offset + MAX_BUFF_CHANGES_PER_BATCH - 1, #pending)

		for index = offset, last do
			changes[#changes + 1] = pending[index]
		end

		pg.me:serverSpaceMsg("RPC_CS_EcsBuffCountChangeBatch", {
			StateSchema.createBuffChangeRequest(self.syncSessionId, changes)
		})

		offset = last + 1
	end
end

function EcsSyncClient:tick()
	if not self.enabled or not pg.space or not pg.me then
		return
	end

	local now = Time.realSecondCache
	local hasPendingEvents = self.exchange:hasPendingEvents()
	local commandBacklogDepth = self.exchange:getBacklogDepth()
	local hasPendingBuffChanges = #self.pendingBuffChanges > 0
	local hasPendingAuthority = next(self.pendingAuthorityReadyObjects) ~= nil
	local isStateSendDue = next(self.pendingSendParts) ~= nil and now >= self.nextStateSendTime
	local isFullSyncDue = self:_hasPendingFullSync() and now >= self.fullSyncWaitUntil and now - self.lastFullSyncTime >= FULL_SYNC_COOLDOWN
	local hasImmediateWork = hasPendingEvents or commandBacklogDepth > 0 or hasPendingBuffChanges or hasPendingAuthority or isStateSendDue or isFullSyncDue

	if now < self.nextIdleTickTime and not hasImmediateWork then
		return
	end

	self.nextIdleTickTime = now + self:_getIdleTickInterval()

	if commandBacklogDepth > 0 then
		self.exchange:flushCommands()
	end

	local hasImmediateState = false

	if hasPendingEvents then
		hasImmediateState = self.exchange:consumeEvents(self)
	end

	local hasUploadTimeout = false

	if next(self.unconfirmedBatches) ~= nil then
		hasUploadTimeout = self:_tickUploadTimeout(now)
	end

	if hasPendingAuthority or next(self.pendingAuthorityReadyObjects) ~= nil then
		self:_tickAuthorityChange()
	end

	if hasPendingBuffChanges then
		self:_flushBuffCountChanges()
	end

	if self:_hasPendingFullSync() then
		self:_flushFullSyncRequest()
	end

	if next(self.removeVersions) ~= nil and now >= self.nextRemoveVersionPruneTime then
		self:_pruneRemoveVersions()
	end

	if next(self.pendingSendParts) ~= nil and (hasImmediateState or hasUploadTimeout or now >= self.nextStateSendTime) then
		self:_sendWaitingStates()

		self.nextStateSendTime = now + self:_getStateSendInterval()
	end
end

return EcsSyncClient
