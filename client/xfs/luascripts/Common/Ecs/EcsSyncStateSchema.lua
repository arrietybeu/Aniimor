-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ecs\\EcsSyncStateSchema.lua

local EcsSyncStateSchema = {}

EcsSyncStateSchema.VERSION = 4
EcsSyncStateSchema.ELEMENT_COUNT = 6
EcsSyncStateSchema.FLAT_FIELD_COUNT = 15
EcsSyncStateSchema.MAX_UINT8 = 255
EcsSyncStateSchema.MAX_UINT16 = 65535
EcsSyncStateSchema.MAX_UINT32 = 4294967295
EcsSyncStateSchema.STATE_MASK = 15
EcsSyncStateSchema.ELEMENT_MASK = 63
EcsSyncStateSchema.MAX_EXPLOSION_TYPE = 5
EcsSyncStateSchema.MAX_LEGACY_KEY = 17179869183
EcsSyncStateSchema.MAX_SAFE_INTEGER = 9007199254740991
EcsSyncStateSchema.MAX_BATCH_STATES = 128
EcsSyncStateSchema.MAX_AUTHORITY_READY_PER_BATCH = 128
EcsSyncStateSchema.MAX_BUFF_CHANGES_PER_BATCH = 128
EcsSyncStateSchema.MAX_FULL_STATE_SYNC_IDS = 128
EcsSyncStateSchema.MAX_REMOVE_INFOS_PER_PUSH = 128
EcsSyncStateSchema.REMOVE_RETENTION_SECONDS = 60

local SCALAR_FIELDS = {
	{
		min = 0,
		name = "state",
		max = EcsSyncStateSchema.STATE_MASK
	},
	{
		min = 0,
		appendElements = true,
		name = "elementMask",
		max = EcsSyncStateSchema.ELEMENT_MASK
	},
	{
		name = "hasBattery",
		boolean = true
	},
	{
		min = 0,
		name = "battery",
		max = EcsSyncStateSchema.MAX_UINT16
	},
	{
		name = "hasExplosive",
		boolean = true
	},
	{
		min = 0,
		name = "explosionType",
		max = EcsSyncStateSchema.MAX_EXPLOSION_TYPE
	},
	{
		min = 0,
		unsigned = true,
		name = "explosionSequence",
		max = EcsSyncStateSchema.MAX_UINT32
	},
	{
		min = 0,
		unsigned = true,
		name = "explosionRemainingMs",
		max = EcsSyncStateSchema.MAX_UINT32
	},
	{
		min = 0,
		unsigned = true,
		name = "explosionCooldownRemainingMs",
		max = EcsSyncStateSchema.MAX_UINT32
	}
}
local FLAT_FIELDS = {
	{
		name = "state",
		min = SCALAR_FIELDS[1].min,
		max = SCALAR_FIELDS[1].max
	},
	{
		name = "elementMask",
		min = SCALAR_FIELDS[2].min,
		max = SCALAR_FIELDS[2].max
	}
}

for index = 1, EcsSyncStateSchema.ELEMENT_COUNT do
	FLAT_FIELDS[#FLAT_FIELDS + 1] = {
		min = 0,
		name = "elements",
		index = index,
		max = EcsSyncStateSchema.MAX_UINT16
	}
end

for index = 3, #SCALAR_FIELDS do
	local field = SCALAR_FIELDS[index]

	FLAT_FIELDS[#FLAT_FIELDS + 1] = {
		name = field.name,
		boolean = field.boolean,
		unsigned = field.unsigned,
		min = field.min,
		max = field.max
	}
end

local FLAT_OFFSETS = {}
local LAYOUT_FINGERPRINT_MODULUS = 2147483647
local layoutFingerprint = 17

local function appendLayoutFingerprint(value)
	layoutFingerprint = (layoutFingerprint * 131 + value) % LAYOUT_FINGERPRINT_MODULUS
end

appendLayoutFingerprint(EcsSyncStateSchema.VERSION)

for ordinal, field in ipairs(FLAT_FIELDS) do
	local key = field.index and field.name .. tostring(field.index) or field.name
	local offset = ordinal - 1

	FLAT_OFFSETS[key] = offset

	appendLayoutFingerprint(offset)

	for index = 1, #key do
		appendLayoutFingerprint(string.byte(key, index))
	end

	appendLayoutFingerprint(0)
	appendLayoutFingerprint(field.boolean and 1 or 0)
	appendLayoutFingerprint(field.unsigned and 1 or 0)
	appendLayoutFingerprint(field.boolean and 0 or field.min)
	appendLayoutFingerprint(field.boolean and 1 or field.max)
end

EcsSyncStateSchema.LAYOUT_FINGERPRINT = layoutFingerprint

local UPLOAD_ALLOWED_FIELDS = {
	syncId = true,
	elements = true,
	baseServerVersion = true,
	authorityVersion = true,
	partId = true
}

for _, field in ipairs(SCALAR_FIELDS) do
	UPLOAD_ALLOWED_FIELDS[field.name] = true
