-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\ActionTimeline.lua

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
local ImpulseData = require("Data.impulse_data")
local Lume = require("Core.Common.lume")
local ToBool = ToBool
local pg = pg
local ActionTimeline = Class.LiteClass("ActionTimeline", AbilityObject)

function ActionTimeline:ctor(owner, layer)
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

function ActionTimeline:init()
	self:clear()
end

function ActionTimeline:resetData()
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

function ActionTimeline:isLock()
	return self.lock > 0
end

function ActionTimeline:clear()
	self:resetData()

	self.pendingTimelineCmdParams = ActionTimelineParams.PendingTimelineCmdParams.new()
end

function ActionTimeline:tick(deltaTime)
	self:tickTimeline(deltaTime)
	self:flush()
end

function ActionTimeline:setTimeline(timelineId, playRate, timelineParams)
	self.pendingTimelineCmdParams:pushCmdSet(timelineId, playRate, timelineParams)

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

	self:flush()

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

	self.owner:refreshAbilityMask(self.ability)
end

function ActionTimeline:continueTimeline(timelineId, playRate, forceJump)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		CombatLogger.debug("@hyj continueTimeline", self:checkPushCmdToPending(AbilityConst.ACTION_TIMELINE_CMD_CONTINUE), self.timelineId, timelineId)
	end

	if not self:checkPushCmdToPending(AbilityConst.ACTION_TIMELINE_CMD_CONTINUE, forceJump) then
		return
	end

	if not self.combatContext then
		return
	end

	self:addContinueCmdMark()
	self.pendingTimelineCmdParams:pushCmdContinue(timelineId, playRate, self.timelineParams)

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

	self:flush()

	self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

	self.owner:refreshAbilityMask(self.ability)
end

function ActionTimeline:stopTimeline()
	if not self.isPlaying then
		return false
	end

	self.pendingTimelineCmdParams:pushCmdStop()
	self:flush()
	self.owner:refreshAbilityMask(self.ability)

	return true
end

function ActionTimeline:resetTimeline()
	if not self.isPlaying then
		return false
	end

	self.pendingTimelineCmdParams:pushCmdReset()
	self:flush()
	self.owner:refreshAbilityMask(self.ability)

	return true
end

function ActionTimeline:checkPushCmdToPending(type, forceJump)
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

function ActionTimeline:addContinueCmdMark()
	self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_CONTINUE

	if self.ability then
		local abilityId = self.ability.abilityId

		if self.ability:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Attack then
			self.owner:addAttackCombatTimelineRef(abilityId)
		else
			self.owner:addSkillCombatTimelineRef(abilityId)
		end
	end
end

function ActionTimeline:clearContinueCmdMark()
	if self.cmdMark == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
		self.cmdMark = AbilityConst.ACTION_TIMELINE_CMD_NONE

		if self.ability then
			local abilityId = self.ability.abilityId

			if self.ability:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Attack then
				self.owner:removeAttackCombatTimelineRef(abilityId)
			else
				self.owner:removeSkillCombatTimelineRef(abilityId)
			end
		end
	end
end

function ActionTimeline:tickTimeline(deltaSeconds)
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

function ActionTimeline:doLockGuard(fun, ...)
	self.lock = self.lock + 1

	local isOk, result = xpcall(fun, debug.traceback, self, ...)

	if not isOk then
		CombatLogger.logException("doLockGuard error", result)
	end

	self.lock = self.lock - 1
end

function ActionTimeline:doNotifyEnter(prevTimeStep, curTimeStep, ctx)
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

function ActionTimeline:stepAdvance()
	if self.timeline == nil then
		return
	end

	local prevTimeStep = self.prevTimeStep
	local curTimeStep = self.curTimeStep

	self:doLockGuard(self.doNotifyEnter, prevTimeStep, curTimeStep, self.combatContext)
	self:doLockGuard(self.doNotifyStateTimeNode, prevTimeStep, curTimeStep, self.combatContext)
end

function ActionTimeline:doNotifyStateTimeNode(prevTimeStep, curTimeStep, ctx)
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

function ActionTimeline:flush()
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

				self.owner:refreshAbilityMask(self.ability)

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
			self.owner:refreshAbilityMask(self.ability)

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

