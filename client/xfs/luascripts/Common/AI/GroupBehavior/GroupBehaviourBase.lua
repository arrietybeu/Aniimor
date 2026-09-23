-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\GroupBehaviourBase.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourUtils = require("Common.Utils.GroupBehaviourUtils")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local FiniteStateMachine = require("Common.Container.FSM.FiniteStateMachine")
local AIUtils = require("Common.Utils.AIUtils")
local Utils = require("Common.Utils.Utils")
local GroupBehaviourBase = Class.LiteClass("GroupBehaviourBase")

function GroupBehaviourBase:ctor(behavType, behavName)
	self.behaviourType = behavType
	self.behaviourName = behavName
	self.parmonBehavId = nil
	self.fsm = FiniteStateMachine.new()
	self.taches = {}
	self.tacheKeyList = {}
	self.members = {}
	self.membersCount = 0
	self.memberData = nil
	self.bindResPoint = nil
	self.bindEnt = nil
	self.minStartMemberCount = -1
	self.minHoldMemberCount = -1
	self.maxMemberCount = -1
	self.cdTime = 0
	self.overrideVisionArea = nil
	self.tickCount = 0
	self.tickInterval = 1
end

function GroupBehaviourBase:init(...)
	self:onInit(...)
end

function GroupBehaviourBase:onInit(...)
	return
end

function GroupBehaviourBase:start()
	self:onStart()
end

function GroupBehaviourBase:onStart()
	return
end

function GroupBehaviourBase:update()
	self.tickCount = self.tickCount + 1

	if self.tickCount >= self.tickInterval then
		self.tickCount = 0

		self.fsm:onRun()
	end
end

function GroupBehaviourBase:destroy()
	self:onDestroy()

	local curTache = self.fsm._curState

	if curTache then
		curTache:onExit(self.fsm)
	end

	self.fsm._curState = nil

	self:unregisterAllMember()

	self.bindResPoint = nil
	self.minStartMemberCount = -1
	self.minHoldMemberCount = -1
	self.maxMemberCount = -1

	for _, tache in pairs(self.taches) do
		tache:onDestroy()
	end
end

function GroupBehaviourBase:onDestroy()
	return
end

function GroupBehaviourBase:addTache(tacheKey, tache)
	if not tacheKey or self.taches[tacheKey] then
		GroupBehaviourUtils.LogError("add tache error, key: %s, val: %s", tostring(tacheKey), tostring(tache))
	end

	self.taches[tacheKey] = tache

	table.insert(self.tacheKeyList, tacheKey)
	self.fsm:addState(tache)
	self.fsm:addState2AnyStateTransition(tacheKey)
end

function GroupBehaviourBase:hasTache(tacheKey)
	return self.taches[tacheKey] ~= nil
end

function GroupBehaviourBase:getNextTacheKey(curTacheKey)
	for index, tacheKey in ipairs(self.tacheKeyList) do
		if tacheKey == curTacheKey then
			if index ~= #self.tacheKeyList then
				return self.tacheKeyList[index + 1]
			end

			break
		end
	end
end

function GroupBehaviourBase:tryTransitionTo(tacheKey)
	local lastKey = self.fsm._curState._stateEnum

	if self.taches[tacheKey] then
		self.fsm:transitionTo(tacheKey)
	end

	if lastKey == GroupBehaviourConst.TacheDefine.CoolDown and tacheKey == GroupBehaviourConst.TacheDefine.MakeGroup then
		self:onStartMakeGroup()

		return
	end

	if lastKey == GroupBehaviourConst.TacheDefine.MakeGroup and tacheKey > GroupBehaviourConst.TacheDefine.MakeGroup then
		self:onStartRunning()

		return
	end

	if lastKey > GroupBehaviourConst.TacheDefine.MakeGroup and tacheKey == GroupBehaviourConst.TacheDefine.CoolDown then
		self:onEndRunning()
	end
end

function GroupBehaviourBase:onStartMakeGroup()
	self:refreshLevelItemStatus(GroupBehaviourConst.RunningState.MakeGroup)
end

function GroupBehaviourBase:onStartRunning()
	if self.bindResPoint then
		self.bindResPoint:onGroupBehavStartRunning()
	end

	self:refreshLevelItemStatus(GroupBehaviourConst.RunningState.Running)
end

