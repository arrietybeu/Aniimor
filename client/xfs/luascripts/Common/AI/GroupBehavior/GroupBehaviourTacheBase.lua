-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\GroupBehaviourTacheBase.lua

local Class = require("Core.Framework.Class")
local State = require("Common.Container.FSM.State")
local GroupBehaviourUtils = require("Common.Utils.GroupBehaviourUtils")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local AiConst = require("Common.Const.AiConst")
local BehaviorTreePlanUtils = require("Common.Utils.BehaviorTreePlanUtils")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local CTRPool = require("Common.AICt.CTRPool")
local CTRConst = require("Common.AICt.CTRConst")
local GroupBehaviourTacheBase = Class.LiteClass("GroupBehaviourTacheBase", State)

function GroupBehaviourTacheBase:ctor(owner, stateKey)
	State.ctor(self, stateKey)

	self.owner = owner
	self.initFlags = {}
	self.finishFlags = {}
	self.timeoutTime = GroupBehaviourConst.TacheDefaultTimeout
	self.timeoutTimerId = nil
	self.isInBreak = false
	self.waitTreeParams = {
		tWaitTime = GroupBehaviourConst.DefaultWaitTime
	}
end

function GroupBehaviourTacheBase:onDestroy()
	return
end

function GroupBehaviourTacheBase:_getTriggerEventName(member)
	GroupBehaviourUtils.LogError("接口未实现, className: %s, methodName: _getTriggerEventName", self.className)
end

function GroupBehaviourTacheBase:_getTriggerContext(member, context)
	GroupBehaviourUtils.LogError("接口未实现, className: %s, methodName: _getTriggerContext", self.className)
end

function GroupBehaviourTacheBase:_getFinishBehavId(member)
	GroupBehaviourUtils.LogError("接口未实现, className: %s, methodName: _getFinishBehavId", self.className)
end

function GroupBehaviourTacheBase:onEnter(controller, oldState)
	GroupBehaviourUtils.LogWithTache(self, "on enter, old: %d, new: %d", oldState and oldState._stateEnum or -99999, self._stateEnum)
	self:_initFlags()
	self:_initTimeoutTimer()
	self:_initMember()
	self:_tryStart()

	self.isInBreak = false
end

function GroupBehaviourTacheBase:onRun(controller)
	return
end

function GroupBehaviourTacheBase:onExit(controller, nextState)
	self:_removeTimeoutTimer()
end

function GroupBehaviourTacheBase:onMemberAdd(member)
	self:_execTriggerToSingleMember(member)
end

function GroupBehaviourTacheBase:onMemberRemove(member)
	local isBreak = self:_tryBreak()

	if not isBreak then
		self:_tryFinish()
	end
end

function GroupBehaviourTacheBase:onMemberPlanInit(member, planType, planId)
	GroupBehaviourUtils.LogWithTache(self, "\ton member plan init, actorId: %d, planId: %s", member.actorId, planId)

	if planId == self:_getFinishBehavId(member) then
		self.initFlags[member.actorId] = true
	end
end

function GroupBehaviourTacheBase:onMemberPlanFinish(member, planType, planId, finishType)
	GroupBehaviourUtils.LogWithTache(self, "\ton member plan finish, actorId: %d, planId: %s, isBreakFinish: %d, waitTime: %d, isCurTachePlan: %s", member.actorId, planId, finishType, self.timeoutTime, self.initFlags[member.actorId] == true)

	if not self.initFlags[member.actorId] then
		return
	end

	if planId == self:_getFinishBehavId(member) then
		if finishType ~= CTRConst.FlowFinishType.Finish then
			member:exitCurrentGroupBehaviour()

			return
		end

		self.finishFlags[member.actorId] = true

		self:changeMemberToWait(member)
	end

	self:_tryFinish()
end

function GroupBehaviourTacheBase:changeMemberToWait(member)
	if member then
		local context = CTRPool.getContext()

		context.tWaitTime = GroupBehaviourConst.DefaultWaitTime

		AIControllerUtils.sendAIEvent(member, "GroupBehavWaitTrigger", context)
	end