function ActionTimeline:doEnterTimelineEvents()
	local entity = self.owner
	local ability = self:getAbility()

	if pg.component == "client" and not entity.deformData and ability and ability:isStolenAbility() then
		entity:doAbilityDeform(ability)
	end

	for _, event in ipairs(self.timeline.timelineEnterEvents) do
		event:executeEvent(entity, self.combatContext)
	end

	if entity.playModelShake and self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		local impulseId = self.timelineParams.hitParams.impulseId
		local impulseData = ImpulseData[impulseId]

		if impulseData and impulseData.modelShakeId then
			entity:playModelShake(impulseData.modelShakeId)
		end
	end

	if entity.addHitImpulse and self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT and self.timelineParams.hitParams.attackForceType == AbilityConst.ATTACK_FORCE_KNOCK_UP then
		local hitParams = self.timelineParams.hitParams
		local impulseH, impulseV = hitParams:getImpulse(entity:isInAir())

		entity:addHitImpulse(impulseH, impulseV, hitParams.impulseDir, hitParams.impulseId, hitParams.airAttackLevel)

		self.timelineParams.hitParams.impulseH = nil
		self.timelineParams.hitParams.impulseV = nil
		self.timelineParams.hitParams.impulseDir = nil
	end

	if self.timelineParams.hitParams then
		local attackForceType = self.timelineParams.hitParams.attackForceType

		if attackForceType == AbilityConst.ATTACK_FORCE_KNOCK_LIGHT or attackForceType == AbilityConst.ATTACK_FORCE_KNOCK_HEAVY then
			self:getObserver():listen(self.owner.subject, AbilityConst.COMBAT_EVENT_STUN_ON_COLLISION, function(tag)
				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					CombatLogger.debug("stunOnCollisionCallback", self.owner.actorId, tag)
				end
			end)
		end
	end
end

function ActionTimeline:playTimelineInternal(isContinue)
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

	if self.timelineParams.hitParams and self.timelineParams.hitParams.overrideTimeLength then
		self.length = self.timelineParams.hitParams.overrideTimeLength
	end

	if self.length == -1 then
		self.isPermanent = true
	end

	if self.owner.authority == Const.AUTHORITY_SIMULATED_PROXY and not self.isPermanent then
		self.length = self.length + AbilityConst.MAX_DELAY_TIME
	end

	self.loop = self.timeline.loop
	self.maxLoopCnt = self.timeline.maxLoopCnt
	self.curLoopCnt = 0
	self.ability = self:getAbility()
	self.startGameTime = self.owner:getGameTime()

	if not Utils.isCreation(self.owner) and not Utils.isSpellField(self.owner) then
		if self.timeline.isSkillTimeline and self.ability and self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
			local oldCnt = self.owner.combatTimelineRef.cnt

			if oldCnt == 0 then
				self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_CAST, true, self:getAbilityId())
			end

			if self.ability:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Attack then
				self.owner:addAttackCombatTimelineRef(self.ability.abilityId)
				self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_ATTACK, true, self.ability.abilityId)
			else
				self.owner:addSkillCombatTimelineRef(self.ability.abilityId)
				self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_SKILL, true, self.ability.abilityId)
			end

			self.owner:refreshAbilityMask(self.ability)

			if oldCnt == 0 and self.ability:getAbilityTemplate().abilityType ~= AbilityConst.EnumAbilityType.Ultimate then
				self.owner:setActionMask(AbilityConst.ACTION_MASK_CANCELLABLE, true)
			end
		elseif self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
			local attackForceType = self.timelineParams.hitParams.attackForceType

			if attackForceType ~= AbilityConst.ATTACK_FORCE_KNOCK_NONE and attackForceType ~= AbilityConst.ATTACK_FORCE_KNOCK_SHAKE then
				self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_HIT, true)
			end
		end
	end

	if isContinue then
		self:updateCombatContextTimelineInfo()
	else
		self:initCombatContext()
	end

	self:doLockGuard(self.doEnterTimelineEvents)

	if not isContinue then
		self.owner:addAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.TIMELINE)
	end
end

