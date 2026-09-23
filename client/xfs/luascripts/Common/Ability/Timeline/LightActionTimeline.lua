-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\LightActionTimeline.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local SafeCallback = require("Core.Framework.SafeCallback")
local CombatLogger = require("Common.Ability.CombatLogger")
local Const = require("Common.Const.Const")
local AbilityObject = require("Common.Ability.AbilityObject")
local Utils = require("Common.Utils.Utils")
local ListPool = require("Common.Container.ListPool")
local Lume = require("Core.Common.lume")
local ToBool = ToBool
local pg = pg
local LightActionTimeline = Class.LiteClass("LightActionTimeline", AbilityObject)

function LightActionTimeline:ctor(owner, layer)
	AbilityObject.ctor(self)
	self:setOwner(owner)

	self.layer = layer

	self:clear()

	self.activeNotifyStates = {}
	self.exitCallbacks = {}
	self.timelineParams = ActionTimelineParams.new()
	self.pendingTimelineCmdParams = ActionTimelineParams.PendingTimelineCmdParams.new()
	self.timelineTemplate = nil
	self.isEnd = false
	self.notifyStateLastTickTimes = {}
	self.notifyStateTickCntMap = {}
	self.lastNotifyIndex = 0
	self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_NONE
end

function LightActionTimeline:init()
	self:clear()
end

function LightActionTimeline:clearObject()
	for _, fun in ipairs(self.exitCallbacks) do
		local isOk, result = xpcall(fun, debug.traceback)

		if not isOk and LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.logException("Ability clear error", result)
		end
	end

	if self.observer then
		self.observer:unlistenAll()
	end

	for _, timerId in pairs(self.timerMap) do
		self.owner:removeEntityTimer(timerId)
	end

	self:resetAbilityObjectData()

	if self.combatContext then
		local combatContext = self.combatContext

		self.combatContext = nil
		combatContext.refCnt = 0
		combatContext.isDead = true

		pg.global.abilityMgr:returnCombatContextToPool(combatContext)
	end
end

function LightActionTimeline:resetData()
	self.isPlaying = false
	self.lock = 0
	self.prevTimeStep = 0
	self.curTimeStep = 0
	self.timelineId = 0
	self.playRate = 0
	self.length = 0
	self.loop = false
	self.maxLoopCnt = 0
	self.curLoopCnt = 0
	self.isPermanent = false
end

function LightActionTimeline:isLock()
	return self.lock > 0
end

function LightActionTimeline:clear()
	self:resetData()

	self.pendingTimelineCmdParams = ActionTimelineParams.PendingTimelineCmdParams.new()
end

function LightActionTimeline:tick(deltaTime)
	self:tickTimeline(deltaTime)
	self:flush()
end

function LightActionTimeline:setTimeline(timelineId, playRate, timelineParams)
	if not pg.global.abilityMgr:getTimelineTemplate(timelineId) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("@jqj timelineTemplate not found", timelineId)
		end

		return false
	end

	self.pendingTimelineCmdParams:pushCmdSet(timelineId, playRate, timelineParams)

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

	self:flush()

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

	return true
end

function LightActionTimeline:continueTimeline(timelineId, playRate, forceJump)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@hyj continueTimeline", self:checkPushCmdToPending(AbilityConst.ACTION_TIMELINE_CMD_CONTINUE), self.timelineId, timelineId)
	end

	if not self:checkPushCmdToPending(AbilityConst.ACTION_TIMELINE_CMD_CONTINUE, forceJump) then
		return
	end

	self:addContinueCmdMark()
	self.pendingTimelineCmdParams:pushCmdContinue(timelineId, playRate, self.timelineParams)

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

	self:flush()

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1
end

function LightActionTimeline:stopTimeline()
	if not self.isPlaying then
		return false
	end

	self.pendingTimelineCmdParams:pushCmdStop()
	self:flush()

	return true
end

function LightActionTimeline:resetTimeline()
	if not self.isPlaying then
		return false
	end

	self.pendingTimelineCmdParams:pushCmdReset()
	self:flush()

	return true
end

