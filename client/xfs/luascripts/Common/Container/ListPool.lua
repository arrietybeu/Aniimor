-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Container\\ListPool.lua

local ListPool = {}
local availableLists = {
	{},
	{},
	{}
}
local listMaxLen = {
	8,
	32
}
local poolMaxCount = {
	2048,
	2048,
	2048
}
local dirtyListMaxCount = poolMaxCount[1] + poolMaxCount[2] + poolMaxCount[3]
local _poolState = "_isInListPool"
local PoolStateDirty = 1
local PoolStateClean = 2
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local table = table
local next = next
local math_max = math.max
local ipairs = ipairs
local poolCounts = {}
local dirtyLists = {}
local dirtyListTypes = {}
local dirtySlots = {
	tail = 0,
	head = 1,
	count = 0
}
local dirtyFrameListTypes = {}
local dirtyFrameListTypeCounts = {}
local frameSlotCapacity = 4
local frameItems, frameNextSlots, freeSlots
local freeSlotCount = frameSlotCapacity
local activeSlots = {
	tail = 0,
	head = 0,
	count = 0
}
local deferredSlots = {
	tail = 0,
	head = 0,
	count = 0
}
local frameSlotUsedCount = 0
local frameSlotHighWatermark = 0
local frameSlotOverflowCount = 0
local tempListOverLimitFrame = 0
local Time = require("Core.Common.Time")
local logger = LoggerManager.getLogger("ListPool")

if jit then
	local table_new = require("table.new")

	function ListPool._getRawList(listType)
		local preAllocatedSize = listMaxLen[listType] or 64

		return table_new(preAllocatedSize, 1)
	end

	function ListPool._newFrameSlotArray(capacity)
		return table_new(capacity, 0)
	end
else
	function ListPool._getRawList(listType)
		return {}
	end

	function ListPool._newFrameSlotArray(capacity)
		return {}
	end
end

if UNITY_EDITOR then
	function ListPool._logCountLimit(listType)
		if tempListOverLimitFrame ~= Time.frameCount and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ListPool.returnList() dirty list count over limit", listType, debug.traceback())

			tempListOverLimitFrame = Time.frameCount
		end
	end

	function ListPool._logCheckReturnListType(list, listType)
		local tCurListLength = #list
		local tListType = listType

		for index, tListMaxLen in ipairs(listMaxLen) do
			if tCurListLength <= tListMaxLen then
				break
			end

			tListType = math_max(tListType, index + 1)
		end

		if listType ~= tListType and LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ListPool.returnList() list len suggest use", tListType)
		end
	end
else
	function ListPool._logCountLimit(listType)
		return
	end

	function ListPool._logCheckReturnListType(list, listType)
		return
	end
end

frameItems = ListPool._newFrameSlotArray(frameSlotCapacity)
frameNextSlots = ListPool._newFrameSlotArray(frameSlotCapacity)
freeSlots = ListPool._newFrameSlotArray(frameSlotCapacity)

for slot = 1, frameSlotCapacity do
	frameNextSlots[slot] = 0
	freeSlots[slot] = slot
end

function ListPool._getFrameSlotStats()
	return frameSlotCapacity, frameSlotUsedCount, activeSlots.count, deferredSlots.count, freeSlotCount, frameSlotHighWatermark, frameSlotOverflowCount
end

function ListPool._appendActiveFrameItem(list, listType)
	local slot = freeSlots[freeSlotCount]

	freeSlots[freeSlotCount] = nil
	freeSlotCount = freeSlotCount - 1
	frameItems[slot] = list
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

	dirtyFrameListTypes[list] = listType
	dirtyFrameListTypeCounts[listType] = (dirtyFrameListTypeCounts[listType] or 0) + 1

	return slot
end

function ListPool._popFrameItem(slotState)
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

function ListPool.transferDirtyFrameDataToDirtyData()
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

function ListPool._releaseFrameSlot(slot)
	frameItems[slot] = nil
	frameNextSlots[slot] = 0
	freeSlotCount = freeSlotCount + 1
	freeSlots[freeSlotCount] = slot
	frameSlotUsedCount = frameSlotUsedCount - 1
end

function ListPool._decreaseDirtyFrameListTypeCount(listType)
	local listTypeCount = dirtyFrameListTypeCounts[listType]

	if listTypeCount ~= nil and listTypeCount > 1 then
		dirtyFrameListTypeCounts[listType] = listTypeCount - 1
	else
		dirtyFrameListTypeCounts[listType] = nil
	end
end

function ListPool._removeDirtyFrameListType(list)
	local listType = dirtyFrameListTypes[list]

	if listType == nil then
		return nil
	end

	dirtyFrameListTypes[list] = nil

	if listType < 0 then
		return -listType
	end

	ListPool._decreaseDirtyFrameListTypeCount(listType)

	return listType
end

function ListPool._transferDirtyFrameListOwnership(list, listType)
	local dirtyFrameListType = dirtyFrameListTypes[list]

	if dirtyFrameListType == nil or dirtyFrameListType < 0 then
		return
	end

	ListPool._decreaseDirtyFrameListTypeCount(dirtyFrameListType)

	dirtyFrameListTypes[list] = -listType
end

function ListPool._clearList(list)
	list[_poolState] = nil

	table.clearArray(list)
	ListPool._checkListIsList(list)

	list[_poolState] = PoolStateClean
