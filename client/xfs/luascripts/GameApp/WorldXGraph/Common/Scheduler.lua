-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\WorldXGraph\\Common\\Scheduler.lua

local Time = require("Core.Common.Time")
local Scheduler = {}

Scheduler.__index = Scheduler

function Scheduler.new(runtime)
	local self = setmetatable({}, Scheduler)

	self.runtime = runtime
	self.tasks = {}
	self.nativeTasks = {}
	self.nextId = 1
	self.paused = false
	self.timerManager = Scheduler.GetTimerManager()

	return self
end

function Scheduler.GetTimerManager()
	local ok, timerManager = pcall(require, "Core.Timer.TimerManager")

	if ok then
		return timerManager
	end

	return nil
end

function Scheduler:NextTaskId()
	local id = self.nextId

	self.nextId = id + 1

	return id
end

function Scheduler.GetUnityDeltaTime()
	return Time.deltaTime
end

function Scheduler.GetGlobalTimeScale()
	return pg.game.globalTimeScale
end

function Scheduler:GetScaledDeltaTime()
	local deltaTime = Scheduler.GetUnityDeltaTime()

	if deltaTime == nil then
		return nil
	end

	return deltaTime * Scheduler.GetGlobalTimeScale()
end

function Scheduler:ScheduleFrameAccumulatedDelay(id, task)
	if self.timerManager == nil or self.timerManager.addRepeatNextFrameCb == nil or self.timerManager.delFrameCb == nil then
		return false
	end

	if Scheduler.GetUnityDeltaTime() == nil then
		return false
	end

	local frameId
	local ok = pcall(function()
		frameId = self.timerManager.addRepeatNextFrameCb(function()
			if not self.runtime.isActive or task.passToken ~= self.runtime.passToken then
				self:CancelNativeTask(id, task)

				return
			end

			task.elapsed = task.elapsed + (self:GetScaledDeltaTime() or 0)

			if task.elapsed < task.duration then
				return
			end

			if self.paused then
				return
			end

			self:CancelNativeTask(id, task)
			self:InvokeTask(task)
		end)
	end)

	if not ok or frameId == nil then
		return false
	end

	task.nativeId = frameId
	task.nativeKind = "repeatFrame"
	self.nativeTasks[id] = task

	return true
end

function Scheduler:InvokeTask(task)
	if self.runtime.isActive and task.passToken == self.runtime.passToken then
		local ok, err = pcall(task.callback)

		if not ok then
			require("GameApp.WorldXGraph.Common.Trace").record("SchedulerCallbackError", tostring(err))
		end
	end
end

function Scheduler:Delay(nodeId, seconds, callback, kind)
	local id = self:NextTaskId()
	local duration = tonumber(seconds) or 0
	local task = {
		elapsed = 0,
		nodeId = nodeId,
		callback = callback,
		passToken = self.runtime.passToken,
		kind = kind or "delay",
		duration = duration
	}

	if duration <= 0 then
		self:InvokeTask(task)

		return id
	end

	if self:ScheduleFrameAccumulatedDelay(id, task) then
		return id
	end

	task.remaining = duration
	self.tasks[id] = {
		nodeId = nodeId,
		remaining = task.remaining,
		callback = callback,
		passToken = task.passToken,
		kind = task.kind
	}

	return id
end

function Scheduler:DelayFrame(nodeId, frames, callback)
	local id = self:NextTaskId()
	local task = {
		kind = "frame",
		nodeId = nodeId,
		callback = callback,
		passToken = self.runtime.passToken
	}

	if self.timerManager ~= nil and self.timerManager.addSpecificFrameCb ~= nil then
		local frameId = self.timerManager.addSpecificFrameCb(tonumber(frames) or 0, false, function()
			self.nativeTasks[id] = nil

			self:InvokeTask(task)
		end)

		task.nativeId = frameId
		task.nativeKind = "frame"
		self.nativeTasks[id] = task

		return id
	end

	task.remaining = tonumber(frames) or 0
	self.tasks[id] = task

	return id
end

function Scheduler:StartTimeout(nodeId, seconds, onTimeout)
	return self:Delay(nodeId, seconds, onTimeout, "timeout")
end

function Scheduler:CancelNativeTask(id, task)
	if self.timerManager == nil or task == nil or task.nativeId == nil then
		self.nativeTasks[id] = nil

		return
	end

	if task.nativeKind == "frame" and self.timerManager.delFrameCb ~= nil then
		self.timerManager.delFrameCb(task.nativeId)
	elseif task.nativeKind == "repeatFrame" and self.timerManager.delFrameCb ~= nil then
		self.timerManager.delFrameCb(task.nativeId)
	elseif self.timerManager.removeTimer ~= nil then
		self.timerManager.removeTimer(task.nativeId)
	end

	self.nativeTasks[id] = nil
end

function Scheduler:CancelTimeout(nodeId)
	for id, task in pairs(self.tasks) do
		if task.nodeId == nodeId and task.kind == "timeout" then
			self.tasks[id] = nil
		end
	end

	for id, task in pairs(self.nativeTasks) do
		if task.nodeId == nodeId and task.kind == "timeout" then
			self:CancelNativeTask(id, task)
		end
	end
end

function Scheduler:Pause()
	self.paused = true
end

function Scheduler:Resume()
	self.paused = false
end

function Scheduler:Tick(deltaTime)
	if self.paused or not self.runtime.isActive then
		return
	end

	local elapsed = tonumber(deltaTime) or 0
	local ready = {}

	for id, task in pairs(self.tasks) do
		task.remaining = task.remaining - elapsed

		if task.remaining <= 0 then
			ready[#ready + 1] = task
			self.tasks[id] = nil
		end
	end

	table.sort(ready, function(left, right)
		return (left.nodeId or 0) < (right.nodeId or 0)
	end)

	for _, task in ipairs(ready) do
		self:InvokeTask(task)
	end
end

function Scheduler:CancelAll()
	for id, task in pairs(self.nativeTasks) do
		self:CancelNativeTask(id, task)
	end

	self.tasks = {}
	self.nativeTasks = {}
end

return Scheduler
