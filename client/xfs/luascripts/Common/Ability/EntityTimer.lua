-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\EntityTimer.lua

local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local EntityTask = require("Common.Ability.EntityTask")
local lume = require("Core.Common.lume")
local taskPool = {}
local EntityTimer = Class.LiteClass("EntityTimer")

function EntityTimer:ctor(owner)
	self.owner = owner
	self.tasks = {}
	self.idCounter = 0
end

local executeTasks = {}

function EntityTimer:update(deltaTime)
	Lume.clear(executeTasks)

	for id, task in pairs(self.tasks) do
		task.duration = (task.duration or 0) - deltaTime

		if task.duration <= 0 then
			executeTasks[#executeTasks + 1] = task
			self.tasks[id] = nil
		end
	end

	table.sort(executeTasks, EntityTimer.cmp)

	for i = 1, #executeTasks do
		local task = executeTasks[i]
		local isOk, result = xpcall(task.func, debug.traceback)

		if not isOk then
			CombatLogger.error("call entity timer error", result)
		end

		taskPool[#taskPool + 1] = task

		lume.clear(task)
		self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ENTITY_TIMER)
	end

	Lume.clear(executeTasks)
end

function EntityTimer.cmp(a, b)
	if math.Approximately(a.duration, b.duration) then
		return a.id < b.id
	else
		return a.duration < b.duration
	end
end

function EntityTimer:add(duration, callback)
	self.idCounter = self.idCounter + 1
	duration = duration or 0

	local task
	local poolSize = #taskPool

	if poolSize > 0 then
		task = taskPool[poolSize]
		taskPool[poolSize] = nil

		task:ctor(self.idCounter, duration, callback)
	else
		task = EntityTask(self.idCounter, duration, callback)
	end

	self.tasks[self.idCounter] = task

	self.owner:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ENTITY_TIMER)

	return self.idCounter
end

function EntityTimer:remove(id)
	local task = self.tasks[id]

	if task then
		taskPool[#taskPool + 1] = task

		Lume.clear(task)
		self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ENTITY_TIMER)
	end

	self.tasks[id] = nil
end

function EntityTimer:clear()
	for id, task in pairs(self.tasks) do
		self.tasks[id] = nil
		taskPool[#taskPool + 1] = task

		lume.clear(task)
		self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.ENTITY_TIMER)
	end
end

return EntityTimer
