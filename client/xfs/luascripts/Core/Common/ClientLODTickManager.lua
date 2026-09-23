-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ClientLODTickManager.lua

local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SampleUtils = SampleUtils
local logger = LoggerManager.getLogger("ClientLODTickManager")
local ClientLODTickManager = {}
local _enabledDis2Interval = {
	[0] = 0.1,
	0.1,
	0.1,
	0.1,
	0.1,
	0.2,
	0.2,
	0.2,
	0.2,
	0.2,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.4,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	0.6,
	1
}
local _FIXED_NEAR_INTERVAL = 0.1
local _DIST_CYCLE_SECOND = 0.5
local _LOW_FPS_NO_SPLIT_DT = 0.1
local _LOW_FPS_NO_EXCLUSIVE_DT = 0.05
local _TOMBSTONE = {
	disabled = true,
	lastTick = 0,
	minInterval = math.huge,
	lodInterval = math.huge,
	interval = math.huge
}
local _infoPool = {}
local _opPool = {}

local function _acquireInfo()
	local n = #_infoPool

	if n > 0 then
		local info = _infoPool[n]

		_infoPool[n] = nil

		return info
	end

	return {}
end

local function _freeInfo(info)
	if info == _TOMBSTONE then
		return
	end

	info.entity = nil
	_infoPool[#_infoPool + 1] = info
end

local _OP_ADD = 1
local _OP_REMOVE = 2
local _OP_SET_DISABLED = 3

local function _newOp(kind, entity, arg)
	local n = #_opPool
	local op = _opPool[n]

	if op ~= nil then
		_opPool[n] = nil
	else
		op = {
			kind = 0,
			entity = false,
			arg = false
		}
	end

	op.kind = kind
	op.entity = entity
	op.arg = arg

	return op
end

local function _freeOp(op)
	op.entity = false
	op.arg = false
	_opPool[#_opPool + 1] = op
end

ClientLODTickManager._mainPlayer = nil
ClientLODTickManager._mainPlayerInfo = nil
ClientLODTickManager._noLODList = {}
ClientLODTickManager._noLODEnt2Idx = {}
ClientLODTickManager._fastList = {}
ClientLODTickManager._fastEnt2Idx = {}
ClientLODTickManager._lodBuckets = {}
ClientLODTickManager._tickTimer = nil
ClientLODTickManager._isInTick = false
ClientLODTickManager._globalPending = {}
ClientLODTickManager._mpInterval = nil
ClientLODTickManager._lastTickSecond = -1
ClientLODTickManager._lastExclusive = false

local _entityEmptyTick

local function _getEntityEmptyTick()
	if _entityEmptyTick == nil then
		_entityEmptyTick = require("Core.Common.Entity").tick
	end

	return _entityEmptyTick
end

local function _newBucket(interval)
	return {
		distCursor = 0,
		tickCursor = 0,
		interval = interval,
		list = {},
		ent2idx = {},
		freeList = {}
	}
end

local function _addToBucket(bucket, info)
	local freeList = bucket.freeList
	local fn = #freeList
	local idx

	if fn > 0 then
		idx = freeList[fn]
		freeList[fn] = nil
	else
		idx = #bucket.list + 1
	end

	bucket.list[idx] = info
	bucket.ent2idx[info.entity] = idx
end

local function _removeFromBucket(bucket, entity)
	local idx = bucket.ent2idx[entity]

	if idx == nil then
		return nil
	end

	local info = bucket.list[idx]

	bucket.list[idx] = _TOMBSTONE
	bucket.ent2idx[entity] = nil
	bucket.freeList[#bucket.freeList + 1] = idx

	return info
end

local function _addToList(list, ent2idx, info)
	local n = #list + 1

	list[n] = info
	ent2idx[info.entity] = n
end

local function _removeFromList(list, ent2idx, entity)
	local idx = ent2idx[entity]

	if idx == nil then
		return nil
	end

	local info = list[idx]
	local n = #list

	if idx < n then
		local last = list[n]

		list[idx] = last
		ent2idx[last.entity] = idx
	end

	list[n] = nil
	ent2idx[entity] = nil

	return info
end

local function _assignToGroup(info)
	local entity = info.entity

	if entity.isMainPlayer == true then
		ClientLODTickManager._mainPlayer = entity
		ClientLODTickManager._mainPlayerInfo = info
		ClientLODTickManager._mpInterval = info.minInterval

		return
	end

	if entity.getPosition == nil then
		info.lodInterval = _FIXED_NEAR_INTERVAL
		info.interval = info.minInterval

		_addToList(ClientLODTickManager._noLODList, ClientLODTickManager._noLODEnt2Idx, info)

		return
	end

	if info.minInterval < _FIXED_NEAR_INTERVAL then
		info.lodInterval = _FIXED_NEAR_INTERVAL
		info.interval = info.minInterval

		_addToList(ClientLODTickManager._fastList, ClientLODTickManager._fastEnt2Idx, info)

		return
	end

	info.disabled = entity.allowLodTick == false
	info.lodInterval = _FIXED_NEAR_INTERVAL
	info.interval = info.minInterval

	local buckets = ClientLODTickManager._lodBuckets
	local bucket = buckets[info.minInterval]

	if bucket == nil then
		bucket = _newBucket(info.minInterval)
		buckets[info.minInterval] = bucket
	end

	_addToBucket(bucket, info)
end

local function _detachFromAnyGroup(entity)
	if ClientLODTickManager._mainPlayer == entity then
		local info = ClientLODTickManager._mainPlayerInfo

		ClientLODTickManager._mainPlayer = nil
		ClientLODTickManager._mainPlayerInfo = nil
		ClientLODTickManager._mpInterval = nil

		return info
	end

	local info = _removeFromList(ClientLODTickManager._noLODList, ClientLODTickManager._noLODEnt2Idx, entity)

	if info ~= nil then
		return info
	end

	info = _removeFromList(ClientLODTickManager._fastList, ClientLODTickManager._fastEnt2Idx, entity)

	if info ~= nil then
		return info
	end

	for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
		info = _removeFromBucket(bucket, entity)

		if info ~= nil then
			return info
		end
	end

	return nil
end

local function _isEmpty()
	if ClientLODTickManager._mainPlayer ~= nil then
		return false
	end

	if #ClientLODTickManager._noLODList > 0 then
		return false
	end

	if #ClientLODTickManager._fastList > 0 then
		return false
	end

	for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
		if #bucket.list - #bucket.freeList > 0 then
			return false
		end
	end

	return true
end

local _tick

local function _ensureTimer()
	if ClientLODTickManager._tickTimer == nil then
		ClientLODTickManager._tickTimer = TimerManager.addRepeatNextFrameCb(_tick)
	end
end

local function _maybeStopTimer()
	if _isEmpty() and ClientLODTickManager._tickTimer ~= nil then
		TimerManager.delFrameCb(ClientLODTickManager._tickTimer)

		ClientLODTickManager._tickTimer = nil
	end
end

local function _doRegister(entity, interval)
	local oldInfo = _detachFromAnyGroup(entity)

	if oldInfo ~= nil then
		_freeInfo(oldInfo)
	end

	if entity.tick == _getEntityEmptyTick() then
		return
	end

	local info = _acquireInfo()

	info.entity = entity
	info.minInterval = interval
	info.lodInterval = _FIXED_NEAR_INTERVAL
	info.interval = interval
	info.disabled = false

	_assignToGroup(info)

	info.lastTick = Time.getTickSecond()

	_ensureTimer()
end

local function _doUnregister(entity)
	local info = _detachFromAnyGroup(entity)

	if info ~= nil then
		_freeInfo(info)
	end
end

local function _doSetDisabled(entity, disabled)
	if ClientLODTickManager._mainPlayer == entity then
		return
	end

	if ClientLODTickManager._noLODEnt2Idx[entity] ~= nil then
		return
	end

	if ClientLODTickManager._fastEnt2Idx[entity] ~= nil then
		return
	end

	for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
		local idx = bucket.ent2idx[entity]

		if idx ~= nil then
			local info = bucket.list[idx]

			info.disabled = disabled

			if disabled then
				info.lodInterval = _FIXED_NEAR_INTERVAL

				local minI = info.minInterval

				info.interval = minI > _FIXED_NEAR_INTERVAL and minI or _FIXED_NEAR_INTERVAL
			end

			return
		end
	end
end

local function _flushGlobalPending()
	local pending = ClientLODTickManager._globalPending
	local n = #pending

	if n == 0 then
		return
	end

	for i = 1, n do
		local op = pending[i]

		if op ~= nil then
			local kind = op.kind

			if kind == _OP_ADD then
				_doRegister(op.entity, op.arg)
			elseif kind == _OP_REMOVE then
				_doUnregister(op.entity)
			elseif kind == _OP_SET_DISABLED then
				_doSetDisabled(op.entity, op.arg)
			end

			_freeOp(op)
		end

		pending[i] = nil
	end

	_maybeStopTimer()
end

function ClientLODTickManager.register(entity, interval)
	if ClientLODTickManager._isInTick then
		ClientLODTickManager._globalPending[#ClientLODTickManager._globalPending + 1] = _newOp(_OP_ADD, entity, interval)

		return
	end

	_doRegister(entity, interval)
end

function ClientLODTickManager.unregister(entity)
	if ClientLODTickManager._isInTick then
		ClientLODTickManager._globalPending[#ClientLODTickManager._globalPending + 1] = _newOp(_OP_REMOVE, entity, nil)

		return
	end

	_doUnregister(entity)
	_maybeStopTimer()
end

function ClientLODTickManager.setDisabled(entity, disabled)
	if ClientLODTickManager._isInTick then
		ClientLODTickManager._globalPending[#ClientLODTickManager._globalPending + 1] = _newOp(_OP_SET_DISABLED, entity, disabled)

		return
	end

	_doSetDisabled(entity, disabled)
end

function ClientLODTickManager.init()
	ClientLODTickManager._lastTickSecond = -1
end

local function _scanListWithSample(list, now)
	for i = 1, #list do
		local info = list[i]
		local dt = now - info.lastTick

		if dt >= info.interval then
			info.lastTick = now

			local entity = info.entity

			SampleUtils.beginSample(SampleUtils.showSampleDesc(entity.tick))

			local status, err = xpcall(entity.tick, debug.traceback, entity, dt)

			SampleUtils.endSample()

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end
		end
	end
end

local function _tickDistSegment(bucket, px, pz, dtScaled)
	local list = bucket.list
	local n = #list
	local cursor = bucket.distCursor

	cursor = n <= cursor and 0 or cursor

	local endIdx = cursor + math.ceil(dtScaled * n / _DIST_CYCLE_SECOND)

	endIdx = n < endIdx and n or endIdx

	for i = cursor + 1, endIdx do
		local info = list[i]

		if not info.disabled then
			local entity = info.entity
			local myPos = entity:getPosition()
			local dx = px - myPos[1]
			local dz = pz - myPos[3]
			local sqr = dx * dx + dz * dz
			local floorDis = math.floor(sqr / 100)
			local lodInterval = _enabledDis2Interval[floorDis] or _enabledDis2Interval[50]

			info.lodInterval = lodInterval

			local minI = info.minInterval

			info.interval = lodInterval < minI and minI or lodInterval
		end
	end

	bucket.distCursor = endIdx
end

local function _tickTickSegmentNoSample(bucket, now, dt, dtScaled)
	local list = bucket.list
	local n = #list
	local cursor, endIdx

	if dt >= _LOW_FPS_NO_SPLIT_DT then
		cursor = 0
		endIdx = n
	else
		cursor = bucket.tickCursor
		cursor = n <= cursor and 0 or cursor
		endIdx = cursor + math.ceil(dtScaled * n / bucket.interval)
		endIdx = n < endIdx and n or endIdx
	end

	for i = cursor + 1, endIdx do
		local info = list[i]
		local iDt = now - info.lastTick

		if iDt >= info.interval then
			info.lastTick = now

			local entity = info.entity
			local status, err = xpcall(entity.tick, debug.traceback, entity, iDt)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end
		end
	end

	bucket.tickCursor = endIdx
end

local function _tickTickSegmentWithSample(bucket, now, dt, dtScaled)
	local list = bucket.list
	local n = #list
	local cursor, endIdx

	if dt >= _LOW_FPS_NO_SPLIT_DT then
		cursor = 0
		endIdx = n
	else
		cursor = bucket.tickCursor
		cursor = n <= cursor and 0 or cursor
		endIdx = cursor + math.ceil(dtScaled * n / bucket.interval)
		endIdx = n < endIdx and n or endIdx
	end

	for i = cursor + 1, endIdx do
		local info = list[i]
		local iDt = now - info.lastTick

		if iDt >= info.interval then
			info.lastTick = now

			local entity = info.entity

			SampleUtils.beginSample(SampleUtils.showSampleDesc(entity.tick))

			local status, err = xpcall(entity.tick, debug.traceback, entity, iDt)

			SampleUtils.endSample()

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end
		end
	end

	bucket.tickCursor = endIdx
end

local function _tickNoSample(now, dt, dtScaled)
	local mainPlayerInfo = ClientLODTickManager._mainPlayerInfo
	local mainPlayerTicked = false

	if mainPlayerInfo ~= nil then
		local mpDt = now - mainPlayerInfo.lastTick

		if mpDt >= mainPlayerInfo.interval then
			mainPlayerInfo.lastTick = now

			local entity = mainPlayerInfo.entity
			local status, err = xpcall(entity.tick, debug.traceback, entity, mpDt)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end

			mainPlayerTicked = true
		end
	end

	if pg.space == nil then
		return
	end

	local fastList = ClientLODTickManager._fastList

	for i = 1, #fastList do
		local info = fastList[i]
		local fDt = now - info.lastTick

		if fDt >= info.interval then
			info.lastTick = now

			local entity = info.entity
			local status, err = xpcall(entity.tick, debug.traceback, entity, fDt)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end
		end
	end

	if mainPlayerTicked then
		if dt < _LOW_FPS_NO_EXCLUSIVE_DT and not ClientLODTickManager._lastExclusive then
			ClientLODTickManager._lastExclusive = true

			return
		end

		ClientLODTickManager._lastExclusive = false
	end

	local noLODList = ClientLODTickManager._noLODList

	for i = 1, #noLODList do
		local info = noLODList[i]
		local nDt = now - info.lastTick

		if nDt >= info.interval then
			info.lastTick = now

			local entity = info.entity
			local status, err = xpcall(entity.tick, debug.traceback, entity, nDt)

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end
		end
	end

	local playerPos = pg.playerPos

	if playerPos == nil then
		for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
			local list = bucket.list

			for i = 1, #list do
				local info = list[i]
				local lDt = now - info.lastTick

				if lDt >= info.interval then
					info.lastTick = now

					local entity = info.entity
					local status, err = xpcall(entity.tick, debug.traceback, entity, lDt)

					if not status then
						local ex = err or "unknown error occurred"

						if LoggerManager.checkLogger(LoggerConst.ERROR) then
							logger:error("__tick__ traceback occurred", ex)
						end
					end
				end
			end
		end

		return
	end

	local px = playerPos[1]
	local pz = playerPos[3]

	for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
		local status, err = xpcall(_tickDistSegment, debug.traceback, bucket, px, pz, dtScaled)

		if not status then
			local ex = err or "unknown error occurred"

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("__dist__ traceback occurred", ex)
			end
		end

		_tickTickSegmentNoSample(bucket, now, dt, dtScaled)
	end
end

local function _tickWithSample(now, dt, dtScaled)
	local mainPlayerInfo = ClientLODTickManager._mainPlayerInfo
	local mainPlayerTicked = false

	if mainPlayerInfo ~= nil then
		local mpDt = now - mainPlayerInfo.lastTick

		if mpDt >= mainPlayerInfo.interval then
			mainPlayerInfo.lastTick = now

			local entity = mainPlayerInfo.entity

			SampleUtils.beginSample(SampleUtils.showSampleDesc(entity.tick))

			local status, err = xpcall(entity.tick, debug.traceback, entity, mpDt)

			SampleUtils.endSample()

			if not status then
				local ex = err or "unknown error occurred"

				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("__tick__ traceback occurred", ex)
				end
			end

			mainPlayerTicked = true
		end
	end

	if pg.space == nil then
		return
	end

	_scanListWithSample(ClientLODTickManager._fastList, now)

	if mainPlayerTicked then
		if dt < _LOW_FPS_NO_EXCLUSIVE_DT and not ClientLODTickManager._lastExclusive then
			ClientLODTickManager._lastExclusive = true

			return
		end

		ClientLODTickManager._lastExclusive = false
	end

	_scanListWithSample(ClientLODTickManager._noLODList, now)

	local playerPos = pg.playerPos

	if playerPos == nil then
		for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
			_scanListWithSample(bucket.list, now)
		end

		return
	end

	local px = playerPos[1]
	local pz = playerPos[3]

	for _, bucket in pairs(ClientLODTickManager._lodBuckets) do
		local status, err = xpcall(_tickDistSegment, debug.traceback, bucket, px, pz, dtScaled)

		if not status then
			local ex = err or "unknown error occurred"

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("__dist__ traceback occurred", ex)
			end
		end

		_tickTickSegmentWithSample(bucket, now, dt, dtScaled)
	end
end

local function _computeDt(now)
	local last = ClientLODTickManager._lastTickSecond
	local dt

	if last > 0 then
		dt = now - last

		if dt > 0.1 then
			dt = 0.1
		end
	else
		dt = 0.0167
	end

	ClientLODTickManager._lastTickSecond = now

	local mp = ClientLODTickManager._mpInterval

	if mp == nil or mp <= 0 then
		return dt, dt
	end

	local r = dt / mp

	if r > 0.5 then
		r = 0.5
	end

	return dt, dt / (1 - r)
end

function _tick()
	if EnableBotTest then
		return
	end

	ClientLODTickManager._isInTick = true

	local now = Time.getTickSecond()
	local dt, dtScaled = _computeDt(now)
	local fn = SampleUtils.sampleOn() and _tickWithSample or _tickNoSample
	local status, err = xpcall(fn, debug.traceback, now, dt, dtScaled)

	ClientLODTickManager._isInTick = false

	if not status then
		local ex = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("__tick_main__ traceback occurred", ex)
		end
	end

	_flushGlobalPending()
end

ClientLODTickManager._tick = _tick

return ClientLODTickManager