function LightActionTimeline:checkPushCmdToPending(type, forceJump)
	if not forceJump and type == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
		if self.cmdMark == AbilityConst.ACTION_TIMELINE_CMD_STOP then
			return false
		end

		if self.pendingTimelineCmdParams.cmd == AbilityConst.ACTION_TIMELINE_CMD_SET then
			return false
		elseif self.pendingTimelineCmdParams.cmd == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
			return false
		end
	end

	return true
end

function LightActionTimeline:addContinueCmdMark()
	self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_CONTINUE
end

function LightActionTimeline:clearContinueCmdMark()
	if self.cmdMark == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
		self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_NONE
	end
end

function LightActionTimeline:tickTimeline(deltaSeconds)
	if not self.isPlaying then
		return
	end

	if self.frameFreezeDuration then
		self.frameFreezeDuration = self.frameFreezeDuration - deltaSeconds
	end

	deltaSeconds = deltaSeconds * self.playRate

	if self.frameFreezeDuration and self.frameFreezeDuration < 0 then
		self.frameFreezeDuration = nil
		self.playRate = 1
	end

	self.prevTimeStep = self.curTimeStep
	self.curTimeStep = self.curTimeStep + deltaSeconds

	self:stepAdvance()

	if self.curTimeStep > self.length and not self.isPermanent then
		if self.loop then
			if self.maxLoopCnt > 0 then
				self.curLoopCnt = self.curLoopCnt + 1

				if self.curLoopCnt >= self.maxLoopCnt then
					self:stopTimelineInternal(false)

					return
				else
					self.lastNotifyIndex = 0

					Lume.clear(self.notifyStateLastTickTimes)
					Lume.clear(self.notifyStateTickCntMap)
				end
			end

			self.prevTimeStep = 0
			self.curTimeStep = 0

			Lume.clear(self.notifyStateLastTickTimes)
			Lume.clear(self.notifyStateTickCntMap)
			Lume.clear(self.activeNotifyStates)
			Lume.clear(self.exitCallbacks)
		else
			self:stopTimelineInternal(false)
		end
	end
end

function LightActionTimeline:doLockGuard(fun, ...)
	self.lock = self.lock + 1

	local isOk, result = xpcall(fun, debug.traceback, self, ...)

	if not isOk then
		CombatLogger.logException("doLockGuard error", result)
	end

	self.lock = self.lock - 1
end

function LightActionTimeline:doNotifyEnter(prevTimeStep, curTimeStep, ctx)
	local entity = self.owner
	local events = self.timeline.timelineNotifyEvents

	for idx = self.lastNotifyIndex + 1, #events do
		if self.isEnd then
			return
		end

		local event = events[idx]

		if event:isNotifyActivate(prevTimeStep, curTimeStep) then
			event:executeNotify(entity, ctx)

			self.lastNotifyIndex = idx
		else
			return
		end
	end
end

function LightActionTimeline:stepAdvance()
	if self.timeline == nil then
		return
	end

	local prevTimeStep = self.prevTimeStep
	local curTimeStep = self.curTimeStep

	self:doLockGuard(self.doNotifyEnter, prevTimeStep, curTimeStep, self.combatContext)
	self:doLockGuard(self.doNotifyStateTimeNode, prevTimeStep, curTimeStep, self.combatContext)
end

