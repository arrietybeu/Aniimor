-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ecs\\EcsSyncExchange.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local StateSchema = require("Common.Ecs.EcsSyncStateSchema")
local logger = LoggerManager.getLogger("EcsSyncExchange")
local EcsSyncExchange = Class.LightClass("EcsSyncExchange")
local SCHEMA_VERSION = StateSchema.VERSION
local DEFAULT_CAPACITY = 512
local HEADER_SIZE = 8
local HEADER_SCHEMA = 1
local HEADER_GENERATION = 2
local HEADER_WRITE_SEQ = 3
local HEADER_READ_SEQ = 4
local HEADER_CAPACITY = 5
local HEADER_OVERFLOW = 6
local HEADER_STATE_LAYOUT_FINGERPRINT = 7
local HEADER_RESERVED = 8
local COMMAND_STRIDE = 22
local COMMAND_TYPE = 0
local COMMAND_LOCAL_ID = 1
local COMMAND_SYNC_ID = 2
local COMMAND_PART_ID = 3
local COMMAND_VERSION = 4
local COMMAND_STATE = 5
local COMMAND_FLAG_0 = 20
local COMMAND_FLAG_1 = 21
local EVENT_STRIDE = 20
local EVENT_TYPE = 0
local EVENT_SYNC_ID = 1
local EVENT_PART_ID = 2
local EVENT_AUTHORITY_VERSION = 3
local EVENT_STATE = 4
local EVENT_IMMEDIATE = 19
local EVENT_PENDING_UPLOAD = 1
local EVENT_AUTHORITY_READY = 2
local COMMAND_REGISTER_SYNC_OBJECT = 1
local COMMAND_QUEUE_SERVER_STATE = 2
local COMMAND_APPLY_REMOVE = 3
local COMMAND_SET_PAUSED = 4
local COMMAND_AUTHORITY_READY_BARRIER = 5
local MAX_SEQUENCE = 2147483647
local UINT32_MODULUS = 4294967296

local function initializeHeader(array, generation, capacity)
	array[HEADER_SCHEMA] = SCHEMA_VERSION
	array[HEADER_GENERATION] = generation
	array[HEADER_WRITE_SEQ] = 0
	array[HEADER_READ_SEQ] = 0
	array[HEADER_CAPACITY] = capacity
	array[HEADER_OVERFLOW] = 0
	array[HEADER_STATE_LAYOUT_FINGERPRINT] = StateSchema.LAYOUT_FINGERPRINT
	array[HEADER_RESERVED] = 0
end

local function recordStart(sequence, capacity, stride)
	return HEADER_SIZE + (sequence - 1) % capacity * stride + 1
end

local function backlogRecordStart(recordIndex)
	return (recordIndex - 1) * COMMAND_STRIDE + 1
end

local function decodeUInt32(value)
	if value < 0 then
		return value + UINT32_MODULUS
	end

	return value
end

local function writeCommandRecord(array, start, commandType, localId, syncId, partId, version, state, flag0, flag1, fillUnusedState)
	array[start + COMMAND_TYPE] = commandType
	array[start + COMMAND_LOCAL_ID] = localId or 0
	array[start + COMMAND_SYNC_ID] = syncId or 0
	array[start + COMMAND_PART_ID] = partId or 0
	array[start + COMMAND_VERSION] = version or 0

	if state then
		StateSchema.writeFlat(array, start + COMMAND_STATE, state)
	elseif fillUnusedState then
		for offset = 0, StateSchema.FLAT_FIELD_COUNT - 1 do
			array[start + COMMAND_STATE + offset] = 0
		end
	end

	array[start + COMMAND_FLAG_0] = flag0 and 1 or 0
	array[start + COMMAND_FLAG_1] = flag1 and 1 or 0
end

function EcsSyncExchange:ctor(capacity)
	self.capacity = capacity or DEFAULT_CAPACITY
	self.generation = 1
	self.commandArray = LuaCSharpArr.New(HEADER_SIZE + self.capacity * COMMAND_STRIDE, 0)
	self.eventArray = LuaCSharpArr.New(HEADER_SIZE + self.capacity * EVENT_STRIDE, 0)
	self.commandBacklog = {}
	self.commandBacklogRead = 1
	self.commandBacklogWrite = 0
	self.bound = false

	initializeHeader(self.commandArray, self.generation, self.capacity)
	initializeHeader(self.eventArray, self.generation, self.capacity)
