-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Etcd\\ProcessInfo.lua

local json = require("json")
local base64 = require("base64")
local class = require("Core.Framework.Class")
local StringEx = require("Core.Framework.String")
local GameServerRepo = require("Core.Server.GameServerRepo")
local ProcessInfo = class.Class("ProcessInfo")

ProcessInfo.PROCESS_KIND_ENGINE = "ENGINE"
ProcessInfo.PROCESS_KIND_SERVICE = "SERVICE"
ProcessInfo.PROCESS_KIND_CONFIG = "CONFIG"
ProcessInfo.PROCESS_KIND_SHARD = "SHARD"
ProcessInfo.ValidProcessKind = {}
ProcessInfo.ValidProcessKind[ProcessInfo.PROCESS_KIND_ENGINE] = 1
ProcessInfo.ValidProcessKind[ProcessInfo.PROCESS_KIND_SERVICE] = 2
ProcessInfo.ValidProcessKind[ProcessInfo.PROCESS_KIND_CONFIG] = 3
ProcessInfo.ValidProcessKind[ProcessInfo.PROCESS_KIND_SHARD] = 4
ProcessInfo.PROCESS_TYPE_GATE = "GATE"
ProcessInfo.PROCESS_TYPE_GAME = "GAME"
ProcessInfo.PROCESS_TYPE_DB = "DB"
ProcessInfo.PROCESS_TYPE_CLUSTERMANAGER = "CLUSTERMANAGER"
ProcessInfo.PROCESS_TYPE_HUB = "HUB"
ProcessInfo.PROCESS_TYPE_HUBPROXY = "HUBPROXY"
ProcessInfo.PROCESS_TYPE_SERVICEPROBE = "SERVICEPROBE"
ProcessInfo.ValidProcessType = {}
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_GATE] = 0
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_GAME] = 1
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_DB] = 2
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_CLUSTERMANAGER] = 3
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_HUB] = 4
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_HUBPROXY] = 5
ProcessInfo.ValidProcessType[ProcessInfo.PROCESS_TYPE_SERVICEPROBE] = 6
ProcessInfo.GLOBAL_KEY = "GLOBAL"

function ProcessInfo:ctor(namespace, processKind, processType, pid, ip, port, clusterId, entities, source, createVersion)
	assert(ProcessInfo.ValidProcessKind[processKind] ~= nil)

	if processKind == ProcessInfo.PROCESS_KIND_ENGINE then
		assert(ProcessInfo.ValidProcessType[processType] ~= nil)
	end

	self.namespace = namespace
	self.processKind = processKind
	self.processType = processType
	self.pid = pid
	self.ip = ip
	self.port = port
	self.clusterId = clusterId
	self.entities = entities or {}
	self.source = source
	self.createVersion = createVersion
	self.metadata = {}
end

function ProcessInfo:dump()
	local metadata = self.metadata or {}

	metadata.entities = self.entities
	metadata.name = GameServerRepo.gameServerDiscoveryName

	local res = {
		self.ip,
		self.port,
		self.clusterId,
		metadata
	}

	return GameServerRepo.protoCodec:encode(res)
end

function ProcessInfo:addEntity(name, entityMeta)
	self.entities[name] = entityMeta
end

function ProcessInfo:removeEntity(name)
	if self.entities[name] == nil then
		return false
	end

	self.entities[name] = nil

	return true
end

function ProcessInfo:hasEntity(name)
	return self.entities[name] ~= nil
end

function ProcessInfo:isSame(other)
	if self.pid == other.pid and self.ip == other.ip and self.port == other.port and self.clusterId == other.clusterId then
		return true
	end

	return false
end

function ProcessInfo:repr()
	return string.format("ProcessInfo (%s, %s, %s, %s)", self:toString(), self.namespace, self.processType, self.pid)
end

function ProcessInfo.newProcessInfoFromRangeInfo(rangeInfo, source)
	local key = rangeInfo[1]
	local namespace, processKind, processType, pid = ProcessInfo.parseKey(key)

	assert(namespace ~= nil)
	assert(processType ~= nil)
	assert(pid ~= nil)
	assert(ProcessInfo.ValidProcessKind[processKind] ~= nil)

	if processKind == ProcessInfo.PROCESS_KIND_ENGINE then
		assert(ProcessInfo.ValidProcessType[processType] ~= nil)
	end

	local value = GameServerRepo.protoCodec:decode(rangeInfo[2])

	assert(#value == 3 or #value == 4)

	if #value == 4 then
		local metadata = value[4]

		return ProcessInfo(namespace, processKind, processType, pid, value[1], value[2], value[3], metadata.entities, source, rangeInfo[3])
	elseif #value == 3 then
		return ProcessInfo(namespace, processKind, processType, pid, value[1], value[2], value[3], nil, source, rangeInfo[3])
	else
		return nil
	end
end

function ProcessInfo.newProcessInfoFromEvent(event, source)
	local namespace, processKind, processType, pid = ProcessInfo.parseKey(event[2])

	assert(namespace ~= nil)
	assert(processType ~= nil)
	assert(pid ~= nil)
	assert(ProcessInfo.ValidProcessKind[processKind] ~= nil)

	if processKind == ProcessInfo.PROCESS_KIND_ENGINE then
		assert(ProcessInfo.ValidProcessType[processType] ~= nil)
	end

	local value = GameServerRepo.protoCodec:decode(event[3])

	assert(#value == 3 or #value == 4)

	if #value == 4 then
		local metadata = value[4]

		return ProcessInfo(namespace, processKind, processType, pid, value[1], value[2], value[3], metadata.entities, source, event[4])
	elseif #value == 3 then
		return ProcessInfo(namespace, processKind, processType, pid, value[1], value[2], value[3], nil, source, event[4])
	else
		return nil
	end
end

function ProcessInfo.parseKey(key)
	return unpack(StringEx.split(key, "/"))
end

return ProcessInfo