end

function ListPool._cacheCleanList(list, listType)
	local tAvailableLists = availableLists[listType or 1]

	tAvailableLists[#tAvailableLists + 1] = list
end

function ListPool._clearListAndCache(list, listType)
	ListPool._clearList(list)
	ListPool._cacheCleanList(list, listType)
end

function ListPool._consumeFrameItem(list, listType)
	local registeredListType = ListPool._removeDirtyFrameListType(list)

	if registeredListType == nil then
		return 0
	end

	listType = registeredListType

	if list[_poolState] == nil then
		local poolCount = poolCounts[listType] or 0

		if poolCount < (poolMaxCount[listType] or poolMaxCount[3]) then
			ListPool._clearListAndCache(list, listType)

			poolCounts[listType] = poolCount + 1

			return 1
		end
	elseif list[_poolState] == PoolStateClean then
		ListPool._cacheCleanList(list, listType)
	end

	return 0
end

function ListPool.getList(listType)
	listType = listType or 1

	local tAvailableLists = availableLists[listType]
	local tAvailableListsLen = #tAvailableLists

	if tAvailableListsLen > 0 then
		local list = tAvailableLists[tAvailableListsLen]

		tAvailableLists[tAvailableListsLen] = nil
		poolCounts[listType] = (poolCounts[listType] or 1) - 1
		list[_poolState] = nil

		return list
	end

	return ListPool._getRawList(listType)
end

function ListPool.returnList(list, listType)
	if not list or list[_poolState] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ListPool.returnList() list already in pool")
		end

		return
	end

	listType = listType or 1

	ListPool._logCheckReturnListType(list, listType)

	local poolCount = poolCounts[listType] or 0

	if poolCount >= (poolMaxCount[listType] or poolMaxCount[3]) then
		ListPool._logCountLimit(listType)

		return
	end

	if dirtySlots.count >= dirtyListMaxCount then
		ListPool._logCountLimit(listType)

		return
	end

	list[_poolState] = PoolStateDirty
	poolCounts[listType] = poolCount + 1
	dirtySlots.tail = dirtySlots.tail % dirtyListMaxCount + 1
	dirtySlots.count = dirtySlots.count + 1
	dirtyLists[dirtySlots.tail] = list
	dirtyListTypes[dirtySlots.tail] = listType

	ListPool._transferDirtyFrameListOwnership(list, listType)
end

function ListPool.getTempFrameList(listType)
	listType = listType or 1

	local tempPoolMaxCount = poolMaxCount[listType] or poolMaxCount[3]
	local tAvailableLists = availableLists[listType]
	local hasAvailableList = tAvailableLists ~= nil and #tAvailableLists > 0

	if freeSlotCount == 0 then
		frameSlotOverflowCount = frameSlotOverflowCount + 1

		ListPool._logCountLimit(listType)

		return ListPool._getRawList(listType)
	end

	if not hasAvailableList and tempPoolMaxCount <= (poolCounts[listType] or 0) + (dirtyFrameListTypeCounts[listType] or 0) then
		ListPool._logCountLimit(listType)

		return ListPool._getRawList(listType)
	end

	local list = ListPool.getList(listType)

	ListPool._appendActiveFrameItem(list, listType)

	return list
end

function ListPool.clearDirtyData(maxClearDirtyCount, canClearCurrentFrameData)
	local clearCount = 0

	if canClearCurrentFrameData then
		while activeSlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
			local slot, list = ListPool._popFrameItem(activeSlots)

			clearCount = clearCount + ListPool._consumeFrameItem(list)

			ListPool._releaseFrameSlot(slot)
		end

		ListPool.transferDirtyFrameDataToDirtyData()
	end

	while deferredSlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
		local slot, list = ListPool._popFrameItem(deferredSlots)

		clearCount = clearCount + ListPool._consumeFrameItem(list)

		ListPool._releaseFrameSlot(slot)
	end

	while dirtySlots.count > 0 and (maxClearDirtyCount == nil or clearCount < maxClearDirtyCount) do
		local list = dirtyLists[dirtySlots.head]
		local listType = dirtyListTypes[dirtySlots.head]

		dirtyLists[dirtySlots.head] = nil
		dirtyListTypes[dirtySlots.head] = nil
		dirtySlots.head = dirtySlots.head % dirtyListMaxCount + 1
		dirtySlots.count = dirtySlots.count - 1

		if list ~= nil and list[_poolState] == PoolStateDirty then
			ListPool._clearList(list)

			if dirtyFrameListTypes[list] == nil then
				ListPool._cacheCleanList(list, listType)
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

function ListPool.printCacheInfo()
	if LoggerManager.checkLogger(LoggerConst.INFO, "Pool") then
		logger:info("[ListPool Cache] reusable=%d/%d/%d capacity=%d/%d/%d dirty=%d/%d active=%d deferred=%d frameCapacity=%d", #availableLists[1], #availableLists[2], #availableLists[3], poolMaxCount[1], poolMaxCount[2], poolMaxCount[3], dirtySlots.count, dirtyListMaxCount, activeSlots.count, deferredSlots.count, frameSlotCapacity)
	end
end

function ListPool._checkListIsList(list)
	if next(list) ~= nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("ListPool.clearDirtyData() list not array", debug.traceback())
		end

		table.clear(list)
	end
end

return ListPool