function LightActionTimeline:doNotifyStateTimeNode(prevTimeStep, curTimeStep, ctx)
	local events = self.timeline.timelineNotifyStateNodes

	for idx = self.lastTimeNodeIndex + 1, #events do
		local timeNode = self.timeline.timelineNotifyStateNodes[idx]

		if prevTimeStep <= timeNode.time and curTimeStep > timeNode.time then
			if timeNode.nodeType == AbilityConst.NOTIFY_STATE_TIME_NODE_ENTER then
				timeNode.notifyState:executeNotifyStateEnter(self.owner, ctx, self.startGameTime)
				table.insert(self.activeNotifyStates, timeNode.notifyState)

				self.notifyStateLastTickTimes[timeNode.notifyState] = timeNode.time
				self.notifyStateTickCntMap[timeNode.notifyState] = 0
			else
				local lastTickTime = self.notifyStateLastTickTimes[timeNode.notifyState] or 0
				local result, lastTickTime, tickCnt = timeNode.notifyState:executeNotifyStateUpdate(self.owner, ctx, timeNode.time, lastTickTime, self.startGameTime, self.notifyStateTickCntMap[timeNode.notifyState])

				if result then
					self.notifyStateLastTickTimes[timeNode.notifyState] = lastTickTime
					self.notifyStateTickCntMap[timeNode.notifyState] = tickCnt
				end

				timeNode.notifyState:executeNotifyStateExit(self.owner, ctx)
				Lume.removeFromArr(self.activeNotifyStates, timeNode.notifyState)

				self.notifyStateLastTickTimes[timeNode.notifyState] = nil
				self.notifyStateTickCntMap[timeNode.notifyState] = nil
			end

			self.lastTimeNodeIndex = idx
		else
			break
		end
	end

	for idx, state in ipairs(self.activeNotifyStates) do
		if self.isEnd then
			return
		end

		local lastTickTime = self.notifyStateLastTickTimes[state] or 0
		local result, lastTickTime, tickCnt = state:executeNotifyStateUpdate(self.owner, ctx, self.curTimeStep, lastTickTime, self.startGameTime, self.notifyStateTickCntMap[state])

		if result then
			self.notifyStateLastTickTimes[state] = lastTickTime
			self.notifyStateTickCntMap[state] = tickCnt
		end
	end
end

function LightActionTimeline:flush()
	if self.pendingTimelineCmdParams.cmd == AbilityConst.ACTION_TIMELINE_CMD_NONE then
		return
	end

	local cmd = self.pendingTimelineCmdParams.cmd

	if cmd == AbilityConst.ACTION_TIMELINE_CMD_STOP then
		if not self:isLock() then
			self:clearContinueCmdMark()

			self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_STOP

			self.pendingTimelineCmdParams:clear()
			self:stopTimelineInternal(true)

			self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_NONE
		end
	elseif cmd == AbilityConst.ACTION_TIMELINE_CMD_RESET then
		if not self:isLock() then
			self:clearContinueCmdMark()
			self.pendingTimelineCmdParams:clear()
			self:stopTimelineInternal(false)
		end
	elseif cmd == AbilityConst.ACTION_TIMELINE_CMD_SET then
		if not self:isLock() then
			if self.isPlaying then
				self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

				self:stopTimelineInternal(true)
				self:flush()

				self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

				return
			else
				self:clearContinueCmdMark()

				self.timelineId = self.pendingTimelineCmdParams.timelineId
				self.playRate = self.pendingTimelineCmdParams.playRate or 1

				self.timelineParams:assign(self.pendingTimelineCmdParams.timelineParams)
				self.pendingTimelineCmdParams:clear()
				self:playTimelineInternal()

				return
			end
		end
	elseif cmd == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE and not self:isLock() then
		if self.isPlaying then
			self:stopTimelineInternal(true)
			self:flush()

			return
		else
			self:clearContinueCmdMark()

			self.timelineId = self.pendingTimelineCmdParams.timelineId
			self.playRate = self.pendingTimelineCmdParams.playRate or 1

			self.timelineParams:assign(self.pendingTimelineCmdParams.timelineParams)
			self.pendingTimelineCmdParams:clear()
			self:playTimelineInternal(true)

			return
		end
	end
end

function LightActionTimeline:doEnterTimelineEvents()
	local entity = self.owner

	for _, event in ipairs(self.timeline.timelineEnterEvents) do
		event:executeEvent(entity, self.combatContext)
	end
end