end

function EcsSyncExchange:bind()
	if self.bound then
		return true
	end

	local commandAccess = self.commandArray:GetCSharpAccess()
	local eventAccess = self.eventArray:GetCSharpAccess()
	local ok, result = pcall(function()
		return appFacade.ecsMgr:BindEcsSyncExchange(commandAccess, eventAccess)
	end)

	self.bound = ok and result == true

	if not self.bound then
		logger:error("共享交换区绑定失败，ECS 同步不可用；请确认已重新生成 XLua：%s", tostring(result))
	end

	return self.bound
end

function EcsSyncExchange:destroy()
	if self.bound and appFacade.ecsMgr then
		local ok, err = pcall(function()
			appFacade.ecsMgr:UnbindEcsSyncExchange()
		end)

		if not ok then
			logger:warn("解绑共享交换区失败：%s", tostring(err))
		end
	end

	self.bound = false

	self.commandArray:DestroyCSharpAccess()
	self.eventArray:DestroyCSharpAccess()
end

function EcsSyncExchange:resetGeneration()
	self.generation = self.generation + 1

	if self.generation >= MAX_SEQUENCE then
		self.generation = 1
	end

	self.commandBacklog = {}
	self.commandBacklogRead = 1
	self.commandBacklogWrite = 0

	initializeHeader(self.commandArray, self.generation, self.capacity)
	initializeHeader(self.eventArray, self.generation, self.capacity)
end

function EcsSyncExchange:isEnabled()
	return self.bound
end

function EcsSyncExchange:_hasBacklog()
	return self.commandBacklogRead <= self.commandBacklogWrite
end

function EcsSyncExchange:getBacklogDepth()
	if not self:_hasBacklog() then
		return 0
	end

	return self.commandBacklogWrite - self.commandBacklogRead + 1
end

function EcsSyncExchange:getPendingEventDepth()
	if not self.bound then
		return 0
	end

	local array = self.eventArray

	if array[HEADER_SCHEMA] ~= SCHEMA_VERSION or array[HEADER_GENERATION] ~= self.generation then
		return 0
	end

	return math.max(0, array[HEADER_WRITE_SEQ] - array[HEADER_READ_SEQ])
end

function EcsSyncExchange:hasPendingEvents()
	return self:getPendingEventDepth() > 0
end

function EcsSyncExchange:_tryBeginCommand()
	local writeSequence = self.commandArray[HEADER_WRITE_SEQ]
	local readSequence = self.commandArray[HEADER_READ_SEQ]

	if writeSequence - readSequence >= self.capacity or writeSequence >= MAX_SEQUENCE then
		return
	end

	local sequence = writeSequence + 1

	return sequence, recordStart(sequence, self.capacity, COMMAND_STRIDE)
end

function EcsSyncExchange:_commitCommand(sequence)
	self.commandArray[HEADER_WRITE_SEQ] = sequence
end

function EcsSyncExchange:_recordOverflow()
	local count = self.commandArray[HEADER_OVERFLOW] + 1

	self.commandArray[HEADER_OVERFLOW] = count

	if count == 1 or count % self.capacity == 0 then
		logger:warn("Lua→C# 交换区满，命令进入 backlog overflow=%s backlog=%s", count, self:getBacklogDepth())
	end
end

function EcsSyncExchange:_appendBacklog(commandType, localId, syncId, partId, version, state, flag0, flag1)
	self.commandBacklogWrite = self.commandBacklogWrite + 1

	writeCommandRecord(self.commandBacklog, backlogRecordStart(self.commandBacklogWrite), commandType, localId, syncId, partId, version, state, flag0, flag1, true)
	self:_recordOverflow()

	return true
end