end

function GroupBehaviourTacheBase:_initFlags()
	table.clear(self.initFlags)
	table.clear(self.finishFlags)
end

function GroupBehaviourTacheBase:_initTimeoutTimer()
	if self.timeoutTime > 0 then
		self.timeoutTimerId = TimerManager.addTimer(self.timeoutTime, function()
			self:_execBreak(false)
		end)
	end

	if UNITY_EDITOR then
		self.startTime = Time.realSecondCache
	end
end

function GroupBehaviourTacheBase:_initMember()
	for i = 1, self.owner.maxMemberCount do
		self:changeMemberToWait(self.owner.members[i])
	end
end

function GroupBehaviourTacheBase:_removeTimeoutTimer()
	if self.timeoutTimerId ~= nil then
		TimerManager.removeTimer(self.timeoutTimerId)

		self.timeoutTimerId = nil
	end

	if UNITY_EDITOR then
		self.startTime = nil
	end
end

function GroupBehaviourTacheBase:_tryStart()
	local condition = self:_checkStart()

	if condition then
		self:_execStart()
	end

	return condition
end

function GroupBehaviourTacheBase:_checkStart()
	return true
end

function GroupBehaviourTacheBase:_execStart()
	self:_execTriggerToAllMember()
end

function GroupBehaviourTacheBase:_tryBreak()
	local condition = self:_checkBreak()

	if condition then
		self:_execBreak(false)
	end

	return condition
end

function GroupBehaviourTacheBase:_checkBreak()
	if table.getCount(self.owner.members) < self.owner.minHoldMemberCount then
		return true
	end

	if self.owner.memberData then
		for i = 1, self.owner.maxMemberCount do
			if not self.owner.memberData[i].notMustNeed and not self.owner.members[i] then
				return true
			end
		end
	end

	return false
end

function GroupBehaviourTacheBase:_execBreak(isNormalFinish)
	if self.isInBreak then
		return
	end

	GroupBehaviourUtils.LogWithTache(self, "\ton break, isNormalFinish: %s", isNormalFinish)

	self.isInBreak = true

	self.owner:unregisterAllMember()
	self.owner:refreshLevelItemStatus(isNormalFinish and GroupBehaviourConst.RunningState.NormalFinish or GroupBehaviourConst.RunningState.AbnormalFinish)
	self.owner:tryTransitionTo(GroupBehaviourConst.TacheDefine.CoolDown)
end

function GroupBehaviourTacheBase:_tryFinish()
	local condition = self:_checkFinish()

	if condition then
		self:_execFinish()
	end

	return condition
end

function GroupBehaviourTacheBase:_checkFinish()
	for _, member in pairs(self.owner.members) do
		if not self.finishFlags[member.actorId] then
			return false
		end
	end

	return true
end

function GroupBehaviourTacheBase:_execFinish()
	table.clear(self.initFlags)
	table.clear(self.finishFlags)

	local nextTacheKey = self.owner:getNextTacheKey(self._stateEnum)

	if nextTacheKey then
		self.owner:tryTransitionTo(nextTacheKey)
	else
		self:_execBreak(true)
	end
end

function GroupBehaviourTacheBase:_execTriggerToAllMember()
	for _, member in pairs(self.owner.members) do
		self:_execTriggerToSingleMember(member)
	end
end

function GroupBehaviourTacheBase:_execTriggerToSingleMember(member)
	local eventName = self:_getTriggerEventName(member)
	local context = CTRPool.getContext()

	self:_getTriggerContext(member, context)
	AIControllerUtils.sendAIEvent(member, eventName, context)
end

function GroupBehaviourTacheBase:getMemberIndex(member)
	return self.owner:getMemberIndex(member)
end

function GroupBehaviourTacheBase:getBindResPoint()
	return self.owner.bindResPoint
end

return GroupBehaviourTacheBase
