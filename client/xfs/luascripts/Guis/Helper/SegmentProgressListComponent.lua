-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Helper\\SegmentProgressListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SegmentProgressListComponent = Class.LightClass("SegmentProgressListComponent", UIComponent)
local START_EVENT = CS.XGUI.EInvokeTime.User1
local FINISH_EVENT = CS.XGUI.EInvokeTime.User2
local LINEAR_EASE = CS.DG.Tweening.Ease.Linear
local DEFAULT_DURATION_PER_SEGMENT = 0.4
local DEFAULT_MIN_DURATION = 0.08
local SCROLL_FALLBACK_TIME = 1
local EPSILON = 0.0001

local function clamp01(value)
	return math.max(0, math.min(1, value or 0))
end

local function isValidObject(value)
	return value ~= nil and NotNil(value)
end

local function getSegmentValue(total, startTarget, endTarget)
	if endTarget <= startTarget then
		return endTarget <= total and 1 or 0
	end

	return clamp01((total - startTarget) / (endTarget - startTarget))
end

function SegmentProgressListComponent:onCtor(options)
	assert(type(options) == "table", "SegmentProgressListComponent requires options")
	assert(options.list, "SegmentProgressListComponent requires list")
	assert(type(options.getProgress) == "function", "SegmentProgressListComponent requires getProgress")
	assert(type(options.getTarget) == "function", "SegmentProgressListComponent requires getTarget")

	self.list = options.list
	self.getProgress = options.getProgress
	self.getTarget = options.getTarget
	self.renderOther = options.renderOther
	self.renderFinalOther = options.renderFinalOther
	self.finalProgress = options.finalProgress
	self.finalEventTarget = options.finalEventTarget or options.finalProgress
	self.finalTarget = options.finalTarget
	self.durationPerSegment = options.durationPerSegment or DEFAULT_DURATION_PER_SEGMENT
	self.minDuration = options.minDuration or DEFAULT_MIN_DURATION
	self.waitFinishEvent = options.waitFinishEvent ~= false
	self.onProgressChanged = options.onProgressChanged
	self.onSegmentComplete = options.onSegmentComplete
	self.onComplete = options.onComplete
	self.currentTotal = nil
	self.visualTotal = nil
	self.targetTotal = nil
	self.isPreparing = false
	self.isPlaying = false
	self.activeKey = nil
	self.activeIndex = nil
	self.activeQueueIndex = nil
	self.activeProgress = nil
	self.activeSegment = nil
	self._serial = 0
	self._segments = {}
	self._segmentsByIndex = {}
	self._playQueue = {}
	self._rendered = {}
	self._progressOwners = {}
	self._scrollEndCallback = nil
	self._scrollFallbackTimer = nil
	self._lastItems = nil
	self._testTimer = nil
	self._progressChangedFrameId = nil
	self._lastNotifiedTotal = nil
end

function SegmentProgressListComponent:registerObjects()
	function self._listRenderCallback(button, index, data)
		if self.renderOther then
			self.renderOther(button, index, data, self.visualTotal)
		end

		self:_bindProgress(button, index, data)
	end

	self.list.luaRenderItem = self._listRenderCallback
end

function SegmentProgressListComponent:_getSegmentValue(segment, total)
	if not segment then
		return 0
	end

	return getSegmentValue(total or 0, segment.startTarget, segment.target)
end