function EcsSyncExchange:_submit(commandType, localId, syncId, partId, version, state, flag0, flag1)
	if not self.bound then
		return false
	end

	self:flushCommands()

	if not self:_hasBacklog() then
		local sequence, start = self:_tryBeginCommand()

		if sequence then
			writeCommandRecord(self.commandArray, start, commandType, localId, syncId, partId, version, state, flag0, flag1)
			self:_commitCommand(sequence)

			return true
		end
	end

	return self:_appendBacklog(commandType, localId, syncId, partId, version, state, flag0, flag1)
end

function EcsSyncExchange:registerSyncObject(legacyKey, syncId, authorityVersion)
	return self:_submit(COMMAND_REGISTER_SYNC_OBJECT, legacyKey, syncId, nil, authorityVersion)
end

function EcsSyncExchange:queueServerState(localId, syncId, partId, serverState, forceApply)
	return self:_submit(COMMAND_QUEUE_SERVER_STATE, localId, syncId, partId, serverState.serverVersion, serverState, forceApply == true)
end

function EcsSyncExchange:applyRemove(syncId, partId)
	return self:_submit(COMMAND_APPLY_REMOVE, nil, syncId, partId)
end

function EcsSyncExchange:setSimulationPaused(syncId, paused, resumeAuthority)
	return self:_submit(COMMAND_SET_PAUSED, nil, syncId, nil, nil, nil, paused, resumeAuthority)
end

function EcsSyncExchange:setAuthorityReadyBarrier(syncId, authorityVersion)
	return self:_submit(COMMAND_AUTHORITY_READY_BARRIER, nil, syncId, nil, authorityVersion)
end

function EcsSyncExchange:flushCommands()
	if not self.bound or not self:_hasBacklog() then
		return 0
	end

	local flushed = 0

	while self:_hasBacklog() do
		local sequence, start = self:_tryBeginCommand()

		if not sequence then
			break
		end

		local backlogStart = backlogRecordStart(self.commandBacklogRead)

		for offset = 0, COMMAND_STRIDE - 1 do
			self.commandArray[start + offset] = self.commandBacklog[backlogStart + offset]
			self.commandBacklog[backlogStart + offset] = nil
		end

		self.commandBacklogRead = self.commandBacklogRead + 1

		self:_commitCommand(sequence)

		flushed = flushed + 1
	end

	if not self:_hasBacklog() then
		self.commandBacklog = {}
		self.commandBacklogRead = 1
		self.commandBacklogWrite = 0
	end

	return flushed
end

function EcsSyncExchange:consumeEvents(consumer)
	if not self:hasPendingEvents() then
		return false
	end

	local array = self.eventArray
	local readSequence = array[HEADER_READ_SEQ]
	local writeSequence = array[HEADER_WRITE_SEQ]
	local hasImmediate = false

	while readSequence < writeSequence do
		local sequence = readSequence + 1
		local start = recordStart(sequence, self.capacity, EVENT_STRIDE)
		local eventType = array[start + EVENT_TYPE]

		if eventType == EVENT_PENDING_UPLOAD then
			consumer:_consumeExchangePendingState(array, start)

			hasImmediate = hasImmediate or array[start + EVENT_IMMEDIATE] ~= 0
		elseif eventType == EVENT_AUTHORITY_READY then
			consumer:_consumeExchangeAuthorityReady(decodeUInt32(array[start + EVENT_SYNC_ID]), decodeUInt32(array[start + EVENT_AUTHORITY_VERSION]))
		else
			logger:error("未知 ECS 交换区事件 type=%s", tostring(eventType))
		end

		readSequence = sequence
		array[HEADER_READ_SEQ] = readSequence
	end

	return hasImmediate
end

EcsSyncExchange.decodeUInt32 = decodeUInt32
EcsSyncExchange.EVENT_SYNC_ID = EVENT_SYNC_ID
EcsSyncExchange.EVENT_PART_ID = EVENT_PART_ID
EcsSyncExchange.EVENT_AUTHORITY_VERSION = EVENT_AUTHORITY_VERSION
EcsSyncExchange.EVENT_STATE = EVENT_STATE
EcsSyncExchange.EVENT_IMMEDIATE = EVENT_IMMEDIATE

return EcsSyncExchange
