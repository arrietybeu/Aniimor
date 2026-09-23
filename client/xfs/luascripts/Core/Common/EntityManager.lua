-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\EntityManager.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("EntityManager")
local Events = require("Common.Container.Events")
local EventConst = require("Const.EventConst")
local EntityManager = {}

EntityManager.eventEmitter = Events.new()
EntityManager._entities = {}
EntityManager._uidEntities = {}
EntityManager._entityType = {
	Player = {},
	Puppet = {},
	EnvObject = {},
	Pet = {},
	SimpleMoveNpc = {},
	StaticNpc = {}
}
EntityManager._entityTypeCount = {
	EnvObject = 0,
	Puppet = 0,
	Player = 0,
	StaticNpc = 0,
	SimpleMoveNpc = 0,
	Pet = 0
}
EntityManager._entityType2ServerEntityType = {
	ClientEnvObject = "EnvObject",
	ClientPuppet = "Puppet",
	ClientPlayer = "Player",
	ClientStaticNpc = "StaticNpc",
	ClientSimpleMoveNpc = "SimpleMoveNpc",
	ClientPet = "Pet"
}

function EntityManager.destroyRepeatedEntity(entity)
	if entity.isClientEnt ~= nil then
		local ClientUtils = require("Utils.ClientUtils")

		ClientUtils.safeDestroy(entity, true)
	else
		entity:destroy()
	end
end

function EntityManager.addEntity(entityId, entity)
	local e = EntityManager._entities[entityId]

	if e ~= nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("add entity %s repeated", entityId)
		end

		EntityManager.destroyRepeatedEntity(e)
	end

	if entityId == "" or entityId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("add entity %s, but entityId is empty, trace: %s", entityId, debug.traceback())
		end

		return
	end

	EntityManager._entities[entityId] = entity

	EntityManager._addEntityByType(entityId, entity)
	EntityManager.eventEmitter:emit(EventConst.ENTITY_ADD, entityId, entity)
end

function EntityManager.removeEntity(entityId)
	if EntityManager._entities[entityId] == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("remove entity %s, but not found", entityId)
	end

	EntityManager._removeEntityByType(entityId)

	local entity = EntityManager._entities[entityId]

	EntityManager._watchDestroyedEntity(entity)

	EntityManager._entities[entityId] = nil

	EntityManager.eventEmitter:emit(EventConst.ENTITY_REMOVE, entityId, entity and entity.staticId)
end

function EntityManager._addEntityByType(entityId, entity)
	local className = entity.className
	local serverClassName = EntityManager._entityType2ServerEntityType[className]

	if serverClassName ~= nil then
		className = serverClassName
	end

	local entityTypeMap = EntityManager._entityType[className]

	if entityTypeMap ~= nil then
		entityTypeMap[entityId] = entity
		EntityManager._entityTypeCount[className] = EntityManager._entityTypeCount[className] + 1
	end
end

function EntityManager._removeEntityByType(entityId)
	local entity = EntityManager._entities[entityId]

	if entity == nil then
		return
	end

	local className = entity.className
	local serverClassName = EntityManager._entityType2ServerEntityType[className]

	if serverClassName ~= nil then
		className = serverClassName
	end

	local entityTypeMap = EntityManager._entityType[className]

	if entityTypeMap ~= nil then
		entityTypeMap[entityId] = nil
		EntityManager._entityTypeCount[className] = EntityManager._entityTypeCount[className] - 1
	end
end

function EntityManager.getEntity(entityId)
	return EntityManager._entities[entityId]
end

function EntityManager.addUidEntity(uid, entity)
	local e = EntityManager._uidEntities[uid]

	if e ~= nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("add entity %s repeated", uid)
		end

		EntityManager.destroyRepeatedEntity(e)
	end

	if uid == "" or uid == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("add entity %s, but uid is empty", uid)
		end

		return
	end

	EntityManager._uidEntities[uid] = entity
end

function EntityManager.removeUidEntity(uid)
	if EntityManager._uidEntities[uid] == nil and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("remove entity %s, but not found", uid)
	end

	EntityManager._uidEntities[uid] = nil
end

function EntityManager.getEntityByUid(uid)
	return EntityManager._uidEntities[uid]
end

function EntityManager.getAllEntities()
	return EntityManager._entities
end

function EntityManager.getAllPlayers()
	return EntityManager._entityType.Player
end

function EntityManager.getEntitiesByType(className)
	return EntityManager._entityType[className]
end

