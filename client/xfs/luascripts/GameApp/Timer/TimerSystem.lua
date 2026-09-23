-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Timer\\TimerSystem.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local SafeCallback = require("Core.Framework.SafeCallback")
local SystemBase = require("GameApp.Core.SystemBase")
local TimerSystem = Class.LightClass("TimerSystem", SystemBase)

function TimerSystem:ctor(name)
	self.name = name
	self.timers = {}
	self.timerIdCounter = 0
	self.tempRemoveTimerIds = {}
end

function TimerSystem:onTick()
	local now = Time.realtimeSinceStartup

	if self._lastTickTime then
		self:updateTimers(now - self._lastTickTime)
	end

	self._lastTickTime = now
end

function TimerSystem:addScaleTimer(delay, callback, isRepeat)
	self.timerIdCounter = self.timerIdCounter + 1

	local timerId = self.timerIdCounter

	self.timers[timerId] = {
		elapsed = 0,
		id = timerId,
		delay = delay,
		callback = callback,
		isRepeat = isRepeat or false
	}

	return timerId
end

function TimerSystem:removeScaleTimer(timerId)
	if self.timers and self.timers[timerId] then
		self.timers[timerId].markedForRemoval = true
	end
end

function TimerSystem:updateTimers(deltaTime)
	if not self.timers then
		return
	end

	table.clear(self.tempRemoveTimerIds)

	for timerId, timer in pairs(self.timers) do
		if timer.markedForRemoval then
			table.insert(self.tempRemoveTimerIds, timerId)
		else
			timer.elapsed = timer.elapsed + deltaTime * pg.game.globalTimeScale

			if timer.elapsed >= timer.delay then
				if timer.callback and timer.markedForRemoval ~= true then
					SafeCallback(timer.callback)
				end

				if timer.isRepeat then
					timer.elapsed = timer.elapsed - timer.delay
				else
					table.insert(self.tempRemoveTimerIds, timerId)
				end
			end
		end
	end

	for _, timerId in ipairs(self.tempRemoveTimerIds) do
		self.timers[timerId] = nil
	end
end

return TimerSystem
