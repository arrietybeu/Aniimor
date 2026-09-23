-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\InfiniteScrollList.lua

local Class = require("Core.Framework.Class")
local InfiniteScrollList = Class.LightClass("InfiniteScrollList")
local DEFAULT_TRIGGER_THRESHOLD = 0.15
local DEFAULT_REARM_DISTANCE = 0.05

local function clamp01(value, defaultValue)
	if type(value) ~= "number" then
		return defaultValue
	end

	return math.max(0, math.min(1, value))
end

function InfiniteScrollList:ctor(uList, options)
	assert(uList, "InfiniteScrollList requires a UList")
	assert(type(options) == "table", "InfiniteScrollList requires options")
	assert(type(options.onRequestNextPage) == "function", "InfiniteScrollList requires options.onRequestNextPage")
	assert(options.getItemKey == nil or type(options.getItemKey) == "function", "InfiniteScrollList options.getItemKey must be a function")
	assert(options.hasMore == nil or type(options.hasMore) == "boolean", "InfiniteScrollList options.hasMore must be a boolean")
	assert(options.autoFill == nil or type(options.autoFill) == "boolean", "InfiniteScrollList options.autoFill must be a boolean")

	local axis = options.axis or "vertical"

	assert(axis == "vertical" or axis == "horizontal", "InfiniteScrollList options.axis must be vertical or horizontal")

	local endValue = options.endValue

	if endValue == nil then
		endValue = axis == "vertical" and 0 or 1
	end

	assert(endValue == 0 or endValue == 1, "InfiniteScrollList options.endValue must be 0 or 1")

	self._uList = uList
	self._onRequestNextPage = options.onRequestNextPage
	self._getItemKey = options.getItemKey
	self._axis = axis
	self._endValue = endValue
	self._triggerThreshold = clamp01(options.triggerThreshold, DEFAULT_TRIGGER_THRESHOLD)
	self._rearmDistance = clamp01(options.rearmDistance, DEFAULT_REARM_DISTANCE)
	self._autoFill = options.autoFill ~= false
	self._items = options.initialItems or {}

	assert(type(self._items) == "table", "InfiniteScrollList options.initialItems must be a table")

	self._cursor = options.initialCursor
	self._hasMore = options.hasMore ~= false
	self._knownKeys = {}
	self._loading = false
	self._destroyed = false
	self._suppressScroll = false
	self._armed = true
	self._generation = 0
	self._requestSerial = 0
	self._activeRequestToken = nil

	self:_rebuildKnownKeys()

	function self._scrollCallback(position)
		self:_onScroll(position)
	end

	self._uList:RegisterToScrollEvent(self._scrollCallback)
end

function InfiniteScrollList:_rebuildKnownKeys()
	self._knownKeys = {}

	if not self._getItemKey then
		return
	end

	for index = 1, #self._items do
		local key = self._getItemKey(self._items[index])

		if key ~= nil then
			self._knownKeys[key] = true
		end
	end
end

