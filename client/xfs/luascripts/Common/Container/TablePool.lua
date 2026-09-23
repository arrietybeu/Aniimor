-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\TablePool.lua

local TablePool = {}
local availableTablesCache = {
	{},
	{},
	{}
}
local tableMaxLen = {
	16,
	32
}
local poolMaxCount = {
	1024,
	512,
	256
}
local dirtyTableMaxCount = poolMaxCount[1] + poolMaxCount[2] + poolMaxCount[3]
local _poolState = "_isInTablePool"
local PoolStateDirty = 1
local PoolStateClean = 2
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local table = table
local poolCounts = {}
local dirtyTables = {}
local dirtyTableTypes = {}
local dirtySlots = {
	count = 0,
	tail = 0,
	head = 1
}
local dirtyFrameTableTypes = {}
local dirtyFrameTableTypeCounts = {}
local frameSlotCapacity = 4
local frameItems, frameNextSlots, freeSlots
local freeSlotCount = frameSlotCapacity
local activeSlots = {
	count = 0,
	tail = 0,
	head = 0
}
local deferredSlots = {
	count = 0,
	tail = 0,
	head = 0
}
local frameSlotUsedCount = 0
local frameSlotHighWatermark = 0
local frameSlotOverflowCount = 0
local tempTableOverLimitFrame = 0
local logger = LoggerManager.getLogger("TablePool")
local Time = require("Core.Common.Time")

if jit then
	local table_new = require("table.new")

	function TablePool._getRawTable(tableType)
		local preAllocatedSize = tableMaxLen[tableType] or 64

		return table_new(0, preAllocatedSize)
	end

	function TablePool._newFrameSlotArray(capacity)
		return table_new(capacity, 0)
	end
else
	function TablePool._getRawTable(tableType)
		return {}
	end

	function TablePool._newFrameSlotArray(capacity)
		return {}
	end
end

if UNITY_EDITOR then
	function TablePool._logCountLimit(tableType)
		if tempTableOverLimitFrame ~= Time.frameCount and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("TablePool.returnTable() dirty table count over limit", tableType, debug.traceback())

			tempTableOverLimitFrame = Time.frameCount
		end
	end
else
	function TablePool._logCountLimit(tableType)
		return
	end
end

frameItems = TablePool._newFrameSlotArray(frameSlotCapacity)
frameNextSlots = TablePool._newFrameSlotArray(frameSlotCapacity)
freeSlots = TablePool._newFrameSlotArray(frameSlotCapacity)

for slot = 1, frameSlotCapacity do
	frameNextSlots[slot] = 0
	freeSlots[slot] = slot
end

function TablePool._getFrameSlotStats()
	return frameSlotCapacity, frameSlotUsedCount, activeSlots.count, deferredSlots.count, freeSlotCount, frameSlotHighWatermark, frameSlotOverflowCount
end

function TablePool._appendActiveFrameItem(tmpTable, tableType)
	local slot = freeSlots[freeSlotCount]

	freeSlots[freeSlotCount] = nil
	freeSlotCount = freeSlotCount - 1
	frameItems[slot] = tmpTable
	frameNextSlots[slot] = 0

	if activeSlots.tail == 0 then
		activeSlots.head = slot
	else
		frameNextSlots[activeSlots.tail] = slot
	end

	activeSlots.tail = slot
	activeSlots.count = activeSlots.count + 1
	frameSlotUsedCount = frameSlotUsedCount + 1

	if frameSlotUsedCount > frameSlotHighWatermark then
		frameSlotHighWatermark = frameSlotUsedCount
	end

	dirtyFrameTableTypes[tmpTable] = tableType
	dirtyFrameTableTypeCounts[tableType] = (dirtyFrameTableTypeCounts[tableType] or 0) + 1

	return slot
end

function TablePool._popFrameItem(slotState)
	local slot = slotState.head

	if slot == 0 then
		return nil, nil
	end

	slotState.head = frameNextSlots[slot]
	slotState.count = slotState.count - 1

	if slotState.head == 0 then
		slotState.tail = 0
	end

	return slot, frameItems[slot]