function EntityManager.getEntityCountByType(className)
	return EntityManager._entityTypeCount[className]
end

function EntityManager.getOnlinePlayerCount()
	return EntityManager._entityTypeCount.Player
end

function EntityManager.isEmpty()
	return next(EntityManager._entities) == nil
end

function EntityManager.getPlayerByUid(uid)
	local players = EntityManager.getAllPlayers()

	for _, player in pairs(players) do
		if player.uid == uid then
			return player
		end
	end
end

function EntityManager.callMethod(methodName, ...)
	local ents = EntityManager._entities
	local num = select("#", ...)

	for _, entity in pairs(ents) do
		if not entity.destroyed and entity[methodName] ~= nil then
			if num == 0 then
				entity[methodName](entity)
			else
				entity[methodName](entity, ...)
			end
		end
	end
end

function EntityManager.profileEntityCount()
	local ents = EntityManager._entities
	local entCounts = {}
	local count = 0
	local entClass

	for _, entity in pairs(ents) do
		if entity then
			count = count + 1
			entClass = entity:getClassType()

			if entCounts[entClass] == nil then
				entCounts[entClass] = 1
			else
				entCounts[entClass] = entCounts[entClass] + 1
			end
		end
	end

	entCounts.all = count

	return entCounts
end

local function createLeakWatchRecords()
	return setmetatable({}, {
		__mode = "k"
	})
end

local _leakWatchRecords = createLeakWatchRecords()

EntityManager.leakWatchRecords = _leakWatchRecords

local _leakWatchNextId = 0
local _leakWatchRecordCount = 0
local _leakWatchDroppedCount = 0
local _leakWatchNextRecountTickSeconds = 0
local _leakWatchOptions = {
	dumpRecordLimit = 200,
	forceGc = true,
	graceSeconds = 300,
	recountIntervalSeconds = 60,
	maxRecords = 10000
}

local function countLeakWatchRecords()
	local count = 0

	for _ in next, _leakWatchRecords do
		count = count + 1
	end

	return count
end

function EntityManager._nextLeakWatchId()
	_leakWatchNextId = _leakWatchNextId + 1

	return _leakWatchNextId
end

function EntityManager._watchDestroyedEntity(entity)
	if entity == nil or entity.destroyed ~= true or _leakWatchRecords[entity] ~= nil then
		return
	end

	local Time = require("Core.Common.Time")
	local now = Time.getTickSecond()

	if _leakWatchRecordCount >= _leakWatchOptions.maxRecords then
		if now >= _leakWatchNextRecountTickSeconds then
			_leakWatchRecordCount = countLeakWatchRecords()
			_leakWatchNextRecountTickSeconds = now + _leakWatchOptions.recountIntervalSeconds
		end

		if _leakWatchRecordCount >= _leakWatchOptions.maxRecords then
			_leakWatchDroppedCount = _leakWatchDroppedCount + 1

			return
		end
	end

	local watchId = EntityManager._nextLeakWatchId()
	local meta = {
		watchId = watchId,
		destroyTickSeconds = now
	}

	_leakWatchRecords[entity] = meta
	_leakWatchRecordCount = _leakWatchRecordCount + 1
end

