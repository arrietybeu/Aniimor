-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\BehaviacAgent\\Unit\\IBaseStateMachineComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local enums = require("Common.AI.Behaviac.Enums")
local AiConst = require("Common.Const.AiConst")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AI")
local EBTStatus = enums.EBTStatus
local EBTRootState = BaseEnum.EBTRootState
local IBaseStateMachineComponent = Class.Component("IBaseStateMachineComponent")

function IBaseStateMachineComponent:onInit()
	local initState = self.ent.hasBornState and EBTRootState.ST_Root_Born or EBTRootState.ST_Root_Idle

	self.currentRootState = initState
	self.lastRootState = nil
	self.currentBehaviorState = BehaviorPathMapData.EnumNameMap.PBT_Noop
	self.lastBehaviorState = nil

	return true
end

function IBaseStateMachineComponent:onRelease()
	self.currentRootState = nil
	self.lastRootState = nil
	self.currentBehaviorState = nil
	self.lastBehaviorState = nil
end

function IBaseStateMachineComponent:getRootState()
	return self.currentRootState
end

function IBaseStateMachineComponent:getRootStateName()
	return BaseEnum.EBTRootState_NAME[self:getRootState()]
end

function IBaseStateMachineComponent:getLastRootState()
	return self.lastRootState
end

function IBaseStateMachineComponent:_setRootState(state)
	if self.currentRootState == state then
		return
	end

	local oldRootState = self.currentRootState

	self:hideEmojiBubble()

	self.lastRootState = oldRootState
	self.currentRootState = state

	if oldRootState == EBTRootState.ST_Root_Combat then
		self:exitCombat()
	elseif oldRootState == EBTRootState.ST_Root_Follow then
		self:exitFollow()
	elseif oldRootState == EBTRootState.ST_Root_Guide then
		self:exitGuide()
	elseif oldRootState == EBTRootState.ST_Root_Wait then
		self:exitWait()
	end
end

function IBaseStateMachineComponent:tryChangeBehaviorState(behaviorState, forceBehaviorState)
	return self:tryChangeRootState(self:getRootState(), behaviorState, nil, forceBehaviorState)
end

function IBaseStateMachineComponent:tryChangeRootState(rootState, behaviorState, forceRootState, forceBehaviorState)
	if not behaviorState then
		if self:getRootState() == rootState then
			return true
		end

		behaviorState = self:getBaseBehaviorState(rootState)
	end

	if not forceRootState and not self:checkBehaviorStateBreak(rootState, behaviorState, forceBehaviorState) then
		return false
	end

	local oldRootState = self:getRootState()
	local oldBehaviorState = self:getBehaviorState()

	self:_setRootState(rootState)
	self:_setBehaviorState(behaviorState)
	self.ent:postComponentMethod("onAIStateChange", oldRootState, self:getRootState(), oldBehaviorState, self:getBehaviorState())
	self.ent:postComponentMethod("onAIStateChangeLater", oldRootState, self:getRootState())

	return true
end

function IBaseStateMachineComponent:checkBehaviorStateBreak(rootState, behaviorState, forceBehaviorState)
	if rootState > self:getRootState() then
		return true
	elseif self:getRootState() == rootState then
		return forceBehaviorState or self:getBehaviorState() ~= behaviorState
	end

	return false
end

function IBaseStateMachineComponent:checkInBeahviorState(behaviorState)
	return self:getBehaviorState() == behaviorState
end

function IBaseStateMachineComponent:resetRootState(fromState)
	if fromState == EBTRootState.ST_Root_Combat and self.isInCombat and self:isInCombat() then
		return EBTStatus.BT_FAILURE
	end

	local ret = self.OVERRIDE_resetRootState and self:OVERRIDE_resetRootState(fromState)

	return ret and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function IBaseStateMachineComponent:enterBorn()
	if self:getRootState() == EBTRootState.ST_Root_Born then
		return
	end

	return self:tryChangeRootState(EBTRootState.ST_Root_Born)
end

function IBaseStateMachineComponent:enterIdle(force)
	if self:getRootState() == EBTRootState.ST_Root_Idle then
		return
	end

	return self.OVERRIDE_enterIdle and self:OVERRIDE_enterIdle(force)
end

function IBaseStateMachineComponent:enterCombat(targetActorId)
	local ret = self.OVERRIDE_enterCombat and self:OVERRIDE_enterCombat(targetActorId)

	return ret and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function IBaseStateMachineComponent:exitCombat()
	return self.OVERRIDE_exitCombat and self:OVERRIDE_exitCombat()
end

function IBaseStateMachineComponent:enterDestroySelf()
	local ret = EBTStatus.BT_FAILURE

	if Utils.isPuppet(self.ent) and self:tryChangeRootState(EBTRootState.ST_Root_Dead, false, true, true) then
		ret = EBTStatus.BT_SUCCESS
	end

	return ret
end

function IBaseStateMachineComponent:enterWait()
	if Utils.isPet(self.ent) then
		return self:tryChangeRootState(EBTRootState.ST_Root_Wait, false, true, true)
	end
end

function IBaseStateMachineComponent:exitWait()
	if Utils.isPet(self.ent) then
		return self:resetRootState(EBTRootState.ST_Root_Wait)
	end