function ActionTimeline:doStopTimelineEvents()
	local entity = self.owner

	for _, event in ipairs(self.timeline.timelineExitEvents) do
		event:executeEvent(entity, self.combatContext)
	end

	for _, event in ipairs(self.activeNotifyStates) do
		event:executeNotifyStateExit(entity, self.combatContext)
	end

	Lume.clear(self.activeNotifyStates)

	if not Utils.isCreation(self.owner) and not Utils.isSpellField(self.owner) and self.ability and self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		local abilityId = self.ability.abilityId

		if self.timeline.isSkillTimeline then
			if self.ability:getAbilityTemplate().abilityType == AbilityConst.EnumAbilityType.Attack then
				self.owner:removeAttackCombatTimelineRef(abilityId)
			else
				self.owner:removeSkillCombatTimelineRef(abilityId)
			end
		end

		local timelineCnt = self.owner.combatTimelineRef.cnt

		if timelineCnt == 0 then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj onAbilityEnd", abilityId, self.timelineId)
			end

			self.owner:onAbilityEnd(self.ability)
		end
	end

	for _, fun in ipairs(self.exitCallbacks) do
		fun()
	end

	Lume.clear(self.exitCallbacks)
end

function ActionTimeline:addExitCallback(fun)
	self.exitCallbacks[#self.exitCallbacks + 1] = fun
end

function ActionTimeline:clearExitCallback()
	Lume.clear(self.exitCallbacks)
end

function ActionTimeline:stopTimelineInternal(interrupt, isContinue)
	if not self.isPlaying then
		return
	end

	if self.timeline == nil then
		self:clear()

		return
	end

	local isFromDialogueGraph = self.combatContext and self.combatContext.constCasterInfo and self.combatContext.constCasterInfo.castSource == AbilityConst.CAST_SOURCE.DIALOGUE_GRAPH

	if interrupt == false and pg.component == "client" and self.owner.authority == Const.AUTHORITY_MASTER and not isFromDialogueGraph then
		self.owner:serverMsg("RPC_CS_StopTimelineByTime", AbilityConst.TIMELINE_LAYER_STR_TO_INT[self.timeline.layer], self.timeline.id)
	end

	self:doLockGuard(self.doStopTimelineEvents)

	self.isEnd = true

	AbilityObject.clearObject(self)
	self:resetData()
	Lume.clear(self.activeNotifyStates)
	self.owner:refreshAbilityMask(self.ability)

	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_HIT, false)
		self.owner:setActionMask(AbilityConst.ACTION_MASK_IN_HIT_BACKSWING, false)

		if self.owner.updateStateCache then
			self.owner:updateStateCache("THORNS_HIT_ST")
		end
	end

	if self.cmdMark == AbilityConst.ACTION_TIMELINE_CMD_CONTINUE then
		return
	end

	self.owner:removeAbilityTickReason(AbilityConst.ABILITY_TICK_REASONS.TIMELINE)

	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		if self.timelineParams.combatParams then
			pg.global.abilityMgr.combatParamsPool:returnObject(self.timelineParams.combatParams)
		end
	elseif self.timelineParams.hitParams then
		pg.global.abilityMgr.hitParamsPool:returnObject(self.timelineParams.hitParams)
	end
end

function ActionTimeline:getAbility()
	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		local combatTimelineParam = self.timelineParams.combatParams
		local srcAbilityId = combatTimelineParam.srcAbilityId
		local srcAbility

		if combatTimelineParam.srcType == AbilityConst.SRC_TYPE_CREATION and combatTimelineParam.srcCreation and combatTimelineParam.srcCreation.master and combatTimelineParam.srcAbilityId then
			srcAbility = combatTimelineParam.srcCreation.master:getRawAbility(combatTimelineParam.srcAbilityId, combatTimelineParam.srcAbilityStoreType)
		end

		if srcAbility == nil then
			local srcEntity = pg.getEntityByActorId(combatTimelineParam.srcActorId)

			if srcEntity then
				srcAbility = srcEntity:getRawAbility(srcAbilityId, combatTimelineParam.srcAbilityStoreType)
			end
		end

		return srcAbility
	elseif self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		local srcAbilityId = self.timelineParams.hitParams.attackerAbilityId
		local attackerEntity = pg.getEntityByActorId(self.timelineParams.hitParams.attackerActorId)
		local srcAbility = attackerEntity and attackerEntity:getRawAbility(srcAbilityId, self.timelineParams.hitParams.attackerAbilityStoreType)

		return srcAbility
	end
end

function ActionTimeline:getAbilityId()
	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		local combatTimelineParam = self.timelineParams.combatParams

		return combatTimelineParam.srcAbilityId
	elseif self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		return self.timelineParams.hitParams.attackerAbilityId
	end
end