function LightActionTimeline:playTimelineInternal(isContinue)
	self.timeline = pg.global.abilityMgr:getTimelineTemplate(self.timelineId)

	Lume.clear(self.notifyStateLastTickTimes)
	Lume.clear(self.notifyStateTickCntMap)

	self.lastNotifyIndex = 0
	self.lastTimeNodeIndex = 0

	Lume.clear(self.activeNotifyStates)

	self.isEnd = false

	if self.timeline == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("@jqj Invalid timelineId", self.timelineId)
		end

		return
	end

	self.isPlaying = true
	self.prevTimeStep = 0
	self.curTimeStep = 0
	self.length = self.timeline.length

	if self.length == -1 then
		self.isPermanent = true
	end

	if self.owner.authority == Const.AUTHORITY_SIMULATED_PROXY and not self.isPermanent then
		self.length = self.length + AbilityConst.MAX_DELAY_TIME
	end

	self.loop = self.timeline.loop
	self.maxLoopCnt = self.timeline.maxLoopCnt
	self.curLoopCnt = 0
	self.startGameTime = self.owner:getGameTime()

	self:initCombatContext()
	self:doLockGuard(self.doEnterTimelineEvents)
end

function LightActionTimeline:doStopTimelineEvents()
	local entity = self.owner

	for _, event in ipairs(self.timeline.timelineExitEvents) do
		event:executeEvent(entity, self.combatContext)
	end

	for _, event in ipairs(self.activeNotifyStates) do
		event:executeNotifyStateExit(entity, self.combatContext)
	end

	Lume.clear(self.activeNotifyStates)

	for _, fun in ipairs(self.exitCallbacks) do
		fun()
	end

	Lume.clear(self.exitCallbacks)
end

function LightActionTimeline:addExitCallback(fun)
	self.exitCallbacks[#self.exitCallbacks + 1] = fun
end

function LightActionTimeline:clearExitCallback()
	Lume.clear(self.exitCallbacks)
end

function LightActionTimeline:stopTimelineInternal(interrupt, isContinue)
	if not self.isPlaying then
		return
	end

	if self.timeline == nil then
		self:clear()

		return
	end

	self:doLockGuard(self.doStopTimelineEvents)

	self.isEnd = true

	self:clearObject()
	self:resetData()
	Lume.clear(self.activeNotifyStates)

	if self.cmdMark == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
		return
	end

	if self.timelineParams.combatParams then
		pg.global.abilityMgr.combatParamsPool:returnObject(self.timelineParams.combatParams)
	end
end

function LightActionTimeline:initCombatContext()
	local actionTimelineContext = pg.global.abilityMgr.combatContextPool:get(true)

	actionTimelineContext:init(self.owner.actorId)

	actionTimelineContext.ctxType = AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE
	actionTimelineContext.refCnt = 1

	if not actionTimelineContext then
		local errorMsg = string.format("lightActionTimelineContext init failed, actorId %d", self.owner.actorId)

		error(errorMsg)

		return
	end

	self.combatContext = actionTimelineContext
	actionTimelineContext.BPName = self.timeline.BPName
	actionTimelineContext.srcCombatContextId = actionTimelineContext.id
	self.combatContext.timelineId = self.timelineId

	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		local combatTimelineParam = self.timelineParams.combatParams

		actionTimelineContext:setConstCasterInfo(combatTimelineParam.constCasterInfo, combatTimelineParam.srcActorId)

		actionTimelineContext.srcType = combatTimelineParam.srcType
		actionTimelineContext.castingCombatContextId = combatTimelineParam.castingCombatContextId

		local targetHitPos = combatTimelineParam.hitPos
		local hitIdx = combatTimelineParam.hitIdx

		if ToBool(combatTimelineParam.targetActorId) then
			actionTimelineContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

			actionTimelineContext.runtimeTargetInfo:initTarget(combatTimelineParam.targetActorId, targetHitPos, hitIdx, nil, true)
		else
			actionTimelineContext.runtimeTargetInfo = nil
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("Invalid timelineKind", self.timelineParams.timelineKind)
	end

	actionTimelineContext:initNodeMap()
end

function LightActionTimeline:setFrameFreeze(playRate, duration)
	if duration > 0 then
		self.playRate = playRate
		self.frameFreezeDuration = duration
	end
end

function LightActionTimeline:getRemainingTime()
	if self.isPermanent then
		return math.maxFloat
	end

	return self.length - self.curTimeStep
end

return LightActionTimeline