end

local UPLOAD_REQUEST_FIELDS = {
	states = true,
	batchId = true,
	syncSessionId = true
}
local FULL_STATE_REQUEST_FIELDS = {
	syncIds = true,
	syncSessionId = true
}
local AUTHORITY_READY_REQUEST_FIELDS = {
	readyObjects = true,
	syncSessionId = true
}
local AUTHORITY_READY_ITEM_FIELDS = {
	syncId = true,
	authorityVersion = true
}
local BUFF_CHANGE_REQUEST_FIELDS = {
	changes = true,
	syncSessionId = true
}
local BUFF_CHANGE_ITEM_FIELDS = {
	actorId = true,
	srcActorId = true,
	layer = true,
	element = true
}

local function isIntegerInRange(value, minValue, maxValue)
	return type(value) == "number" and minValue <= value and value <= maxValue and value == math.floor(value)
end

local function hasOnlyFields(value, allowedFields)
	if type(value) ~= "table" then
		return false
	end

	for key in pairs(value) do
		if not allowedFields[key] then
			return false
		end
	end

	return true
end

local function getDenseArrayLength(value, maxLength)
	if type(value) ~= "table" then
		return
	end

	local count = 0
	local highestIndex = 0

	for key in pairs(value) do
		if not isIntegerInRange(key, 1, maxLength) then
			return
		end

		count = count + 1
		highestIndex = math.max(highestIndex, key)
	end

	if count ~= highestIndex then
		return
	end

	return count
end

function EcsSyncStateSchema.isValidRemoveInfo(removeInfo)
	return type(removeInfo) == "table" and isIntegerInRange(removeInfo.syncId, 1, EcsSyncStateSchema.MAX_UINT32) and (removeInfo.partId == nil or isIntegerInRange(removeInfo.partId, 0, EcsSyncStateSchema.MAX_UINT8)) and isIntegerInRange(removeInfo.removeVersion, 1, EcsSyncStateSchema.MAX_SAFE_INTEGER)
end

function EcsSyncStateSchema.createUploadRequest(syncSessionId, batchId, states)
	return {
		syncSessionId = syncSessionId,
		batchId = batchId,
		states = states
	}
end

function EcsSyncStateSchema.createFullStateRequest(syncSessionId, syncIds)
	return {
		syncSessionId = syncSessionId,
		syncIds = syncIds
	}
end

function EcsSyncStateSchema.createAuthorityReadyRequest(syncSessionId, readyObjects)
	return {
		syncSessionId = syncSessionId,
		readyObjects = readyObjects
	}
end

function EcsSyncStateSchema.createBuffChangeRequest(syncSessionId, changes)
	return {
		syncSessionId = syncSessionId,
		changes = changes
	}
end

local function validateStateFields(state)
	for _, field in ipairs(SCALAR_FIELDS) do
		local value = state[field.name]

		if field.boolean then
			if type(value) ~= "boolean" then
				return false
			end
		elseif not isIntegerInRange(value, field.min, field.max) then
			return false
		end
	end

	if type(state.elements) ~= "table" then
		return false
	end

	local elementCount = 0

	for key, value in pairs(state.elements) do
		if not isIntegerInRange(key, 1, EcsSyncStateSchema.ELEMENT_COUNT) or not isIntegerInRange(value, 0, EcsSyncStateSchema.MAX_UINT16) then
			return false
		end

		elementCount = elementCount + 1

		local elementBit = 2^(key - 1)

		if elementBit > state.elementMask % (elementBit * 2) and value ~= 0 then
			return false
		end
	end

	return elementCount == EcsSyncStateSchema.ELEMENT_COUNT and (state.hasBattery or state.battery == 0) and (state.hasExplosive or state.explosionType == 0 and state.explosionSequence == 0 and state.explosionRemainingMs == 0 and state.explosionCooldownRemainingMs == 0) and (state.explosionType ~= 0 or state.explosionRemainingMs == 0)
end

function EcsSyncStateSchema.copyElements(elements)
	return {
		elements[1],
		elements[2],
		elements[3],
		elements[4],
		elements[5],
		elements[6]
	}
end

function EcsSyncStateSchema.copyState(source, serverVersion, target)
	target = target or {}

	if serverVersion ~= nil then
		target.serverVersion = serverVersion
	elseif source.serverVersion ~= nil then
		target.serverVersion = source.serverVersion
	end

	if source.partId ~= nil then
		target.partId = source.partId
	end

	target.elements = EcsSyncStateSchema.copyElements(source.elements)

	for _, field in ipairs(SCALAR_FIELDS) do
		target[field.name] = source[field.name]
	end

	return target
end

function EcsSyncStateSchema.copyForUpload(record, baseServerVersion)
	local result = {
		syncId = record.syncId,
		partId = record.partId,
		authorityVersion = record.authorityVersion,
		baseServerVersion = baseServerVersion
	}

	return EcsSyncStateSchema.copyState(record, nil, result)