local function dumpDestroyedEntityReferences(dumpEntities)
	if #dumpEntities == 0 then
		return false, "empty_dump_entities"
	end

	local dumpTargets = {}

	for i, info in ipairs(dumpEntities) do
		local entity = info.entity
		local meta = info.meta

		dumpTargets[i] = {
			object = entity,
			objectName = string.format("EntityLeak_%s_%s_%s", entity:getClassType(), entity.id, meta.watchId)
		}
	end

	local MemoryReferenceStringInfo = require("Core.Profiler.MemoryReferenceStringInfo")
	local dumpOk, referenceInfos = pcall(MemoryReferenceStringInfo.DumpMemorySnapshotObjects, _leakWatchOptions.dumpRecordLimit or 200, dumpTargets)

	if not dumpOk then
		logger:error("[EntityLeakWatch] dump references failed targetCount=%s err=%s", #dumpTargets, referenceInfos)

		return false, tostring(referenceInfos)
	end

	for i, info in ipairs(dumpEntities) do
		local entity = info.entity
		local meta = info.meta

		logger:error("[EntityLeakWatch] dump reference watchId=%s entityId=%s class=%s\n%s", meta.watchId, entity.id, entity:getClassType(), referenceInfos[i])
	end

	return true
end

function EntityManager.checkDestroyedEntityLeak(graceSeconds)
	local options = _leakWatchOptions
	local onlinePlayers = EntityManager.getOnlinePlayerCount() or 0

	if onlinePlayers > 0 then
		logger:warn("[EntityLeakWatch] check ignored because players are online, count=%s", onlinePlayers)

		return {}
	end

	graceSeconds = tonumber(graceSeconds)

	if graceSeconds == nil then
		graceSeconds = options.graceSeconds
	else
		graceSeconds = math.max(graceSeconds, 0)
	end

	logger:info("[EntityLeakWatch] manual check started graceSeconds=%s", graceSeconds)

	if options.forceGc then
		collectgarbage("collect")
		collectgarbage("collect")
	end

	local Time = require("Core.Common.Time")
	local now = Time.getTickSecond()
	local tracked = 0
	local total = 0
	local byClass = {}
	local oldestLeakedEntityByClass = {}

	for entity, meta in next, _leakWatchRecords do
		tracked = tracked + 1

		local destroyedAgoSeconds = now - (meta.destroyTickSeconds or now)

		if entity.destroyed == true and graceSeconds <= destroyedAgoSeconds then
			local className = entity:getClassType()

			total = total + 1
			byClass[className] = (byClass[className] or 0) + 1

			local oldestInfo = oldestLeakedEntityByClass[className]

			if oldestInfo == nil or destroyedAgoSeconds > oldestInfo.destroyedAgoSeconds then
				oldestLeakedEntityByClass[className] = {
					entity = entity,
					meta = meta,
					destroyedAgoSeconds = destroyedAgoSeconds
				}
			end
		end
	end

	_leakWatchRecordCount = tracked

	local dumpEntities = {}

	for _, info in pairs(oldestLeakedEntityByClass) do
		dumpEntities[#dumpEntities + 1] = info
	end

	table.sort(dumpEntities, function(first, second)
		return first.entity:getClassType() < second.entity:getClassType()
	end)

	if total > 0 then
		logger:error("[EntityLeakWatch] destroyed entity still alive, total=%s tracked=%s dropped=%s dumpCandidates=%s luaMemKB=%s", total, tracked, _leakWatchDroppedCount, #dumpEntities, collectgarbage("count"))

		for className, count in pairs(byClass) do
			logger:error("[EntityLeakWatch] class=%s count=%s", className, count)
		end
	end

	return dumpEntities
end

function EntityManager.dumpDestroyedEntityLeak(dumpEntity)
	if type(dumpEntity) ~= "table" or type(dumpEntity.entity) ~= "table" or type(dumpEntity.meta) ~= "table" then
		return false, "invalid_dump_entity"
	end

	local entity = dumpEntity.entity
	local meta = dumpEntity.meta

	if entity.destroyed ~= true then
		return false, "entity_not_destroyed"
	end

	if _leakWatchRecords[entity] ~= meta then
		return false, "stale_dump_entity"
	end

	local success, errorMessage = dumpDestroyedEntityReferences({
		dumpEntity
	})

	if success then
		logger:error("[EntityLeakWatch] entity alive class=%s entityId=%s watchId=%s destroyedAgoSeconds=%s", entity:getClassType(), entity.id, meta.watchId, dumpEntity.destroyedAgoSeconds)
	end

	return success, errorMessage
end

function EntityManager.checkAndDumpDestroyedEntityLeak(graceSeconds)
	local dumpEntities = EntityManager.checkDestroyedEntityLeak(graceSeconds)

	for _, dumpEntity in ipairs(dumpEntities) do
		local success, errorMessage = EntityManager.dumpDestroyedEntityLeak(dumpEntity)

		if not success then
			local entity = dumpEntity.entity
			local meta = dumpEntity.meta or {}

			logger:error("[EntityLeakWatch] dump entity failed watchId=%s entityId=%s class=%s err=%s", meta.watchId, entity.id, entity:getClassType(), errorMessage)
		end
	end

	return dumpEntities
end

function EntityManager.getEntityLeakWatchStatus()
	local tracked = countLeakWatchRecords()

	_leakWatchRecordCount = tracked

	return {
		tracked = tracked,
		maxRecords = _leakWatchOptions.maxRecords,
		dropped = _leakWatchDroppedCount,
		recountIntervalSeconds = _leakWatchOptions.recountIntervalSeconds,
		graceSeconds = _leakWatchOptions.graceSeconds,
		forceGc = _leakWatchOptions.forceGc,
		dumpRecordLimit = _leakWatchOptions.dumpRecordLimit
	}
end

return EntityManager
