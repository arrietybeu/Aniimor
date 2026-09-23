-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPosRotSyncData.lua

local PosSyncData = require("GameApp.ShareData.Generated.PosSyncData")
local raw_rawget = rawget
local raw_rawset = rawget(_G, "raw_rawset") or rawset
local ClientPosRotSyncData = {}
local FAR_DISTANCE = 9999

ClientPosRotSyncData.PLAYER_DISTANCE_SLOT = 1
ClientPosRotSyncData.PLAYER_Y_DISTANCE_SLOT = 2
ClientPosRotSyncData.SYNC_POS_FRAME_COUNT_SLOT = 3
ClientPosRotSyncData.SYNC_ROT_FRAME_COUNT_SLOT = 4
ClientPosRotSyncData.SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT = 5
ClientPosRotSyncData.SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT = 6
ClientPosRotSyncData.ROTATION_REVISION_SLOT = 7

local PLAYER_DISTANCE_SLOT = ClientPosRotSyncData.PLAYER_DISTANCE_SLOT
local PLAYER_Y_DISTANCE_SLOT = ClientPosRotSyncData.PLAYER_Y_DISTANCE_SLOT
local SYNC_POS_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_POS_FRAME_COUNT_SLOT
local SYNC_ROT_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_ROT_FRAME_COUNT_SLOT
local SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT
local SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT = ClientPosRotSyncData.SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT
local ROTATION_REVISION_SLOT = ClientPosRotSyncData.ROTATION_REVISION_SLOT
local PLAIN_POOL_MAX_COUNT = 256
local SHARED_POOL_MAX_COUNT = 256
local RELEASED_FIELD = "__clientPosRotSyncDataReleased"
local plainPool = {}
local sharedPool = {}

function ClientPosRotSyncData._initializeMetadata(data)
	data[PLAYER_DISTANCE_SLOT] = FAR_DISTANCE
	data[PLAYER_Y_DISTANCE_SLOT] = FAR_DISTANCE
	data[SYNC_POS_FRAME_COUNT_SLOT] = 0
	data[SYNC_ROT_FRAME_COUNT_SLOT] = 0
	data[SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT] = 0
	data[SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT] = 0
	data[ROTATION_REVISION_SLOT] = 0
end

function ClientPosRotSyncData._destroySharedData(data)
	PosSyncData.destroy(data)
	raw_rawset(data, RELEASED_FIELD, true)
end

function ClientPosRotSyncData.isShared(data)
	return data ~= nil and raw_rawget(data, "shell") ~= nil
end

function ClientPosRotSyncData.createPlain()
	local index = #plainPool
	local data = index > 0 and plainPool[index] or {}

	if index > 0 then
		plainPool[index] = nil
	end

	raw_rawset(data, RELEASED_FIELD, false)
	ClientPosRotSyncData._initializeMetadata(data)

	return data
end

function ClientPosRotSyncData.createShared(position, lastPosition, rotation)
	local index = #sharedPool
	local data = index > 0 and sharedPool[index] or PosSyncData.create()

	if index > 0 then
		sharedPool[index] = nil
	end

	raw_rawset(data, RELEASED_FIELD, false)
	data.shell:PinTransformRefs(position, lastPosition, rotation)
	ClientPosRotSyncData._initializeMetadata(data)

	return data
end

function ClientPosRotSyncData.releasePlain(data)
	if not data or ClientPosRotSyncData.isShared(data) or raw_rawget(data, RELEASED_FIELD) == true then
		return false
	end

	raw_rawset(data, RELEASED_FIELD, true)

	if #plainPool < PLAIN_POOL_MAX_COUNT then
		plainPool[#plainPool + 1] = data

		return true
	end

	return false
end

function ClientPosRotSyncData.releaseShared(data)
	if not data or not ClientPosRotSyncData.isShared(data) or raw_rawget(data, RELEASED_FIELD) == true then
		return false
	end

	raw_rawset(data, RELEASED_FIELD, true)

	if #sharedPool < SHARED_POOL_MAX_COUNT then
		data.shell:ResetTransformAccesses()

		sharedPool[#sharedPool + 1] = data
	else
		ClientPosRotSyncData._destroySharedData(data)
	end

	return true
end

function ClientPosRotSyncData.destroy(data)
	if not data then
		return false
	end

	if ClientPosRotSyncData.isShared(data) then
		return ClientPosRotSyncData.releaseShared(data)
	end

	return ClientPosRotSyncData.releasePlain(data)
end

function ClientPosRotSyncData.writeInitial(data)
	data[ROTATION_REVISION_SLOT] = data[ROTATION_REVISION_SLOT] + 1
end

function ClientPosRotSyncData._writeDistances(data, playerDistance, playerYDistance, frameCount)
	if playerDistance and playerDistance >= 0 then
		data[PLAYER_DISTANCE_SLOT] = playerDistance
		data[SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT] = frameCount
	end

	if playerYDistance and playerYDistance >= 0 then
		data[PLAYER_Y_DISTANCE_SLOT] = playerYDistance
		data[SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT] = frameCount
	end
end

function ClientPosRotSyncData.writePosition(data, playerDistance, playerYDistance, frameCount)
	ClientPosRotSyncData._writeDistances(data, playerDistance, playerYDistance, frameCount)

	data[SYNC_POS_FRAME_COUNT_SLOT] = frameCount
end

function ClientPosRotSyncData.writeRotation(data, playerDistance, playerYDistance, frameCount)
	ClientPosRotSyncData._writeDistances(data, playerDistance, playerYDistance, frameCount)

	data[ROTATION_REVISION_SLOT] = data[ROTATION_REVISION_SLOT] + 1
	data[SYNC_ROT_FRAME_COUNT_SLOT] = frameCount
end

function ClientPosRotSyncData.writePlayerDistance(data, playerDistance, frameCount)
	data[PLAYER_DISTANCE_SLOT] = playerDistance
	data[SYNC_PLAYER_DISTANCE_FRAME_COUNT_SLOT] = frameCount
end

function ClientPosRotSyncData.writePlayerYDistance(data, playerYDistance, frameCount)
	data[PLAYER_Y_DISTANCE_SLOT] = playerYDistance
	data[SYNC_PLAYER_Y_DISTANCE_FRAME_COUNT_SLOT] = frameCount
end

function ClientPosRotSyncData.writeAgentPosition(data, frameCount)
	data[SYNC_POS_FRAME_COUNT_SLOT] = frameCount
end

function ClientPosRotSyncData.writeAgentRotation(data, frameCount)
	data[ROTATION_REVISION_SLOT] = data[ROTATION_REVISION_SLOT] + 1
	data[SYNC_ROT_FRAME_COUNT_SLOT] = frameCount
end

return ClientPosRotSyncData