function GroupBehaviourBase:onEndRunning()
	if self.bindResPoint then
		self.bindResPoint:onGroupBehavEndRunning()
	end

	self:refreshLevelItemStatus(GroupBehaviourConst.RunningState.None)
end

function GroupBehaviourBase:refreshLevelItemStatus(status)
	if self.bindResPoint and Utils.checkClient() then
		local sandBoxId = self.bindResPoint:getGroupBehaviourSandboxId()
		local levelItemId = self.bindResPoint:getGroupBehaviourLevelItemId()

		pg.me.space:setLevelItemState(sandBoxId, levelItemId, status)
	end
end

function GroupBehaviourBase:isRunning()
	if not self.fsm or not self.fsm._curState then
		return false
	end

	return self.fsm._curState._stateEnum > GroupBehaviourConst.TacheDefine.MakeGroup
end

function GroupBehaviourBase:isInCD()
	if not self.fsm or not self.fsm._curState then
		return false
	end

	return self.fsm._curState._stateEnum == GroupBehaviourConst.TacheDefine.CoolDown
end

function GroupBehaviourBase:registerMember(member)
	if table.getCount(self.members) >= self.maxMemberCount then
		return false
	end

	if table.contains(self.members, member) then
		return false
	end

	local memberIndex = self:checkMemberJoinCondition(member)

	if memberIndex < 0 then
		return false
	end

	GroupBehaviourUtils.LogWithBehav(self, "on member add, actorId: %d", member.actorId)

	self.members[memberIndex] = member
	self.membersCount = self.membersCount + 1

	member:onJoinGroupBehaviour(self)
	self:onMemberAdd(member)

	return true
end

function GroupBehaviourBase:checkMemberJoinCondition(member)
	for i = 1, self.maxMemberCount do
		if not self.members[i] then
			return i
		end
	end

	return -1
end

function GroupBehaviourBase:unregisterMember(member, index)
	GroupBehaviourUtils.LogWithBehav(self, "on member remove, actorId: %d", member.actorId)

	self.members[index or self:getMemberIndex(member)] = nil
	self.membersCount = self.membersCount - 1

	member:onExitCurrentGroupBehaviour()
	member:exitCurrentAIGroupPlan()
	AIUtils.resetRootState(member)
	self:onMemberRemove(member)
end

function GroupBehaviourBase:unregisterAllMember()
	local index, member = next(self.members)

	while index do
		self:unregisterMember(member, index)

		index, member = next(self.members, index)
	end
end

function GroupBehaviourBase:onMemberAdd(member)
	local curTache = self.fsm._curState

	if curTache then
		curTache:onMemberAdd(member)
	end
end

function GroupBehaviourBase:onMemberRemove(member)
	local curTache = self.fsm._curState

	if curTache then
		curTache:onMemberRemove(member)
	end
end

function GroupBehaviourBase:onMemberPlanInit(member, planType, planId)
	local curTache = self.fsm._curState

	if curTache then
		curTache:onMemberPlanInit(member, planType, planId)
	end
end

function GroupBehaviourBase:onMemberPlanFinish(member, planType, planId, finishType)
	local curTache = self.fsm._curState

	if curTache then
		curTache:onMemberPlanFinish(member, planType, planId, finishType)
	end
end

function GroupBehaviourBase:getMemberIndex(member)
	for idx, mb in pairs(self.members) do
		if mb == member then
			return idx
		end
	end

	return -1
end

function GroupBehaviourBase:getPreviousMember(member)
	local curMember, lastMember

	for i = 1, self.maxMemberCount do
		if self.members[i] then
			lastMember = curMember
			curMember = self.members[i]

			if curMember == member then
				return lastMember
			end
		end
	end
end

function GroupBehaviourBase:getMemberCount()
	return table.getCount(self.members)
end

function GroupBehaviourBase:getMemberActorIdList()
	local memberActorIds = {}

	for _, member in pairs(self.members) do
		table.insert(memberActorIds, member.actorId)
	end

	return memberActorIds
end

function GroupBehaviourBase:getCdTime()
	if self.bindResPoint and self.bindResPoint.photoId and Utils.checkClient() then
		local ClientUtils = require("Utils.ClientUtils")

		if ClientUtils.checkPhotoPetIsUnlock(self.bindResPoint.photoId) and not ClientUtils.checkPhotoTraitIsUnlock(self.bindResPoint.photoId) then
			return 0
		end
	end

	return self.cdTime
end

return GroupBehaviourBase
