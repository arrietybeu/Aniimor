-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Timer\\Timer.lua

local class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local Timer = class.LightClass("Timer")

function Timer:ctor(func, duration, loop)
	self.func = func
	self.delay = duration
	self.loop = loop or 1
end

function Timer:Start()
	self.running = true

	if self.loop == 1 or self.loop == 0 then
		local function innerFunc()
			self:FuncOnce()
		end

		self.timeId = TimerManager.addTimer(self.delay, innerFunc)
	elseif self.loop > 1 then
		local function innerFunc()
			self:FuncMulti()
		end

		self.timeId = TimerManager.addRepeatTimer(self.delay, innerFunc)
	else
		self.timeId = TimerManager.addRepeatTimer(self.delay, self.func)
	end
end

function Timer:FuncOnce()
	self.func()
	self:Stop()
end

function Timer:FuncMulti()
	self.func()

	self.loop = self.loop - 1

	if self.loop <= 0 then
		self:Stop()
	end
end

function Timer:Stop()
	self.running = false

	if self.timeId then
		TimerManager.removeTimer(self.timeId)

		self.timeId = nil
	end
end

return Timer
