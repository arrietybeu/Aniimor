-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\GroupBehavior\\CallFriends\\GBT_QueueFollow.lua

local Class = require("Core.Framework.Class")
local GroupBehaviourTacheBase = require("Common.AI.GroupBehavior.GroupBehaviourTacheBase")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local TacheDefine = GroupBehaviourConst.TacheDefine
local RECRUIT_FOLLOW_BEHAV_TAG = "TB_Recruit_FollowOneByOne"
local GBT_QueueFollow = Class.LiteClass("GBT_QueueFollow", GroupBehaviourTacheBase)

function GBT_QueueFollow:ctor(owner, stateKey)
	GroupBehaviourTacheBase.ctor(self, owner, stateKey)

	self.timeoutTime = -1
end

function GBT_QueueFollow:_execStart()
	return
end

function GBT_QueueFollow:onMemberAdd(member)
	self:_execTriggerToAllMember()
end

function GBT_QueueFollow:onMemberRemove(member)
	self:_execTriggerToAllMember()
end

function GBT_QueueFollow:onMemberPlanInit(member, planType, planId)
	return
end

function GBT_QueueFollow:onMemberPlanFinish(member, planType, planId)
	return
end

function GBT_QueueFollow:onRun()
	if self.owner:getClosestCallFriendEnvObj() then
		self.owner:tryTransitionTo(TacheDefine.Formation)

		return
	end

	self:_ensureFollow()
end

function GBT_QueueFollow:_ensureFollow()
	for _, member in pairs(self.owner.members) do
		local plan = member:getCurrentAIParmonPlan()

		if not plan or not plan:checkPlanBehavTag(RECRUIT_FOLLOW_BEHAV_TAG) then
			self:_execTriggerToSingleMember(member)
		end
	end
end

function GBT_QueueFollow:_getTriggerEventName(member)
	return "Event_Recruit_Follow"
end

function GBT_QueueFollow:_getTriggerContext(member, context)
	local previousMember = self.owner:getPreviousMember(member)

	context.followOneByOneActorId = previousMember and previousMember.actorId or self.owner.bindEnt.actorId
	context.recruitTargetActorId = self.owner.bindEnt.actorId
end

return GBT_QueueFollow