function InfiniteScrollList:_appendItems(items)
	local appendedCount = 0

	for index = 1, #items do
		local item = items[index]
		local shouldAppend = true

		if self._getItemKey then
			local key = self._getItemKey(item)

			if key ~= nil then
				shouldAppend = not self._knownKeys[key]
				self._knownKeys[key] = true
			end
		end

		if shouldAppend then
			self._items[#self._items + 1] = item
			appendedCount = appendedCount + 1
		end
	end

	return appendedCount
end

function InfiniteScrollList:_getDistanceToEnd(position)
	local value = self._axis == "vertical" and position.y or position.x

	return math.abs(value - self._endValue)
end

function InfiniteScrollList:_syncArmedState()
	if not self._uList or not self._uList.needScrollable then
		self._armed = true

		return
	end

	local distance = self:_getDistanceToEnd(self._uList.normalizedScrollPosition)

	self._armed = distance > self._triggerThreshold + self._rearmDistance
end

function InfiniteScrollList:_onScroll(position)
	if self._destroyed or self._suppressScroll then
		return
	end

	local distance = self:_getDistanceToEnd(position)

	if distance > self._triggerThreshold + self._rearmDistance then
		self._armed = true

		return
	end

	if distance <= self._triggerThreshold and self._armed then
		self:requestNextPage()
	end
end

function InfiniteScrollList:_render(keepPosition)
	local scrollPosition = keepPosition and self._uList.currentScrollPosition or nil

	self._suppressScroll = true

	local success, err = pcall(function()
		self._uList:SetList(self._items)

		if scrollPosition then
			self._uList.currentScrollPosition = scrollPosition
		elseif self._uList.currentScrollPosition then
			local resetPosition = self._uList.currentScrollPosition

			resetPosition.x = 0
			resetPosition.y = 0
			self._uList.currentScrollPosition = resetPosition
		end
	end)

	self._suppressScroll = false

	if not success then
		error(err, 0)
	end
end

function InfiniteScrollList:_tryAutoFill(appendedCount)
	if not self._autoFill or appendedCount <= 0 or self._loading or not self._hasMore then
		return false
	end

	local shouldLoad = not self._uList.needScrollable

	if not shouldLoad then
		local distance = self:_getDistanceToEnd(self._uList.normalizedScrollPosition)

		shouldLoad = distance <= self._triggerThreshold
	end

	if shouldLoad then
		return self:requestNextPage()
	end

	return false
end

function InfiniteScrollList:_invalidateRequest()
	self._generation = self._generation + 1
	self._loading = false
	self._activeRequestToken = nil
end

function InfiniteScrollList:reset(initialCursor, requestImmediately)
	if self._destroyed then
		return false
	end

	self:_invalidateRequest()

	self._items = {}
	self._knownKeys = {}
	self._cursor = initialCursor
	self._hasMore = true
	self._armed = true

	self:_render(false)

	if requestImmediately ~= false then
		return self:requestNextPage()
	end

	return false
end

function InfiniteScrollList:setData(items, nextCursor, hasMore, keepPosition)
	if self._destroyed then
		return 0
	end

	assert(type(items) == "table", "InfiniteScrollList:setData items must be a table")
	assert(hasMore == nil or type(hasMore) == "boolean", "InfiniteScrollList:setData hasMore must be a boolean")
	self:_invalidateRequest()

	self._items = {}
	self._knownKeys = {}

	local appendedCount = self:_appendItems(items)

	self._cursor = nextCursor

	if hasMore == nil then
		self._hasMore = #items > 0
	else
		self._hasMore = hasMore
	end

	self:_render(keepPosition == true)
	self:_syncArmedState()
	self:_tryAutoFill(appendedCount)

	return appendedCount
end

function InfiniteScrollList:requestNextPage()
	if self._destroyed or self._loading or not self._hasMore then
		return false, nil
	end

	self._loading = true
	self._armed = false
	self._requestSerial = self._requestSerial + 1

	local requestToken = {
		generation = self._generation,
		serial = self._requestSerial
	}

	self._activeRequestToken = requestToken

	local success, err = pcall(self._onRequestNextPage, self._cursor, requestToken, self)

	if not success then
		self:rejectPage(requestToken)
		error(err, 0)
	end

	return true, requestToken
end

function InfiniteScrollList:appendPage(requestToken, items, nextCursor, hasMore)
	if self._destroyed or requestToken ~= self._activeRequestToken then
		return false, 0
	end

	assert(type(items) == "table", "InfiniteScrollList:appendPage items must be a table")
	assert(hasMore == nil or type(hasMore) == "boolean", "InfiniteScrollList:appendPage hasMore must be a boolean")

	self._activeRequestToken = nil
	self._loading = false

	local appendedCount = self:_appendItems(items)

	self._cursor = nextCursor

	if hasMore == nil then
		self._hasMore = #items > 0
	else
		self._hasMore = hasMore
	end

	self:_render(true)
	self:_syncArmedState()
	self:_tryAutoFill(appendedCount)

	return true, appendedCount
end

function InfiniteScrollList:rejectPage(requestToken)
	if self._destroyed or requestToken ~= self._activeRequestToken then
		return false
	end

	self._activeRequestToken = nil
	self._loading = false
	self._armed = true

	return true
end

function InfiniteScrollList:isLoading()
	return self._loading
end

function InfiniteScrollList:hasMore()
	return self._hasMore
end

function InfiniteScrollList:getCursor()
	return self._cursor
end

function InfiniteScrollList:getItems()
	return self._items
end

function InfiniteScrollList:getItemCount()
	return #self._items
end

function InfiniteScrollList:destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	self:_invalidateRequest()

	if self._uList and self._scrollCallback then
		self._uList:UnRegisterToScrollEvent(self._scrollCallback)
	end

	self._scrollCallback = nil
	self._onRequestNextPage = nil
	self._getItemKey = nil
	self._knownKeys = nil
	self._items = nil
	self._uList = nil
end

return InfiniteScrollList