function ActionTimeline:initCombatContext()
	local id = self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT and self.timelineParams.combatParams.combatContextId or self.timelineParams.hitParams.combatContextId
	local actionTimelineContext = self.owner:getCombatContextFromCache(AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE, id)

	if not actionTimelineContext then
		local errorMsg = string.format("actionTimelineContext init failed, timelineKind %d combatContextId %d hitCombatContextId %d, actorId %d", self.timelineParams.timelineKind, self.timelineParams.combatParams and self.timelineParams.combatParams.combatContextId or 0, self.timelineParams.hitParams and self.timelineParams.hitParams.combatContextId or 0, self.owner.actorId)

		error(errorMsg)

		return
	end

	self.combatContext = actionTimelineContext
	actionTimelineContext.BPName = self.timeline.BPName
	actionTimelineContext.srcCombatContextId = actionTimelineContext.id
	actionTimelineContext.srcCastingCombatContextId = self.owner.srcCastingCombatContextId
	self.combatContext.timelineId = self.timelineId

	if self.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		local combatTimelineParam = self.timelineParams.combatParams

		actionTimelineContext:setConstCasterInfo(combatTimelineParam.constCasterInfo, combatTimelineParam.srcActorId)

		actionTimelineContext.abilityId = self.ability and self.ability.abilityId
		actionTimelineContext.abilityStoreType = combatTimelineParam.srcAbilityStoreType
		actionTimelineContext.randomPointPos = combatTimelineParam.randomPointPos
		actionTimelineContext.srcType = combatTimelineParam.srcType
		actionTimelineContext.castingCombatContextId = combatTimelineParam.castingCombatContextId
		actionTimelineContext.attackSpeed = combatTimelineParam.attackSpeed or 1

		local abilityCombatContext = self.ability and self.ability:getAbilityObject().combatContext

		actionTimelineContext.curEpCost = abilityCombatContext and abilityCombatContext.curEpCost

		if self.owner.setCastingCombatCcontextId then
			self.owner:setCastingCombatCcontextId(self.ability and self.ability.abilityId, actionTimelineContext.castingCombatContextId)
		end

		local targetHitPos = combatTimelineParam.hitPos
		local hitIdx = combatTimelineParam.hitIdx

		if ToBool(combatTimelineParam.targetActorId) then
			actionTimelineContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

			actionTimelineContext.runtimeTargetInfo:initTarget(combatTimelineParam.targetActorId, targetHitPos, hitIdx, nil, true)
		else
			actionTimelineContext.runtimeTargetInfo = nil
		end
	elseif self.timelineParams.timelineKind == AbilityConst.TIMELINE_HIT then
		local srcAbility = self.ability

		actionTimelineContext:setConstCasterInfo(self.timelineParams.hitParams.constCasterInfo, self.timelineParams.hitParams.attackerActorId)

		actionTimelineContext.abilityId = srcAbility and srcAbility.abilityId
		actionTimelineContext.abilityStoreType = srcAbility and srcAbility.storeType
		actionTimelineContext.srcType = self.timelineParams.hitParams.srcType
		actionTimelineContext.ctxType = AbilityConst.COMBAT_CONTEXT_TYPE_TIMELINE

		local targetHitPos = self.timelineParams.hitParams.targetHitPos
		local hitIdx = self.timelineParams.hitParams.hitIdx

		if ToBool(self.timelineParams.hitParams.targetActorId) then
			actionTimelineContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

			actionTimelineContext.runtimeTargetInfo:initTarget(self.timelineParams.hitParams.targetActorId, targetHitPos, hitIdx, self.timelineParams.hitParams.targetHitPartIdx, true)
		else
			actionTimelineContext.runtimeTargetInfo = nil
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		CombatLogger.error("Invalid timelineKind", self.timelineParams.timelineKind)
	end

	actionTimelineContext:initNodeMap()
end

function ActionTimeline:updateCombatContextTimelineInfo()
	self.owner:addCombatContextRefCnt(self.combatContext)

	self.combatContext.timelineId = self.timelineId

	self.combatContext:initNodeMap()

	self.combatContext.isDying = false
	self.combatContext.isDead = false
end

function ActionTimeline:setFrameFreeze(playRate, duration)
	if duration > 0 then
		self.playRate = playRate
		self.frameFreezeDuration = duration
	end
end

function ActionTimeline:getRemainingTime()
	if self.isPermanent then
		return math.maxFloat
	end

	return self.length - self.curTimeStep
end

return ActionTimeline