end

function IBaseStateMachineComponent:enterFollow(followTarget)
	if not followTarget or followTarget == 0 then
		followTarget = self.ent.getMasterEntity and self.ent:getMasterEntity().actorId
	end

	if pg.getEntityByActorId(followTarget) == nil then
		return false
	end

	self:setBlackBoardProperty("followTarget", followTarget)

	local ret = self:tryChangeRootState(EBTRootState.ST_Root_Follow, false, true)

	return ret and EBTStatus.BT_SUCCESS or EBTStatus.BT_FAILURE
end

function IBaseStateMachineComponent:exitFollow()
	self:setBlackBoardProperty("followTarget", 0)

	return self:resetRootState(EBTRootState.ST_Root_Follow)
end

function IBaseStateMachineComponent:enterGuide(guideTargetActorId)
	if not guideTargetActorId or guideTargetActorId == 0 then
		return false
	end

	self:setBlackBoardProperty("guideTargetActorId", guideTargetActorId)

	return self:tryChangeRootState(EBTRootState.ST_Root_Guide)
end

function IBaseStateMachineComponent:exitGuide()
	self:setBlackBoardProperty("guideTargetActorId", 0)

	return self:resetRootState(EBTRootState.ST_Root_Guide)
end

function IBaseStateMachineComponent:enterHomeLand()
	return self:tryChangeRootState(EBTRootState.ST_Root_HomeLand)
end

function IBaseStateMachineComponent:getBehaviorState()
	return self.currentBehaviorState
end

function IBaseStateMachineComponent:getLastBehaviorState()
	return self.lastBehaviorState
end

function IBaseStateMachineComponent:getBehaviorStateName()
	local behaviorState = self:getBehaviorState()

	return behaviorState and BehaviorPathMapData.EnumMap[behaviorState]
end

function IBaseStateMachineComponent:_setBehaviorState(state)
	if self.currentBehaviorState == state then
		return
	end

	self.lastBehaviorState = self.currentBehaviorState or BehaviorPathMapData.EnumNameMap.PBT_Noop
	self.currentBehaviorState = state
end

function IBaseStateMachineComponent:reset2BaseBehaviorState()
	local rootState = self:getRootState()

	self:tryChangeRootState(rootState, self:getBaseBehaviorState(rootState), true, true)

	return EBTStatus.BT_SUCCESS
end

function IBaseStateMachineComponent:getBaseBehaviorState(rootState)
	rootState = rootState or self:getRootState()

	local isPuppet = Utils.isPuppet(self.ent)

	if rootState == EBTRootState.ST_Root_Combat then
		local defaultCombatState = self:getBlackBoardProperty("Param_ST_AutoCombat")

		if defaultCombatState then
			local baseBehaviorStateName = BehaviorPathMapData.EnumNameMap[defaultCombatState]

			if baseBehaviorStateName then
				return baseBehaviorStateName
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR, "AI") then
				logger:error("当前状态机默认行为状态为", defaultCombatState, "不存在该行为树配置，检查一下导出配置")
			end
		end
	elseif rootState == EBTRootState.ST_Root_Idle then
		local defaultIdleState = self:getBlackBoardProperty("Param_ST_Idle")

		if defaultIdleState then
			local baseBehaviorStateName = BehaviorPathMapData.EnumNameMap[defaultIdleState]

			if baseBehaviorStateName then
				return baseBehaviorStateName
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR, "AI") then
				logger:error("当前状态机默认行为状态为", defaultIdleState, "不存在该行为树配置，检查一下导出配置")
			end
		end
	elseif rootState == EBTRootState.ST_Root_Alert then
		local defaultAlertState = self:getBlackBoardProperty("Param_ST_Alert")

		if defaultAlertState then
			local baseBehaviorStateName = BehaviorPathMapData.EnumNameMap[defaultAlertState]

			if baseBehaviorStateName then
				return baseBehaviorStateName
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR, "AI") then
				logger:error("当前状态机默认行为状态为", defaultAlertState, "不存在该行为树配置，检查一下导出配置")
			end
		end
	elseif rootState == EBTRootState.ST_Root_Sensed then
		local defaultSensedState = self:getBlackBoardProperty("Param_ST_Sensed")

		if defaultSensedState then
			local baseBehaviorStateName = BehaviorPathMapData.EnumNameMap[defaultSensedState]

			if baseBehaviorStateName then
				return baseBehaviorStateName
			end

			if LoggerManager.checkLogger(LoggerConst.ERROR, "AI") then
				logger:error("当前状态机默认行为状态为", defaultSensedState, "不存在该行为树配置，检查一下导出配置")
			end
		end
	end

	return isPuppet and AiConst.SMDefaultBaseState[rootState] or AiConst.PetSMDefaultBaseState[rootState]
end

function IBaseStateMachineComponent:getCurrentBehaviorPath()
	return self:getBehaviorStateName()
end

function IBaseStateMachineComponent:getSMDebugInfo()
	local rootStateName = self:getRootStateName() or ""
	local behaviorStateName = self:getBehaviorStateName() or ""

	return rootStateName .. "," .. behaviorStateName
end

return IBaseStateMachineComponent
