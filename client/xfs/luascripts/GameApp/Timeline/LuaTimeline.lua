-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Timeline\\LuaTimeline.lua

local Class = require("Core.Framework.Class")
local OrderedList = require("Common.Container.OrderedList")
local LuaTimeline = Class.LightClass("LuaTimeline")
local ClientUtils = require("Utils.ClientUtils")

function LuaTimeline:ctor(context)
	self.triggerEvents = OrderedList.new(function(x)
		return x.time
	end)
	self.clips = OrderedList.new(function(x)
		return x.from
	end)
	self.pauseEvents = OrderedList.new(function(x)
		return x.time
	end)
	self.currPauseIndex = 1
	self.currTriggerIndex = 1
	self.currTime = 0
	self.duration = 0
	self.speed = 1
	self.isStop = true
	self.context = context
	self.stopCallback = nil
end

function LuaTimeline:setDuration(duration)
	self.duration = duration
end

function LuaTimeline:setStopCallback(stopCallback)
	self.stopCallback = stopCallback
end

function LuaTimeline:start()
	self.currTime = 0
	self.currTriggerIndex = 1
	self.isStop = false

	pg.game.timeline:addTimeline(self)
end

function LuaTimeline:stop(simulate)
	if simulate then
		self:tick(self.duration)
	end

	if self.isStop then
		return
	end

	self.isStop = true

	if self.stopCallback ~= nil then
		self.stopCallback()
	end
end

function LuaTimeline:tick(deltaTime)
	if self.isStop then
		return false
	end

	local aheadTime = deltaTime * self.speed

	return self:simulate(self.currTime + aheadTime)
end

function LuaTimeline:setSpeed(speed)
	self.speed = speed
end

function LuaTimeline:simulate(currTime)
	if self.isStop then
		return false
	end

	if currTime <= self.currTime then
		return true
	end

	if self:checkPause(self.currTime, currTime) then
		return true
	end

	self:checkTriggers(self.currTime, currTime)
	self:tickClips(self.currTime, currTime)

	self.currTime = currTime

	if currTime > self.duration then
		self:stop()

		return false
	end

	return true
end

function LuaTimeline:setJumpPoints(jumpPoints)
	self.jumpPoints = jumpPoints
end

function LuaTimeline:jumpTo(jumpPointName)
	if self.jumpPoints[jumpPointName] then
		self:simulate(self.jumpPoints[jumpPointName])
	end
end

function LuaTimeline:addPauseEvent(pauseEvent)
	self.pauseEvents:add(pauseEvent)
end

function LuaTimeline:addTrigger(trigger)
	self.triggerEvents:add(trigger)
end

function LuaTimeline:createAndAddTrigger(time, callback)
	local trigger = {
		time = time,
		callback = callback
	}

	self:addTrigger(trigger)

	return trigger
end

function LuaTimeline:addClip(clip)
	self.clips:add(clip)
end

function LuaTimeline:createAndAddClip(from, duration, tickFunc, enterFunc, leaveFunc)
	local clip = {
		from = from,
		duration = duration,
		tick = tickFunc,
		enter = enterFunc,
		leave = leaveFunc
	}

	self:addClip(clip)

	return clip
end

function LuaTimeline:checkPause(lastTime, currTime)
	if self.waitingEvent then
		local result = self.waitingEvent.callback(currTime, self.context, self.waitingEvent.data)

		if not result then
			return true
		end

		self.waitingEvent = nil
	end

	while self.currPauseIndex <= self.pauseEvents:getLength() do
		local event = self.pauseEvents:get(self.currPauseIndex)

		if currTime > event.time then
			self.currPauseIndex = self.currPauseIndex + 1

			local result = false

			ClientUtils.tryWithLogError(function()
				result = event.callback(currTime, self.context, event.data)
			end)

			if not result then
				self:checkTriggers(self.currTime, event.time)
				self:tickClips(self.currTime, event.time)

				self.waitingEvent = event
				self.currTime = event.time

				return true
			end
		else
			break
		end
	end

	return false
end

function LuaTimeline:checkTriggers(lastTime, currTime)
	while self.currTriggerIndex <= self.triggerEvents:getLength() do
		local event = self.triggerEvents:get(self.currTriggerIndex)

		if currTime > event.time then
			self.currTriggerIndex = self.currTriggerIndex + 1

			ClientUtils.tryWithLogError(function()
				event.callback(currTime, self.context, event.data)
			end)
		else
			break
		end
	end
end

function LuaTimeline:tickClips(lastTime, currTime)
	for _, clip in ipairs(self.clips.elements) do
		if currTime < clip.from then
			break
		end

		local lastPassTime = lastTime - clip.from
		local passTime = currTime - clip.from

		if lastPassTime <= 0 and passTime > 0 and clip.enter then
			ClientUtils.tryWithLogError(function()
				clip:enter()
			end)
		end

		if passTime < clip.duration then
			ClientUtils.tryWithLogError(function()
				clip:tick(passTime)
			end)
		elseif lastPassTime <= 0 then
			ClientUtils.tryWithLogError(function()
				clip:tick(clip.duration)
			end)
		end

		if lastPassTime < clip.duration and passTime >= clip.duration and clip.leave then
			ClientUtils.tryWithLogError(function()
				clip:leave()
			end)
		end
	end
end

return LuaTimeline
