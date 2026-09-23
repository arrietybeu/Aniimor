-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Core\\Scheduler.lua

local Scheduler = {}

Scheduler.__index = Scheduler

local SafeCallbackWithStatusAndReturn = require("Core.Framework.SafeCallbackWithStatusAndReturn")
local TIME_TICK_INTERVAL = 0.05
local TIME_EPSILON = 1e-06

function Scheduler.new(runtime)
	local self = setmetatable({}, Scheduler)

	self.runtime = runtime
	self.tasks = {}
	self.frameTasks = {}
	self.nativeTasks = {}
	self.pendingTasks = {}
	self.nextId = 1
	self.paused = false
	self.timerManager = Scheduler.getTimerManager()
	self.tickManager = Scheduler.getTickManager()
	self.tickInterval = nil

	return self
end

function Scheduler.getTimerManager()
	local ok, timerManager = SafeCallbackWithStatusAndReturn(require, "Core.Timer.TimerManager")

	if ok then
		return timerManager
	end

	return nil
end

function Scheduler.getTickManager()
	local ok, tickManager = SafeCallbackWithStatusAndReturn(require, "Core.Common.TickManager")

	if ok then
		return tickManager
	end

	return nil
end

function Scheduler.getGlobalTimeScale()
	if pg.game then
		return pg.game.globalTimeScale or 1
	end

	return 1
end

function Scheduler:getScaledElapsed(deltaTime)
	local elapsed = math.max(tonumber(deltaTime) or 0, 0)

	return elapsed * Scheduler.getGlobalTimeScale()
end

function Scheduler:nextTaskId()
	local id = self.nextId

	self.nextId = id + 1

	return id
end

function Scheduler:refreshTickRegistration()
	local requiredInterval

	if next(self.frameTasks) ~= nil then
		requiredInterval = 0
	elseif next(self.tasks) ~= nil then
		requiredInterval = TIME_TICK_INTERVAL
	end

	if self.tickManager == nil then
		self.tickInterval = nil

		return
	end

	if requiredInterval == nil then
		if self.tickInterval ~= nil then
			self.tickManager.removeTick(self)

			self.tickInterval = nil
		end

		return
	end

	if self.tickInterval ~= requiredInterval then
		self.tickManager.addTick(self, requiredInterval)

		self.tickInterval = requiredInterval
	end
end

function Scheduler:invokeTask(task)
	local isPassTokenValid

	if self.runtime.isPassTokenValid ~= nil then
		isPassTokenValid = self.runtime:isPassTokenValid(task.passToken)
	else
		isPassTokenValid = self.runtime.isActive and task.passToken == self.runtime.passToken
	end

	if not isPassTokenValid then
		return
	end

	if self.paused then
		self.pendingTasks[#self.pendingTasks + 1] = task

		return
	end

	local ok, err = SafeCallbackWithStatusAndReturn(task.callback)

	if not ok and UNITY_EDITOR then
		local RuntimeDebug = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.RuntimeDebug")

		RuntimeDebug.runtimeDiagnostic(self.runtime, "RuntimeError", nil, {
			source = "Scheduler",
			nodeId = task.nodeId,
			error = tostring(err)
		}, "OrderedStrict")
	end
end

function Scheduler:delay(nodeId, seconds, callback, kind)
	local id = self:nextTaskId()
	local duration = tonumber(seconds) or 0
	local task = {
		id = id,
		nodeId = nodeId,
		callback = callback,
		passToken = self.runtime.passToken,
		kind = kind or "delay",
		remaining = duration
	}

	if duration <= 0 then
		self:invokeTask(task)

		return id
	end

	self.tasks[id] = task

	self:refreshTickRegistration()

	return id
end

function Scheduler:delayFrame(nodeId, frames, callback)
	local id = self:nextTaskId()
	local task = {
		kind = "frame",
		id = id,
		nodeId = nodeId,
		callback = callback,
		passToken = self.runtime.passToken
	}

	if self.timerManager ~= nil and self.timerManager.addSpecificFrameCb ~= nil then
		local ok, frameId = SafeCallbackWithStatusAndReturn(self.timerManager.addSpecificFrameCb, tonumber(frames) or 0, false, function()
			self.nativeTasks[id] = nil

			self:invokeTask(task)
		end)

		if ok then
			task.nativeId = frameId
			self.nativeTasks[id] = task

			return id
		end
	end

	task.remainingFrames = math.max(math.floor(tonumber(frames) or 0), 1)
	self.frameTasks[id] = task

	self:refreshTickRegistration()

	return id
end

function Scheduler:startTimeout(nodeId, seconds, onTimeout)
	return self:delay(nodeId, seconds, onTimeout, "timeout")
end

function Scheduler:cancelNativeTask(id, task)
	if self.timerManager ~= nil and task ~= nil and task.nativeId ~= nil and self.timerManager.delFrameCb ~= nil then
		self.timerManager.delFrameCb(task.nativeId)
	end

	self.nativeTasks[id] = nil
end

function Scheduler:cancelTimeout(nodeId)
	for id, task in pairs(self.tasks) do
		if task.nodeId == nodeId and task.kind == "timeout" then
			self.tasks[id] = nil
		end
	end

	for id, task in pairs(self.frameTasks) do
		if task.nodeId == nodeId and task.kind == "timeout" then
			self.frameTasks[id] = nil
		end
	end

	for id, task in pairs(self.nativeTasks) do
		if task.nodeId == nodeId and task.kind == "timeout" then
			self:cancelNativeTask(id, task)
		end
	end

	for index = #self.pendingTasks, 1, -1 do
		local task = self.pendingTasks[index]

		if task.nodeId == nodeId and task.kind == "timeout" then
			table.remove(self.pendingTasks, index)
		end
	end

	self:refreshTickRegistration()
end

function Scheduler:pause()
	self.paused = true
end

function Scheduler:resume()
	self.paused = false

	while not self.paused and self.runtime.isActive and #self.pendingTasks > 0 do
		local task = table.remove(self.pendingTasks, 1)

		self:invokeTask(task)
	end
end

function Scheduler:tick(deltaTime)
	if not self.runtime.isActive then
		self:cancelAll()

		return
	end

	local ready = {}
	local elapsed = self:getScaledElapsed(deltaTime)

	for id, task in pairs(self.tasks) do
		task.remaining = task.remaining - elapsed

		if task.remaining <= TIME_EPSILON then
			ready[#ready + 1] = task
			self.tasks[id] = nil
		end
	end

	for id, task in pairs(self.frameTasks) do
		task.remainingFrames = task.remainingFrames - 1

		if task.remainingFrames <= 0 then
			ready[#ready + 1] = task
			self.frameTasks[id] = nil
		end
	end

	table.sort(ready, function(left, right)
		return left.id < right.id
	end)

	for _, task in ipairs(ready) do
		self:invokeTask(task)

		if not self.runtime.isActive then
			break
		end
	end

	self:refreshTickRegistration()
end

function Scheduler:cancelAll()
	for id, task in pairs(self.nativeTasks) do
		self:cancelNativeTask(id, task)
	end

	self.tasks = {}
	self.frameTasks = {}
	self.nativeTasks = {}
	self.pendingTasks = {}

	self:refreshTickRegistration()
end

return Scheduler
