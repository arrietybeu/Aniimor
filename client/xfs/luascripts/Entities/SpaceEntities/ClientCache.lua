-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCache.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local ClientUtils = require("Utils.ClientUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local GlobalData = require("Core.Client.GlobalData")
local msgpack = require("cmsgpack")
local ClientCache = {}
local logger = LoggerManager.getLogger("ClientCache")
local CACHE_PHYSICAL_KEY = Const.CLIENT_CACHE_PHYSICAL_KEY
local AsyncFileWriter = CS.FunPlus.WorldX.Utils.LuaAsyncFileWriter
local SAVE_INTERVAL_SECONDS = 180
local MUTATION_SAVE_THRESHOLD = 100
local MAX_OSS_READ_ATTEMPTS = 3
local OSS_PUT_URL_TTL_SECONDS = 280
local OSS_PUT_URL_MIN_REMAINING_SECONDS = 60
local OSS_PUT_URL_REFRESH_AGE_SECONDS = OSS_PUT_URL_TTL_SECONDS - OSS_PUT_URL_MIN_REMAINING_SECONDS
local CLIENT_CACHE_META_KEY = Const.CLIENT_KEY.CLIENT_CACHE_META
local OSS_RESOURCE_TYPE = "ClientInfo"
local INITIAL_VERSION = 1
local MISSING_VERSION = -1
local CLEAR_METADATA_VERSION = -2
local activePlayer, activeEntry
local activeOssStarted = true
local ossPutUrlCache = {}
local ossPutUrlTimeCache = {}
local lastOssPutUrlPrefetchAt = 0
local ossReadEntry
local packPayloadScratch = {}
local nextSaveAt = 0

function ClientCache.metric(name, entry, detail)
	return
end

function ClientCache.verify(category, event, detail, ...)
	if select("#", ...) > 0 then
		detail = string.format(detail, ...)
	end
end

function ClientCache.unpackPayload(raw)
	if not raw or raw == "" then
		return nil
	end

	local success, payload = pcall(msgpack.unpack_zstd, raw)

	if not success or type(payload) ~= "table" or type(payload.version) ~= "number" or payload.version <= 0 or payload.version ~= math.floor(payload.version) or type(payload.records) ~= "table" then
		return nil
	end

	return payload
end

function ClientCache.packPayload(version, records)
	packPayloadScratch.version = version
	packPayloadScratch.records = records

	local success, raw = pcall(msgpack.pack_zstd, packPayloadScratch)

	packPayloadScratch.version = nil
	packPayloadScratch.records = nil

	if not success or raw == "" then
		return nil
	end

	return raw
end

function ClientCache.objectKey(entry)
	return entry.uid .. "_" .. CACHE_PHYSICAL_KEY
end

function ClientCache.relativePath(entry)
	return "client_cache/" .. entry.uid .. "_" .. CACHE_PHYSICAL_KEY .. ".zst"
end

function ClientCache.clearDetached()
	local entry = activeEntry

	if activePlayer ~= nil or entry == nil then
		return false
	end

	activeEntry = nil
	activeOssStarted = true

	if entry.ossReadLocalVersion ~= nil then
		ClientCache.clearOssRead(entry)
	end

	entry.records = {}
	entry.dirtyCount = nil
	entry.localDirty = nil
	entry.versionReserved = nil
	entry.writeStarting = nil

	return true
end

function ClientCache.cacheOssPutUrl(entry, url)
	local now = Time.realtimeSinceStartup or 0

	for uid, cachedAt in pairs(ossPutUrlTimeCache) do
		if now - cachedAt >= OSS_PUT_URL_TTL_SECONDS then
			ossPutUrlCache[uid] = nil
			ossPutUrlTimeCache[uid] = nil
		end
	end

	local uid = entry.uid

	ossPutUrlCache[uid] = url
	ossPutUrlTimeCache[uid] = now
end

function ClientCache.getCachedOssPutUrl(entry)
	local uid = entry.uid
	local url = ossPutUrlCache[uid]
	local cachedAt = ossPutUrlTimeCache[uid]
	local now = Time.realtimeSinceStartup or 0

	if url == nil or cachedAt == nil then
		ossPutUrlCache[uid] = nil
		ossPutUrlTimeCache[uid] = nil

		return nil
	end

	local remaining = OSS_PUT_URL_TTL_SECONDS - (now - cachedAt)

	if remaining <= 0 then
		ossPutUrlCache[uid] = nil
		ossPutUrlTimeCache[uid] = nil

		return nil
	end

	return url
end

function ClientCache.onOssPutUrl(key, url, errorType, _, entry)
	if url ~= nil then
		ClientCache.cacheOssPutUrl(entry, url)

		return
	end
end

function ClientCache.prefetchOssPutUrl(entry)
	local uid = entry.uid
	local cachedAt = ossPutUrlTimeCache[uid]
	local now = Time.realtimeSinceStartup or 0

	if lastOssPutUrlPrefetchAt ~= 0 and now - lastOssPutUrlPrefetchAt < OSS_PUT_URL_MIN_REMAINING_SECONDS then
		return
	end

	local retryAfter = ossPutUrlCache[uid] and OSS_PUT_URL_REFRESH_AGE_SECONDS or OSS_PUT_URL_MIN_REMAINING_SECONDS

	if cachedAt ~= nil and retryAfter > now - cachedAt then
		return
	end

	lastOssPutUrlPrefetchAt = now

	local remaining = cachedAt and OSS_PUT_URL_TTL_SECONDS - (now - cachedAt) or nil

	ossPutUrlCache[uid] = nil
	ossPutUrlTimeCache[uid] = now

	local objectKey = ClientCache.objectKey(entry)
	local started, errorMessage = pcall(ClientUtils.requestBinaryResourcePutUrl, OSS_RESOURCE_TYPE, objectKey, ClientCache.onOssPutUrl, entry)
end

function ClientCache.cacheServiceOssPutUrl(entry, key, url, urlSource)
	if urlSource == "service" then
		ClientCache.cacheOssPutUrl(entry, url)
	end
end

function ClientCache.onOssPut(key, success, errorType, httpStatus, version)
	return
end

function ClientCache.startOssPut(entry, version, raw, useCachedUrl)
	local cachedUrl = (useCachedUrl or entry ~= activeEntry or activePlayer == nil) and ClientCache.getCachedOssPutUrl(entry) or nil
	local objectKey = ClientCache.objectKey(entry)

	pcall(ClientUtils.addBinaryResource, OSS_RESOURCE_TYPE, objectKey, raw, ClientCache.onOssPut, cachedUrl, ClientCache.cacheServiceOssPutUrl, entry, version)
end

function ClientCache.notifyReady(entry)
	local player = activePlayer

	if entry ~= activeEntry or player == nil then
		return
	end

	local success, err = pcall(player.onClientCacheReady, player)

	if not success then
		logger:error("ClientCache ready adapter failed: %s", tostring(err))
	end
end

function ClientCache.clearOssRead(entry)
	if ossReadEntry == entry then
		ossReadEntry = nil
	end

	entry.ossReadMetadataVersion = nil
	entry.ossReadLocalVersion = nil
end

function ClientCache.finishOssRead(entry, payload, raw)
	local metadataVersion = entry.ossReadMetadataVersion
	local localVersion = entry.ossReadLocalVersion
	local localRecords = localVersion > 0 and entry.records or nil
	local hasDirty = entry.dirtyCount ~= nil
	local ossVersion = payload and payload.version or MISSING_VERSION

	if metadataVersion == CLEAR_METADATA_VERSION then
		local clearVersion = math.max(0, localVersion, ossVersion) + 1
		local clearRecords = {}
		local clearRaw = ClientCache.packPayload(clearVersion, clearRecords)

		entry.records = clearRecords
		entry.version = clearVersion
		entry.dirtyCount = nil
		entry.localDirty = nil
		entry.versionReserved = nil
		entry.writeStarting = nil

		ClientCache.clearOssRead(entry)

		if clearRaw ~= nil then
			ClientCache.startWrites(entry, clearVersion, clearRaw)
			ClientCache.syncMetadataVersion(entry, clearVersion)
		end

		ClientCache.notifyReady(entry)

		return
	end

	local selectedSource, selectedVersion, selectedRecords, selectedRaw

	if localRecords == nil and payload == nil then
		selectedSource, selectedVersion, selectedRecords = "empty", INITIAL_VERSION, entry.records
	elseif metadataVersion == nil then
		selectedSource, selectedVersion, selectedRecords = "local", localVersion > 0 and localVersion or INITIAL_VERSION, entry.records
	elseif localRecords == nil then
		selectedSource, selectedVersion, selectedRecords, selectedRaw = "oss", payload.version, payload.records, raw
	elseif payload == nil or math.abs(localVersion - metadataVersion) <= math.abs(payload.version - metadataVersion) then
		selectedSource, selectedVersion, selectedRecords = "local", localVersion, localRecords
	else
		selectedSource, selectedVersion, selectedRecords, selectedRaw = "oss", payload.version, payload.records, raw
	end

	entry.records = selectedRecords
	entry.version = selectedVersion

	local keepDirty = hasDirty and selectedSource ~= "oss"

	ClientCache.clearOssRead(entry)

	if selectedSource == "oss" then
		ClientCache.stageLocalOnlyWrite(entry, selectedRaw)
	elseif keepDirty then
		entry.versionReserved = nil

		ClientCache.reserveDirtyVersion(entry)
	elseif selectedSource == "empty" then
		ClientCache.stageLocalOnlyWrite(entry, nil)
	elseif localVersion == MISSING_VERSION then
		local repairRaw = ClientCache.packPayload(selectedVersion, selectedRecords)

		if repairRaw ~= nil then
			ClientCache.startWrites(entry, selectedVersion, repairRaw)
		end
	elseif payload == nil or localVersion ~= ossVersion then
		local repairRaw = ClientCache.packPayload(localVersion, localRecords)

		if repairRaw ~= nil then
			ClientCache.startOssPut(entry, localVersion, repairRaw)
		end
	end

	if not keepDirty and entry.version ~= metadataVersion then
		ClientCache.syncMetadataVersion(entry, entry.version)
	end

	ClientCache.notifyReady(entry)
end

function ClientCache.onOssRead(key, data, errorType, httpStatus, entry, attempt)
	if entry ~= ossReadEntry then
		return
	end

	ossReadEntry = nil

	if errorType == nil then
		local payload = ClientCache.unpackPayload(data)

		ClientCache.finishOssRead(entry, payload, payload and data or nil)
	elseif errorType == "not_found" then
		ClientCache.finishOssRead(entry, nil, nil)
	elseif attempt >= MAX_OSS_READ_ATTEMPTS then
		ClientCache.finishOssRead(entry, nil, nil)
	else
		ClientCache.startOssRead(entry, attempt + 1)
	end
end

function ClientCache.startOssRead(entry, attempt)
	if entry.ossReadLocalVersion == nil or ossReadEntry ~= nil or entry ~= activeEntry or activePlayer == nil or not activeOssStarted then
		return
	end

	ossReadEntry = entry

	local objectKey = ClientCache.objectKey(entry)
	local started, err = pcall(ClientUtils.pullBinaryResource, OSS_RESOURCE_TYPE, objectKey, ClientCache.onOssRead, entry, attempt)

	if not started and ossReadEntry == entry then
		ClientCache.onOssRead(objectKey, nil, "network_error:" .. tostring(err), nil, entry, attempt)
	end
end

function ClientCache.startLocalWriteAsync(entry, raw)
	local relativePath = ClientCache.relativePath(entry)
	local started = pcall(AsyncFileWriter.WriteAsync, relativePath, raw)

	if not started then
		return
	end
end

function ClientCache.startWrites(entry, version, raw, useCachedUrl)
	if entry.writeStarting then
		return
	end

	entry.writeStarting = true

	ClientCache.startLocalWriteAsync(entry, raw)
	ClientCache.startOssPut(entry, version, raw, useCachedUrl)

	entry.writeStarting = nil
end

function ClientCache.stageLocalOnlyWrite(entry, raw)
	raw = raw or ClientCache.packPayload(entry.version, entry.records)

	if raw == nil then
		return
	end

	entry.dirtyCount = nil
	entry.localDirty = nil
	entry.versionReserved = nil

	ClientCache.startLocalWriteAsync(entry, raw)
end

function ClientCache.syncMetadataVersion(entry, version)
	local player = activePlayer

	if entry ~= activeEntry or player == nil then
		return
	end

	local success = player:setClientMetaVersion(version) == true

	if not success then
		logger:error("ClientCache metadata write failure observed, roleScope=%s", entry.uid)
	end
end

function ClientCache.reserveDirtyVersion(entry)
	if entry.dirtyCount == nil or entry.versionReserved then
		return
	end

	if entry.ossReadLocalVersion ~= nil then
		return
	end

	if entry.writeStarting then
		return
	end

	if entry ~= activeEntry or activePlayer == nil then
		return
	end

	local nextVersion = entry.version + 1

	entry.version = nextVersion
	entry.versionReserved = true

	ClientCache.syncMetadataVersion(entry, nextVersion)
end

function ClientCache.saveRemote(entry, useCachedUrl)
	local dirtyCandidate = entry.dirtyCount ~= nil

	if dirtyCandidate and not entry.versionReserved then
		ClientCache.reserveDirtyVersion(entry)
	end

	if dirtyCandidate and not entry.versionReserved then
		return nil
	end

	local candidateVersion = entry.version
	local raw = ClientCache.packPayload(candidateVersion, entry.records)

	if raw == nil then
		return nil
	end

	if dirtyCandidate then
		entry.dirtyCount = nil
		entry.localDirty = nil
		entry.versionReserved = nil
	end

	ClientCache.startWrites(entry, candidateVersion, raw, useCachedUrl)

	return true
end

function ClientCache.saveEntry(entry)
	if entry.ossReadLocalVersion ~= nil then
		return
	end

	if entry.dirtyCount == nil then
		return
	end

	ClientCache.saveRemote(entry)
end

function ClientCache.prepareEntryRead(entry, metadataVersion)
	if entry.ossReadLocalVersion ~= nil then
		ClientCache.clearOssRead(entry)
	end

	local relativePath = ClientCache.relativePath(entry)
	local readSuccess, diskRaw = pcall(AsyncFileWriter.ReadSync, relativePath)

	if not readSuccess then
		logger:error("ClientCache ReadSync failed, relativePath=%s error=%s", relativePath, tostring(diskRaw))

		diskRaw = nil
	end

	local diskPayload = ClientCache.unpackPayload(diskRaw)
	local localVersion = diskPayload and diskPayload.version or MISSING_VERSION

	entry.records = diskPayload and diskPayload.records or {}
	entry.version = localVersion > 0 and localVersion or INITIAL_VERSION
	entry.ossReadMetadataVersion = metadataVersion
	entry.ossReadLocalVersion = localVersion
end

function ClientCache.createEntry(uid, metadataVersion)
	local entry = {
		uid = uid,
		records = {},
		version = INITIAL_VERSION
	}

	ClientCache.prepareEntryRead(entry, metadataVersion)

	return entry
end

function ClientCache.tryStartActiveOss()
	local player = activePlayer
	local entry = activeEntry

	if player == nil or entry == nil then
		return
	end

	if not activeOssStarted then
		if GlobalData.LastBindExtraMsUid ~= player.uid and (ClientRepo.extraGlobalMsProxy ~= nil or GlobalData.LastBindMsUid ~= player.uid) then
			return
		end

		activeOssStarted = true

		ClientCache.prefetchOssPutUrl(entry)
	end

	if entry == activeEntry and entry.ossReadLocalVersion ~= nil and ossReadEntry == nil then
		ClientCache.startOssRead(entry, 1)
	end
end

function ClientCache.attach(player)
	lastOssPutUrlPrefetchAt = 0

	local uid = player.uid

	if player == activePlayer and activeEntry ~= nil then
		return player
	end

	local previousEntry = activeEntry

	activePlayer = nil
	activeOssStarted = true

	local metadataVersion = player:getClientMetaVersion()

	if previousEntry ~= nil and previousEntry.uid == uid and metadataVersion ~= CLEAR_METADATA_VERSION then
		if previousEntry.ossReadLocalVersion ~= nil then
			ClientCache.clearOssRead(previousEntry)
		end

		activePlayer = player
		activeOssStarted = true

		if previousEntry.dirtyCount ~= nil and not previousEntry.versionReserved then
			ClientCache.reserveDirtyVersion(previousEntry)

			metadataVersion = player:getClientMetaVersion()
		end

		if metadataVersion ~= previousEntry.version then
			ClientCache.syncMetadataVersion(previousEntry, previousEntry.version)
		end

		ClientCache.notifyReady(previousEntry)

		return player
	end

	local entry = ClientCache.createEntry(uid, metadataVersion)

	ClientCache.clearDetached()

	activePlayer = player
	activeEntry = entry
	activeOssStarted = false

	ClientCache.tryStartActiveOss()

	return player
end

function ClientCache.detach(player)
	if player ~= activePlayer then
		return false
	end

	lastOssPutUrlPrefetchAt = 0
	activePlayer = nil
	activeOssStarted = true

	return true
end

function ClientCache.isAttached(player)
	return activePlayer ~= nil and player == activePlayer
end

function ClientCache.get(clientKey, recordKey, defaultValue)
	local entry = activeEntry
	local clientRecords = entry.records[clientKey]

	if clientRecords == nil then
		return defaultValue
	end

	local value = clientRecords[recordKey]

	if value == nil then
		return defaultValue
	end

	return value
end

function ClientCache.getOrCreateTable(clientKey, recordKey)
	local records = activeEntry.records
	local clientRecords = records[clientKey]

	if clientRecords == nil then
		clientRecords = {}
		records[clientKey] = clientRecords
	end

	local value = clientRecords[recordKey]

	if value == nil then
		value = {}
		clientRecords[recordKey] = value
	end

	return value
end

function ClientCache.markMutation(entry)
	local wasRemoteDirty = entry.dirtyCount ~= nil
	local mutationCount = (entry.dirtyCount or 0) + 1

	entry.dirtyCount = mutationCount
	entry.localDirty = true

	if not wasRemoteDirty then
		ClientCache.reserveDirtyVersion(entry)
	end

	if mutationCount == MUTATION_SAVE_THRESHOLD then
		ClientCache.saveEntry(entry)
	elseif entry == activeEntry and activePlayer ~= nil and activeOssStarted then
		ClientCache.prefetchOssPutUrl(entry)
	end
end

function ClientCache.set(clientKey, recordKey, value, forceMutation)
	if value == nil then
		return ClientCache.delete(clientKey, recordKey)
	end

	local entry = activeEntry
	local clientRecords = entry.records[clientKey]

	if clientRecords == nil then
		clientRecords = {}
		entry.records[clientKey] = clientRecords
	end

	if clientRecords[recordKey] == value and not forceMutation then
		return true, false
	end

	clientRecords[recordKey] = value

	ClientCache.markMutation(entry)

	return true, true
end

function ClientCache.replace(clientKey, clientRecords)
	activeEntry.records[clientKey] = clientRecords

	ClientCache.markMutation(activeEntry)

	return true
end

function ClientCache.delete(clientKey, recordKey)
	local entry = activeEntry
	local clientRecords = entry.records[clientKey]

	if clientRecords == nil or clientRecords[recordKey] == nil then
		return true, false
	end

	clientRecords[recordKey] = nil

	if next(clientRecords) == nil then
		entry.records[clientKey] = nil
	end

	ClientCache.markMutation(entry)

	return true, true
end

function ClientCache.flushEntrySync(entry)
	if not entry.localDirty then
		return
	end

	local version = entry.version
	local raw = ClientCache.packPayload(version, entry.records)

	if raw == nil then
		return
	end

	entry.localDirty = nil

	local relativePath = ClientCache.relativePath(entry)

	pcall(AsyncFileWriter.WriteSync, relativePath, raw)
end

function ClientCache.flush(player)
	if player ~= activePlayer then
		return false
	end

	ClientCache.flushEntrySync(activeEntry)

	return true
end

function ClientCache.flushForAccountSwitch(player)
	if player ~= activePlayer then
		return false
	end

	local entry = activeEntry

	if entry.ossReadLocalVersion ~= nil then
		return false, "read_in_progress"
	end

	local started = ClientCache.saveRemote(entry, true) == true

	return started, started and "started" or "start_failed"
end

function ClientCache.flushActive()
	local entry = activeEntry

	if entry ~= nil then
		ClientCache.flushEntrySync(entry)
	end
end

function ClientCache.update()
	ClientCache.tryStartActiveOss()

	local now = Time.realtimeSinceStartup or 0

	if now < nextSaveAt then
		return
	end

	nextSaveAt = now + SAVE_INTERVAL_SECONDS

	if activeEntry ~= nil then
		ClientCache.saveEntry(activeEntry)
	end
end

return ClientCache