end

function TablePool.transferDirtyFrameDataToDirtyData()
	if activeSlots.count == 0 then
		return 0
	end

	local transferredCount = activeSlots.count

	if deferredSlots.tail == 0 then
		deferredSlots.head = activeSlots.head
	else
		frameNextSlots[deferredSlots.tail] = activeSlots.head
	end

	deferredSlots.tail = activeSlots.tail
	deferredSlots.count = deferredSlots.count + transferredCount
	activeSlots.head = 0
	activeSlots.tail = 0
	activeSlots.count = 0

	return transferredCount
end

function TablePool._releaseFrameSlot(slot)
	frameItems[slot] = nil
	frameNextSlots[slot] = 0
	freeSlotCount = freeSlotCount + 1
	freeSlots[freeSlotCount] = slot
	frameSlotUsedCount = frameSlotUsedCount - 1
end

function TablePool._decreaseDirtyFrameTableTypeCount(tableType)
	local tableTypeCount = dirtyFrameTableTypeCounts[tableType]

	if tableTypeCount ~= nil and tableTypeCount > 1 then
		dirtyFrameTableTypeCounts[tableType] = tableTypeCount - 1
	else
		dirtyFrameTableTypeCounts[tableType] = nil
	end
end

function TablePool._removeDirtyFrameTableType(tmpTable)
	local tableType = dirtyFrameTableTypes[tmpTable]

	if tableType == nil then
		return nil
	end

	dirtyFrameTableTypes[tmpTable] = nil

	if tableType < 0 then
		return -tableType
	end

	TablePool._decreaseDirtyFrameTableTypeCount(tableType)

	return tableType
end

function TablePool._transferDirtyFrameTableOwnership(tmpTable, tableType)
	local dirtyFrameTableType = dirtyFrameTableTypes[tmpTable]

	if dirtyFrameTableType == nil or dirtyFrameTableType < 0 then
		return
	end

	TablePool._decreaseDirtyFrameTableTypeCount(dirtyFrameTableType)

	dirtyFrameTableTypes[tmpTable] = -tableType
end

function TablePool._clearTable(tmpTable)
	table.clear(tmpTable)

	tmpTable[_poolState] = PoolStateClean
end