function SegmentProgressListComponent:_buildSegments(items, fromTotal, toTotal)
	self._segments = {}
	self._segmentsByIndex = {}
	self._playQueue = {}

	local startTarget = 0

	for index, data in ipairs(items or EMPTY_TABLE) do
		local listIndex = index - 1
		local target = tonumber(self.getTarget(data, listIndex)) or startTarget

		target = math.max(startTarget, target)

		local segment = {
			key = listIndex,
			listIndex = listIndex,
			data = data,
			startTarget = startTarget,
			target = target
		}

		segment.fromValue = self:_getSegmentValue(segment, fromTotal)
		segment.toValue = self:_getSegmentValue(segment, toTotal)
		segment.endTotal = segment.startTarget + segment.toValue * (segment.target - segment.startTarget)
		self._segments[#self._segments + 1] = segment
		self._segmentsByIndex[listIndex] = segment

		if segment.toValue > segment.fromValue + EPSILON then
			self._playQueue[#self._playQueue + 1] = segment
		end

		startTarget = target
	end

	if isValidObject(self.finalProgress) and self.finalTarget ~= nil then
		local target = math.max(startTarget, tonumber(self.finalTarget) or startTarget)
		local segment = {
			isFinal = true,
			key = "final",
			startTarget = startTarget,
			target = target
		}

		segment.fromValue = self:_getSegmentValue(segment, fromTotal)
		segment.toValue = self:_getSegmentValue(segment, toTotal)
		segment.endTotal = segment.startTarget + segment.toValue * (segment.target - segment.startTarget)
		self._segments[#self._segments + 1] = segment
		self._finalSegment = segment

		if segment.toValue > segment.fromValue + EPSILON then
			self._playQueue[#self._playQueue + 1] = segment
		end
	else
		self._finalSegment = nil
	end
end

function SegmentProgressListComponent:_bindProgress(button, index, data)
	local segment = self._segmentsByIndex[index]

	if not segment then
		return
	end

	local progress, eventTarget = self.getProgress(button, data, index)

	if not isValidObject(progress) then
		return
	end

	local previousIndex = self._progressOwners[progress]

	if previousIndex ~= nil and previousIndex ~= index then
		local previousNode = self._rendered[previousIndex]

		if previousNode and previousNode.progress == progress then
			self._rendered[previousIndex] = nil
		end

		if self.isPlaying and self.activeProgress == progress and self.activeIndex == previousIndex then
			local activeSegment = self.activeSegment
			local activeQueueIndex = self.activeQueueIndex
			local token = self._serial
			local currentValue = clamp01(progress.value)

			self.visualTotal = activeSegment.startTarget + currentValue * (activeSegment.target - activeSegment.startTarget)
			activeSegment.fromValue = currentValue
			self.activeKey = nil
			self.activeIndex = nil
			self.activeQueueIndex = nil
			self.activeProgress = nil
			self.activeSegment = nil

			self:startTimer(function()
				if token == self._serial and self.isPlaying then
					self:_playSegment(activeSegment, activeQueueIndex)
				end
			end, 0)
		end

		progress:KillProcessAnim()
	end

	self._progressOwners[progress] = index
	self._rendered[index] = {
		button = button,
		progress = progress,
		eventTarget = eventTarget or progress
	}

	if self.isPlaying and self.activeKey == segment.key and self.activeProgress == progress then
		return
	end

	progress:KillProcessAnim()

	progress.value = self:_getSegmentValue(segment, self.visualTotal)
end

function SegmentProgressListComponent:_applyFinalProgress()
	if not self._finalSegment or not isValidObject(self.finalProgress) then
		return
	end

	if self.isPlaying and self.activeKey == self._finalSegment.key and self.activeProgress == self.finalProgress then
		return
	end

	self.finalProgress:KillProcessAnim()

	self.finalProgress.value = self:_getSegmentValue(self._finalSegment, self.visualTotal)
end

function SegmentProgressListComponent:_syncRenderedProgress()
	for index, node in pairs(self._rendered) do
		local segment = self._segmentsByIndex[index]

		if segment and isValidObject(node.progress) then
			node.progress:KillProcessAnim()

			node.progress.value = self:_getSegmentValue(segment, self.visualTotal)
		end
	end

	self:_applyFinalProgress()
end

function SegmentProgressListComponent:_captureVisualTotal()
	if self.isPlaying and self.activeSegment and isValidObject(self.activeProgress) then
		local segment = self.activeSegment

		return segment.startTarget + clamp01(self.activeProgress.value) * (segment.target - segment.startTarget)
	end

	return self.visualTotal or self.currentTotal
end

function SegmentProgressListComponent:_notifyProgressChanged(total, force)
	if not self.onProgressChanged then
		return
	end

	total = tonumber(total) or 0

	if not force and self._lastNotifiedTotal ~= nil and math.abs(total - self._lastNotifiedTotal) <= EPSILON then
		return
	end

	self._lastNotifiedTotal = total

	self.onProgressChanged(total, self.targetTotal)
end

function SegmentProgressListComponent:_stopProgressChangedTick()
	if self._progressChangedFrameId then
		self:killFrameTimer(self._progressChangedFrameId)

		self._progressChangedFrameId = nil
	end
end

function SegmentProgressListComponent:_startProgressChangedTick()
	if not self.onProgressChanged or self._progressChangedFrameId then
		return
	end

	local token = self._serial

	local function tick()
		self._progressChangedFrameId = nil

		if token ~= self._serial or not self.isPlaying then
			return
		end

		self:_notifyProgressChanged(self:_captureVisualTotal())

		if token == self._serial and self.isPlaying then
			self._progressChangedFrameId = self:startFrameTimer(tick, 1)
		end
	end

	self._progressChangedFrameId = self:startFrameTimer(tick, 1)
end

function SegmentProgressListComponent:_clearScrollWait()
	if self._scrollEndCallback and isValidObject(self.list) then
		self.list:UnRegisterToScrollEndEvent(self._scrollEndCallback)
	end

	self._scrollEndCallback = nil

	if self._scrollFallbackTimer then
		self:killTimer(self._scrollFallbackTimer)

		self._scrollFallbackTimer = nil
	end
end

function SegmentProgressListComponent:_killProgressAnimations()
	for _, node in pairs(self._rendered) do
		if isValidObject(node.progress) then
			node.progress:KillProcessAnim()
		end
	end

	if isValidObject(self.finalProgress) then
		self.finalProgress:KillProcessAnim()
	end
end

function SegmentProgressListComponent:_stopAnimation()
	self._serial = self._serial + 1

	self:_stopProgressChangedTick()
	self:_clearScrollWait()
	self:_killProgressAnimations()

	self.isPreparing = false
	self.isPlaying = false
	self.activeKey = nil
	self.activeIndex = nil
	self.activeQueueIndex = nil
	self.activeProgress = nil
	self.activeSegment = nil
end

function SegmentProgressListComponent:_isIndexVisible(index)
	if not isValidObject(self.list) then
		return false
	end

	local success, minIndex, maxIndex = self.list:TryGetVisualRange()

	return success and minIndex <= index and index <= maxIndex
end

function SegmentProgressListComponent:_ensureVisible(index, callback)
	if index == nil or self:_isIndexVisible(index) then
		callback()

		return
	end

	self:_clearScrollWait()

	local token = self._serial
	local continued = false

	local function continueOnce()
		if continued then
			return
		end

		continued = true

		self:_clearScrollWait()

		if token == self._serial then
			callback()
		end
	end

	function self._scrollEndCallback()
		continueOnce()
	end

	self.list:RegisterToScrollEndEvent(self._scrollEndCallback)
	self.list:GoToIndexMinCost(index, false, false)

	if self:_isIndexVisible(index) then
		continueOnce()

		return
	end

	self._scrollFallbackTimer = self:startTimer(function()
		self._scrollFallbackTimer = nil

		if token ~= self._serial then
			return
		end

		if isValidObject(self.list) then
			self.list:GoToIndex(index, true)
		end

		continueOnce()
	end, SCROLL_FALLBACK_TIME)
end

function SegmentProgressListComponent:_resolveProgress(segment)
	if segment.isFinal then
		if isValidObject(self.finalProgress) then
			return self.finalProgress, self.finalEventTarget or self.finalProgress
		end

		return nil, nil
	end

	local node = self._rendered[segment.listIndex]

	if node and isValidObject(node.progress) then
		return node.progress, node.eventTarget
	end

	local success, button = self.list:TryGetChildAt(segment.listIndex)

	if success and button then
		self:_bindProgress(button, segment.listIndex, segment.data)

		node = self._rendered[segment.listIndex]

		if node and isValidObject(node.progress) then
			return node.progress, node.eventTarget
		end
	end

	return nil, nil
end

function SegmentProgressListComponent:_notifySegmentComplete(segment)
	if not self.onSegmentComplete then
		return
	end

	local button

	if not segment.isFinal then
		local node = self._rendered[segment.listIndex]

		button = node and node.button

		if not isValidObject(button) then
			local success, child = self.list:TryGetChildAt(segment.listIndex)

			button = success and child or nil
		end
	end

	local isReached = segment.toValue >= 1 - EPSILON

	self.onSegmentComplete(button, segment.listIndex, segment.data, segment.endTotal, isReached, segment.isFinal == true)
end

function SegmentProgressListComponent:_finishSegment(segment, eventTarget, token, nextIndex)
	self.visualTotal = segment.endTotal

	self:_notifyProgressChanged(self.visualTotal)

	self.activeKey = nil
	self.activeIndex = nil
	self.activeQueueIndex = nil
	self.activeProgress = nil
	self.activeSegment = nil

	self:_notifySegmentComplete(segment)

	if token ~= self._serial then
		return
	end

	local continued = false

	local function continueOnce()
		if continued then
			return
		end

		continued = true

		if token == self._serial then
			self:_playNext(nextIndex)
		end
	end

	if isValidObject(eventTarget) and eventTarget:CheckHasEvent(FINISH_EVENT) then
		if self.waitFinishEvent then
			eventTarget:InvokeCallbackWithCallback(FINISH_EVENT, continueOnce)
		else
			eventTarget:InvokeCallback(FINISH_EVENT)
			continueOnce()
		end
	else
		continueOnce()
	end
end

function SegmentProgressListComponent:_playSegment(segment, queueIndex)
	local token = self._serial

	self:_ensureVisible(segment.listIndex, function()
		if token ~= self._serial then
			return
		end

		local progress, eventTarget = self:_resolveProgress(segment)

		if not isValidObject(progress) then
			self:_finishSegment(segment, nil, token, queueIndex + 1)

			return
		end

		eventTarget = eventTarget or progress

		progress:KillProcessAnim()

		progress.value = segment.fromValue
		self.activeKey = segment.key
		self.activeIndex = segment.listIndex
		self.activeQueueIndex = queueIndex
		self.activeProgress = progress
		self.activeSegment = segment

		if isValidObject(eventTarget) and eventTarget:CheckHasEvent(START_EVENT) then
			eventTarget:InvokeCallback(START_EVENT)
		end

		local duration = math.max(self.minDuration, self.durationPerSegment * (segment.toValue - segment.fromValue))

		local function onProgressComplete()
			if token ~= self._serial then
				return
			end

			progress.value = segment.toValue

			self:_finishSegment(segment, eventTarget, token, queueIndex + 1)
		end

		if duration <= 0 or not progress.gameObject.activeInHierarchy then
			progress.value = segment.toValue

			onProgressComplete()

			return
		end

		progress:ProgressToValue(segment.toValue, onProgressComplete, duration, 0, LINEAR_EASE)
	end)
end

function SegmentProgressListComponent:_finishAnimation()
	self:_stopProgressChangedTick()

	self.isPlaying = false
	self.activeKey = nil
	self.activeIndex = nil
	self.activeQueueIndex = nil
	self.activeProgress = nil
	self.activeSegment = nil
	self.visualTotal = self.targetTotal
	self.currentTotal = self.targetTotal

	self:_syncRenderedProgress()
	self:_notifyProgressChanged(self.currentTotal, true)

	if self.onComplete then
		self.onComplete(self.currentTotal)
	end
end

function SegmentProgressListComponent:_playNext(queueIndex)
	if not self.isPlaying then
		return
	end

	local segment = self._playQueue[queueIndex]

	if not segment then
		self:_finishAnimation()

		return
	end

	self:_playSegment(segment, queueIndex)
end

function SegmentProgressListComponent:_clearTestTimer()
	if self._testTimer then
		self:killTimer(self._testTimer)

		self._testTimer = nil
	end
end

function SegmentProgressListComponent:refresh(items, total)
	self:_clearTestTimer()

	items = items or {}
	total = tonumber(total) or 0
	self._lastItems = items

	local fromTotal = self:_captureVisualTotal()

	if fromTotal == nil then
		fromTotal = total
	end

	self:_stopAnimation()

	self.currentTotal = fromTotal
	self.visualTotal = fromTotal
	self.targetTotal = total

	self:_buildSegments(items, fromTotal, total)

	local shouldPlay = total > fromTotal + EPSILON and #self._playQueue > 0

	if not shouldPlay then
		self.currentTotal = total
		self.visualTotal = total
	end

	self._rendered = {}
	self._progressOwners = {}
	self.isPreparing = true

	self.list:SetList(items)
	self:_applyFinalProgress()

	if self.renderFinalOther then
		self.renderFinalOther(self.visualTotal)
	end

	self.isPreparing = false

	if shouldPlay then
		self.isPlaying = true

		self:_notifyProgressChanged(fromTotal, true)
		self:_startProgressChangedTick()
		self:_playNext(1)
	else
		self:_syncRenderedProgress()
		self:_notifyProgressChanged(total, true)
	end

	return shouldPlay
end

function SegmentProgressListComponent:testProgress(fromTotal, toTotal, delay, items)
	fromTotal = tonumber(fromTotal)
	toTotal = tonumber(toTotal)
	items = items or self._lastItems

	if fromTotal == nil or toTotal == nil then
		return false, "fromTotal and toTotal must be numbers"
	end

	if type(items) ~= "table" then
		return false, "items are required before the first refresh"
	end

	if toTotal <= fromTotal then
		return false, "toTotal must be greater than fromTotal"
	end

	self:_clearTestTimer()
	self:refresh(items, fromTotal)

	delay = tonumber(delay)

	if delay == nil then
		delay = 1
	end

	if delay <= 0 then
		self:refresh(items, toTotal)

		return true
	end

	self._testTimer = self:startTimer(function()
		self._testTimer = nil

		self:refresh(items, toTotal)
	end, delay)

	return true
end

function SegmentProgressListComponent:onDestroy()
	self:_clearTestTimer()
	self:_stopAnimation()

	if isValidObject(self.list) then
		self.list.luaRenderItem = nil
	end

	self._listRenderCallback = nil
	self._segments = nil
	self._segmentsByIndex = nil
	self._playQueue = nil
	self._rendered = nil
	self._progressOwners = nil
	self._lastItems = nil
	self.getProgress = nil
	self.getTarget = nil
	self.renderOther = nil
	self.renderFinalOther = nil
	self.waitFinishEvent = nil
	self.onProgressChanged = nil
	self.onSegmentComplete = nil
	self.finalProgress = nil
	self.finalEventTarget = nil
	self.list = nil

	UIComponent.onDestroy(self)
end

return SegmentProgressListComponent
