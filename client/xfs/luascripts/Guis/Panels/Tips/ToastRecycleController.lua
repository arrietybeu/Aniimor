-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\ToastRecycleController.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TipAreaConst = require("Guis.Panels.Tips.TipAreaConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ToastRecycleController")
local ToastRecycleController = Class.LightClass("ToastRecycleController")

function ToastRecycleController:ctor()
	self.tasks = {}
	self.nextCheck = 0
	self.destroying = false
end

function ToastRecycleController:reportError(task, stage, err)
	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("Toast recycle failed item=%s stage=%s reason=%s error=%s", task.item.itemKey, stage, task.reason or "start", tostring(err))
	end
end

function ToastRecycleController:runStep(task, stage, callback)
	local ok, err = xpcall(callback, debug.traceback)

	if not ok then
		self:reportError(task, stage, err)
	end

	return ok
end

function ToastRecycleController:request(item, data, force, target, exitEvent, immediate)
	if not item:hasRecycleData(data) then
		return
	end

	local task = item.__recycleTasks[data]

	if task then
		if force or immediate then
			self:finish(task, force and TipAreaConst.RECYCLE_REASON.FORCE or TipAreaConst.RECYCLE_REASON.NORMAL)
		end

		return task
	end

	local now = Time.realSecondCache

	task = {
		item = item,
		data = data,
		target = target,
		deadline = now + (item.recycleTimeout or TipAreaConst.RECYCLE_TIMEOUT)
	}

	if item:isTimelineSuspended() then
		task.suspendedAt = now
	end

	item.__recycleTasks[data] = task
	self.tasks[task] = true
	data.removing = true

	local started = self:runStep(task, "start", function()
		item:onRecycleStarted(data, target)
	end)

	if task.finished then
		return task
	end

	if not started then
		self:finish(task, TipAreaConst.RECYCLE_REASON.ERROR)

		return task
	end

	if force or immediate or self.destroying or item.__recycleDestroying then
		local reason = (self.destroying or item.__recycleDestroying) and TipAreaConst.RECYCLE_REASON.DESTROY or force and TipAreaConst.RECYCLE_REASON.FORCE or TipAreaConst.RECYCLE_REASON.NORMAL

		self:finish(task, reason)

		return task
	end

	local ok = self:runStep(task, "start", function()
		if not task.finished then
			item:playRecycleAnimation(data, target, exitEvent, function()
				self:finish(task, TipAreaConst.RECYCLE_REASON.NORMAL)
			end)
		end
	end)

	if not ok then
		self:finish(task, TipAreaConst.RECYCLE_REASON.ERROR)
	end

	return task
end

function ToastRecycleController:finish(task, reason)
	if task.finished then
		return
	end

	local item, data = task.item, task.data

	task.finished = true
	task.reason = reason
	self.tasks[task] = nil

	if item.__recycleTasks[data] ~= task then
		return
	end

	item.__recycleTasks[data] = nil

	if not item:hasRecycleData(data) then
		return
	end

	self:runStep(task, "remove", function()
		item:removeRecycleData(data)
	end)

	local cleaned = self:runStep(task, "cleanup", function()
		item:onRecycleCleanup(data, task.target, reason)
	end)

	if not cleaned then
		item.__invalidRecycleContent = task.target

		self:runStep(task, "isolate", function()
			if NotNil(task.target) then
				task.target:SetActive(false)
			end
		end)
	end

	self:runStep(task, "finished", function()
		item:onRecycleFinished(data, reason)
	end)

	item.__recycleStateDirty = true

	if item.owner then
		item.owner.recycleStateDirty = true
	end
end

function ToastRecycleController:invalidate(item, data)
	local task = item.__recycleTasks[data]

	if not task then
		return
	end

	task.finished = true
	self.tasks[task] = nil
	item.__recycleTasks[data] = nil
end

function ToastRecycleController:update(now)
	if now < self.nextCheck then
		return
	end

	self.nextCheck = now + TipAreaConst.RECYCLE_CHECK_INTERVAL

	for task in pairs(self.tasks) do
		if not task.item:hasRecycleData(task.data) then
			self:invalidate(task.item, task.data)
		elseif not task.suspendedAt and now >= task.deadline then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("Toast recycle timeout item=%s", task.item.itemKey)
			end

			self:finish(task, TipAreaConst.RECYCLE_REASON.TIMEOUT)
		end
	end
end

function ToastRecycleController:suspendItem(item)
	for _, task in pairs(item.__recycleTasks) do
		if not task.suspendedAt then
			task.suspendedAt = Time.realSecondCache
		end
	end
end

function ToastRecycleController:resumeItem(item)
	for _, task in pairs(item.__recycleTasks) do
		if task.suspendedAt then
			task.deadline = task.deadline + Time.realSecondCache - task.suspendedAt
			task.suspendedAt = nil
		end
	end
end

function ToastRecycleController:finishItem(item)
	while next(item.__recycleTasks) do
		local _, task = next(item.__recycleTasks)

		self:finish(task, TipAreaConst.RECYCLE_REASON.DESTROY)
	end
end

function ToastRecycleController:destroy()
	self.destroying = true

	while next(self.tasks) do
		self:finish(next(self.tasks), TipAreaConst.RECYCLE_REASON.DESTROY)
	end
end

return ToastRecycleController