end

function EcsSyncStateSchema.equals(left, right, includeServerVersion)
	if not left or not right then
		return false
	end

	if includeServerVersion and left.serverVersion ~= right.serverVersion then
		return false
	end

	for _, field in ipairs(SCALAR_FIELDS) do
		if left[field.name] ~= right[field.name] then
			return false
		end
	end

	for index = 1, EcsSyncStateSchema.ELEMENT_COUNT do
		if left.elements[index] ~= right.elements[index] then
			return false
		end
	end

	return true
end

function EcsSyncStateSchema.validateUploadedState(uploadedState)
	if not hasOnlyFields(uploadedState, UPLOAD_ALLOWED_FIELDS) or not isIntegerInRange(uploadedState.syncId, 1, EcsSyncStateSchema.MAX_UINT32) or not isIntegerInRange(uploadedState.partId, 0, EcsSyncStateSchema.MAX_UINT8) or not isIntegerInRange(uploadedState.authorityVersion, 1, EcsSyncStateSchema.MAX_UINT32) or not isIntegerInRange(uploadedState.baseServerVersion, 0, EcsSyncStateSchema.MAX_UINT32) then
		return false, "INVALID_STATE"
	end

	if not validateStateFields(uploadedState) then
		return false, "INVALID_STATE"
	end

	return true
end

function EcsSyncStateSchema.validateServerState(serverState, requireSyncId)
	if type(serverState) ~= "table" or requireSyncId and not isIntegerInRange(serverState.syncId, 1, EcsSyncStateSchema.MAX_UINT32) or not isIntegerInRange(serverState.partId, 0, EcsSyncStateSchema.MAX_UINT8) or not isIntegerInRange(serverState.serverVersion, 1, EcsSyncStateSchema.MAX_UINT32) then
		return false
	end

	return validateStateFields(serverState)
end

function EcsSyncStateSchema.validateSyncObject(objectData)
	return type(objectData) == "table" and isIntegerInRange(objectData.syncId, 1, EcsSyncStateSchema.MAX_UINT32) and isIntegerInRange(objectData.authorityVersion, 1, EcsSyncStateSchema.MAX_UINT32) and isIntegerInRange(objectData.legacyKey, 0, EcsSyncStateSchema.MAX_LEGACY_KEY) and (objectData.syncVersion == nil or isIntegerInRange(objectData.syncVersion, 0, EcsSyncStateSchema.MAX_SAFE_INTEGER)) and (objectData.parts == nil or getDenseArrayLength(objectData.parts, EcsSyncStateSchema.MAX_UINT8 + 1) ~= nil)
end

function EcsSyncStateSchema.writeFlat(array, firstIndex, state)
	for offset = 1, #FLAT_FIELDS do
		local field = FLAT_FIELDS[offset]
		local value = field.index and state[field.name][field.index] or state[field.name]

		if field.boolean then
			value = value and 1 or 0
		end

		array[firstIndex + offset - 1] = value
	end
end

function EcsSyncStateSchema.readFlat(array, firstIndex, decodeUInt32, target)
	target = target or {}
	target.elements = target.elements or {}

	for offset = 1, #FLAT_FIELDS do
		local field = FLAT_FIELDS[offset]
		local value = array[firstIndex + offset - 1]

		if field.boolean then
			value = value ~= 0
		elseif field.unsigned then
			value = decodeUInt32(value)
		end

		if field.index then
			target[field.name][field.index] = value
		else
			target[field.name] = value
		end
	end

	return target
end

EcsSyncStateSchema.SCALAR_FIELDS = SCALAR_FIELDS
EcsSyncStateSchema.FLAT_FIELDS = FLAT_FIELDS
EcsSyncStateSchema.FLAT_OFFSETS = FLAT_OFFSETS
EcsSyncStateSchema.UPLOAD_ALLOWED_FIELDS = UPLOAD_ALLOWED_FIELDS
EcsSyncStateSchema.UPLOAD_REQUEST_FIELDS = UPLOAD_REQUEST_FIELDS
EcsSyncStateSchema.FULL_STATE_REQUEST_FIELDS = FULL_STATE_REQUEST_FIELDS
EcsSyncStateSchema.AUTHORITY_READY_REQUEST_FIELDS = AUTHORITY_READY_REQUEST_FIELDS
EcsSyncStateSchema.AUTHORITY_READY_ITEM_FIELDS = AUTHORITY_READY_ITEM_FIELDS
EcsSyncStateSchema.BUFF_CHANGE_REQUEST_FIELDS = BUFF_CHANGE_REQUEST_FIELDS
EcsSyncStateSchema.BUFF_CHANGE_ITEM_FIELDS = BUFF_CHANGE_ITEM_FIELDS
EcsSyncStateSchema.isIntegerInRange = isIntegerInRange
EcsSyncStateSchema.hasOnlyFields = hasOnlyFields
EcsSyncStateSchema.getDenseArrayLength = getDenseArrayLength

return EcsSyncStateSchema