function TablePool._cacheCleanTable(tmpTable, tableType)
	local availableTables = availableTablesCache[tableType or 1]

	availableTables[#availableTables + 1] = tmpTable
end

function TablePool._clearTableAndCache(tmpTable, tableType)
	TablePool._clearTable(tmpTable)
	TablePool._cacheCleanTable(tmpTable, tableType)
end

function TablePool._consumeFrameItem(tmpTable, tableType)
	local registeredTableType = TablePool._removeDirtyFrameTableType(tmpTable)

	if registeredTableType == nil then
		return 0
	end

	tableType = registeredTableType

	if tmpTable[_poolState] == nil then
		local poolCount = poolCounts[tableType] or 0

		if poolCount < (poolMaxCount[tableType] or poolMaxCount[3]) then
			TablePool._clearTableAndCache(tmpTable, tableType)

			poolCounts[tableType] = poolCount + 1

			return 1
		end
	elseif tmpTable[_poolState] == PoolStateClean then
		TablePool._cacheCleanTable(tmpTable, tableType)
	end

	return 0
end

function TablePool.getTable(tableType)
	tableType = tableType or 1

	local availableTables = availableTablesCache[tableType]

	if #availableTables > 0 then
		local tTable = availableTables[#availableTables]

		availableTables[#availableTables] = nil
		poolCounts[tableType] = (poolCounts[tableType] or 1) - 1
		tTable[_poolState] = nil

		return tTable
	end

	return TablePool._getRawTable(tableType)
end

function TablePool.returnTable(tmpTable, tableType)
	tableType = tableType or 1

	if tmpTable[_poolState] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("TablePool.returnTable() table already in pool", tableType)
		end

		return
	end

	local poolCount = poolCounts[tableType] or 0

	if poolCount >= (poolMaxCount[tableType] or poolMaxCount[3]) then
		return
	end

	if dirtySlots.count >= dirtyTableMaxCount then
		TablePool._logCountLimit(tableType)

		return
	end

	tmpTable[_poolState] = PoolStateDirty
	poolCounts[tableType] = poolCount + 1
	dirtySlots.tail = dirtySlots.tail % dirtyTableMaxCount + 1
	dirtySlots.count = dirtySlots.count + 1
	dirtyTables[dirtySlots.tail] = tmpTable
	dirtyTableTypes[dirtySlots.tail] = tableType

	TablePool._transferDirtyFrameTableOwnership(tmpTable, tableType)
end

function TablePool.getTempFrameTable(tableType)
	tableType = tableType or 1

	local tempPoolMaxCount = poolMaxCount[tableType] or poolMaxCount[3]
	local availableTables = availableTablesCache[tableType]
	local hasAvailableTable = availableTables ~= nil and #availableTables > 0

	if freeSlotCount == 0 then
		frameSlotOverflowCount = frameSlotOverflowCount + 1

		TablePool._logCountLimit(tableType)

		return TablePool._getRawTable(tableType)
	end

	if not hasAvailableTable and tempPoolMaxCount <= (poolCounts[tableType] or 0) + (dirtyFrameTableTypeCounts[tableType] or 0) then
		TablePool._logCountLimit(tableType)

		return TablePool._getRawTable(tableType)
	end

	local tmpTable = TablePool.getTable(tableType)

	TablePool._appendActiveFrameItem(tmpTable, tableType)

	return tmpTable
end

function TablePool.clearDirtyData(maxClearDirtyCount, canClearCurrentFrameData)
	local clearCount = 0

	if canClearCurrentFrameData then
		while activeSlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
			local slot, tmpTable = TablePool._popFrameItem(activeSlots)

			clearCount = clearCount + TablePool._consumeFrameItem(tmpTable)

			TablePool._releaseFrameSlot(slot)
		end

		TablePool.transferDirtyFrameDataToDirtyData()
	end

	while deferredSlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
		local slot, tmpTable = TablePool._popFrameItem(deferredSlots)

		clearCount = clearCount + TablePool._consumeFrameItem(tmpTable)

		TablePool._releaseFrameSlot(slot)
	end

	while dirtySlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
		local tmpTable = dirtyTables[dirtySlots.head]
		local tableType = dirtyTableTypes[dirtySlots.head]

		dirtyTables[dirtySlots.head] = nil
		dirtyTableTypes[dirtySlots.head] = nil
		dirtySlots.head = dirtySlots.head % dirtyTableMaxCount + 1
		dirtySlots.count = dirtySlots.count - 1

		if tmpTable ~= nil and tmpTable[_poolState] == PoolStateDirty then
			TablePool._clearTable(tmpTable)

			if dirtyFrameTableTypes[tmpTable] == nil then
				TablePool._cacheCleanTable(tmpTable, tableType)
			end

			clearCount = clearCount + 1
		end
	end

	if dirtySlots.count == 0 then
		dirtySlots.head = 1
		dirtySlots.tail = 0
	end

	return clearCount
end

function TablePool.printCacheInfo()
	if LoggerManager.checkLogger(LoggerConst.INFO, "Pool") then
		logger:info("[TablePool Cache] reusable=%d/%d/%d capacity=%d/%d/%d dirty=%d/%d active=%d deferred=%d frameCapacity=%d", #availableTablesCache[1], #availableTablesCache[2], #availableTablesCache[3], poolMaxCount[1], poolMaxCount[2], poolMaxCount[3], dirtySlots.count, dirtyTableMaxCount, activeSlots.count, deferredSlots.count, frameSlotCapacity)
	end
end

return TablePool
